#!/usr/bin/env python3
"""Generate the ILP microbench: one PE, one loop, one instruction kind.

The question is the one the study could not answer: what is the *latency* of a
scalar FP op, and how many can issue per cycle?  A single timing number cannot
separate those -- a loop that takes N cycles per op is equally explained by
"latency N, issue 1/cyc" and "latency 1, issue 1/N cyc".

The separation comes from varying instruction-level parallelism while holding
*everything else* fixed.  Every variant runs ITERS iterations of exactly 8
scalar FMAs, so instruction count, loop count, branch count and loop overhead
are identical across all four.  The only difference is how those 8 FMAs are
distributed over independent accumulators:

    k1: one chain,    depth 8   a0 -> a0 -> a0 -> ... (fully serial)
    k2: two chains,   depth 4
    k4: four chains,  depth 2
    k8: eight chains, depth 1   (fully independent)

With latency L and issue width W, time per op is max(L/K, 1/W).  So cycles/op
halves with each doubling of K until it flattens; the K=1 value gives L and the
floor gives W.  This is the standard latency/throughput separation, and it is
only valid because the work is held constant -- the earlier `single-pe-chains`
probe varied the work along with the parallelism and so measured neither.

Accumulators are scalar locals, not array slots, so the loop body stays register
-resident FP arithmetic instead of turning into load/store traffic.  Each
variant's result is written to an exported `sink`, because dead-code elimination
silently removed an unread compute loop earlier in this study.
"""

import argparse
from pathlib import Path

VARIANTS = [1, 2, 4, 8]
FMAS_PER_ITER = 8


def bench_fn(k: int) -> str:
    """Emit one variant: FMAS_PER_ITER FMAs per iteration over k chains."""
    depth = FMAS_PER_ITER // k
    decls = "\n".join(f"  var a{j}: f32 = coef[0] + @as(f32, {j});" for j in range(k))
    # Interleave: round-robin over the k accumulators, depth times each.  This
    # is what puts `depth` dependent ops on each chain's critical path while
    # keeping the total at FMAS_PER_ITER.
    body = "\n".join(
        f"    a{j} = a{j} * c + d;" for _ in range(depth) for j in range(k)
    )
    total = " + ".join(f"a{j}" for j in range(k))
    return f"""
fn bench_k{k}() void {{
  const c = coef[0];
  const d = coef[1];
{decls}
  var i: u16 = 0;
  while (i < iters) : (i += 1) {{
{body}
  }}
  sink[{VARIANTS.index(k)}] = {total};
}}
"""


def timing_block(k: int, idx: int) -> str:
    b = idx * 3
    return f"""
  timestamp.get_timestamp(&tsc_s{idx});
  bench_k{k}();
  timestamp.get_timestamp(&tsc_e{idx});
  lo_ = tsc_s{idx}[0]; hi_ = tsc_s{idx}[1];
  timer_buf[{b + 0}] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));
  lo_ = tsc_s{idx}[2]; hi_ = tsc_e{idx}[0];
  timer_buf[{b + 1}] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));
  lo_ = tsc_e{idx}[1]; hi_ = tsc_e{idx}[2];
  timer_buf[{b + 2}] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));
"""


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--out", default=str(Path(__file__).parent))
    a = ap.parse_args()
    out = Path(a.out)
    out.mkdir(parents=True, exist_ok=True)

    (out / "layout.csl").write_text("""// ILP microbench layout: one PE, four dependency depths, identical work.
param iters: u16;

const memcpy = @import_module("<memcpy/get_params>", .{
  .width = 1,
  .height = 1,
});

layout {
  @set_rectangle(1, 1);
  const memcpy_params = memcpy.get_params(0);
  @set_tile_code(0, 0, "pe.csl", .{
    .memcpy_params = memcpy_params,
    .iters = iters,
  });
  @export_name("coef", [*]f32, true);
  @export_name("sink", [*]f32, true);
  @export_name("maxmin_time", [*]f32, true);
  @export_name("compute", fn()void);
}
""")

    tsc_decls = "\n".join(
        f"var tsc_s{i} = @zeros([timestamp.tsc_size_words]u16);\n"
        f"var tsc_e{i} = @zeros([timestamp.tsc_size_words]u16);"
        for i in range(len(VARIANTS)))
    benches = "".join(bench_fn(k) for k in VARIANTS)
    timings = "".join(timing_block(k, i) for i, k in enumerate(VARIANTS))

    (out / "pe.csl").write_text(f"""// ILP microbench: {FMAS_PER_ITER} scalar f32 FMAs per iteration in every variant.
// Variants differ only in dependency-chain depth ({', '.join(
    f'k{k}=depth {FMAS_PER_ITER // k}' for k in VARIANTS)}).
param memcpy_params;
param iters: u16;

const EXIT: local_task_id = @get_local_task_id(9);
const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);
const timestamp = @import_module("<time>");

{tsc_decls}

var timer_buf = @zeros([{3 * len(VARIANTS)}]f32);
var ptr_timer_buf: [*]f32 = &timer_buf;
var coef = @zeros([2]f32);
var ptr_coef: [*]f32 = &coef;
var sink = @zeros([{len(VARIANTS)}]f32);
var ptr_sink: [*]f32 = &sink;
{benches}
fn compute() void {{
  var lo_: u16 = 0;
  var hi_: u16 = 0;
  timestamp.enable_tsc();
{timings}
  timestamp.disable_tsc();
  @activate(EXIT);
}}

task f_exit() void {{ sys_mod.unblock_cmd_stream(); }}

comptime {{
  @bind_local_task(f_exit, EXIT);
  @export_symbol(ptr_coef, "coef");
  @export_symbol(ptr_sink, "sink");
  @export_symbol(ptr_timer_buf, "maxmin_time");
  @export_symbol(compute);
}}
""")
    print(f"wrote {out}/layout.csl and {out}/pe.csl "
          f"({len(VARIANTS)} variants, {FMAS_PER_ITER} FMAs/iter)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
