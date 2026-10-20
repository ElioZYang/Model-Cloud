"""Execute a trusted MATLAB component graph through one Julia process and MATLAB session."""

from __future__ import annotations

import copy
import hashlib
import json
import math
import re
import subprocess
from pathlib import Path, PurePath
from threading import Lock
from typing import Any, Dict

from loguru import logger

from app.config import settings


MATLAB_IDENTIFIER = re.compile(r"^[A-Za-z][A-Za-z0-9_]*$")
MATLAB_FIELD_PATH = re.compile(
    r"^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)*$"
)
NAMED_BUS_TYPE = re.compile(
    r"^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)+$"
)
TRUSTED_MATLAB_COMPONENT_PREFIXES = ("pmsm.", "engine.")

def resolve_max_concurrent_sessions() -> int:
    """并发上限：MATLAB_MAX_CONCURRENT_SESSIONS 优先，缺省回落旧键；默认 1 串行。"""
    configured = getattr(settings, "MATLAB_MAX_CONCURRENT_SESSIONS", 0)
    if not configured:
        configured = getattr(settings, "MATLAB_MAX_CONCURRENT_TASKS", 1)
    return max(1, int(configured))


class MatlabSessionCoordinator:
    """封装 MATLAB 会话互斥访问；并发上限可配置，默认保持串行。"""

    def __init__(self, max_sessions: int | None = None):
        from threading import BoundedSemaphore

        self._semaphore = BoundedSemaphore(
            resolve_max_concurrent_sessions() if max_sessions is None else max(1, max_sessions)
        )

    def __enter__(self) -> "MatlabSessionCoordinator":
        self._semaphore.acquire()
        return self

    def __exit__(self, exc_type, exc, tb) -> bool:
        self._semaphore.release()
        return False


class GraphExecutionError(RuntimeError):
    """Execution failure carrying the structured nested-node location."""

    def __init__(self, message: str, detail: Dict[str, Any] | None = None):
        super().__init__(message)
        self.detail = detail or {}

    def structured(self) -> Dict[str, Any]:
        """matlab-public-result-v1.structuredError 投影。"""
        detail = self.detail or {}
        return {
            "stage": detail.get("stage", "execute-node"),
            "originPath": detail.get("originPath", []),
            "nodeId": detail.get("nodeId", detail.get("failedNodeId", "")),
            "sourceNodeId": detail.get("sourceNodeId", ""),
            "exceptionType": detail.get("exceptionType", "MATLAB"),
            "exceptionIdentifier": detail.get("exceptionIdentifier", ""),
            "message": str(self),
            "details": detail.get("details", {}),
        }


_MATLAB_FAILURE_IDENTIFIER = re.compile(r"\[([^\[\]]+)\]\s*：")


def resolve_matlab_component_root() -> Path:
    if not settings.MATLAB_COMPONENT_ROOT.strip():
        raise RuntimeError("未配置MATLAB_COMPONENT_ROOT")
    root = Path(settings.MATLAB_COMPONENT_ROOT).resolve()
    if not root.is_dir():
        raise RuntimeError(f"MATLAB_COMPONENT_ROOT不存在: {root}")
    return root


# 进程级共享协调器：所有 execute() 调用共用同一个信号量实例，
# 使 MATLAB_MAX_CONCURRENT_SESSIONS 对跨任务并发真正生效。
MATLAB_SESSION_COORDINATOR = MatlabSessionCoordinator()


class JuliaMatlabGraphExecutor:
    """Run scalar and structured components with one declarative graph contract."""

    def execute(self, task_id: str, execution_payload: Dict[str, Any]) -> Dict[str, Any]:
        graph = self._validate_payload(execution_payload)
        component_root = resolve_matlab_component_root()
        self._validate_source_files(component_root, graph)

        task_dir = (Path(settings.MATLAB_TASK_WORK_DIR).resolve() / task_id).resolve()
        task_dir.mkdir(parents=True, exist_ok=True)
        graph_path = task_dir / "trusted_graph.json"
        generated_path = task_dir / "generated_workflow.jl"
        result_path = task_dir / "result.json"
        stdout_path = task_dir / "julia_stdout.log"
        stderr_path = task_dir / "julia_stderr.log"

        runner_graph = self._prepare_resources(task_dir, graph)
        runner_graph["componentRoot"] = str(component_root)
        runner_graph["taskId"] = task_id
        graph_path.write_text(
            json.dumps(runner_graph, ensure_ascii=False, indent=2), encoding="utf-8"
        )

        command = self._build_command(graph_path, result_path, generated_path)
        logger.info(
            "开始执行统一Julia-MATLAB图任务: taskId={}, nodes={}, order={}",
            task_id,
            len(graph["nodes"]),
            graph["executionOrder"],
        )
        with MATLAB_SESSION_COORDINATOR:
            try:
                process = subprocess.run(
                    command,
                    cwd=str(task_dir),
                    capture_output=True,
                    text=True,
                    timeout=settings.MATLAB_TASK_TIMEOUT,
                    encoding="utf-8",
                    errors="replace",
                    shell=False,
                )
            except subprocess.TimeoutExpired as exc:
                raise RuntimeError(
                    f"Julia-MATLAB图任务执行超时({settings.MATLAB_TASK_TIMEOUT}秒)"
                ) from exc

        stdout = process.stdout or ""
        stderr = process.stderr or ""
        stdout_path.write_text(stdout[-20000:], encoding="utf-8")
        stderr_path.write_text(stderr[-20000:], encoding="utf-8")
        runner_result = None
        if result_path.is_file():
            try:
                runner_result = json.loads(result_path.read_text(encoding="utf-8"))
            except (OSError, json.JSONDecodeError) as exc:
                if process.returncode == 0:
                    raise RuntimeError(f"无法解析Julia图任务结果文件: {exc}") from exc
        if process.returncode != 0:
            if isinstance(runner_result, dict) and not runner_result.get("success"):
                raise self._build_execution_error(runner_result)
            message = stderr.strip() or stdout.strip() or "无错误输出"
            raise RuntimeError(
                f"Julia图任务进程执行失败(returnCode={process.returncode}): "
                f"{message[-4000:]}"
            )
        if not generated_path.is_file():
            raise RuntimeError("Julia图任务未生成generated_workflow.jl")
        if not isinstance(runner_result, dict):
            raise RuntimeError("Julia图任务执行完成但未生成有效result.json")
        if not runner_result.get("success"):
            raise self._build_execution_error(runner_result)

        return self.completed_result(runner_result, generated_path.read_text(encoding="utf-8"))

    def completed_result(self, runner_result: Dict[str, Any], generated_code: str) -> Dict[str, Any]:
        """Use the same public projection for live execution and completed-task recovery."""
        if not runner_result.get("success"):
            raise self._build_execution_error(runner_result)
        result_data: Dict[str, Any] = {
            "schemaVersion": "matlab.public-result.v1",
            "status": "completed",
            "engineType": "matlab",
            "executorType": "julia-matlab-graph",
            "executionOrder": runner_result.get("executionOrder", []),
            "nodeResults": runner_result.get("nodeResults", {}),
            "finalOutputs": runner_result.get("finalOutputs", {}),
            "publicOutputs": runner_result.get("publicOutputs", {}),
            "generatedCode": generated_code,
        }
        if runner_result.get("modelProgramResults"):
            result_data["modelProgramResults"] = runner_result["modelProgramResults"]
        # 非有限值投影：MATLAB jsonencode 已把 NaN/Inf 写为 JSON null；
        # 此处记录原字段路径，不改写数值、不替换为零。
        result_data["nonFinitePaths"] = collect_non_finite_paths(result_data)
        return {
            "resultData": result_data,
            # The runner's result file is task-internal; exposing its absolute
            # path would disclose the simulation host filesystem.
            "resultFileUrl": None,
        }

    def _build_execution_error(self, runner_result: Dict[str, Any]) -> GraphExecutionError:
        message = str(runner_result.get("errorMessage") or "MATLAB图任务执行失败")
        failed_node = runner_result.get("failedNodeId")
        if failed_node:
            message = f"{message}，失败节点={failed_node}"
        detail: Dict[str, Any] = {
            "stage": runner_result.get("stage", "execute-node"),
            "nodeId": failed_node or "",
            "sourceNodeId": runner_result.get("sourceNodeId", ""),
            "originPath": runner_result.get("originPath", []),
            "exceptionType": "MATLAB",
            "exceptionIdentifier": "",
            "details": runner_result.get("details", {}),
        }
        identifier_match = _MATLAB_FAILURE_IDENTIFIER.search(message)
        if identifier_match:
            detail["exceptionIdentifier"] = identifier_match.group(1)
        return GraphExecutionError(message, detail)

    def _validate_payload(self, payload: Dict[str, Any], _program: bool = False) -> Dict[str, Any]:
        if not isinstance(payload, dict):
            raise ValueError("MATLAB executionPayload不能为空")
        schema_version = payload.get("schemaVersion")
        if schema_version != "matlab.execution.v1":
            raise ValueError(
                "MATLAB executionPayload schemaVersion 不受支持: "
                f"{schema_version!r}（必须为 'matlab.execution.v1'；"
                "缺失版本不再默认接受）"
            )
        nodes = payload.get("nodes")
        edges = payload.get("edges")
        execution_order = payload.get("executionOrder")
        if not isinstance(nodes, list) or not nodes:
            raise ValueError("MATLAB图至少需要一个节点")
        if not isinstance(edges, list):
            raise ValueError("MATLAB图edges必须是数组")
        if not isinstance(execution_order, list) or len(execution_order) != len(nodes):
            raise ValueError("MATLAB图executionOrder不正确")

        nodes_by_id: dict[str, dict[str, Any]] = {}
        for node in nodes:
            if not isinstance(node, dict):
                raise ValueError("MATLAB图节点格式不正确")
            node_id = str(node.get("id") or "").strip()
            if not node_id or node_id in nodes_by_id:
                raise ValueError(f"MATLAB图节点ID为空或重复: {node_id}")
            nodes_by_id[node_id] = node
            if "originPath" in node and (
                not isinstance(node["originPath"], list)
                or any(not isinstance(part, str) or not part for part in node["originPath"])
            ):
                raise ValueError(f"MATLAB节点originPath不合法: {node_id}")
            execution_kind = str(node.get("executionKind") or "matlabFunction")
            if execution_kind in {"busCreator", "busSelector"}:
                self._validate_builtin_bus_node(node_id, node, execution_kind)
                continue
            component_id = str(node.get("componentId") or "")
            if not component_id.startswith(TRUSTED_MATLAB_COMPONENT_PREFIXES):
                raise ValueError(f"MATLAB组件ID不受信任: {node.get('componentId')}")
            function_name = str(node.get("functionName") or "")
            if not MATLAB_IDENTIFIER.fullmatch(function_name):
                raise ValueError(f"MATLAB函数名不合法: {function_name}")
            values = node.get("values")
            resources = node.get("resources")
            if not isinstance(values, dict) or not isinstance(resources, dict):
                raise ValueError(f"MATLAB节点values/resources必须是对象: {node_id}")
            for name, value in values.items():
                self._validate_literal(name, value, node_id)
            self._validate_ports(node_id, node.get("inputs"), "输入")
            self._validate_ports(node_id, node.get("outputs"), "输出")
            self._validate_invocation(node_id, node)

        node_ids = set(nodes_by_id)
        if set(map(str, execution_order)) != node_ids:
            raise ValueError("MATLAB图executionOrder与节点集合不一致")
        order_indexes = {
            str(node_id): index for index, node_id in enumerate(execution_order)
        }
        connected_targets: set[tuple[str, str]] = set()
        for edge in edges:
            if not isinstance(edge, dict):
                raise ValueError("MATLAB图连线格式不正确")
            source_node = str(edge.get("sourceNodeId") or "")
            target_node = str(edge.get("targetNodeId") or "")
            source_port = str(edge.get("sourcePort") or "")
            target_port = str(edge.get("targetPort") or "")
            if source_node not in node_ids or target_node not in node_ids:
                raise ValueError("MATLAB图连线引用不存在的节点")
            if order_indexes[source_node] >= order_indexes[target_node]:
                raise ValueError("MATLAB图executionOrder不符合连线依赖")
            source_types = self._port_types(nodes_by_id[source_node]["outputs"])
            target_types = self._port_types(nodes_by_id[target_node]["inputs"])
            if source_port not in source_types or target_port not in target_types:
                raise ValueError("MATLAB图连线引用不存在的端口")
            if not self._port_types_compatible(source_types[source_port], target_types[target_port]):
                raise ValueError("MATLAB图连线端口类型不兼容")
            target_key = (target_node, target_port)
            if target_key in connected_targets:
                raise ValueError("MATLAB图目标输入端口只能连接一次")
            connected_targets.add(target_key)

        for node_id, node in nodes_by_id.items():
            for port in node["inputs"]:
                has_bus_default = False
                if node.get("executionKind") == "busCreator":
                    fields = (node.get("busConfig") or {}).get("fields", [])
                    has_bus_default = any(
                        isinstance(field, dict)
                        and str(field.get("inputPortId") or field.get("id")) == str(port["name"])
                        and field.get("defaultValue") is not None
                        for field in fields
                    )
                if (
                    port.get("required")
                    and (node_id, port["name"]) not in connected_targets
                    and port["name"] not in node["values"]
                    and not has_bus_default
                ):
                    raise ValueError(f"MATLAB图缺少必需输入: {node_id}.{port['name']}")
        public_outputs = payload.get("publicOutputs", [])
        if not isinstance(public_outputs, list):
            raise ValueError("MATLAB图publicOutputs必须是数组")
        output_names: set[str] = set()
        for item in public_outputs:
            if not isinstance(item, dict):
                raise ValueError("MATLAB图publicOutputs格式不正确")
            name = str(item.get("name") or "")
            source_node = str(item.get("sourceNodeId") or "")
            source_port = str(item.get("sourcePort") or "")
            if not name or name in output_names or source_node not in node_ids:
                raise ValueError("MATLAB图publicOutputs引用不正确")
            if source_port not in self._port_types(nodes_by_id[source_node]["outputs"]):
                raise ValueError("MATLAB图publicOutputs端口不存在")
            output_names.add(name)
        programs = payload.get("modelPrograms", [])
        if not isinstance(programs, list) or (_program and programs):
            raise ValueError("PMSM modelPrograms must be a flat list of entrypoint programs")
        program_ids = set()
        total_nodes = 0
        for program in programs:
            if not isinstance(program, dict) or not isinstance(program.get("id"), str) or not program["id"]:
                raise ValueError("PMSM program id is required")
            if program["id"] in program_ids:
                raise ValueError("Duplicate PMSM program id")
            program_ids.add(program["id"])
            entries = program.get("entries")
            if not isinstance(entries, dict) or set(entries) != {"design", "offdesign", "thermal"}:
                raise ValueError("PMSM requires design/offdesign/thermal entrypoints")
            for mode, entry in entries.items():
                self._validate_payload(entry, _program=True)
                if entry.get("analysisMode") != mode:
                    raise ValueError(f"PMSM program analysisMode mismatch: expected {mode}")
                total_nodes += len(entry["nodes"])
                if total_nodes > 1000:
                    raise ValueError("PMSM programs exceed the node limit")
                if sum(node.get("componentId") == "pmsm.program.input" for node in entry["nodes"]) != 1:
                    raise ValueError("PMSM program requires exactly one input node")
                context_ids = {node['id'] for node in entry['nodes'] if node.get('componentId') == 'pmsm.program.input'}
                if any(edge['targetNodeId'] in context_ids for edge in entry['edges']):
                    raise ValueError('PMSM caller input cannot have an internal source')
                if any(not str(node.get("functionName", "")).startswith("mc_pmsm_") for node in entry["nodes"]):
                    raise ValueError("PMSM programs require catalog PMSM functions")
                if any(node.get("componentId") == "pmsm.program.execute" for node in entry["nodes"]):
                    raise ValueError("Recursive PMSM program calls are not supported")
                if any(node.get("componentId") == "pmsm.c.merge" for node in entry["nodes"]):
                    raise ValueError("PMSM compile-time model merge must be resolved before execution")
                if any(arg.get("source") != "input" for node in entry["nodes"] for arg in node["invocation"]["arguments"]):
                    raise ValueError("PMSM programs require explicit input bindings")
        return payload

    def _port_types_compatible(self, source_type: str, target_type: str) -> bool:
        if target_type == "unknown":
            return True
        if source_type == target_type:
            return True
        return target_type == "bus" and (
            source_type == "bus" or NAMED_BUS_TYPE.fullmatch(source_type) is not None
        )

    def _validate_builtin_bus_node(
        self, node_id: str, node: dict[str, Any], execution_kind: str
    ) -> None:
        expected_id = (
            "builtin.bus.creator" if execution_kind == "busCreator" else "builtin.bus.selector"
        )
        if node.get("componentId") != expected_id:
            raise ValueError(f"Bus节点componentId与executionKind不一致: {node_id}")
        if not isinstance(node.get("values"), dict) or not isinstance(node.get("resources"), dict):
            raise ValueError(f"Bus节点values/resources必须是对象: {node_id}")
        self._validate_ports(node_id, node.get("inputs"), "输入")
        self._validate_ports(node_id, node.get("outputs"), "输出")
        if execution_kind == "busCreator":
            config = node.get("busConfig")
            if not isinstance(config, dict):
                raise ValueError(f"Bus Creator缺少busConfig: {node_id}")
            fields = config.get("fields")
            if config.get("schemaMode", "anonymous") not in {"anonymous", "named"}:
                raise ValueError(f"Bus Creator结构模式不合法: {node_id}")
            if config.get("schemaMode", "anonymous") == "named" and not MATLAB_FIELD_PATH.fullmatch(
                str(config.get("schemaRef") or "")
            ):
                raise ValueError(f"Bus Creator命名结构标识不合法: {node_id}")
            if not isinstance(fields, list) or not fields:
                raise ValueError(f"Bus Creator字段不能为空: {node_id}")
            field_ports = set()
            for field in fields:
                self._validate_bus_field(field, node_id, "inputPortId")
                field_ports.add(str(field.get("inputPortId") or field.get("id")))
            paths = [str(field.get("path")) for field in fields]
            if any(
                left == right or left.startswith(right + ".") or right.startswith(left + ".")
                for index, left in enumerate(paths)
                for right in paths[index + 1 :]
            ):
                raise ValueError(f"Bus Creator字段存在覆盖关系: {node_id}")
            if set(self._port_types(node["inputs"])) != field_ports:
                raise ValueError(f"Bus Creator字段与输入端口不一致: {node_id}")
            output_types = self._port_types(node["outputs"])
            if set(output_types) != {"bus"}:
                raise ValueError(f"Bus Creator必须包含bus输出端口: {node_id}")
        else:
            config = node.get("selectorConfig")
            if not isinstance(config, dict):
                raise ValueError(f"Bus Selector缺少selectorConfig: {node_id}")
            selected = config.get("selectedFields", [])
            if not isinstance(selected, list):
                raise ValueError(f"Bus Selector字段列表不合法: {node_id}")
            if set(self._port_types(node["inputs"])) != {"bus"}:
                raise ValueError(f"Bus Selector必须包含bus输入端口: {node_id}")
            selected_ports = set()
            for field in selected:
                self._validate_bus_field(field, node_id, "outputPortId")
                selected_ports.add(str(field.get("outputPortId")))
            paths = [str(field.get("path")) for field in selected]
            if any(
                left == right or left.startswith(right + ".") or right.startswith(left + ".")
                for index, left in enumerate(paths)
                for right in paths[index + 1 :]
            ):
                raise ValueError(f"Bus Selector字段存在覆盖关系: {node_id}")
            if set(self._port_types(node["outputs"])) != selected_ports:
                raise ValueError(f"Bus Selector选择字段与输出端口不一致: {node_id}")

    def _validate_bus_field(self, field: Any, node_id: str, port_key: str) -> None:
        if not isinstance(field, dict):
            raise ValueError(f"Bus字段格式不正确: {node_id}")
        field_id = str(field.get("id") or "")
        path = str(field.get("path") or "")
        data_type = str(field.get("dataType") or "")
        port_id = str(field.get(port_key) or "")
        if not MATLAB_IDENTIFIER.fullmatch(field_id) or not MATLAB_FIELD_PATH.fullmatch(path):
            raise ValueError(f"Bus字段路径不合法: {node_id}.{path}")
        if not MATLAB_IDENTIFIER.fullmatch(port_id) or not data_type:
            raise ValueError(f"Bus字段类型或端口不合法: {node_id}.{path}")

    def _validate_invocation(self, node_id: str, node: dict[str, Any]) -> None:
        invocation = node.get("invocation")
        if not isinstance(invocation, dict):
            raise ValueError(f"MATLAB节点invocation必须是对象: {node_id}")
        if invocation.get("function") != node.get("functionName"):
            raise ValueError(f"MATLAB节点invocation函数不一致: {node_id}")
        input_names = set(self._port_types(node["inputs"]))
        resource_names = set(node["resources"])
        arguments = invocation.get("arguments")
        returns = invocation.get("returns")
        if not isinstance(arguments, list) or not isinstance(returns, list) or not returns:
            raise ValueError(f"MATLAB节点invocation定义不正确: {node_id}")
        for argument in arguments:
            if not isinstance(argument, dict):
                raise ValueError(f"MATLAB节点argument格式不正确: {node_id}")
            source = argument.get("source")
            if source == "input":
                if argument.get("name") not in input_names:
                    raise ValueError(f"MATLAB节点argument输入不存在: {node_id}")
            elif source == "object":
                bindings = argument.get("bindings", [])
                if not isinstance(bindings, list):
                    raise ValueError(f"MATLAB节点bindings必须是数组: {node_id}")
                for binding in bindings:
                    if not isinstance(binding, dict) or not MATLAB_FIELD_PATH.fullmatch(
                        str(binding.get("target") or "")
                    ):
                        raise ValueError(f"MATLAB节点binding target不合法: {node_id}")
                    if binding.get("source") == "input":
                        if binding.get("name") not in input_names:
                            raise ValueError(f"MATLAB节点binding输入不存在: {node_id}")
                    elif binding.get("source") == "resource":
                        if (
                            (
                                binding.get("name") not in resource_names
                                and not binding.get("optional")
                            )
                            or not MATLAB_IDENTIFIER.fullmatch(
                                str(binding.get("property") or "")
                            )
                        ):
                            raise ValueError(f"MATLAB节点binding资源不存在: {node_id}")
                    else:
                        raise ValueError(f"MATLAB节点binding source不受支持: {node_id}")
            else:
                raise ValueError(f"MATLAB节点argument source不受支持: {node_id}")
        output_names = set(self._port_types(node["outputs"]))
        mapped_outputs: set[str] = set()
        return_indexes: set[int] = set()
        return_targets: set[tuple[int, str]] = set()
        for item in returns:
            index = item.get("returnIndex") if isinstance(item, dict) else None
            path = str(item.get("path") or "") if isinstance(item, dict) else ""
            output = str(item.get("output") or "") if isinstance(item, dict) else ""
            if (
                isinstance(index, bool)
                or not isinstance(index, int)
                or index < 0
                or output not in output_names
                or output in mapped_outputs
                or (path and not MATLAB_FIELD_PATH.fullmatch(path))
                or (index, path) in return_targets
            ):
                raise ValueError(f"MATLAB节点return定义不正确: {node_id}")
            mapped_outputs.add(output)
            return_indexes.add(index)
            return_targets.add((index, path))
        if mapped_outputs != output_names or return_indexes != set(
            range(max(return_indexes) + 1)
        ):
            raise ValueError(f"MATLAB节点return映射不完整: {node_id}")

    def _validate_literal(self, name: Any, value: Any, node_id: str) -> None:
        if not MATLAB_IDENTIFIER.fullmatch(str(name)):
            raise ValueError(f"MATLAB节点值名称不合法: {node_id}.{name}")
        if isinstance(value, list):
            # Keep the same numeric vector/matrix contract as the Julia runner.
            matrix = bool(value) and isinstance(value[0], list)
            rows = value if matrix else [value]
            width = len(value[0]) if matrix else len(value)
            for row in rows:
                if not isinstance(row, list) or len(row) != width:
                    raise ValueError(f"MATLAB数值矩阵各行长度必须一致: {node_id}.{name}")
                for item in row:
                    if isinstance(item, bool) or not isinstance(item, (int, float)):
                        raise ValueError(f"MATLAB数组只支持一维或二维数值数组: {node_id}.{name}")
                    if isinstance(item, float) and not math.isfinite(item):
                        raise ValueError(f"MATLAB节点值必须是有限数值: {node_id}.{name}")
            return
        if isinstance(value, float) and not math.isfinite(value):
            raise ValueError(f"MATLAB节点值必须是有限数值: {node_id}.{name}")
        if not isinstance(value, (int, float, bool, str)):
            raise ValueError(f"MATLAB节点值类型不受支持: {node_id}.{name}")

    def _validate_ports(self, node_id: str, ports: Any, direction: str) -> None:
        if not isinstance(ports, list):
            raise ValueError(f"MATLAB节点{direction}端口必须是数组: {node_id}")
        names: set[str] = set()
        for port in ports:
            if not isinstance(port, dict):
                raise ValueError(f"MATLAB节点{direction}端口格式不正确: {node_id}")
            name = str(port.get("name") or "")
            data_type = str(port.get("type") or "")
            if not MATLAB_IDENTIFIER.fullmatch(name) or not data_type or name in names:
                raise ValueError(f"MATLAB节点{direction}端口定义不正确: {node_id}.{name}")
            names.add(name)

    def _port_types(self, ports: list[dict[str, Any]]) -> dict[str, str]:
        return {str(port["name"]): str(port["type"]) for port in ports}

    @staticmethod
    def _program_nodes(graph: Dict[str, Any]):
        yield from graph["nodes"]
        for program in graph.get("modelPrograms", []):
            for entry in program["entries"].values():
                yield from entry["nodes"]

    def _prepare_resources(
        self, task_dir: Path, graph: Dict[str, Any]
    ) -> Dict[str, Any]:
        prepared = copy.deepcopy(graph)
        for node in self._program_nodes(prepared):
            resources = node.get("resources") or {}
            for resource_name, metadata in resources.items():
                if not isinstance(metadata, dict):
                    raise ValueError(
                        f"MATLAB节点资源元数据格式不正确: {node['id']}.{resource_name}"
                    )
                relative_path = str(metadata.get("taskRelativePath") or "")
                relative = PurePath(relative_path)
                expected_hash = str(metadata.get("sha256") or "").lower()
                if not relative_path or relative.is_absolute() or ".." in relative.parts:
                    raise ValueError(f"MATLAB任务资源路径不合法: {resource_name}")
                if len(expected_hash) != 64 or any(
                    char not in "0123456789abcdef" for char in expected_hash
                ):
                    raise ValueError(f"MATLAB任务资源SHA-256不合法: {resource_name}")
                resource_path = (task_dir / relative_path).resolve()
                if task_dir != resource_path and task_dir not in resource_path.parents:
                    raise ValueError(f"MATLAB任务资源路径越界: {resource_name}")
                if not resource_path.is_file():
                    raise RuntimeError(f"MATLAB任务资源不存在: {relative_path}")
                actual_hash = hashlib.sha256(resource_path.read_bytes()).hexdigest()
                if actual_hash != expected_hash:
                    raise RuntimeError(f"MATLAB任务资源SHA-256校验失败: {resource_name}")
                metadata["filePath"] = str(resource_path)
        return prepared

    def _validate_source_files(self, component_root: Path, graph: Dict[str, Any]) -> None:
        for node in self._program_nodes(graph):
            if str(node.get("executionKind") or "matlabFunction") in {"busCreator", "busSelector"}:
                continue
            source_relative_path = str(node.get("sourceRelativePath") or "")
            source_path = PurePath(source_relative_path)
            function_name = str(node["functionName"])
            if (
                not source_relative_path
                or source_path.is_absolute()
                or ".." in source_path.parts
                or source_path.suffix.lower() != ".m"
                or source_path.stem != function_name
            ):
                raise RuntimeError(f"MATLAB源码路径不受信任: {source_relative_path}")
            resolved = (component_root / source_relative_path).resolve()
            if component_root != resolved and component_root not in resolved.parents:
                raise RuntimeError(f"MATLAB源码路径越界: {source_relative_path}")
            if not resolved.is_file():
                raise RuntimeError(f"MATLAB组件文件不存在: {source_relative_path}")

    def _build_command(
        self, graph_path: Path, result_path: Path, generated_path: Path
    ) -> list[str]:
        runner_path = Path(settings.JULIA_MATLAB_RUNNER_PATH)
        if not runner_path.is_absolute():
            runner_path = (Path.cwd() / runner_path).resolve()
        if not runner_path.is_file():
            raise RuntimeError(f"Julia图执行脚本不存在: {runner_path}")
        command = [settings.JULIA_PATH]
        if settings.JULIA_PROJECT_PATH.strip():
            command.append(f"--project={settings.JULIA_PROJECT_PATH}")
        command.extend(
            [str(runner_path), str(graph_path), str(result_path), str(generated_path)]
        )
        return command

def collect_non_finite_paths(value: Any, prefix: str = "") -> list[str]:
    """递归收集 JSON null（MATLAB NaN/Inf 投影）的点路径。

    MATLAB 结构体经 jsonencode 后不会产生真正的 null（空数组仍为 []），
    因此 null 路径即非有限值位置。
    """
    paths: list[str] = []
    if isinstance(value, dict):
        for key, item in value.items():
            child_prefix = f"{prefix}.{key}" if prefix else str(key)
            if item is None:
                paths.append(child_prefix)
            else:
                paths.extend(collect_non_finite_paths(item, child_prefix))
    elif isinstance(value, list):
        for index, item in enumerate(value):
            child_prefix = f"{prefix}[{index}]"
            if item is None:
                paths.append(child_prefix)
            else:
                paths.extend(collect_non_finite_paths(item, child_prefix))
    return paths
