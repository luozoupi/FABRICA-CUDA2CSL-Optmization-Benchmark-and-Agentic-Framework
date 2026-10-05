#!/usr/bin/env python3
"""The task sets of the model-guided optimization study, as data.

`docs/IPDPS_PREREG.md` defines the sets in prose; this module is the machine-
readable copy that sweep commands and the work partition are generated from, so
two accounts cannot disagree about which kernels belong to a cell.

Sets
  H  single-PE operators: one PE does the arithmetic, the timed window is
     in-kernel, and every one of them is hardware-comparable today.
  M  multi-PE kernels whose references carry the device-internal timing
     protocol or time in-kernel already, so agent and reference windows mean
     the same thing on silicon.
  A  the two attention tasks, whose references are expert code.
  X  kernels with a frozen first-correct program that are NOT in the study:
     each carries the reason (train-only split, no cycle-scoreable window,
     SDK 2.10 compile failure). Listed so the exclusion is auditable rather
     than implicit.

Membership requires a frozen first-correct program under
`results/first_correct/<tag>/<kernel>/` -- that program is the common start of
every optimizer arm. `verify()` checks the sets against the repository so a
drifted spec or a missing start program is caught before a sweep starts.

Usage:
  python task_sets.py --list H            # kernels, one per line
  python task_sets.py --kernels H,A       # comma string for run_model_guided_ab.sh --kernels
  python task_sets.py --partition A       # the cells account A owns (see PARTITION)
  python task_sets.py --verify            # check the sets against the repo
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import Dict, List, Tuple

REPO_ROOT = Path(__file__).resolve().parents[1]
FC_TAG = "template_20260722"
FC_ROOT = REPO_ROOT / "code_translation" / "results" / "first_correct" / FC_TAG

# --- H: single-PE operators (27) ------------------------------------------------
H = [
    "Cross-Entropy-Loss-1PE", "DFT-1PE", "Dot-Product-1PE", "GELU-1PE", "GEMV-RowPart",
    "Histogram-1PE", "Histogram-Inline", "L2-Norm-1PE", "Max-Reduction-1PE", "MSE-Loss-1PE",
    "ParBroadcast-Scale", "ParDot-Product", "ParReduce-Sum", "PDFT-Pi-Pipeline",
    "Prefix-Sum-1PE", "ReLU-1PE", "RMSNorm-1PE", "RowParallel-Softmax", "SAXPY-1PE",
    "Sigmoid-1PE", "SiLU-1PE", "Single-Tile-Matvec", "Softmax-1PE", "SpMV-CSR",
    "Stencil7pt-1PE", "Sum-Reduction-1PE", "Tensor-Transpose-021",
]

# --- M: multi-PE kernels with a comparable timed window (4) ---------------------
# GEMM, GEMM-Collectives-2D, GEMV-Collectives-2D and Laplacian2D-Halo carry
# `timing_protocol: device_internal_v2` (re-baselined 2026-09-08). GEMM-Collectives-2D
# stays simulator-only for hardware claims until the SDK 2.10 port lands.
M = ["GEMM", "GEMM-Collectives-2D", "GEMV-Collectives-2D", "Laplacian2D-Halo"]

# --- A: attention tasks with expert references (2) ------------------------------
A = ["Attention-1PE", "Attention-QP"]

# --- X: frozen start program exists, deliberately outside the study -------------
EXCLUDED: Dict[str, str] = {
    "7pt-Stencil": "fails to compile under SDK 2.10; host-bracketed timer (docs/EXCLUDED_TASKS_AUDIT_20260806.md)",
    "BiCGSTAB": "fails to compile under SDK 2.10; solver family is train-only",
    "CG": "fails to compile under SDK 2.10; solver family is train-only",
    "Preconditioned-CG": "fails to compile under SDK 2.10; solver family is train-only",
}

# --- S: the v2 sparse study (docs/IPDPS_PREREG.md, "Task set S (v2)") ------------
# GraphBLAS-derived sparse operators with real SuiteSparse matrices as held-out inputs.
# SpMV-CSR is shared with H (the v1 study); the two studies never run in one sweep.
# Frozen first-correct programs for S come from the T0 translation sweep and live under
# results/first_correct/<S_FC_TAG>/; until that tag exists, verify() checks S against
# the specs and the registry only (a translation-phase set), and --strict-fc makes the
# frozen program mandatory (the optimize phase).
S = ["SpMV-CSR", "RowScale-CSR", "ColScale-CSR", "RowReduce-CSR",
     "SpGEMM-Masked-Dot", "SpMV-RowBlock", "SpMM-CSR-Dense"]
S_PLANNED: List[str] = []   # every S task is authored (16 Sep 2026)   # dirs land 17-21 Sep; removed from this list as they do
S_FC_TAG = "sparse_20260924"
S_FC_ROOT = REPO_ROOT / "code_translation" / "results" / "first_correct" / S_FC_TAG

SETS: Dict[str, List[str]] = {"H": H, "M": M, "A": A, "S": S}
ALL = H + M + A                       # the v1 study; S is verified separately

# --- work partition between two accounts ---------------------------------------
# An account runs WHOLE cells: all arms and all seeds of its kernels. Splitting the
# arms of one kernel across accounts would confound the comparison with the node.
# Set A is split in half by sorted order so both accounts carry a similar simulator
# load; the multi-PE and attention kernels (longest runs) sit with the account that
# owns the hardware allocation.
PARTITION: Dict[str, Dict[str, object]] = {
    "A": {"who": "repository owner (hardware allocation)",
          "kernels": sorted(H)[:14] + M + A,
          "note": "multi-PE + attention are here: their runs are the longest and their "
                  "hardware replay needs the allocation"},
    "B": {"who": "collaborator (own Argo key, different user node)",
          "kernels": sorted(H)[14:],
          "note": "single-PE operators only: short runs, no hardware dependency"},
    # v2 sparse study: multi-PE tasks with the hardware allocation owner, 1-PE tasks on node B
    "S-A": {"who": "repository owner (hardware allocation)",
            "kernels": ["SpMV-RowBlock", "SpMM-CSR-Dense", "SpGEMM-Masked-Dot"],
            "note": "multi-PE sparse tasks and the masked SpGEMM: longest runs, hardware replay"},
    "S-B": {"who": "collaborator (own Argo key, different user node)",
            "kernels": ["SpMV-CSR", "RowScale-CSR", "ColScale-CSR", "RowReduce-CSR"],
            "note": "1-PE sparse tasks: short runs"},
}


def kernels_of(spec: str) -> List[str]:
    """'H', 'H,A', 'all' -> kernel list, de-duplicated, order preserved."""
    if spec.strip().lower() == "all":
        names = list(ALL)
    else:
        names = []
        for part in spec.split(","):
            part = part.strip()
            if not part:
                continue
            if part in SETS:
                names.extend(SETS[part])
            else:
                names.append(part)          # an explicit kernel name is allowed
    seen, out = set(), []
    for n in names:
        if n not in seen:
            seen.add(n)
            out.append(n)
    return out


def verify_sparse(strict_fc: bool = False) -> Tuple[bool, List[str]]:
    """Check set S: every member has a spec with structure+eval blocks and a registry
    entry (planned members are exempt until their directories land); with strict_fc, or
    once the S frozen-program root exists, every member needs a frozen program."""
    msgs: List[str] = []
    ok = True
    kernels_dir = REPO_ROOT / "kernels"
    try:
        sys.path.insert(0, str(REPO_ROOT / "code_translation"))
        from cuda2csl import KERNEL_REGISTRY  # noqa: WPS433
        registry = set(KERNEL_REGISTRY)
    except Exception:                          # registry import needs the agent env; do not fail on it
        registry = None
    need_fc = strict_fc or S_FC_ROOT.is_dir()
    for k in S:
        spec_path = kernels_dir / k / "spec.yaml"
        if not spec_path.is_file():
            if k in S_PLANNED:
                msgs.append(f"PLANNED {k}: directory not yet authored")
                continue
            ok = False; msgs.append(f"FAIL {k}: no spec.yaml under kernels/"); continue
        text = spec_path.read_text()
        for block in ("structure:", "eval:"):
            if block not in text:
                ok = False; msgs.append(f"FAIL {k}: spec lacks the `{block}` block")
        if registry is not None and k not in registry:
            ok = False; msgs.append(f"FAIL {k}: not in cuda2csl.KERNEL_REGISTRY")
        if need_fc and not (S_FC_ROOT / k / "meta.json").is_file():
            ok = False; msgs.append(f"FAIL {k}: no frozen first-correct program in {S_FC_ROOT.name}")
    part = sorted(list(PARTITION["S-A"]["kernels"]) + list(PARTITION["S-B"]["kernels"]))  # type: ignore[arg-type]
    if part != sorted(S):
        ok = False; msgs.append(f"FAIL S partition does not cover S exactly ({part} vs {sorted(S)})")
    if ok:
        authored = [k for k in S if (kernels_dir / k / "spec.yaml").is_file()]
        msgs.append(f"OK  S={len(S)} ({len(authored)} authored, {len(S) - len(authored)} planned); "
                    f"frozen programs {'required and present' if need_fc else 'not yet required'}; S partition covers S once")
    return ok, msgs


def verify(fc_root: Path = FC_ROOT) -> Tuple[bool, List[str]]:
    """Check the v1 sets (H/M/A) against the repository. Returns (ok, messages)."""
    msgs: List[str] = []
    ok = True
    kernels_dir = REPO_ROOT / "kernels"

    dups = [k for k in set(ALL) if ALL.count(k) > 1]
    if dups:
        ok = False
        msgs.append(f"FAIL kernel in more than one set: {sorted(dups)}")

    for k in ALL:
        if not (fc_root / k / "meta.json").is_file():
            ok = False
            msgs.append(f"FAIL {k}: no frozen first-correct program in {fc_root.name}")

    for k in ALL:
        direct = kernels_dir / k
        alt = kernels_dir / k.replace("-", " ")
        if not (direct / "spec.yaml").is_file() and not (alt / "spec.yaml").is_file():
            ok = False
            msgs.append(f"FAIL {k}: no spec.yaml under kernels/")

    frozen = {p.name for p in fc_root.iterdir() if p.is_dir()} if fc_root.is_dir() else set()
    unaccounted = sorted(frozen - set(ALL) - set(EXCLUDED))
    if unaccounted:
        ok = False
        msgs.append(f"FAIL frozen programs in neither a set nor EXCLUDED: {unaccounted} "
                    f"(add to a set or give a reason in EXCLUDED)")

    part = sorted(list(PARTITION["A"]["kernels"]) + list(PARTITION["B"]["kernels"]))  # type: ignore[arg-type]
    if part != sorted(ALL):
        ok = False
        missing = sorted(set(ALL) - set(part))
        extra = sorted(set(part) - set(ALL))
        msgs.append(f"FAIL partition does not cover the study exactly (missing {missing}, extra {extra})")

    if ok:
        msgs.append(f"OK  H={len(H)} M={len(M)} A={len(A)} total={len(ALL)}; "
                    f"{len(EXCLUDED)} excluded with reasons; partition covers every kernel once")
    return ok, msgs


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--list", metavar="SETS", help="print the kernels of these sets, one per line")
    g.add_argument("--kernels", metavar="SETS", help="print a comma string for --kernels")
    g.add_argument("--partition", metavar="A|B", help="print the kernels an account owns")
    g.add_argument("--verify", action="store_true", help="check the v1 sets (H/M/A) and the v2 set S against the repository")
    ap.add_argument("--fc", default=str(FC_ROOT))
    ap.add_argument("--strict-fc", action="store_true", help="S members must have a frozen first-correct program")
    a = ap.parse_args()
    if a.verify:
        ok, msgs = verify(Path(a.fc))
        ok_s, msgs_s = verify_sparse(strict_fc=a.strict_fc)
        for m in msgs + msgs_s:
            print(m)
        return 0 if (ok and ok_s) else 1
    if a.partition:
        key = a.partition.strip().upper()
        if key not in PARTITION:
            ap.error(f"--partition must be one of {sorted(PARTITION)}")
        cell = PARTITION[key]
        print(",".join(sorted(cell["kernels"])))  # type: ignore[arg-type]
        return 0
    names = kernels_of(a.list or a.kernels)
    print("\n".join(names) if a.list else ",".join(names))
    return 0


if __name__ == "__main__":
    sys.exit(main())
