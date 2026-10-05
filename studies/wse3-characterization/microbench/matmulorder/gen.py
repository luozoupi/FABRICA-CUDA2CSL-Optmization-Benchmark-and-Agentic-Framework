#!/usr/bin/env python3
"""Generate the matmul-traversal probe: all six loop orders, one PE, identical work.

The question is which traversal of C = A*B a WSE-3 PE actually wants. Two already
measured facts decide it in advance, so this is a prediction under test, not a
survey:

  1. FMACH is a fused multiply-add computing  dest = src0 + src1 * src2  with a
     single rounding, where src2 is ONE scalar broadcast to all 8 lanes
     (2,816 lane records; of the 165 that discriminate, 100% fused, 0% unfused).
     The hardware FMA is therefore an *axpy*: vector += vector * scalar.
  2. A dependent f16 accumulation runs one element per 2 cycles on ONE lane,
     where independent elements run 8 per cycle.

So a traversal whose innermost loop walks the OUTPUT vector is one FMACH per
inner iteration at 8 lanes. A traversal whose innermost loop walks K is a dot
product, which the ISA cannot express as one FMA: it needs a multiply plus a
reduction, and the reduction is exactly the dependent chain from (2).

  ikj, kij   j innermost -> C[i,:] += B[k,:] * A[i,k]   unit stride, 8 lanes
  jki, kji   i innermost -> C[:,j] += A[:,k] * B[k,j]   stride N,    8 lanes
  ijk, jik   k innermost -> C[i,j]  = sum_k ...         reduction,   1 lane

All six compute the same C over the same arrays with the same MAC count, and each
result is exported separately so the numbers are checked, not assumed.
"""

import argparse
from pathlib import Path

M = N = K = 32
VARIANTS = ["ikj", "kij", "jki", "kji", "ijk", "jik", "ikj_map", "ijk_scalar",
            "ijk_bt", "ikj_map_blk", "ijk_tree", "kij_map", "outer_tile4", "outer_tile4b", "outer_tile4c"]


def layout_csl() -> str:
    return """// Matmul traversal probe: one PE, six loop orders, identical MAC count.
const memcpy = @import_module("<memcpy/get_params>", .{ .width = 1, .height = 1 });
layout {
  @set_rectangle(1, 1);
  @set_tile_code(0, 0, "pe.csl", .{ .memcpy_params = memcpy.get_params(0) });
  @export_name("A", [*]f16, true);
  @export_name("B", [*]f16, true);
  @export_name("Bt", [*]f16, true);
  @export_name("Cout", [*]f16, true);
  @export_name("cycles", [*]f32, true);
  @export_name("compute", fn()void);
}
"""


def bench_body(v: str) -> str:
    """One CSL function per traversal. Loop order is the only difference."""
    if v in ("ikj", "kij"):
        outer, mid = ("i", "k") if v == "ikj" else ("k", "i")
        lim = {"i": M, "k": K}
        return f"""
// {v}: innermost loop walks C's row -> one FMACH, unit stride, all 8 lanes.
fn bench_{v}() void {{
  var {outer}: u16 = 0;
  while ({outer} < {lim[outer]}) : ({outer} += 1) {{
    var {mid}: u16 = 0;
    while ({mid} < {lim[mid]}) : ({mid} += 1) {{
      var cd = @increment_dsd_offset(c_row, @as(i16, i * {N}), f16);
      var bd = @increment_dsd_offset(b_row, @as(i16, k * {N}), f16);
      @fmach(cd, cd, bd, A[i * {K} + k]);
    }}
  }}
}}
"""
    if v in ("jki", "kji"):
        outer, mid = ("j", "k") if v == "jki" else ("k", "j")
        lim = {"j": N, "k": K}
        return f"""
// {v}: innermost loop walks C's column -> one FMACH, stride {N}, all 8 lanes.
fn bench_{v}() void {{
  var {outer}: u16 = 0;
  while ({outer} < {lim[outer]}) : ({outer} += 1) {{
    var {mid}: u16 = 0;
    while ({mid} < {lim[mid]}) : ({mid} += 1) {{
      var cd = @increment_dsd_offset(c_col, @as(i16, j), f16);
      var ad = @increment_dsd_offset(a_col, @as(i16, k), f16);
      @fmach(cd, cd, ad, B[k * {N} + j]);
    }}
  }}
}}
"""
    if v == "ikj_map":
        # The WaferLLM idiom: load the descriptors once per output row, then let
        # @map walk A's row feeding scalars. No per-iteration address arithmetic.
        return f"""
// ikj_map: same traversal as ikj, but the descriptors are loaded once per row
// and @map supplies the scalars, so the inner loop is pure FMACH.
fn step_map(alpha: f16) void {{
  @fmach(c_dsr_d, c_dsr_0, b_dsr_1, alpha);
}}

fn bench_ikj_map() void {{
  var i: u16 = 0;
  while (i < {M}) : (i += 1) {{
    var cd = @increment_dsd_offset(c_row, @as(i16, i * {N}), f16);
    @load_to_dsr(c_dsr_d, cd, .{{ .save_address = false }});
    @load_to_dsr(c_dsr_0, cd, .{{ .save_address = false }});
    @load_to_dsr(b_dsr_1, b_row, .{{ .save_address = true }});
    var ad = @increment_dsd_offset(a_row, @as(i16, i * {K}), f16);
    @map(step_map, ad);
  }}
}}
"""
    if v == "ijk_bt":
        # Inner product again, but reading B from a pre-transposed copy so BOTH
        # operands are unit stride. If stride is what costs the lanes, the
        # multiply here must jump from 1 lane to 8. Falsifiable.
        return f"""
// ijk_bt: dot product with B pre-transposed, so both operands are unit stride.
// A direct test of the claim that a strided operand is what collapses the lanes.
fn bench_ijk_bt() void {{
  var i: u16 = 0;
  while (i < {M}) : (i += 1) {{
    var j: u16 = 0;
    while (j < {N}) : (j += 1) {{
      var ad = @increment_dsd_offset(a_row, @as(i16, i * {K}), f16);
      var bd = @increment_dsd_offset(bt_row, @as(i16, j * {K}), f16);
      @fmulh(t_vec, ad, bd);
      var acc: f16 = @as(f16, 0.0);
      @faddh(&acc, acc, t_vec);
      C[i * {N} + j] = acc;
    }}
  }}
}}
"""
    if v == "ikj_map_blk":
        # The seventh textbook way: tiling. On a PE with a flat scratchpad and no
        # cache there is no reuse to win, so this should not help.
        return f"""
// ikj_map_blk: the seventh textbook way, tiling. The output row is split into
// {N//4}-element tiles. Note what this costs: @map's streaming operand advances by
// the DSD length, so once the tile width ({N//4}) stops matching B's row pitch ({N}),
// the stream walks the wrong elements. A correct tiled version must reload B
// every k -- which is precisely the per-iteration descriptor traffic that made
// the untiled version fast.
fn bench_ikj_map_blk() void {{
  var i: u16 = 0;
  while (i < {M}) : (i += 1) {{
    var jb: u16 = 0;
    while (jb < 4) : (jb += 1) {{
      var cd = @set_dsd_length(@increment_dsd_offset(c_row,
                 @as(i16, i * {N} + jb * {N//4}), f16), {N//4});
      var k: u16 = 0;
      while (k < {K}) : (k += 1) {{
        var bd = @set_dsd_length(@increment_dsd_offset(b_row,
                   @as(i16, k * {N} + jb * {N//4}), f16), {N//4});
        @fmach(cd, cd, bd, A[i * {K} + k]);
      }}
    }}
  }}
}}
"""
    if v == "ijk_tree":
        # The fix for the broken inner-product variants. @faddh(&acc, acc, dsd)
        # miscompiles, so the reduction is done as a log2(K) tree of ELEMENTWISE
        # vector adds instead -- every one of which is lane-parallel and none of
        # which is a horizontal reduction. B comes from the transposed copy so
        # both multiply operands are unit stride.
        tree = "\n".join(
            f"      @faddh(t{w}a, t{w}a, t{w}b);" for w in (16, 8, 4, 2, 1))
        return f"""
// ijk_tree: inner product done correctly -- multiply, then a {K}-element
// reduction as {K.bit_length()-1} elementwise vector adds. No horizontal reduction anywhere.
fn bench_ijk_tree() void {{
  var i: u16 = 0;
  while (i < {M}) : (i += 1) {{
    var j: u16 = 0;
    while (j < {N}) : (j += 1) {{
      var ad = @increment_dsd_offset(a_row, @as(i16, i * {K}), f16);
      var bd = @increment_dsd_offset(bt_row, @as(i16, j * {K}), f16);
      @fmulh(t_vec, ad, bd);
{tree}
      C[i * {N} + j] = t_buf[0];
    }}
  }}
}}
"""
    if v == "kij_map":
        # The outer product with the same descriptor hoisting that made ikj_map
        # fast. Consecutive FMACHs write DIFFERENT rows of C, so unlike ikj_map
        # they carry no read-after-write dependency on each other.
        return f"""
// kij_map: outer product, descriptors hoisted. For a fixed k the scalars come
// from a column of A and each step writes a different row of C, so the FMACHs
// are mutually independent -- ikj_map's are a dependent chain on one row.
fn bench_kij_map() void {{
  var k: u16 = 0;
  while (k < {K}) : (k += 1) {{
    @load_to_dsr(c_dsr_d, c_row, .{{ .save_address = true }});
    @load_to_dsr(c_dsr_0, c_row, .{{ .save_address = true }});
    var bd = @increment_dsd_offset(b_row, @as(i16, k * {N}), f16);
    @load_to_dsr(b_dsr_1, bd, .{{ .save_address = false }});
    var ak = @increment_dsd_offset(a_col, @as(i16, k), f16);
    @map(step_map, ak);
  }}
}}
"""
    if v == "outer_tile4":
        # The tiled outer product the GPU account calls the real inner loop:
        # hold a tile of C, walk k, and reuse each loaded operand across the tile.
        body = "\n".join(
            f"        @fmach(cd{r}, cd{r}, bd, A[(ib * 4 + {r}) * {K} + k]);"
            for r in range(4))
        decl = "\n".join(
            f"      var cd{r} = @increment_dsd_offset(c_row, @as(i16, (ib * 4 + {r}) * {N}), f16);"
            for r in range(4))
        return f"""
// outer_tile4: the tiled outer product. Four rows of C are held as a tile and k
// is walked once, so each B row loaded feeds 4 x {N} MACs instead of {N}. On a GPU the
// tile would live in registers; here it can only live in SRAM.
fn bench_outer_tile4() void {{
  var ib: u16 = 0;
  while (ib < {M // 4}) : (ib += 1) {{
{decl}
    var k: u16 = 0;
    while (k < {K}) : (k += 1) {{
      var bd = @increment_dsd_offset(b_row, @as(i16, k * {N}), f16);
{body}
    }}
  }}
}}
"""
    if v == "outer_tile4b":
        # The same tile, written so the inner loop contains no index arithmetic:
        # every A offset and the B offset advance by a constant add per k. This
        # separates the cost of the tiled-outer-product IDEA from the cost of the
        # address math a naive spelling of it generates.
        decl = "\n".join(
            f"    var cd{r} = @increment_dsd_offset(c_row, @as(i16, (ib * 4 + {r}) * {N}), f16);\n"
            f"    var a{r}: u16 = (ib * 4 + {r}) * {K};" for r in range(4))
        body = "\n".join(
            f"      @fmach(cd{r}, cd{r}, bd, A[a{r}]);" for r in range(4))
        bump = "\n".join(f"      a{r} += 1;" for r in range(4))
        return f"""
// outer_tile4b: the tiled outer product with running offsets instead of index
// arithmetic. Same tile, same reuse, no multiplies in the inner loop.
fn bench_outer_tile4b() void {{
  var ib: u16 = 0;
  while (ib < {M // 4}) : (ib += 1) {{
{decl}
    var bo: i16 = 0;
    var k: u16 = 0;
    while (k < {K}) : (k += 1) {{
      var bd = @increment_dsd_offset(b_row, bo, f16);
{body}
{bump}
      bo += {N};
    }}
  }}
}}
"""
    if v == "outer_tile4c":
        # The tiled outer product given the machine what it actually needs: the
        # four C-row descriptors pinned in DSRs for the whole tile, so nothing
        # spills, and one B descriptor load amortised across four FMACHs.
        loads = "\n".join(
            f"    var cd{r} = @increment_dsd_offset(c_row, @as(i16, (ib * 4 + {r}) * {N}), f16);\n"
            f"    @load_to_dsr(td{r}, cd{r}, .{{ .save_address = false }});\n"
            f"    @load_to_dsr(ts{r}, cd{r}, .{{ .save_address = false }});\n"
            f"    var a{r}: u16 = (ib * 4 + {r}) * {K};" for r in range(4))
        body = "\n".join(f"      @fmach(td{r}, ts{r}, tb1, A[a{r}]);" for r in range(4))
        bump = "\n".join(f"      a{r} += 1;" for r in range(4))
        return f"""
// outer_tile4c: the tiled outer product with all four C-row descriptors pinned
// in DSRs for the tile's lifetime. One B descriptor load now feeds four FMACHs,
// and the four are mutually independent because they write different rows.
fn bench_outer_tile4c() void {{
  var ib: u16 = 0;
  while (ib < {M // 4}) : (ib += 1) {{
{loads}
    var bo: i16 = 0;
    var k: u16 = 0;
    while (k < {K}) : (k += 1) {{
      var bd = @increment_dsd_offset(b_row, bo, f16);
      @load_to_dsr(tb1, bd, .{{ .save_address = false }});
{body}
{bump}
      bo += {N};
    }}
  }}
}}
"""
    if v == "ijk_scalar":
        # The dot-product traversal written without a DSD at all: correct, and the
        # honest baseline for what the k-innermost order costs when it must work.
        return f"""
// ijk_scalar: k innermost as a plain scalar loop. No DSD, no reduction builtin,
// so it is correct; it is also the slowest thing here.
fn bench_ijk_scalar() void {{
  var i: u16 = 0;
  while (i < {M}) : (i += 1) {{
    var j: u16 = 0;
    while (j < {N}) : (j += 1) {{
      var acc: f16 = @as(f16, 0.0);
      var k: u16 = 0;
      while (k < {K}) : (k += 1) {{
        acc += A[i * {K} + k] * B[k * {N} + j];
      }}
      C[i * {N} + j] = acc;
    }}
  }}
}}
"""
    outer, mid = ("i", "j") if v == "ijk" else ("j", "i")
    lim = {"i": M, "j": N}
    return f"""
// {v}: innermost loop walks K -> a dot product. Not one FMA: multiply, then a
// dependent reduction.
fn bench_{v}() void {{
  var {outer}: u16 = 0;
  while ({outer} < {lim[outer]}) : ({outer} += 1) {{
    var {mid}: u16 = 0;
    while ({mid} < {lim[mid]}) : ({mid} += 1) {{
      var ad = @increment_dsd_offset(a_row, @as(i16, i * {K}), f16);
      var bd = @increment_dsd_offset(b_col, @as(i16, j), f16);
      @fmulh(t_vec, ad, bd);
      var acc: f16 = @as(f16, 0.0);
      @faddh(&acc, acc, t_vec);
      C[i * {N} + j] = acc;
    }}
  }}
}}
"""


def pe_csl() -> str:
    tsc = "\n".join(
        f"var tsc_s{i} = @zeros([timestamp.tsc_size_words]u16);\n"
        f"var tsc_e{i} = @zeros([timestamp.tsc_size_words]u16);"
        for i in range(len(VARIANTS)))

    timed = []
    for i, v in enumerate(VARIANTS):
        timed.append(f"""
  zero_C();
  timestamp.get_timestamp(&tsc_s{i});
  bench_{v}();
  timestamp.get_timestamp(&tsc_e{i});
  save_C({i});
  lo_ = tsc_s{i}[0]; hi_ = tsc_s{i}[1];
  cyc_buf[{i*3+0}] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));
  lo_ = tsc_s{i}[2]; hi_ = tsc_e{i}[0];
  cyc_buf[{i*3+1}] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));
  lo_ = tsc_e{i}[1]; hi_ = tsc_e{i}[2];
  cyc_buf[{i*3+2}] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));""")

    return f"""// Matmul traversal probe.  Six loop orders, {M}x{N}x{K} f16, {M*N*K} MACs each.
param memcpy_params;

const EXIT: local_task_id = @get_local_task_id(9);
const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);
const timestamp = @import_module("<time>");

{tsc}

var cyc_buf = @zeros([{len(VARIANTS)*3}]f32);
var ptr_cyc: [*]f32 = &cyc_buf;

var A = @zeros([{M*K}]f16);
var B = @zeros([{K*N}]f16);
var Bt = @zeros([{K*N}]f16);
var ptr_Bt: [*]f16 = &Bt;
var C = @zeros([{M*N}]f16);
var Cout = @zeros([{len(VARIANTS)*(4*N + M)}]f16);
var ptr_A: [*]f16 = &A;
var ptr_B: [*]f16 = &B;
var ptr_Cout: [*]f16 = &Cout;

var t_buf = @zeros([{K}]f16);

// Descriptor registers for the @map idiom.
const c_dsr_d = @get_dsr(dsr_dest, 0);
const c_dsr_0 = @get_dsr(dsr_src0, 0);
const b_dsr_1 = @get_dsr(dsr_src1, 1);
const td0 = @get_dsr(dsr_dest, 2);
const td1 = @get_dsr(dsr_dest, 3);
const td2 = @get_dsr(dsr_dest, 4);
const td3 = @get_dsr(dsr_dest, 5);
const ts0 = @get_dsr(dsr_src0, 2);
const ts1 = @get_dsr(dsr_src0, 3);
const ts2 = @get_dsr(dsr_src0, 4);
const ts3 = @get_dsr(dsr_src0, 5);
const tb1 = @get_dsr(dsr_src1, 3);

// Base descriptors. Runtime row/column selection is one @increment_dsd_offset.
const c_row = @get_dsd(mem1d_dsd, .{{ .tensor_access = |j|{{{N}}} -> C[j] }});
const b_row = @get_dsd(mem1d_dsd, .{{ .tensor_access = |j|{{{N}}} -> B[j] }});
const c_col = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{M}}} -> C[i * {N}] }});
const a_col = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{M}}} -> A[i * {K}] }});
const a_row = @get_dsd(mem1d_dsd, .{{ .tensor_access = |k|{{{K}}} -> A[k] }});
const b_col = @get_dsd(mem1d_dsd, .{{ .tensor_access = |k|{{{K}}} -> B[k * {N}] }});
const bt_row = @get_dsd(mem1d_dsd, .{{ .tensor_access = |k|{{{K}}} -> Bt[k] }});
const t16a = @get_dsd(mem1d_dsd, .{{ .tensor_access = |x|{{16}} -> t_buf[x] }});
const t16b = @get_dsd(mem1d_dsd, .{{ .tensor_access = |x|{{16}} -> t_buf[x + 16] }});
const t8a  = @get_dsd(mem1d_dsd, .{{ .tensor_access = |x|{{8}}  -> t_buf[x] }});
const t8b  = @get_dsd(mem1d_dsd, .{{ .tensor_access = |x|{{8}}  -> t_buf[x + 8] }});
const t4a  = @get_dsd(mem1d_dsd, .{{ .tensor_access = |x|{{4}}  -> t_buf[x] }});
const t4b  = @get_dsd(mem1d_dsd, .{{ .tensor_access = |x|{{4}}  -> t_buf[x + 4] }});
const t2a  = @get_dsd(mem1d_dsd, .{{ .tensor_access = |x|{{2}}  -> t_buf[x] }});
const t2b  = @get_dsd(mem1d_dsd, .{{ .tensor_access = |x|{{2}}  -> t_buf[x + 2] }});
const t1a  = @get_dsd(mem1d_dsd, .{{ .tensor_access = |x|{{1}}  -> t_buf[x] }});
const t1b  = @get_dsd(mem1d_dsd, .{{ .tensor_access = |x|{{1}}  -> t_buf[x + 1] }});
const t_vec = @get_dsd(mem1d_dsd, .{{ .tensor_access = |k|{{{K}}} -> t_buf[k] }});

fn zero_C() void {{
  var z: u16 = 0;
  while (z < {M*N}) : (z += 1) {{ C[z] = @as(f16, 0.0); }}
}}

fn save_C(slot: i16) void {{
  const base: u16 = @as(u16, slot) * {4*N + M};
  var z: u16 = 0;
  while (z < {4*N}) : (z += 1) {{ Cout[base + z] = C[z]; }}   // first 4 rows verbatim
  var r: u16 = 0;
  while (r < {M}) : (r += 1) {{                                // every row's sum
    var acc: f16 = @as(f16, 0.0);
    var c: u16 = 0;
    while (c < {N}) : (c += 1) {{ acc += C[r * {N} + c]; }}
    Cout[base + {4*N} + r] = acc;
  }}
}}
{''.join(bench_body(v) for v in VARIANTS)}
fn compute() void {{
  var lo_: u16 = 0;
  var hi_: u16 = 0;
  timestamp.enable_tsc();
{''.join(timed)}
  timestamp.disable_tsc();
  @activate(EXIT);
}}

task f_exit() void {{ sys_mod.unblock_cmd_stream(); }}

comptime {{
  @bind_local_task(f_exit, EXIT);
  @export_symbol(ptr_A, "A");
  @export_symbol(ptr_B, "B");
  @export_symbol(ptr_Bt, "Bt");
  @export_symbol(ptr_Cout, "Cout");
  @export_symbol(ptr_cyc, "cycles");
  @export_symbol(compute);
}}
"""


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=str(Path(__file__).parent))
    a = ap.parse_args()
    out = Path(a.out)
    (out / "layout.csl").write_text(layout_csl())
    (out / "pe.csl").write_text(pe_csl())
    import json
    (out / "meta.json").write_text(json.dumps(
        {"M": M, "N": N, "K": K, "macs": M * N * K, "variants": VARIANTS}, indent=1))
    print(f"wrote layout.csl, pe.csl, meta.json  ({M}x{N}x{K}, {M*N*K} MACs, "
          f"{len(VARIANTS)} variants)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
