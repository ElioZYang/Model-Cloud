"""Serialization failures retain the actual output location and diagnostics."""
from app.executors.julia_matlab_graph_executor import JuliaMatlabGraphExecutor


def test_complex_serialization_error_preserves_output_location():
    executor = object.__new__(JuliaMatlabGraphExecutor)
    fields = [{"path": "$.THRUST_REF", "shape": [1, 1], "indices": [1]}]
    result = {
        "failedNodeId": "root__solve_design",
        "stage": "serialize-output",
        "originPath": ["设计点模型", "设计点平衡求解"],
        "errorMessage": "输出端口=DP，复数字段=$.THRUST_REF\n执行失败[MATLAB:json:UnsupportedComplexDataType]：无法编码复数",
        "details": {"outputPort": "DP", "complexFields": fields},
    }
    error = executor._build_execution_error(result)
    assert error.detail["stage"] == "serialize-output"
    assert error.detail["nodeId"] == "root__solve_design"
    assert error.detail["details"] == result["details"]
    assert error.detail["exceptionIdentifier"] == "MATLAB:json:UnsupportedComplexDataType"
    assert error.structured()["details"]["complexFields"] == fields


def test_legacy_execution_error_keeps_default_stage():
    executor = object.__new__(JuliaMatlabGraphExecutor)
    error = executor._build_execution_error({"failedNodeId": "node", "errorMessage": "failure"})
    assert error.detail["stage"] == "execute-node"
    assert error.detail["details"] == {}
