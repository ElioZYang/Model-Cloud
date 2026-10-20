"""PMSM callable graphs keep the same validation boundary as outer graphs."""
import copy
import json
from pathlib import Path

import pytest
from app.executors.julia_matlab_graph_executor import JuliaMatlabGraphExecutor

ROOT = Path(__file__).resolve().parents[2]
FIXTURE = ROOT / 'contracts/matlab/fixtures/engine/engine.configuration.hpcgv-turboshaft.trusted-graph.json'

def graph():
    return json.loads(FIXTURE.read_text(encoding='utf-8'))

@pytest.mark.parametrize('fixture,schema', [
    ('pmsm/standalone.project-v3.json', 'matlab-project-v3.schema.json'),
    ('pmsm/hpcgv.project-v3.json', 'matlab-project-v3.schema.json'),
    ('engine/engine.configuration.hpcgv-turboshaft.trusted-graph.json',
     'matlab-execution-graph-v1.schema.json'),
])
def test_callable_project_and_graph_contracts(fixture, schema):
    jsonschema = pytest.importorskip('jsonschema')
    contracts = ROOT / 'contracts/matlab'
    document = json.loads((contracts / 'fixtures' / fixture).read_text(encoding='utf-8'))
    definition = json.loads((contracts / schema).read_text(encoding='utf-8'))
    jsonschema.Draft202012Validator(definition).validate(document)


def test_program_sources_and_entrypoints_are_validated():
    executor = JuliaMatlabGraphExecutor()
    payload = executor._validate_payload(graph())
    executor._validate_source_files(ROOT / 'model-cloud-backend/src/main/resources/static/matlab_component_source', payload)
    assert len(payload['modelPrograms']) == 1
    assert set(payload['modelPrograms'][0]['entries']) == {'design', 'offdesign', 'thermal'}

def test_hidden_program_cycles_are_rejected():
    payload = graph()
    entry = payload['modelPrograms'][0]['entries']['design']
    entry['executionOrder'].reverse()
    with pytest.raises(ValueError, match='executionOrder'):
        JuliaMatlabGraphExecutor()._validate_payload(payload)

def test_hidden_program_source_escape_is_rejected():
    payload = graph()
    payload['modelPrograms'][0]['entries']['design']['nodes'][0]['sourceRelativePath'] = '../escape.m'
    with pytest.raises(RuntimeError, match='源码路径'):
        JuliaMatlabGraphExecutor()._validate_source_files(ROOT / 'model-cloud-backend/src/main/resources/static/matlab_component_source', payload)

def test_program_registry_rejects_duplicate_ids_and_recursive_programs():
    payload = graph()
    payload['modelPrograms'].append(copy.deepcopy(payload['modelPrograms'][0]))
    with pytest.raises(ValueError, match='Duplicate'):
        JuliaMatlabGraphExecutor()._validate_payload(payload)
    payload = graph()
    payload['modelPrograms'][0]['entries']['design']['modelPrograms'] = [copy.deepcopy(payload['modelPrograms'][0])]
    with pytest.raises(ValueError, match='flat list'):
        JuliaMatlabGraphExecutor()._validate_payload(payload)


def test_internal_failure_retains_outer_call_and_inner_location():
    inner = dict(programId='motor', entrypoint='offdesign', nodeId='inner_begin',
                 sourceNodeId='begin', originPath=['motor', 'offdesign', 'begin'],
                 exceptionIdentifier='PMSM:InvalidPower')
    result = dict(failedNodeId='outer_motor', sourceNodeId=inner['sourceNodeId'],
                  originPath=inner['originPath'], details={'modelProgram': inner},
                  errorMessage='执行失败[PMSM:ProgramNodeFailed]：Power must be nonzero')
    error = JuliaMatlabGraphExecutor()._build_execution_error(result).structured()
    assert error['nodeId'] == 'outer_motor'
    assert error['sourceNodeId'] == 'begin'
    assert error['originPath'] == inner['originPath']
    assert error['details']['modelProgram']['entrypoint'] == 'offdesign'
