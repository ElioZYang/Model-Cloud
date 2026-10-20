"""PMSM component declarations, separate from assembly templates."""
from pathlib import Path
import json

ROOT=Path(__file__).resolve().parents[2]
CATALOG=ROOT/'model-cloud-backend/src/main/resources/matlab-components/pmsm-components.json'
NUMBERS={'power_kw':'kW','speed_rpm':'rpm','T':'K','P':'Pa','WA':'kg/s','FAR':'','D':'','EFFH':'',
         'temp_Fe':'degC','temp_Cu':'degC','TPR_ref':'','WCOR_ref':'','B_g_override':'T'}

def port(name,**kw):
    if name in NUMBERS: typ='number'; kw.setdefault('unit',NUMBERS[name])
    elif name in {'mode','thermalMode','program_id'}: typ='string'
    elif name=='free_temperature_mask': typ='array'
    elif name in {'INPUT','OUTPUT'}: typ='bus'
    else: typ='pmsm.'+({'designModel':'motorModel','geometry_in':'geometry','configuration_in':'configuration'}.get(name,name))
    return {'name':name,'type':typ,'required':True,'description':name,**kw}

def component(key,label,function,inputs,outputs,category='PMSM计算组件'):
    return dict(id='pmsm.c.'+key,name=label,engineType='matlab',executorType='julia-matlab-graph',
        componentKind='calculation',functionName='mc_pmsm_c_'+function,category=category,
        sourceRelativePath='core/mc_pmsm_c_'+function+'.m',iconRelativePath='defaults/matlab-function.svg',
        fallbackIconRelativePath='defaults/matlab-function.svg',inputs=[port(n) for n in inputs],outputs=[port(n) for n in outputs],resources=[],
        invocation=dict(function='mc_pmsm_c_'+function,arguments=[dict(source='input',name=n) for n in inputs],
                        returns=[dict(output=n,returnIndex=i,path='') for i,n in enumerate(outputs)]))

def definitions():
    specs=[
      ('prepare-design','设计工况与参数','prepare_design',['configuration','power_kw','speed_rpm','B_g_override'],['configuration','operatingPoint']),
      ('dimensions','电机主尺寸','dimensions',['configuration','operatingPoint'],['configuration','geometry']),
      ('stator','定子槽形与绕组','stator',['configuration','operatingPoint','geometry'],['geometry','slot','winding']),
      ('rotor','转子与磁钢','rotor',['configuration','operatingPoint','geometry','slot'],['geometry','magnet']),
      ('mass','质量与冷却结构','mass',['configuration','operatingPoint','geometry','slot','winding','magnet'],['geometry','mass']),
      ('losses','设计点损耗','losses',['configuration','operatingPoint','geometry','slot','winding','magnet','mass'],['losses']),
      ('performance','设计点性能','performance',['configuration','operatingPoint','geometry','winding','mass','losses'],['performance']),
      ('assemble','组装设计电机模型','assemble',['configuration','geometry','slot','winding','magnet','mass','losses','performance'],['motorModel']),
      ('off-operating','非设计点工况','off_operating',['motorModel','power_kw','speed_rpm'],['operatingPoint']),
      ('off-losses','非设计点损耗','off_losses',['motorModel','operatingPoint'],['losses']),
      ('off-performance','非设计点性能','off_performance',['motorModel','operatingPoint','losses'],['performance']),
      ('off-assemble','组装工作点模型','off_assemble',['designModel','losses','performance'],['motorModel']),
      ('existing-model','已有电机模型','existing_model',['designModel'],['motorModel']),
      ('thermal-geometry','热分析几何','thermal_geometry',['motorModel'],['thermalGeometry']),
      ('flow','冷却流动状态','flow',['thermalGeometry','thermalBoundary'],['flowState']),
      ('material','材料热物性','material',['motorModel','thermalGeometry'],['materialProperties']),
      ('boundary','热边界配置','boundary',['T','P','WA','FAR','D','EFFH','temp_Fe','temp_Cu','free_temperature_mask','mode','TPR_ref','WCOR_ref'],['thermalBoundary']),
      ('solve','热平衡求解','solve',['thermalNetwork'],['thermalResult']),
      ('outlet','出口状态与压损','outlet',['motorModel','thermalGeometry','thermalBoundary','flowState','coolingFlow','thermalResult'],['outletFlow']),
      ('apply-thermal','热结果回写','apply_thermal',['motorModel','thermalGeometry','thermalBoundary','thermalResult','outletFlow'],['motorModel']),
      ('output','功率与最终结果','output',['INPUT','motorModel','outletFlow'],['OUTPUT']),
      ('merge','电机模型合流','merge',['designModel','offdesignModel','existingModel'],['motorModel']),
    ]
    result=[component(*spec) for spec in specs]
    for item in result:
        for p in item['inputs']:
            if p['name']=='B_g_override': p.update(required=False,defaultValue=0,description='气隙磁密覆盖值；0沿用配置')
            if item['id']=='pmsm.c.merge': p.update(type='pmsm.motorModel',required=False)
    for kind,label in [('air','空气冷却网络'),('hpcgv','HPCGV冷却网络'),('liquid','液冷网络')]:
        result.append(component('network-'+kind,label,'network_'+kind,
            ['motorModel','thermalGeometry','flowState','materialProperties','thermalBoundary'],['thermalNetwork','coolingFlow','motorModel']))
    fields=['configuration','designModel','power_kw','speed_rpm','T','P','WA','FAR','D','EFFH',
            'temp_Fe','temp_Cu','free_temperature_mask','thermalMode','TPR_ref','WCOR_ref']
    request=component('request','工况与配置输入','request',['INPUT'],fields)
    request['invocation']['returns']=[dict(output=n,returnIndex=0,path=n) for n in fields]
    result.insert(0,request)
    old=json.loads(CATALOG.read_text(encoding='utf-8-sig'))
    keep={'pmsm.program.input','pmsm.program.execute','pmsm.configuration','pmsm.offdesign-input','pmsm.thermal-input'}
    result.extend(item for item in old if item['id'] in keep)
    assert len([i for i in result if i['id'] in keep])==len(keep)
    for item in result:
        if item['id'] == 'pmsm.program.execute':
            item['hiddenFromCatalog']=True
        else:
            item.pop('hiddenFromCatalog', None)
    return result

def publish_components():
    result=definitions()
    CATALOG.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(f'Published {len(result)} component declarations (no subsystem template yet)')

if __name__=='__main__': publish_components()
