"""Audit a real Julia result through the public projection and artifact collector."""
from collections import Counter
import argparse
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'model-cloud-simulation'))

from jsonschema import Draft202012Validator
from app.artifacts import collect_artifacts, project_result_data
from app.executors.julia_matlab_graph_executor import JuliaMatlabGraphExecutor


def verify(folder: Path) -> dict:
    raw = json.loads((folder / 'result.json').read_text(encoding='utf-8'))
    projected = JuliaMatlabGraphExecutor().completed_result(
        raw, (folder / 'generated_workflow.jl').read_text(encoding='utf-8'))
    manifest, files = collect_artifacts('pmsm-verification', projected, folder)
    data = project_result_data(projected['resultData'], manifest)
    data['artifacts'] = manifest
    schema = json.loads((ROOT / 'contracts/matlab/matlab-public-result-v1.schema.json')
                        .read_text(encoding='utf-8'))
    Draft202012Validator(schema).validate(data)
    report = dict(passed=True, outerNodes=len(raw['executionOrder']),
                  resultNodes=len(raw['nodeResults']),
                  programSnapshots=len(raw.get('modelProgramResults', [])),
                  artifactsByPhase=dict(Counter(a['phase'] for a in manifest)))
    if 'root__scan__scan_finalize' in raw['nodeResults']:
        outputs = raw['nodeResults']['root__scan__scan_finalize']['outputs']
        diagnostics = outputs['MISSION_final']['G']['pmsmSolverDiagnostics']
        assert len(diagnostics) == 220
        assert all(d['converged'] and d['exitflag'] > 0 for d in diagnostics)
        report['scanPoints'] = len(diagnostics)
        report['maxNormalizedResidual'] = max(d['normalized_residual'] for d in diagnostics)
        assert report['maxNormalizedResidual'] <= 1e-6
        assert report['artifactsByPhase'] == dict(design=1, power=3, final=3)
    (folder / 'public-result.json').write_text(
        json.dumps(data, ensure_ascii=False), encoding='utf-8')
    (folder / 'artifact-files.json').write_text(
        json.dumps(files, ensure_ascii=False, indent=2), encoding='utf-8')
    (folder / 'verification-report.json').write_text(
        json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
    return report


def verify_failure(folder: Path) -> dict:
    raw = json.loads((folder / 'result.json').read_text(encoding='utf-8'))
    assert raw['success'] is False
    error = JuliaMatlabGraphExecutor()._build_execution_error(raw).structured()
    data = dict(schemaVersion='matlab.public-result.v1', status='failed',
                nodeResults={}, error=error)
    schema = json.loads((ROOT / 'contracts/matlab/matlab-public-result-v1.schema.json')
                        .read_text(encoding='utf-8'))
    Draft202012Validator(schema).validate(data)
    report = dict(passed=True, nodeId=error['nodeId'], sourceNodeId=error['sourceNodeId'],
                  originPath=error['originPath'], stage=error['stage'])
    inner = error['details'].get('modelProgram')
    if inner:
        assert error['originPath'] == inner['originPath']
        assert error['sourceNodeId'] == inner['sourceNodeId']
        assert inner['entrypoint'] in {'design', 'offdesign', 'thermal'}
        report['entrypoint'] = inner['entrypoint']
        report['originalException'] = inner['exceptionIdentifier']
    (folder / 'public-error.json').write_text(
        json.dumps(data, ensure_ascii=False), encoding='utf-8')
    (folder / 'verification-report.json').write_text(
        json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('folder', type=Path)
    parser.add_argument('--failure', action='store_true')
    args = parser.parse_args()
    operation = verify_failure if args.failure else verify
    print(json.dumps(operation(args.folder.resolve()), ensure_ascii=False, indent=2))
