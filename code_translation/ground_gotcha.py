"""Ground-truth checker for proposed CSL gotchas.

Given a (wrong_csl, right_csl, expected_cslc_error_substring) tuple, this
runs cslc against minimal compile harnesses and asserts:
  - the WRONG snippet causes cslc to emit an error containing the
    expected_error_substring (or, if "(none)" was claimed, that it
    compiles silently — useful for "this is silent bad behavior" gotchas)
  - the RIGHT snippet compiles clean
  - every cited tutorial path actually exists on disk

Used by the halo-gotchas workflow as a pre-verification grounding gate.
A draft that fails grounding never reaches the (expensive) refuter pass.

Design:
  - Minimal harness templates: 1x1 single-PE, 2x1 send-recv, 2x2 mesh.
    The drafter places the snippet inside `{SNIPPET}` in pe_program.csl;
    layout.csl + commands.sh are scaffolds we own.
  - cslc is invoked via the existing _singularity_gate (so concurrent
    grounding checks don't wedge the shim).
  - All temp dirs cleaned up unless XKERNEL_KEEP_GROUND_TEMPDIR=1.
"""

from __future__ import annotations

import logging
import os
import re
import shutil
import subprocess
import tempfile
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

from benchmark_csl import _singularity_gate  # type: ignore

logger = logging.getLogger(__name__)

CSL_EXAMPLES_ROOT = Path(os.environ.get(
    "CSL_EXAMPLES_ROOT", os.path.expanduser("~/csl-examples")))
CSL_SDK_ROOT = Path(os.environ.get(
    "CSL_SDK_ROOT", os.path.expanduser(default_sdk_root())))

# Per-compile timeout. cslc on a tiny single-PE bundle is ~10-20s warm,
# ~30-60s cold. 180s tolerates contention + container cold-start.
_CSLC_TIMEOUT_S = float(os.environ.get("XKERNEL_GROUND_TIMEOUT_S", "180"))


# ---- harness templates ---------------------------------------------------
#
# Each template defines (layout_csl, command_args, params). pe_program.csl
# is built by string-substitution of `{SNIPPET}` in pe_template_csl.
#
# Drafters target one of these harness keys based on the gotcha topic:
#  "single_pe"      — minimal 1x1, no fabric. For pure-language gotchas
#                     (DSDs, casts, exports, struct shapes).
#  "send_recv_2x1"  — 1x2 PEs, one sender + one receiver, two colors.
#                     For halo-receive / queue / async-fabric gotchas.
#  "mesh_2x2"       — 2x2 PEs with c2d_params imported. For collectives /
#                     diagonal-neighbor gotchas.

_HARNESS_SINGLE_PE = {
    "layout_csl": """\
param M: i16;
param N: i16;

const memcpy = @import_module("<memcpy/get_params>", .{ .width = 1, .height = 1 });

layout {
  @set_rectangle(1, 1);
  @set_tile_code(0, 0, "pe_program.csl", .{
    .memcpy_params = memcpy.get_params(0),
    .M = M,
    .N = N
  });
  @export_name("f_run", fn()void);
}
""",
    "pe_template_csl": """\
param memcpy_params: comptime_struct;
param M: i16;
param N: i16;

const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);

// ---- begin gotcha snippet ----
{SNIPPET}
// ---- end gotcha snippet ----

fn f_run() void {
  sys_mod.unblock_cmd_stream();
}

comptime {
  @export_symbol(f_run);
}
""",
    "compile_cmd": [
        "cslc", "--arch=wse3", "./layout.csl",
        "--fabric-dims=8,3", "--fabric-offsets=4,1",
        "--params=M:4,N:6",
        "-o", "out", "--memcpy", "--channels", "1",
    ],
}

_HARNESS_SEND_RECV_2x1 = {
    "layout_csl": """\
param M: i16 = 4;

const memcpy = @import_module("<memcpy/get_params>", .{ .width = 2, .height = 1 });
const C_SEND : color = @get_color(8);

layout {
  @set_rectangle(2, 1);

  // PE (0,0): sender
  @set_tile_code(0, 0, "pe_program.csl", .{
    .memcpy_params = memcpy.get_params(0),
    .is_sender = true,
    .M = M,
    .C_SEND = C_SEND,
  });
  @set_color_config(0, 0, C_SEND, .{
    .routes = .{ .rx = .{ RAMP }, .tx = .{ EAST } }
  });

  // PE (1,0): receiver
  @set_tile_code(1, 0, "pe_program.csl", .{
    .memcpy_params = memcpy.get_params(1),
    .is_sender = false,
    .M = M,
    .C_SEND = C_SEND,
  });
  @set_color_config(1, 0, C_SEND, .{
    .routes = .{ .rx = .{ WEST }, .tx = .{ RAMP } }
  });

  @export_name("f_run", fn()void);
}
""",
    "pe_template_csl": """\
param memcpy_params: comptime_struct;
param is_sender: bool;
param M: i16;
param C_SEND: color;

const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);

// ---- begin gotcha snippet ----
{SNIPPET}
// ---- end gotcha snippet ----

fn f_run() void {
  sys_mod.unblock_cmd_stream();
}

comptime {
  @export_symbol(f_run);
}
""",
    "compile_cmd": [
        "cslc", "--arch=wse3", "./layout.csl",
        "--fabric-dims=10,3", "--fabric-offsets=4,1",
        "-o", "out", "--memcpy", "--channels", "1",
    ],
}

_HARNESS_MESH_2x2 = {
    "layout_csl": """\
param matrix_dim: u16 = 4;

const memcpy = @import_module("<memcpy/get_params>", .{ .width = 2, .height = 2 });
const c2d = @import_module("<collectives_2d/params>");

layout {
  @set_rectangle(2, 2);
  var Px: u16 = 0;
  while (Px < 2) : (Px += 1) {
    var Py: u16 = 0;
    while (Py < 2) : (Py += 1) {
      const c2d_params = c2d.get_params(Px, Py, .{
        .x_colors      = .{ @get_color(0), @get_color(1) },
        .x_entrypoints = .{ @get_local_task_id(14), @get_local_task_id(15) },
        .y_colors      = .{ @get_color(4), @get_color(5) },
        .y_entrypoints = .{ @get_local_task_id(16), @get_local_task_id(17) },
      });
      @set_tile_code(Px, Py, "pe_program.csl", .{
        .memcpy_params = memcpy.get_params(Px),
        .c2d_params = c2d_params,
        .matrix_dim = matrix_dim,
      });
      Py += 0; // suppress unused-var lint when body has no body refs
    }
    Px += 0;
  }
  @export_name("f_run", fn()void);
}
""",
    "pe_template_csl": """\
param memcpy_params: comptime_struct;
param c2d_params: comptime_struct;
param matrix_dim: u16;

const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);

// ---- begin gotcha snippet ----
{SNIPPET}
// ---- end gotcha snippet ----

fn f_run() void {
  sys_mod.unblock_cmd_stream();
}

comptime {
  @export_symbol(f_run);
}
""",
    "compile_cmd": [
        "cslc", "--arch=wse3", "./layout.csl",
        "--fabric-dims=10,4", "--fabric-offsets=4,1",
        "-o", "out", "--memcpy", "--channels", "1",
    ],
}

HARNESSES: Dict[str, Dict[str, Any]] = {
    "single_pe": _HARNESS_SINGLE_PE,
    "send_recv_2x1": _HARNESS_SEND_RECV_2x1,
    "mesh_2x2": _HARNESS_MESH_2x2,
}


def _run_cslc(workdir: Path, compile_cmd: List[str]) -> Tuple[int, str]:
    """Invoke cslc with the SDK on PATH; return (returncode, stderr+stdout tail)."""
    env = os.environ.copy()
    env["PATH"] = f"{CSL_SDK_ROOT}:{env.get('PATH', '')}"
    try:
        with _singularity_gate():
            proc = subprocess.run(
                compile_cmd,
                cwd=str(workdir),
                env=env,
                capture_output=True,
                text=True,
                timeout=_CSLC_TIMEOUT_S,
                check=False,
            )
        # Combine stderr + stdout; cslc emits errors on stderr but warnings
        # and the "Compilation successful" line on stdout.
        merged = (proc.stderr or "") + "\n" + (proc.stdout or "")
        # Trim ANSI color escapes — they clutter the LLM's view.
        merged = re.sub(r"\x1b\[[0-9;]*m", "", merged)
        return proc.returncode, merged
    except subprocess.TimeoutExpired:
        return -9, f"(cslc timed out after {_CSLC_TIMEOUT_S}s)"


def ground_csl_snippet(snippet: str,
                       harness_key: str = "single_pe",
                       keep_tempdir: bool = False) -> Dict[str, Any]:
    """Compile a snippet inside a known harness; return {compiles, stderr_tail, exit}.

    `snippet` is dropped verbatim into `{SNIPPET}` of the harness's pe_program.csl.
    `harness_key` selects which scaffold (single_pe, send_recv_2x1, mesh_2x2).

    Returns:
      {
        "compiles": bool,
        "exit_code": int,
        "stderr_tail": str (last ~2000 chars of merged stderr+stdout),
        "harness_key": str,
        "tempdir_kept": Optional[str]  # set when XKERNEL_KEEP_GROUND_TEMPDIR=1
      }
    """
    if harness_key not in HARNESSES:
        return {
            "compiles": False, "exit_code": -1,
            "stderr_tail": f"unknown harness_key={harness_key!r}; "
                           f"valid: {sorted(HARNESSES)}",
            "harness_key": harness_key, "tempdir_kept": None,
        }
    h = HARNESSES[harness_key]
    keep = keep_tempdir or os.environ.get("XKERNEL_KEEP_GROUND_TEMPDIR") == "1"
    tmp = tempfile.mkdtemp(prefix=f"ground_{harness_key}_")
    try:
        wd = Path(tmp)
        (wd / "layout.csl").write_text(h["layout_csl"])
        pe_text = h["pe_template_csl"].replace("{SNIPPET}", snippet)
        (wd / "pe_program.csl").write_text(pe_text)
        rc, merged = _run_cslc(wd, h["compile_cmd"])
        # Tail to keep prompt budget bounded for downstream LLM use.
        tail = merged[-2000:] if len(merged) > 2000 else merged
        return {
            "compiles": rc == 0,
            "exit_code": rc,
            "stderr_tail": tail,
            "harness_key": harness_key,
            "tempdir_kept": tmp if keep else None,
        }
    finally:
        if not keep:
            shutil.rmtree(tmp, ignore_errors=True)


def resolve_citations(citation_paths: List[str]) -> Dict[str, bool]:
    """Return {path: exists_on_disk} for each cited tutorial path."""
    out: Dict[str, bool] = {}
    for p in citation_paths:
        # Citations are typically "csl-examples/tutorials/<topic>/<file>" or
        # just "csl-examples/tutorials/<topic>"; resolve against the root.
        rel = p
        for prefix in ("csl-examples/", "csl-examples/"):
            if rel.startswith(prefix):
                rel = rel[len(prefix):]
                break
        full = CSL_EXAMPLES_ROOT / rel
        # The full path must exist as either a file or a directory. We
        # cannot fall back to .parent.exists() — every path under
        # csl-examples/tutorials/* has tutorials/ as a parent, so that
        # check is trivially true and would whitewash fabricated paths.
        out[p] = full.exists()
    return out


def ground_gotcha(wrong_csl: str,
                  right_csl: str,
                  expected_error_substring: str,
                  citations: List[str],
                  harness_key: str = "single_pe") -> Dict[str, Any]:
    """Full grounding pass for one gotcha. Returns a verdict dict.

    Verdict shape:
      {
        "grounded": bool,                    # all gates passed
        "wrong": {compiles, exit_code, stderr_tail, harness_key},
        "right": {compiles, exit_code, stderr_tail, harness_key},
        "expected_error_substring": str,
        "wrong_matches_expected_error": bool,
        "right_compiles_clean": bool,
        "citations": {path: exists, ...},
        "all_citations_resolve": bool,
        "evidence": str (short summary for downstream consumers),
      }

    Gates:
      G1. WRONG must not compile clean. If expected_error_substring is a
          real substring, the stderr must contain it (case-insensitive).
          Special case: expected_error_substring == "(silent)" means
          WRONG should compile clean — used for "silent runtime drop"
          gotchas where cslc can't catch the issue.
      G2. RIGHT must compile clean.
      G3. Every citation path must resolve under CSL_EXAMPLES_ROOT.
    """
    wrong = ground_csl_snippet(wrong_csl, harness_key=harness_key)
    right = ground_csl_snippet(right_csl, harness_key=harness_key)
    citations_map = resolve_citations(citations)
    all_cites_ok = bool(citations) and all(citations_map.values())

    expected_lower = (expected_error_substring or "").strip().lower()
    if expected_lower == "(silent)":
        # Gotcha is about a silent failure; WRONG should compile clean.
        wrong_matches = wrong["compiles"]
    else:
        wrong_matches = (
            not wrong["compiles"]
            and expected_lower in wrong["stderr_tail"].lower()
        ) if expected_lower else (not wrong["compiles"])

    right_ok = right["compiles"]
    grounded = wrong_matches and right_ok and all_cites_ok

    evidence_lines = []
    evidence_lines.append(
        f"WRONG: compiles={wrong['compiles']} exit={wrong['exit_code']} "
        f"(expected_match={wrong_matches})"
    )
    evidence_lines.append(
        f"RIGHT: compiles={right['compiles']} exit={right['exit_code']} "
        f"(expected pass={right_ok})"
    )
    missing_cites = [p for p, ok in citations_map.items() if not ok]
    if missing_cites:
        evidence_lines.append(f"CITATIONS MISSING: {missing_cites}")
    else:
        evidence_lines.append(f"CITATIONS: all {len(citations_map)} resolve")

    return {
        "grounded": grounded,
        "wrong": wrong,
        "right": right,
        "expected_error_substring": expected_error_substring,
        "wrong_matches_expected_error": wrong_matches,
        "right_compiles_clean": right_ok,
        "citations": citations_map,
        "all_citations_resolve": all_cites_ok,
        "evidence": "\n".join(evidence_lines),
    }


# ---- CLI smoke test ------------------------------------------------------
if __name__ == "__main__":
    import json
    import sys

    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

    if len(sys.argv) > 1 and sys.argv[1] == "selftest":
        # Smoke test: verify the harness compiles clean with a trivial
        # snippet, and fails predictably on a known-bad snippet.
        print("=== selftest: empty snippet on single_pe ===")
        r = ground_csl_snippet("", "single_pe")
        print(f"  compiles={r['compiles']} exit={r['exit_code']}")
        if not r['compiles']:
            print("  STDERR TAIL:")
            print(r['stderr_tail'][-800:])
        assert r["compiles"], "empty snippet should compile"
        print("OK")

        print("=== selftest: syntactically bad snippet on single_pe ===")
        r = ground_csl_snippet("@this_builtin_does_not_exist();", "single_pe")
        print(f"  compiles={r['compiles']} exit={r['exit_code']}")
        assert not r["compiles"], "bogus builtin should fail to compile"
        print("OK")

        print("=== selftest: citation resolution ===")
        r = resolve_citations([
            "csl-examples/tutorials/topic-11-collectives",
            "csl-examples/tutorials/topic-99-nonexistent",
        ])
        print(json.dumps(r, indent=2))
        assert r["csl-examples/tutorials/topic-11-collectives"] is True
        assert r["csl-examples/tutorials/topic-99-nonexistent"] is False
        print("OK")

        print("\nAll selftests passed.")
        sys.exit(0)

    print("Usage: python ground_gotcha.py selftest")
