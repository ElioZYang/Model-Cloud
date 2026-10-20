from pathlib import Path
import json
import sys

root=Path(__file__).resolve().parents[2]
source=Path(sys.argv[1])
label=sys.argv[2]
graph=json.loads(source.read_text(encoding='utf-8'))
graph['componentRoot']=str(root/'model-cloud-backend/src/main/resources/static/matlab_component_source')
folder=root/'tools/pmsm/verification'/label
folder.mkdir(parents=True,exist_ok=True)
(folder/'graph.json').write_text(json.dumps(graph,ensure_ascii=False),encoding='utf-8')
print(folder)
