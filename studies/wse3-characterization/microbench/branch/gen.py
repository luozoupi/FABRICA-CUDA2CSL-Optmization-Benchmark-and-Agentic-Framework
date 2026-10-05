#!/usr/bin/env python3
"""Branch microbench: how does a conditional branch cost on this pipeline?

Five variants on one PE, identical arithmetic, differing only in control flow.
Conditions come from a data array sent by the host, so the compiler cannot fold
them; the SAME code runs against three flag patterns:

  straight   512 adds, no branch at all (straight-line, unrolled)   -- baseline
  loop       512 adds in a while loop                               -- one taken back-edge per iteration
  cond_true  loop, body guarded by `if (flag[i] != 0)`, flags all 1 -- the skip-branch is NEVER taken
  cond_false same code, flags all 0                                 -- the skip-branch is ALWAYS taken
  cond_alt   same code, flags alternate 1,0,1,0                     -- taken every other time

If there is a branch predictor, cond_alt should cost more than either constant
pattern; if branches resolve statically, all three cost the same per taken/not
taken outcome and the difference between cond_true and cond_false is the pure
taken-branch penalty.  The dispatch trace then shows the gap after each `jmp`.
The guarded body is three dependent ops so if-conversion is unattractive.
"""
from pathlib import Path

N, REPS = 512, 16
straight = "\n".join(f"  s = s + ia[{i}];" for i in range(N))

PE = f"""param memcpy_params;
const EXIT: local_task_id = @get_local_task_id(9);
const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);
const timestamp = @import_module("<time>");

var tsc_s = @zeros([timestamp.tsc_size_words]u16);
var tsc_e = @zeros([timestamp.tsc_size_words]u16);
var timer_buf = @zeros([15]f32);
var ptr_timer_buf: [*]f32 = &timer_buf;
var sink = @zeros([5]f32);
var ptr_sink: [*]f32 = &sink;

var ia = @zeros([{N}]i16);
var f_true = @zeros([{N}]i16);
var f_false = @zeros([{N}]i16);
var f_alt = @zeros([{N}]i16);
var ptr_ia: [*]i16 = &ia;
var ptr_f_true: [*]i16 = &f_true;
var ptr_f_false: [*]i16 = &f_false;
var ptr_f_alt: [*]i16 = &f_alt;
var s: i16 = 0;

fn bench_straight() void {{
  var rr: u16 = 0;
  while (rr < {REPS}) : (rr += 1) {{
{straight}
  }}
}}

fn bench_loop() void {{
  var rr: u16 = 0;
  while (rr < {REPS}) : (rr += 1) {{
    var i: u16 = 0;
    while (i < {N}) : (i += 1) {{ s = s + ia[i]; }}
  }}
}}

fn guarded(flags: *[{N}]i16) void {{
  var rr: u16 = 0;
  while (rr < {REPS}) : (rr += 1) {{
    var i: u16 = 0;
    while (i < {N}) : (i += 1) {{
      if (flags.*[i] != 0) {{
        s = s + ia[i];
        s = s ^ (s << 1);
        s = s + 3;
      }}
    }}
  }}
}}
fn bench_true() void {{ guarded(&f_true); }}
fn bench_false() void {{ guarded(&f_false); }}
fn bench_alt() void {{ guarded(&f_alt); }}

fn compute() void {{
  var lo_: u16 = 0;
  var hi_: u16 = 0;
  timestamp.enable_tsc();
__TIMINGS__
  timestamp.disable_tsc();
  @activate(EXIT);
}}

task f_exit() void {{ sys_mod.unblock_cmd_stream(); }}

comptime {{
  @bind_local_task(f_exit, EXIT);
  @export_symbol(ptr_timer_buf, "maxmin_time");
  @export_symbol(ptr_sink, "sink");
  @export_symbol(ptr_ia, "ia");
  @export_symbol(ptr_f_true, "f_true");
  @export_symbol(ptr_f_false, "f_false");
  @export_symbol(ptr_f_alt, "f_alt");
  @export_symbol(compute);
}}
"""

def timing(i, fn):
    b = i * 3
    return f"""
  s = 0;
  timestamp.get_timestamp(&tsc_s);
  {fn}();
  timestamp.get_timestamp(&tsc_e);
  sink[{i}] = @as(f32, s);
  lo_ = tsc_s[0]; hi_ = tsc_s[1];
  timer_buf[{b}] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));
  lo_ = tsc_s[2]; hi_ = tsc_e[0];
  timer_buf[{b+1}] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));
  lo_ = tsc_e[1]; hi_ = tsc_e[2];
  timer_buf[{b+2}] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));
"""

VARIANTS = ["straight", "loop", "true", "false", "alt"]
LAYOUT = """const memcpy = @import_module("<memcpy/get_params>", .{ .width = 1, .height = 1 });
layout {
  @set_rectangle(1, 1);
  @set_tile_code(0, 0, "pe.csl", .{ .memcpy_params = memcpy.get_params(0) });
  @export_name("maxmin_time", [*]f32, true);
  @export_name("sink", [*]f32, true);
  @export_name("ia", [*]i16, true);
  @export_name("f_true", [*]i16, true);
  @export_name("f_false", [*]i16, true);
  @export_name("f_alt", [*]i16, true);
  @export_name("compute", fn()void);
}
"""
if __name__ == "__main__":
    here = Path(__file__).parent
    (here / "pe.csl").write_text(PE.replace("__TIMINGS__", "".join(timing(i, f"bench_{v}") for i, v in enumerate(VARIANTS))))
    (here / "layout.csl").write_text(LAYOUT)
    import json; (here / "meta.json").write_text(json.dumps({"N": N, "REPS": REPS, "variants": VARIANTS}))
    print("wrote pe.csl layout.csl meta.json")
