"""Instrument gas-path returns and equivalent-thrust expressions in copies."""
import argparse
import re
from pathlib import Path


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    for name in ('DESIGN', 'OFFDESIGN'):
        text = (args.source / 'Mainprogram-v1' / f'{name}.m').read_text(encoding='utf-8-sig')
        lines = []
        for line in text.splitlines():
            lines.append(line)
            match = re.match(r'\s*(?:\[)?(O[12]?)(?:\])?\s*=\s*([A-Z][A-Z_0-9]*)\(([^;]+)\);', line)
            if match:
                variable, function, inputs = match.groups()
                lines.append(f"mc_record('component',struct('function','{function}','gasPathIndex',k,'inputs',{{{{{inputs}}}}},'result',{variable}));")
            if 'THRUST_REF=WA*(V_EXT_cor-V)/1000;' in line:
                lines.append("mc_record('formula',struct('WA',WA,'V',V,'PW_REF',PW_REF,'radicand',2*(1000*PW_REF/WA+0.5*V^2),'V_EXT_cor',V_EXT_cor,'THRUST_REF',THRUST_REF));")
            if 'OP.THRUST_REF=(WA0+WA1)*(V_EXT_cor-V)/1000;' in line:
                lines.append("mc_record('formula',struct('WA',WA0+WA1,'V',V,'PW_REF',PW_REF,'radicand',2*(1000*PW_REF/(WA0+WA1)+0.5*V^2),'V_EXT_cor',V_EXT_cor,'THRUST_REF',OP.THRUST_REF));")
        (args.output / f'{name}.m').write_text('\n'.join(lines)+'\n', encoding='utf-8')
