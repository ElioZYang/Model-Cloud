"""统一契约（contracts/matlab）解析测试。

黄金夹具由后端 EngineGoldenFixtureTest 生成（mvn test -Dgolden.update=true），
此处用 JSON Schema 验证三构型的工程文档与展开图仍然符合版本化契约。
"""
import json
from pathlib import Path

import pytest

jsonschema = pytest.importorskip("jsonschema")

REPO_ROOT = Path(__file__).resolve().parents[2]
CONTRACTS = REPO_ROOT / "contracts" / "matlab"
FIXTURES = CONTRACTS / "fixtures" / "engine"

CONFIGURATIONS = [
    "engine.configuration.ducted-fan",
    "engine.configuration.turboshaft",
    "engine.configuration.mixed-turbofan",
]


def _load_schema(name: str) -> dict:
    with open(CONTRACTS / name, "r", encoding="utf-8") as handle:
        return json.load(handle)


def _load_fixture(name: str) -> dict:
    with open(FIXTURES / name, "r", encoding="utf-8") as handle:
        return json.load(handle)


@pytest.mark.parametrize("configuration", CONFIGURATIONS)
def test_project_fixture_conforms_to_project_v3_schema(configuration: str) -> None:
    """文件名保留历史引用，内容明确符合 V3 装配域契约。"""
    document = _load_fixture(f"{configuration}.project-v2.json")
    jsonschema.validate(document, _load_schema("matlab-project-v3.schema.json"))
    assert document["schemaVersion"] == 3
    for scene in document["scenes"].values():
        assert "kind" not in scene
        assert "relationGroups" not in scene
        for edge in scene["dataEdges"]:
            assert not {"relation", "streamRole", "groupId"}.intersection(edge)


@pytest.mark.parametrize("configuration", CONFIGURATIONS)
def test_trusted_graph_fixture_conforms_to_execution_graph_schema(configuration: str) -> None:
    """trusted 图（真实提交形态）符合收紧后的 matlab-execution-graph-v1 契约。"""
    graph = _load_fixture(f"{configuration}.trusted-graph.json")
    jsonschema.validate(graph, _load_schema("matlab-execution-graph-v1.schema.json"))
    assert graph["schemaVersion"] == "matlab.execution.v1"
    order = graph["executionOrder"]
    node_ids = [node["id"] for node in graph["nodes"]]
    assert sorted(order) == sorted(node_ids), "executionOrder 必须恰好覆盖全部节点"
    assert len(set(order)) == len(order), "executionOrder 不允许重复"


@pytest.mark.parametrize("configuration", CONFIGURATIONS)
def test_expanded_graph_fixture_structure(configuration: str) -> None:
    """展开层夹具（模板级锚）：结构性质断言，不跑 v1 schema（其 schemaVersion=2 为展开器内部格式）。"""
    graph = _load_fixture(f"{configuration}.expanded-graph.json")
    assert graph["schemaVersion"] == 2
    assert graph["nodes"] and graph["edges"] is not None


@pytest.mark.parametrize("configuration", CONFIGURATIONS)
def test_trusted_graph_edges_reference_known_nodes(configuration: str) -> None:
    """trusted 图的边只能引用存在的节点，且 dataType 来自受信源端口。"""
    graph = _load_fixture(f"{configuration}.trusted-graph.json")
    node_ids = {node["id"] for node in graph["nodes"]}
    for edge in graph["edges"]:
        assert edge["sourceNodeId"] in node_ids, edge
        assert edge["targetNodeId"] in node_ids, edge
        assert edge.get("dataType"), edge


@pytest.mark.parametrize("configuration", CONFIGURATIONS)
def test_expanded_graph_edges_reference_known_nodes(configuration: str) -> None:
    """展开图的边只能引用展开后存在的节点与端口。"""
    graph = _load_fixture(f"{configuration}.expanded-graph.json")
    node_ids = {node["id"] for node in graph["nodes"]}
    for edge in graph["edges"]:
        assert edge["sourceNodeId"] in node_ids, edge
        assert edge["targetNodeId"] in node_ids, edge


@pytest.mark.parametrize("configuration", CONFIGURATIONS)
def test_initialization_node_carries_assembly_json(configuration: str) -> None:
    """初始化节点的 values 中携带 assembly_json（物理装配输入）。"""
    graph = _load_fixture(f"{configuration}.expanded-graph.json")
    initializer = graph["nodes"][0]
    assert initializer["componentId"] == "engine.stage.initialize-configuration"
    assembly = json.loads(initializer["values"]["assembly_json"])
    # 阶段5起 Java 只产出 EnginePhysicalSceneV1；发动机语义由 MATLAB 推导。
    assert assembly["schemaVersion"] == "engine.physical-scene.v1"
    for field in ("sceneId", "nodes", "edges", "relationGroups", "assemblyDefaults"):
        assert field in assembly, f"{configuration} 缺少装配字段 {field}"
    for legacy in ("F", "SHAFT", "EXT", "NS", "NW", "WA_extraction"):
        assert legacy not in assembly, f"{configuration} 不应再由 Java 计算 {legacy}"
