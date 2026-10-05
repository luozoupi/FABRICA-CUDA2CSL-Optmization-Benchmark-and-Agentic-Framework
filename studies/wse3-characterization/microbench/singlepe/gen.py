#!/usr/bin/env python3
"""Generate the single-PE roofline suite (no cross-PE communication).

Five separately-compiled suites, each fully resident in one PE's SRAM, timed by
the device TSC around every variant, with a shared runner:

  A   pure memory   read (scalar-register dest -- probed expressible), write
                    (fill), copy, strided read
  B   pure compute  axpy (incl. SIMD-unaligned N), scalar dot loop (serial FMA),
                    vector dot (fmulh + fmach-accumulate)
  C1  mixed         single-tile GEMV sweep, 5-point stencil as shifted adds
  C2  mixed         elementwise add/mul, N up to the 3-array capacity limit
  D   integer       i16 elementwise via @add16 DSD, i16 scalar dot, i8 scalar

Design rules carried over from earlier probes in this study:
  * identical-work discipline: reps chosen so every variant does >= ~8k elements,
    so tiny-N points measure loop/setup overhead against the same total work
  * every variant writes a checksum to an exported f32 sink AFTER the timed
    region -- dead-code elimination has already eaten one measurement here
  * d2h is 32-bit only, so sinks and timers are f32

Two constraints the demand spec missed, both measured in this study: usable SRAM
is 44,976 B (not 48 KiB), and a 3-array f16 kernel caps at n=7,492 -- so the
requested "EW sweep to 20k" is not compilable; C2 stops at 6,144.
"""

from __future__ import annotations

import json
from pathlib import Path

TARGET = 8192  # minimum total elements per timed region


def reps_for(elems, target=TARGET):
    return max(1, target // max(elems, 1))


# ---------------------------------------------------------------- suite specs
def suite_A():
    arrays = """
var A = @zeros([12288]f16);
var Bb = @zeros([4096]f16);
var rsink: f16 = 0.0;
var chk: f16 = 0.0;
var ptr_A: [*]f16 = &A;
var ptr_Bb: [*]f16 = &Bb;
"""
    variants, fns = [], []
    for n in (16, 64, 256, 1024, 4096, 12288):
        r = reps_for(n)
        fns.append(f"""
fn bench_read_{n}() void {{
  const s = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{n}}} -> A[i] }});
  var rr: u16 = 0;
  while (rr < {r}) : (rr += 1) {{ @fmovh(&rsink, s); }}
}}""")
        variants.append(dict(name=f"read_{n}", fn=f"bench_read_{n}", family="read",
                             elems=n, reps=r, flop=0, bytes=2, sink="@as(f32, rsink)"))
    for n in (16, 64, 256, 1024, 4096):
        r = reps_for(n)
        fns.append(f"""
fn bench_copy_{n}() void {{
  const s = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{n}}} -> A[i] }});
  const d = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{n}}} -> Bb[i] }});
  var rr: u16 = 0;
  while (rr < {r}) : (rr += 1) {{ @fmovh(d, s); }}
}}""")
        variants.append(dict(name=f"copy_{n}", fn=f"bench_copy_{n}", family="copy",
                             elems=n, reps=r, flop=0, bytes=4, sink="@as(f32, chk)",
                             consume=f"@faddh(&chk, chk, @get_dsd(mem1d_dsd, .{{ .tensor_access = |j|{{{n}}} -> Bb[j] }}));"))
    # Strided READ measured through a full-rate copy: the scalar-dest form pins
    # everything to 1 elem/cyc (see the read family), so stride effects only show
    # when the destination can absorb 8/cyc.
    for st in (1, 2, 4, 8):
        n, r = 1024, reps_for(1024)
        fns.append(f"""
fn bench_rstride_{st}() void {{
  const s = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{n}}} -> A[{st} * i] }});
  const d = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{n}}} -> Bb[i] }});
  var rr: u16 = 0;
  while (rr < {r}) : (rr += 1) {{ @fmovh(d, s); }}
}}""")
        variants.append(dict(name=f"rstride_{st}", fn=f"bench_rstride_{st}", family="rstride",
                             elems=n, reps=r, flop=0, bytes=4, sink="@as(f32, chk)",
                             consume=f"@faddh(&chk, chk, @get_dsd(mem1d_dsd, .{{ .tensor_access = |j|{{{n}}} -> Bb[j] }}));"))
    for n in (16, 64, 256, 1024, 4096, 12288):
        r = reps_for(n)
        fns.append(f"""
fn bench_write_{n}() void {{
  const d = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{n}}} -> A[i] }});
  var rr: u16 = 0;
  while (rr < {r}) : (rr += 1) {{ @fmovh(d, @as(f16, 1.5)); }}
}}""")
        variants.append(dict(name=f"write_{n}", fn=f"bench_write_{n}", family="write",
                             elems=n, reps=r, flop=0, bytes=2, sink="@as(f32, chk)",
                             consume=f"@faddh(&chk, chk, @get_dsd(mem1d_dsd, .{{ .tensor_access = |j|{{{n}}} -> A[j] }}));"))
    exports = [("A", "f16", 12288), ("Bb", "f16", 4096)]
    return arrays, fns, variants, exports


def suite_B():
    arrays = """
var x_arr = @zeros([2048]f16);
var y_arr = @zeros([2048]f16);
var t_arr = @zeros([2048]f16);
var z_arr = @zeros([2048]f16);
var acc: f16 = 0.0;
var ptr_x_arr: [*]f16 = &x_arr;
var ptr_y_arr: [*]f16 = &y_arr;
var ptr_t_arr: [*]f16 = &t_arr;
var ptr_z_arr: [*]f16 = &z_arr;
"""
    variants, fns = [], []
    for n in (7, 8, 9, 15, 16, 17, 32, 128, 512, 2048):
        r = reps_for(n)
        fns.append(f"""
fn bench_axpy_{n}() void {{
  const xs = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{n}}} -> x_arr[i] }});
  const ys = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{n}}} -> y_arr[i] }});
  var rr: u16 = 0;
  while (rr < {r}) : (rr += 1) {{ @fmach(ys, ys, xs, @as(f16, 1.0009765625)); }}
}}""")
        variants.append(dict(name=f"axpy_{n}", fn=f"bench_axpy_{n}", family="axpy",
                             elems=n, reps=r, flop=2, bytes=6, sink="@as(f32, y_arr[0])"))
    for k in (1, 2, 4, 8, 64, 256, 1024):
        r = reps_for(k, 4096)
        fns.append(f"""
fn bench_dotloop_{k}() void {{
  var rr: u16 = 0;
  while (rr < {r}) : (rr += 1) {{
    var i: u16 = 0;
    while (i < {k}) : (i += 1) {{ acc = acc + x_arr[(i + rr) & 2047] * y_arr[i]; }}
  }}
}}""")
        variants.append(dict(name=f"dotloop_{k}", fn=f"bench_dotloop_{k}", family="dotloop",
                             elems=k, reps=r, flop=2, bytes=4, sink="@as(f32, acc)"))
    # Vector dot: elementwise multiply pass + hardware reduction. No @fdph
    # builtin exists (probed); @faddh with a scalar destination does, and sums.
    for k in (8, 64, 256, 1024, 2048):
        r = reps_for(k, 4096)
        fns.append(f"""
fn bench_vdot_{k}() void {{
  const xs = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{k}}} -> x_arr[i] }});
  const zs = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{k}}} -> z_arr[i] }});
  const ts = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{k}}} -> t_arr[i] }});
  var rr: u16 = 0;
  while (rr < {r}) : (rr += 1) {{
    @fmulh(ts, xs, zs);
    @faddh(&acc, acc, ts);
  }}
}}""")
        variants.append(dict(name=f"vdot_{k}", fn=f"bench_vdot_{k}", family="vdot",
                             elems=k, reps=r, flop=2, bytes=8, sink="@as(f32, acc)"))
    # The reduction alone: serial accumulate straight off a DSD stream.
    for k in (64, 1024, 2048):
        r = reps_for(k, 4096)
        fns.append(f"""
fn bench_reduce_{k}() void {{
  const xs = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{k}}} -> x_arr[i] }});
  var rr: u16 = 0;
  while (rr < {r}) : (rr += 1) {{ @faddh(&acc, acc, xs); }}
}}""")
        variants.append(dict(name=f"reduce_{k}", fn=f"bench_reduce_{k}", family="reduce",
                             elems=k, reps=r, flop=1, bytes=2, sink="@as(f32, acc)"))
    # Mask isolation at scale: 2047 vs 2048 with setup fully amortised.
    for n in (2047,):
        r = reps_for(n)
        fns.append(f"""
fn bench_axpy_{n}() void {{
  const xs = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{n}}} -> x_arr[i] }});
  const ys = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{n}}} -> y_arr[i] }});
  var rr: u16 = 0;
  while (rr < {r}) : (rr += 1) {{ @fmach(ys, ys, xs, @as(f16, 1.0009765625)); }}
}}""")
        variants.append(dict(name=f"axpy_{n}", fn=f"bench_axpy_{n}", family="axpy",
                             elems=n, reps=r, flop=2, bytes=6, sink="@as(f32, y_arr[1])"))
    exports = [("x_arr", "f16", 2048), ("y_arr", "f16", 2048), ("t_arr", "f16", 2048), ("z_arr", "f16", 2048)]
    return arrays, fns, variants, exports


def suite_C1():
    arrays = """
var Amat = @zeros([4096]f16);
var X = @zeros([64]f16);
var Y = @zeros([64]f16);
var Bout = @zeros([4096]f16);
const acol_base = @get_dsd(mem1d_dsd, .{ .tensor_access = |i|{64} -> Amat[i] });
var acol = @get_dsd(mem1d_dsd, .{ .tensor_access = |i|{64} -> Amat[i] });
var ptr_Amat: [*]f16 = &Amat;
var ptr_X: [*]f16 = &X;
var ptr_Y: [*]f16 = &Y;
var ptr_Bout: [*]f16 = &Bout;
"""
    variants, fns = [], []
    for m, k in ((4, 8), (8, 16), (16, 32), (32, 64), (64, 32), (64, 64)):
        r = reps_for(m * k, 4096)
        fns.append(f"""
fn bench_gemv_{m}_{k}() void {{
  const yd = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{m}}} -> Y[i] }});
  const a0 = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{m}}} -> Amat[i] }});
  var rr: u16 = 0;
  while (rr < {r}) : (rr += 1) {{
    @fmovh(yd, @as(f16, 0.0));
    acol = a0;
    for (@range(i16, {k})) |kk| {{
      @fmach(yd, yd, acol, X[kk]);
      acol = @increment_dsd_offset(acol, {m}, f16);
    }}
  }}
}}""")
        variants.append(dict(name=f"gemv_{m}x{k}", fn=f"bench_gemv_{m}_{k}", family="gemv",
                             elems=m * k, reps=r, flop=2,
                             bytes=round(2 * (m * k + k + 2 * m) / (m * k), 3),
                             sink="@as(f32, Y[0])"))
    # 5-point stencil over a 64-wide grid, rows 1..61: four shifted vector adds.
    n = 3968
    r = reps_for(n, 4096)
    fns.append(f"""
fn bench_stencil5() void {{
  const oc = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{n}}} -> Bout[i + 64] }});
  const cc = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{n}}} -> Amat[i + 64] }});
  const ww = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{n}}} -> Amat[i + 63] }});
  const ee = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{n}}} -> Amat[i + 65] }});
  const nn = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{n}}} -> Amat[i] }});
  const ss = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{n}}} -> Amat[i + 128] }});
  var rr: u16 = 0;
  while (rr < {r}) : (rr += 1) {{
    @faddh(oc, cc, ww);
    @faddh(oc, oc, ee);
    @faddh(oc, oc, nn);
    @faddh(oc, oc, ss);
  }}
}}""")
    variants.append(dict(name="stencil5_64x64", fn="bench_stencil5", family="stencil",
                         elems=n, reps=r, flop=4, bytes=24, sink="@as(f32, Bout[64])"))
    exports = [("Amat", "f16", 4096), ("X", "f16", 64), ("Y", "f16", 64), ("Bout", "f16", 4096)]
    return arrays, fns, variants, exports


def suite_C2():
    arrays = """
var a3 = @zeros([6144]f16);
var b3 = @zeros([6144]f16);
var c3 = @zeros([6144]f16);
var ptr_a3: [*]f16 = &a3;
var ptr_b3: [*]f16 = &b3;
var ptr_c3: [*]f16 = &c3;
"""
    variants, fns = [], []
    for op, builtin in (("ewmul", "@fmulh"), ("ewadd", "@faddh")):
        for n in (8, 64, 512, 2048, 6144):
            r = reps_for(n)
            fns.append(f"""
fn bench_{op}_{n}() void {{
  const aa = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{n}}} -> a3[i] }});
  const bb = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{n}}} -> b3[i] }});
  const cc = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{n}}} -> c3[i] }});
  var rr: u16 = 0;
  while (rr < {r}) : (rr += 1) {{ {builtin}(cc, aa, bb); }}
}}""")
            variants.append(dict(name=f"{op}_{n}", fn=f"bench_{op}_{n}", family=op,
                                 elems=n, reps=r, flop=1, bytes=6,
                                 sink="@as(f32, c3[0])"))
    exports = [("a3", "f16", 6144), ("b3", "f16", 6144), ("c3", "f16", 6144)]
    return arrays, fns, variants, exports


def suite_D():
    arrays = """
var ia = @zeros([2048]i16);
var ib = @zeros([2048]i16);
var ic = @zeros([2048]i16);
var q8 = @zeros([512]i8);
var iacc: i16 = 0;
var qacc: i8 = 0;
var ptr_ia: [*]i16 = &ia;
var ptr_ib: [*]i16 = &ib;
var ptr_ic: [*]i16 = &ic;
var ptr_q8: [*]i8 = &q8;
"""
    variants, fns = [], []
    for n in (8, 512, 2048):
        r = reps_for(n)
        fns.append(f"""
fn bench_iadd_{n}() void {{
  const aa = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{n}}} -> ia[i] }});
  const bb = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{n}}} -> ib[i] }});
  const cc = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{n}}} -> ic[i] }});
  var rr: u16 = 0;
  while (rr < {r}) : (rr += 1) {{ @add16(cc, aa, bb); }}
}}""")
        variants.append(dict(name=f"iadd16_{n}", fn=f"bench_iadd_{n}", family="iadd16",
                             elems=n, reps=r, flop=1, bytes=6, sink="@as(f32, ic[0])"))
    for k in (8, 256):
        r = reps_for(k, 4096)
        fns.append(f"""
fn bench_idot_{k}() void {{
  var rr: u16 = 0;
  while (rr < {r}) : (rr += 1) {{
    var i: u16 = 0;
    while (i < {k}) : (i += 1) {{ iacc = iacc + ia[(i + rr) & 2047] * ib[i]; }}
  }}
}}""")
        variants.append(dict(name=f"idot16_{k}", fn=f"bench_idot_{k}", family="idot16",
                             elems=k, reps=r, flop=2, bytes=4, sink="@as(f32, iacc)"))
    r = reps_for(512)
    fns.append(f"""
fn bench_i8add() void {{
  var rr: u16 = 0;
  while (rr < {r}) : (rr += 1) {{
    var i: u16 = 0;
    while (i < 512) : (i += 1) {{ qacc = qacc + q8[(i + rr) & 511]; }}
  }}
}}""")
    variants.append(dict(name="i8add_512", fn="bench_i8add", family="i8",
                         elems=512, reps=r, flop=1, bytes=1, sink="@as(f32, qacc)"))
    exports = [("ia", "i16", 2048), ("ib", "i16", 2048), ("ic", "i16", 2048), ("q8", "i8", 512)]
    return arrays, fns, variants, exports


SUITES = {"A": suite_A, "B": suite_B, "C1": suite_C1, "C2": suite_C2, "D": suite_D}

LAYOUT = """const memcpy = @import_module("<memcpy/get_params>", .{ .width = 1, .height = 1 });
layout {
  @set_rectangle(1, 1);
  @set_tile_code(0, 0, "pe.csl", .{ .memcpy_params = memcpy.get_params(0) });
  @export_name("maxmin_time", [*]f32, true);
  @export_name("sink", [*]f32, true);
__EXPORT_NAMES__  @export_name("compute", fn()void);
}
"""


def timing(i, fn, sink_expr=None, consume=None):
    b = i * 3
    sink_line = (f"  {consume}\n" if consume else "") + (f"  sink[{i}] = {sink_expr};\n" if sink_expr else "")
    return f"""
  timestamp.get_timestamp(&tsc_s);
  {fn}();
  timestamp.get_timestamp(&tsc_e);
{sink_line}
  lo_ = tsc_s[0]; hi_ = tsc_s[1];
  timer_buf[{b}] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));
  lo_ = tsc_s[2]; hi_ = tsc_e[0];
  timer_buf[{b + 1}] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));
  lo_ = tsc_e[1]; hi_ = tsc_e[2];
  timer_buf[{b + 2}] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));
"""


def emit(suite, out_root):
    arrays, fns, variants, exports = SUITES[suite]()
    nv = len(variants)
    d = out_root / suite
    d.mkdir(parents=True, exist_ok=True)
    names = "".join(f'  @export_name("{n}", [*]{t}, true);\n' for n, t, _ in exports)
    (d / "layout.csl").write_text(LAYOUT.replace("__EXPORT_NAMES__", names))
    export_syms = "".join(f'  @export_symbol(ptr_{n}, "{n}");\n' for n, _, _ in exports)
    body = "".join(fns)
    # sink written right after each variant (outside its timed region) so no
    # variant's result is a dead store for the compiler to remove
    times = "".join(timing(i, v["fn"], v["sink"], v.get("consume")) for i, v in enumerate(variants))
    sinks = ""
    (d / "pe.csl").write_text(f"""// Single-PE roofline suite {suite} -- generated by gen.py, do not edit.
param memcpy_params;

const EXIT: local_task_id = @get_local_task_id(9);
const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);
const timestamp = @import_module("<time>");

var tsc_s = @zeros([timestamp.tsc_size_words]u16);
var tsc_e = @zeros([timestamp.tsc_size_words]u16);
var timer_buf = @zeros([{3 * nv}]f32);
var ptr_timer_buf: [*]f32 = &timer_buf;
var sink = @zeros([{nv}]f32);
var ptr_sink: [*]f32 = &sink;
{arrays}{body}
fn compute() void {{
  var lo_: u16 = 0;
  var hi_: u16 = 0;
  timestamp.enable_tsc();
{times}
  timestamp.disable_tsc();
{sinks}
  @activate(EXIT);
}}

task f_exit() void {{ sys_mod.unblock_cmd_stream(); }}

comptime {{
  @bind_local_task(f_exit, EXIT);
  @export_symbol(ptr_timer_buf, "maxmin_time");
  @export_symbol(ptr_sink, "sink");
{export_syms}  @export_symbol(compute);
}}
""")
    (d / "meta.json").write_text(json.dumps(
        {"suite": suite, "exports": [{"name": n, "dtype": t, "len": L} for n, t, L in exports],
         "variants": [{k: v[k] for k in
         ("name", "family", "elems", "reps", "flop", "bytes")} for v in variants]},
        indent=1))
    print(f"suite {suite}: {nv} variants")


if __name__ == "__main__":
    root = Path(__file__).parent
    for s in SUITES:
        emit(s, root)
