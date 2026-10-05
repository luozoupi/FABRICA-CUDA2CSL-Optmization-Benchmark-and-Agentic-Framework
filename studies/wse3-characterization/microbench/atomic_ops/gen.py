#!/usr/bin/env python3
"""Atomic ISA suite: MIPS-style basic operations, each executed exactly once.

Every form is preceded by a marker store into an EXPORTED array (so the store
survives dead-store elimination) whose immediate 0x5A00+i is recognisable in the
disassembly; the trace is then cut by marker PC.  No reps, no TSC: the cycle
truth comes from the dispatch and pipe traces.
"""
import json
from pathlib import Path

FORMS = [
 ("arith",  "sub_i16",    "ci[0] = ai[0] - bi[0];"),
 ("arith",  "mul_i16",    "ci[1] = ai[0] * bi[0];"),
 ("arith",  "mul_f16",    "cf[0] = af[0] * bf[0];"),
 ("arith",  "fma_f16",    "cf[1] = af[0] * bf[0] + af[1];"),
 ("logic",  "and_i16",    "ci[2] = ai[0] & bi[0];"),
 ("logic",  "or_i16",     "ci[3] = ai[0] | bi[0];"),
 ("logic",  "xor_i16",    "ci[4] = ai[0] ^ bi[0];"),
 ("logic",  "shl_i16",    "ci[5] = ai[0] << 3;"),
 ("logic",  "shr_i16",    "ci[6] = ai[0] >> 2;"),
 ("control","br_taken",   "if (ai[2] < bi[2]) { ci[7] = 11; } else { ci[7] = 22; }"),
 ("control","br_not",     "if (ai[3] < bi[3]) { ci[8] = 11; } else { ci[8] = 22; }"),
 ("control","loop2",      "var k: u16 = 0;\n  while (k < @as(u16, bi[1])) : (k += 1) { ci[9] = ci[9] + ai[k]; }"),
 ("convert","f16_to_f32", "c32[0] = @as(f32, af[0]);"),
 ("convert","f32_to_f16", "cf[2] = @as(f16, a32[0]);"),
 ("memory", "dsd_fill8",  "@fmovh(c8, @as(f16, 1.5));"),
 ("memory", "dsd_copy8",  "@fmovh(c8b, a8);"),
 ("memory", "dsd_stride2","@fmovh(c8c, a8s2);"),
 ("memory", "dsd_reduce8","@faddh(&acc, acc, a8);\n  cf[3] = acc;"),
 ("vector", "dsd_mulh8",  "@fmulh(c8d, a8, b8);"),
 ("vector", "dsd_fmach8", "@fmach(c8e, a8, b8, @as(f16, 0.5));"),
 ("vector", "dsd_add16x8","@add16(ic8, ia8, ib8);"),
 ("vector", "dsd_fadds8", "@fadds(c32d, a32d, b32d);"),
]

LAYOUT = """const memcpy = @import_module("<memcpy/get_params>", .{ .width = 1, .height = 1 });
layout {
  @set_rectangle(1, 1);
  @set_tile_code(0, 0, "pe.csl", .{ .memcpy_params = memcpy.get_params(0) });
  @export_name("ai", [*]i16, true);  @export_name("bi", [*]i16, true);  @export_name("ci", [*]i16, true);
  @export_name("af", [*]f16, true);  @export_name("bf", [*]f16, true);  @export_name("cf", [*]f16, true);
  @export_name("a", [*]f16, true);   @export_name("b", [*]f16, true);   @export_name("c", [*]f16, true);
  @export_name("a32", [*]f32, true); @export_name("b32", [*]f32, true); @export_name("c32", [*]f32, true);
  @export_name("ia8", [*]i16, true); @export_name("ib8", [*]i16, true); @export_name("ic8", [*]i16, true);
  @export_name("mark", [*]i16, true);
  @export_name("compute", fn()void);
}
"""

def main():
    body = ""
    for i, (_cls, name, csl) in enumerate(FORMS):
        body += f"\n  mark[{i}] = 0x5A{i:02X};   // {name}\n  {csl}\n"
    pe = f"""param memcpy_params;
const EXIT: local_task_id = @get_local_task_id(9);
const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);

var ai = @zeros([4]i16); var bi = @zeros([4]i16); var ci = @zeros([16]i16);
var af = @zeros([4]f16); var bf = @zeros([4]f16); var cf = @zeros([16]f16);
var a = @zeros([16]f16); var b = @zeros([16]f16); var c = @zeros([64]f16);
var a32 = @zeros([8]f32); var b32 = @zeros([8]f32); var c32 = @zeros([16]f32);
var ia8 = @zeros([8]i16); var ib8 = @zeros([8]i16); var ic8 = @zeros([8]i16);
var mark = @zeros([32]i16);
var acc: f16 = 0.0;
var ptr_ai: [*]i16 = &ai; var ptr_bi: [*]i16 = &bi; var ptr_ci: [*]i16 = &ci;
var ptr_af: [*]f16 = &af; var ptr_bf: [*]f16 = &bf; var ptr_cf: [*]f16 = &cf;
var ptr_a: [*]f16 = &a;   var ptr_b: [*]f16 = &b;   var ptr_c: [*]f16 = &c;
var ptr_a32: [*]f32 = &a32; var ptr_b32: [*]f32 = &b32; var ptr_c32: [*]f32 = &c32;
var ptr_ia8: [*]i16 = &ia8; var ptr_ib8: [*]i16 = &ib8; var ptr_ic8: [*]i16 = &ic8;
var ptr_mark: [*]i16 = &mark;

const a8   = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{8}} -> a[i] }});
const b8   = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{8}} -> b[i] }});
const a8s2 = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{8}} -> a[2 * i] }});
const c8   = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{8}} -> c[i] }});
const c8b  = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{8}} -> c[i + 8] }});
const c8c  = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{8}} -> c[i + 16] }});
const c8d  = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{8}} -> c[i + 24] }});
const c8e  = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{8}} -> c[i + 32] }});
const ia8d = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{8}} -> ia8[i] }});
const ib8d = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{8}} -> ib8[i] }});
const ic8d = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{8}} -> ic8[i] }});
const a32d = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{8}} -> a32[i] }});
const b32d = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{8}} -> b32[i] }});
const c32d = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{8}} -> c32[i + 8] }});

fn compute() void {{{body}
  mark[{len(FORMS)}] = 0x5A{len(FORMS):02X};
  @activate(EXIT);
}}

task f_exit() void {{ sys_mod.unblock_cmd_stream(); }}

comptime {{
  @bind_local_task(f_exit, EXIT);
  @export_symbol(ptr_ai, "ai"); @export_symbol(ptr_bi, "bi"); @export_symbol(ptr_ci, "ci");
  @export_symbol(ptr_af, "af"); @export_symbol(ptr_bf, "bf"); @export_symbol(ptr_cf, "cf");
  @export_symbol(ptr_a, "a");   @export_symbol(ptr_b, "b");   @export_symbol(ptr_c, "c");
  @export_symbol(ptr_a32, "a32"); @export_symbol(ptr_b32, "b32"); @export_symbol(ptr_c32, "c32");
  @export_symbol(ptr_ia8, "ia8"); @export_symbol(ptr_ib8, "ib8"); @export_symbol(ptr_ic8, "ic8");
  @export_symbol(ptr_mark, "mark");
  @export_symbol(compute);
}}
"""
    pe = pe.replace("@add16(ic8, ia8, ib8);", "@add16(ic8d, ia8d, ib8d);")
    here = Path(__file__).parent
    (here / "pe.csl").write_text(pe); (here / "layout.csl").write_text(LAYOUT)
    (here / "meta.json").write_text(json.dumps([{"cls": c, "name": n, "csl": s} for c, n, s in FORMS], indent=1))
    print(f"wrote pe.csl with {len(FORMS)} forms")

if __name__ == "__main__":
    main()
