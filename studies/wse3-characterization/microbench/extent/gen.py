#!/usr/bin/env python3
"""Generate the DSD extent probe: how many elements does ONE dispatch cover?

The DSD is the hardware loop.  From the MeshGEMM trace a single `IMOV32.NF`
dispatch covered 4,096 elements and `FMOV16.NF` reached 256, but every one of
114,688 `FMACH` dispatches covered exactly 16 -- which is WaferLLM's tile size,
not a demonstrated hardware ceiling.  Nothing in this study has ever asked an FMA
for more than 16 elements, so the limit is simply unknown.

METHOD.  Three f16 arrays are allocated once at the maximum length; each variant
issues a single builtin over a DSD of length L.  Memory is therefore constant and
only the requested extent changes.  The answer comes from the trace's `num_data`
field, not from timing: if one dispatch reports num_data == L the hardware looped
L times, and if the compiler splits the work into several dispatches that shows up
as several records at the same PC.
"""

import argparse
from pathlib import Path

# Past 4096 the three operands share one array: the arithmetic result is
# meaningless but `num_data` is what is being measured, and a single 22,000-element
# f16 array is the largest working set one PE can hold (see microbench/capacity).
LENGTHS = [4096, 8192, 16384, 20480, 21000, 21500, 22000]
MAXLEN = max(LENGTHS)
# (label, builtin, arity) -- arity 3 takes a trailing scalar operand.
OPS = [("fmach", "@fmach", 3), ("fmovh", "@fmovh", 1), ("fmulh", "@fmulh", 2)]


def variants():
    return [(op, builtin, arity, L) for op, builtin, arity in OPS for L in LENGTHS]


def bench(idx, op, builtin, arity, L):
    dsds = f"""  const d0 = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{L}}} -> A[i] }});
  const d1 = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{L}}} -> A[i] }});
  const d2 = @get_dsd(mem1d_dsd, .{{ .tensor_access = |i|{{{L}}} -> A[i] }});"""
    if arity == 3:
        call = f"{builtin}(d2, d0, d1, @as(f16, 1.0009765625));"
    elif arity == 2:
        call = f"{builtin}(d2, d0, d1);"
    else:
        call = f"{builtin}(d2, @as(f16, 1.5));"
    return f"""
fn bench_{idx}() void {{
{dsds}
  {call}
}}
"""


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=str(Path(__file__).parent))
    a = ap.parse_args()
    out = Path(a.out)
    V = variants()

    (out / "layout.csl").write_text("""// DSD extent probe: one PE, one builtin per variant, sweeping DSD length.
const memcpy = @import_module("<memcpy/get_params>", .{ .width = 1, .height = 1 });
layout {
  @set_rectangle(1, 1);
  @set_tile_code(0, 0, "pe.csl", .{ .memcpy_params = memcpy.get_params(0) });
  @export_name("C", [*]f16, true);
  @export_name("compute", fn()void);
}
""")

    benches = "".join(bench(i, *v) for i, v in enumerate(V))
    calls = "\n".join(f"  bench_{i}();" for i in range(len(V)))
    (out / "pe.csl").write_text(f"""// DSD extent probe.  Arrays are fixed at the maximum length so that only the
// requested DSD extent varies between variants.
param memcpy_params;

const EXIT: local_task_id = @get_local_task_id(9);
const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);

var A = @zeros([{MAXLEN}]f16);
var ptr_C: [*]f16 = &A;
{benches}
fn compute() void {{
{calls}
  @activate(EXIT);
}}

task f_exit() void {{ sys_mod.unblock_cmd_stream(); }}

comptime {{
  @bind_local_task(f_exit, EXIT);
  @export_symbol(ptr_C, "C");
  @export_symbol(compute);
}}
""")
    (out / "variants.json").write_text(__import__("json").dumps(
        [{"index": i, "op": v[0], "length": v[3]} for i, v in enumerate(V)], indent=1))
    print(f"wrote {out}/layout.csl, pe.csl, variants.json "
          f"({len(V)} variants: {len(OPS)} ops x {len(LENGTHS)} lengths)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
