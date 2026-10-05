#!/usr/bin/env python3
"""Build the group-C (repair) probe items: one injected defect per item in a small correct
toy program, compiled with the real SDK compiler to capture the actual error message. Each
item asks the model to fix the file given the stderr; scoring = compiles and <= 6 changed lines.

    XKERNEL_SDK_FLAVOR=2.10 ~/bin/micromamba run -n xkernel-agent python csl_probe/make_repair_items.py

Serial SDK job (12 compile-only runs plus the base program). Re-running overwrites the C items.
"""
from __future__ import annotations

import subprocess
import sys
import tempfile
from pathlib import Path

import yaml

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from workflow_common import build_sdk_env, default_sdk_root  # noqa: E402

LAYOUT = '''// FIXED layout (do not change): one PE; the host writes x and a, reads y.
param n: u16;

const memcpy = @import_module("<memcpy/get_params>", .{ .width = 1, .height = 1 });

layout {
  @set_rectangle(1, 1);
  const memcpy_params = memcpy.get_params(0);
  @set_tile_code(0, 0, "pe.csl", .{ .memcpy_params = memcpy_params, .n = n });
  @export_name("x", [*]f32, true);
  @export_name("a", [*]f32, true);
  @export_name("y", [*]f32, true);
  @export_name("compute", fn()void);
}
'''

BASE = '''// toy: y[i] = a[0] * x[i] + y[i], then one bulk scale of y by 2 through a DSD
param memcpy_params;
param n: u16;

const DONE: local_task_id = @get_local_task_id(13);
const memcpy_mod = @import_module("<memcpy/memcpy>", memcpy_params);

var x_array = @zeros([n]f32);
var a_array = @zeros([1]f32);
var y_array = @zeros([n]f32);
var ptr_x: [*]f32 = &x_array;
var ptr_a: [*]f32 = &a_array;
var ptr_y: [*]f32 = &y_array;

const y_dsd = @get_dsd(mem1d_dsd, .{ .tensor_access = |i|{n} -> y_array[i] });

fn compute() void {
  const a: f32 = a_array[0];
  var i: u16 = 0;
  while (i < n) : (i += 1) {
    y_array[i] = a * x_array[i] + y_array[i];
  }
  @fmuls(y_dsd, y_dsd, 2.0);
  @activate(DONE);
}

task f_done() void {
  memcpy_mod.unblock_cmd_stream();
}

comptime {
  @bind_local_task(f_done, DONE);
  @export_symbol(ptr_x, "x");
  @export_symbol(ptr_a, "a");
  @export_symbol(ptr_y, "y");
  @export_symbol(compute);
}
'''

# (id, description of the defect family, transformation of BASE)
# 16 Sep 2026: three first-draft defects compile on SDK 2.10 and were replaced (they are runtime or
# interface faults, not compile errors): @activate inside comptime, @range(i16, n) with a u16 bound,
# and a layout export without @export_symbol (fails only at run time with runner.get_id -> None).
DEFECTS = [
    ("C01_pointer_form", "pointer to array written as &arr[0] (a *T, not [*]T)", lambda s: s.replace("var ptr_y: [*]f32 = &y_array;", "var ptr_y: [*]f32 = &y_array[0];")),
    ("C02_export_mutability", "mutable export backed by a const pointer", lambda s: s.replace("var ptr_y: [*]f32 = &y_array;", "const ptr_y: [*]f32 = &y_array;")),
    ("C03_undeclared_identifier", "a misspelled array name in the loop body", lambda s: s.replace("    y_array[i] = a * x_array[i] + y_array[i];", "    y_array[i] = a * x_arr[i] + y_array[i];")),
    ("C04_missing_semicolon", "a statement without its terminating semicolon", lambda s: s.replace("  @fmuls(y_dsd, y_dsd, 2.0);", "  @fmuls(y_dsd, y_dsd, 2.0)")),
    ("C05_reserved_queue", "initialising input queue 0, which memcpy owns", lambda s: s.replace("  @bind_local_task(f_done, DONE);", "  @bind_local_task(f_done, DONE);\n  @initialize_queue(@get_input_queue(0), .{ .color = @get_color(8) });")),
    ("C06_task_id_band", "local task id outside the WSE-3 band", lambda s: s.replace("@get_local_task_id(13)", "@get_local_task_id(40)")),
    ("C07_misspelled_builtin", "misspelled DSD builtin", lambda s: s.replace("@fmuls(y_dsd, y_dsd, 2.0);", "@fmulz(y_dsd, y_dsd, 2.0);")),
    ("C08_dsd_arity", "wrong operand count in a DSD op", lambda s: s.replace("@fmuls(y_dsd, y_dsd, 2.0);", "@fmuls(y_dsd, 2.0);")),
    ("C09_bad_import", "import of a library module that does not exist", lambda s: s.replace('@import_module("<memcpy/memcpy>", memcpy_params)', '@import_module("<memcpy/memcpy_v2>", memcpy_params)')),
    ("C10_tensor_access_missing", "mem1d_dsd without a tensor_access", lambda s: s.replace("const y_dsd = @get_dsd(mem1d_dsd, .{ .tensor_access = |i|{n} -> y_array[i] });", "const y_dsd = @get_dsd(mem1d_dsd, .{ .extent = n, .base = y_array });")),
    ("C11_type_mismatch", "u16 loop counter written into an f32 array without a cast", lambda s: s.replace("    y_array[i] = a * x_array[i] + y_array[i];", "    y_array[i] = i;")),
    ("C12_comptime_struct_removed", "SDK 1.4 typed memcpy param on SDK 2.10", lambda s: s.replace("param memcpy_params;", "param memcpy_params: comptime_struct;")),
]

PROMPT = '''This Cerebras CSL file (SDK 2.10, WSE-3, one PE) does not compile. The layout is fixed and correct. Fix
`pe.csl` with the SMALLEST change that makes it compile and keeps its behaviour (y[i] = a*x[i] + y[i],
then y doubled). Reply with ONLY the complete corrected pe.csl in one ```csl fenced block.

Compiler output:
```
{stderr}
```

Fixed layout.csl:
```csl
{layout}
```

pe.csl:
```csl
{pe}
```'''


def compile_only(pe: str, sdk_root: str):
    work = Path(tempfile.mkdtemp(prefix="probe_c_", dir=str(HERE.parent / "sandbox")))
    (work / "layout.csl").write_text(LAYOUT); (work / "pe.csl").write_text(pe)
    cmd = "cslc ./layout.csl --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 --params=n:64 -o out --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0"
    r = subprocess.run(cmd, shell=True, cwd=str(work), env=build_sdk_env(sdk_root), capture_output=True, text=True, timeout=600)
    err = "\n".join(l for l in ((r.stderr or "") + "\n" + (r.stdout or "")).splitlines() if l.strip() and not l.startswith("\x1b[34m[INFO]"))
    return r.returncode == 0, err[-1500:]


def main() -> int:
    sdk = default_sdk_root()
    ok, err = compile_only(BASE, sdk)
    if not ok:
        print("BASE program does not compile; fix it first:\n" + err); return 1
    print("base program compiles")
    (HERE / "items").mkdir(exist_ok=True)
    made = 0
    for iid, family, xf in DEFECTS:
        pe = xf(BASE)
        assert pe != BASE, iid
        ok, err = compile_only(pe, sdk)
        if ok:
            print(f"{iid}: the defect STILL COMPILES on this SDK -- dropped"); continue
        item = {"id": iid, "group": "C_repair", "defect_family": family, "prompt": PROMPT.format(stderr=err, layout=LAYOUT.strip(), pe=pe.strip()),
                "fixed_layout": LAYOUT, "defective_pe": pe, "compiler_stderr": err, "compile_params": {"n": 64},
                "cslc_args": "--arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0",
                "expected": {"compiles": True, "max_changed_lines": 6}, "scoring": "compiles and at most 6 changed lines vs the defective file",
                "source_citation": "synthetic defect in a probe-only toy program; family from error_gotcha_retrieval / error_family"}
        (HERE / "items" / f"{iid}.yaml").write_text(yaml.safe_dump(item, sort_keys=False, width=110))
        print(f"{iid}: captured ({len(err)} chars): {err.splitlines()[0][:100] if err else ''}"); made += 1
    print(f"wrote {made} repair items")
    return 0


if __name__ == "__main__":
    sys.exit(main())
