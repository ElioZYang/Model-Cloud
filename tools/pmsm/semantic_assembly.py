"""Assemble the PMSM from published components and real named-port edges."""
from copy import deepcopy
import json
from semantic_catalog import CATALOG,ROOT,definitions,port

class Scene:
    def __init__(self,id,title,catalog):
        self.value=dict(id=id,title=title,nodes=[],dataEdges=[],boundaryPorts=[],viewport=dict(x=0,y=0,zoom=1))
        self.catalog=catalog
    def node(self,id,key,**extra):
        item=self.catalog[key]
        n=dict(id=id,componentId=key,instanceName=item['name'],nodeKind='matlabFunction',values={},resources={},
               position=dict(x=len(self.value['nodes'])*310,y=100),**extra)
        self.value['nodes'].append(n)
        return id
    def edge(self,source,output,target,input):
        self.value['dataEdges'].append(dict(id=f"e{len(self.value['dataEdges'])}",sourceNodeId=source,sourcePort=output,targetNodeId=target,targetPort=input))
    def input(self,name,*targets):
        p=port(name)
        mappings=[dict(childNodeId=node,childPortId=target) for node,target in targets]
        self.value['boundaryPorts'].append(dict(id=name,name=name,kind='data',direction='input',dataType=p['type'],
            required=True,mapping=mappings[0],mappings=mappings))
    def output(self,name,node,output):
        self.value['boundaryPorts'].append(dict(id=name,name=name,kind='data',direction='output',dataType=port(name)['type'],
            mapping=dict(childNodeId=node,childPortId=output)))

def wrapper(id,name,child,**kw):
    return dict(id=id,componentId='project.subsystem.'+child,instanceName=name,nodeKind='subsystem',executionKind='subsystem',
                childSceneId=child,values={},resources={},position=dict(x=0,y=0),**kw)

def remap(scenes,prefix):
    result=deepcopy(scenes)
    ids={node['id']:prefix+node['id'] for s in result.values() for node in s['nodes']}
    for sid,s in result.items():
        s['id']=prefix+sid
        for n in s['nodes']:
            n['id']=ids[n['id']]
            if n.get('childSceneId'): n['childSceneId']=prefix+n['childSceneId']
            if n.get('modelEntrypoints'): n['modelEntrypoints']={m:prefix+v for m,v in n['modelEntrypoints'].items()}
        for e in s['dataEdges']:
            e['id']=prefix+e['id']; e['sourceNodeId']=ids[e['sourceNodeId']]; e['targetNodeId']=ids[e['targetNodeId']]
        for b in s['boundaryPorts']:
            for mapping in [b.get('mapping'),*b.get('mappings',[])]:
                if mapping and mapping['childNodeId'] in ids: mapping['childNodeId']=ids[mapping['childNodeId']]
    return {s['id']:s for s in result.values()}

def build():
    catalog=definitions(); by={i['id']:i for i in catalog}
    c=lambda key:'pmsm.c.'+key
    design=Scene('design','电磁设计',by)
    for id,key in [('design_prepare','prepare-design'),('dimensions','dimensions'),('stator','stator'),('rotor','rotor'),
                   ('mass','mass'),('design_losses','losses'),('design_performance','performance'),('design_model','assemble')]:
        design.node(id,c(key))
    for n in ['configuration','power_kw','speed_rpm']: design.input(n,('design_prepare',n))
    design.edge('design_prepare','configuration','dimensions','configuration')
    design.edge('design_prepare','operatingPoint','dimensions','operatingPoint')
    for target in ['stator','rotor','mass','design_losses','design_performance']:
        design.edge('dimensions','configuration',target,'configuration')
        design.edge('design_prepare','operatingPoint',target,'operatingPoint')
    for src,dst in [('dimensions','stator'),('stator','rotor'),('rotor','mass'),('mass','design_losses'),('mass','design_performance'),('mass','design_model')]:
        design.edge(src,'geometry',dst,'geometry')
    for target in ['rotor','mass','design_losses','design_model']: design.edge('stator','slot',target,'slot')
    for target in ['mass','design_losses','design_performance','design_model']: design.edge('stator','winding',target,'winding')
    for target in ['mass','design_losses','design_model']: design.edge('rotor','magnet',target,'magnet')
    for target in ['design_losses','design_performance','design_model']: design.edge('mass','mass',target,'mass')
    for target in ['design_performance','design_model']: design.edge('design_losses','losses',target,'losses')
    design.edge('dimensions','configuration','design_model','configuration')
    design.edge('design_performance','performance','design_model','performance')
    design.output('motorModel','design_model','motorModel')

    off=Scene('offdesign','非设计点更新',by)
    for id,key in [('off_operating','off-operating'),('off_losses','off-losses'),('off_performance','off-performance'),('off_model','off-assemble')]: off.node(id,c(key))
    off.input('designModel',('off_operating','motorModel'),('off_losses','motorModel'),('off_performance','motorModel'),('off_model','designModel'))
    for n in ['power_kw','speed_rpm']: off.input(n,('off_operating',n))
    for target in ['off_losses','off_performance']: off.edge('off_operating','operatingPoint',target,'operatingPoint')
    for target in ['off_performance','off_model']: off.edge('off_losses','losses',target,'losses')
    off.edge('off_performance','performance','off_model','performance'); off.output('motorModel','off_model','motorModel')

    thermal=Scene('thermal','热分析',by)
    for id,key in [('thermal_boundary','boundary'),('thermal_geometry','thermal-geometry'),('flow_state','flow'),('thermal_material','material'),
                   ('cooling_network','network-hpcgv'),('thermal_solve','solve'),('outlet','outlet'),('thermal_apply','apply-thermal')]: thermal.node(id,c(key))
    thermal.input('motorModel',*[(n,'motorModel') for n in ['thermal_geometry','thermal_material','cooling_network']])
    thermal_inputs=['T','P','WA','FAR','D','EFFH','temp_Fe','temp_Cu','free_temperature_mask','mode','TPR_ref','WCOR_ref']
    for n in thermal_inputs: thermal.input(n,('thermal_boundary',n))
    for target in ['flow_state','cooling_network','outlet','thermal_apply']: thermal.edge('thermal_boundary','thermalBoundary',target,'thermalBoundary')
    for target in ['flow_state','thermal_material','cooling_network','outlet','thermal_apply']: thermal.edge('thermal_geometry','thermalGeometry',target,'thermalGeometry')
    for target in ['cooling_network','outlet']: thermal.edge('flow_state','flowState',target,'flowState')
    thermal.edge('thermal_material','materialProperties','cooling_network','materialProperties')
    thermal.edge('cooling_network','thermalNetwork','thermal_solve','thermalNetwork')
    thermal.edge('cooling_network','coolingFlow','outlet','coolingFlow')
    for target in ['outlet','thermal_apply']: thermal.edge('cooling_network','motorModel',target,'motorModel')
    for target in ['outlet','thermal_apply']: thermal.edge('thermal_solve','thermalResult',target,'thermalResult')
    thermal.edge('outlet','outletFlow','thermal_apply','outletFlow')
    for name,node in [('motorModel','thermal_apply'),('outletFlow','outlet'),('thermalResult','thermal_solve')]: thermal.output(name,node,name)

    main=Scene('main','PMSM完整计算流程',by)
    main.node('caller_input','pmsm.program.input'); main.node('request',c('request'))
    main.value['nodes'] += [wrapper('electromagnetic_design','电磁设计','design',activeModes=['design']),
                            wrapper('operating_update','非设计点更新','offdesign',activeModes=['offdesign'])]
    main.node('existing_model',c('existing-model'),activeModes=['thermal'])
    main.node('model_merge',c('merge'))
    main.value['nodes'].append(wrapper('thermal_analysis','热分析','thermal'))
    main.node('final_output',c('output'))
    positions=[(0,280),(360,280),(800,0),(800,380),(800,760),(1230,280),(1620,280),(2100,280)]
    for node,(x,y) in zip(main.value['nodes'],positions): node['position']=dict(x=x,y=y)
    main.edge('caller_input','INPUT','request','INPUT')
    for n in ['configuration','power_kw','speed_rpm']: main.edge('request',n,'electromagnetic_design',n)
    for n in ['designModel','power_kw','speed_rpm']: main.edge('request',n,'operating_update',n)
    main.edge('request','designModel','existing_model','designModel')
    for node,portname in [('electromagnetic_design','designModel'),('operating_update','offdesignModel'),('existing_model','existingModel')]:
        main.edge(node,'motorModel','model_merge',portname)
    main.edge('model_merge','motorModel','thermal_analysis','motorModel')
    for n in thermal_inputs: main.edge('request','thermalMode' if n=='mode' else n,'thermal_analysis',n)
    main.edge('caller_input','INPUT','final_output','INPUT')
    main.edge('thermal_analysis','motorModel','final_output','motorModel')
    main.edge('thermal_analysis','outletFlow','final_output','outletFlow')
    main.input('INPUT',('caller_input','INPUT')); main.output('OUTPUT','final_output','OUTPUT')
    scenes={s.value['id']:s.value for s in [main,design,off,thermal]}
    subsystem=dict(id='pmsm.subsystem.hpcgv',name='PMSM电磁热子系统',engineType='matlab',executorType='julia-matlab-graph',
        componentKind='subsystem',functionName='',sourceRelativePath='',category='PMSM子系统',legacyName='hpcgv pmsm',
        iconRelativePath='defaults/matlab-function.svg',fallbackIconRelativePath='defaults/matlab-function.svg',inputs=[port('INPUT')],outputs=[port('OUTPUT')],resources=[],
        physicalCapabilities=by['pmsm.program.execute']['physicalCapabilities'],assemblyDefaults={'TPR':1},
        modelEntrypoints={mode:'main' for mode in ['design','offdesign','thermal']},
        templateDefinition=dict(rootSceneId='main',scenes=deepcopy(scenes),physicalAssemblies={}))
    catalog.append(subsystem)
    root=Scene('standalone','独立PMSM项目',by)
    root.node('configuration','pmsm.configuration')
    previous='configuration'; previous_port='INPUT'
    for mode,motor_id in [('design','motor'),('offdesign','offdesign_motor'),('thermal','thermal_motor')]:
        prefix=mode+'_instance_'; scenes.update(remap(subsystem['templateDefinition']['scenes'],prefix))
        if mode!='design':
            req=mode+'_request'; root.node(req,'pmsm.offdesign-input' if mode=='offdesign' else 'pmsm.thermal-input')
            root.edge(previous,previous_port,req,'design' if mode=='offdesign' else 'result')
            previous=req; previous_port='INPUT'
        motor=wrapper(motor_id,{'design':'设计点PMSM','offdesign':'非设计点PMSM','thermal':'热分析PMSM'}[mode],prefix+'main')
        motor['componentId']=subsystem['id']; motor['modelEntrypoints']={m:prefix+'main' for m in ['design','offdesign','thermal']}
        root.value['nodes'].append(motor); root.edge(previous,previous_port,motor_id,'INPUT')
        previous=motor_id; previous_port='OUTPUT'
    # The unprefixed scenes belong to the reusable subsystem, not the project.
    project_scenes={k:v for k,v in scenes.items() if k not in {'main','design','offdesign','thermal'}}
    for index,node in enumerate(root.value['nodes']): node['position']=dict(x=index*400,y=100)
    project_scenes['standalone']=root.value
    project=dict(schemaVersion=3,engineType='matlab',rootSceneId='standalone',scenes=project_scenes,physicalAssemblies={})
    standalone=deepcopy(subsystem)
    standalone.update(id='pmsm.project.standalone',name='独立PMSM工程',category='PMSM项目',inputs=[],outputs=[],templateDefinition={k:project[k] for k in ['rootSceneId','scenes','physicalAssemblies']})
    for key in ['physicalCapabilities','legacyName','assemblyDefaults','modelEntrypoints']: standalone.pop(key,None)
    catalog.append(standalone)
    CATALOG.write_text(json.dumps(catalog,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    (ROOT/'contracts/matlab/fixtures/pmsm/standalone.project-v3.json').write_text(json.dumps(project,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(f'Assembled one connected main scene, 3 functional subscenes, {len(catalog)} catalog entries')

if __name__=='__main__': build()
