#!/usr/bin/env python3
"""Producer-consumer bubble sweeps: one CSL program per dependency class.

Each program's compute() holds NP marker-bracketed pairs of the same producer and consumer.
The programs are compiled once, then rebuilt from their captured IR with function-local
`optnone` (so source order survives) and with K[i] inline `nop` instructions inserted between
the producer and the consumer of pair i.  The dispatch spacing that remains after the fillers
are accounted for is the delay attributable to the dependency, and the far-spaced pair is the
control.  A dependency class whose delay does not shrink as K grows is not a stall at all.

Classes and their producer -> consumer:
  dsr_*     lds*wds (the DSR loaded LAST, chosen per class) -> add16 [dds]=[s0ds],[s1ds]
  gpr       ld16 (second operand)                            -> add16
  f16dep    fmulh                                            -> faddh   (one operand load sits between)
  i16dep    add16                                            -> add16
  cflag_jmp lt16.and cflag0                                  -> cflag0 ? jmp
  mem       st16 [c[i]]                                      -> ld16 [c[i]]
  reduce    faddh r = r,[s1ds]  (8-element reduction)        -> st16 of its result
"""
import json
from pathlib import Path

K = [0, 1, 2, 3, 4, 6, 12, 24]          # fillers per pair; 24 is the far control
NP = len(K)

LAYOUT = """const memcpy = @import_module("<memcpy/get_params>", .{ .width = 1, .height = 1 });
layout {
  @set_rectangle(1, 1);
  @set_tile_code(0, 0, "pe.csl", .{ .memcpy_params = memcpy.get_params(0) });
  @export_name("a", [*]i16, true);  @export_name("b", [*]i16, true);  @export_name("g", [*]i16, true);
  @export_name("c", [*]i16, true);  @export_name("d", [*]i16, true);
  @export_name("af", [*]f16, true); @export_name("bf", [*]f16, true); @export_name("gf", [*]f16, true);
  @export_name("cf", [*]f16, true); @export_name("mark", [*]i16, true);
  @export_name("compute", fn()void);
}
"""

def pe(body, extra_decls="", n_pairs=NP):
    return f"""param memcpy_params;
const EXIT: local_task_id = @get_local_task_id(9);
const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);

var a = @zeros([8]i16); var b = @zeros([8]i16); var g = @zeros([8]i16);
var c = @zeros([80]i16); var d = @zeros([8]i16);
var af = @zeros([8]f16); var bf = @zeros([8]f16); var gf = @zeros([8]f16); var cf = @zeros([16]f16);
var mark = @zeros([16]i16);
var p_a: [*]i16 = &a; var p_b: [*]i16 = &b; var p_g: [*]i16 = &g; var p_c: [*]i16 = &c; var p_d: [*]i16 = &d;
var p_af: [*]f16 = &af; var p_bf: [*]f16 = &bf; var p_gf: [*]f16 = &gf; var p_cf: [*]f16 = &cf; var p_mark: [*]i16 = &mark;

const ad  = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{8}} -> a[i] }});
const bd  = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{8}} -> b[i] }});
const afd = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{8}} -> af[i] }});
{extra_decls}
fn compute() void {{
{body}
  mark[{n_pairs}] = 0x{0x6000 + n_pairs:04X};
  @activate(EXIT);
}}

task f_exit() void {{ sys_mod.unblock_cmd_stream(); }}

comptime {{
  @bind_local_task(f_exit, EXIT);
  @export_symbol(p_a, "a"); @export_symbol(p_b, "b"); @export_symbol(p_g, "g"); @export_symbol(p_c, "c"); @export_symbol(p_d, "d");
  @export_symbol(p_af, "af"); @export_symbol(p_bf, "bf"); @export_symbol(p_gf, "gf"); @export_symbol(p_cf, "cf"); @export_symbol(p_mark, "mark");
  @export_symbol(compute);
}}
"""

def mk(i): return f"  mark[{i}] = 0x{0x6000 + i:04X};\n"

CLASSES = {}
# --- DSR load-use: three descriptor loads then the op; NP pairs + one 'prepared' pair (loads stripped in IR)
decl = "".join(f"const cd{i} = @get_dsd(mem1d_dsd, .{{ .tensor_access = |j|{{8}} -> c[j + {8*i}] }});\n" for i in range(NP + 1))
body = "".join(mk(i) + f"  @add16(cd{i}, ad, bd);\n" for i in range(NP)) + mk(NP) + f"  @add16(cd{NP - 1}, ad, bd);\n"
for last in ("s1", "d", "s0"):
    CLASSES[f"dsr_{last}last"] = dict(body=body, decls=decl, producer="dsr", dsr_last=last,
        pairs=NP + 1, k=K + [0], prepared_pair=NP, expect="dsr")
CLASSES["gpr"]      = dict(body="".join(mk(i) + f"  c[{i}] = a[{i}] + b[{i}];\n" for i in range(NP)), decls="", producer="gpr", pairs=NP, k=K, expect="gpr")
CLASSES["f16dep"]   = dict(body="".join(mk(i) + f"  cf[{i}] = af[{i}] * bf[{i}] + gf[{i}];\n" for i in range(NP)), decls="", producer="f16dep", pairs=NP, k=K, expect="f16dep")
CLASSES["i16dep"]   = dict(body="".join(mk(i) + f"  c[{i}] = (a[{i}] + b[{i}]) + g[{i}];\n" for i in range(NP)), decls="", producer="i16dep", pairs=NP, k=K, expect="i16dep")
CLASSES["cflag_jmp"]= dict(body="".join(mk(i) + f"  if (a[{i}] < b[{i}]) {{ c[{i}] = 11; }} else {{ c[{i}] = 22; }}\n" for i in range(NP)), decls="", producer="cflag", pairs=NP, k=K, expect="cflag")
CLASSES["mem"]      = dict(body="".join(mk(i) + f"  c[{i}] = a[{i}] + b[{i}];\n  d[{i}] = c[{i}] + g[{i}];\n" for i in range(NP)), decls="", producer="mem", pairs=NP, k=K, expect="mem")
decl_r = "".join(f"var acc{i}: f16 = 0.0;\n" for i in range(NP))
# back-to-back dependent chains at distance 1 cannot be written in CSL under optnone (a load always
# lands between the two ops), so these two pairs are inline assembly inserted at the IR level:
#   movri r5, movri r8, <op> r5 = r5, r8, nop*k, <op> r5 = r5, r8      (timing only; nothing is stored)
CLASSES["f16chain_asm"] = dict(body="".join(mk(i) for i in range(NP)), decls="", producer="asm_f16", pairs=NP, k=K, expect="none")
CLASSES["i16chain_asm"] = dict(body="".join(mk(i) for i in range(NP)), decls="", producer="asm_i16", pairs=NP, k=K, expect="none")
CLASSES["reduce"]   = dict(body="".join(mk(i) + f"  @faddh(&acc{i}, acc{i}, afd);\n  cf[{i}] = acc{i};\n" for i in range(NP)), decls=decl_r, producer="reduce", pairs=NP, k=K, expect="reduce")

def main():
    here = Path(__file__).parent
    for name, c in CLASSES.items():
        d = here / "cases" / name; d.mkdir(parents=True, exist_ok=True)
        (d / "layout.csl").write_text(LAYOUT); (d / "pe.csl").write_text(pe(c["body"], c["decls"], c["pairs"]))
        (d / "meta.json").write_text(json.dumps({k: v for k, v in c.items() if k not in ("body", "decls")}, indent=1))
    print(f"wrote {len(CLASSES)} class programs, {NP} pairs each (K={K}); dsr classes carry an extra prepared-DSR pair")

if __name__ == "__main__":
    main()
