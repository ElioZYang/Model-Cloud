"""Build the shared PMSM components from the read-only engine reference.

Run with --reference and --standalone. Equations are copied, not rederived.
Generated stages use explicit state imports/exports (no eval or base workspace).
"""
from pathlib import Path
import argparse
import hashlib
import json
import re
import shutil

REPO = Path(__file__).resolve().parents[2]
LIB = REPO / 'model-cloud-backend/src/main/resources/static/matlab_component_source/PMSM'


def write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding='utf-8')


def read(path):
    try:
        return path.read_text(encoding='utf-8-sig')
    except UnicodeDecodeError:
        return path.read_text(encoding='gb18030')


def assigned(source):
    # Original model statements have one assignment per line; keep indexed and
    # struct assignments as an update to their root variable.
    result = set(re.findall(r'(?m)^\s*([A-Za-z]\w*)(?:\([^=\n]*\)|\.[^=\n]*)?\s*=(?!=)', source))
    for group in re.findall(r'\[([^\]\n]+)\]\s*=', source):
        result.update(re.findall(r'[A-Za-z]\w*', group))
    result.update(re.findall(r'\bfor\s+([A-Za-z]\w*)\s*=', source))
    return result


def stage(name, body, known):
    used = set(re.findall(r'\b[A-Za-z]\w*\b', body)) & known
    assigned_here = assigned(body)
    imports = '\n'.join(f"if isfield(state,'{v}'), {v}=state.{v}; end" for v in sorted(used))
    exports = '\n'.join(f"if exist('{v}','var') && ~isa({v},'function_handle'), state.{v}={v}; end" for v in sorted(assigned_here))
    return f'function state = {name}(state)\n% Generated from the engine reference; see provenance.json.\n{imports}\n{body}\n{exports}\nend\n'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--reference', type=Path, required=True)
    parser.add_argument('--standalone', type=Path, required=True)
    args = parser.parse_args()
    # Keep this module as the byte-safe source reader used by componentize.py;
    # its command entry now builds the semantic implementation, never the old
    # state-bus stage generator below.
    from componentize import build as build_semantic_components
    build_semantic_components(args.reference, args.standalone)
    return
    ref = args.reference
    sources = {}
    for folder in ['Pmsm/geometry', 'Pmsm/losses', 'Pmsm/thermal', 'Thermodynamics-v1']:
        for path in (ref / folder).glob('*.m'):
            text = read(path)
            if re.search(r'(?m)^\s*function\b', text):
                sources[path.stem] = (path, text)
    for name in ['PMSM_design', 'PMSM_off_design', 'PMSM_thermal_network']:
        path = ref / ('Pmsm/thermal' if name == 'PMSM_thermal_network' else 'Pmsm') / (name+'.m')
        sources[name] = (path, read(path))
    # Scripts are expanded into a local function scope before stage extraction.
    scripts = {name: read(ref/'Pmsm/thermal'/f'{name}.m') for name in
               ['get_pmsm_geometry', 'build_thermal_network_air', 'build_thermal_network_hpcgv', 'build_thermal_network_liquid']}
    names = set(sources) | set(scripts)
    def rename(text):
        for name in sorted(names, key=len, reverse=True):
            text = re.sub(r'\b'+re.escape(name)+r'\b', 'mc_pmsm_'+name, text)
        return text
    generated = {}
    # Copy only dependencies reachable from the supported public entries.
    reachable = set()
    def visit(name):
        if name in reachable or name not in sources: return
        reachable.add(name)
        for callee in names:
            if re.search(r'\b'+re.escape(callee)+r'\b', sources[name][1]): visit(callee)
    for entry in ['PMSM_design', 'PMSM_off_design', 'PMSM_thermal_network']:
        visit(entry)
    for script in scripts.values():
        for name in names:
            if re.search(r'\b'+re.escape(name)+r'\b', script): visit(name)
    for name in sorted(reachable - {'PMSM_design','PMSM_off_design','PMSM_thermal_network'}):
        generated['mc_pmsm_'+name] = rename(sources[name][1])

    design = sources['PMSM_design'][1]
    design = design[design.index('\n')+1:design.rfind('\nend')]
    markers = ['%% 主要尺寸计算', '%% 槽形优化设计', '    Br=get_prop', '    cp_air=1005', '%% 重量计算', '%% 6. 输出增强']
    offsets = [0]+[design.index(marker) for marker in markers]+[len(design)]
    design_stages = ['prepare_design','main_dimensions','stator_winding','rotor_magnet','losses_performance','mass_cooling','assemble_design']
    known = assigned(design) | {'pmsm_input','P_rated','n_rated'}
    for i, name in enumerate(design_stages):
        generated['mc_pmsm_'+name] = stage('mc_pmsm_'+name, rename(design[offsets[i]:offsets[i+1]]), known)
    off = sources['PMSM_off_design'][1]
    off = off[off.index('\n')+1:off.rfind('\nend')]
    cuts = [0, off.index('%% 非设计点损耗计算'), off.index('%% 更新输出结构体'), len(off)]
    off_stages = ['prepare_offdesign','offdesign_losses','assemble_offdesign']
    known = assigned(off) | {'pmsm_params_offdesign','P_offdesign','n_offdesign'}
    for i,name in enumerate(off_stages):
        generated['mc_pmsm_'+name] = stage('mc_pmsm_'+name,rename(off[cuts[i]:cuts[i+1]]),known)
    thermal = sources['PMSM_thermal_network'][1]
    thermal = thermal[thermal.index('\n')+1:thermal.rfind('\nend')]
    thermal = thermal.replace('get_pmsm_geometry;', scripts['get_pmsm_geometry'])
    start, end = thermal.index('switch cooling'), thermal.index('T1=T+dT_air*EFF;')
    prepare, finish = thermal[:start], thermal[end:]
    known = assigned(thermal) | {'INPUT'}
    for body in scripts.values(): known |= assigned(body)
    generated['mc_pmsm_prepare_thermal'] = stage('mc_pmsm_prepare_thermal',rename(prepare),known)
    for cooling in ['air','hpcgv','liquid']:
        body = scripts['build_thermal_network_'+cooling]
        mode={'air':1,'hpcgv':2,'liquid':3}[cooling]
        body += f'\npmsm_params.input.cooling={mode};\nOUTPUT.pmsm_params.input.cooling={mode};\ncooling={mode};\n'
        if cooling=='liquid': body+='EFF=0;\n'
        generated['mc_pmsm_network_'+cooling] = stage('mc_pmsm_network_'+cooling,rename(body),known)
    generated['mc_pmsm_finish_thermal'] = stage('mc_pmsm_finish_thermal',rename(finish),known)
    generated['mc_pmsm_select_network'] = '''function state=mc_pmsm_select_network(state)
switch state.cooling
case 1, state=mc_pmsm_network_air(state);
case 2, state=mc_pmsm_network_hpcgv(state);
case 3, state=mc_pmsm_network_liquid(state); state.EFF=0;
otherwise, error('PMSM:InvalidCooling','Unsupported cooling mode');
end
end
'''
    generated['mc_pmsm_PMSM_design'] = 'function result=mc_pmsm_PMSM_design(config,power,speed)\nmc_pmsm_validate_operating(power,speed);\nstate=struct(\'pmsm_input\',config,\'P_rated\',power,\'n_rated\',speed);\n'+''.join(f'state=mc_pmsm_{s}(state);\n' for s in design_stages)+'result=state.motor_params_design;\nend\n'
    generated['mc_pmsm_PMSM_off_design'] = "function result=mc_pmsm_PMSM_off_design(model,power,speed)\nmc_pmsm_validate_operating(power,speed);\nstate=struct('pmsm_params_offdesign',model,'P_offdesign',power,'n_offdesign',speed);\n"+''.join(f'state=mc_pmsm_{s}(state);\n' for s in off_stages)+'result=state.pmsm_params_offdesign;\nend\n'
    generated['mc_pmsm_PMSM_thermal_network'] = 'function result=mc_pmsm_PMSM_thermal_network(input)\nstate=mc_pmsm_prepare_thermal(struct(\'INPUT\',input));\nstate=mc_pmsm_select_network(state);\nstate=mc_pmsm_finish_thermal(state);\nresult=state.OUTPUT;\nend\n'
    generated['mc_pmsm_validate_operating'] = '''function mc_pmsm_validate_operating(power,speed)
if ~isnumeric(power)||~isscalar(power)||~isreal(power)||~isfinite(power)||power==0
error('PMSM:InvalidPower','Power must be a finite nonzero real scalar (kW).'); end
if ~isnumeric(speed)||~isscalar(speed)||~isreal(speed)||~isfinite(speed)||speed<=0
error('PMSM:InvalidSpeed','Speed must be a positive finite real scalar (rpm).'); end
end
'''
    # Preserve the robust existing workbook reader, replacing only its name and
    # default path. The workbook itself comes from the engine reference.
    reader = (LIB/'src/io/INPUT_ELECTRIC.m').read_text(encoding='utf-8-sig')
    reader = reader.replace('INPUT_ELECTRIC','mc_pmsm_read_configuration')
    reader = reader.replace('thermal_conductivity (W/(mK))','thermal_conductivity (W/(m·K))')
    start = reader.index('for group_index =')
    end = reader.index('pmsm_input.optimal.design_parameters', start)
    reader = reader[:start] + reader[end:]
    reader = re.sub(r"project_root = .*?;", "project_root = fileparts(fileparts(mfilename('fullpath')));", reader)
    reader = reader.replace("fullfile(project_root, 'input', 'pmsm input.xlsx')", "fullfile(project_root, 'input', 'pmsm input.xlsx')")
    generated['mc_pmsm_read_configuration'] = reader
    (LIB/'input').mkdir(parents=True,exist_ok=True)
    shutil.copyfile(ref/'Input/pmsm input.xlsx',LIB/'input/pmsm input.xlsx')
    for extra in (Path(__file__).parent/'matlab').glob('*.m'):
        generated[extra.stem] = extra.read_text(encoding='utf-8')
    manifest = {'reference': str(ref), 'files': {str(path.relative_to(ref)):hashlib.sha256(path.read_bytes()).hexdigest() for path,_ in sources.values() if path.stem in reachable}, 'designStages':design_stages,'offdesignStages':off_stages}
    for root in [args.standalone/'shared', LIB/'src']:
        for name, text in generated.items(): write(root/'core'/(name+'.m'),text)
        # reader lives in core and resolves ../input
        (root/'input').mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ref/'Input/pmsm input.xlsx',root/'input/pmsm input.xlsx')
        write(root/'provenance.json',json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
        default_program=LIB/'src/default-program.json'
        if default_program.exists() and default_program != root/'default-program.json':
            shutil.copyfile(default_program,root/'default-program.json')
    print(f'Generated {len(generated)} shared functions in standalone and library')
    write(args.standalone/'run_pmsm_analysis.m', '''function result=run_pmsm_analysis(request)
% Explicit independent entry: see docs/PMSM-shared-model.md.
root=fileparts(mfilename('fullpath')); oldpath=path;
cleanup=onCleanup(@() path(oldpath)); %#ok<NASGU>
addpath(fullfile(root,'shared/core'));
result=mc_pmsm_run(request);
end
''')
    write(args.standalone/'run_pmsm_core.m', '''%% Independent PMSM: design, offdesign and steady thermal analysis
modelRoot=fileparts(mfilename('fullpath'));
addpath(modelRoot);
request=struct('mode','design','power_kw',50,'speed_rpm',60000,...
    'flow',struct('T',288.15,'P',101325,'WA',1,'FAR',0,'D',0,'EFFH',1));
design=run_pmsm_analysis(request);
request.mode='offdesign'; request.design_model=design.pmsm_params;
request.power_kw=25; request.speed_rpm=48000;
offdesign=run_pmsm_analysis(request);
request.mode='thermal'; request.design_model=offdesign.pmsm_params;
request.free_temperature_mask=[true;true];
thermal=run_pmsm_analysis(request);
disp(struct('design_power_kW',design.PWG,'offdesign_power_kW',offdesign.PWG,...
    'steady_temperatures_C',thermal.pmsm_params.thermal.temp_values,...
    'steady_residual',thermal.solver.normalizedResidual));
''')


if __name__ == '__main__': main()
