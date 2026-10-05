#!/usr/bin/env python3
"""Fabric receive followed by computation: the fifth walkthrough of the single-PE model.

PE0 sends B f32 words east (async fabout DSD).  PE1 receives them into `buf` (async fabin
DSD, completion activates RECV_DONE) and, in that task, computes res = buf + loc with one
DSD add and unblocks.  Every array is exported so the host seeds buf on PE0 and loc on PE1
and checks res on PE1 exactly.  The receiver's dependency chain is therefore
    wavelets -> fabin queue -> fmovs (microthread) -> task activation -> fadds -> res
and the trace shows each link: wavelet records at the router, the receive's redispatch,
the task's first dispatch, the add's element records.
"""
from pathlib import Path

LAYOUT = """param B: u16;
const memcpy = @import_module("<memcpy/get_params>", .{ .width = 2, .height = 1 });
const C6: color = @get_color(6);
layout {
  @set_rectangle(2, 1);
  @set_tile_code(0, 0, "pe.csl", .{ .memcpy_params = memcpy.get_params(0), .B = B, .is_first = true });
  @set_tile_code(1, 0, "pe.csl", .{ .memcpy_params = memcpy.get_params(1), .B = B, .is_first = false });
  @set_color_config(0, 0, C6, .{ .routes = .{ .rx = .{ RAMP }, .tx = .{ EAST } } });
  @set_color_config(1, 0, C6, .{ .routes = .{ .rx = .{ WEST }, .tx = .{ RAMP } } });
  @export_name("buf", [*]f32, true); @export_name("loc", [*]f32, true); @export_name("res", [*]f32, true);
  @export_name("run", fn()void);
}
"""

PE = """param memcpy_params;
param B: u16;
param is_first: bool;

const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);
const iq: input_queue = @get_input_queue(6);
const oq: output_queue = @get_output_queue(6);
const RECV_DONE: local_task_id = @get_local_task_id(19);
const SEND_DONE: local_task_id = @get_local_task_id(20);

var buf = @zeros([B]f32); var loc = @zeros([B]f32); var res = @zeros([B]f32);
var p_buf: [*]f32 = &buf; var p_loc: [*]f32 = &loc; var p_res: [*]f32 = &res;
const buf_dsd = @get_dsd(mem1d_dsd, .{ .tensor_access = |i|{B} -> buf[i] });
const loc_dsd = @get_dsd(mem1d_dsd, .{ .tensor_access = |i|{B} -> loc[i] });
const res_dsd = @get_dsd(mem1d_dsd, .{ .tensor_access = |i|{B} -> res[i] });
const fin  = @get_dsd(fabin_dsd,  .{ .extent = B, .input_queue = iq });
const fout = @get_dsd(fabout_dsd, .{ .extent = B, .output_queue = oq });

fn run() void {
  if (is_first) {
    @fmovs(fout, buf_dsd, .{ .async = true, .activate = SEND_DONE });
  } else {
    @fmovs(buf_dsd, fin, .{ .async = true, .activate = RECV_DONE });
  }
}

// the compute step that depends on the received data
task recv_done() void {
  @fadds(res_dsd, buf_dsd, loc_dsd);
  sys_mod.unblock_cmd_stream();
}

task send_done() void { sys_mod.unblock_cmd_stream(); }

comptime {
  if (!is_first) { @initialize_queue(iq, .{ .color = @get_color(6) }); }
  if (is_first)  { @initialize_queue(oq, .{ .color = @get_color(6) }); }
  @bind_local_task(recv_done, RECV_DONE);
  @bind_local_task(send_done, SEND_DONE);
  @export_symbol(p_buf, "buf"); @export_symbol(p_loc, "loc"); @export_symbol(p_res, "res");
  @export_symbol(run);
}
"""
if __name__ == "__main__":
    here = Path(__file__).parent
    (here / "layout.csl").write_text(LAYOUT); (here / "pe.csl").write_text(PE); print("wrote layout.csl, pe.csl")
