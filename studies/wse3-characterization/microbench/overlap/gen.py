#!/usr/bin/env python3
"""Overlap microbench: does independent scalar work execute concurrently with a DSD hardware loop?

Three separately-callable functions on one PE, so region boundaries need no markers:

  region_a()   a long i16 DSD add alone                     -> icA
  region_b()   an independent scalar dependency chain alone  -> outsc[0]
  region_c()   the same DSD plus the same scalar chain, with no dependency between them

The scalar chain is a REGISTER-ONLY squaring recurrence, acc = acc*acc + k, seeded from
memory once.  Two properties matter:
  * it cannot be algebraically collapsed (a first attempt using acc = (acc<<1) + ia[k]
    was folded away by the compiler, which proved that shifting an i16 left 16 times
    zeroes the earlier terms -- 256 steps became 16);
  * it touches no memory, so it contends with the DSD only for the execute pipeline,
    not for the memory port.  A dependent-load chain would confound the two.

Each region's instructions are attributed by the CSL source text the disassembler
reports, so any scheduling or interleaving is still classified correctly.
"""
import json
from pathlib import Path

L = 2048        # DSD length (i16 elements)
S = 256         # scalar chain steps

LAYOUT = """const memcpy = @import_module("<memcpy/get_params>", .{ .width = 1, .height = 1 });
layout {
  @set_rectangle(1, 1);
  @set_tile_code(0, 0, "pe.csl", .{ .memcpy_params = memcpy.get_params(0) });
  @export_name("iaL", [*]i16, true); @export_name("ibL", [*]i16, true);
  @export_name("icA", [*]i16, true); @export_name("icC", [*]i16, true);
  @export_name("ia", [*]i16, true);  @export_name("ib", [*]i16, true);
  @export_name("outsc", [*]i16, true);
  @export_name("region_a", fn()void);
  @export_name("region_b", fn()void);
  @export_name("region_c", fn()void);
}
"""

def chain(var, k, n):
    return "\n".join(f"  {var} = {var} * {var} + {k};" for _ in range(n))

def main():
    pe = f"""param memcpy_params;
const EXIT: local_task_id = @get_local_task_id(9);
const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);

var iaL = @zeros([{L}]i16); var ibL = @zeros([{L}]i16);
var icA = @zeros([{L}]i16); var icC = @zeros([{L}]i16);
var ia  = @zeros([64]i16);  var ib = @zeros([64]i16);
var outsc = @zeros([4]i16);

var p_iaL: [*]i16 = &iaL; var p_ibL: [*]i16 = &ibL; var p_icA: [*]i16 = &icA; var p_icC: [*]i16 = &icC;
var p_ia: [*]i16 = &ia; var p_ib: [*]i16 = &ib; var p_outsc: [*]i16 = &outsc;

const iaLd = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{L}}} -> iaL[i] }});
const ibLd = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{L}}} -> ibL[i] }});
const icAd = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{L}}} -> icA[i] }});
const icCd = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{L}}} -> icC[i] }});

// region A: one long DSD hardware loop, nothing else
fn region_a() void {{
  @add16(icAd, iaLd, ibLd);
  @activate(EXIT);
}}

// region B: one independent scalar dependency chain, nothing else
fn region_b() void {{
  var accB: i16 = ia[0];
  var kB: i16 = ia[1];
{chain("accB", "kB", S)}
  outsc[0] = accB;
  @activate(EXIT);
}}

// region C: the same DSD and the same chain, mutually independent
fn region_c() void {{
  @add16(icCd, iaLd, ibLd);
  var accC: i16 = ib[0];
  var kC: i16 = ib[1];
{chain("accC", "kC", S)}
  outsc[1] = accC;
  @activate(EXIT);
}}

task f_exit() void {{ sys_mod.unblock_cmd_stream(); }}

comptime {{
  @bind_local_task(f_exit, EXIT);
  @export_symbol(p_iaL, "iaL"); @export_symbol(p_ibL, "ibL");
  @export_symbol(p_icA, "icA"); @export_symbol(p_icC, "icC");
  @export_symbol(p_ia, "ia"); @export_symbol(p_ib, "ib");
  @export_symbol(p_outsc, "outsc");
  @export_symbol(region_a); @export_symbol(region_b); @export_symbol(region_c);
}}
"""
    here = Path(__file__).parent
    (here / "pe.csl").write_text(pe); (here / "layout.csl").write_text(LAYOUT)
    # how the probe attributes each instruction to a region, by disassembler source text
    (here / "meta.json").write_text(json.dumps({
        "L": L, "S": S,
        "attribution": {
            "A_dsd":    ["icAd"],
            "C_dsd":    ["icCd"],
            "B_scalar": ["accB", "kB"],
            "C_scalar": ["accC", "kC"],
        }}, indent=1))
    print(f"wrote pe.csl (L={L} DSD elements, S={S} register-only chain steps)")

if __name__ == "__main__":
    main()
