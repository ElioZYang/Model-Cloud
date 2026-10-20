from pathlib import Path
import json

root=Path(__file__).resolve().parents[2]/'contracts/matlab'
def read(name): return json.loads((root/name).read_text(encoding='utf-8-sig'))
def save(name,value): (root/name).write_text(json.dumps(value,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
project=read('matlab-project-v3.schema.json')
boundary=project['$defs'].get('boundaryPort')
if boundary:
    boundary['required']=['id','name','kind']
    boundary['properties']['defaultValue']={'type':['number','string','boolean','array']}
for definition in project['$defs'].values():
    props=definition.get('properties',{})
    if 'childSceneId' in props:
        props['modelEntrypoints']={'type':'object','required':['design','offdesign','thermal'],
            'properties':{mode:{'type':'string','minLength':1} for mode in ['design','offdesign','thermal']},'additionalProperties':False}
    if 'shaftGroups' in props:
        props['motorBindings']={'type':'array','items':{'type':'object','required':['motorNodeId','shaftGroupId'],
            'properties':{'motorNodeId':{'type':'string'},'shaftGroupId':{'type':'string'}},'additionalProperties':False}}
save('matlab-project-v3.schema.json',project)
execution=read('matlab-execution-graph-v1.schema.json')
execution['properties']['modelPrograms']={'type':'array','items':{'type':'object','required':['id','entries'],
    'properties':{'id':{'type':'string','minLength':1},'entries':{'type':'object','required':['design','offdesign','thermal'],
    'properties':{mode:{'$ref':'#'} for mode in ['design','offdesign','thermal']},'additionalProperties':False}},'additionalProperties':False}}
save('matlab-execution-graph-v1.schema.json',execution)
physical=read('engine-physical-scene-v1.schema.json')
physical['properties']['motorBindings']={'type':'array','items':{'type':'object','required':['motorNodeId','shaftGroupId'],
    'properties':{'motorNodeId':{'type':'string'},'shaftGroupId':{'type':'string'}},'additionalProperties':False}}
save('engine-physical-scene-v1.schema.json',physical)
public=read('matlab-public-result-v1.schema.json')
public['properties']['modelProgramResults']={'type':'array','items':{'type':'object'}}
save('matlab-public-result-v1.schema.json',public)
