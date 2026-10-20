"""Restore the original standalone catalog and equations beside the hybrid model.

Component IDs and port contracts are retained. MATLAB names are prefixed so the
runner's shared genpath cannot select another model's same-named function.
"""
from pathlib import Path
import hashlib
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
REVISION = '152294e5da11c6a3d23c41ea19c7a35e736f8940'
RESOURCES = Path('model-cloud-backend/src/main/resources')
SOURCE = RESOURCES / 'static/matlab_component_source/PMSM'
DESTINATION = RESOURCES / 'static/matlab_component_source/PMSM_Independent'
PREFIX = 'mc_pmsm_ind_'


def original(path):
    return subprocess.check_output(['git', 'show', f'{REVISION}:{path.as_posix()}'], cwd=ROOT)


def restore():
    paths = subprocess.check_output(
        ['git', 'ls-tree', '-r', '--name-only', REVISION, str(SOURCE.as_posix())],
        cwd=ROOT, text=True).splitlines()
    functions = {Path(path).stem: PREFIX + Path(path).stem for path in paths if path.endswith('.m')}
    pattern = re.compile(r'\b(' + '|'.join(sorted(map(re.escape, functions), key=len, reverse=True)) + r')\b')
    hashes = {}
    for path in map(Path, paths):
        data = original(path)
        relative = path.relative_to(SOURCE)
        hashes[relative.as_posix()] = hashlib.sha256(data).hexdigest()
        if path.suffix == '.m':
            relative = relative.with_name(functions[path.stem] + '.m')
            try:
                text = data.decode('utf-8-sig')
            except UnicodeDecodeError:
                text = data.decode('gb18030')
            data = pattern.sub(lambda match: functions[match.group()], text).encode('utf-8')
        target = ROOT / DESTINATION / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
    catalog_path = RESOURCES / 'matlab-components/pmsm-components.json'
    catalog = json.loads(original(catalog_path))
    for component in catalog:
        function = component['functionName']
        component['functionName'] = functions[function]
        component['invocation']['function'] = functions[function]
        relative = Path(component['sourceRelativePath'])
        component['sourceRelativePath'] = relative.with_name(functions[function] + '.m').as_posix()
    output = ROOT / RESOURCES / 'matlab-components/pmsm-independent-components.json'
    output.write_text(json.dumps(catalog, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    schema = RESOURCES / 'matlab-components/pmsm-config-schema.json'
    (ROOT / schema.with_name('pmsm-independent-config-schema.json')).write_bytes(original(schema))
    provenance = dict(sourceRevision=REVISION, sourceDirectory=SOURCE.as_posix(),
                      functionPrefix=PREFIX, originalSha256=hashes)
    (ROOT / DESTINATION / 'provenance.json').write_text(
        json.dumps(provenance, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f'Restored {len(catalog)} components, {len(functions)} MATLAB files and the original workbook.')


if __name__ == '__main__':
    restore()
