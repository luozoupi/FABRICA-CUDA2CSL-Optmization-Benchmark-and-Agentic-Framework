#!/usr/bin/env python3
"""
CUDA -> CSL translation workflow with staged Cerebras bundle benchmarking.
"""

from __future__ import annotations

import argparse
import json
import logging
import os
import re
import shutil
import tempfile
from pathlib import Path
from typing import Dict, List, Optional, Tuple

from benchmark_csl import benchmark_translated_compute_file
import csl_knowledge_base
from experience_store import ExperienceStore
from profile_csl import build_profile_report, format_profile_for_prompt
from prompt_cuda2csl import (
    CSL_OPTIMIZATION_STEPS,
    MODEL_CSL_OPT_STEPS,
    DEFAULT_CSL_OPT_STEPS,
    Instruction_system_csl_optimization,
    Instruction_system_cuda_to_csl,
    angle_metadata,
    angles_for_group,
    builtin_whitelist_block,
    csl_bundle_fix,
    csl_bundle_fix_contract,
    csl_bundle_fix_with_review,
    default_frozen_callout_block,
    q_analyse_cuda_source,
    q_design_architecture,
    q_optimize_csl_compute,
    q_optimize_select_angle,
    q_plan_mesh_decomposition,  # backward-compat alias for q_design_architecture
    q_review_failure,
    q_translate_cuda_to_csl_bundle,
    q_translate_cuda_to_csl_codesign,
    q_translate_from_template,
)
from design_schema import validate_and_augment as _validate_design
from translation_facts import render_facts_block as _render_translation_facts
from translation_facts import extract_layout_facts as _extract_layout_facts
from wiring_plan import (
    parse_wiring_plan as _parse_wiring_plan,
    validate_wiring_plan as _validate_wiring_plan,
    merge_with_translation_facts as _merge_wiring_facts,
    format_wiring_plan_block as _format_wiring_plan,
    parse_layout_contract as _parse_layout_contract,
)
from csl_templates import (
    select_template as _select_template,
    get_template as _get_template,
    format_template_prompt as _format_template_prompt,
)
from debugger_agent import (
    DebuggerAgent,
    DebuggerInput,
    DebuggerReport,
    ScopedFileReader,
    read_layout_csl,
    should_fire as debugger_should_fire,
)
from error_gotcha_retrieval import retrieve_gotchas
from contract_check import (
    spec_frozen_lists,
    splice_frozen_functions,
    validate_against_reference as validate_contract,
)
from workflow_common import (
    DEFAULT_API_KEY_FILE,
    build_sdk_env,
    create_anthropic_client,
    create_openai_client,
    current_python_identity,
    detect_current_python_packages,
    ensure_directory,
    expand_path,
    _clip_head_tail,
    extract_code_block,
    extract_multi_file_blocks,
    format_command_transcript,
    is_anthropic_model,
    load_api_key,
    load_shell_setup,
    llm_complete,
    maybe_load_dotenv,
    package_available,
    probe_command,
    run_subprocess,
    save_json,
    timestamped_output_dir,
)
from workflow_common import default_sdk_root, sdk_sif_path  # noqa: E402


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(filename)s:%(lineno)d - %(levelname)s - %(message)s",
)


# ---------------------------------------------------------------------------
# Progressive layer-clearance tracker (B7)
# ---------------------------------------------------------------------------
# Tracks compile-error families across repair attempts.  When a family
# disappears, injects a "don't regress" advisory into the next fix prompt.
# Gate: XKERNEL_LAYER_CLEARANCE (default "1" = ON).

_LAYER_PATTERNS: List[Tuple[str, str]] = [
    (r"undeclared identifier|undefined symbol|not found in scope", "undeclared-symbol"),
    (r"initialization for this queue has already been set", "queue-already-set"),
    (r"not a member of struct|no member named", "struct-field"),
    (r"expected .*i16.*got.*u16|cannot cast.*i16.*u16", "u16-i16-cast"),
    (r"arguments do not match|no matching overload", "signature-mismatch"),
    (r"task has already been bound", "task-id-reuse"),
    (r"unused entry in module instantiation", "unused-module-entry"),
    (r"@activate.*comptime", "activate-in-comptime"),
    (r"@import_module.*not found|cannot find module", "import-not-found"),
]
_LAYER_RES = [(re.compile(p, re.I), label) for p, label in _LAYER_PATTERNS]


class LayerClearanceTracker:
    """Track which compile-error families appear/disappear across attempts."""

    def __init__(self):
        self._prev_families: set = set()
        self._cleared: set = set()

    def _classify(self, stderr: str) -> set:
        families = set()
        for regex, label in _LAYER_RES:
            if regex.search(stderr):
                families.add(label)
        return families

    def update(self, stderr: str) -> None:
        cur = self._classify(stderr or "")
        newly_cleared = self._prev_families - cur
        if newly_cleared:
            self._cleared |= newly_cleared
            logging.info("[layer-clearance] cleared: %s", ", ".join(sorted(newly_cleared)))
        self._prev_families = cur

    def advisory(self) -> str:
        if os.environ.get("XKERNEL_LAYER_CLEARANCE", "1") == "0":
            return ""
        if not self._cleared:
            return ""
        items = "\n".join(f"  - {f}" for f in sorted(self._cleared))
        return (
            "LAYER-CLEARANCE ADVISORY: you previously fixed these error "
            "families — do NOT reintroduce them:\n" + items
        )

    def reset(self):
        self._prev_families = set()
        self._cleared = set()


REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MODEL = os.getenv("OPENAI_MODEL", "gpt-4.1")
DEFAULT_WORK_ROOT = str(Path(__file__).resolve().parent / "sandbox" / "cuda2csl")
DEFAULT_OUTPUT = str(Path(__file__).resolve().parent / "results" / "cuda2csl")
LEGACY_CEREBRAS_VENV = "~/R_2.9.0/venv_cerebras_pt"
DEFAULT_AGENT_ENV = "fabrica-agent"

ALCF_ENDPOINTS = {
    "metis": {
        "base_url": "https://inference-api.alcf.anl.gov/resource_server/metis/api/v1",
        "default_model": "gpt-oss-120b",
    },
    "sophia": {
        "base_url": "https://inference-api.alcf.anl.gov/resource_server/sophia/vllm/v1",
        "default_model": "openai/gpt-oss-120b",
    },
}

def _k(name: str, target: str) -> dict:
    """Build a KERNEL_REGISTRY entry for kernels/NAME/CUDA/kernel.cu → kernels/NAME/CSL."""
    return {
        "cuda_path":         str(REPO_ROOT / "kernels" / name / "CUDA" / "kernel.cu"),
        "reference_csl_dir": str(REPO_ROOT / "kernels" / name / "CSL"),
        "target_relpath":    target,
        "commands_script":   "commands_wse3.sh",
        "arch":              "wse3",
    }


KERNEL_REGISTRY = {
    # --- Single-PE compute file (pe.csl pattern) ---
    "GEMV":                _k("GEMV",                "pe.csl"),
    "GEMM":                _k("GEMM",                "pe.csl"),
    "GEMM-Collectives-2D": _k("GEMM Collectives 2D", "pe.csl"),
    "GEMV-Checkerboard":   _k("GEMV Checkerboard",   "pe.csl"),
    "GEMV-Collectives-2D": _k("GEMV Collectives 2D", "pe.csl"),
    "Cholesky":            _k("Cholesky",             "pe.csl"),
    "Wide-Multiplication": _k("Wide Multiplication",  "pe.csl"),
    "Single-Tile-Matvec":  _k("Single Tile Matvec",  "pe_matvec.csl"),
    "Game-of-Life":        _k("Game of Life",         "pe_program.csl"),
    # --- Graded halo-exchange kernels (added 2026-05-30) ---
    # Laplacian2D-Halo: the minimum-viable 4-cardinal halo kernel
    # Laplacian2D-Reduce / LorenzoPredictor-Tile: compile-clean skeletons (numerical verification pending)
    "Laplacian2D-Halo":      _k("Laplacian2D-Halo",      "pe.csl"),
    "Laplacian2D-Reduce":    _k("Laplacian2D-Reduce",    "pe.csl"),
    "LorenzoPredictor-Tile": _k("LorenzoPredictor-Tile", "pe.csl"),
    # --- Residual compute files ---
    "Residual":            _k("Residual",             "residual.csl"),
    # --- Jacobi 2D 5-point stencil (added to registry 2026-06-24). Already a
    #     full WSE-3 bundle: pe.csl is the @set_tile_code compute, run.py prints
    #     cycles_send over the on-device step() window, gated verifier (tolerance
    #     clamped). Inline-arithmetic stencil -> cycles is the right metric. ---
    "Jacobi-2D-5pt":       _k("Jacobi-2D-5pt",        "pe.csl"),
    # --- Histogram: WSE-2 -> WSE-3 ported 2026-06-24 (commands_wse3.sh generated;
    #     data-task/input-queue migration + queue-init; validated result=1024).
    #     metric: correctness_only (no TSC window + data-dependent + tally lib). The
    #     agent writes histogram.csl (the per-PE binning compute); code.csl=layout. ---
    "Histogram":           _k("Histogram",            "histogram.csl"),
    # --- SpMV-CSR: HAND-WRITTEN-COMPUTE variant (authored 2026-06-24). The real
    #     translation counterpart to the library-delegated SpMV-Hypersparse: the agent
    #     writes the explicit CSR matvec (per-row reduction + gathered x load), single
    #     PE, TSC-timed -> metric: cycles. Validated on WSE-3 (y=A@x, 6927 cyc). See
    #     docs/HANDWRITTEN_KERNELS.md. ---
    "SpMV-CSR":            _k("SpMV-CSR",             "pe.csl"),
    # --- Histogram-1PE: HAND-WRITTEN-COMPUTE variant (authored 2026-06-24). The
    #     real-translation counterpart to the <kernels/tally>-delegated Histogram: the
    #     agent writes the explicit per-element binning (divide/modulo + indexed
    #     increment), single PE, TSC-timed -> metric: cycles. Validated on WSE-3
    #     (exact bincount, 6191 cyc). See docs/HANDWRITTEN_KERNELS.md. ---
    "Histogram-1PE":       _k("Histogram-1PE",        "pe.csl"),
    "Histogram-Inline":    _k("Histogram-Inline",     "pe.csl"),
    "GEMV-RowPart":        _k("GEMV-RowPart",         "pe.csl"),
    # --- Stencil7pt-1PE: HAND-WRITTEN-COMPUTE variant (authored 2026-06-24). The
    #     real-translation counterpart to the stencil_3d_7pts-library-delegated
    #     7-Point Stencil: the agent writes the explicit 3D 7-point weighted sum with
    #     boundary guards, single PE, TSC-timed -> metric: cycles. Validated on WSE-3
    #     (exact match, 40497 cyc). See docs/HANDWRITTEN_KERNELS.md. ---
    "Stencil7pt-1PE":      _k("Stencil7pt-1PE",       "pe.csl"),
    # --- DFT-1PE: HAND-WRITTEN-COMPUTE variant in the FFT family (authored
    #     2026-06-24). The real-translation counterpart to the FFT-library-delegated
    #     3D-FFT / FFT-1D-2D: the agent writes the explicit complex MAC of a direct
    #     O(N^2) DFT (host-provided twiddle tables), single PE, TSC-timed ->
    #     metric: cycles. Validated on WSE-3 (vs np.fft.fft, 145233 cyc). See
    #     docs/HANDWRITTEN_KERNELS.md. ---
    "DFT-1PE":             _k("DFT-1PE",              "pe.csl"),
    # --- GEMM-1PE: HAND-WRITTEN simple dense matmul (authored 2026-06-24). The
    #     leak-free TEST counterpart to the collective-SUMMA GEMM-Collectives-2D
    #     (which stays train: MeshGEMM-pattern overlap). Agent writes the dense
    #     triple-loop fmac, single PE, TSC-timed -> metric: cycles. Validated on
    #     WSE-3 (C=A@B, 119197 cyc). See docs/HANDWRITTEN_KERNELS.md. ---
    "GEMM-1PE":            _k("GEMM-1PE",             "pe.csl"),
    # --- Scientific-computing kernels ported from MatthewRHermes/mrh gpu/
    #     (quantum chemistry; added 2026-06-23). Tensor-Transpose-021 is a new
    #     single-kernel operation family (index permutation); PDFT-Pi-Pipeline
    #     is the first PROGRAM-LEVEL task (3 data-dependent stages in one file). ---
    "Tensor-Transpose-021": _k("Tensor-Transpose-021", "pe.csl"),
    "PDFT-Pi-Pipeline":     _k("PDFT-Pi-Pipeline",     "pe.csl"),
    # --- KernelBench enrichment kernels (authored 2026-07-09). Single-PE
    #     elementwise, reduction, normalization, loss, scan, and BLAS kernels
    #     covering ML-critical operation families missing from the original
    #     benchmark suite. All TSC-timed, seeded inputs, SDK 2.10 compatible. ---
    "ReLU-1PE":                _k("ReLU-1PE",                "pe.csl"),
    "Sum-Reduction-1PE":       _k("Sum-Reduction-1PE",       "pe.csl"),
    "Sigmoid-1PE":             _k("Sigmoid-1PE",             "pe.csl"),
    "Max-Reduction-1PE":       _k("Max-Reduction-1PE",       "pe.csl"),
    "RMSNorm-1PE":             _k("RMSNorm-1PE",             "pe.csl"),
    "GELU-1PE":                _k("GELU-1PE",                "pe.csl"),
    "MSE-Loss-1PE":            _k("MSE-Loss-1PE",            "pe.csl"),
    "SAXPY-1PE":               _k("SAXPY-1PE",               "pe.csl"),
    "Dot-Product-1PE":         _k("Dot-Product-1PE",         "pe.csl"),
    "Softmax-1PE":             _k("Softmax-1PE",             "pe.csl"),
    "Prefix-Sum-1PE":          _k("Prefix-Sum-1PE",          "pe.csl"),
    "SiLU-1PE":                _k("SiLU-1PE",                "pe.csl"),
    "L2-Norm-1PE":             _k("L2-Norm-1PE",             "pe.csl"),
    "Cross-Entropy-Loss-1PE":  _k("Cross-Entropy-Loss-1PE",  "pe.csl"),
    # --- Multi-PE enrichment kernels (authored 2026-07-18). Higher difficulty
    #     kernels requiring wavelet-based inter-PE communication (fabric routing,
    #     tree reduction, collective operations). ---
    "ParReduce-Sum":           _k("ParReduce-Sum",           "pe.csl"),
    "ParBroadcast-Scale":      _k("ParBroadcast-Scale",      "pe.csl"),
    "ParDot-Product":          _k("ParDot-Product",           "pe.csl"),
    "RowParallel-Softmax":     _k("RowParallel-Softmax",     "pe.csl"),
    # --- Attention tasks (expert hand-written references, added 2026-09-08) ---
    "Attention-QP":            _k("Attention-QP",            "pe.csl"),
    "Attention-1PE":           _k("Attention-1PE",           "pe.csl"),
    # --- Source subdirectory kernels (src/kernel_*.csl pattern) ---
    "7pt-Stencil":         _k("7-Point Stencil",      "src/kernel.csl"),
    "BiCGSTAB":            _k("BiCGSTAB",             "src/kernel_bicgstab.csl"),
    "CG":                  _k("Conjugate Gradient",   "src/kernel_cg.csl"),
    "Power-Method":        _k("Power Method",         "src/kernel_power.csl"),
    "Preconditioned-CG":   _k("Preconditioned CG",    "src/kernel_pcg.csl"),
    # --- Complex multi-PE-type kernels (optional, harder to translate) ---
    "Mandelbrot":          _k("Mandelbrot",            "middle.csl"),
    "FFT-1D-2D":           _k("FFT 1D-2D",            "ucode_2d.csl"),
    # --- Reference-only published kernels (registered for the agent to read
    #     the CUDA source + emit CSL into, but verification harness is the
    #     upstream's own; arch=wse2 from upstream — agentic sweeps will skip
    #     these unless the user supplies a wse3 port + run.py verifier) ---
    # Monte Carlo continuous-energy cross-section lookup
    # (Argonne, 2024; doi:10.1016/j.cpc.2024.109072; MIT license).
    "MC-Particle-Transport": {
        "cuda_path":         str(REPO_ROOT / "kernels" / "MC-Particle-Transport" / "CUDA" / "kernel.cu"),
        "reference_csl_dir": str(REPO_ROOT / "kernels" / "MC-Particle-Transport" / "CSL"),
        "target_relpath":    "device_code.csl",
        "commands_script":   "commands_wse3.sh",
        "arch":              "wse2",
    },
}


def load_text(path: str) -> str:
    with open(path, "r", encoding="utf-8") as fh:
        return fh.read()


def load_kernel_spec(reference_dir: str) -> Optional[Dict[str, object]]:
    """Load kernels/<name>/spec.yaml if present, else None.

    The spec is xkernel-bench metadata (task description, input/output shapes,
    WSE-3 reference cycles, hidden-files list for W2). See
    kernels/SPEC_SCHEMA.md. Spec is purely additive — when absent the
    framework falls back to today's reference-CSL-only contract.
    """
    spec_path = os.path.join(os.path.dirname(reference_dir.rstrip("/")), "spec.yaml")
    # reference_dir typically ends in /CSL — spec.yaml is one level up at kernel root
    if not os.path.isfile(spec_path):
        spec_path_alt = os.path.join(reference_dir, "..", "spec.yaml")
        if os.path.isfile(spec_path_alt):
            spec_path = spec_path_alt
        else:
            return None
    try:
        import yaml  # type: ignore
        with open(spec_path, "r", encoding="utf-8") as fh:
            return yaml.safe_load(fh)
    except Exception as exc:
        logging.warning("[load_kernel_spec] failed to parse %s: %s", spec_path, exc)
        return None


def resolve_sizes(spec: Optional[Dict[str, object]]) -> List[Dict[str, object]]:
    """Normalize the Phase-2 problem-size axis with back-compat.

    Returns a list of size dicts, each: {name, role, params, commands_script,
    wse3_reference:{cycles_send,time_send_us}}. If the spec has an explicit
    `sizes:` list, return it (filling commands_script default). Otherwise
    synthesize a single `default` size from the legacy top-level
    `wse3_reference`/`params`/`build_command`, so old specs keep working.
    """
    if spec and isinstance(spec.get("sizes"), list) and spec["sizes"]:
        out: List[Dict[str, object]] = []
        for s in spec["sizes"]:
            if not isinstance(s, dict):
                continue
            entry = dict(s)
            entry.setdefault("commands_script", "commands_wse3.sh")
            entry.setdefault("name", "default")
            entry.setdefault("role", "decomposition")
            out.append(entry)
        if out:
            return out
    # legacy fallback
    ref = (spec or {}).get("wse3_reference") if isinstance(spec, dict) else None
    params = ref.get("params") if isinstance(ref, dict) else None
    return [{
        "name": "default",
        "role": "correctness",
        "params": params or {},
        "commands_script": "commands_wse3.sh",
        "wse3_reference": {
            "cycles_send": (ref or {}).get("cycles_send") if isinstance(ref, dict) else None,
            "time_send_us": (ref or {}).get("time_send_us") if isinstance(ref, dict) else None,
        },
    }]


def select_size(spec: Optional[Dict[str, object]], size_name: Optional[str]) -> Dict[str, object]:
    """Pick the requested size by name; default to the first (or 'small' if
    present). Raises a clear error if a named size doesn't exist."""
    sizes = resolve_sizes(spec)
    if size_name:
        for s in sizes:
            if s.get("name") == size_name:
                return s
        raise ValueError(
            f"--size '{size_name}' not found; available: {[s.get('name') for s in sizes]}")
    for s in sizes:
        if s.get("name") == "small":
            return s
    return sizes[0]


def resolve_eval(spec: Optional[Dict[str, object]]) -> Optional[Dict[str, object]]:
    """Normalize the input-level train/test split (`eval:` block in spec.yaml).

    Returns {train_seed, heldout_seeds:[...], seed_env} or None when the spec has
    no `eval:` block (back-compat: the held-out gate then does nothing). This is
    the input-split analogue of resolve_sizes() — purely additive metadata.

    IMPORTANT (firewall): heldout_seeds are HARNESS-ONLY. They must never enter an
    agent prompt. spec.yaml is not part of build_reference_contract (the agent sees
    only run.py + layout + commands), and spec_task_summary() below renders tasks/
    inputs/outputs but NOT this block — so the values stay hidden. The leakage test
    in test_no_compute_leak.py asserts this.
    """
    if not spec or not isinstance(spec, dict):
        return None
    ev = spec.get("eval")
    if not isinstance(ev, dict):
        return None
    heldout = ev.get("heldout_seeds") or []
    if not isinstance(heldout, list):
        heldout = []
    seed_env = ev.get("seed_env") or "XKERNEL_EVAL_SEED"
    train_seed = ev.get("train_seed")
    return {
        "train_seed": train_seed,
        "heldout_seeds": [int(s) for s in heldout],
        "seed_env": str(seed_env),
    }


_VALID_METRIC_CLASSES = ("cycles", "normalized_cycles", "correctness_only")


def resolve_metric(spec: Optional[Dict[str, object]]) -> Dict[str, object]:
    """Normalize the scoring-metric CLASS for a kernel (`metric:` in spec.yaml).

    The benchmark scores agent translations primarily by cycles_send (on-device
    cycle count). But two kernel families don't fit a raw cycle number honestly:
      - library-delegated compute (e.g. 3D-FFT -> <kernels/fft>, SpMV -> hypersparse
        lib): a cycle count measures the SDK LIBRARY, not the agent's translation
        -> metric: correctness_only.
      - data-dependent / size-varying work (SpMV per-nnz, MC per-particle): a single
        raw cycle number is unstable; report cycles per work-unit
        -> metric: normalized_cycles (+ work_unit: "<expr>").
    Default is "cycles" (back-compat: absent `metric:` -> cycles). Returns
    {class, work_unit, reason}. Purely additive metadata; the harness already runs
    a correctness-only pass fine (a pass with cycles_send=None survives and
    --auto-optimize cleanly reports "no baseline target").
    """
    default = {"class": "cycles", "work_unit": None, "reason": ""}
    if not spec or not isinstance(spec, dict):
        return default
    m = spec.get("metric")
    if m is None:
        return default
    if isinstance(m, str):
        cls = m
        work_unit, reason = None, ""
    elif isinstance(m, dict):
        cls = m.get("class", "cycles")
        work_unit = m.get("work_unit")
        reason = m.get("reason", "")
    else:
        return default
    if cls not in _VALID_METRIC_CLASSES:
        logging.warning("[resolve_metric] unknown metric class %r; defaulting to 'cycles'", cls)
        cls = "cycles"
    return {"class": cls, "work_unit": work_unit, "reason": reason}


def spec_task_summary(spec: Optional[Dict[str, object]]) -> str:
    """Render a kernel spec as a short prose block for prompt injection.

    Returns "" when spec is None (the optimizer then runs without task hints —
    the current code itself is the only signal of what it's supposed to do).
    Output covers tasks + inputs + outputs but never includes the
    `wse3_reference` cycles (that's the optimizer's hidden target).
    """
    if not spec or not isinstance(spec, dict):
        return ""
    lines: List[str] = []
    tasks = spec.get("tasks") or []
    if tasks:
        lines.append("Task description:")
        for t in tasks:
            lines.append(f"  - {t}")
    inputs = spec.get("inputs") or []
    if inputs:
        lines.append("Inputs:")
        for inp in inputs:
            if isinstance(inp, dict):
                name = inp.get("name", "?")
                shape = inp.get("shape", "?")
                dtype = inp.get("dtype", "?")
                desc = inp.get("description", "")
                lines.append(f"  - {name}: {shape} {dtype} — {desc}")
    outputs = spec.get("outputs") or []
    if outputs:
        lines.append("Outputs (verified by the bundle's run.py):")
        for out in outputs:
            if isinstance(out, dict):
                name = out.get("name", "?")
                shape = out.get("shape", "?")
                dtype = out.get("dtype", "?")
                tol_abs = out.get("tolerance_abs", "—")
                tol_rel = out.get("tolerance_rel", "—")
                desc = out.get("description", "")
                lines.append(f"  - {name}: {shape} {dtype} "
                             f"(tol_abs={tol_abs}, tol_rel={tol_rel}) — {desc}")
    return "\n".join(lines).strip()


def legacy_venv_report(venv_path: str) -> Dict[str, object]:
    resolved = expand_path(venv_path)
    python_path = os.path.join(resolved, "bin", "python")
    activate_path = os.path.join(resolved, "bin", "activate")
    report = {
        "path": resolved,
        "python_path": python_path,
        "python_exists": os.path.exists(python_path),
        "activate_exists": os.path.exists(activate_path),
        "usable": False,
        "reason": "",
    }
    if not os.path.exists(python_path):
        report["reason"] = "bin/python is missing or points at a missing interpreter target."
        return report
    probe = run_subprocess(
        'source "{activate}" >/dev/null 2>&1 && command -v python && python -V'.format(
            activate=activate_path
        ),
        timeout=20,
    )
    lines = [line.strip() for line in probe.stdout.splitlines() if line.strip()]
    activated_python = lines[0] if lines else ""
    report["activated_python"] = activated_python
    report["activated_python_version"] = lines[1] if len(lines) > 1 else ""
    report["usable"] = activated_python.startswith(resolved)
    if not report["usable"]:
        report["reason"] = (
            "Activation does not place the venv interpreter on PATH; "
            "the shell stays on the system Python."
        )
    return report


def agent_env_report(api_key_file: str,
                     api_key_command: Optional[str] = None) -> Dict[str, object]:
    maybe_load_dotenv()
    packages = detect_current_python_packages(["openai", "dotenv"])
    api_key_available = False
    api_key_error = None
    try:
        api_key_available = bool(load_api_key(api_key_file, api_key_command=api_key_command))
    except Exception as exc:  # noqa: BLE001 - readiness reports should not crash.
        api_key_error = str(exc)
    identity = current_python_identity()
    micromamba_available = shutil.which("micromamba") is not None
    micromamba_env = {
        "name": DEFAULT_AGENT_ENV,
        "exists": False,
        "ready": False,
    }
    if micromamba_available:
        probe_cmd = f"""source ~/.bashrc >/dev/null 2>&1 && micromamba run -n {DEFAULT_AGENT_ENV} python -c "import importlib.util, json, sys; print(json.dumps({{'python': sys.executable, 'version': sys.version.splitlines()[0], 'openai': importlib.util.find_spec('openai') is not None, 'dotenv': importlib.util.find_spec('dotenv') is not None}}))" """
        probe = run_subprocess(
            probe_cmd,
            timeout=30,
        )
        if probe.ok:
            try:
                payload = json.loads(probe.stdout.strip())
                micromamba_env.update({
                    "exists": True,
                    "python": payload.get("python"),
                    "version": payload.get("version"),
                    "packages": {
                        "openai": bool(payload.get("openai")),
                        "dotenv": bool(payload.get("dotenv")),
                    },
                })
                micromamba_env["ready"] = (
                    all(micromamba_env["packages"].values()) and api_key_available
                )
            except json.JSONDecodeError:
                micromamba_env["probe_error"] = probe.stdout.strip() or probe.stderr.strip()
        else:
            micromamba_env["probe_error"] = probe.stderr.strip() or probe.stdout.strip()
    return {
        "python": identity,
        "micromamba_available": micromamba_available,
        "micromamba_env": micromamba_env,
        "environment_file_exists": os.path.exists(
            str(Path(__file__).resolve().parent / "environment.micromamba.yml")
        ),
        "packages": packages,
        "api_key_file": expand_path(api_key_file),
        "api_key_command": "<set>" if api_key_command else None,
        "api_key_available": api_key_available,
        "api_key_error": api_key_error,
        "ready": (all(packages.values()) or bool(micromamba_env["ready"])) and api_key_available,
    }


def sdk_report(sdk_root: str,
               shell_setup: Optional[str] = None) -> Dict[str, object]:
    resolved = expand_path(sdk_root)
    env = build_sdk_env(resolved)
    cslc_path = os.path.join(resolved, "cslc")
    cs_python_path = os.path.join(resolved, "cs_python")
    return {
        "sdk_root": resolved,
        "cslc_wrapper_exists": os.path.exists(cslc_path),
        "cs_python_wrapper_exists": os.path.exists(cs_python_path),
        "shell_setup_applied": bool(shell_setup and shell_setup.strip()),
        "cslc_launch": probe_command("cslc --help", env=env, shell_setup=shell_setup),
        "cs_python_launch": probe_command("cs_python --help", env=env, shell_setup=shell_setup),
    }


def build_env_report(api_key_file: str,
                     sdk_root: str,
                     api_key_command: Optional[str] = None,
                     base_url: Optional[str] = None,
                     model: Optional[str] = None,
                     alcf_endpoint: Optional[str] = None,
                     shell_setup: Optional[str] = None) -> Dict[str, object]:
    report = {
        "agent_python": agent_env_report(api_key_file, api_key_command=api_key_command),
        "legacy_cerebras_venv": legacy_venv_report(LEGACY_CEREBRAS_VENV),
        "sdk": sdk_report(sdk_root, shell_setup=shell_setup),
        "shell_setup": shell_setup,
        "llm": {
            "base_url": base_url,
            "model": model,
            "alcf_endpoint": alcf_endpoint,
            "api_key_source": "command" if api_key_command else "file_or_env",
        },
    }
    agent_ready = bool(report["agent_python"]["ready"])  # type: ignore[index]
    sdk_state = report["sdk"]  # type: ignore[assignment]
    sdk_ready = (
        sdk_state["cslc_launch"]["status"] == "ready"  # type: ignore[index]
        and sdk_state["cs_python_launch"]["status"] == "ready"  # type: ignore[index]
    )
    if agent_ready and sdk_ready:
        report["overall_status"] = "ready"
    elif agent_ready:
        report["overall_status"] = "partial"
    else:
        report["overall_status"] = "not_ready"
    return report


def resolve_kernel_inputs(args) -> Dict[str, str]:
    if args.cuda and args.reference_csl_dir:
        reference_dir = expand_path(args.reference_csl_dir)
        target_relpath = args.target_relpath or infer_target_relpath(reference_dir)
        return {
            "kernel_name": args.kernel or Path(args.cuda).stem,
            "cuda_path": expand_path(args.cuda),
            "reference_csl_dir": reference_dir,
            "target_relpath": target_relpath,
            "commands_script": args.commands_script or preferred_commands_script(reference_dir, args.arch),
            "arch": args.arch,
        }

    kernel_name = args.kernel or "GEMV"
    if kernel_name not in KERNEL_REGISTRY:
        raise ValueError(f"Unsupported kernel '{kernel_name}'. Available kernels: {sorted(KERNEL_REGISTRY)}")
    spec = dict(KERNEL_REGISTRY[kernel_name])
    # Phase-2 size axis: if a size is requested (or the kernel's spec.yaml
    # defines sizes), select that size's commands_script. Explicit
    # --commands-script still wins. Falls back silently when no spec/size.
    size_name = getattr(args, "size", None)
    if size_name and not args.commands_script:
        kspec = load_kernel_spec(spec["reference_csl_dir"])
        try:
            chosen = select_size(kspec, size_name)
            spec["commands_script"] = chosen.get("commands_script", spec["commands_script"])
            spec["size_name"] = chosen.get("name")
        except ValueError as exc:
            raise ValueError(f"[{kernel_name}] {exc}")
    if args.commands_script:
        spec["commands_script"] = args.commands_script
    if args.arch:
        spec["arch"] = args.arch
    spec["kernel_name"] = kernel_name
    return spec


def preferred_commands_script(reference_dir: str, arch: str) -> str:
    preferred = f"commands_{arch}.sh"
    preferred_path = os.path.join(reference_dir, preferred)
    if os.path.exists(preferred_path):
        return preferred
    generic_path = os.path.join(reference_dir, "commands.sh")
    if os.path.exists(generic_path):
        return "commands.sh"
    raise FileNotFoundError(
        f"No command script found in {reference_dir}. Expected {preferred} or commands.sh."
    )


def infer_target_relpath(reference_dir: str) -> str:
    candidates = [
        "pe.csl",
        "kernel.csl",
        "src/kernel.csl",
        "pe_program.csl",
        "residual.csl",
        "task.csl",
        "code.csl",
    ]
    for candidate in candidates:
        if os.path.exists(os.path.join(reference_dir, candidate)):
            return candidate
    raise FileNotFoundError(f"Could not infer compute target from {reference_dir}.")


def _layout_from_commands(reference_dir: str, commands_script: Optional[str]) -> Optional[str]:
    """Parse the ACTIVE build script for the layout CSL it actually compiles.

    The build invokes `cslc ./src/layout_power.csl ...` — the first positional
    `*.csl` arg on the cslc line is the file that is really compiled (and which
    @set_tile_code-includes the agent's compute file). A hardcoded name-list
    (the old _find_layout_csl) returns a STALE `layout.csl` for kernels whose
    active build uses a differently-named layout (layout_power/cg/pcg/bicgstab,
    code.csl, layout_matvec) — so the agent was shown the wrong interface
    contract and the contract validator checked exports against the wrong file
    (the v1.0 immune-kernel build-path bug, in the contract path). This resolves
    the layout from the script so it always matches the active build.
    Returns None if it can't determine it (caller falls back to the name-list).
    """
    if not commands_script:
        return None
    cmd_path = os.path.join(reference_dir, commands_script)
    if not os.path.exists(cmd_path):
        return None
    try:
        raw = load_text(cmd_path)
    except Exception:
        return None
    # Join backslash-continued lines so multi-line cslc invocations parse.
    joined = raw.replace("\\\n", " ")
    for line in joined.splitlines():
        s = line.strip()
        if not s.startswith("cslc") and " cslc " not in (" " + s):
            continue
        # First positional token ending in .csl (skip flags starting with -).
        for tok in s.split():
            if tok.startswith("-") or "=" in tok:
                continue
            cand = tok.lstrip("./")
            if cand.endswith(".csl"):
                p = os.path.join(reference_dir, cand)
                if os.path.exists(p):
                    return p
    return None


def _find_layout_csl(reference_dir: str, commands_script: Optional[str] = None) -> str:
    """Return path to the layout/config CSL file.

    Prefers the layout the ACTIVE build script (commands_script) compiles, so it
    always matches the real build. Falls back to a common-name list when the
    script can't be parsed (back-compat with callers that pass no script)."""
    from_cmd = _layout_from_commands(reference_dir, commands_script)
    if from_cmd:
        return from_cmd
    for candidate in [
        "layout.csl", "src/layout.csl",
        "code.csl",          # Wide Multiplication, Mandelbrot
        "layout_matvec.csl", # Single Tile Matvec
    ]:
        path = os.path.join(reference_dir, candidate)
        if os.path.exists(path):
            return path
    raise FileNotFoundError(f"No layout file found in {reference_dir}")


# Patterns that MUST survive run.py compression. A line is kept if any of
# these substrings appears in it. Goal: agent still sees the host-side
# protocol (which entrypoints launch, in what order, what's memcpy'd,
# how cycles_send is computed, what verification asserts).
_RUN_PY_KEEP_PATTERNS = (
    # Function / class scaffolding so the snippet is readable as Python.
    "def ", "class ",
    # The host-runner protocol.
    "simulator.launch", "simulator.memcpy_",
    "runner.launch",    "runner.memcpy_",
    # tic/toc readback path.
    "make_u48", "tsc", "time_start", "time_end", "time_ref",
    "cycles_send", "time_send",
    # Verification — the agent must know what "correct" means.
    "assert_allclose", "np.testing.assert", " assert ", "assert (",
    "SUCCESS", "FAIL",
    # Host-side collection — the agent must see how D2H reads work.
    ".collect(", "dist.collect",
    # Distribution module — the agent must see the dependency injection.
    "distribution", "distribute(", "import dist",
    # Reference launches inside timing_analysis function.
    "f_tic", "f_toc", "f_memcpy_timestamps", "f_reference_timestamps",
    "f_sync", "f_enable_timer",
)


def _compress_run_py(run_text: str, max_chars: int) -> str:
    """Trim run.py to the host-side protocol the agent needs to plug into.

    Keeps lines containing any of `_RUN_PY_KEEP_PATTERNS`; drops everything
    else (license boilerplate, command-line parsing, matrix loading,
    compile-script construction, intermediate diagnostic prints).
    The kept lines preserve original line numbers in the digest header
    so the agent can read it as "this is line N of run.py".

    If the full text is already under max_chars, returns it unchanged.
    """
    if len(run_text) <= max_chars:
        return run_text
    lines = run_text.splitlines()
    kept: List[Tuple[int, str]] = []
    for idx, raw in enumerate(lines, start=1):
        stripped = raw.strip()
        if not stripped:
            continue
        if stripped.startswith("#"):
            continue
        if any(pat in raw for pat in _RUN_PY_KEEP_PATTERNS):
            kept.append((idx, raw.rstrip()))
    body = "\n".join(f"{idx:>4}: {text}" for idx, text in kept)
    header = (
        f"# run.py compressed to the host-side protocol "
        f"(original {len(lines)} lines / {len(run_text)} chars; "
        f"kept {len(kept)} essential lines). Format: <orig_line>: <code>.\n"
        f"# The unkept lines were docstrings, argparse, compile-script\n"
        f"# construction, matrix loading, and diagnostic prints — they\n"
        f"# do not affect the host↔kernel interface your CSL must implement.\n"
    )
    digest = header + body
    # If the digest itself still exceeds max_chars, truncate body but keep
    # the trailing timing_analysis + verification lines (read tail-biased).
    if len(digest) > max_chars:
        # Reserve ~500 chars for the header, split remainder 30/70 head/tail.
        budget = max(max_chars - len(header) - 200, 500)
        head_budget = int(budget * 0.3)
        tail_budget = budget - head_budget
        body_text = body
        head = body_text[:head_budget]
        tail = body_text[-tail_budget:]
        digest = (header + head
                  + f"\n\n# ... [truncated {len(body_text) - head_budget - tail_budget} chars of digest body] ...\n\n"
                  + tail)
    return digest


def build_reference_contract(reference_dir: str,
                             target_relpath: str,
                             commands_script: str,
                             max_chars: Optional[int] = None) -> Tuple[str, str, str]:
    """Return (contract, reference_compute, layout_text).

    `contract` is the run.py + command-script bundle the agent sees as the
    launch protocol. `layout_text` is hoisted out so prompts can put it in
    its own clearly-labeled section (per Phase 2a of the post-2026-06-02
    plan); the per-kernel interface is the protocol the agent was guessing
    at when the reference compute was hidden, so giving it dedicated
    attention is the fix. `reference_compute` is returned for the contract
    validator only — it must never appear in any prompt; the
    compute-leak guard in CUDA2CSLOrchestrator enforces this.
    """
    target_path = os.path.join(reference_dir, target_relpath)
    reference_compute = load_text(target_path)
    # Resolve the layout from the ACTIVE build script so the agent sees the
    # interface contract that is really compiled (not a stale layout.csl).
    layout_text = load_text(_find_layout_csl(reference_dir, commands_script))
    run_text = load_text(os.path.join(reference_dir, "run.py"))
    commands_text = load_text(os.path.join(reference_dir, commands_script))
    # Phase 2b: when max_chars is set, compress run.py to its host-side
    # protocol digest if the assembled contract would exceed it. This is
    # what unblocks PCG/BiCGSTAB where the full reference contract hits a
    # threshold that causes the agent to emit no CSL block at all. layout
    # and commands.sh stay verbatim — they're small (~5KB + ~1KB) and
    # both are interface-critical. Only run.py is compressible.
    if max_chars is not None:
        # Rough headroom check: contract template adds ~250 chars of
        # boilerplate. If full inclusion fits, skip compression.
        full_size = len(run_text) + len(commands_text) + 300
        if full_size > max_chars:
            # Target: leave run.py at most (max_chars - commands - 300) chars.
            run_budget = max(max_chars - len(commands_text) - 300, 2000)
            digested = _compress_run_py(run_text, run_budget)
            logging.info(
                "[build_reference_contract] run.py compressed: "
                "%d -> %d chars (max_chars=%d)",
                len(run_text), len(digested), max_chars,
            )
            run_text = digested
    contract = """Target file: {target_relpath}
Reference directory: {reference_dir}

The translated compute file must remain compatible with:
- layout.csl (shown separately as its own prompt section)
- run.py
- {commands_script}

run.py:
```python
{run_text}
```

{commands_script}:
```bash
{commands_text}
```""".format(
        target_relpath=target_relpath,
        reference_dir=reference_dir,
        commands_script=commands_script,
        run_text=run_text,
        commands_text=commands_text,
    )

    # Lever 1 (2026-06-18): append the signatures of the library modules
    # layout.csl imports. The implementer is firewalled from these library
    # files and otherwise thrashes reverse-engineering their param arities from
    # cslc errors (root cause of ~50% of W1 failures — see
    # results/w1_failure_analysis_20260618.md). These are library INTERFACES
    # (param decls + one-line fn sigs), NOT the bench's reference compute, so
    # the compute-leak canary (which guards a line of THIS kernel's reference
    # pe.csl) is unaffected. Injected via the contract chokepoint so it reaches
    # both the translate prompt and every repair-prompt variant. Gate:
    # XKERNEL_LIB_SIGNATURES=0 to disable (for A/B).
    try:
        from library_signatures import library_signatures_block  # type: ignore
        # C5 fix: pass the build arch so the extractor resolves the arch-specific
        # library pe.csl (wse3/pe.csl has typed output_queues:[4]u16 / scalar
        # output_ut_id; the neutral file leaves them untyped `= {}`). Derive arch
        # from the active build-script name (commands_wse3.sh -> wse3), which the
        # agent already sees; default wse3.
        _arch = "wse2" if "wse2" in (commands_script or "") else "wse3"
        lib_block = library_signatures_block(reference_dir, layout_text, arch=_arch)
        if lib_block:
            contract = contract + "\n\n" + lib_block
    except Exception as exc:  # never let signature extraction break a run
        logging.warning("[build_reference_contract] library_signatures skipped: %s",
                        str(exc)[:200])
    return contract, reference_compute, layout_text


def benchmark_summary_text(result: Dict[str, object]) -> str:
    return json.dumps(
        {
            "status": result.get("status"),
            "failure_reason": result.get("failure_reason"),
            "compile_time_ms": result.get("compile_time_ms"),
            "run_time_ms": result.get("run_time_ms"),
            "success_marker": result.get("success_marker"),
        },
        indent=2,
    )


def _profiling_context_from_profile(profile: Dict[str, object]) -> Dict[str, object]:
    """Compact, JSON-safe summary of one benchmark's profile for step records."""
    ctx: Dict[str, object] = {}
    arts = (profile or {}).get("artifacts") or {}
    slp = arts.get("sim_log_parsed")
    if slp:
        ctx["sim_log_bottleneck"] = slp.get("bottleneck_label")
        ctx["stall_ratio"] = slp.get("stall_ratio")
        ctx["wavelet_density"] = slp.get("wavelet_density")
    tp = arts.get("trace_profile")
    if tp:
        ctx["trace_bottleneck"] = tp.get("bottleneck")
        ctx["trace_reason"] = tp.get("bottleneck_reason")
        ctx["pe_util_mean"] = (tp.get("util_stats") or {}).get("mean")
        ctx["pe_util_min"] = (tp.get("util_stats") or {}).get("min")
        ctx["pe_util_max"] = (tp.get("util_stats") or {}).get("max")
        ctx["congested_count"] = tp.get("congested_count")
    mem = arts.get("memory_profile")
    if mem:
        ctx["sram_utilization"] = mem.get("utilization")
    mr = arts.get("model_readout")
    if mr:
        for key in ("bottleneck", "ipc", "float_pct", "elements_per_dispatch", "f16_arith_pct",
                    "roofline_fraction_f16", "distinct_ut_ids", "turns", "pct_of_bound",
                    "predicted_cycles"):
            if mr.get(key) is not None:
                ctx[f"model_{key}"] = mr.get(key)
        ctx["model_keys"] = list(mr.get("model_keys") or [])
    return ctx



class CUDA2CSLOrchestrator:
    def __init__(self,
                 model: str,
                 api_key_file: str,
                 api_key_command: Optional[str],
                 base_url: Optional[str],
                 max_tokens: int,
                 turns_limit: int,
                 work_root: str,
                 sdk_root: str,
                 arch: str,
                 commands_script: str,
                 shell_setup: Optional[str],
                 analysis_model: Optional[str] = None,
                 target_sdk: str = "1.4.0",
                 profile_feedback_enabled: bool = False,
                 keep_profile_bundles: bool = False,
                 skip_analyse: bool = False,
                 skip_planner: bool = False,
                 skip_reviewer: bool = False,
                 reviewer_max_attempts: int = 10,
                 num_runs: int = 1,
                 optimize_num_runs: int = 3):
        self.model = model
        self.api_key_file = api_key_file
        self.api_key_command = api_key_command
        self.base_url = base_url
        self.max_tokens = max_tokens
        self.turns_limit = turns_limit
        self.work_root = ensure_directory(work_root)
        self.sdk_root = sdk_root
        # Model-guided optimization (IPDPS 2027 study). XKERNEL_MODEL_GUIDED=1
        # feeds the silicon-model readout of the CURRENT BEST candidate into the
        # angle selector and the optimizer prompt; XKERNEL_MODEL_ANGLES (default:
        # same value) adds the model-derived angles to the whitelist. Both are
        # off by default, so the O0 baseline keeps the previous behaviour.
        self.model_guided = os.environ.get("XKERNEL_MODEL_GUIDED", "0") == "1"
        self.model_angles = os.environ.get(
            "XKERNEL_MODEL_ANGLES", "1" if self.model_guided else "0") == "1"
        # Candidate retention for hardware-in-the-loop replay (O2) and the
        # fidelity study: keep the code + simulator result of EVERY benchmarked
        # optimizer candidate (accepted or not) and write them under
        # <kernel_output_dir>/candidates/. XKERNEL_HW_CONFIRM=batch implies it.
        self.keep_candidates = (os.environ.get("XKERNEL_KEEP_CANDIDATES", "0") == "1"
                                or os.environ.get("XKERNEL_HW_CONFIRM", "") == "batch")
        self.retained_candidates: List[Dict[str, object]] = []
        self.arch = arch
        self.commands_script = commands_script
        self.shell_setup = shell_setup
        self.analysis_model = analysis_model or model   # CUDAForge: per-phase LLM
        self.skip_analyse = skip_analyse  # one-shot baseline: bypass analyse_cuda LLM call
        self.kernel_group = ""  # WS4.1: set by main() from spec.group; steers for_implementer opt-hints
        self.skip_planner = skip_planner  # bypass mesh-decomposition planner
        self.skip_reviewer = skip_reviewer  # bypass reviewer agent; legacy fix-prompt path
        self.reviewer_max_attempts = reviewer_max_attempts  # attempt cap when reviewer active
        # Phase 1a variance-reduction knobs:
        # - num_runs is for ad-hoc translate-loop benchmarks (default 1
        #   preserves pre-Phase-1a behavior exactly).
        # - optimize_num_runs is the cycle-comparison sample size inside
        #   optimize() — default 3, taking the median to kill the ~20-30%
        #   simulator noise. Setting to 1 reverts to the old single-sample
        #   accept rule.
        self.num_runs = max(1, int(num_runs))
        self.optimize_num_runs = max(1, int(optimize_num_runs))
        # Phase 1b: best-of-N — at each optimizer attempt, generate N
        # independent candidates and keep the one with lowest median cycles
        # that also passes the contract gate. Sequential v1 (simulator is
        # the bottleneck anyway). Default 1 = pre-Phase-1b behavior.
        self.best_of = 1
        self.architect_respin_count = 0  # bumped on each bucket-A verdict
        # Default cap = 2; env override (XKERNEL_FORCE_RESPIN_CAP) lets the A/B
        # harness compare "reviewer with no respins" against "reviewer + respins"
        # without code changes.
        self.MAX_ARCHITECT_RESPINS = int(os.getenv("XKERNEL_FORCE_RESPIN_CAP", "2"))
        # Debugger sub-agent: per-kernel fire counter + last-attempt failure
        # reason cache (used by debugger_agent.should_fire to detect repeats).
        self.debugger_fires_used = 0
        self._previous_failure_reason: Optional[str] = None
        self._kernel_dir_for_debugger: Optional[str] = None  # set in repair_loop
        self.target_sdk = target_sdk
        self.profile_feedback_enabled = profile_feedback_enabled
        self.keep_profile_bundles = keep_profile_bundles
        self.messages: List[Dict[str, str]] = []
        self.history: List[Dict[str, str]] = []
        self.current_code: Optional[str] = None
        self.cuda_analysis: Optional[str] = None
        self.decomposition_plan: Optional[str] = None
        self.run_log: List[Dict[str, object]] = []
        self.profile_log: List[Dict[str, object]] = []
        self.latest_profiler_feedback: str = "(profiler feedback not collected)"
        self._client = None
        self._exp_store = ExperienceStore()
        self._last_benchmark: Optional[Dict] = None  # tracks baseline_ms for experience recording
        # Canary line from the reference compute CSL. Set once per kernel by
        # _set_compute_canary(); _llm_call asserts no outgoing message contains
        # it. This makes the "layout visible, compute hidden" invariant
        # tested rather than merely documented. None disables the check (used
        # by callers that legitimately have no reference compute, e.g. unit
        # tests of unrelated helpers).
        self._compute_canary: Optional[str] = None
        self._compute_canary_kernel: Optional[str] = None
        # W2 (--optimize-only) legitimately feeds the input CSL into the
        # optimizer prompt (labeled "current code at N cycles") — the
        # canary would false-positive on every prompt. main() sets this
        # to True when entering --optimize-only mode. The contract
        # validator (validate_contract) is the second layer that catches
        # gaming attempts regardless of this flag.
        self._w2_disarm_compute_canary: bool = False
        # Co-design mode (XKERNEL_CODESIGN_LAYOUT=1): the agent authors BOTH the
        # compute file AND layout.csl from scratch. In that mode the reference
        # layout is hidden + canaried (so it can't be regurgitated), and the
        # agent's layout is overlaid onto the staged bundle at benchmark time.
        self.codesign_layout: bool = os.getenv("XKERNEL_CODESIGN_LAYOUT", "0") == "1"
        self._layout_canary: Optional[str] = None
        self._layout_canary_kernel: Optional[str] = None
        # Extra agent-authored files (bundle-relative path -> body) overlaid onto
        # the staged bundle in _benchmark_current_code. Empty in the default path.
        self._agent_extra_files: Optional[Dict[str, str]] = None

    def _append(self, role: str, content: str) -> None:
        message = {"role": role, "content": content}
        self.messages.append(message)
        self.history.append(message)

    def _client_or_raise(self):
        if self._client is None:
            if is_anthropic_model(self.model):
                self._client = create_anthropic_client(
                    api_key_file=self.api_key_file,
                    api_key_command=self.api_key_command,
                )
            else:
                self._client = create_openai_client(
                    api_key_file=self.api_key_file,
                    base_url=self.base_url,
                    api_key_command=self.api_key_command,
                )
        return self._client

    @staticmethod
    def _profile_bottleneck_signature(csl_code: str,
                                      sibling_csl: Optional[str] = None) -> Dict[str, object]:
        """Task #24: static-analysis profiler. Scan a CSL compute file for
        structural patterns that indicate specific bottlenecks. Returns
        a dict {bottleneck_name: evidence_hits}.

        For split-file kernels (Power-Method, CG, PCG) where the agent's
        target is the helper file (e.g. kernel_power.csl) but the
        @export_symbol block lives in the entrypoint file (kernel.csl),
        pass the entrypoint file via `sibling_csl`. Patterns that count
        cross-file evidence (e.g. many_launch_dispatched_fns counting
        exported f_*) consult sibling_csl too. The target file is still
        the primary subject.

        Deterministic, fast (~1ms), no LLM call. The matcher consumes this
        dict to rank angles whose `applicable_bottlenecks` intersect the
        detected set. When the kernel exhibits no clear bottleneck (e.g.
        already well-optimized), the dict is empty and the selector falls
        back to free-form reasoning over the whole whitelist — the user's
        "widen the search" path, rather than firing in the dark.

        v1 detection covers:
          - dsd_rebuild_in_loop: @get_dsd inside a `for` block
          - scalar_loops_over_arrays: indexed array writes inside a loop
            without nearby @fmacs/@fadds/@map
          - runtime_size_in_inner_loop: @as(i16, PARAM) cast inside a loop
          - polling_async: while-loop checking a flag, or busy-wait
          - sync_fabric_ops: @mov*/@fmac* with fabric DSDs and NO .async
          - circular_buffer_manual: pointer math (& foo[...]) in stencil
            patterns, with no .save_address use
          - large_runtime_table: var T = build_*() patterns
          - separate_mul_then_add: @fmuls followed by @fadds (two ops where
            one @fmacs would do)
          - var_used_where_param_works: top-level `var SIZE: i16` that
            could be `param SIZE: i16` (heuristic: matches a top-level var
            whose name is uppercase, conventionally params)

        v1 deliberately does NOT detect bad_stride_hint, narrow_simd_use,
        microthread_collision_hint — those need access to dimension
        values + arch knowledge the profiler doesn't have yet. They're in
        the catalog for future per-fn-timing/profile expansion."""
        sig: Dict[str, int] = {}

        def _bump(key: str, n: int = 1) -> None:
            sig[key] = sig.get(key, 0) + n

        # Strip comments to reduce false positives.
        nocomment = re.sub(r"//[^\n]*", "", csl_code)

        # Identify `for` blocks: track brace depth from each `for (...)`.
        # CSL syntax: `for (@range(i16, N)) |i| {` — the parens are nested
        # so a non-greedy [^)]* regex won't match. Use a paren-balanced
        # walker for the `for (...)` head, then look for `|var| {` after
        # it, then brace-balance for the body.
        for_blocks: List[str] = []
        i = 0
        while i < len(nocomment):
            m = re.search(r"\bfor\s*\(", nocomment[i:])
            if not m:
                break
            head_start = i + m.end() - 1  # position of opening (
            # Paren-balance walk for the for-head.
            depth = 1
            k = head_start + 1
            while k < len(nocomment) and depth > 0:
                c = nocomment[k]
                if c == "(":
                    depth += 1
                elif c == ")":
                    depth -= 1
                k += 1
            head_end = k  # past the closing )
            # Now look for the |var| binding and opening brace.
            tail_m = re.match(r"\s*\|[^|]*\|\s*\{", nocomment[head_end:])
            if not tail_m:
                # Not a for-loop body; skip past this `for` token.
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
        n_get_dsd_in_loop = len(re.findall(r"@get_dsd\s*\(", loop_text))
        if n_get_dsd_in_loop > 0:
            _bump("dsd_rebuild_in_loop", n_get_dsd_in_loop)

        # runtime_size_in_inner_loop — @as(i16, X) where X looks comptime
        n_as_in_loop = len(re.findall(r"@as\s*\(\s*[iuf]16\s*,\s*[A-Z_][A-Z0-9_]*\s*\)", loop_text))
        if n_as_in_loop > 0:
            _bump("runtime_size_in_inner_loop", n_as_in_loop)
        # also tag as redundant_at_cast for comptime_hoist
        if n_as_in_loop > 0:
            _bump("redundant_at_cast", n_as_in_loop)

        # scalar_loops_over_arrays: loop body has indexed write `var[i] = ...`
        # AND no @fmacs/@fadds/@map in the same loop body.
        for body in for_blocks:
            has_scalar_write = bool(re.search(r"\b[A-Za-z_][A-Za-z0-9_]*\s*\[[^\]]+\]\s*=", body))
            has_bulk_op = bool(re.search(r"@fmac[sh]|@fadd[sh]|@fmov[sh]|@map\b", body))
            if has_scalar_write and not has_bulk_op:
                _bump("scalar_loops_over_arrays")

        # polling_async — while-loops over a flag
        n_busy_wait = len(re.findall(r"\bwhile\s*\(\s*!\s*[A-Za-z_]", nocomment))
        n_busy_wait += len(re.findall(r"\bwhile\s*\(\s*[A-Za-z_][A-Za-z0-9_]*\s*==\s*(?:false|0)\b", nocomment))
        if n_busy_wait > 0:
            _bump("polling_async", n_busy_wait)

        # sync_fabric_ops — fabin_dsd/fabout_dsd used in op without .async
        # heuristic: find fab*_dsd identifier, find the @mov/fmac call using it,
        # check for ".async" in the same statement.
        fab_dsds = set(re.findall(r"\b([A-Za-z_][A-Za-z0-9_]*)\s*=\s*@get_dsd\s*\(\s*fab(?:in|out)_dsd", nocomment))
        sync_fab = 0
        for dsd in fab_dsds:
            for m in re.finditer(
                rf"@(?:mov\w+|fmac\w+|fadd\w+|fmov\w+)\s*\([^)]*\b{re.escape(dsd)}\b[^)]*\)",
                nocomment,
            ):
                if ".async" not in m.group(0):
                    sync_fab += 1
        if sync_fab > 0:
            _bump("sync_fabric_ops", sync_fab)
            _bump("serialized_compute_and_comm", sync_fab)

        # separate_mul_then_add — @fmuls immediately followed by @fadds
        n_pairs = len(re.findall(
            r"@fmul[sh]\s*\([^)]*\)\s*;\s*@fadd[sh]\s*\(",
            nocomment,
            re.DOTALL,
        ))
        if n_pairs > 0:
            _bump("separate_mul_then_add", n_pairs)

        # large_runtime_table — `var X = build_table_*()` or runtime size N
        n_runtime_init = len(re.findall(
            r"\bvar\s+[A-Za-z_][A-Za-z0-9_]*\s*=\s*[A-Za-z_][A-Za-z0-9_]*\s*\(",
            nocomment,
        ))
        # heuristic threshold — only flag if there are multiple
        if n_runtime_init >= 3:
            _bump("large_runtime_table", n_runtime_init)

        # circular_buffer_manual — pointer math `&foo[i*N]` repeatedly in
        # what looks like a stencil/sliding-window context.
        n_ptr_math = len(re.findall(r"&\s*[A-Za-z_][A-Za-z0-9_]*\s*\[[^\]]+\*[^\]]+\]", nocomment))
        has_save_address = "save_address" in nocomment
        if n_ptr_math >= 2 and not has_save_address:
            _bump("circular_buffer_manual", n_ptr_math)

        # var_used_where_param_works — top-level var with uppercase name
        # (convention for params/constants). Looser heuristic.
        n_upper_var = len(re.findall(r"^\s*var\s+([A-Z_][A-Z0-9_]{2,})\s*:", nocomment, re.MULTILINE))
        if n_upper_var > 0:
            _bump("var_used_where_param_works", n_upper_var)

        # unexplored_comptime_config — imported modules that pass a
        # @concat_structs(...) or anonymous struct as comptime params. Each
        # such import is a tunable surface: the struct's fields can often
        # be set to different internal values without changing the external
        # contract. The historical 7pt-Stencil 1076-cycle win was exactly
        # this — `.BLOCK_SIZE = MAX_ZDIM` inside the stencil_mod import.
        n_import_with_struct = len(re.findall(
            r'@import_module\s*\(\s*"[^"]+"\s*,\s*@?(?:concat_structs|\{|\.\{)',
            nocomment,
        ))
        if n_import_with_struct > 0:
            _bump("unexplored_comptime_config", n_import_with_struct)

        # many_launch_dispatched_fns — kernels that export ≥4 workload-
        # phase f_* entrypoints (excluding the 6 infrastructure fns
        # f_tic/f_toc/f_memcpy_timestamps/f_reference_timestamps/f_sync/
        # f_enable_timer). Each exported phase = one host launch per call,
        # ~10-20 cycles dispatch overhead + a fabric barrier. Iterative
        # solvers (CG/PCG/BiCGSTAB/Power-Method) all hit this — BiCGSTAB
        # exports 11 workload entrypoints. The iterative_phase_fusion
        # angle targets reducing launch count by chaining phases via
        # device-side task activation.
        # For split-file kernels, scan BOTH target and sibling so that
        # f_* exported in kernel.csl but defined as forward decls in
        # kernel_*.csl get counted. The union is what host-side run.py
        # can actually launch.
        _INFRASTRUCTURE_FNS = {
            "f_tic", "f_toc", "f_memcpy_timestamps", "f_reference_timestamps",
            "f_sync", "f_enable_timer",
        }
        export_scan_text = nocomment
        if sibling_csl:
            sibling_nocomment = re.sub(r"//[^\n]*", "", sibling_csl)
            export_scan_text = export_scan_text + "\n" + sibling_nocomment
        exported_fns = set(re.findall(
            r"@export_symbol\s*\(\s*(f_[A-Za-z0-9_]+)",
            export_scan_text,
        ))
        workload_fns = exported_fns - _INFRASTRUCTURE_FNS
        if len(workload_fns) >= 4:
            # bump by count so the matcher score scales with severity
            _bump("many_launch_dispatched_fns", len(workload_fns))

        return {
            "bottlenecks": sig,
            "n_for_loops": len(for_blocks),
            "code_chars": len(csl_code),
        }

    @staticmethod
    def _match_angles_to_bottlenecks(whitelist: List[str],
                                     signature: Dict[str, object]) -> List[Tuple[str, int]]:
        """Score each angle in the whitelist by how many of its
        `applicable_bottlenecks` intersect the detected signature, weighted
        by hit count. Returns [(angle_name, score)] sorted descending.
        Angles with zero matches are excluded (the selector falls back to
        free-form reasoning for those — the "widen the search" path)."""
        detected = signature.get("bottlenecks") or {}
        if not detected:
            return []
        scored: List[Tuple[str, int]] = []
        for name in whitelist:
            meta = angle_metadata(name)
            applicable = meta.get("applicable_bottlenecks", []) or []
            score = sum(int(detected.get(b, 0)) for b in applicable)
            if score > 0:
                scored.append((name, score))
        scored.sort(key=lambda t: -t[1])
        return scored

    def _set_compute_canary(self, reference_compute_file: Optional[str],
                            kernel_name: Optional[str] = None) -> None:
        """Stash a distinctive line from the reference compute CSL so
        _llm_call can assert it never leaks into a prompt.

        Prefers a `fn` declaration (function names are the most distinctive
        per-kernel artefact, least likely to false-positive against other
        reference material). Falls back to any non-comment, non-import line
        ≥40 chars long. Returns None silently if no suitable line exists.
        """
        if not reference_compute_file:
            self._compute_canary = None
            self._compute_canary_kernel = None
            return

        def _is_skippable(line: str) -> bool:
            if not line or line.startswith("//"):
                return True
            # Skip imports — the agent legitimately sees these in layout.csl
            # and other reference material, so they're not useful as a canary.
            if "@import_module" in line:
                return True
            return False

        canary = None
        # Strong canary requirement: the line must contain CSL-specific
        # syntax (a @builtin call) that would NOT appear in a CUDA source
        # file's comments or in unrelated reference material. Prevents
        # false-positives on:
        #   - CUDA comments that reference CSL function names (e.g. a CUDA
        #     stub kernel.cu mentioning "@map(gemv_static_step_A, x_dsd)")
        #   - layout.csl which has its own @get_color / @import_module calls
        # The canary is most useful when it's a statement only the
        # reference compute file could produce.
        _CSL_SIGNAL_BUILTINS = (
            "@fmacs", "@fadds", "@fmuls", "@fmach", "@faddh", "@fmovh",
            "@mov32", "@mov16", "@fmov",
            "@increment_dsd_offset", "@set_dsd_base_addr", "@set_dsd_length",
            "@load_to_dsr", "@map",
        )

        def _has_csl_signal(line: str) -> bool:
            return any(b in line for b in _CSL_SIGNAL_BUILTINS)

        # Pass 1: prefer a function body line that contains a CSL signal
        # builtin (these are the strongest "this is real CSL compute" markers).
        for raw in reference_compute_file.splitlines():
            line = raw.strip()
            if _is_skippable(line):
                continue
            if len(line) >= 30 and _has_csl_signal(line):
                canary = line
                break
        # Pass 2: fall back to a `fn` declaration whose name is sufficiently
        # distinctive (≥3 underscores or ≥15 chars after "fn "). Skip names
        # that match frozen infrastructure fns.
        if canary is None:
            for raw in reference_compute_file.splitlines():
                line = raw.strip()
                if _is_skippable(line):
                    continue
                if line.startswith("fn ") and len(line) >= 30:
                    if any(line.startswith(f"fn {fn}(") for fn in
                           ("f_tic", "f_toc", "f_memcpy_timestamps",
                            "f_reference_timestamps", "f_sync", "f_enable_timer")):
                        continue
                    # Require the fn name to be distinctive — more than just
                    # a common prefix like f_spmv that any solver might use.
                    fn_name = line[3:].split("(", 1)[0].strip()
                    if len(fn_name) >= 12 or fn_name.count("_") >= 2:
                        canary = line
                        break
        # Pass 3: any sufficiently long line containing an `@` builtin
        # (any builtin, not just the signal list — `@get_dsd`, `@bind_*`,
        # `@activate`, `@bitcast` all count). The `@` requirement still
        # protects against CUDA-source false-positives.
        if canary is None:
            for raw in reference_compute_file.splitlines():
                line = raw.strip()
                if _is_skippable(line):
                    continue
                if len(line) >= 40 and "@" in line:
                    canary = line
                    break
        if canary is None:
            logging.warning(
                "[cuda2csl] could not extract compute-leak canary from "
                "reference (kernel=%s); compute-hidden invariant unenforced",
                kernel_name,
            )
        self._compute_canary = canary
        self._compute_canary_kernel = kernel_name

    def _set_layout_canary(self, reference_layout_text: Optional[str],
                           kernel_name: Optional[str] = None) -> None:
        """Co-design mode (XKERNEL_CODESIGN_LAYOUT): when the agent authors
        layout.csl from scratch, the reference layout must ALSO be hidden +
        canaried so the agent can't regurgitate the reference routing. Picks a
        distinctive routing line — preferring @set_color_config / switch /
        pop_on_advance / @set_tile_code (the routing the agent must invent),
        else any long `@`-builtin line. Off (None) in the default path."""
        self._layout_canary = None
        self._layout_canary_kernel = kernel_name
        if not reference_layout_text:
            return
        # @set_tile_code excluded: it's too generic — any co-designed layout
        # legitimately uses it with the same target filename. Prefer routing-
        # specific lines that carry reference-distinctive parameter values.
        _LAYOUT_SIGNALS = ("@set_color_config", "pop_on_advance",
                           ".switches", ".routes")
        for raw in reference_layout_text.splitlines():
            line = raw.strip()
            if not line or line.startswith("//") or "@import_module" in line:
                continue
            if len(line) >= 30 and any(s in line for s in _LAYOUT_SIGNALS):
                self._layout_canary = line
                return
        # fallback: any long @-builtin line
        for raw in reference_layout_text.splitlines():
            line = raw.strip()
            if not line or line.startswith("//") or "@import_module" in line:
                continue
            if len(line) >= 40 and "@" in line:
                self._layout_canary = line
                return
        logging.warning("[cuda2csl] could not extract layout canary (kernel=%s); "
                        "layout-hidden invariant unenforced in co-design mode", kernel_name)

    def _assert_no_compute_leak(self, messages: List[Dict[str, str]]) -> None:
        """Raise AssertionError if any message contains the canary line from
        the reference compute CSL. This is the enforcement mechanism for the
        "layout visible, compute hidden" benchmark invariant — without it,
        an accidental refactor could leak the reference into prompts and the
        agent's "translation" would silently become "regurgitation".

        Disarmed in W2 mode (--optimize-only) where the input CSL legitimately
        IS the reference compute (relabeled as "current code") — that's the
        explicit W2 contract per REPIVOT_CYCLES.md."""
        if self._w2_disarm_compute_canary:
            return
        # (canary_string, kind) pairs to enforce. The compute canary is always
        # active; the layout canary is added only in co-design mode where the
        # agent authors layout.csl and the reference layout must stay hidden.
        canaries = []
        if self._compute_canary:
            # Template-gen mode: if the canary line is generic boilerplate
            # that also appears in the template, it's a false positive — the
            # template is not the reference compute, it's shared scaffolding.
            canary_in_template = False
            if os.getenv("XKERNEL_TEMPLATE_GEN", "0") == "1":
                tpl_name = getattr(self, "_active_template_name", None)
                if tpl_name:
                    try:
                        tpl_text = _get_template(tpl_name)
                        canary_in_template = self._compute_canary in tpl_text
                    except Exception:
                        pass
            if not canary_in_template:
                canaries.append((self._compute_canary, "compute", self._compute_canary_kernel))
        if getattr(self, "_layout_canary", None):
            canaries.append((self._layout_canary, "layout", self._layout_canary_kernel))
        if not canaries:
            return
        for msg in messages:
            # Only guard against leaks via SYSTEM/USER roles — the prompts
            # WE send to the model. ASSISTANT messages are the agent's own
            # prior replies; if the agent independently produced a line
            # matching the reference (common: short fn signatures, task IDs)
            # that's not a leak, it's convergent generation. The guard
            # would false-positive on every W1 repair-loop turn otherwise.
            if msg.get("role") not in ("system", "user"):
                continue
            content = msg.get("content", "")
            if not isinstance(content, str):
                continue
            for canary, kind, kern in canaries:
                if canary in content:
                    raise AssertionError(
                        f"[{kind}-leak guard] reference {kind} CSL canary detected "
                        f"in outgoing prompt (kernel={kern}, role={msg.get('role')}). "
                        f"The benchmark contract hides the reference {kind} file — "
                        f"refactor that introduced this must be fixed before "
                        f"continuing. Canary: {canary[:80]!r}"
                    )

    def _llm_call(self, messages: List[Dict[str, str]], max_tokens: Optional[int] = None) -> str:
        self._assert_no_compute_leak(messages)
        # Phase 2b diagnostic: surface prompt size so threshold tuning has
        # real data. DEBUG-level so it doesn't spam the default log.
        total_chars = sum(len(m.get("content", "") or "")
                          for m in messages if isinstance(m.get("content"), str))
        logging.debug("[cuda2csl] _llm_call total_chars=%d msgs=%d",
                      total_chars, len(messages))
        client = self._client_or_raise()
        return llm_complete(client, self.model, messages, max_tokens or self.max_tokens)

    def _llm_call_with_trim_on_overflow(self, cuda_code: str) -> str:
        """Call the implementer on self.messages. On context-window overflow,
        trim the conversation history (keep system + analysis + just the most
        recent user prompt) and retry once. Preserves the current repair
        attempt's prompt; drops earlier failed-attempt history."""
        try:
            return self._llm_call(self.messages)
        except Exception as exc:
            msg = str(exc).lower()
            is_ctx_overflow = (
                "context length" in msg
                or "maximum context" in msg
                or "input length" in msg and "exceeds" in msg
                or "context_length_exceeded" in msg
            )
            if not is_ctx_overflow or len(self.messages) < 3:
                raise
            # Last entry must be the user fix-prompt we just appended.
            last_user = self.messages[-1]
            if last_user.get("role") != "user":
                raise
            logging.warning(
                "[cuda2csl] context overflow during repair (%s); trimming history "
                "and retrying the current fix prompt against the clean thread",
                str(exc)[:160],
            )
            trimmed: List[Dict[str, str]] = []
            trimmed.append({"role": "system", "content": Instruction_system_cuda_to_csl})
            if self.cuda_analysis and not self.skip_analyse:
                trimmed.append({"role": "user", "content": q_analyse_cuda_source.format(cuda_code=cuda_code)})
                trimmed.append({"role": "assistant", "content": self.cuda_analysis})
            trimmed.append(last_user)
            self.messages = trimmed
            return self._llm_call(self.messages)

    def analyse_cuda(self, cuda_code: str) -> str:
        self._append("system", Instruction_system_cuda_to_csl)
        prompt = q_analyse_cuda_source.format(cuda_code=cuda_code)
        self._append("user", prompt)
        # CUDAForge pattern: use cheaper analysis_model for semantic analysis phase
        if self.analysis_model != self.model:
            self._assert_no_compute_leak(self.messages)
            client = self._client_or_raise()
            reply = llm_complete(client, self.analysis_model, self.messages,
                                 min(self.max_tokens, 2048))
        else:
            reply = self._llm_call(self.messages, max_tokens=min(self.max_tokens, 2048))
        self._append("assistant", reply)
        self.cuda_analysis = reply
        return reply

    def design_architecture(self,
                            cuda_code: str,
                            target_relpath: str,
                            reference_contract: str,
                            layout_text: str = "",
                            failure_context: Optional[str] = None) -> str:
        """ARCHITECT phase: produce a DESIGN.md memo before any CSL is written.

        Uses the architect-lens knowledge context (memory budgets, decomposition
        taxonomy, mesh-pattern catalog) — NOT the implementer-lens syntax rules.
        The architect's deliverable is free-form markdown describing layout,
        compute steps, memory budget, bandwidth, collective choice, patterns,
        edge cases, and trade-offs. The implementer reads this as a directive
        (with permission to amend if the contract makes it infeasible).

        On architect re-spin (triggered by a reviewer's bucket-A verdict), the
        caller passes `failure_context` describing what went wrong with the
        previous design. The architect must amend its design to address that.
        """
        knowledge = csl_knowledge_base.for_architect(
            "\n".join([target_relpath, cuda_code, self.cuda_analysis or ""])
        )
        prompt = q_design_architecture.format(
            knowledge_base=knowledge,
            layout_text=layout_text or "(layout.csl not provided to this design call)",
            reference_contract=reference_contract,
            cuda_analysis=self.cuda_analysis or "(no analysis available)",
            cuda_code=cuda_code,
        )
        if failure_context:
            prompt += (
                "\n\n## Prior design failed; amend with this context\n"
                + failure_context.strip()
                + "\n\nProduce a REVISED DESIGN.md that addresses this failure. "
                  "In section 8 (trade-offs), explain what you changed vs the "
                  "prior design and why."
            )
        # Architect runs in a SEPARATE conversation thread — the memo gets
        # threaded into the implementer prompt as a single block, but the
        # design reasoning does not pollute self.messages (which is the
        # implementer's history).
        architect_messages = [
            {"role": "system", "content": Instruction_system_cuda_to_csl},
            {"role": "user", "content": prompt},
        ]
        # 3072 tokens: reasoning-style models (gpt-oss-120b, o-series) burn
        # most of their budget on hidden reasoning. 1024 was too tight —
        # observed `finish_reason=length` with empty content and the entire
        # memo sitting in `.reasoning`. Free-form prose also benefits from
        # more headroom than the old JSON schema needed.
        budget = min(self.max_tokens, 3072)
        self._assert_no_compute_leak(architect_messages)
        reply = llm_complete(self._client_or_raise(), self.model,
                             architect_messages, budget)
        if not reply or not reply.strip():
            reply = ("(architect returned empty content — likely a reasoning "
                     "model that exceeded its token budget. Implement the "
                     "kernel directly from the patterns catalog and contract.)")

        if os.getenv("XKERNEL_DESIGN_SCHEMA", "0") == "1" and layout_text:
            augmented, vr = _validate_design(reply, layout_text)
            if not vr.ok:
                logging.warning("[architect] design validation failed: %s", vr.errors)
                architect_messages.append({"role": "assistant", "content": reply})
                architect_messages.append({"role": "user", "content": (
                    "Your design has validation errors that must be fixed:\n"
                    + "\n".join(f"- {e}" for e in vr.errors)
                    + "\n\nProduce a corrected DESIGN.md."
                )})
                self._assert_no_compute_leak(architect_messages)
                reply2 = llm_complete(self._client_or_raise(), self.model,
                                      architect_messages, budget)
                if reply2 and reply2.strip():
                    augmented2, vr2 = _validate_design(reply2, layout_text)
                    reply = augmented2
                    if not vr2.ok:
                        logging.warning("[architect] design validation still failing after respin: %s", vr2.errors)
                else:
                    reply = augmented
            else:
                reply = augmented

        if os.getenv("XKERNEL_WIRING_PLAN", "0") == "1" and layout_text:
            try:
                wp = _parse_wiring_plan(reply, layout_text)
                ref_dir = getattr(self, "_kernel_dir_for_debugger", None)
                if ref_dir:
                    try:
                        facts = _extract_layout_facts(ref_dir)
                        wp = _merge_wiring_facts(wp, facts)
                    except Exception:
                        pass
                lc = _parse_layout_contract(layout_text)
                vr_wp = _validate_wiring_plan(wp, lc)
                if vr_wp.errors:
                    logging.warning("[wiring_plan] validation errors: %s", vr_wp.errors)
                wp_block = _format_wiring_plan(wp)
                reply = reply + "\n\n" + wp_block + "\n"
                self._wiring_plan = wp
            except Exception as exc:
                logging.warning("[wiring_plan] parse/validate failed: %s", exc)
                self._wiring_plan = None
        else:
            self._wiring_plan = None

        self.decomposition_plan = reply
        return reply

    def review_failure(self,
                       current_code: str,
                       benchmark: Dict[str, object],
                       reference_contract: str) -> Dict[str, object]:
        """REVIEWER phase: classify a failed benchmark into bucket A/B/C.

        Runs in its own conversation thread (mirrors the architect pattern in
        :meth:`design_architecture` — never appends to self.messages). Returns
        a dict with keys: bucket (str in {A,B,C}), rationale (str),
        design_amendment (Optional[str]), raw (the model's full reply).

        On any LLM error or parse failure, defaults to bucket B (the historical
        always-route-to-implementer behaviour) so the loop never blocks.
        """
        knowledge = csl_knowledge_base.for_reviewer(
            "\n".join([str(benchmark.get("failure_reason") or ""),
                       self.decomposition_plan or ""])
        )
        prompt = q_review_failure.format(
            knowledge_base=knowledge,
            decomposition_plan=self.decomposition_plan or "(no design memo on record)",
            reference_contract=reference_contract,
            current_code=current_code,
            benchmark_status=benchmark.get("status"),
            failure_reason=benchmark.get("failure_reason"),
            command_transcript=format_command_transcript(benchmark.get("transcript", [])),
        )
        reviewer_messages = [
            {"role": "system", "content": Instruction_system_cuda_to_csl},
            {"role": "user", "content": prompt},
        ]
        # 1024 tokens: reviewer is intentionally cheap. The verdict header is
        # ~50 tokens; the rest goes to rationale + design amendment.
        budget = min(self.max_tokens, 1024)
        self._assert_no_compute_leak(reviewer_messages)
        raw = llm_complete(self._client_or_raise(), self.model,
                           reviewer_messages, budget)
        return self._parse_reviewer_verdict(raw)

    @staticmethod
    def _parse_reviewer_verdict(raw: str) -> Dict[str, object]:
        """Parse a reviewer reply into {bucket, rationale, design_amendment, raw}.

        Robust to whitespace + case in the header. On any parse failure (no
        BUCKET line, non-A/B/C value, empty input), defaults to bucket B with
        a rationale that explains the fallback. Never raises.
        """
        import re
        bucket = "B"
        rationale = "(reviewer reply unparseable; defaulting to B)"
        amendment: Optional[str] = None
        missing_symbol: Optional[str] = None
        debug_action: Optional[str] = None
        if raw and raw.strip():
            m = re.search(r"^\s*BUCKET\s*:\s*([ABC])\b",
                          raw, re.IGNORECASE | re.MULTILINE)
            if m:
                bucket = m.group(1).upper()
            m = re.search(r"^\s*RATIONALE\s*:\s*(.+?)$",
                          raw, re.IGNORECASE | re.MULTILINE)
            if m:
                rationale = m.group(1).strip()[:300]
            if bucket == "C":
                m = re.search(r"^\s*MISSING_SYMBOL\s*:\s*(.+?)$",
                              raw, re.IGNORECASE | re.MULTILINE)
                if m:
                    missing_symbol = m.group(1).strip()[:200]
            # SUGGESTED_DEBUG_ACTION is valid on any bucket; the reviewer
            # may recommend a debug step for both B and C verdicts, and for
            # A verdicts the architect can incorporate it into the new design.
            m = re.search(r"SUGGESTED_DEBUG_ACTION\s*:\s*(.+?)(?=\n\s*[A-Z][A-Z_]+\s*:|\Z)",
                          raw, re.IGNORECASE | re.DOTALL)
            if m:
                action = m.group(1).strip()[:500]
                if action and action.lower() not in ("(none)", "none", "n/a", "-"):
                    debug_action = action
            if bucket == "A":
                m = re.search(r"DESIGN_AMENDMENT\s*:\s*(.+?)(?:\n\s*\n|\Z)",
                              raw, re.IGNORECASE | re.DOTALL)
                if m:
                    amendment = m.group(1).strip()[:800]
        return {
            "bucket": bucket,
            "rationale": rationale,
            "missing_symbol": missing_symbol,
            "debug_action": debug_action,
            "design_amendment": amendment,
            "raw": raw,
        }

    # Backward-compat alias. Existing callers (and saved state) reference
    # plan_mesh_decomposition; new code should call design_architecture().
    plan_mesh_decomposition = design_architecture

    def _extract_translation(self, reply: str, target_relpath: str) -> Optional[str]:
        """Extract the agent's compute file from a reply. In co-design mode also
        extracts layout.csl into self._agent_extra_files (so it gets overlaid
        onto the staged bundle at benchmark time). Returns the compute body, or
        None if the compute block is missing (caller retries).

        Single-file (default) path: identical to `extract_code_block(reply,
        'csl')` — co-design is fully gated behind self.codesign_layout."""
        if not self.codesign_layout:
            code = extract_code_block(reply, "csl")
            # Check for distribution.py in the reply (Python fenced block).
            # Kernels that use distribution.py (e.g. GEMV) need the agent to
            # author its own collect()/distribute() so D2H coordinates match
            # the agent's decomposition — not the reference's hidden one.
            py_blocks = extract_multi_file_blocks(reply, "python")
            dist_body = None
            for k, v in (py_blocks or {}).items():
                if "distribution" in k.lower():
                    dist_body = v
                    break
            if dist_body:
                extras = getattr(self, "_agent_extra_files", None) or {}
                extras["distribution.py"] = dist_body
                self._agent_extra_files = extras
                logging.info("[cuda2csl] extracted agent-authored distribution.py (%d lines)",
                             dist_body.count("\n") + 1)
            return code
        blocks = extract_multi_file_blocks(reply, "csl")
        if not blocks:
            return None
        # Compute file: prefer the exact relpath tag, then its basename, then
        # the legacy bare-fence (empty-key) fallback.
        base = os.path.basename(target_relpath)
        code = blocks.get(target_relpath) or blocks.get(base) or blocks.get("")
        # Layout file: any key whose basename is layout.csl.
        layout_body = None
        for k, v in blocks.items():
            if os.path.basename(k) == "layout.csl":
                layout_body = v
                break
        if layout_body:
            self._agent_extra_files = {"layout.csl": layout_body}
        return code

    def _benchmark_current_code(self,
                                kernel_name: str,
                                current_code: str,
                                reference_dir: str,
                                target_relpath: str,
                                num_runs: int = 1,
                                heldout_eval: Optional[bool] = None,
                                compile_only: bool = False) -> Dict[str, object]:
        stage_root = tempfile.mkdtemp(prefix=f"{kernel_name.lower()}_", dir=self.work_root)
        translated_path = os.path.join(stage_root, target_relpath)
        ensure_directory(os.path.dirname(translated_path))
        with open(translated_path, "w", encoding="utf-8") as fh:
            fh.write(current_code)
        result = benchmark_translated_compute_file(
            translated_path=translated_path,
            reference_dir=reference_dir,
            target_relpath=target_relpath,
            work_dir=stage_root,
            sdk_root=self.sdk_root,
            shell_setup=self.shell_setup,
            commands_script=self.commands_script,
            arch=self.arch,
            keep_staged_bundle=self.profile_feedback_enabled,
            num_runs=num_runs,
            # Co-design mode: overlay agent-authored layout.csl (+ any other
            # extra files) onto the staged bundle. Empty/None in the default
            # single-file path, so behaviour is unchanged when off.
            extra_overlays=getattr(self, "_agent_extra_files", None),
            # Input-split held-out gate: default-on for the translate repair loop
            # (per-attempt, ends on a pass); the W2 optimize inner loop passes
            # heldout_eval=False (per-candidate ranking by cycles — held-out would
            # ~3x cost; final confirmation runs it).
            heldout_eval=heldout_eval,
            compile_only=compile_only,
        )
        if self.profile_feedback_enabled:
            profile = build_profile_report(
                benchmark=result,
                target_sdk=self.target_sdk,
                arch=self.arch,
                stage_label="optimization" if self._last_benchmark else "translation",
            )
            self.profile_log.append(profile)
            self.latest_profiler_feedback = format_profile_for_prompt(profile)
            result["profile_feedback"] = self.latest_profiler_feedback
            # Attach the profile to the result it describes, so the optimizer can
            # read the profile of the candidate it is EDITING (the current best),
            # not of the last candidate it happened to benchmark.
            result["model_readout"] = (profile.get("artifacts") or {}).get("model_readout")
            result["profiling_context"] = _profiling_context_from_profile(profile)
            staged_bundle = result.get("staged_bundle")
            if (
                not self.keep_profile_bundles
                and staged_bundle
                and os.path.exists(str(staged_bundle))
            ):
                shutil.rmtree(str(staged_bundle), ignore_errors=True)
        result["stage_root"] = stage_root
        self.run_log.append(result)
        # Record to experience store
        baseline_ms = (self._last_benchmark.get("run_time_ms")
                       if self._last_benchmark else None)
        self._exp_store.record(
            model=self.model,
            kernel=kernel_name,
            phase="optimization" if self._last_benchmark else "translation",
            step="translate" if not self._last_benchmark else "step",
            code_before=self.current_code or current_code,
            code_after=current_code,
            benchmark_result=result,
            baseline_ms=baseline_ms,
        )
        self._last_benchmark = result
        return result

    def translate(self,
                  kernel_name: str,
                  cuda_code: str,
                  reference_dir: str,
                  target_relpath: str,
                  reference_contract: str,
                  reference_compute_file: str,  # accepted for API compat; NOT shown to translator
                  task_summary: str = "",
                  layout_text: str = "") -> Tuple[str, Dict[str, object]]:
        # Reset per-kernel debugger state so the cap and repeat detection
        # apply within one kernel only (not across the batch).
        self.debugger_fires_used = 0
        self._previous_failure_reason = None
        self._kernel_dir_for_debugger = reference_dir
        self._layer_tracker = LayerClearanceTracker()
        # Arm the compute-leak guard for this kernel. From this point on,
        # any prompt sent via _llm_call / direct llm_complete is scanned
        # against a canary line from the reference compute CSL; if the
        # canary appears, AssertionError is raised. This enforces the
        # "layout visible, compute hidden" benchmark invariant.
        self._set_compute_canary(reference_compute_file, kernel_name=kernel_name)
        # Co-design mode: the agent will author layout.csl too, so HIDE the
        # reference layout from the implementer and arm a layout canary so it
        # cannot be regurgitated. (Default path leaves layout_text shown and
        # the layout canary disarmed.)
        if self.codesign_layout:
            self._set_layout_canary(layout_text, kernel_name=kernel_name)
            layout_text = ""  # withhold the reference layout from all prompts
        else:
            self._layout_canary = None
        # Stash task_summary + layout on self so the architect-respin
        # retranslate and bucket-routed repair paths can reuse them
        # (translate() local scope is lost when control returns into the
        # repair loop).
        self._task_summary_for_translate = task_summary
        self._layout_text_for_translate = layout_text
        if not self.cuda_analysis:
            if self.skip_analyse:
                self._append("system", Instruction_system_cuda_to_csl)
                self.cuda_analysis = "(analysis phase skipped — interpret the CUDA source directly)"
            else:
                self.analyse_cuda(cuda_code)

        if not self.decomposition_plan:
            if self.skip_planner:
                self.decomposition_plan = "(architecture phase skipped)"
            else:
                try:
                    self.design_architecture(cuda_code, target_relpath, reference_contract,
                                             layout_text=layout_text)
                except Exception as exc:
                    logging.warning("[cuda2csl] architect failed (%s); falling back to skip-planner placeholder",
                                    exc)
                    self.decomposition_plan = "(architect errored: " + str(exc)[:120] + ")"

        # Per the W1 hiding repivot: do NOT show the reference compute file to
        # the translator. The agent gets CUDA + task_summary (from spec.yaml)
        # + layout.csl (hoisted as its own labeled section, Phase 2a) +
        # reference_contract (= run.py + command script). It writes the CSL
        # from first principles. The compute-leak canary asserts the
        # reference compute file does not appear in any prompt.
        _kb = csl_knowledge_base.for_implementer(
            "\n".join([target_relpath, cuda_code, self.cuda_analysis or ""]),
            kernel_group=self.kernel_group,
            target_name=kernel_name,
            target_cuda=cuda_code,
            forbidden_lines=[self._compute_canary] if self._compute_canary else None,
        )
        _tf = ""
        if os.getenv("XKERNEL_TRANSLATION_FACTS", "0") == "1" and reference_dir:
            _tf = _render_translation_facts(reference_dir)
        self._translation_facts_block = _tf

        if self.codesign_layout:
            prompt = q_translate_cuda_to_csl_codesign.format(
                target_relpath=target_relpath,
                knowledge_base=_kb,
                task_summary=task_summary or "(no spec.yaml task description available; infer from CUDA)",
                decomposition_plan=self.decomposition_plan,
                reference_contract=reference_contract,
                cuda_analysis=self.cuda_analysis,
                cuda_code=cuda_code,
                builtin_whitelist=builtin_whitelist_block(),
            )
        elif os.getenv("XKERNEL_TEMPLATE_GEN", "0") == "1" and layout_text:
            tpl_name = _select_template(layout_text)
            if tpl_name:
                tpl_text = _get_template(tpl_name)
                tpl_block = _format_template_prompt(tpl_name, tpl_text)
                logging.info("[cuda2csl] template-gen: using %s template", tpl_name)
                self._active_template_name = tpl_name
                prompt = q_translate_from_template.format(
                    csl_template=tpl_block,
                    task_summary=task_summary or "(no spec.yaml task description available; infer from CUDA)",
                    cuda_analysis=self.cuda_analysis,
                    cuda_code=cuda_code,
                    builtin_whitelist=builtin_whitelist_block(),
                )
            else:
                logging.info("[cuda2csl] template-gen: no template fits, falling back to from-scratch")
                prompt = q_translate_cuda_to_csl_bundle.format(
                    target_relpath=target_relpath,
                    knowledge_base=_kb,
                    task_summary=task_summary or "(no spec.yaml task description available; infer from CUDA)",
                    decomposition_plan=self.decomposition_plan,
                    layout_text=layout_text or "(layout.csl not provided)",
                    translation_facts=_tf,
                    reference_contract=reference_contract,
                    cuda_analysis=self.cuda_analysis,
                    cuda_code=cuda_code,
                    builtin_whitelist=builtin_whitelist_block(),
                )
        else:
            prompt = q_translate_cuda_to_csl_bundle.format(
                target_relpath=target_relpath,
                knowledge_base=_kb,
                task_summary=task_summary or "(no spec.yaml task description available; infer from CUDA)",
                decomposition_plan=self.decomposition_plan,
                layout_text=layout_text or "(layout.csl not provided)",
                translation_facts=_tf,
                reference_contract=reference_contract,
                cuda_analysis=self.cuda_analysis,
                cuda_code=cuda_code,
                builtin_whitelist=builtin_whitelist_block(),
            )
        n_translate = int(os.environ.get("XKERNEL_BEST_OF_N", "1"))
        if n_translate >= 2:
            # Best-of-N: generate N independent translations from the same
            # architecture plan, compile-check each, pick the one that
            # compiles (or the first if none do). Triples the chance of
            # landing in a "good" initial basin for fragile kernels.
            msg_checkpoint = list(self.messages)
            candidates: List[Tuple[str, List[Dict[str, str]]]] = []
            for i in range(n_translate):
                self.messages = list(msg_checkpoint)
                self._append("user", prompt)
                try:
                    reply = self._llm_call(self.messages)
                except Exception as exc:
                    logging.warning("[cuda2csl] best-of-N candidate %d/%d LLM failed: %s",
                                    i + 1, n_translate, exc)
                    continue
                self._append("assistant", reply)
                c = self._extract_translation(reply, target_relpath)
                if c:
                    candidates.append((c, list(self.messages)))
                    logging.info("[cuda2csl] best-of-N candidate %d/%d: %d lines",
                                 i + 1, n_translate, c.count("\n") + 1)
                else:
                    logging.info("[cuda2csl] best-of-N candidate %d/%d: no CSL block", i + 1, n_translate)
            if not candidates:
                raise RuntimeError(
                    f"best-of-{n_translate}: no candidate produced a CSL code block"
                )
            _MIN_CANDIDATE_LINES = 20
            best_idx = 0
            best_compiles = False
            for idx, (cand_code, _) in enumerate(candidates):
                n_lines = cand_code.count("\n") + 1
                if n_lines < _MIN_CANDIDATE_LINES:
                    logging.info("[cuda2csl] best-of-N candidate %d/%d: skipped (%d lines < %d min)",
                                 idx + 1, len(candidates), n_lines, _MIN_CANDIDATE_LINES)
                    continue
                self.current_code = cand_code
                dry = self._benchmark_current_code(
                    kernel_name=kernel_name,
                    current_code=cand_code,
                    reference_dir=reference_dir,
                    target_relpath=target_relpath,
                    compile_only=True,
                )
                s = dry.get("status", "fail")
                logging.info("[cuda2csl] best-of-N candidate %d/%d compile: %s",
                             idx + 1, len(candidates), s)
                if s in ("pass", "blocked"):
                    best_idx = idx
                    best_compiles = True
                    break
            if not best_compiles:
                best_idx = max(range(len(candidates)),
                               key=lambda i: candidates[i][0].count("\n"))
            code, winning_msgs = candidates[best_idx]
            self.messages = winning_msgs
            self.current_code = code
            logging.info("[cuda2csl] best-of-N: selected candidate %d/%d",
                         best_idx + 1, len(candidates))
        else:
            self._append("user", prompt)
            reply = self._llm_call(self.messages)
            self._append("assistant", reply)

            code = self._extract_translation(reply, target_relpath)
            MAX_INITIAL_TRANSLATE_RETRIES = 3
            retries_left = MAX_INITIAL_TRANSLATE_RETRIES
            while not code and retries_left > 0:
                retries_left -= 1
                logging.warning(
                    "[cuda2csl] initial translation returned no CSL code block; "
                    "retrying (%d/%d) with a one-line nudge",
                    MAX_INITIAL_TRANSLATE_RETRIES - retries_left,
                    MAX_INITIAL_TRANSLATE_RETRIES,
                )
                nudge = (
                    "Your previous reply contained no ```csl fenced code block. "
                    "Re-send the complete CSL compute file inside a single ```csl "
                    "code fence, with no prose outside the fence."
                )
                self._append("user", nudge)
                try:
                    reply = self._llm_call(self.messages)
                except Exception as exc:
                    logging.warning("[cuda2csl] retry LLM call failed (%s); aborting initial translate",
                                    exc)
                    break
                self._append("assistant", reply)
                code = self._extract_translation(reply, target_relpath)
            if not code:
                raise RuntimeError(
                    "The model did not return a CSL code block for the initial translation "
                    f"after {MAX_INITIAL_TRANSLATE_RETRIES} retries."
                )
            self.current_code = code

        # Effective attempt cap: reviewer-active loops use reviewer_max_attempts
        # (default 10) because an architect re-spin "uses" an attempt without
        # producing an implementer fix; the legacy path stays at turns_limit
        # (default 4) so --skip-reviewer reproduces the prior behaviour.
        effective_limit = (
            self.turns_limit if self.skip_reviewer else self.reviewer_max_attempts
        )
        # Cap on "wasted" attempts that don't consume the real budget. A
        # wasted attempt = implementer returned no CSL, so the model burned
        # tokens without producing anything to benchmark. We grant up to 3
        # extra retries before giving up to avoid pathological infinite loops.
        MAX_WASTED_ATTEMPTS = 3
        wasted_attempts = 0
        logging.info("[cuda2csl] repair loop limit: %d (skip_reviewer=%s, +<= %d wasted)",
                     effective_limit, self.skip_reviewer, MAX_WASTED_ATTEMPTS)

        last_result: Dict[str, object] = {}
        attempt = 0
        while attempt < effective_limit:
            attempt += 1
            logging.info("[cuda2csl] Benchmarking attempt %d / %d",
                         attempt, effective_limit)

            # Compile-only dry-check: run cslc only (~2s) before the full
            # simulation (~30s). If the code doesn't compile, skip the
            # expensive run and feed the compile error to the reviewer.
            if os.environ.get("XKERNEL_DRY_CHECK", "1") == "1":
                dry = self._benchmark_current_code(
                    kernel_name=kernel_name,
                    current_code=self.current_code,
                    reference_dir=reference_dir,
                    target_relpath=target_relpath,
                    compile_only=True,
                )
                if dry.get("status") not in ("pass", "blocked"):
                    logging.info("[cuda2csl] dry-check compile FAILED (skipping full sim)")
                    benchmark = dry
                    last_result = benchmark
                    status = benchmark.get("status")
                else:
                    logging.info("[cuda2csl] dry-check compile OK → running full benchmark")
                    benchmark = self._benchmark_current_code(
                        kernel_name=kernel_name,
                        current_code=self.current_code,
                        reference_dir=reference_dir,
                        target_relpath=target_relpath,
                    )
                    last_result = benchmark
                    status = benchmark.get("status")
            else:
                benchmark = self._benchmark_current_code(
                    kernel_name=kernel_name,
                    current_code=self.current_code,
                    reference_dir=reference_dir,
                    target_relpath=target_relpath,
                )
                last_result = benchmark
                status = benchmark.get("status")
            if status in ("pass", "blocked"):
                return self.current_code, benchmark

            # Update layer-clearance tracker with this attempt's stderr.
            _lc_stderr = ""
            for _lc_entry in reversed(benchmark.get("transcript") or []):
                if isinstance(_lc_entry, dict):
                    _lc_stderr = _lc_entry.get("stderr") or _lc_entry.get("stdout") or ""
                    if _lc_stderr:
                        break
            self._layer_tracker.update(_lc_stderr)

            # Auto-distribution fallback: if run.py uses distribution.py
            # and the error is "dest tensor must be one-dimensional", the
            # agent's decomposition places y somewhere the reference
            # distribution.py doesn't read. Auto-generate a simple
            # distribution.py that reads from PE(0,0) and retry once.
            _all_stderr = _lc_stderr + str(benchmark.get("failure_reason", ""))
            for _te in (benchmark.get("transcript") or []):
                if isinstance(_te, dict):
                    _all_stderr += str(_te.get("stderr", "")) + str(_te.get("stdout", ""))
            if ("dest tensor must be one-dimensional" in _all_stderr
                    and not getattr(self, "_auto_dist_attempted", False)):
                dist_path = os.path.join(reference_dir, "distribution.py")
                if os.path.isfile(dist_path):
                    self._auto_dist_attempted = True
                    auto_dist = (
                        "import numpy as np\n"
                        "from cerebras.sdk.runtime.sdkruntimepybind import "
                        "MemcpyDataType, MemcpyOrder\n"
                        "DTYPE = MemcpyDataType.MEMCPY_32BIT\n"
                        "ORDER = MemcpyOrder.ROW_MAJOR\n"
                        "def grid(params):\n"
                        "    return int(params.get('kernel_cols',1)), "
                        "int(params.get('kernel_rows',1))\n"
                        "def distribute(name, arr, params):\n"
                        "    kc, kr = grid(params)\n"
                        "    if name == 'A':\n"
                        "        return arr.ravel(), kc, kr, "
                        "arr.size // (kc * kr), 0, 0\n"
                        "    return arr.ravel(), 1, 1, arr.size, 0, 0\n"
                        "def collect(name, params):\n"
                        "    kc, kr = grid(params)\n"
                        "    mr = int(params.get('matrix_rows', 32))\n"
                        "    if name == 'y':\n"
                        "        return 0, 0, 1, 1, mr\n"
                        "    raise KeyError(name)\n"
                    )
                    extras = getattr(self, "_agent_extra_files", None) or {}
                    extras["distribution.py"] = auto_dist
                    self._agent_extra_files = extras
                    logging.info("[cuda2csl] auto-injected fallback distribution.py "
                                 "(collect from PE(0,0)) — retrying benchmark")
                    benchmark = self._benchmark_current_code(
                        kernel_name=kernel_name,
                        current_code=self.current_code,
                        reference_dir=reference_dir,
                        target_relpath=target_relpath,
                    )
                    last_result = benchmark
                    status = benchmark.get("status")
                    if status in ("pass", "blocked"):
                        return self.current_code, benchmark

            # ---- reviewer phase: classify the failure ----
            if self.skip_reviewer:
                verdict: Dict[str, object] = {
                    "bucket": "B",
                    "rationale": "(reviewer skipped via --skip-reviewer)",
                    "design_amendment": None,
                    "raw": "",
                }
            else:
                try:
                    verdict = self.review_failure(self.current_code, benchmark, reference_contract)
                except Exception as exc:
                    logging.warning("[cuda2csl] reviewer call failed (%s); defaulting to bucket B",
                                    exc)
                    verdict = {
                        "bucket": "B",
                        "rationale": f"(reviewer error: {str(exc)[:120]})",
                        "design_amendment": None,
                        "raw": "",
                    }

            # Cap architect re-spins. Subsequent A verdicts demote to B.
            if (verdict["bucket"] == "A"
                    and self.architect_respin_count >= self.MAX_ARCHITECT_RESPINS):
                logging.info("[cuda2csl] architect re-spin cap (%d) reached; demoting A→B",
                             self.MAX_ARCHITECT_RESPINS)
                verdict = dict(verdict)
                verdict["bucket"] = "B"
                verdict["rationale"] = ("(A demoted to B: respin cap reached) "
                                        + str(verdict.get("rationale", "")))

            logging.info("[cuda2csl] verdict on attempt %d: bucket=%s rationale=%s",
                         attempt, verdict["bucket"], str(verdict.get("rationale"))[:120])

            # Stash full verdict on the benchmark record so it survives into
            # final_result.json via the existing run_log → write_final_artifacts
            # path. No schema change needed.
            benchmark["reviewer_verdict"] = verdict

            # Log the verdict to the experience store as a "repair" phase step.
            try:
                self._exp_store.record(
                    model=self.model,
                    kernel=kernel_name,
                    phase="repair",
                    step=f"review_verdict_{verdict['bucket']}",
                    code_before=self.current_code,
                    code_after=self.current_code,
                    benchmark_result=benchmark,
                    baseline_ms=None,
                )
            except Exception as exc:
                logging.warning("[cuda2csl] experience_store record failed (%s); continuing",
                                exc)

            # ---- route the next turn ----
            if verdict["bucket"] == "A":
                self.architect_respin_count += 1
                failure_ctx = (
                    f"Attempt {attempt} of {effective_limit} failed with "
                    f"status={benchmark.get('status')} and "
                    f"failure_reason={benchmark.get('failure_reason')}.\n\n"
                    f"Reviewer rationale: {verdict.get('rationale')}\n\n"
                    f"Reviewer's suggested amendment:\n"
                    f"{verdict.get('design_amendment') or '(no specific amendment supplied)'}"
                )
                logging.info("[cuda2csl] bucket A: re-spinning architect (respin %d/%d)",
                             self.architect_respin_count, self.MAX_ARCHITECT_RESPINS)
                # Force regeneration of the design memo.
                self.decomposition_plan = None
                try:
                    self.design_architecture(cuda_code, target_relpath, reference_contract,
                                             layout_text=getattr(self, "_layout_text_for_translate", ""),
                                             failure_context=failure_ctx)
                except Exception as exc:
                    logging.warning("[cuda2csl] architect re-spin failed (%s); reusing last design",
                                    exc)
                    # If re-spin fails, fall through to bucket B with the original design.
                    self.decomposition_plan = (
                        "(architect re-spin errored: " + str(exc)[:120] + "; "
                        "implementer falls back to its previous design)"
                    )
                    fix_prompt = csl_bundle_fix_with_review.format(
                        current_code=self.current_code,
                        layout_text=getattr(self, "_layout_text_for_translate", "") or "(layout.csl not provided)",
                        translation_facts=getattr(self, "_translation_facts_block", ""),
                        reference_contract=reference_contract,
                        benchmark_status=benchmark.get("status"),
                        failure_reason=benchmark.get("failure_reason"),
                        command_transcript=format_command_transcript(benchmark.get("transcript", [])),
                        verdict_bucket="B",
                        reviewer_rationale=verdict.get("rationale"),
                        debug_action=verdict.get("debug_action") or "(none — stderr is the spec)",
                        debugger_report="",
                        builtin_whitelist=builtin_whitelist_block(),
                    )
                    self._append("user", fix_prompt)
                    reply = self._llm_call_with_trim_on_overflow(cuda_code)
                else:
                    # Reset implementer thread to a fresh slate against the
                    # NEW architecture. Replay [system, analyse_q, analyse_a]
                    # so the new translation has the CUDA semantics in context.
                    self.messages = []
                    self._append("system", Instruction_system_cuda_to_csl)
                    if self.cuda_analysis and not self.skip_analyse:
                        self._append("user", q_analyse_cuda_source.format(cuda_code=cuda_code))
                        self._append("assistant", self.cuda_analysis)
                    _rs_kb = csl_knowledge_base.for_implementer(
                        "\n".join([target_relpath, cuda_code, self.cuda_analysis or ""]),
                        kernel_group=self.kernel_group,
                        target_name=kernel_name,
                        target_cuda=cuda_code,
                        forbidden_lines=[self._compute_canary] if self._compute_canary else None,
                    )
                    _rs_task = (self._task_summary_for_translate
                                or "(no spec.yaml task description available; infer from CUDA)")
                    if self.codesign_layout:
                        new_translate = q_translate_cuda_to_csl_codesign.format(
                            target_relpath=target_relpath, knowledge_base=_rs_kb,
                            task_summary=_rs_task, decomposition_plan=self.decomposition_plan,
                            reference_contract=reference_contract,
                            cuda_analysis=self.cuda_analysis, cuda_code=cuda_code,
                            builtin_whitelist=builtin_whitelist_block(),
                        )
                    else:
                        new_translate = q_translate_cuda_to_csl_bundle.format(
                            target_relpath=target_relpath, knowledge_base=_rs_kb,
                            task_summary=_rs_task, decomposition_plan=self.decomposition_plan,
                            layout_text=getattr(self, "_layout_text_for_translate", "") or "(layout.csl not provided)",
                            translation_facts=getattr(self, "_translation_facts_block", ""),
                            reference_contract=reference_contract,
                            cuda_analysis=self.cuda_analysis, cuda_code=cuda_code,
                            builtin_whitelist=builtin_whitelist_block(),
                        )
                    self._append("user", new_translate)
                    reply = self._llm_call(self.messages)
            elif verdict["bucket"] == "C":
                missing = verdict.get("missing_symbol") or (
                    "(reviewer did not name a specific symbol — read the "
                    "rationale and command transcript to identify what's missing)"
                )
                logging.info("[cuda2csl] bucket C: contract violation repair (missing=%s)",
                             str(missing)[:80])
                fix_prompt = csl_bundle_fix_contract.format(
                    current_code=self.current_code,
                    layout_text=getattr(self, "_layout_text_for_translate", "") or "(layout.csl not provided)",
                    translation_facts=getattr(self, "_translation_facts_block", ""),
                    reference_contract=reference_contract,
                    commands_script=self.commands_script,
                    benchmark_status=benchmark.get("status"),
                    failure_reason=benchmark.get("failure_reason"),
                    command_transcript=format_command_transcript(benchmark.get("transcript", [])),
                    reviewer_rationale=verdict.get("rationale"),
                    missing_symbol=missing,
                    debug_action=verdict.get("debug_action") or "(none — restore the missing symbol verbatim)",
                    builtin_whitelist=builtin_whitelist_block(),
                )
                self._append("user", fix_prompt)
                reply = self._llm_call_with_trim_on_overflow(cuda_code)
            else:  # bucket B (default)
                logging.info("[cuda2csl] bucket B: implementer repair (debug_action=%s)",
                             str(verdict.get("debug_action"))[:80])
                # Optional: fire the debugger sub-agent for a structured
                # diagnostic report before the implementer's fix prompt.
                # Gate by XKERNEL_DEBUGGER (default OFF) + concrete trigger
                # conditions (see debugger_agent.should_fire). Cap per kernel.
                debugger_report_block = ""
                if debugger_should_fire(
                        bucket="B",
                        debug_action=verdict.get("debug_action"),
                        current_failure_reason=benchmark.get("failure_reason"),
                        previous_failure_reason=self._previous_failure_reason,
                        fires_used_for_this_kernel=self.debugger_fires_used):
                    logging.info("[cuda2csl] firing debugger sub-agent (fire %d/%d)",
                                 self.debugger_fires_used + 1,
                                 1)
                    try:
                        dbg = DebuggerAgent(
                            llm_call=self._llm_call,
                            max_tokens=min(self.max_tokens, 1024),
                        )
                        # stderr_tail: pull from transcript's last entry
                        # Fix #3 part 2 (per audit task #34): pick the
                        # FAILING step, not blindly the last. When compile
                        # fails but cleanup commands ran after, or when a
                        # multi-run step has a passing repeat after a
                        # failing one, transcript[-1] is the wrong entry.
                        # Walk from the end for the first entry with
                        # non-zero returncode (or status != 'pass').
                        transcript = benchmark.get("transcript", []) or []
                        stderr_tail = ""
                        if transcript:
                            failing = None
                            for e in reversed(transcript):
                                if not isinstance(e, dict):
                                    continue
                                rc = e.get("returncode")
                                if rc not in (0, "", None) or e.get("status") not in ("pass", None):
                                    failing = e
                                    break
                            if failing is None:
                                # Fall back to the actual last entry.
                                failing = transcript[-1] if isinstance(transcript[-1], dict) else None
                            if failing:
                                # Use the same head+tail clip as the
                                # transcript formatter so reviewer and
                                # debugger see consistent windows. 2000
                                # chars (400 head + 1600 tail) since the
                                # debugger only sees one step.
                                raw = failing.get("stderr") or failing.get("stdout") or ""
                                stderr_tail = _clip_head_tail(raw, head=400, tail=1600)
                        readable_files = None
                        if os.environ.get("XKERNEL_DEBUGGER_V2", "0") == "1":
                            reader = ScopedFileReader(self._kernel_dir_for_debugger or "")
                            readable_files = reader.read_all()
                            if self.codesign_layout and readable_files:
                                readable_files = {k: v for k, v in readable_files.items()
                                                  if not k.startswith("layout")}
                        report = dbg.diagnose(DebuggerInput(
                            current_csl=self.current_code or "",
                            stderr_tail=stderr_tail,
                            failure_reason=str(benchmark.get("failure_reason") or ""),
                            reviewer_rationale=str(verdict.get("rationale") or ""),
                            reviewer_debug_action=str(verdict.get("debug_action") or ""),
                            reference_contract=reference_contract or "",
                            layout_csl="" if self.codesign_layout else read_layout_csl(self._kernel_dir_for_debugger),
                            readable_files=readable_files,
                        ))
                        debugger_report_block = report.to_prompt_block()
                        self.debugger_fires_used += 1
                        # Stash debugger output on the benchmark record so it
                        # survives into final_result.json for inspection.
                        benchmark["debugger_report"] = {
                            "diagnostic_run": report.diagnostic_run,
                            "diagnostic_output": report.diagnostic_output,
                            "diagnosis": report.diagnosis,
                            "recommended_patch": report.recommended_patch,
                            "confidence": report.confidence,
                            "fired": report.fired,
                        }
                        logging.info("[cuda2csl] debugger emitted report: confidence=%s patch=%s",
                                     report.confidence,
                                     (report.recommended_patch or "")[:80])
                    except Exception as exc:
                        logging.warning("[cuda2csl] debugger fire failed (%s); proceeding without",
                                        str(exc)[:200])
                        debugger_report_block = ""
                # Compile-error→gotcha micro-retrieval: scan stderr for
                # known patterns and append targeted fix hints.
                _gotcha_stderr = ""
                for entry in reversed(benchmark.get("transcript") or []):
                    if isinstance(entry, dict):
                        _gotcha_stderr = entry.get("stderr") or entry.get("stdout") or ""
                        if _gotcha_stderr:
                            break
                gotcha_block = retrieve_gotchas(_gotcha_stderr)
                layer_advisory = self._layer_tracker.advisory()
                combined_report = "\n\n".join(
                    b for b in [debugger_report_block, gotcha_block, layer_advisory] if b
                )
                fix_prompt = csl_bundle_fix_with_review.format(
                    current_code=self.current_code,
                    layout_text=getattr(self, "_layout_text_for_translate", "") or "(layout.csl not provided)",
                    translation_facts=getattr(self, "_translation_facts_block", ""),
                    reference_contract=reference_contract,
                    benchmark_status=benchmark.get("status"),
                    failure_reason=benchmark.get("failure_reason"),
                    command_transcript=format_command_transcript(benchmark.get("transcript", [])),
                    verdict_bucket=verdict["bucket"],
                    reviewer_rationale=verdict.get("rationale"),
                    debug_action=verdict.get("debug_action") or "(none — stderr is the spec)",
                    debugger_report=combined_report,
                    builtin_whitelist=builtin_whitelist_block(),
                )
                self._append("user", fix_prompt)
                reply = self._llm_call_with_trim_on_overflow(cuda_code)
            # Update previous_failure_reason cache for the next iteration's
            # debugger-fire decision (do this after the bucket dispatch so
            # all buckets contribute to the repeat-detection signal).
            self._previous_failure_reason = benchmark.get("failure_reason")

            self._append("assistant", reply)
            repaired = self._extract_translation(reply, target_relpath)
            if not repaired:
                # The implementer's reply had no CSL block. Don't burn an
                # attempt on this — decrement the counter and bump the wasted
                # tally. Cap the total wasted retries so we never loop forever.
                wasted_attempts += 1
                if wasted_attempts > MAX_WASTED_ATTEMPTS:
                    logging.warning(
                        "[cuda2csl] attempt %d: implementer returned no CSL block "
                        "for the %d-th time; giving up to avoid infinite loop",
                        attempt, wasted_attempts,
                    )
                    break
                logging.warning(
                    "[cuda2csl] attempt %d: no CSL block in implementer reply; "
                    "not consuming the attempt (wasted %d/%d) and retrying",
                    attempt, wasted_attempts, MAX_WASTED_ATTEMPTS,
                )
                attempt -= 1  # don't burn the attempt
                continue
            self.current_code = repaired

        return self.current_code, last_result

    def _filter_angles(self, angles: List[str],
                       kernel_spec: Optional[Dict[str, object]]) -> Tuple[List[str], Dict[str, str]]:
        """Apply the angle gates: XKERNEL_ANGLE_DENYLIST (comma list), the task's
        precision contract (`spec.precision.allow_f16_internal` or an f16 I/O
        dtype) for `requires_precision_ok` angles, XKERNEL_HW_ANGLES=1 for
        `hardware_validated` angles (the simulator cannot see their effect), and
        co-design mode (XKERNEL_CODESIGN_LAYOUT=1) for `codesign_only` angles.
        Returns (kept, {angle: reason})."""
        denylist = {a.strip() for a in os.environ.get("XKERNEL_ANGLE_DENYLIST", "").split(",") if a.strip()}
        precision = ((kernel_spec or {}).get("precision") or {}) if isinstance(kernel_spec, dict) else {}
        io_dtype = str(precision.get("io_dtype", "")).lower()
        f16_ok = bool(precision.get("allow_f16_internal")) or io_dtype in ("f16", "fp16", "half")
        hw_angles = os.environ.get("XKERNEL_HW_ANGLES", "0") == "1"
        codesign = os.environ.get("XKERNEL_CODESIGN_LAYOUT", "0") == "1"
        kept: List[str] = []
        denied: Dict[str, str] = {}
        for name in angles:
            meta = angle_metadata(name)
            if name in denylist:
                denied[name] = "denylist"
            elif meta.get("requires_precision_ok") and not f16_ok:
                denied[name] = "precision_contract"
            elif meta.get("hardware_validated") and not hw_angles:
                denied[name] = "hardware_only"
            elif meta.get("codesign_only") and not codesign:
                denied[name] = "codesign_only"
            else:
                kept.append(name)
        if denied:
            logging.info("[optimize] angles denied: %s", denied)
        return kept, denied

    def _select_optimization_angle(self,
                                   whitelist: List[str],
                                   round_robin_idx: int,
                                   current_code: str,
                                   current_cycles: int,
                                   reference_cycles: Optional[int],
                                   kernel_group: str,
                                   per_fn_cycles: Optional[Dict[str, int]] = None,
                                   last_accepted_diff: Optional[str] = None,
                                   recent_attempts: Optional[List[Dict[str, object]]] = None,
                                   proven_angles: Optional[List[Dict[str, object]]] = None,
                                   attempted_no_op_angles: Optional[List[Dict[str, object]]] = None,
                                   bottleneck_signature: Optional[Dict[str, object]] = None) -> Tuple[str, str]:
        """A3: pick ONE angle from the whitelist for this optimize attempt.

        Uses a single small LLM call (q_optimize_select_angle template).
        Returns (angle_name, reason). On any failure (LLM error, parse
        failure, name not in whitelist), falls back to round-robin selection
        from the whitelist and returns reason="fallback: <error class>".

        The selector is the ONE place where the LLM has discretion over the
        optimization plan. Every other LLM step works inside its picked
        angle. This keeps the search space curated (whitelist) while letting
        the model adapt to the actual bottleneck."""
        if not whitelist:
            return ("comptime_cleanup", "fallback: empty_whitelist")

        def _round_robin_fallback(reason: str) -> Tuple[str, str]:
            return (whitelist[round_robin_idx % len(whitelist)],
                    f"fallback: {reason}")

        # Build the whitelist block: each angle name + its one-line description.
        # The selector sees the descriptions so it can match the angle to the
        # situation (not just pick a name at random).
        # If proven_angles is supplied (from spec.yaml), annotate matching
        # whitelist entries with the historical cycle reduction. This is the
        # framework's "this angle has worked here before" hint — empirical,
        # not theoretical. Especially useful early in a run before the
        # selector has any of its own attempt history to learn from.
        proven_lookup = {
            (p.get("angle") or ""): p
            for p in (proven_angles or [])
            if isinstance(p, dict)
        }
        # Task #25: negative-experience memory. Angles previously attempted
        # on this kernel that produced no cycle improvement. Annotated with
        # ✗ in the whitelist so the selector deprioritizes them. NOT a
        # hard block — if the kernel state has materially changed (e.g.
        # different best_code base), the angle might still be worth a
        # retry. Selector decides.
        no_op_lookup = {
            (p.get("angle") or ""): p
            for p in (attempted_no_op_angles or [])
            if isinstance(p, dict)
        }
        # Task #24: bottleneck-matched angles. Annotate each angle with the
        # bottlenecks it would address (and how many evidence hits it has
        # in this kernel) so the selector can match technique to bottleneck.
        matched = self._match_angles_to_bottlenecks(whitelist, bottleneck_signature or {})
        matched_lookup = dict(matched)  # {angle_name: score}

        whitelist_lines = []
        for name in whitelist:
            meta = angle_metadata(name)
            desc = meta["description"].split(".")[0].strip()  # first sentence
            line = f"  - {name}: {desc[:140]}"
            proven = proven_lookup.get(name)
            if proven:
                bc = proven.get("best_cycles")
                src = proven.get("source", "")
                line += f"   ★ PROVEN on this kernel: {bc} cycles ({src})" if bc else f"   ★ PROVEN on this kernel"
            no_op = no_op_lookup.get(name)
            if no_op:
                runs = no_op.get("runs_tried", "?")
                last = no_op.get("last_attempted", "")
                line += f"   ✗ NO-OP on this kernel: tried {runs}× with no cycle reduction (most recent: {last})"
            if name in matched_lookup:
                score = matched_lookup[name]
                applicable = meta.get("applicable_bottlenecks", []) or []
                detected = (bottleneck_signature or {}).get("bottlenecks", {}) or {}
                hits = [b for b in applicable if b in detected]
                line += f"   ⚙ BOTTLENECK MATCH (score={score}): {', '.join(hits)}"
            whitelist_lines.append(line)
        whitelist_block = "\n".join(whitelist_lines)
        if proven_lookup:
            whitelist_block += (
                "\n\n(★ entries have produced REAL cycle reductions on this "
                "specific kernel in past runs. Prefer them unless the recent "
                "attempts or per-fn breakdown clearly point elsewhere.)"
            )
        if no_op_lookup:
            whitelist_block += (
                "\n\n(✗ entries were tried on this kernel in past runs and "
                "produced no cycle reduction. Skip them unless the kernel's "
                "current state differs materially from when they were tried "
                "(e.g. a new accepted change unlocked a fresh hot spot). "
                "Burning attempts on known no-ops wastes budget.)"
            )
        if matched_lookup:
            whitelist_block += (
                "\n\n(⚙ entries match a bottleneck pattern detected in the "
                "current code by the static profiler. The score = total "
                "evidence-hits for that angle's applicable bottlenecks. "
                "Higher score = more direct match. The profiler is "
                "deterministic and based on REAL pattern detection in the "
                "code, so ⚙ matches are the strongest signal available "
                "BEFORE any per-fn timing data.)"
            )
        elif bottleneck_signature and bottleneck_signature.get("bottlenecks"):
            whitelist_block += (
                "\n\n(The profiler detected bottlenecks but no whitelisted "
                "angle directly addresses them. Widen your reasoning beyond "
                "the typical levers; consider whether any angle could be "
                "creatively applied to the detected patterns.)"
            )
        elif bottleneck_signature is not None:
            whitelist_block += (
                "\n\n(The profiler detected no clear structural bottlenecks "
                "in the current code — it may already be well-optimized at "
                "the pattern level. Pick based on the kernel's group + "
                "general first-principles reasoning.)"
            )

        # Bottleneck signature block — what the static profiler detected
        # in the current code. Selector should treat this as the primary
        # signal (along with per_fn_cycles when available).
        if bottleneck_signature and bottleneck_signature.get("bottlenecks"):
            sig_dict = bottleneck_signature["bottlenecks"]
            sig_lines = [f"  - {b}: {n} occurrences" for b, n in sorted(sig_dict.items(), key=lambda kv: -kv[1])]
            bottleneck_block = (
                "Static profiler signature (deterministic pattern detection on the current code):\n"
                + "\n".join(sig_lines)
                + f"\n\nCode has {bottleneck_signature.get('n_for_loops', 0)} for-loop blocks, "
                + f"{bottleneck_signature.get('code_chars', 0)} chars total."
            )
        else:
            bottleneck_block = (
                "Static profiler signature: no clear structural bottlenecks detected. "
                "The code may already be well-optimized at the pattern level."
            )

        # Silicon-model readout of the code being edited (model-guided mode).
        model_text = (bottleneck_signature or {}).get("model_readout_text")
        if model_text:
            bottleneck_block += (
                "\n\nSilicon performance model (traces from the simulator, costs measured on "
                "WSE-3 hardware). This is the authoritative signal: prefer angles whose ⚙ match "
                "names a model_* key, and do not propose width or precision changes the readout "
                "reports as already spent.\n" + str(model_text)
            )

        # Per-fn cycle block — present only if per_fn_cycles is non-empty.
        # When B1/B2 land this will tell the selector which f_* is hot.
        if per_fn_cycles:
            sorted_fns = sorted(per_fn_cycles.items(), key=lambda kv: -kv[1])
            per_fn_lines = [f"  {fn}: {cyc} cycles" for fn, cyc in sorted_fns]
            per_fn_cycles_block = (
                "Per-function cycle breakdown (highest first):\n"
                + "\n".join(per_fn_lines)
                + "\n\nFocus the angle on whatever function dominates."
            )
        else:
            per_fn_cycles_block = (
                "Per-function cycle breakdown: not available for this kernel. "
                "Pick based on the code shape alone."
            )

        # Last-accepted-diff block — present only after the first acceptance.
        if last_accepted_diff:
            diff_excerpt = last_accepted_diff[:1500]
            last_diff_block = (
                "Last accepted change (what the previous attempt did):\n"
                "```diff\n"
                f"{diff_excerpt}\n"
                "```\n\n"
                "Prefer NOT to repeat the same angle. If the bottleneck moved, pick the angle that targets the new hot spot."
            )
        else:
            last_diff_block = "No prior accepted change yet — this is the first improvement attempt."

        # Recent-attempts block — show the selector which angles ALREADY ran
        # this kernel (and their outcomes) so it doesn't pick the same losing
        # angle over and over. Without this, deterministic LLM responses
        # given identical context will pick the same angle every round.
        if recent_attempts:
            tried_lines = []
            for r in recent_attempts[-6:]:  # last 6 attempts
                outcome = "ACCEPTED" if r.get("selected") else f"rejected({r.get('rejected_reason', 'unknown')[:30]})"
                tried_lines.append(f"  - attempt {r.get('attempt')}: {r.get('angle')} → {outcome}")
            tried_block = (
                "Recent attempts this run (avoid repeating losing angles):\n"
                + "\n".join(tried_lines)
            )
            # Embed inside last_diff_block so the format spec stays the same.
            last_diff_block = tried_block + "\n\n" + last_diff_block

        # Truncate current code to keep prompt small (the optimizer's main
        # prompt has the full code; the selector just needs enough to judge
        # the kernel's shape).
        SNIPPET_LINES = 80
        code_lines = current_code.split("\n")
        if len(code_lines) > SNIPPET_LINES:
            current_code_snippet = "\n".join(code_lines[:SNIPPET_LINES])
            current_code_snippet += f"\n... [{len(code_lines) - SNIPPET_LINES} more lines truncated]"
        else:
            current_code_snippet = current_code

        prompt = q_optimize_select_angle.format(
            whitelist_block=whitelist_block,
            kernel_group=kernel_group or "(unknown)",
            current_cycles=current_cycles,
            reference_cycles=reference_cycles if reference_cycles is not None else "(not measured)",
            bottleneck_block=bottleneck_block,
            per_fn_cycles_block=per_fn_cycles_block,
            last_diff_block=last_diff_block,
            snippet_lines=SNIPPET_LINES,
            current_code_snippet=current_code_snippet,
        )
        messages = [
            {"role": "system", "content": Instruction_system_csl_optimization},
            {"role": "user", "content": prompt},
        ]
        # 1024 tokens: reasoning models (gpt-oss-120b, o-series) burn most of
        # their budget on hidden reasoning before emitting; 256 tokens caused
        # them to return empty content. 1024 fits inside any reasonable model
        # cap and gives reasoning models enough headroom to actually produce
        # ANGLE: + REASON:. The selector reply is parsed by regex so excess
        # tokens cost compute but don't affect correctness.
        try:
            reply = self._llm_call(messages, max_tokens=min(self.max_tokens, 1024))
        except Exception as exc:
            logging.warning("[select_angle] LLM call failed (%s); round-robin fallback",
                            str(exc)[:120])
            return _round_robin_fallback(f"llm_error: {str(exc)[:80]}")

        # Parse strict format: "ANGLE: name" + "REASON: ...".
        angle_match = re.search(r"^\s*ANGLE\s*:\s*(\S+)", reply, re.MULTILINE | re.IGNORECASE)
        reason_match = re.search(r"^\s*REASON\s*:\s*(.+)$", reply, re.MULTILINE | re.IGNORECASE)
        if not angle_match:
            logging.warning("[select_angle] could not parse ANGLE: from reply (%s); fallback",
                            reply[:120])
            return _round_robin_fallback("parse_failure")
        picked = angle_match.group(1).strip().rstrip(",.;:")
        reason = reason_match.group(1).strip() if reason_match else "(no reason)"
        if picked not in whitelist:
            logging.warning("[select_angle] picked '%s' not in whitelist; fallback", picked)
            return _round_robin_fallback(f"unknown_angle: {picked}")
        return (picked, reason)

    def optimize(self,
                 kernel_name: str,
                 reference_dir: str,
                 target_relpath: str,
                 reference_contract: str,
                 reference_compute_file: str,  # accepted for API compat; NOT shown to optimizer
                 baseline_result: Dict[str, object],
                 requested_steps: List[str],
                 min_attempts: int = 5,
                 max_attempts: int = 10,
                 task_summary: str = "",
                 kernel_spec: Optional[Dict[str, object]] = None) -> Tuple[str, Dict[str, object], Dict[str, object]]:
        """Cycle-reduction optimizer. Iterates LLM-generated variants of the
        current best compute file, keeps a variant ONLY if its `cycles_send`
        is strictly less than the current best. Terminates when:
          - max_attempts reached, OR
          - we've done at least min_attempts AND the last
            ``_OPTIMIZE_PATIENCE`` attempts in a row produced no improvement.

        Per the repivot (code_translation/REPIVOT_CYCLES.md), the reference
        compute file is intentionally NOT shown to the optimizer to avoid
        biasing toward mimicry. Only the **current** code, the cycle target,
        and the profile feedback are visible.
        """
        _OPTIMIZE_PATIENCE = 5  # stop after this many consecutive no-improvements past min_attempts
        # Arm the compute-leak guard in case optimize() is entered without
        # translate() running first (the --optimize-only / W2 path). Cheap
        # if already armed; idempotent.
        self._set_compute_canary(reference_compute_file, kernel_name=kernel_name)
        _base_mr = baseline_result.get("model_readout") if isinstance(baseline_result.get("model_readout"), dict) else {}
        summary: Dict[str, object] = {
            "baseline": {
                "status": baseline_result.get("status"),
                "run_time_ms": baseline_result.get("run_time_ms"),
                "cycles_send": baseline_result.get("cycles_send"),
                # Silicon-model view of the START program (present when
                # XKERNEL_MODEL_GUIDED=1): class, matcher keys, predicted device
                # cycles. The paper groups paired results by this class.
                "model_class": _base_mr.get("bottleneck"),
                "model_keys": _base_mr.get("model_keys"),
                "predicted_cycles": _base_mr.get("predicted_cycles"),
                "roofline_fraction_f16": _base_mr.get("roofline_fraction_f16"),
            },
            "steps": [],
            "selected_variant": "baseline",
            "min_attempts": min_attempts,
            "max_attempts": max_attempts,
        }

        if baseline_result.get("status") != "pass":
            summary["skipped"] = (
                "Optimization requires a passing baseline. The baseline benchmark "
                "did not pass."
            )
            return self.current_code, baseline_result, summary

        baseline_cycles = baseline_result.get("cycles_send")
        if not isinstance(baseline_cycles, int) or baseline_cycles <= 0:
            summary["skipped"] = (
                "Optimization requires a baseline cycles_send measurement. The "
                "baseline benchmark passed but did not report cycles_send — this "
                "kernel's run.py does not emit a `cycles_send = N cycles` line."
            )
            return self.current_code, baseline_result, summary

        best_code = self.current_code
        best_result = baseline_result
        best_cycles = baseline_cycles
        consecutive_no_improvement = 0
        if self.keep_candidates:
            _bmr = baseline_result.get("model_readout") if isinstance(baseline_result.get("model_readout"), dict) else {}
            self.retained_candidates.append({
                "attempt": 0, "cand_idx": 0, "angle": "baseline", "accepted": True,
                "predicted_cycles": _bmr.get("predicted_cycles"), "model_class": _bmr.get("bottleneck"),
                "status": baseline_result.get("status"), "success_marker": baseline_result.get("success_marker"),
                "cycles_send": baseline_cycles, "cycles_send_runs": baseline_result.get("cycles_send_runs"),
                "contract_violation": None, "base_label": "input", "base_cycles": None,
                "code": best_code,
            })
        # Phase 1c: top-K reservoir. Track the 3 best-ever survivor variants
        # so a stalled lineage can branch from a runner-up before we
        # terminate. Each entry: {code, result, cycles, ancestry}. Sorted
        # ascending by cycles (top_k[0] is the current best).
        TOP_K = 3
        top_k: List[Dict[str, object]] = [{
            "code": best_code,
            "result": best_result,
            "cycles": best_cycles,
            "ancestry": ["baseline"],
        }]
        # When we've stalled past patience, before terminating we try one
        # rotation starting from top_k[1] (the second-best lineage). Only
        # set true once; if THAT rotation also stalls we terminate.
        branch_attempted = False
        # When non-None, the NEXT iteration uses this code as `best_code`
        # for prompt formation rather than top_k[0]. Used to implement the
        # one-shot branch from top_k[1].
        branch_from_code: Optional[str] = None
        branch_from_cycles: Optional[int] = None
        branch_from_ancestry: Optional[List[str]] = None

        # Resolve frozen-function / frozen-param lists from spec.yaml (with
        # defaults from contract_check). Used by the validator gate below to
        # reject variants that game the cycle metric by editing timing
        # functions or shadowing host-supplied params.
        frozen_fns, frozen_params = spec_frozen_lists(kernel_spec)
        summary["contract"] = {
            "frozen_functions": list(frozen_fns),
            "frozen_params":    list(frozen_params),
        }

        # A2: per-kernel optimization_angles in spec.yaml override the
        # generic --steps list. Falls back to requested_steps (--steps) if
        # spec.yaml didn't supply a whitelist. Falls back to all catalog
        # entries if neither is present.
        spec_angles = (kernel_spec or {}).get("optimization_angles") or []
        if spec_angles:
            angle_order = list(spec_angles)
            angle_source = f"spec.yaml ({len(spec_angles)} angles)"
        elif requested_steps:
            angle_order = list(requested_steps)
            angle_source = f"--steps ({len(requested_steps)} angles)"
        else:
            angle_order = list(CSL_OPTIMIZATION_STEPS.keys())
            angle_source = f"full catalog ({len(angle_order)} angles)"
        kernel_group = (kernel_spec or {}).get("group", "")
        if self.model_angles:
            for _model_angle in MODEL_CSL_OPT_STEPS:
                if _model_angle not in angle_order:
                    angle_order.append(_model_angle)
            angle_source += " + model angles"
        angle_order, angles_denied = self._filter_angles(angle_order, kernel_spec)
        summary["angles_denied"] = angles_denied
        summary["angle_source"] = angle_source
        summary["angle_whitelist"] = list(angle_order)
        summary["kernel_group"] = kernel_group
        logging.info("[optimize] angle whitelist for %s: source=%s, angles=%s",
                     kernel_name, angle_source, angle_order)

        # A3: track last accepted diff so the selector can avoid repeating.
        last_accepted_diff: Optional[str] = None
        last_accepted_angle: Optional[str] = None
        prev_best_code: Optional[str] = None

        attempt = 0
        while attempt < max_attempts:
            attempt += 1
            # A3: per-round angle selection via LLM. Falls back to round-robin
            # on parse/error failure. Uses the previous attempt index for
            # the round-robin fallback so coverage is still rotated.
            # Task #24: profile the current best code BEFORE asking the
            # selector to pick an angle. The static profiler emits a
            # bottleneck signature dict; the deterministic matcher uses it
            # to rank whitelist angles by how well they address the
            # detected patterns. Selector sees both the signature and the
            # ranked match — its job is then to confirm (or override) with
            # reasoning, not pick blind. When the profiler finds nothing
            # (kernel is already well-optimized at the pattern level), the
            # selector "widens the search" to free-form reasoning over the
            # full whitelist.
            #
            # For split-file kernels (target=src/kernel_<suffix>.csl),
            # load the sibling src/kernel.csl too so the profiler can see
            # @export_symbol blocks that live in the entrypoint file.
            sibling_csl_text: Optional[str] = None
            target_basename = os.path.basename(target_relpath)
            if target_basename.startswith("kernel_") and target_basename.endswith(".csl"):
                sibling_path = os.path.join(
                    os.path.dirname(os.path.join(reference_dir, target_relpath)),
                    "kernel.csl",
                )
                if os.path.isfile(sibling_path):
                    try:
                        with open(sibling_path, "r", encoding="utf-8") as fh:
                            sibling_csl_text = fh.read()
                    except Exception:
                        sibling_csl_text = None
            bottleneck_sig = self._profile_bottleneck_signature(best_code, sibling_csl=sibling_csl_text)
            # Inject runtime profiler bottleneck labels (from sim.log)
            # into the static signature so the angle selector can use them.
            # Use the profile of the code being edited (the current best), not of
            # the last candidate benchmarked -- after a rejected attempt those are
            # different programs.
            base_ctx = (best_result or {}).get("profiling_context") or {}
            if self.profile_feedback_enabled and base_ctx:
                label = base_ctx.get("sim_log_bottleneck") or ""
                if label == "stall-bound":
                    bottleneck_sig["bottlenecks"]["pe_stall_dominant"] = 1
                elif label == "fabric-bound":
                    bottleneck_sig["bottlenecks"]["fabric_comm_dominant"] = 1
                if (base_ctx.get("sram_utilization") or 0) > 0.85:
                    bottleneck_sig["bottlenecks"]["memory_pressure_high"] = 1
            model_readout = (best_result or {}).get("model_readout")
            if self.model_guided and model_readout:
                for _key in model_readout.get("model_keys") or []:
                    bottleneck_sig["bottlenecks"][_key] = 1
                bottleneck_sig["model_readout_text"] = model_readout.get("readout_text")
            if bottleneck_sig.get("bottlenecks"):
                logging.info("[optimize] attempt %d profiler: %s",
                             attempt, dict(bottleneck_sig["bottlenecks"]))
            # Combine spec.yaml's cross-run no-op history with IN-RUN
            # no-ops accumulated so far. An angle that's been tried in
            # this run and didn't improve cycles is just as "no-op" for
            # future picks within the same run as one recorded in
            # spec.yaml — the selector should skip both unless evidence
            # has changed (a different best_code base, the bottleneck
            # signature moved, etc.).
            spec_no_ops = list((kernel_spec or {}).get("attempted_no_op_angles") or [])
            in_run_no_ops_count: Dict[str, int] = {}
            for s in summary.get("steps", []):
                if s.get("selected"):
                    continue  # skip accepted attempts
                ang = s.get("angle") or s.get("selector_picked")
                if not ang:
                    continue
                in_run_no_ops_count[ang] = in_run_no_ops_count.get(ang, 0) + 1
            for ang, n in in_run_no_ops_count.items():
                spec_no_ops.append({
                    "angle": ang,
                    "runs_tried": n,
                    "last_attempted": f"this run, attempt history (×{n})",
                })

            # In-run HARD BAN: an angle tried ≥3 times this run with no
            # improvement gets removed from the whitelist passed to the
            # selector. Observed pattern in Opus PM run: selector picked
            # iterative_phase_fusion 5 times in a row because it was the
            # only angle matching the dominant bottleneck — selector kept
            # picking it even though no_op annotations said it had failed.
            # Hard ban forces the search to widen after saturation.
            IN_RUN_BAN_THRESHOLD = 3
            banned_this_run = {a for a, n in in_run_no_ops_count.items()
                               if n >= IN_RUN_BAN_THRESHOLD}
            effective_whitelist = [a for a in angle_order if a not in banned_this_run]
            if not effective_whitelist:
                # Don't ban EVERYTHING — fall back to full whitelist if
                # ban would leave us empty. The selector still sees
                # all the ✗ annotations and can pick the "least bad".
                effective_whitelist = list(angle_order)
                if banned_this_run:
                    logging.warning(
                        "[optimize] all angles banned this run (%s); "
                        "falling back to full whitelist",
                        sorted(banned_this_run),
                    )
            elif banned_this_run:
                logging.info(
                    "[optimize] attempt %d: hard-banning saturated angles %s "
                    "(tried ≥%d× this run without improvement)",
                    attempt, sorted(banned_this_run), IN_RUN_BAN_THRESHOLD,
                )

            step_name, step_reason = self._select_optimization_angle(
                whitelist=effective_whitelist,  # may exclude in-run banned angles
                round_robin_idx=attempt - 1,
                current_code=best_code,
                current_cycles=best_cycles,
                reference_cycles=baseline_cycles,  # whoever called us measured this
                kernel_group=kernel_group,
                per_fn_cycles=(best_result or {}).get("per_fn_cycles"),
                last_accepted_diff=last_accepted_diff,
                recent_attempts=summary.get("steps", []),  # tell selector what's already been tried
                proven_angles=(kernel_spec or {}).get("proven_angles") or [],
                attempted_no_op_angles=spec_no_ops,
                bottleneck_signature=bottleneck_sig,
            )
            angle_meta = angle_metadata(step_name)
            description = angle_meta["description"]
            logging.info("[optimize] attempt %d/%d: selector picked '%s' (reason: %s)",
                         attempt, max_attempts, step_name, step_reason[:120])

            # Task #21: distinct-angle best-of-N. When best_of > 1, generate
            # N candidates from N DIFFERENT angles instead of N variants of
            # the same one. The selector's pick is candidate 1's angle;
            # candidates 2..N walk the whitelist starting AFTER the picked
            # angle (skipping it). Gives strictly more coverage per attempt:
            # the selector's best guess PLUS adjacent levers that might
            # surprise. Falls back to repeating the same angle if N exceeds
            # whitelist length.
            n_candidates = max(1, int(self.best_of))
            # Use effective_whitelist (excludes in-run banned angles) for
            # the candidate rotation too — otherwise candidates 2..N could
            # include angles the selector just successfully avoided.
            picked_idx = effective_whitelist.index(step_name) if step_name in effective_whitelist else 0
            candidate_angles: List[str] = [step_name]
            for offset in range(1, n_candidates):
                # Rotate from one past the picked angle; if we run out of
                # distinct angles, wrap and reuse (rare for whitelists with
                # ≥3 entries and best_of ≤3).
                next_idx = (picked_idx + offset) % len(effective_whitelist)
                next_angle = effective_whitelist[next_idx]
                if next_angle in candidate_angles:
                    # Whitelist exhausted; just repeat the picked angle.
                    next_angle = step_name
                candidate_angles.append(next_angle)
            if n_candidates > 1:
                logging.info("[optimize] attempt %d/%d: best-of-%d angles = %s",
                             attempt, max_attempts, n_candidates, candidate_angles)

            # Phase 1c: if a branch from top_k[1] is queued, use it as the
            # base for THIS attempt's prompt instead of the global best.
            # The branch is one-shot — subsequent iterations resume normal
            # behavior (or get another branch if patience exhausts again,
            # but `branch_attempted` guards against that).
            attempt_base_code = best_code
            attempt_base_result = best_result
            attempt_base_cycles = best_cycles
            attempt_base_label = "best"
            if branch_from_code is not None:
                attempt_base_code = branch_from_code
                attempt_base_cycles = branch_from_cycles
                # Synthesize a benchmark-summary stub for the branch base.
                attempt_base_result = {
                    "status": "pass",
                    "cycles_send": branch_from_cycles,
                    "_branch_ancestry": branch_from_ancestry,
                }
                attempt_base_label = f"branch_from_top_k_{branch_from_ancestry[-1] if branch_from_ancestry else '?'}"
                logging.info("[optimize] attempt %d/%d: branching from top_k runner-up "
                             "(cycles=%d, ancestry=%s)",
                             attempt, max_attempts, branch_from_cycles, branch_from_ancestry)
                # Consume the branch — one-shot.
                branch_from_code = None
                branch_from_cycles = None
                branch_from_ancestry = None

            # Per-candidate prompt builder. Each candidate uses its OWN angle
            # (task #21), so retrieval + lever block + optimizer prompt all
            # need to be parameterized by the candidate's angle, not a single
            # attempt-wide angle.
            def _build_prompt_for_angle(angle_name: str) -> List[Dict[str, str]]:
                ang_meta = angle_metadata(angle_name)
                ang_desc = ang_meta["description"]
                prompt = q_optimize_csl_compute.format(
                    optimization_name=angle_name,
                    optimization_description=ang_desc,
                    frozen_callout_block=default_frozen_callout_block(
                        getattr(self, "kernel_spec", None)
                    ),
                    knowledge_base=csl_knowledge_base.for_optimization(
                        "\n".join([angle_name, ang_desc, attempt_base_code]),
                        kernel_group=kernel_group,
                        picked_angle=angle_name,
                        angle_query_hint=ang_meta.get("knowledge_query_hint", ""),
                        angle_source_skill=ang_meta.get("source_skill", ""),
                    ),
                    task_summary=task_summary or "(no task description; the kernel's spec.yaml was not loaded)",
                    reference_contract=reference_contract,
                    current_code=attempt_base_code,
                    current_cycles=attempt_base_cycles,
                    benchmark_summary=benchmark_summary_text(attempt_base_result),
                    profiler_feedback=(
                        ((attempt_base_result or {}).get("profile_feedback")
                         or self.latest_profiler_feedback)
                        if self.profile_feedback_enabled
                        else "(profile feedback disabled; using benchmark summary only)"
                    ),
                )
                return [
                    {"role": "system", "content": Instruction_system_csl_optimization},
                    {"role": "user", "content": prompt},
                ]

            # Phase 1b + task #21: best-of-N with N DISTINCT angles. Each
            # candidate gets its own prompt built from its own angle's
            # description + knowledge retrieval. Survivors are pooled and
            # the lowest-cycles one wins.
            candidate_records: List[Dict[str, object]] = []
            # The optimizer must emit the FULL modified compute file. A flat
            # 4096-token cap silently truncated large kernels (CG/PCG/BiCGSTAB
            # at 400-490 LOC) -> no parseable ```csl``` block -> 0 accepts
            # ("no_csl_block"). Scale the budget to the input: ~chars/4 tokens
            # to reproduce the file, x2.5 to cover the model's reasoning
            # preamble + the rewrite, +2048 headroom, floor 4096, ceiling
            # self.max_tokens. (Mined 2026-06-18: x1.6 still truncated CG's
            # structural-rewrite attempts — only the localized buffer_cleanup
            # edit fit; bumped to x2.5. Pass --max-tokens >= 12288 for big
            # kernels so the ceiling doesn't bind.)
            _gen_budget = min(self.max_tokens,
                              max(4096, int(len(best_code) / 4 * 2.5) + 2048))
            for cand_idx, cand_angle in enumerate(candidate_angles, start=1):
                cand_record: Dict[str, object] = {"cand_idx": cand_idx, "angle": cand_angle}
                try:
                    reply = self._llm_call(_build_prompt_for_angle(cand_angle),
                                           max_tokens=_gen_budget)
                except Exception as exc:
                    logging.warning("[optimize] LLM call failed on attempt %d cand %d (%s, %s); continuing",
                                    attempt, cand_idx, cand_angle, str(exc)[:120])
                    cand_record["status"] = "llm_error"
                    cand_record["reason"] = str(exc)[:300]
                    candidate_records.append(cand_record)
                    continue
                candidate = extract_code_block(reply, "csl")
                if not candidate:
                    cand_record["status"] = "no_csl_block"
                    cand_record["reason"] = "Model did not return a CSL code block."
                    candidate_records.append(cand_record)
                    continue
                # Mechanically enforce the frozen-function contract: overwrite any
                # frozen fn (timing fns f_tic/f_toc/f_*_timestamps) the model
                # perturbed with the reference's verbatim definition. Without this,
                # the optimizer regenerates the whole file and keeps tripping the
                # contract gate on a frozen *timing* fn it had no reason to touch —
                # observed killing 100% of optimize candidates on 7pt-Stencil (and
                # historically BiCGSTAB/CG). The model's real (non-frozen) compute
                # edits are preserved; only the frozen spans are restored. Gated so
                # the behavior is A/B-comparable. Default ON.
                if os.environ.get("XKERNEL_SPLICE_FROZEN", "1") == "1":
                    candidate, _spliced = splice_frozen_functions(
                        candidate, reference_compute_file, frozen_fns)
                    if _spliced:
                        cand_record["frozen_spliced"] = _spliced
                bench = self._benchmark_current_code(
                    kernel_name=kernel_name,
                    current_code=candidate,
                    reference_dir=reference_dir,
                    target_relpath=target_relpath,
                    num_runs=self.optimize_num_runs,
                    # W2 inner loop: rank by cycles only; skip held-out per-candidate
                    # (final confirmation below re-benchmarks the winner with it on).
                    heldout_eval=False,
                )
                violation = validate_contract(
                    variant_src=candidate,
                    reference_src=reference_compute_file,
                    frozen_functions=frozen_fns,
                    frozen_params=frozen_params,
                )
                cand_record.update({
                    "status": bench.get("status"),
                    "failure_reason": bench.get("failure_reason"),
                    "cycles_send": bench.get("cycles_send"),
                    "cycles_send_runs": bench.get("cycles_send_runs"),
                    "contract_violation": violation,
                    "_candidate": candidate,  # internal, stripped before summary
                    "_benchmark": bench,
                })
                candidate_records.append(cand_record)
                if self.keep_candidates:
                    _cmr = bench.get("model_readout") if isinstance(bench.get("model_readout"), dict) else {}
                    self.retained_candidates.append({
                        "attempt": attempt, "cand_idx": cand_idx, "angle": cand_angle, "accepted": False,
                        "predicted_cycles": _cmr.get("predicted_cycles"), "model_class": _cmr.get("bottleneck"),
                        "status": bench.get("status"), "success_marker": bench.get("success_marker"),
                        "cycles_send": bench.get("cycles_send"), "cycles_send_runs": bench.get("cycles_send_runs"),
                        "contract_violation": violation, "base_label": attempt_base_label,
                        "base_cycles": attempt_base_cycles, "code": candidate,
                    })

            # Pick the survivor: contract-passing AND status=pass AND
            # reported cycles_send. Among those, lowest cycles wins. If no
            # survivor, the attempt is a no-improvement.
            survivors = [
                r for r in candidate_records
                if r.get("contract_violation") is None
                and r.get("status") == "pass"
                and isinstance(r.get("cycles_send"), int)
                and r.get("cycles_send", 0) > 0
            ]
            if not survivors:
                # No usable candidate this attempt. Record summary and bump
                # patience counter. The summary captures every candidate
                # attempt for debugging.
                consecutive_no_improvement += 1
                # Use the first candidate's failure mode as the headline reason.
                headline = candidate_records[0] if candidate_records else {}
                reason_bits = []
                if headline.get("contract_violation"):
                    reason_bits.append(f"contract_violation: {headline['contract_violation']}")
                elif headline.get("status") != "pass":
                    reason_bits.append(f"status={headline.get('status')}")
                elif not isinstance(headline.get("cycles_send"), int):
                    reason_bits.append("no_cycles_reported")
                # Capture profiling context for reasoning analysis
                # Profile of the program this attempt started from.
                profiling_ctx = dict((attempt_base_result or {}).get("profiling_context") or {})

                step_record = {
                    "attempt": attempt,
                    "angle": step_name,
                    "selector_picked": step_name,
                    "bottleneck_signature": (bottleneck_sig or {}).get("bottlenecks"),
                    "profiling_context": profiling_ctx or None,
                    "best_of": n_candidates,
                    "best_of_angles": list(candidate_angles),
                    "status": headline.get("status", "no_candidate"),
                    "failure_reason": headline.get("failure_reason"),
                    "rejected_reason": "; ".join(reason_bits) or "no_survivor",
                    "best_cycles_before": best_cycles,
                    "selector_reason": step_reason,
                    "candidates": [
                        {k: v for k, v in r.items() if not k.startswith("_")}
                        for r in candidate_records
                    ],
                }
                logging.info("[optimize] attempt %d/%d (%s) best-of-%d: no survivor (%s)",
                             attempt, max_attempts, step_name, n_candidates,
                             step_record["rejected_reason"])
                summary["steps"].append(step_record)
            else:
                # Pick lowest-cycles survivor for the accept/reject decision.
                survivors.sort(key=lambda r: r["cycles_send"])
                winner = survivors[0]
                cand_cycles = int(winner["cycles_send"])
                benchmark = winner["_benchmark"]
                candidate = winner["_candidate"]
                winning_angle = winner.get("angle", step_name)
                # Profile of the accepted candidate itself.
                profiling_ctx_here = dict((benchmark or {}).get("profiling_context") or {})
                step_record = {
                    "attempt": attempt,
                    "angle": winning_angle,
                    "selector_picked": step_name,
                    "bottleneck_signature": (bottleneck_sig or {}).get("bottlenecks"),
                    "profiling_context": profiling_ctx_here or None,
                    "best_of": n_candidates,
                    "best_of_angles": list(candidate_angles),
                    "winner_cand_idx": winner["cand_idx"],
                    "status": benchmark.get("status"),
                    "failure_reason": benchmark.get("failure_reason"),
                    "run_time_ms": benchmark.get("run_time_ms"),
                    "cycles_send": cand_cycles,
                    "cycles_send_runs": benchmark.get("cycles_send_runs"),
                    "best_cycles_before": best_cycles,
                    "candidates": [
                        {k: v for k, v in r.items() if not k.startswith("_")}
                        for r in candidate_records
                    ],
                }
                # Input-split FINAL CONFIRMATION (anti-gaming): the inner loop ranks
                # candidates by cycles with held-out skipped (cost). Before ACCEPTING
                # a new best, re-benchmark the winner WITH the held-out gate on, so an
                # optimizer can't converge to a faster-but-hardcoded candidate. Only
                # runs when the kernel has an `eval:` block; cheap (one extra confirm
                # per accepted improvement, not per candidate).
                if (cand_cycles < best_cycles
                        and os.environ.get("XKERNEL_HELDOUT_EVAL", "1") != "0"
                        and resolve_eval(load_kernel_spec(reference_dir))):
                    confirm = self._benchmark_current_code(
                        kernel_name=kernel_name, current_code=candidate,
                        reference_dir=reference_dir, target_relpath=target_relpath,
                        num_runs=1, heldout_eval=True)
                    if confirm.get("status") != "pass":
                        logging.warning(
                            "[optimize] winner attempt %d rejected by held-out gate: %s",
                            attempt, str(confirm.get("failure_reason"))[:120])
                        step_record["status"] = "fail"
                        step_record["failure_reason"] = confirm.get("failure_reason")
                        step_record["heldout_rejected"] = True
                        summary["steps"].append(step_record)
                        consecutive_no_improvement += 1
                        continue
                if cand_cycles < best_cycles:
                    # A4: record the diff between the previous best and this
                    # new best so the next attempt's selector can see what
                    # just worked. Unified diff capped to 1500 chars (the
                    # selector prompt only takes the first 1500 anyway).
                    try:
                        import difflib as _difflib
                        prev_lines = (best_code or "").splitlines(keepends=True)
                        new_lines = candidate.splitlines(keepends=True)
                        diff = "".join(_difflib.unified_diff(
                            prev_lines, new_lines,
                            fromfile=f"best_before_a{attempt}",
                            tofile=f"best_after_a{attempt}_{step_name}",
                            n=2,  # 2 lines of context, keep diff compact
                        ))
                        last_accepted_diff = diff[:1500] if diff else None
                        last_accepted_angle = step_name
                    except Exception as exc:
                        logging.warning("[optimize] diff capture failed (%s); selector "
                                        "will see no last_diff on next round", str(exc)[:80])
                        last_accepted_diff = None
                    best_code = candidate
                    best_result = benchmark
                    best_cycles = cand_cycles
                    summary["selected_variant"] = f"attempt_{attempt}_{step_name}_cand{winner['cand_idx']}"
                    step_record["selected"] = True
                    step_record["cycles_delta"] = cand_cycles - step_record["best_cycles_before"]
                    step_record["selector_reason"] = step_reason
                    consecutive_no_improvement = 0
                    if self.keep_candidates:
                        for _rec in reversed(self.retained_candidates):
                            if _rec.get("attempt") == attempt and _rec.get("code") == candidate:
                                _rec["accepted"] = True
                                break
                    logging.info("[optimize] attempt %d/%d (%s) best-of-%d cand %d: cycles %d -> %d (Δ %+d). ACCEPTED.",
                                 attempt, max_attempts, step_name, n_candidates,
                                 winner["cand_idx"],
                                 step_record["best_cycles_before"], cand_cycles,
                                 step_record["cycles_delta"])
                else:
                    consecutive_no_improvement += 1
                    step_record["rejected_reason"] = (
                        f"cycles {cand_cycles} >= best {best_cycles} "
                        f"(best survivor of {n_candidates})"
                    )
                    step_record["selector_reason"] = step_reason
                    logging.info("[optimize] attempt %d/%d (%s) best-of-%d: rejected (%s). best stays at %d cycles.",
                                 attempt, max_attempts, step_name, n_candidates,
                                 step_record["rejected_reason"], best_cycles)
                # Phase 1c: top-K reservoir update. Every contract-passing
                # survivor is a candidate for the reservoir, even ones that
                # don't beat the current best — they're worth keeping for
                # the branch-on-stall path. Dedupe by code identity (avoid
                # the same variant appearing twice).
                if not any(e["code"] == candidate for e in top_k):
                    top_k.append({
                        "code": candidate,
                        "result": benchmark,
                        "cycles": cand_cycles,
                        "ancestry": [
                            *(top_k[0]["ancestry"] if not branch_attempted else []),
                            f"a{attempt}_{step_name}",
                        ][-3:],  # keep ancestry compact
                    })
                    top_k.sort(key=lambda e: e["cycles"])
                    if len(top_k) > TOP_K:
                        top_k = top_k[:TOP_K]
                step_record["top_k_after"] = [
                    {"cycles": e["cycles"], "ancestry": list(e["ancestry"])}
                    for e in top_k
                ]
                summary["steps"].append(step_record)

            # Early-termination after min_attempts if we've stalled. But
            # before terminating, give the top_k runner-up one rotation —
            # the current best lineage may have plateaued at a local
            # minimum that a different ancestor could escape.
            if (attempt >= min_attempts
                    and consecutive_no_improvement >= _OPTIMIZE_PATIENCE):
                if not branch_attempted and len(top_k) >= 2 and attempt < max_attempts:
                    branch_attempted = True
                    branch_from_code = top_k[1]["code"]
                    branch_from_cycles = top_k[1]["cycles"]
                    branch_from_ancestry = list(top_k[1]["ancestry"])
                    # Reset the patience counter — give the branch a fresh
                    # window. The min_attempts gate has already cleared.
                    consecutive_no_improvement = 0
                    logging.info(
                        "[optimize] patience exhausted on best lineage; "
                        "branching to top_k[1] (cycles=%d) for one rotation",
                        branch_from_cycles,
                    )
                    continue  # don't terminate yet; the next attempt uses the branch
                summary["terminated_reason"] = (
                    f"patience: {consecutive_no_improvement} consecutive no-improvements "
                    f"after {attempt} attempts (min_attempts={min_attempts})"
                    + (" (branch already attempted)" if branch_attempted else "")
                )
                logging.info("[optimize] %s", summary["terminated_reason"])
                break

        self.current_code = best_code
        summary["final_status"] = best_result.get("status")
        summary["final_run_time_ms"] = best_result.get("run_time_ms")
        summary["final_cycles_send"] = best_result.get("cycles_send")
        summary["attempts_used"] = attempt
        summary["cycle_reduction_pct"] = (
            round(100.0 * (baseline_cycles - best_cycles) / baseline_cycles, 3)
            if best_cycles < baseline_cycles else 0.0
        )
        # Persist the final top-K reservoir so post-hoc lineage analysis
        # can see the variant diversity the run discovered.
        summary["top_k"] = [
            {"cycles": e["cycles"], "ancestry": list(e["ancestry"])}
            for e in top_k
        ]
        summary["branch_attempted"] = branch_attempted

        # Reasoning reflection: document what profiling data was available
        # and how it influenced angle selection across the optimization run.
        reflection = {
            "profile_feedback_enabled": self.profile_feedback_enabled,
            "trace_profile_enabled": bool(
                self.profile_feedback_enabled
                and self.profile_log
                and any((p.get("artifacts") or {}).get("trace_profile") for p in self.profile_log)
            ),
            "angles_tried": [],
            "angles_accepted": [],
            "profiling_signals_seen": set(),
        }
        for step in summary.get("steps", []):
            reflection["angles_tried"].append(step.get("angle", "?"))
            if step.get("selected"):
                reflection["angles_accepted"].append({
                    "angle": step.get("angle"),
                    "cycles_delta": step.get("cycles_delta"),
                    "profiling_context": step.get("profiling_context"),
                })
            ctx = step.get("profiling_context") or {}
            for k in ctx:
                if ctx[k] is not None:
                    reflection["profiling_signals_seen"].add(k)
        reflection["profiling_signals_seen"] = sorted(reflection["profiling_signals_seen"])
        summary["reasoning_reflection"] = reflection

        return best_code, best_result, summary


def build_version_trace(run_log: List[Dict[str, object]],
                        optimization_summary: Dict[str, object],
                        reference_baseline: Optional[Dict[str, object]]) -> Dict[str, object]:
    """W1 per-version trace (cycles + ms vs CSL reference).

    Walks `run_log` (translate-loop attempts) and `optimization_summary['steps']`
    (optimizer attempts), normalizes each into a flat row, and computes
    per-row deltas vs the human-written reference compute file's benchmark
    numbers. The reference's measurement is taken once at the top of main()
    (with optimize_num_runs samples) and passed in here.

    Output schema:
      {
        "reference": {"cycles_send": N, "run_time_ms": M, "num_runs": K},
        "versions": [
          {"phase": "translate"|"optimize", "attempt": 1, "status": ...,
           "cycles_send": N, "run_time_ms": M, "accepted": true|false,
           "vs_ref_cycles_pct": -49.6, "vs_ref_ms_pct": +2.1,
           "angle": "comptime_cleanup" (optimize only)},
          ...
        ],
        "summary": {
          "first_passing_attempt": int|null,  # which translate attempt first passed
          "best_cycles": int|null,
          "best_vs_ref_cycles_pct": float|null,
        }
      }

    A negative percent means "faster than reference"; positive means slower.
    """
    ref_cycles = (reference_baseline or {}).get("cycles_send") if reference_baseline else None
    ref_ms = (reference_baseline or {}).get("run_time_ms") if reference_baseline else None

    def _pct(value, ref):
        # Skip if either side is missing/invalid, OR if the value is 0
        # (which usually means "didn't run", not "ran in zero ms" — the
        # translate-loop's compile-failed entries report run_time_ms=0).
        if not isinstance(value, (int, float)) or not isinstance(ref, (int, float)):
            return None
        if ref <= 0 or value <= 0:
            return None
        return round(100.0 * (value - ref) / ref, 3)

    versions: List[Dict[str, object]] = []
    # Translate-loop attempts come from run_log. Each entry has status,
    # cycles_send, run_time_ms — these are the agent's iterations toward
    # the first working CSL.
    first_passing_attempt = None
    for i, entry in enumerate(run_log, start=1):
        cyc = entry.get("cycles_send")
        ms = entry.get("run_time_ms")
        status = entry.get("status")
        if status == "pass" and first_passing_attempt is None:
            first_passing_attempt = i
        versions.append({
            "phase": "translate",
            "attempt": i,
            "status": status,
            "failure_reason": entry.get("failure_reason"),
            "cycles_send": cyc,
            "cycles_send_runs": entry.get("cycles_send_runs"),
            "run_time_ms": ms,
            "vs_ref_cycles_pct": _pct(cyc, ref_cycles),
            "vs_ref_ms_pct": _pct(ms, ref_ms),
            "accepted": status == "pass",
        })
    # Optimizer attempts come from optimization_summary["steps"]. Each
    # records cycles_send (median across cycles_send_runs), winner_cand_idx,
    # selected flag.
    for step in (optimization_summary or {}).get("steps", []):
        cyc = step.get("cycles_send")
        versions.append({
            "phase": "optimize",
            "attempt": step.get("attempt"),
            "angle": step.get("angle"),
            "best_of": step.get("best_of"),
            "winner_cand_idx": step.get("winner_cand_idx"),
            "status": step.get("status"),
            "failure_reason": step.get("failure_reason"),
            "cycles_send": cyc,
            "cycles_send_runs": step.get("cycles_send_runs"),
            "run_time_ms": step.get("run_time_ms"),
            "vs_ref_cycles_pct": _pct(cyc, ref_cycles),
            "vs_ref_ms_pct": _pct(step.get("run_time_ms"), ref_ms),
            "accepted": bool(step.get("selected", False)),
            "rejected_reason": step.get("rejected_reason"),
            "contract_violation": step.get("contract_violation"),
        })
    # Headline summary numbers.
    accepted_cycles = [v["cycles_send"] for v in versions
                       if v.get("accepted") and isinstance(v.get("cycles_send"), int)]
    best_cycles = min(accepted_cycles) if accepted_cycles else None
    return {
        "reference": {
            "cycles_send": ref_cycles,
            "run_time_ms": ref_ms,
            "num_runs": (reference_baseline or {}).get("num_runs") if reference_baseline else None,
        },
        "versions": versions,
        "summary": {
            "first_passing_attempt": first_passing_attempt,
            "best_cycles": best_cycles,
            "best_vs_ref_cycles_pct": _pct(best_cycles, ref_cycles),
            "n_versions": len(versions),
            "n_accepted": sum(1 for v in versions if v.get("accepted")),
        },
    }


def write_final_artifacts(kernel_output_dir: str,
                          target_relpath: str,
                          translated_code: str,
                          metadata: Dict[str, object],
                          env_report: Dict[str, object],
                          benchmark_result: Dict[str, object],
                          optimization_summary: Dict[str, object],
                          history: List[Dict[str, str]],
                          run_log: List[Dict[str, object]],
                          profile_log: Optional[List[Dict[str, object]]] = None,
                          reference_baseline: Optional[Dict[str, object]] = None,
                          retained_candidates: Optional[List[Dict[str, object]]] = None) -> None:
    translated_path = os.path.join(kernel_output_dir, target_relpath)
    ensure_directory(os.path.dirname(translated_path))
    with open(translated_path, "w", encoding="utf-8") as fh:
        fh.write(translated_code)

    save_json(metadata, os.path.join(kernel_output_dir, "bundle_metadata.json"))
    save_json(env_report, os.path.join(kernel_output_dir, "env_check.json"))
    save_json(benchmark_result, os.path.join(kernel_output_dir, "benchmark.json"))
    save_json(optimization_summary, os.path.join(kernel_output_dir, "optimization_summary.json"))
    save_json({"messages": history}, os.path.join(kernel_output_dir, "translation_log.json"))
    save_json({"attempts": run_log}, os.path.join(kernel_output_dir, "final_result.json"))
    # W1 per-version trace: every version (translate attempts + optimize
    # attempts) compared against the human-written CSL reference's
    # cycles_send + run_time_ms. The reference is measured separately by
    # main() (NOT shown to the agent — that invariant still holds; we just
    # measure it on the same harness so the trace is honest).
    version_trace = build_version_trace(run_log, optimization_summary, reference_baseline)
    save_json(version_trace, os.path.join(kernel_output_dir, "version_trace.json"))
    # Optimizer candidates (XKERNEL_KEEP_CANDIDATES / XKERNEL_HW_CONFIRM=batch):
    # one directory per benchmarked candidate with its compute file and a
    # meta.json, plus an index without the code. hw_replay.py --versions
    # replays them on the appliance simulator and WSE-3.
    if retained_candidates:
        cand_root = os.path.join(kernel_output_dir, "candidates")
        index: List[Dict[str, object]] = []
        for rec in retained_candidates:
            label = "attempt_00_baseline" if rec.get("attempt", 0) == 0 else \
                f"attempt_{int(rec.get('attempt', 0)):02d}_cand{int(rec.get('cand_idx', 1))}_{rec.get('angle', 'angle')}"
            cdir = os.path.join(cand_root, label)
            ensure_directory(cdir)
            code = rec.get("code")
            if isinstance(code, str) and code:
                cpath = os.path.join(cdir, target_relpath)
                ensure_directory(os.path.dirname(cpath))
                with open(cpath, "w", encoding="utf-8") as fh:
                    fh.write(code)
            meta = {k: v for k, v in rec.items() if k != "code"}
            meta.update({"label": label, "target_relpath": target_relpath,
                         "reference_dir": metadata.get("reference_dir"),
                         "commands_script": metadata.get("commands_script")})
            save_json(meta, os.path.join(cdir, "meta.json"))
            index.append(meta)
        save_json({"candidates": index}, os.path.join(cand_root, "index.json"))

    # LLM usage (provider-reported token counts for every call in this process).
    try:
        import workflow_common as _wc
        if _wc.USAGE_LOG:
            save_json(_wc.usage_summary(), os.path.join(kernel_output_dir, "usage_log.json"))
    except Exception as exc:  # accounting must never fail a run
        logging.warning("[artifacts] usage_log.json not written: %s", exc)
    if profile_log:
        save_json({"profiles": profile_log}, os.path.join(kernel_output_dir, "profiler_feedback.json"))
        latest_feedback = str(profile_log[-1].get("agent_feedback") or "").strip()
        if latest_feedback:
            with open(os.path.join(kernel_output_dir, "profiler_feedback.txt"), "w", encoding="utf-8") as fh:
                fh.write(latest_feedback + "\n")


def main() -> None:
    parser = argparse.ArgumentParser(description="CUDA -> CSL translation workflow")
    parser.add_argument("--kernel", type=str, default="GEMV", help="Named kernel pair to translate")
    parser.add_argument("--cuda", type=str, help="Path to a CUDA source file")
    parser.add_argument("--reference-csl-dir", type=str, help="Path to a reference CSL bundle directory")
    parser.add_argument("--target-relpath", type=str, default=None,
                        help="Compute file path inside the CSL bundle (for ad hoc mode)")
    parser.add_argument("--backend", type=str, default="openai", choices=["openai"],
                        help="OpenAI-compatible backend")
    parser.add_argument("--api-key-file", type=str, default=DEFAULT_API_KEY_FILE)
    parser.add_argument("--api-key-command", type=str, default=None,
                        help="Shell command that prints an API key/token; takes precedence over --api-key-file.")
    parser.add_argument("--base-url", type=str, default=None,
                        help="Optional OpenAI-compatible base URL override")
    parser.add_argument("--alcf-endpoint", type=str, choices=sorted(ALCF_ENDPOINTS), default=None,
                        help="Use an ALCF inference endpoint preset and its default model.")
    parser.add_argument("--model", type=str, default=None)
    parser.add_argument("--analysis-model", type=str, default=None,
                        help="Cheaper model for the CUDA analysis phase (default: same as --model)")
    parser.add_argument("--max-tokens", type=int, default=8192)
    parser.add_argument("--turns", type=int, default=4,
                        help="Max translation repair turns")
    parser.add_argument("--skip-analyse", action="store_true",
                        help="Bypass the analyse_cuda LLM call — one-shot baseline mode "
                             "(translate prompt receives a placeholder for the analysis section).")
    parser.add_argument("--skip-planner", action="store_true",
                        help="Bypass the mesh-decomposition planner LLM call. "
                             "Use with --skip-analyse for a literally-one-LLM-call baseline.")
    parser.add_argument("--skip-reviewer", action="store_true",
                        help="Bypass the reviewer agent — all failures route to the "
                             "implementer with the legacy fix prompt (pre-reviewer baseline).")
    parser.add_argument("--reviewer-max-attempts", type=int, default=10,
                        help="Total benchmark+repair attempt cap when the reviewer is "
                             "active. Ignored when --skip-reviewer is set (falls back "
                             "to --turns).")
    parser.add_argument("--no-knowledge", action="store_true",
                        help="BASELINE ABLATION (soft): strip all curated/retrieved "
                             "knowledge (TIER-A: RAG, gotchas, tutorials, skills, mesh "
                             "patterns, optimizer experience). Keeps the CSL language "
                             "primer (TIER-B) and structure (TIER-C: layout.csl, "
                             "contract, CUDA source, builtin whitelist). Sets "
                             "XKERNEL_NO_KNOWLEDGE=1. Keep the reviewer ACTIVE (do not "
                             "pass --skip-reviewer, which caps the loop at --turns) and "
                             "pair with --reviewer-max-attempts 20 to loop toward a pass.")
    parser.add_argument("--bare", action="store_true",
                        help="BASELINE ABLATION (hard): with --no-knowledge, ALSO strip "
                             "the CSL language primer (TIER-B). The for_* knowledge "
                             "functions return empty; only TIER-C template structure "
                             "remains. Sets XKERNEL_BARE=1. No effect without "
                             "--no-knowledge.")
    parser.add_argument("--sdk-root", type=str, default=default_sdk_root())
    parser.add_argument("--target-sdk", type=str, default=os.getenv("XKERNEL_TARGET_SDK", "1.4.0"),
                        help="Target Cerebras SDK version for compatibility-aware knowledge retrieval.")
    parser.add_argument("--arch", type=str, default="wse3")
    parser.add_argument("--commands-script", type=str, default=None)
    parser.add_argument("--size", type=str, default=None,
                        help="Problem-size axis (Phase-2): name of a size under spec.yaml "
                             "`sizes:` (e.g. small, large). Selects that size's "
                             "commands_script + reference baseline. Default: 'small' if "
                             "present else the legacy single size.")
    parser.add_argument("--shell-setup", type=str, default=None,
                        help="Shell commands to run before SDK probes and staged bundle commands.")
    parser.add_argument("--shell-setup-file", type=str, default=None,
                        help="Path to a bash snippet to source before SDK probes and staged bundle commands.")
    parser.add_argument("--optimize-only", action="store_true",
                        help="Workflow 2: skip analyse/design/translate; load an existing "
                             "CSL file (--csl-path or the kernel's reference compute file) "
                             "as the starting point, benchmark it for the cycle baseline, "
                             "then enter the cycle-reduction optimize() loop. The agent does "
                             "NOT see the reference as 'reference' — only as 'current code at "
                             "N cycles'. See code_translation/REPIVOT_CYCLES.md.")
    parser.add_argument("--csl-path", type=str, default=None,
                        help="Override the starting CSL file for --optimize-only. If omitted, "
                             "uses the kernel's reference compute file (kernels/<name>/CSL/...)")
    parser.add_argument("--optimize", action="store_true")
    parser.add_argument("--auto-optimize", action="store_true",
                        help="After translate() returns a passing benchmark with a cycles_send "
                             "measurement, automatically enter the cycle-reduction optimize() "
                             "loop. Implies --optimize. Per the cycle-reduction repivot "
                             "(see code_translation/REPIVOT_CYCLES.md), this is the standard "
                             "workflow for CUDA→CSL translation runs.")
    parser.add_argument("--min-optimize-attempts", type=int, default=5,
                        help="Optimizer min attempts before patience-based termination.")
    parser.add_argument("--max-optimize-attempts", type=int, default=10,
                        help="Optimizer max attempts (hard cap).")
    parser.add_argument("--steps", type=str, default=",".join(DEFAULT_CSL_OPT_STEPS))
    parser.add_argument("--profile-feedback", action="store_true",
                        help="Build profiler feedback from each staged CSL benchmark and inject it into optimization prompts.")
    parser.add_argument("--keep-profile-bundles", action="store_true",
                        help="Keep staged bundles used for profiler artifact inspection.")
    parser.add_argument("--rl-bandit", action="store_true",
                        help="Use Thompson Sampling bandit for step selection")
    parser.add_argument("--rl-mcts", action="store_true",
                        help="Use MCTS tree search for step sequencing")
    parser.add_argument("--mcts-budget", type=int, default=20,
                        help="Max MCTS node evaluations per run (default 20)")
    parser.add_argument("--best-of", type=int, default=1,
                        help="Generate N LLM candidates per step and keep best (default 1)")
    parser.add_argument("--measure-reference", dest="measure_reference",
                        action="store_true", default=True,
                        help="Measure the human CSL reference once at start so "
                             "every translate/optimize version's cycles + ms can be "
                             "compared to it in version_trace.json. ON by default; "
                             "the reference is NEVER shown to the agent — the "
                             "compute-leak invariant still holds.")
    parser.add_argument("--no-measure-reference", dest="measure_reference",
                        action="store_false",
                        help="Skip the reference measurement (saves one benchmark "
                             "round). version_trace.json then has reference=None.")
    parser.add_argument("--num-runs", type=int, default=1,
                        help="Repeat cs_python run.py N times per benchmark "
                             "for ad-hoc translate-loop measurements. Default "
                             "1 preserves pre-Phase-1a single-sample behavior.")
    parser.add_argument("--optimize-num-runs", type=int, default=3,
                        help="Repeat cs_python run.py N times per optimizer "
                             "variant; the median cycles_send is the accept "
                             "signal. Default 3 kills the ~20-30%% simulator "
                             "noise without paying a 5× wall-clock cost.")
    parser.add_argument("--max-contract-chars", type=int,
                        default=int(os.getenv("XKERNEL_MAX_CONTRACT_CHARS", "12000")),
                        help="If the reference_contract (run.py + commands.sh) "
                             "exceeds this length, run.py is compressed to a "
                             "host-protocol digest. Unblocks no_csl_block on "
                             "PCG/BiCGSTAB where the full contract is too large "
                             "for the implementer's output budget. (default 12000)")
    parser.add_argument("--check-env", action="store_true")
    parser.add_argument("--output", type=str, default=DEFAULT_OUTPUT)
    parser.add_argument("--work-root", type=str, default=DEFAULT_WORK_ROOT)
    args = parser.parse_args()

    os.environ["XKERNEL_TARGET_SDK"] = args.target_sdk
    os.environ["XKERNEL_TARGET_ARCH"] = args.arch

    # Baseline-ablation mode. Set the env vars the knowledge_tier() chokepoint
    # in csl_knowledge_base reads, BEFORE any for_* knowledge call fires.
    if args.no_knowledge:
        os.environ["XKERNEL_NO_KNOWLEDGE"] = "1"
        # TIER-C builtin whitelist stays ON (it is necessary structure, not
        # knowledge) — do not disable XKERNEL_BUILTIN_WHITELIST here.
        if args.bare:
            os.environ["XKERNEL_BARE"] = "1"
        tier = "bare" if args.bare else "soft"
        if args.skip_reviewer:
            # --skip-reviewer routes the loop limit to --turns (default 4),
            # defeating the point of a loop-to-cap baseline. Warn loudly; the
            # operator almost certainly wants the reviewer ON with empty
            # knowledge, not bypassed.
            logging.warning(
                "[cuda2csl] --no-knowledge with --skip-reviewer: the repair "
                "loop will cap at --turns (%d), NOT --reviewer-max-attempts. "
                "For a loop-to-cap baseline, drop --skip-reviewer.",
                args.turns)
        logging.info(
            "[cuda2csl] BASELINE ABLATION active: knowledge tier=%s "
            "(TIER-A stripped%s; TIER-C structure kept). reviewer=%s, "
            "reviewer_max_attempts=%d",
            tier,
            ", TIER-B CSL primer also stripped" if args.bare else
            ", TIER-B CSL primer kept",
            "skipped" if args.skip_reviewer else "active",
            args.reviewer_max_attempts)
    elif args.bare:
        logging.warning(
            "[cuda2csl] --bare has no effect without --no-knowledge; ignoring.")
    shell_setup = load_shell_setup(args.shell_setup, args.shell_setup_file)
    endpoint_config = ALCF_ENDPOINTS.get(args.alcf_endpoint or "")
    effective_base_url = args.base_url or (endpoint_config["base_url"] if endpoint_config else None)
    effective_model = args.model or (
        endpoint_config["default_model"] if endpoint_config else DEFAULT_MODEL
    )
    env_report = build_env_report(
        args.api_key_file,
        args.sdk_root,
        api_key_command=args.api_key_command,
        base_url=effective_base_url,
        model=effective_model,
        alcf_endpoint=args.alcf_endpoint,
        shell_setup=shell_setup,
    )
    if args.check_env:
        print(json.dumps(env_report, indent=2))
        return

    spec = resolve_kernel_inputs(args)
    kernel_name = spec["kernel_name"]
    reference_dir = spec["reference_csl_dir"]
    target_relpath = spec["target_relpath"]
    commands_script = spec["commands_script"]
    cuda_path = spec["cuda_path"]

    output_root = timestamped_output_dir(expand_path(args.output), "run")
    kernel_output_dir = ensure_directory(os.path.join(output_root, kernel_name))
    save_json(env_report, os.path.join(kernel_output_dir, "env_check.json"))

    cuda_code = load_text(cuda_path)
    reference_contract, reference_compute, layout_text = build_reference_contract(
        reference_dir=reference_dir,
        target_relpath=target_relpath,
        commands_script=commands_script,
        max_chars=args.max_contract_chars,
    )

    # Load kernels/<name>/spec.yaml if present. Used by the optimizer to
    # describe the task to the agent without showing it the reference CSL.
    # When absent the optimizer runs without a task hint.
    kernel_spec = load_kernel_spec(reference_dir)
    task_summary = spec_task_summary(kernel_spec)
    if kernel_spec:
        logging.info("[main] loaded kernel spec for %s (group=%s, difficulty=%s)",
                     kernel_spec.get("kernel_id", kernel_name),
                     kernel_spec.get("group", "?"),
                     kernel_spec.get("difficulty", "?"))

    orchestrator = CUDA2CSLOrchestrator(
        model=effective_model,
        api_key_file=args.api_key_file,
        api_key_command=args.api_key_command,
        base_url=effective_base_url,
        max_tokens=args.max_tokens,
        turns_limit=args.turns,
        work_root=expand_path(args.work_root),
        sdk_root=args.sdk_root,
        arch=spec["arch"],
        commands_script=commands_script,
        shell_setup=shell_setup,
        analysis_model=args.analysis_model,
        target_sdk=args.target_sdk,
        profile_feedback_enabled=args.profile_feedback,
        keep_profile_bundles=args.keep_profile_bundles,
        skip_analyse=args.skip_analyse,
        skip_planner=args.skip_planner,
        skip_reviewer=args.skip_reviewer,
        reviewer_max_attempts=args.reviewer_max_attempts,
        num_runs=args.num_runs,
        optimize_num_runs=args.optimize_num_runs,
    )
    # Phase 1b: --best-of N generates N candidates per optimizer attempt and
    # keeps the best (lowest median cycles among contract-passing variants).
    orchestrator.best_of = max(1, int(args.best_of))
    # WS4.1: steer the implementer's promoted-optimization hints by kernel group.
    orchestrator.kernel_group = str((kernel_spec or {}).get("group", "") or "")

    # W1 per-version trace: measure the human CSL reference ONCE up front
    # so every translate/optimize version's cycles + ms have a real
    # comparison point in version_trace.json. The agent NEVER sees this
    # measurement — we run the reference through the same harness it
    # would use, but the result lives only in the trace file. The
    # compute-leak guard ensures the canary still trips if the reference
    # ever bleeds into a prompt.
    reference_baseline_for_trace: Optional[Dict[str, object]] = None
    if args.measure_reference:
        import tempfile as _tmp
        try:
            with _tmp.TemporaryDirectory(prefix=f"{kernel_name.lower()}_refbench_",
                                          dir=expand_path(args.work_root)) as _refwork:
                ref_path = os.path.join(reference_dir, target_relpath)
                ref_bench = benchmark_translated_compute_file(
                    translated_path=ref_path,
                    reference_dir=reference_dir,
                    target_relpath=target_relpath,
                    work_dir=_refwork,
                    sdk_root=args.sdk_root,
                    shell_setup=shell_setup,
                    commands_script=commands_script,
                    arch=spec["arch"],
                    num_runs=orchestrator.optimize_num_runs,
                )
            reference_baseline_for_trace = {
                "cycles_send": ref_bench.get("cycles_send"),
                "cycles_send_runs": ref_bench.get("cycles_send_runs"),
                "run_time_ms": ref_bench.get("run_time_ms"),
                "compile_time_ms": ref_bench.get("compile_time_ms"),
                "num_runs": ref_bench.get("num_runs"),
                "status": ref_bench.get("status"),
            }
            logging.info("[main] reference baseline: status=%s cycles_send=%s run_time_ms=%s "
                         "(num_runs=%s) — used ONLY for version_trace.json, NEVER shown to agent",
                         ref_bench.get("status"),
                         ref_bench.get("cycles_send"),
                         ref_bench.get("run_time_ms"),
                         ref_bench.get("num_runs"))
        except Exception as exc:
            logging.warning("[main] reference baseline measurement failed (%s); "
                            "version_trace.json will have reference=None",
                            str(exc)[:200])
            reference_baseline_for_trace = None

    if args.optimize_only:
        # Workflow 2: load an existing CSL as the starting point, benchmark
        # it for the cycle baseline, then go straight to optimize(). No
        # CUDA, no architect, no implementer-first-pass; just the cycle
        # reduction loop. Per REPIVOT_CYCLES.md the optimizer doesn't see
        # the reference labeled as "reference" — only as "current code".
        #
        # In W2 the input CSL IS shown to the optimizer (labeled
        # "current code at N cycles") — that's the whole point of W2.
        # The compute-leak guard, which is designed for W1's stronger
        # "hidden compute" contract, must be disarmed here or it fires on
        # every legitimate optimizer prompt. The contract validator
        # (validate_contract) still catches gaming attempts.
        orchestrator._w2_disarm_compute_canary = True
        csl_input_path = expand_path(args.csl_path) if args.csl_path else (
            os.path.join(reference_dir, target_relpath)
        )
        if not os.path.isfile(csl_input_path):
            raise SystemExit(f"--optimize-only: CSL input not found at {csl_input_path}")
        logging.info("[main] --optimize-only: loading CSL from %s", csl_input_path)
        translated_code = load_text(csl_input_path)
        orchestrator.current_code = translated_code
        # Benchmark the input to get the cycle baseline. Use optimize_num_runs
        # so the baseline median is measured on the same number of samples
        # as later optimizer variants — fair apples-to-apples comparison.
        benchmark_result = orchestrator._benchmark_current_code(
            kernel_name=kernel_name,
            current_code=translated_code,
            reference_dir=reference_dir,
            target_relpath=target_relpath,
            num_runs=orchestrator.optimize_num_runs,
        )
        if benchmark_result.get("status") != "pass":
            logging.warning("[main] --optimize-only: baseline CSL failed benchmark "
                            "(status=%s) — optimize() will skip with no baseline",
                            benchmark_result.get("status"))
        else:
            base_cyc = benchmark_result.get("cycles_send")
            logging.info("[main] --optimize-only: baseline status=pass, cycles_send=%s",
                         base_cyc)
        # Auto-optimize is implied by --optimize-only; force --optimize on
        # so the post-translate path enters optimize() unconditionally.
        args.optimize = True
    else:
        _contract_for_translate = reference_contract
        if orchestrator.codesign_layout:
            # Co-design mode hides the reference layout and arms a layout
            # canary. The library-signatures block was built FROM the layout
            # text and may contain canary-matching lines (e.g. @set_tile_code
            # patterns). Strip the library-signatures section so the canary
            # doesn't fire on the contract itself.
            _lib_header = "## Library module signatures"
            if _lib_header in _contract_for_translate:
                _contract_for_translate = _contract_for_translate[
                    :_contract_for_translate.index(_lib_header)
                ].rstrip()
                logging.info("[main] co-design: stripped library-signatures from "
                             "reference contract (layout is hidden)")
        translated_code, benchmark_result = orchestrator.translate(
            kernel_name=kernel_name,
            cuda_code=cuda_code,
            reference_dir=reference_dir,
            target_relpath=target_relpath,
            reference_contract=_contract_for_translate,
            reference_compute_file=reference_compute,
            task_summary=task_summary,
            layout_text=layout_text,
        )

    optimization_summary: Dict[str, object] = {"skipped": "Optimization not requested."}
    optimize_requested = (args.optimize or args.auto_optimize
                          or args.rl_bandit or args.rl_mcts)
    if optimize_requested:
        # Auto-optimize gate: only enter the cycle-reduction loop if the
        # translation step actually produced a passing benchmark with a
        # measurable cycles_send. Otherwise the optimizer would skip with
        # "no baseline cycles" — log that explicitly so the run record
        # is honest about why no optimization happened.
        if args.auto_optimize and not args.optimize:
            if benchmark_result.get("status") != "pass":
                optimization_summary = {
                    "skipped": (
                        "--auto-optimize: translation did not produce a passing "
                        f"benchmark (status={benchmark_result.get('status')}); "
                        "cycle-reduction loop requires a passing baseline."
                    )
                }
                logging.info("[main] %s", optimization_summary["skipped"])
            elif not isinstance(benchmark_result.get("cycles_send"), int):
                optimization_summary = {
                    "skipped": (
                        "--auto-optimize: translation passed but did not report "
                        "cycles_send; cycle-reduction loop has no baseline target."
                    )
                }
                logging.info("[main] %s", optimization_summary["skipped"])
            else:
                logging.info("[main] --auto-optimize: translation passed with "
                             "cycles_send=%d, entering optimize() loop "
                             "(min=%d, max=%d)",
                             benchmark_result["cycles_send"],
                             args.min_optimize_attempts,
                             args.max_optimize_attempts)
        requested_steps = [step.strip() for step in args.steps.split(",") if step.strip()]
        common_kwargs = dict(
            kernel_name=kernel_name,
            reference_dir=reference_dir,
            target_relpath=target_relpath,
            reference_contract=reference_contract,
            reference_compute_file=reference_compute,
            baseline_result=benchmark_result,
            all_steps=requested_steps,
            experience_store=orchestrator._exp_store,
            model=args.model,
        )
        if args.rl_bandit:
            from rl_bandit_optimizer import bandit_optimize
            translated_code, benchmark_result, optimization_summary = bandit_optimize(
                orchestrator=orchestrator,
                n_rounds=len(requested_steps),
                **common_kwargs,
            )
        elif args.rl_mcts:
            from rl_mcts_optimizer import mcts_optimize
            translated_code, benchmark_result, optimization_summary = mcts_optimize(
                orchestrator=orchestrator,
                budget=args.mcts_budget,
                **common_kwargs,
            )
        else:
            # Only call optimize() if the baseline passed with cycles_send,
            # OR if the user passed --optimize explicitly (legacy path which
            # the optimize() method itself guards against missing baseline).
            if (args.auto_optimize
                    and benchmark_result.get("status") == "pass"
                    and isinstance(benchmark_result.get("cycles_send"), int)) or args.optimize:
                translated_code, benchmark_result, optimization_summary = orchestrator.optimize(
                    kernel_name=kernel_name,
                    reference_dir=reference_dir,
                    target_relpath=target_relpath,
                    reference_contract=reference_contract,
                    reference_compute_file=reference_compute,
                    baseline_result=benchmark_result,
                    requested_steps=requested_steps,
                    min_attempts=args.min_optimize_attempts,
                    max_attempts=args.max_optimize_attempts,
                    task_summary=task_summary,
                    kernel_spec=kernel_spec,
                )

    metadata = {
        "kernel": kernel_name,
        "source_cuda_path": cuda_path,
        "reference_dir": reference_dir,
        "target_relpath": target_relpath,
        "commands_script": commands_script,
        "arch": spec["arch"],
        "target_sdk": args.target_sdk,
        "model": effective_model,
        "backend": args.backend,
        "api_key_file": expand_path(args.api_key_file) if not args.api_key_command else None,
        "api_key_source": "command" if args.api_key_command else "file_or_env",
        "base_url": effective_base_url,
        "alcf_endpoint": args.alcf_endpoint,
        "shell_setup": shell_setup,
        "profile_feedback": args.profile_feedback,
    }
    write_final_artifacts(
        kernel_output_dir=kernel_output_dir,
        target_relpath=target_relpath,
        translated_code=translated_code,
        metadata=metadata,
        env_report=env_report,
        benchmark_result=benchmark_result,
        optimization_summary=optimization_summary,
        history=orchestrator.history,
        run_log=orchestrator.run_log,
        profile_log=orchestrator.profile_log,
        reference_baseline=reference_baseline_for_trace,
        retained_candidates=getattr(orchestrator, "retained_candidates", None),
    )

    print(json.dumps({
        "kernel": kernel_name,
        "output_dir": kernel_output_dir,
        "status": benchmark_result.get("status"),
        "failure_reason": benchmark_result.get("failure_reason"),
        "run_time_ms": benchmark_result.get("run_time_ms"),
    }, indent=2))


if __name__ == "__main__":
    main()
