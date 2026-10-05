#!/usr/bin/env python3
"""Generate the loop-form probe: what does each nesting level cost?

Step 1 (microbench/extent) showed a single `@fmach` dispatch covers at least
22,000 elements -- the whole PE -- so WaferLLM's 16-element tile is a software
choice, not an ISA limit.  This asks what that choice costs.

Four shapes, identical total FP element count (TOTAL), differing only in how the
work is divided between the hardware loop (the DSD) and software loops:

  L0  one @fmach over a TOTAL-length DSD          0 software loops
  L1  while loop over TILE-length @fmach          1
  L2  @map over a DSD, body does a TILE @fmach    2   (the MeshGEMV shape)
  L3  for + @map + TILE @fmach                    3   (the MeshGEMM shape)

Reported per FP element so the shapes are directly comparable.
"""

import argparse
from pathlib import Path

TOTAL = 4096
TILE = 16
OUTER = TOTAL // TILE            # 256 for L1/L2
L3_K = 16                        # L3: K * MAP * TILE == TOTAL
L3_MAP = TOTAL // (TILE * L3_K)  # 16

VARIANTS = ["L0", "L1", "L2", "L3"]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=str(Path(__file__).parent))
    a = ap.parse_args()
    out = Path(a.out)

    (out / "layout.csl").write_text("""// Loop-form probe: one PE, four nesting depths, identical FP element count.
const memcpy = @import_module("<memcpy/get_params>", .{ .width = 1, .height = 1 });
layout {
  @set_rectangle(1, 1);
  @set_tile_code(0, 0, "pe.csl", .{ .memcpy_params = memcpy.get_params(0) });
  @export_name("C", [*]f16, true);
  @export_name("maxmin_time", [*]f32, true);
  @export_name("compute", fn()void);
}
""")

    tsc = "\n".join(
        f"var tsc_s{i} = @zeros([timestamp.tsc_size_words]u16);\n"
        f"var tsc_e{i} = @zeros([timestamp.tsc_size_words]u16);"
        for i in range(len(VARIANTS)))

    timings = "".join(f"""
  timestamp.get_timestamp(&tsc_s{i});
  bench_{v}();
  timestamp.get_timestamp(&tsc_e{i});
  lo_ = tsc_s{i}[0]; hi_ = tsc_s{i}[1];
  timer_buf[{i*3+0}] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));
  lo_ = tsc_s{i}[2]; hi_ = tsc_e{i}[0];
  timer_buf[{i*3+1}] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));
  lo_ = tsc_e{i}[1]; hi_ = tsc_e{i}[2];
  timer_buf[{i*3+2}] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));
""" for i, v in enumerate(VARIANTS))

    (out / "pe.csl").write_text(f"""// Loop-form probe.  Every variant performs {TOTAL} f16 FMA elements.
param memcpy_params;

const EXIT: local_task_id = @get_local_task_id(9);
const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);
const timestamp = @import_module("<time>");

{tsc}

var timer_buf = @zeros([{3*len(VARIANTS)}]f32);
var ptr_timer_buf: [*]f32 = &timer_buf;

var A = @zeros([{TOTAL}]f16);
var B = @zeros([{TOTAL}]f16);
var C = @zeros([{TOTAL}]f16);
var ptr_C: [*]f16 = &C;

// L0: the whole problem as one hardware loop.
fn bench_L0() void {{
  const a = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{TOTAL}}} -> A[i] }});
  const b = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{TOTAL}}} -> B[i] }});
  const c = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{TOTAL}}} -> C[i] }});
  @fmach(c, a, b, @as(f16, 1.0009765625));
}}

// L1: one software loop over {TILE}-element tiles.
fn bench_L1() void {{
  var i: u16 = 0;
  while (i < {OUTER}) : (i += 1) {{
    const a = @get_dsd(mem1d_dsd, .{{ .tensor_access = |k|{{{TILE}}} -> A[k] }});
    const b = @get_dsd(mem1d_dsd, .{{ .tensor_access = |k|{{{TILE}}} -> B[k] }});
    const c = @get_dsd(mem1d_dsd, .{{ .tensor_access = |k|{{{TILE}}} -> C[k] }});
    @fmach(c, a, b, @as(f16, 1.0009765625));
  }}
}}

// L2: @map over a DSD -- the MeshGEMV shape.
const map_a = @get_dsd(mem1d_dsd, .{{ .tensor_access = |k|{{{TILE}}} -> A[k] }});
const map_b = @get_dsd(mem1d_dsd, .{{ .tensor_access = |k|{{{TILE}}} -> B[k] }});
const map_c = @get_dsd(mem1d_dsd, .{{ .tensor_access = |k|{{{TILE}}} -> C[k] }});
const outer_dsd = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{OUTER}}} -> A[i] }});

fn step(cur: f16) void {{
  @fmach(map_c, map_a, map_b, cur);
}}

fn bench_L2() void {{
  @map(step, outer_dsd);
}}

// L3: for + @map + DSD -- the MeshGEMM shape.
const inner_dsd = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{L3_MAP}}} -> A[i] }});

fn bench_L3() void {{
  for (@range(i16, {L3_K})) |k| {{
    @map(step, inner_dsd);
  }}
}}

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
  @export_symbol(ptr_C, "C");
  @export_symbol(ptr_timer_buf, "maxmin_time");
  @export_symbol(compute);
}}
""")
    (out / "meta.json").write_text(__import__("json").dumps(
        {"total_elements": TOTAL, "tile": TILE, "outer": OUTER,
         "l3_k": L3_K, "l3_map": L3_MAP, "variants": VARIANTS}, indent=1))
    print(f"wrote {out}/layout.csl, pe.csl  (TOTAL={TOTAL} f16 FMA elements per variant)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
