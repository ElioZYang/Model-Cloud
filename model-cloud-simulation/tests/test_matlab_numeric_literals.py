"""Numeric inputs must survive Python validation before reaching Julia/MATLAB."""
import json
from pathlib import Path

import pytest

from app.executors.julia_matlab_graph_executor import JuliaMatlabGraphExecutor


@pytest.mark.parametrize("value", [
    1000, 0.5, True, "assembly", [], [0, 0], [0, 1000, 500],
    [[1, 2], [3, 4]], [[1], [2]], [[]],
])
def test_supported_literals_preserve_values(value):
    before = json.dumps(value)
    JuliaMatlabGraphExecutor()._validate_literal("generator_power_kw", value, "design")
    assert json.dumps(value) == before


@pytest.mark.parametrize("value", [
    [True], ["1000"], [None], [{}], [[[1]]], [1, [2]],
    [[1, 2], [3]], [[1], 2], [float("nan")], [[float("inf")]],
    float("-inf"), {}, None,
])
def test_unsupported_literals_report_input_endpoint(value):
    with pytest.raises(ValueError, match=r"design\.generator_power_kw"):
        JuliaMatlabGraphExecutor()._validate_literal("generator_power_kw", value, "design")


@pytest.mark.parametrize("power", [1000, [0, 0], [0, 1000, 500]])
def test_complete_graph_accepts_scalar_and_multi_shaft_power(power):
    root = Path(__file__).resolve().parents[2]
    fixture = root / "contracts/matlab/fixtures/engine/engine.configuration.mixed-turbofan.trusted-graph.json"
    graph = json.loads(fixture.read_text(encoding="utf-8"))
    node = next(node for node in graph["nodes"] if "generator_power_kw" in node["values"])
    node["values"]["generator_power_kw"] = power
    port = next(port for port in node["inputs"] if port["name"] == "generator_power_kw")
    port["type"] = "array"
    validated = JuliaMatlabGraphExecutor()._validate_payload(graph)
    validated_node = next(item for item in validated["nodes"] if item["id"] == node["id"])
    assert validated_node["values"]["generator_power_kw"] == power
