#!/usr/bin/env python3
"""Optimization-exploration workflow.

Independent of and parallel to explore_csl.py. Where explore_csl asks "can
the LLM write a correct CSL kernel for this idea", optimize_explore asks
"can the LLM make THIS passing kernel measurably faster, and what general
lesson can we distill from the attempt".

Per round, for one target kernel:
  1. Measure the baseline cycles_send (median of N runs).
  2. Run the static bottleneck profiler on its pe.csl.
  3. Pick ONE optimization angle (LLM via q_optimize_select_angle, biased
     toward angles whose applicable_bottlenecks intersect the detected set).
  4. Ask the implementer to rewrite pe.csl applying ONLY that angle
     (q_optimize_csl_compute).
  5. Stage + benchmark. Reject if:
        - compile / run fails
        - contract_check rejects (frozen f_tic/f_toc bodies, etc.)
        - candidate cycles >= baseline * (1 - epsilon)
  6. On accept: ask the LLM in ONE short turn to summarise the diff.
     Persist {angle, kernel_group, baseline, candidate, speedup, diff_summary}.

Output lands at ~/xkernel/knowledge/explored/optimization/ (separate tree
from the kernel-generation exploration corpus).

This is the dedicated driver — the existing cuda2csl.py --optimize path is
left untouched.
"""

from __future__ import annotations

import argparse
import json
import logging
import os
import re
import sys
import tempfile
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

THIS_DIR = Path(__file__).resolve().parent
if str(THIS_DIR) not in sys.path:
    sys.path.insert(0, str(THIS_DIR))

from benchmark_csl import benchmark_translated_compute_file  # type: ignore
from contract_check import (  # type: ignore
    spec_frozen_lists,
    validate_against_reference,
)
import csl_knowledge_base  # type: ignore
from knowledge_persistence import (  # type: ignore
    DEFAULT_EXPLORED_ROOT,
    ExplorationStore,
)
import optimization_tree  # type: ignore
import bench_structure  # type: ignore
import optimization_planner  # type: ignore


def _bundle_dir_from_store_row(store_row: Dict[str, Any]) -> str:
    """Extract just the bundle dir name (no path prefix) from the store
    row's artifacts_dir. record_optimization writes
    'optimization/accepted/<slug>__<ts>' or 'optimization/failures/...';
    the tree wants only the dir basename for its `bundle` field."""
    rel = store_row.get("artifacts_dir") or ""
    return os.path.basename(rel.rstrip("/")) if rel else ""
import numeric_check  # type: ignore
from debugger_agent import (  # type: ignore
    DebuggerAgent, DebuggerInput, DebuggerReport, read_layout_csl,
)
from prompt_cuda2csl import (  # type: ignore
    CSL_OPTIMIZATION_STEPS_CATALOG,
    CYCLES_SEND_RECIPE,
    DEFAULT_CSL_OPT_STEPS,
    Instruction_system_csl_optimization,
    angle_metadata,
    angles_for_group,
    builtin_whitelist_block,
    csl_optimize_repair,
    q_optimize_csl_compute,
    q_optimize_csl_compute_multifile,
    q_optimize_open_compute,
    q_optimize_select_angle,
)
from workflow_common import (  # type: ignore
    DEFAULT_API_KEY_FILE,
    ProviderHandle,
    ensure_directory,
    expand_path,
    extract_code_block,
    extract_multi_file_blocks,
    format_command_transcript,
    llm_complete,
    load_shell_setup,
    resolve_provider,
)
from workflow_common import default_sdk_root, sdk_sif_path  # noqa: E402


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(filename)s:%(lineno)d - %(levelname)s - %(message)s",
)
logger = logging.getLogger("optimize_explore")


REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SDK_ROOT = default_sdk_root()


# ---------------------------------------------------------------------------
# Static bottleneck profiler (lifted from cuda2csl._profile_bottleneck_signature)
# ---------------------------------------------------------------------------
#
# Re-implemented here as a free function so optimize_explore doesn't depend
# on instantiating the heavy CUDA2CSLOrchestrator. The patterns + key
# names MUST stay aligned with the CSL_OPTIMIZATION_STEPS_CATALOG entries'
# applicable_bottlenecks lists, otherwise the angle selector won't match.

def profile_bottlenecks(csl_code: str) -> Dict[str, int]:
    """Scan a CSL compute file for structural patterns indicating known
    bottlenecks. Returns ``{bottleneck_name: hits}``.

    Patterns kept conservative — false negatives (missing a bottleneck) are
    safer than false positives (steering the LLM into the wrong angle).
    """
    sig: Dict[str, int] = {}

    def bump(key: str, n: int = 1) -> None:
        sig[key] = sig.get(key, 0) + n

    nocomment = re.sub(r"//[^\n]*", "", csl_code or "")

    # for-block extractor (CSL: `for (@range(i16, N)) |i| { ... }`).
    for_blocks: List[str] = []
    i = 0
    while i < len(nocomment):
        m = re.search(r"\bfor\s*\(", nocomment[i:])
        if not m:
            break
        head_start = i + m.end() - 1
        depth = 1
        k = head_start + 1
        while k < len(nocomment) and depth > 0:
            c = nocomment[k]
            if c == "(":
                depth += 1
            elif c == ")":
                depth -= 1
            k += 1
        head_end = k
        tail_m = re.match(r"\s*\|[^|]*\|\s*\{", nocomment[head_end:])
        if not tail_m:
            i = head_end
            continue
        body_start = head_end + tail_m.end()
        depth = 1
        j = body_start
        while j < len(nocomment) and depth > 0:
            if nocomment[j] == "{":
                depth += 1
            elif nocomment[j] == "}":
                depth -= 1
            j += 1
        for_blocks.append(nocomment[body_start:j])
        i = j
    loop_text = "\n".join(for_blocks)

    # dsd_rebuild_in_loop
    n = len(re.findall(r"@get_dsd\s*\(", loop_text))
    if n > 0:
        bump("dsd_rebuild_in_loop", n)

    # runtime_size_in_inner_loop
    n = len(re.findall(
        r"@as\s*\(\s*[iuf]16\s*,\s*[A-Z_][A-Z0-9_]*\s*\)", loop_text))
    if n > 0:
        bump("runtime_size_in_inner_loop", n)
        bump("redundant_at_cast", n)

    # scalar_loops_over_arrays
    for body in for_blocks:
        has_scalar_write = bool(re.search(
            r"\b[A-Za-z_][A-Za-z0-9_]*\s*\[[^\]]+\]\s*=", body))
        has_bulk_op = bool(re.search(
            r"@fmac[sh]|@fadd[sh]|@fmov[sh]|@map\b", body))
        if has_scalar_write and not has_bulk_op:
            bump("scalar_loops_over_arrays")

    # separate_mul_then_add
    n = len(re.findall(
        r"@fmul[sh]\s*\([^)]*\)\s*;\s*@fadd[sh]\s*\(",
        nocomment, re.DOTALL))
    if n > 0:
        bump("separate_mul_then_add", n)

    # polling_async
    n = len(re.findall(r"\bwhile\s*\(\s*!\s*[A-Za-z_]", nocomment))
    n += len(re.findall(
        r"\bwhile\s*\(\s*[A-Za-z_][A-Za-z0-9_]*\s*==\s*(?:false|0)\b",
        nocomment))
    if n > 0:
        bump("polling_async", n)

    # sync_fabric_ops
    fab_dsds = set(re.findall(
        r"\b([A-Za-z_][A-Za-z0-9_]*)\s*=\s*@get_dsd\s*\(\s*fab(?:in|out)_dsd",
        nocomment))
    sync_fab = 0
    for dsd in fab_dsds:
        for m in re.finditer(
            rf"@(?:mov\w+|fmac\w+|fadd\w+|fmov\w+)"
            rf"\s*\([^)]*\b{re.escape(dsd)}\b[^)]*\)", nocomment,
        ):
            if ".async" not in m.group(0):
                sync_fab += 1
    if sync_fab > 0:
        bump("sync_fabric_ops", sync_fab)
        bump("serialized_compute_and_comm", sync_fab)

    # large_runtime_table heuristic
    n = len(re.findall(
        r"\bvar\s+[A-Za-z_][A-Za-z0-9_]*\s*=\s*[A-Za-z_][A-Za-z0-9_]*\s*\(",
        nocomment))
    if n >= 3:
        bump("large_runtime_table", n)

    # var_used_where_param_works
    n = len(re.findall(r"^\s*var\s+([A-Z_][A-Z0-9_]{2,})\s*:",
                       nocomment, re.MULTILINE))
    if n > 0:
        bump("var_used_where_param_works", n)

    # unexplored_comptime_config
    n = len(re.findall(
        r'@import_module\s*\(\s*"[^"]+"\s*,\s*@?(?:concat_structs|\{|\.\{)',
        nocomment))
    if n > 0:
        bump("unexplored_comptime_config", n)
    return sig


# ---------------------------------------------------------------------------
# Target resolution
# ---------------------------------------------------------------------------

@dataclass
class OptimizationTarget:
    """The bundle we're trying to optimize."""
    bundle_dir: Path              # contains layout.csl, pe.csl, run.py, commands_*.sh
    target_relpath: str           # "pe.csl" / "task.csl" / "src/kernel.csl" / ...
    kernel_id: str
    kernel_group: str             # e.g. "gemv", "stencil", "all"
    spec: Optional[Dict[str, Any]] = None
    angles: List[str] = field(default_factory=list)
    # Detected at resolve-time: which cslc arch + which commands_*.sh
    # exists in the bundle. We prefer wse3 when both are present; fall
    # back to wse2 with a clear log message when only wse2 is shipped
    # (some upstream kernels like SpMV Hypersparse and 25-Point Stencil
    # haven't been re-instrumented for wse3 yet).
    arch: str = "wse3"
    commands_script: str = "commands_wse3.sh"

    @property
    def pe_path(self) -> Path:
        return self.bundle_dir / self.target_relpath


_GROUP_KEYWORDS = {
    "gemv":      ["gemv", "matvec"],
    "gemm":      ["gemm", "matmul", "summa"],
    "stencil":   ["stencil", "halo", "laplacian", "lorenzo"],
    "linalg":    ["cholesky", "cg", "bicgstab", "pcg", "power_iteration"],
    "fft":       ["fft", "butterfly"],
    "reduction": ["reduce", "softmax", "layernorm", "rmsnorm", "sum", "max",
                  "norm", "scan", "prefix", "histogram"],
    "sparse":    ["spmv", "spmm", "spgemm", "csr", "csc", "sparse", "segmented", "mxm", "graphblas", "ell", "dia"],
    "app":       ["mandelbrot", "wide", "histogram"],
}


def infer_kernel_group(kernel_id: str, spec: Optional[Dict[str, Any]] = None) -> str:
    """Best-effort kernel group inference. Spec wins; else keyword match
    on the kernel id; else 'all'."""
    if spec and isinstance(spec.get("group"), str):
        return spec["group"]
    name = (kernel_id or "").lower()
    for group, keywords in _GROUP_KEYWORDS.items():
        if any(kw in name for kw in keywords):
            return group
    return "all"


def load_spec(bundle_dir: Path) -> Optional[Dict[str, Any]]:
    spec_path = bundle_dir.parent / "spec.yaml"
    if not spec_path.is_file():
        spec_path = bundle_dir / "spec.yaml"
    if not spec_path.is_file():
        return None
    try:
        import yaml  # type: ignore
        return yaml.safe_load(spec_path.read_text(encoding="utf-8"))
    except Exception as exc:
        logger.warning("[spec] could not parse %s: %s", spec_path, exc)
        return None


def _registry_target_relpath(kernel_name: str) -> Optional[str]:
    """Look up the canonical target_relpath for a kernel by its directory
    name (e.g. ``7-Point Stencil`` → ``src/kernel.csl``) via the
    cuda2csl.KERNEL_REGISTRY entries. Returns None when the registry has no
    entry matching this directory name. Best-effort import — KERNEL_REGISTRY
    lives in cuda2csl.py which has a heavy import; do it lazily so a
    standalone unit test of resolve_target doesn't pay the cost.
    """
    try:
        import cuda2csl  # type: ignore
    except Exception:
        return None
    for spec in (cuda2csl.KERNEL_REGISTRY or {}).values():
        try:
            ref_dir = Path(spec.get("reference_csl_dir", ""))
            # ref_dir typically ends in /CSL and its parent.name matches the
            # bench directory we got from --target.
            if ref_dir.parent.name == kernel_name:
                return spec.get("target_relpath")
        except Exception:
            continue
    return None


def _find_compute_file(bundle: Path,
                       hint_relpath: Optional[str] = None) -> Optional[str]:
    """Search a bench directory for the compute file. Returns the relpath
    (relative to ``bundle``) of the most-likely compute file, or None.

    Search order:
      1. ``hint_relpath`` if provided + exists (e.g. CLI override or registry).
      2. ``pe.csl`` / ``pe_*.csl`` at bundle root (the most common layout).
      3. ``src/kernel*.csl`` (stencil / CG / BiCGSTAB / PCG / power_method).
      4. Any ``*.csl`` at bundle root that isn't ``layout.csl`` /
         ``launch.csl`` — the largest by size wins (catches residual.csl,
         middle.csl, ucode_2d.csl, device_code.csl, etc).
    """
    if hint_relpath:
        if (bundle / hint_relpath).is_file():
            return hint_relpath
    # 2. pe*.csl at root
    pe_root = sorted(bundle.glob("pe*.csl"),
                     key=lambda x: x.stat().st_size if x.is_file() else 0,
                     reverse=True)
    if pe_root:
        return pe_root[0].name
    # 3. src/kernel*.csl
    src_kernels = sorted((bundle / "src").glob("kernel*.csl"),
                         key=lambda x: x.stat().st_size if x.is_file() else 0,
                         reverse=True) if (bundle / "src").is_dir() else []
    if src_kernels:
        return f"src/{src_kernels[0].name}"
    # 4. any *.csl at root that isn't layout / launch
    others = [p for p in bundle.glob("*.csl")
              if p.is_file() and p.name not in {"layout.csl", "launch.csl"}]
    others.sort(key=lambda x: x.stat().st_size, reverse=True)
    if others:
        return others[0].name
    return None


def _kernel_id_from_path(p: Path) -> str:
    """Derive a canonical kernel id from a path. Strips timestamps
    (``foo__20260604T...``), spaces become underscores so the persistence
    slug is filesystem-safe.
    """
    raw = (p.name if (p / "CSL").is_dir() else p.parent.name).split("__")[0]
    # Replace whitespace with underscores; leave dashes and dots alone so
    # "7-Point_Stencil" keeps the hyphen but loses the space.
    return "_".join(raw.split())


def _detect_arch_and_script(bundle: Path,
                            arch_override: Optional[str] = None,
                            ) -> Tuple[str, str]:
    """Return (arch, commands_script) for a bundle.

    Preference order: arch_override (when set + the script exists) →
    commands_wse3.sh → commands_wse2.sh → commands.sh.

    Raises FileNotFoundError when no recognisable script exists — better
    than letting the benchmark fail 30+ seconds in.
    """
    candidates = []
    if arch_override:
        candidates.append((arch_override, f"commands_{arch_override}.sh"))
    candidates.extend([
        ("wse3", "commands_wse3.sh"),
        ("wse2", "commands_wse2.sh"),
        # commands.sh is unversioned; assume wse3 since that's our target.
        ("wse3", "commands.sh"),
    ])
    for arch, script in candidates:
        if (bundle / script).is_file():
            return arch, script
    raise FileNotFoundError(
        f"no commands_<arch>.sh in {bundle}. Looked for "
        f"commands_wse3.sh, commands_wse2.sh, commands.sh. "
        f"Pass --arch <wseN> if the kernel uses a different name."
    )


def resolve_target(target_path: str,
                    target_relpath_override: Optional[str] = None,
                    arch_override: Optional[str] = None,
                    ) -> OptimizationTarget:
    """Accepts either a kernels/<name>/ directory or .../CSL/ directory or
    a directory under knowledge/explored/successes/.

    Compute-file selection (the bug your 7-Point Stencil run hit):
      * if --target-relpath is set, use it
      * else if KERNEL_REGISTRY has an entry whose reference_csl_dir
        matches this bench, use its target_relpath
      * else search pe.csl → src/kernel*.csl → other *.csl at root

    Spaces in the bench directory name (e.g. ``7-Point Stencil``,
    ``Conjugate Gradient``) are mapped to underscores in the kernel id so
    the persistence slug is filesystem-safe.
    """
    p = Path(os.path.expanduser(target_path)).resolve()
    if not p.is_dir():
        raise FileNotFoundError(f"target not found: {p}")
    # If the path is .../<name>/ with a CSL/ subdir, descend.
    if (p / "CSL").is_dir():
        bundle = p / "CSL"
    elif (p / "pe.csl").is_file() or (p / "layout.csl").is_file():
        bundle = p
    elif ((p / "src").is_dir() and
          any((p / fn).is_file() for fn in
              ("commands_wse3.sh", "commands_wse2.sh", "commands.sh"))):
        # BiCGSTAB/CG/PCG/Power Method layout: compute lives in src/
        # (kernel_*.csl + blas.csl) but the run script + run.py sit at
        # the bundle root next to src/. No pe.csl/layout.csl at root.
        bundle = p
    else:
        raise FileNotFoundError(
            f"{p} does not look like a kernel bundle "
            "(no pe.csl, layout.csl, src/+commands_*.sh, or CSL/ subdir)"
        )

    # Compute file: hint > registry > glob fallback.
    hint = target_relpath_override
    if not hint:
        bench_dir_name = (p.name if (p / "CSL").is_dir() else p.parent.name)
        hint = _registry_target_relpath(bench_dir_name)
    target_relpath = _find_compute_file(bundle, hint)
    if not target_relpath:
        raise FileNotFoundError(
            f"no compute file found in {bundle}. Tried hint={hint!r}, "
            "pe*.csl, src/kernel*.csl, and any other *.csl. Pass "
            "--target-relpath PATH (relative to the bundle directory) "
            "to override."
        )

    kid = _kernel_id_from_path(p)
    spec = load_spec(bundle)
    group = infer_kernel_group(kid, spec)
    angles = (spec.get("optimization_angles")
              if spec and isinstance(spec.get("optimization_angles"), list)
              else None) or angles_for_group(group) or DEFAULT_CSL_OPT_STEPS
    arch, commands_script = _detect_arch_and_script(bundle, arch_override)
    if arch != "wse3":
        logger.warning(
            "[%s] arch fallback: bundle ships only %s (no commands_wse3.sh) — "
            "running with --arch=%s. cycles_send numbers will reflect the "
            "older simulator and won't be comparable to wse3 baselines.",
            kid, commands_script, arch,
        )
    return OptimizationTarget(
        bundle_dir=bundle,
        target_relpath=target_relpath,
        kernel_id=kid,
        kernel_group=group,
        spec=spec,
        angles=list(angles),
        arch=arch,
        commands_script=commands_script,
    )


# ---------------------------------------------------------------------------
# OptimizationOrchestrator
# ---------------------------------------------------------------------------

@dataclass
class RoundOutcome:
    round_idx: int
    angle: str
    accepted: bool
    candidate_cycles: Optional[int]
    baseline_cycles: Optional[int]
    speedup: Optional[float]
    reject_reason: Optional[str]
    diff_summary: Optional[str]
    raw_reply: str = ""
    # Full benchmark dict from benchmark_translated_compute_file when the
    # candidate ran; None when rejected before benchmark (contract
    # violation, no csl fence, LLM error). Carries cycles_send_runs so
    # the persistence layer can record the per-run noise envelope.
    benchmark_dict: Optional[Dict[str, Any]] = None
    # Multi-file ACCEPTED dict {relpath: text}. None when single-file or
    # not accepted. Used by run() to propagate per-focus-file state into
    # the next round's prompt so a 2nd accept builds on the 1st.
    accepted_files: Optional[Dict[str, str]] = None


class OptimizationOrchestrator:

    def __init__(self,
                 *,
                 provider: ProviderHandle,
                 store: ExplorationStore,
                 sdk_root: str,
                 work_root: str,
                 shell_setup: Optional[str],
                 max_tokens: int = 8192,
                 num_runs: int = 3,
                 epsilon: float = 0.01,
                 max_repair_attempts: int = 1,
                 mode: str = "angles",
                 open_after_consecutive_rejects: int = 3,
                 enable_singularity_gate: bool = False) -> None:
        self.provider = provider
        self.store = store
        self.sdk_root = sdk_root
        self.work_root = ensure_directory(expand_path(work_root))
        self.shell_setup = shell_setup
        self.max_tokens = max_tokens
        # cycles_send variance is ~20-30% on the simulator (per the existing
        # comments in benchmark_csl); take the median of N runs.
        self.num_runs = max(1, int(num_runs))
        # Require at least (1+epsilon)x improvement to accept. 1% headroom
        # keeps noise from getting accepted as a "win".
        self.epsilon = max(0.0, float(epsilon))
        # Per-round repair budget. After a candidate fails (compile, run,
        # no-cycles, or contract) we feed the diagnosis back into the LLM
        # and try once more. Cap at max_repair_attempts to bound spend.
        # Set to 0 to disable repairs entirely (preserves old behaviour).
        self.max_repair_attempts = max(0, int(max_repair_attempts))
        # Mode-switching:
        #   angles  → only the named-angle loop (original behavior)
        #   open    → only the open-mode loop (no angle, free form)
        #   auto    → angles loop until N consecutive rejects, then open
        if mode not in ("angles", "open", "auto"):
            raise ValueError(f"unknown mode: {mode!r}")
        self.mode = mode
        self.open_after_consecutive_rejects = max(1, int(
            open_after_consecutive_rejects))
        if enable_singularity_gate:
            os.environ["XKERNEL_SINGULARITY_GATE"] = "1"
        # Force the debugger on so failed candidates get a real diagnosis
        # for the repair prompt. Mirrors what explore_csl does.
        os.environ.setdefault("XKERNEL_DEBUGGER", "1")
        # Round-0 plan (which files to focus / expose). Populated by run()
        # after baseline measurement via _load_plan().
        self.plan: Optional[optimization_planner.OptimizationPlan] = None

    # ----- LLM ------------------------------------------------------------

    def llm(self, prompt: str, *, max_tokens: Optional[int] = None,
            system: Optional[str] = None) -> str:
        messages = [
            {"role": "system",
             "content": system or Instruction_system_csl_optimization},
            {"role": "user", "content": prompt},
        ]
        return llm_complete(self.provider.client, self.provider.model,
                            messages, max_tokens or self.max_tokens)

    # ----- benchmarking ---------------------------------------------------

    def benchmark_with_pe(self, target: OptimizationTarget,
                          pe_csl_text: str) -> Dict[str, Any]:
        """Stage a candidate pe.csl into a sandbox copy of the bundle and
        benchmark. num_runs runs per call (median taken inside benchmark).

        Single-file wrapper over ``benchmark_with_files`` — kept as the
        public entry point used by the (still single-file) round handlers
        while Piece 3a/b/c land. Multi-file callers should use
        ``benchmark_with_files`` directly.
        """
        return self.benchmark_with_files(
            target, {target.target_relpath: pe_csl_text}
        )

    def benchmark_with_files(self, target: OptimizationTarget,
                             files: Dict[str, str]) -> Dict[str, Any]:
        """Stage a dict of ``{relpath: text}`` into the sandbox before
        benchmarking. Each file is overwritten in the staged bundle copy;
        files not in the dict keep their reference contents.

        The primary file (the one ``benchmark_translated_compute_file``
        diffs against the reference) is always ``target.target_relpath``;
        the others are auxiliary edits the multi-file plan asked for
        (e.g. a thin-dispatcher kernel editing ``blas.csl`` alongside
        ``residual.csl``).
        """
        if not files:
            raise ValueError("benchmark_with_files: empty files dict")
        if target.target_relpath not in files:
            raise ValueError(
                f"benchmark_with_files: target_relpath "
                f"{target.target_relpath!r} not in files dict (got "
                f"{sorted(files.keys())})"
            )
        work_dir = tempfile.mkdtemp(prefix=f"opt_{target.kernel_id}_",
                                    dir=self.work_root)
        # The primary file goes through translated_path so the benchmark
        # helper can read+diff it; aux files are staged into the bundle
        # copy AFTER stage_reference_bundle runs, which means we need
        # access to the staged bundle dir. Easiest path: stage the
        # primary the normal way, then walk the bundle and overwrite
        # the aux files in place.
        primary_relpath = target.target_relpath
        primary_text = files[primary_relpath]
        primary_path = Path(work_dir) / primary_relpath
        primary_path.parent.mkdir(parents=True, exist_ok=True)
        primary_path.write_text(primary_text, encoding="utf-8")
        try:
            result = benchmark_translated_compute_file(
                translated_path=str(primary_path),
                reference_dir=str(target.bundle_dir),
                target_relpath=primary_relpath,
                work_dir=work_dir,
                sdk_root=self.sdk_root,
                shell_setup=self.shell_setup,
                commands_script=target.commands_script,
                arch=target.arch,
                keep_staged_bundle=len(files) > 1,
                num_runs=self.num_runs,
            )
            if len(files) > 1:
                staged_bundle = result.get("staged_bundle")
                if not staged_bundle or not os.path.isdir(staged_bundle):
                    # Without the bundle dir we can't overlay aux edits;
                    # fail loudly rather than silently benchmarking the
                    # reference auxiliaries (which would mask a real
                    # regression in the LLM's edit).
                    raise RuntimeError(
                        "multi-file benchmark needed the staged bundle "
                        "to overlay aux edits, but staged_bundle is "
                        f"missing or not a dir: {staged_bundle!r}"
                    )
                # Overlay each aux file, then re-run the bundle's
                # commands script — we need to recompile after the
                # overlay since the primary alone wasn't enough.
                for rel, text in files.items():
                    if rel == primary_relpath:
                        continue
                    dst = Path(staged_bundle) / rel
                    dst.parent.mkdir(parents=True, exist_ok=True)
                    dst.write_text(text, encoding="utf-8")
                # Re-run the staged bundle with the overlay applied.
                from benchmark_csl import run_staged_bundle  # type: ignore
                overlay_result = run_staged_bundle(
                    staged_bundle=staged_bundle,
                    commands_script=result["commands_script"],
                    sdk_root=self.sdk_root,
                    shell_setup=self.shell_setup,
                    timeout=2700,
                    num_runs=self.num_runs,
                )
                # Merge the overlay run's outcome over the primary run's
                # metadata (keep paths/diff stats from the original
                # call, take cycle/transcript fields from the overlay).
                for k in (
                    "status", "failure_reason", "compile_time_ms",
                    "run_time_ms", "cycles_send", "time_send_us",
                    "cycles_send_runs", "cycles_send_min",
                    "cycles_send_max", "time_send_us_runs",
                    "num_runs", "success_marker", "transcript",
                    "script_command", "script_elapsed_ms",
                ):
                    if k in overlay_result:
                        result[k] = overlay_result[k]
            return result
        finally:
            import shutil
            shutil.rmtree(work_dir, ignore_errors=True)

    # ----- planning -------------------------------------------------------

    def _load_plan(
            self,
            target: OptimizationTarget,
            preflight_skipped_angles: Optional[List[str]] = None,
    ) -> "optimization_planner.OptimizationPlan":
        """Scan the bench, fetch (or build) the round-0 plan, stash it on
        ``self.plan``. Always returns the plan — falls back to a
        root-only plan if the scanner or planner errors.

        ``preflight_skipped_angles`` (when provided) is the list of
        catalog angles already implemented by the baseline. Threading
        this into the planner lets it drop helper files whose only
        relevance is an already-skipped angle (e.g. drop blas.csl when
        fmac_bulk is skipped, since blas.csl is pure bulk-BLAS).

        Called once per ``run()`` invocation, between baseline measurement
        and round 1. Subsequent rounds read ``self.plan.focus_files`` and
        ``self.plan.expose_in_prompt`` to know what to edit / show.
        """
        try:
            struct = bench_structure.scan_bench(
                bench_csl_dir=str(target.bundle_dir),
                root_compute_relpath=target.target_relpath,
            )
        except Exception as exc:
            logger.warning(
                "[%s] bench-structure scan failed (%s) — falling back to "
                "root-only plan", target.kernel_id, str(exc)[:200]
            )
            self.plan = optimization_planner.OptimizationPlan(
                kernel_id=target.kernel_id,
                focus_files=[target.target_relpath],
                expose_in_prompt=[target.target_relpath],
                rationale=(f"FALLBACK: bench_structure.scan_bench raised "
                           f"({str(exc)[:120]}). Defaulting to root-only."),
                suggested_first_angle="",
                confidence="low",
                fingerprint="scan-failed",
            )
            return self.plan
        # XKERNEL_OPTIMIZATION_PLANS_ROOT lets tests / smoke-test runs
        # use a throwaway plans directory without polluting the shared
        # ~/xkernel/knowledge/explored/optimization/plans/ cache.
        explored_root = os.environ.get(
            "XKERNEL_OPTIMIZATION_PLANS_ROOT",
            optimization_planner.DEFAULT_EXPLORED_ROOT,
        )
        try:
            self.plan = optimization_planner.get_or_make_plan(
                kernel_id=target.kernel_id,
                kernel_group=target.kernel_group,
                baseline_cycles=self._first_round_baseline,
                struct=struct,
                llm_call=lambda p: self.llm(p, max_tokens=900),
                planner_model=self.provider.model,
                explored_root=explored_root,
                preflight_skipped_angles=preflight_skipped_angles,
            )
        except Exception as exc:
            logger.warning(
                "[%s] planner raised (%s) — falling back to root-only plan",
                target.kernel_id, str(exc)[:200]
            )
            self.plan = optimization_planner.OptimizationPlan(
                kernel_id=target.kernel_id,
                focus_files=[target.target_relpath],
                expose_in_prompt=[target.target_relpath],
                rationale=(f"FALLBACK: planner raised ({str(exc)[:120]}). "
                           "Defaulting to root-only."),
                suggested_first_angle="",
                confidence="low",
                fingerprint="planner-failed",
            )
        return self.plan

    # ----- multi-file prompt scaffolding ----------------------------------

    def _is_multifile(self) -> bool:
        """True when the planner asked for ≥ 2 focus files. Single-file
        plans (the only case until Piece 3 lands BiCGSTAB/CG/PCG/Power)
        keep the legacy single-file prompt + parser path.

        Also fires when the plan picked exactly ONE focus file that
        DISAGREES with target.target_relpath (the dispatcher). This
        catches helper-only plans (e.g. focus=['src/blas.csl'] picked
        without the dispatcher) that the legacy single-file path would
        otherwise silently misroute: that path edits
        target.target_relpath regardless of plan.focus_files, so a
        helper-only plan would end up editing the dispatcher anyway.
        Routing through the multi-file path lets us actually edit the
        helper (with the dispatcher shown read-only).
        """
        if self.plan is None:
            return False
        if len(self.plan.focus_files) > 1:
            return True
        if (len(self.plan.focus_files) == 1
                and self.plan.focus_files[0] != self._target_relpath_for_plan()):
            return True
        return False

    def _target_relpath_for_plan(self) -> str:
        """Helper for _is_multifile: returns the relpath the legacy
        single-file path would edit. Lazily looks at the most recently
        passed target. Used only when plan has exactly one focus file."""
        # The plan dispatch decision happens inside attempt_round, where
        # target is in scope; the only consumer of this method is
        # _is_multifile which gets called from attempt_round. To avoid
        # threading target through every branch, we store the active
        # target on self at attempt_round entry.
        t = getattr(self, "_active_target", None)
        return t.target_relpath if t is not None else ""

    def _read_current_files(
            self,
            target: OptimizationTarget,
            overrides: Optional[Dict[str, str]] = None,
    ) -> Dict[str, str]:
        """Read the current on-disk text of every file in
        ``self.plan.expose_in_prompt``. The focus subset is what the LLM
        is allowed to rewrite; the rest is read-only context.

        ``overrides`` (when provided) replaces the on-disk content for
        any relpath that appears in it. Used by the round driver to
        propagate an accepted multi-file edit to the next round's
        prompt: round N+1 must see what round N produced, not the
        unchanged reference on disk.

        Missing files raise loudly — that signals a stale cached plan
        (a file the planner expected has been moved/deleted). The caller
        should invalidate the plan cache and retry.
        """
        if self.plan is None:
            raise RuntimeError("_read_current_files called before _load_plan")
        files: Dict[str, str] = {}
        for rel in self.plan.expose_in_prompt:
            if overrides and rel in overrides:
                files[rel] = overrides[rel]
                continue
            p = target.bundle_dir / rel
            if not p.is_file():
                raise FileNotFoundError(
                    f"plan expected {rel!r} in {target.bundle_dir} but the "
                    "file is missing — the cached plan may be stale. Delete "
                    f"~/xkernel/knowledge/explored/optimization/plans/"
                    f"{target.kernel_id.lower()}.json and re-run."
                )
            files[rel] = p.read_text(encoding="utf-8")
        return files

    def _build_frozen_callout_block(self,
                                    target: OptimizationTarget) -> str:
        """Render the frozen-symbol callout. Thin wrapper over the
        shared ``prompt_cuda2csl.default_frozen_callout_block`` so the
        single-file path (cuda2csl.py), the RL optimizers, and this
        orchestrator all render the same structured block."""
        from prompt_cuda2csl import default_frozen_callout_block  # type: ignore
        return default_frozen_callout_block(target.spec)

    def _build_focus_files_block(self) -> str:
        if self.plan is None:
            return ""
        return "\n".join(f"  - {rel}" for rel in self.plan.focus_files)

    def _build_exposed_files_block(self,
                                   exposed: Dict[str, str],
                                   max_chars_per_file: int = 16000) -> str:
        """Render the exposed files dict as a sequence of
        ``` csl:<relpath> fences. Each file is annotated with
        (focus|read-only) so the LLM knows which it may rewrite.

        Focus files are NEVER clipped — the LLM must be able to echo
        them back verbatim, and a clipped marker like "// ...elided"
        causes the model to refuse to emit code (saw this on PCG: the
        12k-char kernel_pcg.csl was clipped to 6k and the LLM replied
        only with English saying "I cannot reliably reconstruct the
        elided kernel content"). Read-only context files MAY be clipped
        when they exceed ``max_chars_per_file`` (typically a 1100-line
        allreduce library that's here for reference but not edit).
        """
        if self.plan is None:
            return ""
        focus = set(self.plan.focus_files)
        parts: List[str] = []
        for rel, body in exposed.items():
            is_focus = rel in focus
            tag = "FOCUS" if is_focus else "read-only"
            clipped = body
            if not is_focus and len(clipped) > max_chars_per_file:
                head = clipped[: max_chars_per_file - 200]
                clipped = (
                    f"{head}\n// ... ({len(body) - len(head)} chars elided "
                    f"— file is {len(body)} chars total)\n"
                )
            parts.append(
                f"### {rel}  ({tag})\n"
                f"```csl:{rel}\n{clipped}\n```\n"
            )
        return "\n".join(parts)

    # ----- angle pre-flight ------------------------------------------------

    @staticmethod
    def is_angle_satisfied(angle: str, pe_text: str) -> Optional[str]:
        """Return a short "reason" string if the baseline already implements
        the angle's canonical pattern, else None.

        Heuristics are conservative — we'd rather waste a round than skip
        an angle that has a hidden win. The catalog's "after" signature
        for each angle is encoded here as a regex over pe.csl.
        """
        if not pe_text:
            return None
        nocomment = re.sub(r"//[^\n]*", "", pe_text)
        if angle == "fmac_bulk":
            # An @fmacs whose dst is a DSD (not a scalar) implies bulk form.
            if re.search(r"@fmacs\s*\(\s*[A-Za-z_][A-Za-z0-9_]*_dsd\b",
                         nocomment) or re.search(
                    r"@fmacs\s*\(\s*dsd_[A-Za-z0-9_]+", nocomment):
                return "baseline already uses bulk @fmacs over a DSD"
            return None
        if angle == "dsd_offset_chaining":
            # Pattern: @get_dsd at module scope + @increment_dsd_offset inside
            # a loop. We approximate "at module scope" by checking the
            # @get_dsd that's not nested inside a for-block (the bottleneck
            # profiler already does the inverse — dsd_rebuild_in_loop).
            if "@increment_dsd_offset" in nocomment:
                return "baseline already uses @increment_dsd_offset"
            return None
        if angle == "comptime_hoist":
            # Catalog target: drop @as(i16, PARAM) inside loops; use comptime
            # values directly in @range. If profile_bottlenecks reports zero
            # runtime_size_in_inner_loop hits, there's nothing to hoist.
            bn = profile_bottlenecks(pe_text)
            if "runtime_size_in_inner_loop" not in bn and \
                    "redundant_at_cast" not in bn:
                return ("no @as casts inside runtime loops — comptime hoist "
                        "has nothing to move")
            return None
        if angle == "buffer_cleanup":
            # Hard to detect statically; never auto-skip.
            return None
        if angle in ("memory_simd_alignment", "stride_optimization",
                      "fabric_simd_packing", "comptime_hoisting_tables",
                      "comptime_value_tuning"):
            # These touch internals (align hints, simd packing) that the
            # static profiler can't reliably confirm. Never auto-skip.
            return None
        return None

    def preflight_angles(self,
                         target: OptimizationTarget) -> Tuple[List[str], Dict[str, str]]:
        """Return (active_angles, skip_report). Active angles is the
        sublist whose pattern is NOT already implemented; skip_report
        maps skipped angles to a short reason."""
        pe = target.pe_path.read_text(encoding="utf-8")
        skipped: Dict[str, str] = {}
        active: List[str] = []
        for a in target.angles:
            reason = self.is_angle_satisfied(a, pe)
            if reason:
                skipped[a] = reason
            else:
                active.append(a)
        return active, skipped

    # ----- baseline --------------------------------------------------------

    def measure_baseline(self, target: OptimizationTarget) -> Dict[str, Any]:
        pe_text = target.pe_path.read_text(encoding="utf-8")
        logger.info("[%s] measuring baseline (num_runs=%d)",
                    target.kernel_id, self.num_runs)
        result = self.benchmark_with_pe(target, pe_text)
        return result

    # ----- angle selection -------------------------------------------------

    def select_angle(self, target: OptimizationTarget,
                     current_pe: str,
                     current_cycles: Optional[int],
                     bottlenecks: Dict[str, int],
                     prior_outcomes: List[RoundOutcome]) -> Tuple[str, str]:
        """Pick the next angle. Strict fairness: pick the angle with the
        FEWEST prior attempts on this kernel; tiebreak by bottleneck
        overlap; final tiebreak by catalog order so picks are deterministic.

        Hard caps:
          - never pick the same angle 3 rounds in a row (forces rotation
            even when the scorer wants to anchor)
          - never pick an angle that just produced a contract violation
            in the immediately-prior round (it'll just regenerate the
            same broken delta)

        Falls back to LLM via q_optimize_select_angle when the scorer
        ties multiple angles AND no prior outcomes yet (round 1 with no
        bottleneck signal — pure cold start).
        """
        from collections import Counter
        attempts = Counter(o.angle for o in prior_outcomes)
        # Round 1: honor the planner's suggested_first_angle. The
        # planner has seen the bench structure + pre-flight skip set
        # and picked the angle most likely to land — overriding catalog
        # order makes the first round informative rather than mechanical.
        # Subsequent rounds revert to the fewest-attempts scheduler.
        if (not prior_outcomes
                and self.plan is not None
                and self.plan.suggested_first_angle
                and self.plan.suggested_first_angle in target.angles):
            return (self.plan.suggested_first_angle,
                    "planner suggested_first_angle")
        # Last-3 streak detection.
        recent_streak = []
        for o in reversed(prior_outcomes):
            if recent_streak and o.angle != recent_streak[-1]:
                break
            recent_streak.append(o.angle)
        banned_streak = (recent_streak[0]
                          if len(recent_streak) >= 2 else None)
        # Contract-fail one-round ban.
        banned_contract = None
        if prior_outcomes and not prior_outcomes[-1].accepted \
                and "contract" in (prior_outcomes[-1].reject_reason or ""):
            banned_contract = prior_outcomes[-1].angle

        scored: List[Tuple[Tuple[int, int, float], str, str]] = []
        for idx, name in enumerate(target.angles):
            if name in (banned_streak, banned_contract):
                continue
            meta = angle_metadata(name)
            applicable = set(meta.get("applicable_bottlenecks") or [])
            overlap = applicable & set(bottlenecks.keys())
            # Sort key: fewest attempts first, then bigger overlap first,
            # then catalog order. The tuple (attempts, -overlap, idx) is
            # ascending — smallest wins.
            key = (attempts.get(name, 0), -len(overlap), idx)
            reason = (f"attempts={attempts.get(name, 0)}, overlap={sorted(overlap)}"
                      if overlap
                      else f"attempts={attempts.get(name, 0)}, no overlap "
                           f"(catalog order)")
            scored.append((key, name, reason))
        scored.sort(key=lambda t: t[0])
        if scored:
            return scored[0][1], scored[0][2]

        # Fallback: ask the LLM. Tight prompt, low max_tokens.
        bottleneck_block = (
            "Detected bottlenecks (from static profiler):\n  - "
            + "\n  - ".join(f"{k} ({v})" for k, v in bottlenecks.items())
        ) if bottlenecks else "No structural bottlenecks detected by the static profiler."
        last_diff_block = (
            f"Last accepted angle: {last_accept}." if last_accept
            else "No accepted improvement yet this session."
        )
        whitelist_block = "\n".join(f"  - {a}: "
                                    + (angle_metadata(a).get("description") or "")[:120]
                                    for a in target.angles)
        snippet_lines = 60
        snippet = "\n".join(current_pe.splitlines()[:snippet_lines])
        prompt = q_optimize_select_angle.format(
            whitelist_block=whitelist_block,
            kernel_group=target.kernel_group,
            current_cycles=current_cycles or "(unknown)",
            reference_cycles=(target.spec or {}).get("wse3_reference", {})
                              .get("cycles_send", "(unknown)"),
            bottleneck_block=bottleneck_block,
            per_fn_cycles_block="(per-function cycle breakdown not available)",
            last_diff_block=last_diff_block,
            snippet_lines=snippet_lines,
            current_code_snippet=snippet,
        )
        try:
            reply = self.llm(prompt, max_tokens=300)
        except Exception as exc:
            logger.warning("[%s] angle selector LLM failed: %s",
                           target.kernel_id, str(exc)[:200])
            reply = ""
        m = re.search(r"^\s*ANGLE\s*:\s*([A-Za-z0-9_]+)",
                       reply, re.IGNORECASE | re.MULTILINE)
        if m and m.group(1) in target.angles:
            reason_m = re.search(r"^\s*REASON\s*:\s*(.+)$",
                                  reply, re.IGNORECASE | re.MULTILINE)
            return m.group(1), (reason_m.group(1).strip()[:200]
                                if reason_m else "(LLM picked)")
        # Final fallback: round-robin
        idx = len(prior_outcomes) % max(1, len(target.angles))
        return target.angles[idx], "round-robin fallback"

    # ----- per-round attempt (multi-file) ---------------------------------

    def _attempt_round_multifile(
            self,
            target: OptimizationTarget,
            round_idx: int,
            current_cycles: Optional[int],
            bottlenecks: Dict[str, int],
            prior: List[RoundOutcome],
            current_files_override: Optional[Dict[str, str]] = None,
    ) -> RoundOutcome:
        """Round handler used when self.plan.focus_files has ≥ 2 entries.

        Shape mirrors attempt_round but the prompt fences all exposed
        files with ``` csl:<relpath>, the parser pulls them apart, and
        the benchmark stages every focus file before recompiling.

        Same accept/reject gate as the single-file path.

        ``current_files_override`` is the multi-file analog of
        ``current_pe`` in attempt_round — the dict of focus-file states
        accepted in prior rounds. When provided, the prompt + contract
        checks see these overrides instead of the on-disk reference.
        Round 1 leaves it None (everything reads off disk); rounds
        2..N pass the dict the run loop tracks. WITHOUT this override,
        round 2's prompt would show round-0 disk state and the LLM
        would discard round 1's win on every subsequent round.
        """
        if self.plan is None:
            raise RuntimeError(
                "_attempt_round_multifile called before _load_plan"
            )
        # Read the current state of every exposed file off disk (the
        # focus files are what we'll diff against in the contract check),
        # applying any override that captures prior-round accepts.
        exposed = self._read_current_files(target, current_files_override)
        # The angle selector still picks one named angle for the round —
        # multi-file doesn't change WHICH optimization to try, only
        # WHERE the LLM may edit. Use the root focus file as the snippet
        # so select_angle has something to look at; the catalog matching
        # is by group not file.
        root_text = exposed.get(target.target_relpath, "")
        angle, _reason = self.select_angle(
            target, root_text, current_cycles, bottlenecks, prior,
        )
        meta = angle_metadata(angle)
        logger.info(
            "[%s] round %d: angle=%s (multi-file: focus=%s)",
            target.kernel_id, round_idx, angle, self.plan.focus_files,
        )

        kb = csl_knowledge_base.for_optimization(
            f"{target.kernel_id} {target.kernel_group} {angle}",
            kernel_group=target.kernel_group,
            picked_angle=angle,
            angle_query_hint=meta.get("knowledge_query_hint", ""),
            angle_source_skill=meta.get("source_skill", ""),
            current_kernel=target.kernel_id,
        )
        task_summary = ""
        if target.spec and isinstance(target.spec.get("tasks"), list):
            task_summary = ("Task description:\n  - "
                            + "\n  - ".join(str(t) for t in target.spec["tasks"]))
        reference_contract = ""
        for fname in ("layout.csl", "run.py", "commands_wse3.sh"):
            p = target.bundle_dir / fname
            if p.is_file():
                reference_contract += (f"\n### {fname}\n```\n"
                                       + p.read_text(encoding="utf-8")[:3000]
                                       + "\n```\n")
        bench_summary = (
            f"Last benchmark: cycles_send={current_cycles}, "
            f"baseline cycles_send for accept = strictly less than "
            f"{int((current_cycles or 0) * (1 - self.epsilon))} "
            f"(epsilon={self.epsilon})."
        )
        prompt = q_optimize_csl_compute_multifile.format(
            current_cycles=current_cycles,
            frozen_callout_block=self._build_frozen_callout_block(target),
            knowledge_base=kb,
            task_summary=task_summary,
            optimization_name=angle,
            optimization_description=meta.get("description", "")[:600],
            focus_files_block=self._build_focus_files_block(),
            reference_contract=reference_contract[:8000],
            exposed_files_block=self._build_exposed_files_block(exposed),
            benchmark_summary=bench_summary,
            profiler_feedback="(per-PE TSC profiler not collected in this loop)",
        )
        try:
            reply = self.llm(prompt)
        except Exception as exc:
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=None, baseline_cycles=current_cycles,
                speedup=None,
                reject_reason=f"implementer LLM error: {str(exc)[:150]}",
                diff_summary=None, raw_reply="",
            )

        # Parse per-file fences. The LLM is asked to emit one fence per
        # focus file, but in practice it sometimes drops focus files it
        # didn't actually change (CG/Power_Method live runs showed the
        # model explicitly reasoning "I'll emit only blas.csl"). Treat
        # an omitted focus file as "unchanged" — fall back to the
        # current-state text for that file. The acceptance gate (cycles
        # must strictly drop) still protects against phantom wins:
        # if every focus file is unchanged the bench will return the
        # baseline cycles and the round will reject as no-improvement.
        #
        # If NO focus files at all came back, that's still a hard
        # reject — means the reply had zero csl fences, not even an
        # accidental empty edit.
        per_file_raw = extract_multi_file_blocks(reply, "csl")
        per_file: Dict[str, str] = {}
        preserved_unchanged: List[str] = []
        for rel in self.plan.focus_files:
            if rel in per_file_raw:
                per_file[rel] = per_file_raw[rel]
            else:
                per_file[rel] = exposed[rel]  # current-state fallback
                preserved_unchanged.append(rel)
        if all(rel in preserved_unchanged for rel in self.plan.focus_files):
            # Every focus file was omitted — the reply had no csl
            # fences for any of them. Reject so we don't waste a cslc
            # run on the unchanged reference.
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=None, baseline_cycles=current_cycles,
                speedup=None,
                reject_reason=("multi-file reply omitted ALL focus "
                               f"files {self.plan.focus_files}; "
                               "nothing to benchmark"),
                diff_summary=None, raw_reply=reply,
            )
        if preserved_unchanged:
            logger.info(
                "[%s] round %d multi-file: %d/%d focus files unchanged "
                "(omitted by LLM, treated as no-op): %s",
                target.kernel_id, round_idx, len(preserved_unchanged),
                len(self.plan.focus_files), preserved_unchanged,
            )
        # Reject if the LLM tried to edit a read-only file (anything
        # emitted in the reply that is NOT in focus_files). Scan the
        # RAW parser output (not the derived per_file, which by
        # construction contains only focus relpaths via the
        # preservation fallback above).
        touched_readonly = [rel for rel in per_file_raw
                            if rel and rel not in set(self.plan.focus_files)]
        if touched_readonly:
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=None, baseline_cycles=current_cycles,
                speedup=None,
                reject_reason=(f"touched read-only files: "
                               f"{touched_readonly}"),
                diff_summary=None, raw_reply=reply,
            )

        # Frozen-contract check per focus file. The frozen-symbol list
        # (f_tic/f_toc/param decls) lives in spec.yaml and describes the
        # ORIGINAL reference, so we always diff against the on-disk
        # reference here — using the prior-round accepted state as the
        # baseline could let the contract drift across rounds.
        ff, fp = spec_frozen_lists(target.spec)
        for rel in self.plan.focus_files:
            ref_text = (target.bundle_dir / rel).read_text(encoding="utf-8")
            violation = validate_against_reference(
                per_file[rel], ref_text,
                frozen_functions=ff, frozen_params=fp,
            )
            if violation:
                return RoundOutcome(
                    round_idx=round_idx, angle=angle, accepted=False,
                    candidate_cycles=None, baseline_cycles=current_cycles,
                    speedup=None,
                    reject_reason=f"contract ({rel}): {violation[:180]}",
                    diff_summary=None, raw_reply=reply,
                )

        # Benchmark — overlay every focus file onto the staged bundle.
        # The primary file (target.target_relpath) MUST be in the dict
        # since the planner always includes the root in focus_files.
        bench_files = {rel: per_file[rel] for rel in self.plan.focus_files}
        bench = self.benchmark_with_files(target, bench_files)
        # On reject paths, populate accepted_files with the dict the LLM
        # produced so the run-loop's failure persistence can write aux
        # files (blas.csl etc.) to the failures/<slug>/ bundle. Even on
        # rejection, the operator wants to see WHICH aux edits were
        # tried. (Field name is "accepted_files" for symmetry with the
        # accept path; on rejects it means "files staged for the
        # benchmark that just rejected".)
        if bench.get("status") != "pass":
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=None, baseline_cycles=current_cycles,
                speedup=None,
                reject_reason=f"bench {bench.get('status')}: "
                              f"{bench.get('failure_reason') or '?'}",
                diff_summary=None, raw_reply=reply,
                benchmark_dict=bench,
                accepted_files=dict(bench_files),
            )
        cand_cycles = bench.get("cycles_send")
        if cand_cycles is None:
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=None, baseline_cycles=current_cycles,
                speedup=None,
                reject_reason="cycles_send not reported by run.py",
                diff_summary=None, raw_reply=reply,
                benchmark_dict=bench,
                accepted_files=dict(bench_files),
            )
        threshold = (current_cycles or 0) * (1.0 - self.epsilon)
        if cand_cycles >= threshold and current_cycles:
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=cand_cycles, baseline_cycles=current_cycles,
                speedup=(current_cycles / cand_cycles)
                        if cand_cycles else None,
                reject_reason=(f"no-improvement (cycles {cand_cycles} >= "
                               f"threshold {int(threshold)})"),
                diff_summary=None, raw_reply=reply,
                benchmark_dict=bench,
                accepted_files=dict(bench_files),
            )
        # Accept. Persist via store using the ROOT focus file as the
        # representative optimized_pe_csl (the persistence layer is
        # currently single-file; the multi-file write-back of aux focus
        # files lands in Piece 3a's final glue step which extends
        # record_optimization, scheduled for after the live BiCGSTAB
        # validation). For now we record the root file's new text so
        # the per-kernel JSON DAG still shows movement.
        root_ref = (target.bundle_dir / target.target_relpath).read_text(
            encoding="utf-8"
        )
        root_new = per_file[target.target_relpath]
        diff_summary = self._distill_diff(
            angle, root_ref, root_new, current_cycles, cand_cycles,
        )
        # Aux files = focus files OTHER than the root; persisted as
        # extras so multi-file accepts don't lose the helper edits and
        # offline audit can see exactly what blas.csl looked like.
        aux_extras = {
            rel: text for rel, text in bench_files.items()
            if rel != target.target_relpath
        }
        store_row = self.store.record_optimization(
            kernel=target.kernel_id,
            kernel_group=target.kernel_group,
            angle=angle,
            baseline_cycles=current_cycles,
            candidate_cycles=cand_cycles,
            accepted=True,
            reject_reason=None,
            optimized_pe_csl=root_new,
            diff_summary=diff_summary,
            benchmark_result=bench,
            bottlenecks=sorted(bottlenecks.keys()),
            provider=self.provider.kind,
            model=self.provider.model,
            extra_files=aux_extras,
        )
        sp = store_row.get("speedup")
        logger.info(
            "[%s] round %d ACCEPT (multi-file): %s baseline=%s "
            "candidate=%s speedup=%.2fx (edited %d files, "
            "%d aux persisted)",
            target.kernel_id, round_idx, angle, current_cycles,
            cand_cycles, sp or 0.0, len(bench_files), len(aux_extras),
        )
        try:
            optimization_tree.record_accept_in_tree(
                kernel=target.kernel_id,
                baseline_cycles=self._first_round_baseline,
                candidate_cycles=int(cand_cycles),
                parent_cycles=int(current_cycles) if current_cycles else None,
                bundle=_bundle_dir_from_store_row(store_row),
                angle=angle,
                ts=store_row.get("ts") or "",
                diff_summary_text=diff_summary or "",
                explored_root=str(self.store.root),
            )
        except Exception as exc:
            logger.warning(
                "[%s] tree update failed (multi-file): %s",
                target.kernel_id, str(exc)[:200],
            )
        return RoundOutcome(
            round_idx=round_idx, angle=angle, accepted=True,
            candidate_cycles=cand_cycles, baseline_cycles=current_cycles,
            speedup=sp,
            reject_reason=None, diff_summary=diff_summary, raw_reply=reply,
            benchmark_dict=bench,
            accepted_files=dict(bench_files),
        )

    # ----- per-round attempt ----------------------------------------------

    def attempt_round(
            self,
            target: OptimizationTarget,
            round_idx: int,
            current_pe: str,
            current_cycles: Optional[int],
            bottlenecks: Dict[str, int],
            prior: List[RoundOutcome],
            current_files_override: Optional[Dict[str, str]] = None,
    ) -> RoundOutcome:
        # Stash target so _is_multifile (and its
        # _target_relpath_for_plan helper) can detect a helper-only
        # single-focus plan that disagrees with target.target_relpath
        # and route it through the multi-file path instead of silently
        # editing the dispatcher.
        self._active_target = target
        # Multi-file detour: when the planner asked for ≥ 2 focus files,
        # OR for a single focus that isn't the dispatcher, build a
        # multi-file prompt and route through the multi-file parser +
        # multi-file benchmark. The single-file path below is unchanged
        # for plans that focus only on the root.
        if self._is_multifile():
            return self._attempt_round_multifile(
                target, round_idx, current_cycles, bottlenecks, prior,
                current_files_override=current_files_override,
            )
        angle, _reason = self.select_angle(
            target, current_pe, current_cycles, bottlenecks, prior,
        )
        meta = angle_metadata(angle)
        logger.info("[%s] round %d: angle=%s", target.kernel_id,
                    round_idx, angle)

        # Build the optimizer prompt (reuse q_optimize_csl_compute).
        kb = csl_knowledge_base.for_optimization(
            f"{target.kernel_id} {target.kernel_group} {angle}",
            kernel_group=target.kernel_group,
            picked_angle=angle,
            angle_query_hint=meta.get("knowledge_query_hint", ""),
            angle_source_skill=meta.get("source_skill", ""),
            current_kernel=target.kernel_id,
        )
        task_summary = ""
        if target.spec and isinstance(target.spec.get("tasks"), list):
            task_summary = ("Task description:\n  - "
                            + "\n  - ".join(str(t) for t in target.spec["tasks"]))
        reference_contract = ""
        # Show layout.csl + run.py + commands as the reference contract.
        for fname in ("layout.csl", "run.py", "commands_wse3.sh"):
            p = target.bundle_dir / fname
            if p.is_file():
                reference_contract += (f"\n### {fname}\n```\n"
                                       + p.read_text(encoding="utf-8")[:3000]
                                       + "\n```\n")
        bench_summary = (
            f"Last benchmark: cycles_send={current_cycles}, "
            f"baseline cycles_send for accept = strictly less than "
            f"{int((current_cycles or 0) * (1 - self.epsilon))} "
            f"(epsilon={self.epsilon})."
        )
        prompt = q_optimize_csl_compute.format(
            current_cycles=current_cycles,
            frozen_callout_block=self._build_frozen_callout_block(target),
            knowledge_base=kb,
            task_summary=task_summary,
            optimization_name=angle,
            optimization_description=meta.get("description", "")[:600],
            reference_contract=reference_contract[:8000],
            current_code=current_pe,
            benchmark_summary=bench_summary,
            profiler_feedback="(per-PE TSC profiler not collected in this loop)",
        )
        try:
            reply = self.llm(prompt)
        except Exception as exc:
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=None, baseline_cycles=current_cycles,
                speedup=None,
                reject_reason=f"implementer LLM error: {str(exc)[:150]}",
                diff_summary=None, raw_reply="",
            )
        new_pe = extract_code_block(reply, "csl")
        if not new_pe:
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=None, baseline_cycles=current_cycles,
                speedup=None, reject_reason="no ```csl fence in reply",
                diff_summary=None, raw_reply=reply,
            )

        # Frozen-contract check BEFORE we burn cslc.
        ref_pe = target.pe_path.read_text(encoding="utf-8")
        ff, fp = spec_frozen_lists(target.spec)
        violation = validate_against_reference(new_pe, ref_pe,
                                               frozen_functions=ff,
                                               frozen_params=fp)
        if violation:
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=None, baseline_cycles=current_cycles,
                speedup=None, reject_reason=f"contract: {violation[:200]}",
                diff_summary=None, raw_reply=reply,
            )

        bench = self.benchmark_with_pe(target, new_pe)
        if bench.get("status") != "pass":
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=None, baseline_cycles=current_cycles,
                speedup=None,
                reject_reason=f"bench {bench.get('status')}: "
                              f"{bench.get('failure_reason') or '?'}",
                diff_summary=None, raw_reply=reply,
                benchmark_dict=bench,
            )
        cand_cycles = bench.get("cycles_send")
        if cand_cycles is None:
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=None, baseline_cycles=current_cycles,
                speedup=None,
                reject_reason="cycles_send not reported by run.py",
                diff_summary=None, raw_reply=reply,
                benchmark_dict=bench,
            )
        # Require strictly better cycles by at least epsilon.
        threshold = (current_cycles or 0) * (1.0 - self.epsilon)
        if cand_cycles >= threshold and current_cycles:
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=cand_cycles, baseline_cycles=current_cycles,
                speedup=(current_cycles / cand_cycles)
                        if cand_cycles else None,
                reject_reason=(f"no-improvement (cycles {cand_cycles} >= "
                               f"threshold {int(threshold)})"),
                diff_summary=None, raw_reply=reply,
                benchmark_dict=bench,
            )
        # Accept. Persist via store; ask for a one-paragraph diff summary.
        diff_summary = self._distill_diff(angle, ref_pe, new_pe,
                                          current_cycles, cand_cycles)
        store_row = self.store.record_optimization(
            kernel=target.kernel_id,
            kernel_group=target.kernel_group,
            angle=angle,
            baseline_cycles=current_cycles,
            candidate_cycles=cand_cycles,
            accepted=True,
            reject_reason=None,
            optimized_pe_csl=new_pe,
            diff_summary=diff_summary,
            benchmark_result=bench,
            bottlenecks=sorted(bottlenecks.keys()),
            provider=self.provider.kind,
            model=self.provider.model,
        )
        sp = store_row.get("speedup")
        logger.info("[%s] round %d ACCEPT: %s baseline=%s candidate=%s speedup=%.2fx",
                    target.kernel_id, round_idx, angle,
                    current_cycles, cand_cycles, sp or 0.0)
        # Tree: record this accept as a new node in the per-kernel DAG.
        # Failures are non-fatal — the orchestrator can keep going even
        # if the tree machinery is broken. baseline_cycles_full = the
        # original kernel baseline (before any optimization on this run);
        # current_cycles is the parent's cycle count (what this accept
        # forked from). The tree resolves parent_id via parent_cycles.
        try:
            optimization_tree.record_accept_in_tree(
                kernel=target.kernel_id,
                baseline_cycles=self._first_round_baseline,
                candidate_cycles=int(cand_cycles),
                parent_cycles=int(current_cycles) if current_cycles else None,
                bundle=_bundle_dir_from_store_row(store_row),
                angle=angle,
                ts=store_row.get("ts") or "",
                diff_summary_text=diff_summary or "",
                explored_root=str(self.store.root),
            )
        except Exception as exc:
            logger.warning("[%s] tree update failed: %s",
                           target.kernel_id, str(exc)[:200])
        return RoundOutcome(
            round_idx=round_idx, angle=angle, accepted=True,
            candidate_cycles=cand_cycles, baseline_cycles=current_cycles,
            speedup=sp,
            reject_reason=None, diff_summary=diff_summary, raw_reply=reply,
        )

    # ----- open-mode round -------------------------------------------------
    #
    # Same acceptance gate as the named-angle round but no angle, no lever
    # block. The prompt nudges the LLM toward changes the named-angle
    # catalog doesn't describe (algorithmic rewrites, fusion, async
    # pipelining). Persisted under angle="OPEN" so aggregates stay clean.

    _OPEN_FENCE_RE = re.compile(
        r"```hypothesis\s*\n(.*?)```\s*```csl\s*\n(.*?)```",
        re.DOTALL,
    )

    def _parse_open_reply(self, reply: str) -> Tuple[Optional[str], Optional[str]]:
        """Extract (hypothesis, csl_code) from an open-mode reply. Falls
        back to plain csl-fence extraction if the hypothesis fence is
        missing — better to have the code than to reject the round."""
        if not reply:
            return None, None
        m = self._OPEN_FENCE_RE.search(reply)
        if m:
            return m.group(1).strip(), m.group(2).strip()
        csl = extract_code_block(reply, "csl")
        return None, csl

    def attempt_open_round(self,
                           target: OptimizationTarget,
                           round_idx: int,
                           current_pe: str,
                           current_cycles: Optional[int],
                           bottlenecks: Dict[str, int],
                           prior: List["RoundOutcome"]) -> "RoundOutcome":
        """One open-mode attempt. Same shape as attempt_round but with
        a different prompt and angle="OPEN" in the record."""
        angle = "OPEN"
        logger.info("[%s] round %d: OPEN-mode (no named angle)",
                    target.kernel_id, round_idx)

        # KB context: for_optimization without picked_angle so the lever
        # block is suppressed; the explored-experience block still shows
        # what historically helped this group.
        kb = csl_knowledge_base.for_optimization(
            f"{target.kernel_id} {target.kernel_group} open-mode",
            kernel_group=target.kernel_group,
            current_kernel=target.kernel_id,
        )
        task_summary = ""
        if target.spec and isinstance(target.spec.get("tasks"), list):
            task_summary = ("\n".join(f"  - {t}"
                                       for t in target.spec["tasks"]))
        bottleneck_block = (
            "  - " + "\n  - ".join(f"{k} ({v})" for k, v in bottlenecks.items())
        ) if bottlenecks else "  (no structural bottlenecks detected)"
        # Compact history: what angles have been tried, accept rate.
        from collections import Counter
        attempts = Counter(o.angle for o in prior)
        accepts = Counter(o.angle for o in prior if o.accepted)
        if attempts:
            lines = []
            for a, n in sorted(attempts.items()):
                acc = accepts.get(a, 0)
                lines.append(f"  - {a}: {acc}/{n} accepted")
            angle_history_block = "\n".join(lines)
        else:
            angle_history_block = "  (no prior named-angle attempts on this kernel)"

        reference_contract = ""
        for fname in ("layout.csl", "run.py", "commands_wse3.sh"):
            p = target.bundle_dir / fname
            if p.is_file():
                reference_contract += (f"\n### {fname}\n```\n"
                                       + p.read_text(encoding="utf-8")[:3000]
                                       + "\n```\n")
        prompt = q_optimize_open_compute.format(
            current_cycles=current_cycles,
            frozen_callout_block=self._build_frozen_callout_block(target),
            task_summary=task_summary or "(no task description on file)",
            bottleneck_block=bottleneck_block,
            angle_history_block=angle_history_block,
            reference_contract=reference_contract[:8000],
            knowledge_base=kb,
            current_code=current_pe,
            builtin_whitelist=builtin_whitelist_block(),
        )
        try:
            reply = self.llm(prompt)
        except Exception as exc:
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=None, baseline_cycles=current_cycles,
                speedup=None,
                reject_reason=f"implementer LLM error: {str(exc)[:150]}",
                diff_summary=None, raw_reply="", benchmark_dict=None,
            )
        hypothesis, new_pe = self._parse_open_reply(reply)
        if not new_pe:
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=None, baseline_cycles=current_cycles,
                speedup=None, reject_reason="no ```csl fence in reply",
                diff_summary=None, raw_reply=reply, benchmark_dict=None,
            )

        # Same contract + bench gates as the angle path.
        ref_pe = target.pe_path.read_text(encoding="utf-8")
        ff, fp = spec_frozen_lists(target.spec)
        violation = validate_against_reference(new_pe, ref_pe,
                                               frozen_functions=ff,
                                               frozen_params=fp)
        if violation:
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=None, baseline_cycles=current_cycles,
                speedup=None, reject_reason=f"contract: {violation[:200]}",
                diff_summary=None, raw_reply=reply, benchmark_dict=None,
            )
        bench = self.benchmark_with_pe(target, new_pe)
        if bench.get("status") != "pass":
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=None, baseline_cycles=current_cycles,
                speedup=None,
                reject_reason=f"bench fail: {bench.get('status')}: "
                              f"{bench.get('failure_reason') or '?'}",
                diff_summary=None, raw_reply=reply, benchmark_dict=bench,
            )
        cand_cycles = bench.get("cycles_send")
        if cand_cycles is None:
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=None, baseline_cycles=current_cycles,
                speedup=None,
                reject_reason="cycles_send not reported by run.py",
                diff_summary=None, raw_reply=reply, benchmark_dict=bench,
            )
        threshold = (current_cycles or 0) * (1.0 - self.epsilon)
        if cand_cycles >= threshold and current_cycles:
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=cand_cycles, baseline_cycles=current_cycles,
                speedup=(current_cycles / cand_cycles) if cand_cycles else None,
                reject_reason=(f"no-improvement (cycles {cand_cycles} >= "
                               f"threshold {int(threshold)})"),
                diff_summary=None, raw_reply=reply, benchmark_dict=bench,
            )
        # Accept. The hypothesis fence — when present — is what we persist
        # as the distilled lesson; that's the open-mode equivalent of the
        # named-angle catalog's description. Fall back to _distill_diff
        # when the LLM omitted the hypothesis block.
        if hypothesis:
            diff_summary = "[OPEN-MODE HYPOTHESIS] " + hypothesis[:1100]
        else:
            diff_summary = ("[OPEN-MODE, NO HYPOTHESIS FENCE] "
                             + self._distill_diff(angle, ref_pe, new_pe,
                                                  current_cycles, cand_cycles))
        store_row = self.store.record_optimization(
            kernel=target.kernel_id, kernel_group=target.kernel_group,
            angle=angle, baseline_cycles=current_cycles,
            candidate_cycles=cand_cycles,
            accepted=True, reject_reason=None,
            optimized_pe_csl=new_pe, diff_summary=diff_summary,
            benchmark_result=bench,
            bottlenecks=sorted(bottlenecks.keys()),
            provider=self.provider.kind, model=self.provider.model,
        )
        sp = store_row.get("speedup")
        logger.info("[%s] round %d OPEN-ACCEPT: baseline=%s candidate=%s "
                    "speedup=%.2fx", target.kernel_id, round_idx,
                    current_cycles, cand_cycles, sp or 0.0)
        try:
            optimization_tree.record_accept_in_tree(
                kernel=target.kernel_id,
                baseline_cycles=getattr(self, "_first_round_baseline",
                                          current_cycles) or current_cycles,
                candidate_cycles=int(cand_cycles),
                parent_cycles=int(current_cycles) if current_cycles else None,
                bundle=_bundle_dir_from_store_row(store_row),
                angle=angle,
                ts=store_row.get("ts") or "",
                diff_summary_text=diff_summary or "",
                explored_root=str(self.store.root),
            )
        except Exception as exc:
            logger.warning("[%s] tree update failed (OPEN): %s",
                           target.kernel_id, str(exc)[:200])
        return RoundOutcome(
            round_idx=round_idx, angle=angle, accepted=True,
            candidate_cycles=cand_cycles, baseline_cycles=current_cycles,
            speedup=sp,
            reject_reason=None, diff_summary=diff_summary, raw_reply=reply,
            benchmark_dict=bench,
        )

    # ----- repair loop -----------------------------------------------------
    #
    # Mirrors explore_csl.repair_round but for the optimization path:
    # one shot per repair, fed the previous broken pe.csl + cslc/run
    # stderr + (optionally) a debugger diagnosis. The angle is preserved
    # in the repair prompt so the fix doesn't collapse back to baseline.

    # Reject reasons we'll try to repair. "no-improvement" is NOT one —
    # the LLM already produced a correct kernel; another shot at the same
    # angle won't help.
    _REPAIRABLE_PREFIXES = (
        "bench fail:", "no ```csl fence", "contract:",
        "cycles_send not reported", "implementer LLM error",
    )

    def _is_repairable(self, reject_reason: Optional[str]) -> bool:
        if not reject_reason:
            return False
        return any(reject_reason.startswith(p) for p in self._REPAIRABLE_PREFIXES)

    def _debugger_diagnose(self,
                           target: OptimizationTarget,
                           candidate_pe: str,
                           bench: Optional[Dict[str, Any]],
                           failure_reason: str) -> Optional[str]:
        """One debugger call. Returns a prompt-block string (or None on error).
        Cheap — bounded inputs, <=1k output tokens."""
        try:
            stderr_tail = ""
            for entry in (bench or {}).get("transcript") or []:
                if entry.get("status") != "pass":
                    stderr_tail = (entry.get("stderr") or "")[-2000:]
                    break
            inp = DebuggerInput(
                current_csl=candidate_pe,
                stderr_tail=stderr_tail,
                failure_reason=failure_reason,
                reviewer_rationale="(no reviewer — optimization mode)",
                reviewer_debug_action="inspect cslc/run stderr; recommend "
                                       "a minimal patch that preserves the "
                                       "optimization intent",
                reference_contract=read_layout_csl(str(target.bundle_dir)),
                layout_csl=read_layout_csl(str(target.bundle_dir)),
            )
            dbg = DebuggerAgent(
                llm_call=lambda msgs, max_tokens=None: llm_complete(
                    self.provider.client, self.provider.model,
                    msgs, max_tokens or 1024),
                max_tokens=1024,
            )
            report = dbg.diagnose(inp)
            return report.to_prompt_block() if report.fired else None
        except Exception as exc:
            logger.warning("[%s] debugger errored: %s",
                           target.kernel_id, str(exc)[:200])
            return None

    def repair_round(self,
                      target: OptimizationTarget,
                      round_idx: int,
                      angle: str,
                      current_cycles: Optional[int],
                      prev_outcome: "RoundOutcome",
                      attempt: int) -> "RoundOutcome":
        """One repair iteration. Returns a new RoundOutcome (may be
        accept, may be another rejection — caller decides whether to
        repair-again based on max_repair_attempts and reject_reason).
        """
        # Pull the previous candidate's pe.csl out of its raw_reply
        # (we don't otherwise persist it before this point).
        prev_pe = extract_code_block(prev_outcome.raw_reply, "csl") or ""
        diagnosis_block = self._debugger_diagnose(
            target, prev_pe, prev_outcome.benchmark_dict,
            prev_outcome.reject_reason or "unknown",
        ) or "(no debugger diagnosis available)"
        # Refresh KB context for this angle (same call shape as attempt_round).
        meta = angle_metadata(angle)
        kb = csl_knowledge_base.for_optimization(
            f"{target.kernel_id} {target.kernel_group} {angle}",
            kernel_group=target.kernel_group,
            picked_angle=angle,
            angle_query_hint=meta.get("knowledge_query_hint", ""),
            angle_source_skill=meta.get("source_skill", ""),
            current_kernel=target.kernel_id,
        )
        # Render reference contract (layout.csl + run.py + commands_wse3.sh).
        reference_contract = ""
        for fname in ("layout.csl", "run.py", "commands_wse3.sh"):
            p = target.bundle_dir / fname
            if p.is_file():
                reference_contract += (f"\n### {fname}\n```\n"
                                       + p.read_text(encoding="utf-8")[:3000]
                                       + "\n```\n")
        # Render the failure transcript tail.
        bench = prev_outcome.benchmark_dict or {}
        transcript_text = format_command_transcript(bench.get("transcript", []))
        repair_prompt = csl_optimize_repair.format(
            angle_name=angle,
            angle_description=meta.get("description", "")[:600],
            benchmark_status=bench.get("status", "fail"),
            failure_reason=prev_outcome.reject_reason or "unknown",
            command_transcript=transcript_text[:4000],
            debugger_report=diagnosis_block,
            knowledge_base=kb,
            previous_pe=prev_pe[:6000],
            reference_contract=reference_contract[:8000],
            builtin_whitelist=builtin_whitelist_block(),
            cycles_send_recipe=CYCLES_SEND_RECIPE,
        )
        try:
            reply = self.llm(repair_prompt)
        except Exception as exc:
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=None, baseline_cycles=current_cycles,
                speedup=None,
                reject_reason=f"repair LLM error: {str(exc)[:150]}",
                diff_summary=None, raw_reply="",
                benchmark_dict=None,
            )
        new_pe = extract_code_block(reply, "csl")
        if not new_pe:
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=None, baseline_cycles=current_cycles,
                speedup=None, reject_reason="no ```csl fence in repair reply",
                diff_summary=None, raw_reply=reply, benchmark_dict=None,
            )
        # Frozen-contract check BEFORE cslc.
        ref_pe = target.pe_path.read_text(encoding="utf-8")
        ff, fp = spec_frozen_lists(target.spec)
        violation = validate_against_reference(new_pe, ref_pe,
                                               frozen_functions=ff,
                                               frozen_params=fp)
        if violation:
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=None, baseline_cycles=current_cycles,
                speedup=None,
                reject_reason=f"contract (repair): {violation[:200]}",
                diff_summary=None, raw_reply=reply, benchmark_dict=None,
            )
        bench2 = self.benchmark_with_pe(target, new_pe)
        if bench2.get("status") != "pass":
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=None, baseline_cycles=current_cycles,
                speedup=None,
                reject_reason=f"bench fail (repair): {bench2.get('status')}: "
                              f"{bench2.get('failure_reason') or '?'}",
                diff_summary=None, raw_reply=reply, benchmark_dict=bench2,
            )
        cand_cycles = bench2.get("cycles_send")
        if cand_cycles is None:
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=None, baseline_cycles=current_cycles,
                speedup=None,
                reject_reason="cycles_send not reported by run.py (repair)",
                diff_summary=None, raw_reply=reply, benchmark_dict=bench2,
            )
        threshold = (current_cycles or 0) * (1.0 - self.epsilon)
        if cand_cycles >= threshold and current_cycles:
            return RoundOutcome(
                round_idx=round_idx, angle=angle, accepted=False,
                candidate_cycles=cand_cycles, baseline_cycles=current_cycles,
                speedup=(current_cycles / cand_cycles) if cand_cycles else None,
                reject_reason=(f"no-improvement after repair "
                               f"(cycles {cand_cycles} >= "
                               f"threshold {int(threshold)})"),
                diff_summary=None, raw_reply=reply, benchmark_dict=bench2,
            )
        # Accept the repaired variant — persist with a "via repair" lesson tag.
        diff_summary = self._distill_diff(angle, ref_pe, new_pe,
                                          current_cycles, cand_cycles)
        diff_summary = ("[ACCEPTED VIA REPAIR ATTEMPT " + str(attempt) + "] "
                        + (diff_summary or "")[:1100])
        store_row = self.store.record_optimization(
            kernel=target.kernel_id, kernel_group=target.kernel_group,
            angle=angle, baseline_cycles=current_cycles,
            candidate_cycles=cand_cycles,
            accepted=True, reject_reason=None,
            optimized_pe_csl=new_pe, diff_summary=diff_summary,
            benchmark_result=bench2,
            provider=self.provider.kind, model=self.provider.model,
        )
        sp = (current_cycles / cand_cycles) if (current_cycles and cand_cycles) else None
        logger.info("[%s] round %d REPAIR-ACCEPT (attempt %d): %s "
                    "baseline=%s candidate=%s speedup=%.2fx",
                    target.kernel_id, round_idx, attempt, angle,
                    current_cycles, cand_cycles, sp or 0.0)
        try:
            optimization_tree.record_accept_in_tree(
                kernel=target.kernel_id,
                baseline_cycles=getattr(self, "_first_round_baseline",
                                          current_cycles) or current_cycles,
                candidate_cycles=int(cand_cycles),
                parent_cycles=int(current_cycles) if current_cycles else None,
                bundle=_bundle_dir_from_store_row(store_row),
                angle=angle,
                ts=store_row.get("ts") or "",
                diff_summary_text=diff_summary or "",
                explored_root=str(self.store.root),
            )
        except Exception as exc:
            logger.warning("[%s] tree update failed (REPAIR): %s",
                           target.kernel_id, str(exc)[:200])
        return RoundOutcome(
            round_idx=round_idx, angle=angle, accepted=True,
            candidate_cycles=cand_cycles, baseline_cycles=current_cycles,
            speedup=sp,
            reject_reason=None, diff_summary=diff_summary, raw_reply=reply,
            benchmark_dict=bench2,
        )

    def _distill_diff(self, angle: str,
                      old_pe: str, new_pe: str,
                      baseline: Optional[int],
                      cand: Optional[int]) -> str:
        """One short LLM call to summarise what changed and why. Returns a
        short paragraph suitable for KB ingest. Best-effort — falls back to
        a templated string when the call errors."""
        prompt = (
            "You are summarising one accepted CSL optimization for a "
            "knowledge-base entry. Output two SHORT paragraphs (≤80 words "
            "each), no preamble, no fences:\n\n"
            "  P1: which concrete CSL constructs changed (e.g. 'replaced a "
            "scalar for-loop over A_tile with a single @fmacs over a "
            "mem1d_dsd'). Cite line types, not full code.\n"
            "  P2: why this reduced cycles_send under the named angle.\n\n"
            f"Angle: {angle}\n"
            f"Baseline cycles: {baseline}  Candidate cycles: {cand}\n\n"
            "## OLD pe.csl (first 200 lines)\n```csl\n"
            + "\n".join(old_pe.splitlines()[:200]) + "\n```\n\n"
            "## NEW pe.csl (first 200 lines)\n```csl\n"
            + "\n".join(new_pe.splitlines()[:200]) + "\n```\n"
        )
        try:
            reply = self.llm(prompt, max_tokens=400)
        except Exception as exc:
            return (f"Auto-summary failed ({str(exc)[:80]}). Angle={angle}, "
                    f"baseline={baseline}, candidate={cand}.")
        return reply.strip()[:1200]

    # ----- driver -----------------------------------------------------------

    def run(self, target: OptimizationTarget,
            n_rounds: int) -> List[RoundOutcome]:
        # Pre-flight: drop angles whose canonical "after" pattern is
        # already present in the baseline. Skipped angles are logged so
        # the operator sees why budget was redirected.
        # Skip the pre-flight entirely in --mode open (no named angles
        # consulted anyway) so we don't abort on "all angles satisfied"
        # — that's exactly the case open-mode exists for.
        # Capture the skipped set so we can thread it into the planner
        # later (lets the planner drop helpers whose only relevance is
        # an already-satisfied angle, e.g. blas.csl when fmac_bulk is
        # skipped).
        preflight_skipped: List[str] = []
        if self.mode == "open":
            logger.info("[%s] OPEN mode: skipping named-angle pre-flight",
                        target.kernel_id)
        else:
            active, skipped = self.preflight_angles(target)
            if skipped:
                for a, why in skipped.items():
                    logger.info("[%s] pre-flight SKIP %-25s : %s",
                                target.kernel_id, a, why)
                preflight_skipped = sorted(skipped.keys())
            if not active:
                if self.mode == "auto":
                    logger.info("[%s] all angles already satisfied → "
                                "auto-mode will run open from round 1",
                                target.kernel_id)
                else:
                    raise RuntimeError(
                        f"all {len(target.angles)} requested angles are "
                        "already implemented in the baseline. Re-run with "
                        "--mode open (or --mode auto) to let the LLM "
                        "search outside the catalog."
                    )
            else:
                if len(active) < len(target.angles):
                    logger.info("[%s] %d/%d angles active after pre-flight: %s",
                                target.kernel_id, len(active),
                                len(target.angles), active)
                target.angles = active

        baseline = self.measure_baseline(target)
        if baseline.get("status") != "pass":
            # Surface the actual cslc/cs_python stderr so the operator
            # knows whether the baseline is broken (missing dep, missing
            # data file, env drift) vs. simply uninstrumented. The bare
            # "command_failed" string in failure_reason is useless.
            tail = ""
            for entry in (baseline.get("transcript") or []):
                if entry.get("status") != "pass":
                    tail = (entry.get("stderr") or "")[-1500:]
                    break
            raise RuntimeError(
                f"baseline failed to benchmark for {target.kernel_id} "
                f"(reason={baseline.get('failure_reason')!r}). "
                f"The kernel's own commands_{target.arch}.sh did not run "
                f"cleanly in our staging sandbox. Common causes: missing "
                f"input data file (e.g. SpMV Hypersparse expects "
                f"./data/rmat*.mtx), different cs_python flag conventions, "
                f"or run.py imports utilities not copied to the sandbox.\n"
                f"--- cslc/cs_python stderr tail ---\n{tail or '(empty)'}"
            )
        base_cycles = baseline.get("cycles_send")
        # Stash the absolute baseline (before any optimization on this
        # session) on self so accept handlers can populate the tree's
        # root-cycles field correctly. current_cycles moves with each
        # accept; _first_round_baseline does not.
        self._first_round_baseline = base_cycles
        if base_cycles is None:
            raise RuntimeError(
                f"baseline for {target.kernel_id} ran successfully but did "
                "not emit `cycles_send = N cycles` to stdout. This kernel's "
                "run.py is correctness-only — no timing instrumentation.\n"
                "\n"
                "Fix options:\n"
                "  1. Pick a kernel that IS instrumented (GEMV, GEMM, "
                "Cholesky, 7-Point Stencil, BiCGSTAB, CG, etc).\n"
                "  2. Add the canonical tic/toc + cycles_send print to "
                "this kernel's run.py (see /home/USER/xkernel/kernels/GEMV/"
                "CSL/run.py for the pattern).\n"
                "  3. Run with --no-cycles-required to use run_time_ms as "
                "the optimization signal instead (less precise — wall "
                "clock includes simulator overhead)."
            )
        # Empirical noise floor: median-of-N stdev from the baseline's
        # per-run cycles list (when available). Use it to raise epsilon
        # if the user's setting is below 2*sigma/median. This prevents
        # accepting a "win" that's indistinguishable from noise.
        runs = baseline.get("cycles_send_runs") or []
        if len(runs) >= 3:
            import statistics as _stats
            sigma = _stats.pstdev(runs)
            empirical_eps = (2.0 * sigma / base_cycles) if base_cycles else 0.0
            if empirical_eps > self.epsilon:
                logger.info("[%s] noise-aware epsilon raised "
                            "%.4f -> %.4f (sigma=%.2f cycles over %d runs)",
                            target.kernel_id, self.epsilon, empirical_eps,
                            sigma, len(runs))
                self.epsilon = empirical_eps
            else:
                logger.info("[%s] baseline noise OK: sigma=%.2f, "
                            "epsilon=%.4f (>= 2*sigma/median=%.4f)",
                            target.kernel_id, sigma, self.epsilon,
                            empirical_eps)
        logger.info("[%s] baseline cycles_send = %d (group=%s, "
                    "active angles=%d, epsilon=%.3f)",
                    target.kernel_id, base_cycles, target.kernel_group,
                    len(target.angles), self.epsilon)

        # Round-0 plan: which files to optimize, which to expose. For
        # self-contained kernels (Cholesky etc.) this trivially says
        # "focus on root, expose root" — same as today's behavior. For
        # thin-dispatcher kernels (BiCGSTAB/CG/PCG/Power Method) it
        # surfaces the editable libraries (blas.csl, benchmark-libs
        # subdirs) so the round handlers can edit + benchmark them.
        # preflight_skipped is threaded in so the planner can drop a
        # helper whose only catalog-targetable angle is already
        # satisfied (e.g. drop blas.csl when fmac_bulk is skipped).
        plan = self._load_plan(target,
                                preflight_skipped_angles=preflight_skipped)
        logger.info(
            "[%s] plan: focus=%s expose=%s first_angle=%s confidence=%s",
            target.kernel_id, plan.focus_files, plan.expose_in_prompt,
            plan.suggested_first_angle or "(scheduler picks)",
            plan.confidence,
        )

        current_pe = target.pe_path.read_text(encoding="utf-8")
        current_cycles = int(base_cycles)
        outcomes: List[RoundOutcome] = []
        # Multi-file state propagation: after a multi-file accept, the
        # accepted dict moves into this override so round N+1 sees what
        # round N produced (not the unchanged reference on disk).
        # None on single-file plans or before any accept lands.
        current_files_override: Optional[Dict[str, str]] = None
        # Track consecutive-reject streak for the auto-switch into open mode.
        consec_rejects = 0
        # When auto-mode finds no angles to try (every named angle is
        # already satisfied), force open mode immediately rather than
        # cycling through empty rounds.
        forced_open = (self.mode == "auto" and not target.angles)
        if forced_open:
            logger.info("[%s] auto-mode + no active angles → starting in "
                        "OPEN from round 1", target.kernel_id)
        for r in range(1, n_rounds + 1):
            bottlenecks = profile_bottlenecks(current_pe)
            # Decide whether to run an angle-mode round or an open-mode round.
            if self.mode == "open":
                use_open = True
            elif self.mode == "angles":
                use_open = False
            else:  # auto
                use_open = (forced_open or
                            consec_rejects >= self.open_after_consecutive_rejects)
                if use_open and not forced_open:
                    logger.info("[%s] auto-mode: %d consecutive rejects → "
                                "switching to OPEN for remaining rounds",
                                target.kernel_id, consec_rejects)
                    forced_open = True
            if use_open:
                outcome = self.attempt_open_round(
                    target, r, current_pe, current_cycles, bottlenecks,
                    outcomes,
                )
            else:
                outcome = self.attempt_round(
                    target, r, current_pe, current_cycles, bottlenecks,
                    outcomes,
                    current_files_override=current_files_override,
                )
            outcomes.append(outcome)
            if outcome.accepted and outcome.candidate_cycles is not None:
                # Promote the accepted variant to current; future rounds
                # optimise on top of the new best.
                current_pe = extract_code_block(outcome.raw_reply, "csl") or current_pe
                current_cycles = outcome.candidate_cycles
                consec_rejects = 0
                if outcome.accepted_files:
                    # Multi-file accept: stash the whole dict so round
                    # N+1's prompt + bottleneck profile reflect the new
                    # state of every focus file, not just the root.
                    current_files_override = dict(outcome.accepted_files)
                    # Keep the root focus-file text aligned with
                    # current_pe so the bottleneck profiler (which still
                    # reads current_pe at the top of the loop) sees the
                    # accepted edits.
                    root_text = current_files_override.get(target.target_relpath)
                    if root_text:
                        current_pe = root_text
            else:
                consec_rejects += 1
                # Try to repair if the failure mode is one we know how to
                # address (compile/run/contract/no-cycles). Cap by
                # max_repair_attempts. The repair_round itself persists
                # successes via record_optimization; we record the FINAL
                # outcome (whether it's the original failure or the
                # post-repair failure) so the JSONL row carries the
                # actual broken pe.csl + stderr.
                final = outcome
                repair_idx = 0
                while (repair_idx < self.max_repair_attempts
                        and self._is_repairable(final.reject_reason)):
                    repair_idx += 1
                    logger.info("[%s] round %d repair attempt %d/%d "
                                "(angle=%s, reason=%s)",
                                target.kernel_id, r, repair_idx,
                                self.max_repair_attempts, final.angle,
                                (final.reject_reason or "?")[:60])
                    repaired = self.repair_round(
                        target, r, final.angle, current_cycles,
                        final, repair_idx,
                    )
                    final = repaired
                    if final.accepted:
                        break
                if final.accepted and final.candidate_cycles is not None:
                    # Repair won — promote it AND reset the open-mode streak
                    # counter (the round produced an accept after all).
                    current_pe = (extract_code_block(final.raw_reply, "csl")
                                   or current_pe)
                    current_cycles = final.candidate_cycles
                    outcomes[-1] = final
                    consec_rejects = 0
                    if final.accepted_files:
                        current_files_override = dict(final.accepted_files)
                        root_text = current_files_override.get(
                            target.target_relpath)
                        if root_text:
                            current_pe = root_text
                    continue
                # Either no repair was attempted, or repair also failed.
                # Persist with the failure-bundle bits so we can inspect
                # what the LLM did wrong AND so future runs can read it.
                bench_for_record = (final.benchmark_dict
                                     if final.benchmark_dict
                                     else {"status": "rejected"})
                last_pe = (extract_code_block(final.raw_reply, "csl") or "")
                stderr_tail = ""
                for entry in (bench_for_record.get("transcript") or []):
                    if entry.get("status") != "pass":
                        stderr_tail = (entry.get("stderr") or "")[-1500:]
                        break
                # Cheap diagnosis on terminal failure — gives the operator
                # a starting point without needing to re-run the debugger
                # by hand.
                diagnosis = None
                if self._is_repairable(final.reject_reason) and last_pe:
                    diagnosis = self._debugger_diagnose(
                        target, last_pe, final.benchmark_dict,
                        final.reject_reason or "?",
                    )
                # Multi-file rejects: persist aux file contents the LLM
                # emitted (e.g. blas.csl edits in the BiCGSTAB family)
                # so offline audit can see exactly which aux edits were
                # tried on a rejected round, not just the root file.
                # accepted_files holds the dict the multi-file path
                # used; for single-file rejects it's None.
                fail_extras = {
                    rel: text for rel, text in (final.accepted_files or {}).items()
                    if rel != target.target_relpath
                } if final.accepted_files else None
                self.store.record_optimization(
                    kernel=target.kernel_id,
                    kernel_group=target.kernel_group,
                    angle=final.angle,
                    baseline_cycles=base_cycles,
                    candidate_cycles=final.candidate_cycles,
                    accepted=False,
                    reject_reason=final.reject_reason,
                    optimized_pe_csl="",
                    diff_summary=None,
                    benchmark_result=bench_for_record,
                    bottlenecks=sorted(bottlenecks.keys()),
                    provider=self.provider.kind,
                    model=self.provider.model,
                    failure_pe_csl=last_pe,
                    failure_layout_csl=(target.bundle_dir / "layout.csl").read_text(
                        encoding="utf-8", errors="ignore"
                    ) if (target.bundle_dir / "layout.csl").is_file() else "",
                    failure_stderr_tail=stderr_tail,
                    failure_diagnosis=diagnosis,
                    extra_files=fail_extras,
                )
                # Update the outcomes list with the final (post-repair) row
                # so the scheduler sees the most recent attempt.
                outcomes[-1] = final
        return outcomes


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def build_argparser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description="Optimization-exploration: iteratively reduce cycles_send "
                    "of an existing passing CSL kernel.",
    )
    p.add_argument("--target", required=True,
                   help="Path to a passing kernel bundle: either "
                        "kernels/<Name>/ (with CSL/ subdir) or a "
                        "knowledge/explored/successes/<id>__<ts>/ dir.")
    p.add_argument("--target-relpath", default=None,
                   help="Override the compute-file relpath inside the "
                        "bundle (e.g. 'src/kernel.csl' for 7-Point "
                        "Stencil, 'residual.csl' for Residual). Default: "
                        "look up KERNEL_REGISTRY, then auto-search "
                        "pe*.csl / src/kernel*.csl / other *.csl.")
    p.add_argument("--arch", default=None, choices=["wse2", "wse3"],
                   help="Override cslc architecture. Default: auto-detect "
                        "from which commands_<arch>.sh exists in the "
                        "bundle (prefers wse3, falls back to wse2 with "
                        "a warning).")
    p.add_argument("--n-rounds", type=int, default=3)
    p.add_argument("--num-runs", type=int, default=3,
                   help="Per-attempt benchmark runs; median taken to kill "
                        "the simulator's 20-30%% cycles noise.")
    p.add_argument("--epsilon", type=float, default=0.01,
                   help="Min relative speedup to accept (1.0 + epsilon). "
                        "Default 0.01 = 1%% — keeps noise from getting "
                        "accepted as a win.")
    p.add_argument("--repair-attempts", type=int, default=1,
                   help="Per-round repair iterations after a compile/run/"
                        "contract failure (each iteration = 1 debugger "
                        "diagnosis + 1 implementer fix + 1 re-benchmark). "
                        "0 disables the repair loop. Default: 1.")
    p.add_argument("--mode", choices=["angles", "open", "auto"],
                   default="angles",
                   help="Optimization mode. 'angles' = only the named-angle "
                        "catalog (original behaviour). 'open' = free-form, "
                        "no named angle (find any cycle reduction). 'auto' "
                        "= start with angles, switch to open after N "
                        "consecutive rejects.")
    p.add_argument("--open-after", type=int, default=3,
                   help="For --mode auto: switch to open mode after this "
                        "many consecutive angle-mode rejects (an accept "
                        "resets the counter). Default: 3.")
    p.add_argument("--angles", type=str, default=None,
                   help="Comma-separated list of angle names to restrict to. "
                        "Default: pull from spec.yaml or kernel group.")
    p.add_argument("--provider", choices=["auto", "alcf", "argo", "openai"],
                   default="auto")
    p.add_argument("--alcf-endpoint", choices=["metis", "sophia"], default="metis")
    p.add_argument("--model", type=str, default=None)
    p.add_argument("--api-key-file", type=str, default=DEFAULT_API_KEY_FILE)
    p.add_argument("--api-key-command", type=str, default=None)
    p.add_argument("--require-provider", action="store_true")
    p.add_argument("--sdk-root", type=str, default=DEFAULT_SDK_ROOT)
    p.add_argument("--work-root", type=str,
                   default=str(THIS_DIR / "sandbox" / "optimize_explore"))
    p.add_argument("--export-dir", type=str, default=DEFAULT_EXPLORED_ROOT)
    p.add_argument("--shell-setup", type=str, default=None)
    p.add_argument("--shell-setup-file", type=str, default=None)
    p.add_argument("--max-tokens", type=int, default=8192)
    p.add_argument("--enable-singularity-gate", action="store_true")
    p.add_argument("--dry-run", action="store_true",
                   help="Resolve target + profile bottlenecks + pick first "
                        "angle, but skip LLM and cslc. Useful for CI.")
    p.add_argument("--audit", action="store_true",
                   help="Scan the directory passed as --target (e.g. "
                        "kernels/) and report which kernels are "
                        "optimize-ready (have commands_*.sh, instrumented "
                        "run.py emitting cycles_send). Skips all LLM work. "
                        "Use this BEFORE picking a kernel to optimize.")
    return p


def _audit_kernels(root: Path) -> None:
    """Walk a kernels/ root and report optimize-readiness per kernel.

    Per-kernel checks (cheap, no cslc invocation):
      - has any commands_<arch>.sh
      - has any compute file (pe.csl / src/kernel*.csl / other *.csl)
      - has run.py
      - run.py emits cycles_send print (grep)
      - has spec.yaml
      - flagged caveats (needs data file, --skip-compile, etc.)

    Prints a table sorted: ready first, then partially-ready, then broken.
    """
    if not root.is_dir():
        print(f"audit: {root} is not a directory")
        return
    rows = []
    for kdir in sorted(root.iterdir()):
        if not kdir.is_dir() or kdir.name.startswith(("_", ".")):
            continue
        csl_dir = kdir / "CSL"
        if not csl_dir.is_dir():
            csl_dir = kdir  # bare layout, no CSL subdir
        notes = []
        # commands script
        script = None
        for arch_name, fname in (("wse3", "commands_wse3.sh"),
                                  ("wse2", "commands_wse2.sh")):
            if (csl_dir / fname).is_file():
                script = (arch_name, fname)
                break
        if not script:
            rows.append((kdir.name, "BROKEN", "no commands_*.sh", []))
            continue
        arch, script_name = script
        if arch == "wse2":
            notes.append("wse2-only")
        # compute file
        compute = _find_compute_file(csl_dir)
        if not compute:
            rows.append((kdir.name, "BROKEN",
                         "no pe*.csl / src/kernel*.csl / other *.csl", notes))
            continue
        notes.append(f"compute={compute}")
        # run.py
        runpy = csl_dir / "run.py"
        if not runpy.is_file():
            rows.append((kdir.name, "BROKEN", "no run.py", notes))
            continue
        # cycles_send instrumentation
        runtext = runpy.read_text(encoding="utf-8", errors="ignore")
        cycles_print = ("cycles_send" in runtext and "print" in runtext)
        # caveats
        if "--infile" in runtext or "data/" in runtext:
            notes.append("needs data file")
        if "--skip-compile" in runtext:
            notes.append("--skip-compile flag present")
        spec = csl_dir.parent / "spec.yaml" if csl_dir.name == "CSL" \
               else csl_dir / "spec.yaml"
        if spec.is_file():
            spec_text = spec.read_text(encoding="utf-8", errors="ignore")
            if "no_wse3_reference" in spec_text:
                notes.append("spec: no_wse3_reference")
            if "hidden_from_optimize_only" in spec_text:
                notes.append("hidden_from_optimize_only")
        # readiness
        if cycles_print and "needs data file" not in notes:
            ready = "READY"
        elif cycles_print:
            ready = "PARTIAL"
        else:
            ready = "NO_CYCLES"
        rows.append((kdir.name, ready, "", notes))

    # Render
    order = {"READY": 0, "PARTIAL": 1, "NO_CYCLES": 2, "BROKEN": 3}
    rows.sort(key=lambda r: (order.get(r[1], 99), r[0]))
    counts = {}
    for _, status, _, _ in rows:
        counts[status] = counts.get(status, 0) + 1
    print()
    print(f"  {'kernel':<28} {'status':<10}  notes")
    print("  " + "-" * 90)
    for name, status, why, notes in rows:
        note_str = "; ".join(notes + ([why] if why else []))
        print(f"  {name:<28} {status:<10}  {note_str}")
    print()
    print("Counts: " + ", ".join(f"{s}={n}" for s, n in counts.items()))
    print()
    print("READY kernels are the safe bet for optimize_explore:")
    for name, status, _, _ in rows:
        if status == "READY":
            print(f"  micromamba run -n xkernel-agent python3 "
                  f"code_translation/optimize_explore.py "
                  f"--target 'kernels/{name}' --mode auto --n-rounds 10 "
                  f"--num-runs 5 --provider argo --enable-singularity-gate")
            if status == "READY":
                # Only first few
                break


def main() -> int:
    args = build_argparser().parse_args()
    shell_setup = load_shell_setup(args.shell_setup, args.shell_setup_file)
    # --audit short-circuits BEFORE resolve_target (which expects a single
    # kernel bundle, not a kernels/ root).
    if args.audit:
        _audit_kernels(Path(os.path.expanduser(args.target)).resolve())
        return 0
    target = resolve_target(args.target,
                            target_relpath_override=args.target_relpath,
                            arch_override=args.arch)
    if args.angles:
        wanted = {a.strip() for a in args.angles.split(",") if a.strip()}
        target.angles = [a for a in target.angles if a in wanted] or list(wanted)
    logger.info("[main] target=%s group=%s angles=%s",
                target.kernel_id, target.kernel_group, target.angles)

    if args.dry_run:
        pe = target.pe_path.read_text(encoding="utf-8")
        bn = profile_bottlenecks(pe)
        logger.info("[main] dry-run bottlenecks: %s", bn or "(none detected)")
        logger.info("[main] dry-run picked angles: %s", target.angles)
        return 0

    store = ExplorationStore(args.export_dir)
    try:
        provider = resolve_provider(
            provider=args.provider,
            alcf_endpoint=args.alcf_endpoint,
            model=args.model,
            api_key_file=args.api_key_file,
            api_key_command=args.api_key_command,
            require=args.require_provider,
        )
    except RuntimeError as exc:
        logger.error("[main] provider resolution failed: %s", exc)
        return 2
    orch = OptimizationOrchestrator(
        provider=provider, store=store,
        sdk_root=expand_path(args.sdk_root),
        work_root=args.work_root,
        shell_setup=shell_setup,
        max_tokens=args.max_tokens,
        num_runs=args.num_runs,
        epsilon=args.epsilon,
        max_repair_attempts=max(0, int(args.repair_attempts)),
        mode=args.mode,
        open_after_consecutive_rejects=max(1, int(args.open_after)),
        enable_singularity_gate=args.enable_singularity_gate,
    )
    outcomes = orch.run(target, n_rounds=args.n_rounds)
    accepts = [o for o in outcomes if o.accepted]
    print()
    print("=" * 60)
    print(f"  kernel              {target.kernel_id}")
    print(f"  group               {target.kernel_group}")
    print(f"  rounds run          {len(outcomes)}")
    print(f"  accepts             {len(accepts)}")
    if accepts:
        # Two distinct numbers worth reporting:
        #   - cumulative: initial_baseline / best_cycles_ever — the actual
        #     headline gain across the whole session
        #   - last hop:  the speedup of the single best round, attributable
        #     to one angle
        # The original code printed only the last-hop speedup, which is
        # misleading when the session chains multiple accepts.
        best = min(accepts, key=lambda o: o.candidate_cycles or 1 << 30)
        # Initial baseline = baseline_cycles of the FIRST round (before any
        # accept moved current_cycles forward).
        first_baseline = outcomes[0].baseline_cycles if outcomes else None
        cumulative_speedup = (first_baseline / best.candidate_cycles
                              if (first_baseline and best.candidate_cycles)
                              else None)
        if cumulative_speedup:
            print(f"  initial baseline    {first_baseline} cycles")
            print(f"  best cycles_send    {best.candidate_cycles}")
            print(f"  cumulative speedup  {cumulative_speedup:.3f}x "
                  f"({(1 - best.candidate_cycles/first_baseline)*100:.1f}% saved)")
            print(f"  best single hop     {best.speedup:.3f}x ({best.angle})")
            if len(accepts) > 1:
                hops = " → ".join(str(o.candidate_cycles) for o in accepts)
                print(f"  accept chain        {first_baseline} → {hops}")
        else:
            print(f"  best cycles_send    {best.candidate_cycles}")
            print(f"  best speedup        {best.speedup:.3f}x ({best.angle})")
    print("=" * 60)
    return 0


if __name__ == "__main__":
    sys.exit(main())
