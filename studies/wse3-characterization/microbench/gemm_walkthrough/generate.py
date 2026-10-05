#!/usr/bin/env python3
"""Materialize a tiny GEMM in a new, isolated directory; never submit a job."""
from __future__ import annotations
import argparse
import json
from pathlib import Path

CASES = {"g0": (4, 1), "g1": (4, 2), "g2": (8, 2)}

LAYOUT = '''param N: u16;
param P: u16;
param HISTORY: u16;
const memcpy = @import_module("<memcpy/get_params>", .{ .width = P, .height = P });
const c2d = @import_module("<collectives_2d/params>");
layout {
  @set_rectangle(P, P);
  for (@range(u16, P)) |x| {
    for (@range(u16, P)) |y| {
      const cp = c2d.get_params(x, y, .{
        .x_colors = .{ @get_color(0), @get_color(1) },
        .x_entrypoints = .{ @get_local_task_id(8), @get_local_task_id(9) },
        .y_colors = .{ @get_color(4), @get_color(5) },
        .y_entrypoints = .{ @get_local_task_id(10), @get_local_task_id(11) }
      });
      @set_tile_code(x, y, "pe.csl", .{
        .N = N, .P = P, .HISTORY = HISTORY, .px = x, .py = y,
        .memcpy_params = memcpy.get_params(x), .c2d_params = cp
      });
    }
  }
  @export_name("A", [*]f32, true);
  @export_name("B", [*]f32, true);
  @export_name("C", [*]f32, true);
  @export_name("h_a", [*]f32, true);
  @export_name("h_b", [*]f32, true);
  @export_name("h_old", [*]f32, true);
  @export_name("h_new", [*]f32, true);
  @export_name("a_seen", [*]f32, true);
  @export_name("b_seen", [*]f32, true);
  @export_name("h_clock", [*]u16, true);
  @export_name("time_words", [*]u16, true);
  @export_name("run", fn()void);
}
'''

COMMON = '''param N: u16; param P: u16; param HISTORY: u16;
param px: u16; param py: u16;
param memcpy_params; param c2d_params;
const T: u16 = N / P;
const H: u16 = if (HISTORY == 1) T*T*N else 1;
const S: u16 = if (HISTORY == 1) P*T*T else 1;
const sys = @import_module("<memcpy/memcpy>", memcpy_params);
const clock = @import_module("<time>");
var A = @zeros([T*T]f32); var B = @zeros([T*T]f32); var C = @zeros([T*T]f32);
var h_a = @zeros([H]f32); var h_b = @zeros([H]f32);
var h_old = @zeros([H]f32); var h_new = @zeros([H]f32);
var a_seen = @zeros([S]f32); var b_seen = @zeros([S]f32);
var h_clock = @zeros([H*3]u16);
var time_words = @zeros([6]u16);
var stamp = @zeros([3]u16);
var pA: [*]f32 = &A; var pB: [*]f32 = &B; var pC: [*]f32 = &C;
var pha: [*]f32 = &h_a; var phb: [*]f32 = &h_b;
var pho: [*]f32 = &h_old; var phn: [*]f32 = &h_new;
var pas: [*]f32 = &a_seen; var pbs: [*]f32 = &b_seen;
var phc: [*]u16 = &h_clock; var pt: [*]u16 = &time_words;

fn start_clock() void {
  clock.enable_tsc(); clock.get_timestamp(&stamp);
  for (@range(u16, 3)) |z| { time_words[z] = stamp[z]; }
}
fn finish() void {
  clock.get_timestamp(&stamp);
  for (@range(u16, 3)) |z| { time_words[3+z] = stamp[z]; }
  sys.unblock_cmd_stream();
}
'''

SINGLE = '''fn gemm() void {
  if (HISTORY == 1) {
    for (@range(u16, T*T)) |l| { a_seen[l] = A[l]; b_seen[l] = B[l]; }
  }
  var i: u16 = 0;
  while (i < N) : (i += 1) {
    var j: u16 = 0;
    while (j < N) : (j += 1) {
      var acc: f32 = 0.0;
      var k: u16 = 0;
      while (k < N) : (k += 1) {
        const av = A[i*N+k];
        const bv = B[k*N+j];
        const old = acc;
        const product = av * bv;
        acc = old + product;
        if (HISTORY == 1) {
          const slot = (i*N+j)*N+k;
          h_a[slot] = av; h_b[slot] = bv;
          h_old[slot] = old; h_new[slot] = acc;
          clock.get_timestamp(&stamp);
          for (@range(u16, 3)) |z| { h_clock[slot*3+z] = stamp[z]; }
        }
      }
      C[i*N+j] = acc;
    }
  }
}
fn run() void { start_clock(); gemm(); finish(); }
'''

MULTI = '''const mpi_x = @import_module("<collectives_2d/pe>", .{
  .dim_params = c2d_params.x, .queues = [2]u16{2,4},
  .dest_dsr_ids = [1]u16{1}, .src0_dsr_ids = [1]u16{1}, .src1_dsr_ids = [1]u16{1}
});
const mpi_y = @import_module("<collectives_2d/pe>", .{
  .dim_params = c2d_params.y, .queues = [2]u16{3,5},
  .dest_dsr_ids = [1]u16{2}, .src0_dsr_ids = [1]u16{2}, .src1_dsr_ids = [1]u16{2}
});
const COMP = @get_local_task_id(13);
const XDONE = @get_local_task_id(14);
const YDONE = @get_local_task_id(15);
var abuf = @zeros([T*T]f32); var bbuf = @zeros([T*T]f32);
var step: u16 = 0;
task x_done() void { @activate(COMP); }
task y_done() void { @unblock(COMP); }
fn panels() void {
  const ap = if (px == step) &A else &abuf;
  const bp = if (py == step) &B else &bbuf;
  mpi_x.broadcast(step, @ptrcast([*]u32, ap), T*T, XDONE);
  mpi_y.broadcast(step, @ptrcast([*]u32, bp), T*T, YDONE);
}
fn gemm() void {
  const ap = if (px == step) &A else &abuf;
  const bp = if (py == step) &B else &bbuf;
  if (HISTORY == 1) {
    for (@range(u16, T*T)) |l| {
      a_seen[step*T*T+l] = ap.*[l]; b_seen[step*T*T+l] = bp.*[l];
    }
  }
  var k: u16 = 0;
  while (k < T) : (k += 1) {
    var j: u16 = 0;
    while (j < T) : (j += 1) {
      var i: u16 = 0;
      while (i < T) : (i += 1) {
        const av = ap.*[k*T+i];
        const bv = bp.*[j*T+k];
        const old = C[j*T+i];
        const product = av * bv;
        const acc = old + product;
        C[j*T+i] = acc;
        if (HISTORY == 1) {
          const slot = (j*T+i)*N+step*T+k;
          h_a[slot] = av; h_b[slot] = bv;
          h_old[slot] = old; h_new[slot] = acc;
          clock.get_timestamp(&stamp);
          for (@range(u16, 3)) |z| { h_clock[slot*3+z] = stamp[z]; }
        }
      }
    }
  }
}
task compute() void {
  gemm(); step += 1; @block(COMP);
  if (step < P) { panels(); } else { finish(); }
}
fn run() void { start_clock(); mpi_x.init(); mpi_y.init(); panels(); }
'''

EXPORT = '''comptime {
  @export_symbol(pA, "A"); @export_symbol(pB, "B"); @export_symbol(pC, "C");
  @export_symbol(pha, "h_a"); @export_symbol(phb, "h_b");
  @export_symbol(pho, "h_old"); @export_symbol(phn, "h_new");
  @export_symbol(pas, "a_seen"); @export_symbol(pbs, "b_seen");
  @export_symbol(phc, "h_clock"); @export_symbol(pt, "time_words");
  @export_symbol(run);
  BIND_TASKS
}
'''


def materialize(case: str, out: Path, history: bool = True) -> None:
    n, p = CASES[case]
    out.mkdir(parents=True, exist_ok=False)
    tasks = '@bind_local_task(x_done, XDONE); @bind_local_task(y_done, YDONE); @bind_local_task(compute, COMP);' if p > 1 else ''
    (out / 'layout.csl').write_text(LAYOUT)
    (out / 'pe.csl').write_text(COMMON + (SINGLE if p == 1 else MULTI) + EXPORT.replace('BIND_TASKS', tasks))
    (out / 'case.json').write_text(json.dumps({'case': case, 'n': n, 'p': p, 'history': history, 'dtype': 'f32'}, indent=2))
    (out / 'run.py').write_text((Path(__file__).parent / 'run.py').read_text())


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--case', choices=CASES, required=True)
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--no-history', action='store_true')
    args = ap.parse_args()
    materialize(args.case, args.out, not args.no_history)
