"""Build explicit, semantic-port components from the untouched engine equations.

This step deliberately does not publish a catalog or assemble an editor template.
"""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import re
import shutil

ROOT = Path(__file__).resolve().parents[2]
LIB = ROOT / 'model-cloud-backend/src/main/resources/static/matlab_component_source/PMSM/src'
spec = importlib.util.spec_from_file_location('pmsm_source', Path(__file__).with_name('sync_pmsm.py'))
source = importlib.util.module_from_spec(spec)
spec.loader.exec_module(source)


def build(reference: Path, standalone: Path):
    generated = {p.stem: p.read_text(encoding='utf-8')
                 for p in Path(__file__).with_name('components').glob('*.m')}
    functions = {}
    for directory in ['Pmsm/geometry', 'Pmsm/losses', 'Pmsm/thermal', 'Thermodynamics-v1']:
        for p in (reference / directory).glob('*.m'):
            body = source.read(p)
            if re.search(r'(?m)^\s*function\b', body):
                functions[p.stem] = (p, body)
    def rename(body):
        for name in sorted(functions, key=len, reverse=True):
            body = re.sub(r'\b' + re.escape(name) + r'\b', 'mc_pmsm_' + name, body)
        return body
    # Dependencies, not monolithic PMSM entry functions.
    for name, (_, body) in functions.items():
        if name in {'PMSM_thermal_network', 'thermal_model_vv'}:
            continue
        generated['mc_pmsm_' + name] = rename(body)
    geometry_path = reference / 'Pmsm/thermal/get_pmsm_geometry.m'
    geometry = source.read(geometry_path)
    geometry = geometry[geometry.index('% 几何参数'):]
    geometry_names = sorted(source.assigned(geometry))
    export = ',...\n'.join(f"'{name}',{name}" for name in geometry_names)
    generated['mc_pmsm_c_thermal_geometry'] = (
        'function thermalGeometry=mc_pmsm_c_thermal_geometry(motorModel)\n'
        'pmsm_params=motorModel;\n' + geometry + '\nthermalGeometry=struct(' + export + ');\nend\n')
    groups = dict(thermalGeometry=geometry_names,
                  flowState=['W','WA','K','WCOR','M_in','Ts_amb','Ps_amb','Vel','rhos'],
                  materialProperties=['t_iso','k_iso','k_cu','k_stator','k_housing','k_cavity','k_slot'],
                  thermalBoundary=['T','P','FAR','D','EFFH','T_Fe','T_Cu'])
    reference_paths = [geometry_path]
    for kind in ['air', 'hpcgv', 'liquid']:
        path = reference / f'Pmsm/thermal/build_thermal_network_{kind}.m'
        reference_paths.append(path)
        body = source.read(path)
        cut = re.search(r'(?m)^\s*\[dTdt\s*,\s*T_thermal_balance\]\s*=', body)
        assert cut, path
        body = body[:cut.start()]
        assert 'thermal_balance_solver(' not in body
        imports = '\n'.join(f'{name}={group}.{name};'
                            for group, names in groups.items() for name in names
                            if re.search(r'\b' + name + r'\b', body))
        cooling_id = {'air': 1, 'hpcgv': 2, 'liquid': 3}[kind]
        generated['mc_pmsm_c_network_' + kind] = (
            f'function [thermalNetwork,coolingFlow,motorModel]=mc_pmsm_c_network_{kind}'
            '(motorModel,thermalGeometry,flowState,materialProperties,thermalBoundary)\n'
            'pmsm_params=motorModel;\n' + imports + '\n' + rename(body) +
            "\nthermalNetwork=struct('R',R,'C',C,'PW_in',PW_in,'T_in',T_in,'LM1',LM1,'LM2',LM2,'Q_Fe',Q_Fe,'Q_Cu',Q_Cu);\n"
            f"coolingFlow=struct('Re_cgv',Re_cgv);\nmotorModel.input.cooling={cooling_id};\nend\n")
    generated['mc_pmsm_PMSM_design'] = '''function motorModel=mc_pmsm_PMSM_design(configuration,power_kw,speed_rpm)
[c,op]=mc_pmsm_c_prepare_design(configuration,power_kw,speed_rpm,0);
[c,g]=mc_pmsm_c_dimensions(c,op);
[g,s,w]=mc_pmsm_c_stator(c,op,g);
[g,mag]=mc_pmsm_c_rotor(c,op,g,s);
[g,mass]=mc_pmsm_c_mass(c,op,g,s,w,mag);
losses=mc_pmsm_c_losses(c,op,g,s,w,mag,mass);
performance=mc_pmsm_c_performance(c,op,g,w,mass,losses);
motorModel=mc_pmsm_c_assemble(c,g,s,w,mag,mass,losses,performance);
end
'''
    generated['mc_pmsm_PMSM_off_design'] = '''function motorModel=mc_pmsm_PMSM_off_design(designModel,power_kw,speed_rpm)
op=mc_pmsm_c_off_operating(designModel,power_kw,speed_rpm);
losses=mc_pmsm_c_off_losses(designModel,op);
performance=mc_pmsm_c_off_performance(designModel,op,losses);
motorModel=mc_pmsm_c_off_assemble(designModel,losses,performance);
end
'''
    generated['mc_pmsm_PMSM_thermal_network'] = '''function OUTPUT=mc_pmsm_PMSM_thermal_network(INPUT)
model=INPUT.pmsm_params; values=model.thermal.temp_values; names=model.thermal.temp_variables;
refTPR=1; refWCOR=1;
if isfield(INPUT,'TPR'), refTPR=INPUT.TPR; end
if isfield(INPUT,'WCOR'), refWCOR=INPUT.WCOR; end
b=mc_pmsm_c_boundary(INPUT.T,INPUT.P,INPUT.WA,INPUT.FAR,INPUT.D,INPUT.EFFH,...
    values(strcmpi(names,'temp_Fe')),values(strcmpi(names,'temp_Cu')),[false;false],INPUT.mode,refTPR,refWCOR);
g=mc_pmsm_c_thermal_geometry(model); f=mc_pmsm_c_flow(g,b); material=mc_pmsm_c_material(model,g);
switch model.input.cooling
case 1, [network,cooling,model]=mc_pmsm_c_network_air(model,g,f,material,b);
case 2, [network,cooling,model]=mc_pmsm_c_network_hpcgv(model,g,f,material,b);
case 3, [network,cooling,model]=mc_pmsm_c_network_liquid(model,g,f,material,b);
otherwise, error('PMSM:InvalidCooling','Unsupported cooling');
end
thermal=mc_pmsm_c_solve(network);
outlet=mc_pmsm_c_outlet(model,g,b,f,cooling,thermal);
model=mc_pmsm_c_apply_thermal(model,g,b,thermal,outlet);
OUTPUT=INPUT; OUTPUT.T=outlet.T; OUTPUT.P=outlet.P;
OUTPUT.TPR=outlet.TPR; OUTPUT.WCOR=outlet.WCOR; OUTPUT.pmsm_params=model;
end
'''
    for name in ['PMSM_design', 'PMSM_off_design']:
        reference_paths.append(reference / f'Pmsm/{name}.m')
    reference_paths.append(reference / 'Pmsm/thermal/PMSM_thermal_network.m')
    reference_paths.extend(p for p, _ in functions.values())
    manifest = dict(version='semantic-components-v2', reference=str(reference),
                    files={str(p.relative_to(reference)):hashlib.sha256(p.read_bytes()).hexdigest()
                           for p in set(reference_paths)})
    for dest in [LIB, standalone / 'shared']:
        for name, body in generated.items(): source.write(dest / 'core' / (name + '.m'), body)
        runtime = Path(__file__).with_name('matlab')
        for helper in runtime.glob('*.m'):
            shutil.copyfile(helper, dest / 'core' / helper.name)
        source.write(dest / 'provenance.json', json.dumps(manifest, ensure_ascii=False, indent=2))
        (dest / 'input').mkdir(exist_ok=True, parents=True)
        shutil.copyfile(reference / 'Input/pmsm input.xlsx', dest / 'input/pmsm input.xlsx')
    print(f'Generated explicit components and dependencies: {len(generated)} files')


if __name__ == '__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('--reference', type=Path, required=True)
    parser.add_argument('--standalone', type=Path, required=True)
    args=parser.parse_args()
    build(args.reference, args.standalone)
