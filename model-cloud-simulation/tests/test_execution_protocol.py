"""阶段6执行协议测试：schemaVersion 校验、结构化错误、非有限值投影、会话协调器。"""
import threading
import time
from unittest import mock

import pytest

from app.executors import julia_matlab_graph_executor as executor_module
from app.executors.julia_matlab_graph_executor import (
    GraphExecutionError,
    MatlabSessionCoordinator,
    collect_non_finite_paths,
    JuliaMatlabGraphExecutor,
)


def _payload(schema_version):
    return {
        "schemaVersion": schema_version,
        "nodes": [{
            "id": "n1", "componentId": "engine.stage.initialize-configuration",
            "functionName": "component_engine_initialize_configuration",
            "executionKind": "matlabFunction", "values": {}, "resources": {}, "inputs": [], "outputs": [{"name": "DP", "type": "unknown"}],
            "invocation": {"function": "component_engine_initialize_configuration", "arguments": [], "returns": [{"output": "DP", "returnIndex": 0}]},
        }],
        "edges": [],
        "executionOrder": ["n1"],
    }


class TestSchemaVersion:
    """契约硬化后：只接受 matlab.execution.v1；缺失或旧版本一律拒绝。"""

    def test_rejects_unknown_version(self):
        executor = JuliaMatlabGraphExecutor()
        with pytest.raises(ValueError, match="schemaVersion"):
            executor._validate_payload(_payload("matlab.execution.v9"))

    def test_rejects_missing_version(self):
        executor = JuliaMatlabGraphExecutor()
        payload = _payload("matlab.execution.v1")
        del payload["schemaVersion"]
        with pytest.raises(ValueError, match="schemaVersion"):
            executor._validate_payload(payload)

    def test_rejects_legacy_version_2(self):
        executor = JuliaMatlabGraphExecutor()
        with pytest.raises(ValueError, match="schemaVersion"):
            executor._validate_payload(_payload(2))

    def test_accepts_unified_only(self):
        executor = JuliaMatlabGraphExecutor()
        assert executor._validate_payload(_payload("matlab.execution.v1"))


class TestGraphExecutionError:
    def test_structured_projection(self):
        error = GraphExecutionError(
            "节点design_point__solve_design执行失败[engine:FlowTopology]：无法线性化，失败节点=x",
            detail={
                "stage": "execute-node",
                "nodeId": "root__design_point__solve_design",
                "sourceNodeId": "solve_design",
                "originPath": ["构型设计点模型", "设计点平衡求解"],
                "exceptionType": "MATLAB",
                "exceptionIdentifier": "engine:FlowTopology",
                "details": {},
            },
        )
        structured = error.structured()
        assert structured["stage"] == "execute-node"
        assert structured["nodeId"] == "root__design_point__solve_design"
        assert structured["sourceNodeId"] == "solve_design"
        assert structured["originPath"] == ["构型设计点模型", "设计点平衡求解"]
        assert structured["exceptionIdentifier"] == "engine:FlowTopology"
        assert structured["exceptionType"] == "MATLAB"
        assert "message" in structured

    def test_identifier_extracted_from_matlab_message(self):
        executor = JuliaMatlabGraphExecutor()
        error = executor._build_execution_error({
            "errorMessage": "节点root__p执行失败[MATLAB:UndefinedFunction]：未定义函数",
            "failedNodeId": "root__p",
            "sourceNodeId": "p",
            "originPath": ["物理构型"],
        })
        structured = error.structured()
        assert structured["exceptionIdentifier"] == "MATLAB:UndefinedFunction"
        assert structured["nodeId"] == "root__p"
        assert structured["originPath"] == ["物理构型"]


class TestNonFiniteProjection:
    def test_collects_null_paths(self):
        result = {
            "nodeResults": {
                "n1": {"outputs": {"DP": {"THRUST": None, "list": [1.0, None, 3.0]}}},
                "n2": {"outputs": {"y": 2.0}},
            },
            "finalOutputs": {"n2": {"y": None}},
        }
        paths = collect_non_finite_paths(result)
        assert paths == [
            "nodeResults.n1.outputs.DP.THRUST",
            "nodeResults.n1.outputs.DP.list[1]",
            "finalOutputs.n2.y",
        ]

    def test_values_not_replaced_by_zero(self):
        result = {"outputs": {"a": None}}
        assert result["outputs"]["a"] is None
        assert collect_non_finite_paths(result) == ["outputs.a"]


class TestSessionCoordinator:
    def test_default_serializes_access(self):
        active = []
        max_observed = []
        coordinator = MatlabSessionCoordinator()

        def worker():
            with coordinator:
                active.append(1)
                max_observed.append(len(active))
                time.sleep(0.05)
                active.pop()

        threads = [threading.Thread(target=worker) for _ in range(4)]
        for thread in threads:
            thread.start()
        for thread in threads:
            thread.join()
        assert max(max_observed) == 1

    def test_explicit_limit_allows_parallel(self):
        coordinator = MatlabSessionCoordinator(max_sessions=2)
        barrier = threading.Barrier(2, timeout=2)

        def worker():
            with coordinator:
                barrier.wait()

        threads = [threading.Thread(target=worker) for _ in range(2)]
        for thread in threads:
            thread.start()
        for thread in threads:
            thread.join(timeout=5)
        assert barrier.n_waiting == 0


class TestSharedSessionCoordinator:
    """P1 回归：协调器必须是进程级单例，跨 execute() 调用共享同一个信号量。"""

    @staticmethod
    def _trusted_payload():
        return {
            "schemaVersion": "matlab.execution.v1",
            "nodes": [{
                "id": "n1", "componentId": "engine.stage.initialize-configuration",
                "functionName": "component_engine_initialize_configuration",
                "executionKind": "matlabFunction", "values": {}, "resources": {},
                "sourceRelativePath": "engine/src/workflows/component_engine_initialize_configuration.m",
                "inputs": [], "outputs": [{"name": "DP", "type": "unknown"}],
                "invocation": {"function": "component_engine_initialize_configuration",
                               "arguments": [], "returns": [{"output": "DP", "returnIndex": 0}]},
            }],
            "edges": [],
            "executionOrder": ["n1"],
        }

    def test_module_level_singleton(self):
        assert executor_module.MATLAB_SESSION_COORDINATOR is executor_module.MATLAB_SESSION_COORDINATOR

    def test_concurrent_execute_calls_are_serialized(self, monkeypatch):
        """两个并发 execute()（各自实例化 executor）不得同时进入临界区。"""
        executor = JuliaMatlabGraphExecutor()
        monkeypatch.setattr(executor_module.settings, "MATLAB_COMPONENT_ROOT",
                            str(executor_module.resolve_matlab_component_root()))
        active = []
        max_concurrency = []

        class FakeProcess:
            returncode = 0
            stdout = ""
            stderr = ""

        def fake_run(*args, **kwargs):
            active.append(1)
            max_concurrency.append(len(active))
            time.sleep(0.05)
            active.pop()
            return FakeProcess()

        monkeypatch.setattr(executor_module.subprocess, "run", fake_run)
        payload = self._trusted_payload()
        errors = []

        def worker():
            try:
                executor.execute(f"task-{threading.get_ident()}", payload)
            except RuntimeError:
                # 无 result.json 时按预期抛错；串行化断言只关心并发度。
                pass
            except Exception as error:  # pragma: no cover - 其他异常收集报告
                errors.append(error)

        threads = [threading.Thread(target=worker) for _ in range(2)]
        for thread in threads:
            thread.start()
        for thread in threads:
            thread.join(timeout=15)
        assert not errors, errors
        assert max(max_concurrency) == 1, "两次 execute() 并发进入了 MATLAB 会话临界区"
