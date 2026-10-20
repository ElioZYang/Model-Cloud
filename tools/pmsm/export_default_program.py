"""Export the three compiled semantic programs for independent PMSM execution."""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
source = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / 'model-cloud-backend/target/pmsm/standalone.trusted-graph.json'
graph = json.loads(source.read_text(encoding='utf-8'))
programs = {item['id']: item for item in graph.get('modelPrograms', [])}
selection = {'design': 'motor', 'offdesign': 'offdesign_motor', 'thermal': 'thermal_motor'}
result = {}
for mode, program_id in selection.items():
    entry = programs[program_id]['entries'][mode]
    if entry.get('analysisMode') != mode:
        raise ValueError(f'{program_id}.{mode} has an invalid analysisMode')
    result[mode] = entry
payload = json.dumps(result, ensure_ascii=False, indent=2) + '\n'
destinations = [
    ROOT / 'model-cloud-backend/src/main/resources/static/matlab_component_source/PMSM/src/default-program.json',
    Path(r'C:\Users\xiong\Documents\PMSM_Project\PMSM_moudle/shared/default-program.json'),
]
for destination in destinations:
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(payload, encoding='utf-8')
print('Exported compiled design, offdesign and thermal programs to library and standalone project')
