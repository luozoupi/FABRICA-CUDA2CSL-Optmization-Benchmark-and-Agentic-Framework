#!/usr/bin/env python3
"""N-stage store-and-forward relay: the depth-cost microbench.

Luczynski et al. model each store-and-forward stage as (2*T_R + 1) ~ 5 cycles on
WSE-2.  Our corpus fit (FINDINGS 10f) put the WSE-3 relay stage at k ~ 2.07, with
the caveat that trace-inferred depth might dilute it.  This measures the stage
cost directly: PE0 sends B wavelets east; every intermediate PE receives the whole
message into SRAM (async fabin DSD), and on completion re-sends it east; the last
PE timestamps completion.  T(N, B) = a*B + k*(N-1) + c, fitted over N and B.

Colours alternate 6/7 per hop because a router cannot route on ingress direction:
the colour arriving from WEST must differ from the colour this PE injects.  Queue
id == colour id follows the calibration codegen, which runs on hardware.
Timing is one simulator clock, so the raw TSC difference between PE0's send
start and PE_N's receive completion is valid without synchronisation.
"""
import argparse, json
from pathlib import Path

LAYOUT = """param N: i16;
param B: u16;
const memcpy = @import_module("<memcpy/get_params>", .{ .width = N + 1, .height = 1 });
const CA: color = @get_color(6);
const CB: color = @get_color(7);
layout {
  @set_rectangle(N + 1, 1);
  for (@range(i16, N + 1)) |i| {
    // hop j (PE j -> PE j+1) carries colour 6 when j is even, 7 when odd
    const cout_id: u16 = if (i % 2 == 0) 6 else 7;
    const cin_id: u16 = if ((i + 1) % 2 == 0) 6 else 7;
    @set_tile_code(i, 0, "pe.csl", .{
      .memcpy_params = memcpy.get_params(i), .B = B,
      .is_first = (i == 0), .is_last = (i == N),
      .cin_id = cin_id, .cout_id = cout_id,
    });
    if (i > 0) {
      @set_color_config(i, 0, if (cin_id == 6) CA else CB,
                        .{ .routes = .{ .rx = .{ WEST }, .tx = .{ RAMP } } });
    }
    if (i < N) {
      @set_color_config(i, 0, if (cout_id == 6) CA else CB,
                        .{ .routes = .{ .rx = .{ RAMP }, .tx = .{ EAST } } });
    }
  }
  @export_name("timer", [*]f32, true);
  @export_name("run", fn()void);
}
"""

PE = """param memcpy_params;
param B: u16;
param is_first: bool;
param is_last: bool;
param cin_id: u16;
param cout_id: u16;

const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);
const timestamp = @import_module("<time>");
const iq: input_queue = @get_input_queue(cin_id);
const oq: output_queue = @get_output_queue(cout_id);
const RECV_DONE: local_task_id = @get_local_task_id(19);
const SEND_DONE: local_task_id = @get_local_task_id(20);

var buf = @zeros([B]f32);
const buf_dsd = @get_dsd(mem1d_dsd, .{ .tensor_access = |i|{B} -> buf[i] });
const fin = @get_dsd(fabin_dsd, .{ .extent = B, .input_queue = iq });
const fout = @get_dsd(fabout_dsd, .{ .extent = B, .output_queue = oq });

var tsc = @zeros([timestamp.tsc_size_words]u16);
var timer = @zeros([2]f32);
var ptr_timer: [*]f32 = &timer;

fn pack() void {
  timer[0] = @bitcast(f32, (@as(u32, tsc[1]) << @as(u16, 16)) | @as(u32, tsc[0]));
  timer[1] = @bitcast(f32, @as(u32, tsc[2]));
}

// One RPC for every PE, each unblocking exactly once:
//   first PE      stamps, sends, unblocks in send_done
//   middle PEs    arm receive, forward in recv_done, unblock in send_done
//   last PE       arm receive, stamp + unblock in recv_done
fn run() void {
  timestamp.enable_tsc();
  if (is_first) {
    timestamp.get_timestamp(&tsc);
    pack();
    @fmovs(fout, buf_dsd, .{ .async = true, .activate = SEND_DONE });
  } else {
    @fmovs(buf_dsd, fin, .{ .async = true, .activate = RECV_DONE });
  }
}

task recv_done() void {
  if (is_last) {
    timestamp.get_timestamp(&tsc);
    pack();
    sys_mod.unblock_cmd_stream();
  } else {
    @fmovs(fout, buf_dsd, .{ .async = true, .activate = SEND_DONE });
  }
}

task send_done() void { sys_mod.unblock_cmd_stream(); }

comptime {
  // A queue receives nothing until it is bound to a colour (WSE-3 keeps queue
  // ids and colours distinct) -- the omission deadlocked the first sweep.
  if (!is_first) { @initialize_queue(iq, .{ .color = @get_color(cin_id) }); }
  if (!is_last)  { @initialize_queue(oq, .{ .color = @get_color(cout_id) }); }
  @bind_local_task(recv_done, RECV_DONE);
  @bind_local_task(send_done, SEND_DONE);
  @export_symbol(ptr_timer, "timer");
  @export_symbol(run);
}
"""

if __name__ == "__main__":
    here = Path(__file__).parent
    (here / "layout.csl").write_text(LAYOUT)
    (here / "pe.csl").write_text(PE)
    print("wrote layout.csl, pe.csl")
