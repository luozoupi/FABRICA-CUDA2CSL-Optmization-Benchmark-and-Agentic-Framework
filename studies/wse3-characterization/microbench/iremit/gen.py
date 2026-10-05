#!/usr/bin/env python3
"""Five ways to compute one sparse matrix-vector product on one PE, plus two IR-level probes.

The matrix is BANDED, so every row's nonzeros are a contiguous column run AND the matrix has only
four diagonals.  That is the best case for format transformation, which is the point: it bounds
what turning irregular access into affine access can buy, measured on one PE against the scalar
gather over identical data.

  spmv_scalar   CSL scalar gather: y[r] = sum val[j] * x[col_idx[j]]        the honest baseline
  spmv_ir       the same algorithm, body AUTHORED IN LLVM IR                the emission gate test
  spmv_blk      per-row DSD with a RUNTIME base and length, product reduced by a scalar loop
                (the DSD reduction is unusable for f32 -- see probe_reduce)
  spmv_dia      diagonal format: vectorised ACROSS rows, so no horizontal reduction and no gather
                at all -- two stream-to-stream DSD ops per diagonal
  probe_reduce  does the f32 DSD reduction accumulate when its accumulator is NOT a compile-time
                constant?  The defect measured earlier used `acc = 0.0`; this seeds from memory.

All five write their own output array; the host checks every one against numpy.
"""
import json
from pathlib import Path

NROWS, NCOLS, MAXNNZ, NDIA = 16, 16, 64, 4
RPLEN = NROWS + 2
MARK = {"scalar": (0, 1), "ir": (2, 3), "blk": (4, 5), "dia": (6, 7), "probe": (8, 9), "probe_const": (10, 11), "blk_dsdred": (12, 13)}

LAYOUT = """const memcpy = @import_module("<memcpy/get_params>", .{ .width = 1, .height = 1 });
layout {
  @set_rectangle(1, 1);
  @set_tile_code(0, 0, "pe.csl", .{ .memcpy_params = memcpy.get_params(0) });
  @export_name("row_ptr", [*]u16, true); @export_name("col_idx", [*]u16, true);
  @export_name("col_start", [*]u16, true); @export_name("run_len", [*]u16, true);
  @export_name("val", [*]f32, true);      @export_name("x", [*]f32, true);
  @export_name("dia_val", [*]f32, true);  @export_name("dia_off", [*]u16, true);
  @export_name("dia_len", [*]u16, true);  @export_name("dia_row0", [*]u16, true);
  @export_name("dia_xoff", [*]u16, true);
  @export_name("probe_seed", [*]f32, true); @export_name("probe_out", [*]f32, true);
  @export_name("y_sc", [*]f32, true); @export_name("y_ir", [*]f32, true);
  @export_name("y_bk", [*]f32, true); @export_name("y_di", [*]f32, true);
  @export_name("mark", [*]u16, true);
  @export_name("spmv_scalar", fn()void); @export_name("spmv_ir", fn()void);
  @export_name("spmv_blk", fn()void);    @export_name("spmv_dia", fn()void);
  @export_name("probe_reduce", fn()void); @export_name("probe_reduce_const", fn()void);
  @export_name("spmv_blk_dsdred", fn()void); @export_name("y_bd", [*]f32, true);
}
"""

def pe():
    m = lambda k, i: f"  mark[{MARK[k][i]}] = 0x{0x7000 + MARK[k][i]:04X};\n"
    return f"""param memcpy_params;
const EXIT: local_task_id = @get_local_task_id(9);
const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);

const NROWS: u16 = {NROWS};
const NDIA: u16 = {NDIA};

var row_ptr   = @zeros([{RPLEN}]u16);
var col_idx   = @zeros([{MAXNNZ}]u16);
var col_start = @zeros([{NROWS}]u16);
var run_len   = @zeros([{NROWS}]u16);
var val       = @zeros([{MAXNNZ}]f32);
var x         = @zeros([{NCOLS}]f32);
var dia_val   = @zeros([{MAXNNZ}]f32);
var dia_off   = @zeros([{NDIA}]u16);
var dia_len   = @zeros([{NDIA}]u16);
var dia_row0  = @zeros([{NDIA}]u16);
var dia_xoff  = @zeros([{NDIA}]u16);
var tmp       = @zeros([{NCOLS}]f32);
var probe_seed = @zeros([2]f32);
var probe_out  = @zeros([2]f32);
var acc32: f32 = 0.0;
var y_sc = @zeros([{NROWS}]f32); var y_ir = @zeros([{NROWS}]f32);
var y_bk = @zeros([{NROWS}]f32); var y_di = @zeros([{NROWS}]f32); var y_bd = @zeros([{NROWS}]f32);
var mark = @zeros([16]u16);

var p_row_ptr: [*]u16 = &row_ptr; var p_col_idx: [*]u16 = &col_idx;
var p_col_start: [*]u16 = &col_start; var p_run_len: [*]u16 = &run_len;
var p_val: [*]f32 = &val; var p_x: [*]f32 = &x;
var p_dia_val: [*]f32 = &dia_val; var p_dia_off: [*]u16 = &dia_off;
var p_dia_len: [*]u16 = &dia_len; var p_dia_row0: [*]u16 = &dia_row0;
var p_dia_xoff: [*]u16 = &dia_xoff;
var p_probe_seed: [*]f32 = &probe_seed; var p_probe_out: [*]f32 = &probe_out;
var p_y_sc: [*]f32 = &y_sc; var p_y_ir: [*]f32 = &y_ir;
var p_y_bk: [*]f32 = &y_bk; var p_y_di: [*]f32 = &y_di; var p_y_bd: [*]f32 = &y_bd;
var p_mark: [*]u16 = &mark;

// full-extent descriptors; the strategies re-base and re-length them at run time
const val_dsd = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{MAXNNZ}}} -> val[i] }});
const dv_dsd  = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{MAXNNZ}}} -> dia_val[i] }});
const x_dsd   = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{NCOLS}}} -> x[i] }});
const tmp_dsd = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{NCOLS}}} -> tmp[i] }});
const ydi_dsd = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{NROWS}}} -> y_di[i] }});

// ---------------------------------------------------------------- 1. scalar gather (baseline)
fn spmv_scalar() void {{
{m("scalar", 0)}  var r: u16 = 0;
  while (r < NROWS) : (r += 1) {{
    const s: u16 = row_ptr[r];
    const e: u16 = row_ptr[r + 1];
    var acc: f32 = 0.0;
    var j: u16 = s;
    while (j < e) : (j += 1) {{
      const c: u16 = col_idx[j];
      acc += val[j] * x[c];
    }}
    y_sc[r] = acc;
  }}
{m("scalar", 1)}  @activate(EXIT);
}}

// ---------------------------------------------------------------- 2. gate test: body replaced by hand-written IR
fn spmv_ir() void {{
{m("ir", 0)}  y_ir[0] = 0.0;
{m("ir", 1)}  @activate(EXIT);
}}

// ---------------------------------------------------------------- 3. block gather: runtime base + length
// The elementwise product is one DSD op over the row's run.  The horizontal sum is a scalar loop,
// because the f32 DSD reduction does not accumulate (probe_reduce measures that directly).
fn spmv_blk() void {{
{m("blk", 0)}  var r: u16 = 0;
  while (r < NROWS) : (r += 1) {{
    const s: u16 = row_ptr[r];
    const n: u16 = run_len[r];
    const c0: u16 = col_start[r];
    var vd = @set_dsd_length(val_dsd, n);
    vd = @increment_dsd_offset(vd, @as(i16, s), f32);
    var xd = @set_dsd_length(x_dsd, n);
    xd = @increment_dsd_offset(xd, @as(i16, c0), f32);
    var td = @set_dsd_length(tmp_dsd, n);
    @fmuls(td, vd, xd);
    var acc: f32 = 0.0;
    var q: u16 = 0;
    while (q < n) : (q += 1) {{ acc += tmp[q]; }}
    y_bk[r] = acc;
  }}
{m("blk", 1)}  @activate(EXIT);
}}

// ---------------------------------------------------------------- 3b. REGRESSION CASE
// Exactly the shape that silently returned the last element instead of the sum: a runtime-length
// DSD reduction into a register accumulator, inside a loop, over a buffer the preceding @fmuls
// just wrote.  Kept and checked so the hazard stays reproducible rather than remembered.
fn spmv_blk_dsdred() void {{
{m("blk_dsdred", 0)}  var r: u16 = 0;
  while (r < NROWS) : (r += 1) {{
    const s: u16 = row_ptr[r];
    const n: u16 = run_len[r];
    const c0: u16 = col_start[r];
    var vd = @set_dsd_length(val_dsd, n);
    vd = @increment_dsd_offset(vd, @as(i16, s), f32);
    var xd = @set_dsd_length(x_dsd, n);
    xd = @increment_dsd_offset(xd, @as(i16, c0), f32);
    var td = @set_dsd_length(tmp_dsd, n);
    @fmuls(td, vd, xd);
    acc32 = 0.0;
    @fadds(&acc32, acc32, td);
    y_bd[r] = acc32;
  }}
{m("blk_dsdred", 1)}  @activate(EXIT);
}}

// ---------------------------------------------------------------- 4. diagonal: vectorised across rows
// No horizontal reduction and no gather: every operand is an affine run, every destination a
// stream.  Two DSD ops per diagonal for the whole matrix.
fn spmv_dia() void {{
{m("dia", 0)}  @fmovs(ydi_dsd, 0.0);
  var d: u16 = 0;
  while (d < NDIA) : (d += 1) {{
    const n: u16 = dia_len[d];
    var vd = @set_dsd_length(dv_dsd, n);
    vd = @increment_dsd_offset(vd, @as(i16, dia_off[d]), f32);
    var xd = @set_dsd_length(x_dsd, n);
    xd = @increment_dsd_offset(xd, @as(i16, dia_xoff[d]), f32);
    var td = @set_dsd_length(tmp_dsd, n);
    var yd = @set_dsd_length(ydi_dsd, n);
    yd = @increment_dsd_offset(yd, @as(i16, dia_row0[d]), f32);
    @fmuls(td, vd, xd);
    @fadds(yd, yd, td);
  }}
{m("dia", 1)}  @activate(EXIT);
}}

// ---------------------------------------------------------------- 5. probe: is the f32 DSD reduction
// broken in general, or only when its accumulator is a compile-time constant?  probe_seed comes
// from the host, so the compiler cannot fold it to 0.0.
fn probe_reduce() void {{
{m("probe", 0)}  acc32 = probe_seed[0];
  var vd = @set_dsd_length(val_dsd, {MAXNNZ});
  @fadds(&acc32, acc32, vd);
  probe_out[0] = acc32;
{m("probe", 1)}  @activate(EXIT);
}}

// identical to probe_reduce except the accumulator starts as a literal 0.0, isolating whether the
// compile-time constant is what stops the allocator coalescing dest and src0.
fn probe_reduce_const() void {{
{m("probe_const", 0)}  acc32 = 0.0;
  var vd = @set_dsd_length(val_dsd, {MAXNNZ});
  @fadds(&acc32, acc32, vd);
  probe_out[1] = acc32;
{m("probe_const", 1)}  @activate(EXIT);
}}

task f_exit() void {{ sys_mod.unblock_cmd_stream(); }}

comptime {{
  @bind_local_task(f_exit, EXIT);
  @export_symbol(p_row_ptr, "row_ptr"); @export_symbol(p_col_idx, "col_idx");
  @export_symbol(p_col_start, "col_start"); @export_symbol(p_run_len, "run_len");
  @export_symbol(p_val, "val"); @export_symbol(p_x, "x");
  @export_symbol(p_dia_val, "dia_val"); @export_symbol(p_dia_off, "dia_off");
  @export_symbol(p_dia_len, "dia_len"); @export_symbol(p_dia_row0, "dia_row0");
  @export_symbol(p_dia_xoff, "dia_xoff");
  @export_symbol(p_probe_seed, "probe_seed"); @export_symbol(p_probe_out, "probe_out");
  @export_symbol(p_y_sc, "y_sc"); @export_symbol(p_y_ir, "y_ir");
  @export_symbol(p_y_bk, "y_bk"); @export_symbol(p_y_di, "y_di"); @export_symbol(p_y_bd, "y_bd");
  @export_symbol(p_mark, "mark");
  @export_symbol(spmv_scalar); @export_symbol(spmv_ir);
  @export_symbol(spmv_blk);    @export_symbol(spmv_dia);
  @export_symbol(probe_reduce); @export_symbol(probe_reduce_const); @export_symbol(spmv_blk_dsdred);
}}
"""

# ---------------------------------------------------------------- the hand-authored IR body
# Every line is ours: both nested loops, the CSR indirection, the accumulator phi, the marker
# stores and the task activation.  Array symbols are placeholders (%%name%%) because CSL mangles
# the globals of arrays the device only reads: `val` becomes @"$$csl_base_address$$N$$val" while a
# written array like `y_ir` keeps its plain name.  build.py resolves them from the capture.
IR_BODY = f"""entry:
  store i16 {0x7000 + MARK['ir'][0]}, i16* getelementptr inbounds ([16 x i16], [16 x i16]* %%mark%%, i16 0, i16 {MARK['ir'][0]}), align 2
  br label %row.head

row.head:
  %r = phi i16 [ 0, %entry ], [ %r.next, %row.tail ]
  %r.lt = icmp ult i16 %r, {NROWS}
  br i1 %r.lt, label %row.body, label %done

row.body:
  %sp = getelementptr [{RPLEN} x i16], [{RPLEN} x i16]* %%row_ptr%%, i16 0, i16 %r
  %s = load i16, i16* %sp, align 2
  %r.p1 = add i16 %r, 1
  %ep = getelementptr [{RPLEN} x i16], [{RPLEN} x i16]* %%row_ptr%%, i16 0, i16 %r.p1
  %e = load i16, i16* %ep, align 2
  br label %nz.head

nz.head:
  %j = phi i16 [ %s, %row.body ], [ %j.next, %nz.body ]
  %acc = phi float [ 0.000000e+00, %row.body ], [ %acc.next, %nz.body ]
  %j.lt = icmp ult i16 %j, %e
  br i1 %j.lt, label %nz.body, label %nz.done

nz.body:
  %cp = getelementptr [{MAXNNZ} x i16], [{MAXNNZ} x i16]* %%col_idx%%, i16 0, i16 %j
  %c = load i16, i16* %cp, align 2
  %vp = getelementptr [{MAXNNZ} x float], [{MAXNNZ} x float]* %%val%%, i16 0, i16 %j
  %v = load float, float* %vp, align 4
  %xp = getelementptr [{NCOLS} x float], [{NCOLS} x float]* %%x%%, i16 0, i16 %c
  %xv = load float, float* %xp, align 4
  %prod = fmul float %v, %xv
  %acc.next = fadd float %acc, %prod
  %j.next = add i16 %j, 1
  br label %nz.head

nz.done:
  %yp = getelementptr [{NROWS} x float], [{NROWS} x float]* %%y_ir%%, i16 0, i16 %r
  store float %acc, float* %yp, align 4
  br label %row.tail

row.tail:
  %r.next = add i16 %r, 1
  br label %row.head

done:
  store i16 {0x7000 + MARK['ir'][1]}, i16* getelementptr inbounds ([16 x i16], [16 x i16]* %%mark%%, i16 0, i16 {MARK['ir'][1]}), align 2
  call void @llvm.sdr.actvt.r(i16 9)
  ret void"""

if __name__ == "__main__":
    h = Path(__file__).parent
    (h / "layout.csl").write_text(LAYOUT); (h / "pe.csl").write_text(pe())
    (h / "spmv_ir_body.ll").write_text(IR_BODY + "\n")
    (h / "meta.json").write_text(json.dumps({"NROWS": NROWS, "NCOLS": NCOLS, "MAXNNZ": MAXNNZ,
                                             "RPLEN": RPLEN, "NDIA": NDIA, "MARK": MARK}, indent=1))
    print(f"wrote layout.csl, pe.csl, spmv_ir_body.ll ({len(IR_BODY.splitlines())} lines of hand-authored IR)")
