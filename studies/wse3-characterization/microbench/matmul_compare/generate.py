#!/usr/bin/env python3
"""Controlled variants derived from matmulorder; never modify the retained run."""
import argparse, importlib.util, json, shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
VARIANTS=['ikj','kij','jki','kji','ijk_reduce','jik_reduce','ikj_map','ijk_bt_reduce','ikj_map_blk','ikj_packed_blk','ijk_scalar','ijk_bad']

def materialize(n,work):
    spec=importlib.util.spec_from_file_location('base_matmul',ROOT/'microbench/matmulorder/gen.py')
    base=importlib.util.module_from_spec(spec);spec.loader.exec_module(base)
    base.M=base.N=base.K=n;base.VARIANTS=VARIANTS
    original=base.bench_body;tile=n//4
    def body(v):
        if v.endswith('_reduce'):
            source=v.removesuffix('_reduce')
            text=original(source).replace(f'bench_{source}',f'bench_{v}')
            text=text.replace('var acc: f16 = @as(f16, 0.0);','red[0] = @as(f16, 0.0);')
            text=text.replace('@faddh(&acc, acc, t_vec);','@faddh(red_dsd, red_dsd, t_vec);')
            return text.replace(f'C[i * {n} + j] = acc;',f'C[i * {n} + j] = red[0];')
        if v=='ijk_bad':return original('ijk').replace('bench_ijk','bench_ijk_bad')
        if v=='ikj_packed_blk':return f'''
// Bp has [tile_j][k][j_in_tile] order. The streaming DSR advances by tile width.
fn bench_ikj_packed_blk() void {{
  var i: u16 = 0;
  while (i < {n}) : (i += 1) {{
    var jb: u16 = 0;
    while (jb < 4) : (jb += 1) {{
      var cd = @set_dsd_length(@increment_dsd_offset(c_row, @as(i16, i*{n}+jb*{tile}), f16), {tile});
      var bd = @increment_dsd_offset(bp_row, @as(i16, jb*{n*tile}), f16);
      @load_to_dsr(c_dsr_d, cd, .{{.save_address=false}});
      @load_to_dsr(c_dsr_0, cd, .{{.save_address=false}});
      @load_to_dsr(b_dsr_1, bd, .{{.save_address=true}});
      var ad = @increment_dsd_offset(a_row, @as(i16, i*{n}), f16);
      @map(step_map, ad);
    }}
  }}
}}
'''
        return original(v)
    base.bench_body=body
    layout=base.layout_csl().replace('  @export_name("Bt"','  @export_name("Bp", [*]f16, true);\n  @export_name("Bt"')
    code=base.pe_csl().replace('var t_buf',f'''var Bp = @zeros([{n*n}]f16);
var ptr_Bp: [*]f16 = &Bp;
const bp_row = @get_dsd(mem1d_dsd, .{{.tensor_access=|j|{{{tile}}}->Bp[j]}});
var red = @zeros([1]f16);
const red_dsd = @get_dsd(mem1d_dsd, .{{.tensor_access=|k|{{{n}}}->red[0]}});
var t_buf''').replace('  @export_symbol(ptr_Bt','  @export_symbol(ptr_Bp, "Bp");\n  @export_symbol(ptr_Bt')
    # Descriptive comments from the older probe are hypotheses, not conclusions.
    code='\n'.join(line for line in code.splitlines() if not line.strip().startswith('//'))+'\n'
    work.mkdir(parents=True,exist_ok=False)
    (work/'layout.csl').write_text(layout);(work/'pe.csl').write_text(code)
    (work/'meta.json').write_text(json.dumps(dict(n=n,tile=tile,variants=VARIANTS,dtype='f16',seed=20260922),indent=2))
    shutil.copy2(Path(__file__).with_name('run.py'),work/'run.py')

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--n',type=int,choices=[4,8,16,32],required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();materialize(a.n,a.out)
