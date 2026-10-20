from copy import deepcopy
from pathlib import Path
import json

ROOT=Path(__file__).resolve().parents[2]
RES=ROOT/'model-cloud-backend/src/main/resources'
def load(path): return json.loads(path.read_text(encoding='utf-8-sig'))
def save(path,value): path.write_text(json.dumps(value,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')

def build():
    folder=RES/'matlab-components/engine/configurations'
    config=load(folder/'engine.configuration.turboshaft.json')
    config.update(id='engine.configuration.hpcgv-turboshaft',name='HPCGV混动涡轴发动机',legacyName='hpcgv turboshaft',catalogOrder=12,
        description='单轴涡轴与可展开PMSM电磁热子系统耦合；设计、非设计匹配与工况扫描')
    template=config['templateDefinition']; scenes=template['scenes']
    pmsm=next(item for item in load(RES/'matlab-components/pmsm-components.json') if item['id']=='pmsm.subsystem.hpcgv')
    profile_scenes=deepcopy(pmsm['templateDefinition']['scenes'])
    prefix='hpcgv_'
    ids={node['id']:prefix+node['id'] for scene in profile_scenes.values() for node in scene['nodes']}
    for sceneid,scene in profile_scenes.items():
        scene['id']=prefix+sceneid
        for node in scene['nodes']:
            node['id']=ids[node['id']]
            if node.get('childSceneId'): node['childSceneId']=prefix+node['childSceneId']
            if node.get('modelEntrypoints'): node['modelEntrypoints']={mode:prefix+scene_id for mode,scene_id in node['modelEntrypoints'].items()}
        for edge in scene['dataEdges']:
            edge['id']=prefix+edge['id']; edge['sourceNodeId']=ids[edge['sourceNodeId']]; edge['targetNodeId']=ids[edge['targetNodeId']]
        for boundary in scene['boundaryPorts']:
            for mapping in [boundary.get('mapping'),*boundary.get('mappings',[])]:
                if mapping and mapping.get('childNodeId') in ids: mapping['childNodeId']=ids[mapping['childNodeId']]
        scenes[scene['id']]=scene
    members=scenes['assembly_relations']['nodes']
    motor=dict(id='pmsm_1',componentId=pmsm['id'],instanceName='HPCGV PMSM',legacyName='hpcgv pmsm',legacyOrder=2,
        nodeKind='subsystem',executionKind='subsystem',childSceneId=prefix+'main',
        modelEntrypoints={mode:prefix+'main' for mode in ['design','offdesign','thermal']},
        values={},resources={},assemblyDefaults={'TPR':1},position=dict(x=300,y=100))
    for i,node in enumerate(members):
        node['legacyOrder']=i+1 if i==0 else i+2
        values={'inlet_1':{'TPR':-1},'duct_1':{'TPR':.97},'hpc_1':{'TPR':1,'PRC':3.5,'EFFC':.85},
            'burn_1':{'TPR':.99,'EB':.99,'HU':43.124e6,'TO':1223},'hpt_1':{'TPR':1,'PRT':0,'EFFT':.89},'nozzle_1':{'TPR':.97}}
        node['assemblyDefaults'].update(values[node['id']])
    members.insert(1,motor)
    assembly=template['physicalAssemblies']['assembly_physical']
    assembly['name']='HPCGV混动涡轴发动机'
    assembly['defaults']['type']='hpcgv turboshaft'
    assembly['memberNodeIds'].insert(1,'pmsm_1')
    assembly['flowRelations'][0]['targetNodeId']='pmsm_1'
    assembly['flowRelations'].insert(1,dict(id='flow_pmsm_to_duct',kind='flow',sourceNodeId='pmsm_1',sourcePortId='OUTPUT',targetNodeId='duct_1',targetPortId='INPUT'))
    assembly['motorBindings']=[dict(motorNodeId='pmsm_1',shaftGroupId='shaft_1')]
    save(folder/'engine.configuration.hpcgv-turboshaft.json',config)
    fixture=ROOT/'contracts/matlab/fixtures/pmsm/hpcgv.project-v3.json'
    save(fixture,{**template,'schemaVersion':3,'engineType':'matlab'})
    print('Created hpcgv turboshaft with one physical motor member and three callable entry scenes')

if __name__=='__main__': build()
