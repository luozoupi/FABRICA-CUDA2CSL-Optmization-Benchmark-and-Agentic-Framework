#!/usr/bin/env python3
"""Generate the SRAM read/write bank-conflict microbench.

The cs_readelf man page documents the rule but not its cost:

    "Cerebras devices have 8 hardware banks.  The bank a memory access lies in is
     determined by bits [3:1] of the address...  Bank conflicts where concurrent
     reads and writes target the same bank OR THE SAME BANK MODULO 4 may result
     in cycle delays."

The study already confirmed the stride/alignment half of this on silicon (24
cases, 1.94x penalty).  The *read/write* half -- a concurrent read and write
colliding -- has never been probed, and it is the half the sentence is actually
about.

METHOD.  A DSD copy issues a read and a write every cycle, so `@fmovs(dst, src)`
is the natural concurrent read/write generator.  Every variant copies the same
element count from the same source; only the destination's element offset within
a shared pool changes, 0..7.  f32 occupies 2 words, so a unit element offset
moves the destination 2 bank positions and the 8 variants sweep every bank
relationship exactly twice.

Crucially the predicted conflict classes are NOT computed from the source offset
alone -- `run.py` reads the linked addresses of `pool` and `src` out of the ELF
and derives bank(addr) = bits[3:1] from the real placement, because the compiler
chooses the base addresses and assuming them would beg the question.
"""

import argparse
from pathlib import Path

# (label, dest element offset, source stride, source alignment)
#
# The first eight sweep the read/write bank relationship at stride 1 -- the case
# the man page's "concurrent reads and writes" sentence describes.
#
# The last four are a POSITIVE CONTROL, not a new question.  They shift BOTH the
# source and the destination by `align`, matching what the study's original
# single-pe-bank probe varies (calibration_codegen.py:1886, `base = lane *
# storage + alignment`) -- an absolute shift of the access window, not the
# relative source/destination offset the first eight sweep.  The study already
# measured a 1.94x penalty from strided access with exactly one slow alignment
# class per stride.  If this probe cannot reproduce that known effect, then a
# flat read/write result means the probe is insensitive, not that the effect is
# absent -- so the control has to run in the same binary, on the same clock.
VARIANTS = ([(f"rw-off{k}", k, 1, 0) for k in range(8)]
            + [(f"ctl-s2a{a}", a, 2, a) for a in range(4)])
OFFSETS = list(range(len(VARIANTS)))


def bench_fn(idx: int) -> str:
    _label, off, stride, align = VARIANTS[idx]
    src = (f"|i|{{n}} -> src_arr[i]" if stride == 1
           else f"|i|{{n}} -> src_arr[{stride} * i + {align}]")
    return f"""
fn bench_off{idx}() void {{
  const dst = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{n}} -> pool[i + {off}] }});
  const s   = @get_dsd(mem1d_dsd, .{{ .tensor_access = {src} }});
  var r: u16 = 0;
  while (r < reps) : (r += 1) {{
    @fmovs(dst, s);
  }}
}}
"""


def timing_block(k: int) -> str:
    b = k * 3
    return f"""
  timestamp.get_timestamp(&tsc_s{k});
  bench_off{k}();
  timestamp.get_timestamp(&tsc_e{k});
  lo_ = tsc_s{k}[0]; hi_ = tsc_s{k}[1];
  timer_buf[{b + 0}] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));
  lo_ = tsc_s{k}[2]; hi_ = tsc_e{k}[0];
  timer_buf[{b + 1}] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));
  lo_ = tsc_e{k}[1]; hi_ = tsc_e{k}[2];
  timer_buf[{b + 2}] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));
"""


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=str(Path(__file__).parent))
    a = ap.parse_args()
    out = Path(a.out)

    (out / "layout.csl").write_text("""// Bank read/write conflict microbench: one PE, 8 destination bank offsets.
param n: u16;
param reps: u16;

const memcpy = @import_module("<memcpy/get_params>", .{ .width = 1, .height = 1 });

layout {
  @set_rectangle(1, 1);
  const memcpy_params = memcpy.get_params(0);
  @set_tile_code(0, 0, "pe.csl", .{
    .memcpy_params = memcpy_params, .n = n, .reps = reps,
  });
  @export_name("src", [*]f32, true);
  @export_name("pool", [*]f32, true);
  @export_name("maxmin_time", [*]f32, true);
  @export_name("compute", fn()void);
}
""")

    tsc = "\n".join(
        f"var tsc_s{k} = @zeros([timestamp.tsc_size_words]u16);\n"
        f"var tsc_e{k} = @zeros([timestamp.tsc_size_words]u16);" for k in OFFSETS)

    (out / "pe.csl").write_text(f"""// Bank read/write conflict probe.  Identical copy work in every variant;
// only the destination's element offset (0..7) inside `pool` changes.
param memcpy_params;
param n: u16;
param reps: u16;

const EXIT: local_task_id = @get_local_task_id(9);
const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);
const timestamp = @import_module("<time>");

{tsc}

var timer_buf = @zeros([{3 * len(OFFSETS)}]f32);
var ptr_timer_buf: [*]f32 = &timer_buf;

var src_arr = @zeros([2 * n + 4]f32);  // headroom for the strided control
var ptr_src: [*]f32 = &src_arr;
// Room for the largest offset so every variant writes the same element count.
var pool = @zeros([n + {max(OFFSETS) + 1}]f32);
var ptr_pool: [*]f32 = &pool;

{"".join(bench_fn(k) for k in OFFSETS)}
fn compute() void {{
  var lo_: u16 = 0;
  var hi_: u16 = 0;
  timestamp.enable_tsc();
{"".join(timing_block(k) for k in OFFSETS)}
  timestamp.disable_tsc();
  @activate(EXIT);
}}

task f_exit() void {{ sys_mod.unblock_cmd_stream(); }}

comptime {{
  @bind_local_task(f_exit, EXIT);
  @export_symbol(ptr_src, "src");
  @export_symbol(ptr_pool, "pool");
  @export_symbol(ptr_timer_buf, "maxmin_time");
  @export_symbol(compute);
}}
""")
    print(f"wrote {out}/layout.csl and {out}/pe.csl ({len(OFFSETS)} bank offsets)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
