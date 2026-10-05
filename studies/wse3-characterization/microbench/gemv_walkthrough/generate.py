#!/usr/bin/env python3
"""Small X @ W teaching kernels with vertical partial reduction/allreduce."""
import argparse
import json
from pathlib import Path
import sys

sys.path.insert(0,str(Path(__file__).resolve().parents[2]))
from microbench.gemm_walkthrough.generate import LAYOUT as GEMM_LAYOUT

CASES={'v0':(4,1),'v1':(4,2),'v2':(8,2)}
PHASES=['inputs','local','peer','reduced','final']
FLOATS=['W','X','partial','peer','result','h_w','h_x','h_old','h_new','r_old','r_peer','r_new']
SHORTS=['h_clock','phase_clock','phase_flags','time_words']

COMMON='''param N: u16; param P: u16; param HISTORY: u16;
param px: u16; param py: u16;
param memcpy_params; param c2d_params;
const T: u16 = N/P;
const H: u16 = if (HISTORY == 1) T*T else 1;
const R: u16 = if (HISTORY == 1) T else 1;
const sys = @import_module("<memcpy/memcpy>", memcpy_params);
const clock = @import_module("<time>");
var W = @zeros([T*T]f32); var X = @zeros([T]f32);
var partial = @zeros([T]f32); var peer = @zeros([T]f32); var result = @zeros([T]f32);
var h_w = @zeros([H]f32); var h_x = @zeros([H]f32);
var h_old = @zeros([H]f32); var h_new = @zeros([H]f32);
var r_old = @zeros([R]f32); var r_peer = @zeros([R]f32); var r_new = @zeros([R]f32);
var h_clock = @zeros([3*H]u16);
var phase_clock = @zeros([15]u16); var phase_flags = @zeros([5]u16);
var time_words = @zeros([6]u16); var stamp = @zeros([3]u16);

fn gemv() void {
  var k: u16 = 0;
  while (k < T) : (k += 1) {
    var j: u16 = 0;
    while (j < T) : (j += 1) {
      const w = W[k*T+j]; const x = X[k];
      const old = partial[j]; const product = x*w; const acc = old+product;
      partial[j] = acc;
      if (HISTORY == 1) {
        const h = j*T+k;
        h_w[h] = w; h_x[h] = x; h_old[h] = old; h_new[h] = acc;
        clock.get_timestamp(&stamp);
        for (@range(u16,3)) |z| { h_clock[h*3+z] = stamp[z]; }
      }
    }
  }
}
fn combine() void {
  var j: u16 = 0;
  while (j < T) : (j += 1) {
    const old = partial[j]; const incoming = peer[j];
    const acc = old+incoming; result[j] = acc;
    if (HISTORY == 1) { r_old[j] = old; r_peer[j] = incoming; r_new[j] = acc; }
  }
}
fn start_clock() void {
  clock.enable_tsc(); clock.get_timestamp(&stamp);
  for (@range(u16,3)) |z| { time_words[z] = stamp[z]; }
}
fn finish() void {
  clock.get_timestamp(&stamp);
  for (@range(u16,3)) |z| { time_words[z+3] = stamp[z]; }
  sys.unblock_cmd_stream();
}
'''

MULTI='''const mpi_y = @import_module("<collectives_2d/pe>", .{
  .dim_params = c2d_params.y, .queues = [2]u16{3,5},
  .dest_dsr_ids = [1]u16{2}, .src0_dsr_ids = [1]u16{2}, .src1_dsr_ids = [1]u16{2}
});
const RECEIVED = @get_local_task_id(13);
const DONE = @get_local_task_id(14);
task received() void {
  if (HISTORY == 1) { phase_peer(); }
  if (py == P-1) {
    combine();
    if (HISTORY == 1) { phase_reduced(); }
  }
  mpi_y.broadcast(P-1, @ptrcast([*]u32,&result), T, DONE);
}
task done() void {
  if (HISTORY == 1) { phase_final(); }
  finish();
}
fn run() void {
  start_clock(); mpi_y.init();
  if (HISTORY == 1) { phase_inputs(); }
  gemv();
  if (HISTORY == 1) { phase_local(); }
  if (py == 0) {
    for (@range(u16,T)) |j| { peer[j] = partial[j]; }
  }
  mpi_y.broadcast(0, @ptrcast([*]u32,&peer), T, RECEIVED);
}
'''

SINGLE='''fn run() void {
  start_clock();
  if (HISTORY == 1) { phase_inputs(); }
  gemv();
  if (HISTORY == 1) { phase_local(); }
  for (@range(u16,T)) |j| { result[j] = partial[j]; }
  if (HISTORY == 1) { phase_final(); }
  finish();
}
'''

def materialize(case,out,history=True):
    n,p=CASES[case];out=Path(out);out.mkdir(parents=True,exist_ok=False)
    layout=GEMM_LAYOUT[:GEMM_LAYOUT.index('  @export_name("A"')]
    layout+=''.join(f'  @export_name("{f}", [*]{"f32" if f in FLOATS else "u16"}, true);\n' for f in FLOATS+SHORTS)
    layout+='  @export_name("run", fn()void);\n}\n'
    phases=''
    for s,name in enumerate(PHASES):
        phases+=f'''fn phase_{name}() void {{
  clock.get_timestamp(&stamp);
  for (@range(u16,3)) |z| {{ phase_clock[{s}*3+z] = stamp[z]; }}
  phase_flags[{s}] = {s+1};
}}
'''
    exports=''
    for name in FLOATS+SHORTS:
        exports+=f'var ptr_{name}: [*]{"f32" if name in FLOATS else "u16"} = &{name};\n'
    exports+='comptime {\n'
    exports+=''.join(f'  @export_symbol(ptr_{name}, "{name}");\n' for name in FLOATS+SHORTS)
    exports+='  @export_symbol(run);\n'
    if p>1:exports+='  @bind_local_task(received, RECEIVED); @bind_local_task(done, DONE);\n'
    exports+='}\n'
    (out/'layout.csl').write_text(layout)
    (out/'pe.csl').write_text(COMMON+phases+(SINGLE if p==1 else MULTI)+exports)
    (out/'case.json').write_text(json.dumps({'case':case,'n':n,'p':p,'history':history,'dtype':'f32','operation':'X @ W'},indent=2))
    (out/'run.py').write_text((Path(__file__).parent/'run.py').read_text())

if __name__=='__main__':
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--case',choices=CASES,required=True)
    ap.add_argument('--out',type=Path,required=True);ap.add_argument('--no-history',action='store_true')
    a=ap.parse_args();materialize(a.case,a.out,not a.no_history)
