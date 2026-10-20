"""Create observation-only MATLAB copies for a saved engine task."""
import argparse
import json
import shutil
from pathlib import Path


def prepare(source: Path, destination: Path, platform: bool):
    source = source.resolve()
    destination.mkdir(parents=True, exist_ok=True)
    for name in ('BALANCE_FUNCTION_DESIGN', 'BALANCE_FUNCTION_OFFDESIGN'):
        text = (source / 'Mainprogram-v1' / f'{name}.m').read_text(encoding='utf-8-sig')
        if name.endswith('_DESIGN'):
            marker = '% 建立并求解非设计点的平衡方程'
            text = text.replace(marker, "mc_input_DP=DP; mc_exitflag=1; mc_fval=[]; mc_output=struct();\n" + marker, 1)
            if not platform:
                text = text.replace('XD(LM)=fsolve(', '[XD(LM),mc_fval,mc_exitflag,mc_output]=fsolve(', 1)
            info = 'diagnostics' if platform else "struct('exitflag',mc_exitflag,'fval',mc_fval,'output',mc_output,'residual_norm',norm(YD(:),inf))"
            record = f"mc_record('design',struct('inputDP',mc_input_DP,'result',DP,'X',XD,'LM',LM,'residual',YD,'diagnostics',{info}));\n"
            text = text.replace('dis=DP.display;', record + 'dis=DP.display;', 1)
        else:
            marker = '% 建立并求解非设计点的平衡方程'
            text = text.replace(marker, "mc_input_OP=OP; mc_input_X=X0;\n" + marker, 1)
            if not platform:
                text = text.replace('X(LM)=fsolve(', '[X(LM),mc_fval,mc_exitflag,mc_output]=fsolve(', 1)
                text = text.replace('[~,OP]=OFFDESIGN(', '[YOFF,OP]=OFFDESIGN(', 1)
            text = text.replace('X=real(X);', 'mc_rawX=X;\nX=real(X);', 1)
            info = 'diagnostics' if platform else "struct('exitflag',mc_exitflag,'fval',mc_fval,'output',mc_output,'residual_norm',norm(YOFF(:),inf))"
            record = f"mc_record('offdesign',struct('DP',DP,'inputOP',mc_input_OP,'inputX',mc_input_X,'rawX',mc_rawX,'X',X,'LM',LM,'DX',DX,'residual',YOFF,'result',OP,'diagnostics',{info}));\n"
            text = text.replace('dis=OP.display;', record + 'dis=OP.display;', 1)
        (destination / f'{name}.m').write_text(text, encoding='utf-8')
    if platform:
        scope = (source / 'workflows/component_engine_envelope_scope.m').read_text(encoding='utf-8-sig')
        scope = scope.replace("runtime_root = fileparts(fileparts(mfilename('fullpath')));", f"runtime_root = '{source.as_posix()}';")
        scope = scope.replace("addpath(genpath(runtime_root), '-begin');", "addpath(genpath(runtime_root), '-begin');\naddpath(getenv('MC_DIAG_OVERRIDE'), '-begin');")
        (destination / 'component_engine_envelope_scope.m').write_text(scope, encoding='utf-8')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--original', type=Path, required=True)
    parser.add_argument('--platform', type=Path, required=True)
    parser.add_argument('--task', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    for label, root in [('original', args.original), ('platform', args.platform)]:
        prepare(root, args.output / label / 'override', label == 'platform')
    shutil.copy2(args.task / 'trusted_graph.json', args.output / 'trusted_graph.json')
    graph = json.loads((args.task / 'trusted_graph.json').read_text(encoding='utf-8'))
    init = next(n for n in graph['nodes'] if n['functionName'] == 'component_engine_initialize_configuration')
    (args.output / 'assembly.json').write_text(init['values']['assembly_json'], encoding='utf-8')
