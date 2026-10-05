#!/usr/bin/env python3
"""Re-benchmark every success under ``knowledge/explored/successes/`` and
patch its ``metrics.json`` + the matching row in ``experiences.jsonl`` with
freshly measured ``cycles_send`` / ``time_send_us`` / ``run_time_ms`` /
``compile_time_ms`` when available.

What this script DOES
  - For each bundle in successes/ (or only those passed via --kernel):
      * Stage the bundle into a sandbox and run benchmark_translated_compute_file
      * Classify the rerun outcome
      * If the rerun PASSES and reports ``cycles_send`` (the canonical
        ``cycles_send = N cycles`` stdout line that benchmark_csl parses),
        patch metrics.json and the experiences.jsonl row.
      * If the rerun passes but the bundle's run.py lacks the cycles_send
        instrumentation, tag the bundle as ``needs_cycles_instrumentation``
        in metrics.json so the operator (or a future explore_csl round
        targeting the same idea) can re-emit it with the recipe baked in.
      * If the rerun fails, tag the bundle as ``rebench_broken`` so it
        won't be promoted by explore_promote.py.

What this script DOES NOT do
  - It does NOT invent numbers. Bundles whose run.py never prints
    ``cycles_send`` cannot have a number patched in — that would be
    fabrication; we record the gap instead.
  - It does NOT mutate ``index.md``. The original success/failure
    classification stands; we only patch the per-bundle metrics + the
    JSONL row.
  - It does NOT delete anything. Failed re-runs are tagged in-place.

Usage
  python3 code_translation/rebench_explored.py                # all successes
  python3 code_translation/rebench_explored.py --kernel row_softmax
  python3 code_translation/rebench_explored.py --concurrency 2 --enable-singularity-gate
  python3 code_translation/rebench_explored.py --dry-run      # just classify
"""

from __future__ import annotations

import argparse
import json
import logging
import os
import shutil
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, List, Optional

THIS_DIR = Path(__file__).resolve().parent
if str(THIS_DIR) not in sys.path:
    sys.path.insert(0, str(THIS_DIR))

from benchmark_csl import benchmark_translated_compute_file  # type: ignore
from knowledge_persistence import DEFAULT_EXPLORED_ROOT  # type: ignore
from workflow_common import ensure_directory, expand_path, load_shell_setup  # type: ignore
from workflow_common import default_sdk_root, sdk_sif_path  # noqa: E402


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(filename)s:%(lineno)d - %(levelname)s - %(message)s",
)
logger = logging.getLogger("rebench_explored")


REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SDK_ROOT = default_sdk_root()


# ---------------------------------------------------------------------------
# Status taxonomy for a re-bench
# ---------------------------------------------------------------------------

REBENCH_PATCHED = "patched"            # rerun ok + cycles_send measured → metrics.json updated
REBENCH_NO_CYCLES = "needs_cycles_instrumentation"  # rerun ok but run.py has no cycles_send print
REBENCH_BROKEN = "rebench_broken"      # rerun failed (env drift, missing dep, regression)
REBENCH_SKIPPED = "skipped"            # missing bundle files, can't even try
REBENCH_NO_RUN_PY = "no_run_py"        # absent run.py — not benchable


@dataclass
class RebenchOutcome:
    bundle_dir: Path
    kernel_id: str
    status: str
    measured_cycles_send: Optional[int] = None
    measured_time_send_us: Optional[float] = None
    measured_run_time_ms: Optional[float] = None
    measured_compile_time_ms: Optional[float] = None
    rerun_status: Optional[str] = None
    failure_reason: Optional[str] = None
    notes: List[str] = field(default_factory=list)


# ---------------------------------------------------------------------------
# Per-bundle re-bench
# ---------------------------------------------------------------------------

_CYCLES_SEND_PRESENT_RE = __import__("re").compile(r"cycles_send\s*=\s*\{?\s*cycles_send")
_CYCLES_SEND_PRINT_RE = __import__("re").compile(
    r"cycles_send\s*=\s*\{cycles_send\}|print\(\s*f[\"']cycles_send\s*=|"
    r"print\(\s*\"cycles_send\s*=\""
)


def _has_cycles_send_print(run_py_text: str) -> bool:
    """Cheap detector: does this run.py emit the canonical cycles_send line?

    Two acceptable forms:
      print(f"cycles_send = {cycles_send} cycles")
      print("cycles_send =", cycles_send, "cycles")
    Both end up matching cycles_send=...cycles in stdout, which is what
    benchmark_csl._CYCLES_SEND_RE looks for.
    """
    if not run_py_text:
        return False
    return "cycles_send" in run_py_text and "print" in run_py_text


def _benchmark_one_bundle(*,
                          bundle_dir: Path,
                          sdk_root: str,
                          work_root: str,
                          shell_setup: Optional[str],
                          timeout: int = 240) -> Optional[Dict[str, Any]]:
    pe = bundle_dir / "pe.csl"
    layout = bundle_dir / "layout.csl"
    run_py = bundle_dir / "run.py"
    cmds = bundle_dir / "commands_wse3.sh"
    if not pe.is_file() or not layout.is_file() or not run_py.is_file():
        return None
    if not cmds.is_file():
        # Synthesize the canonical command script if it's missing — the
        # bundle's layout.csl + pe.csl should still build.
        cmds.write_text(
            "#!/usr/bin/env bash\nset -e\n"
            "cslc --arch=wse3 ./layout.csl --fabric-dims=11,6 "
            "--fabric-offsets=4,1 --memcpy --channels=1 -o out\n"
            "cs_python run.py --name out\n",
            encoding="utf-8",
        )
        cmds.chmod(0o755)
    work_dir = tempfile.mkdtemp(prefix="rebench_", dir=work_root)
    try:
        return benchmark_translated_compute_file(
            translated_path=str(pe),
            reference_dir=str(bundle_dir),
            target_relpath="pe.csl",
            work_dir=work_dir,
            sdk_root=sdk_root,
            shell_setup=shell_setup,
            commands_script="commands_wse3.sh",
            arch="wse3",
            timeout=timeout,
            keep_staged_bundle=False,
            num_runs=1,
        )
    finally:
        shutil.rmtree(work_dir, ignore_errors=True)


def rebench_one(bundle_dir: Path,
                *,
                sdk_root: str,
                work_root: str,
                shell_setup: Optional[str],
                dry_run: bool = False) -> RebenchOutcome:
    kernel_id = bundle_dir.name.split("__")[0]
    out = RebenchOutcome(bundle_dir=bundle_dir, kernel_id=kernel_id,
                         status=REBENCH_SKIPPED)
    run_py = bundle_dir / "run.py"
    if not run_py.is_file():
        out.status = REBENCH_NO_RUN_PY
        out.notes.append("run.py missing from bundle")
        return out

    has_cycles_print = _has_cycles_send_print(
        run_py.read_text(encoding="utf-8", errors="ignore")
    )

    if dry_run:
        out.status = (REBENCH_PATCHED if has_cycles_print
                      else REBENCH_NO_CYCLES)
        out.notes.append("dry-run: skipped actual benchmark")
        return out

    bench = _benchmark_one_bundle(
        bundle_dir=bundle_dir, sdk_root=sdk_root, work_root=work_root,
        shell_setup=shell_setup,
    )
    if bench is None:
        out.notes.append("missing pe.csl / layout.csl / run.py")
        return out

    rerun_status = bench.get("status")
    success_marker = bench.get("success_marker")
    cycles_send = bench.get("cycles_send")
    out.rerun_status = rerun_status
    out.measured_run_time_ms = _to_float(bench.get("run_time_ms"))
    out.measured_compile_time_ms = _to_float(bench.get("compile_time_ms"))

    if rerun_status != "pass" or not success_marker:
        out.status = REBENCH_BROKEN
        out.failure_reason = bench.get("failure_reason") or "no success_marker"
        # Capture a short tail of the last non-pass step's stderr so the user
        # can see why it broke without re-running by hand.
        for entry in (bench.get("transcript") or []):
            if entry.get("status") != "pass":
                tail = (entry.get("stderr") or "")[-400:]
                if tail:
                    out.notes.append(f"stderr_tail: {tail}")
                break
        return out

    if cycles_send is None:
        out.status = REBENCH_NO_CYCLES
        out.notes.append(
            "run.py runs cleanly but does not print "
            "'cycles_send = N cycles' — instrumentation absent"
        )
        return out

    out.status = REBENCH_PATCHED
    out.measured_cycles_send = int(cycles_send)
    out.measured_time_send_us = _to_float(bench.get("time_send_us"))
    return out


def _to_float(v: Any) -> Optional[float]:
    if isinstance(v, (int, float)) and not isinstance(v, bool):
        return float(v)
    return None


# ---------------------------------------------------------------------------
# Metrics patching
# ---------------------------------------------------------------------------

def _read_json(p: Path) -> Optional[Dict[str, Any]]:
    if not p.is_file():
        return None
    try:
        return json.loads(p.read_text(encoding="utf-8"))
    except Exception:
        return None


def _write_json_atomic(p: Path, data: Dict[str, Any]) -> None:
    tmp = p.with_suffix(p.suffix + ".tmp")
    tmp.write_text(json.dumps(data, indent=2), encoding="utf-8")
    os.replace(tmp, p)


def patch_metrics_json(bundle_dir: Path, out: RebenchOutcome) -> bool:
    """Update the bundle's metrics.json in place. Returns True on write."""
    p = bundle_dir / "metrics.json"
    data = _read_json(p) or {}
    changed = False
    if out.status == REBENCH_PATCHED:
        if out.measured_cycles_send is not None and (
                data.get("cycles_send") != out.measured_cycles_send):
            data["cycles_send"] = out.measured_cycles_send
            changed = True
        if out.measured_time_send_us is not None:
            data["time_send_us"] = out.measured_time_send_us
            changed = True
        if out.measured_run_time_ms is not None:
            data["run_time_ms"] = out.measured_run_time_ms
            changed = True
        if out.measured_compile_time_ms is not None:
            data["compile_time_ms"] = out.measured_compile_time_ms
            changed = True
        data["rebench_status"] = REBENCH_PATCHED
        changed = True
    elif out.status == REBENCH_NO_CYCLES:
        data["rebench_status"] = REBENCH_NO_CYCLES
        data["rebench_notes"] = (
            "run.py runs and verifies but lacks the canonical "
            "`cycles_send = N cycles` print. Re-emit with the cycles_send "
            "recipe to populate the metric."
        )
        if out.measured_run_time_ms is not None:
            data.setdefault("run_time_ms_rerun", out.measured_run_time_ms)
        if out.measured_compile_time_ms is not None:
            data.setdefault("compile_time_ms_rerun", out.measured_compile_time_ms)
        changed = True
    elif out.status == REBENCH_BROKEN:
        data["rebench_status"] = REBENCH_BROKEN
        data["rebench_failure_reason"] = out.failure_reason or "unknown"
        data["rebench_notes"] = "; ".join(out.notes)[:600]
        changed = True
    elif out.status == REBENCH_NO_RUN_PY:
        data["rebench_status"] = REBENCH_NO_RUN_PY
        changed = True
    if changed:
        _write_json_atomic(p, data)
    return changed


def patch_experiences_jsonl(explored_root: Path,
                            outcomes: List[RebenchOutcome]) -> int:
    """Rewrite experiences.jsonl with patched cycles_send / run_time_ms /
    compile_time_ms for any row whose artifacts_dir matches a patched bundle.

    Returns the count of rows modified. Atomic write via .tmp + os.replace
    so an interrupted run does not corrupt the corpus.
    """
    p = explored_root / "experiences.jsonl"
    if not p.is_file():
        return 0
    # Map bundle_dir (relative) -> outcome for quick lookup.
    by_rel: Dict[str, RebenchOutcome] = {}
    for o in outcomes:
        try:
            rel = str(o.bundle_dir.relative_to(explored_root))
        except ValueError:
            continue
        by_rel[rel] = o

    tmp = p.with_suffix(".tmp")
    n_modified = 0
    with open(p, "r", encoding="utf-8") as fin, \
         open(tmp, "w", encoding="utf-8") as fout:
        for line in fin:
            stripped = line.strip()
            if not stripped:
                fout.write(line)
                continue
            try:
                row = json.loads(stripped)
            except json.JSONDecodeError:
                fout.write(line)
                continue
            rel = row.get("artifacts_dir") or ""
            o = by_rel.get(rel)
            if o is None:
                fout.write(line)
                continue
            modified = False
            if o.status == REBENCH_PATCHED:
                if o.measured_cycles_send is not None and (
                        row.get("cycles_send") != o.measured_cycles_send):
                    row["cycles_send"] = o.measured_cycles_send
                    modified = True
                if o.measured_run_time_ms is not None and (
                        row.get("run_time_ms") != o.measured_run_time_ms):
                    row["run_time_ms"] = o.measured_run_time_ms
                    modified = True
                if o.measured_compile_time_ms is not None and (
                        row.get("compile_time_ms") != o.measured_compile_time_ms):
                    row["compile_time_ms"] = o.measured_compile_time_ms
                    modified = True
                if modified:
                    row["rebench_status"] = REBENCH_PATCHED
            elif o.status in (REBENCH_NO_CYCLES, REBENCH_BROKEN,
                              REBENCH_NO_RUN_PY):
                if row.get("rebench_status") != o.status:
                    row["rebench_status"] = o.status
                    if o.failure_reason:
                        row["rebench_failure_reason"] = o.failure_reason
                    modified = True
            if modified:
                n_modified += 1
                fout.write(json.dumps(row, ensure_ascii=False) + "\n")
            else:
                fout.write(line)
    os.replace(tmp, p)
    return n_modified


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def list_success_bundles(explored_root: Path,
                          only_kernel: Optional[str] = None) -> List[Path]:
    successes = explored_root / "successes"
    if not successes.is_dir():
        return []
    out: List[Path] = []
    for d in sorted(successes.iterdir()):
        if not d.is_dir():
            continue
        if only_kernel and not d.name.startswith(only_kernel + "__"):
            continue
        out.append(d)
    return out


def run(*,
        explored_root: Path,
        sdk_root: str,
        work_root: str,
        shell_setup: Optional[str],
        only_kernel: Optional[str],
        concurrency: int,
        dry_run: bool,
        enable_singularity_gate: bool) -> int:
    if enable_singularity_gate:
        os.environ["XKERNEL_SINGULARITY_GATE"] = "1"
    bundles = list_success_bundles(explored_root, only_kernel=only_kernel)
    if not bundles:
        logger.info("nothing to rebench under %s", explored_root / "successes")
        return 0
    logger.info("re-benchmarking %d success bundle(s) (concurrency=%d, dry_run=%s)",
                len(bundles), concurrency, dry_run)
    ensure_directory(work_root)

    outcomes: List[RebenchOutcome] = []

    def _do(b: Path) -> RebenchOutcome:
        try:
            o = rebench_one(b, sdk_root=sdk_root, work_root=work_root,
                            shell_setup=shell_setup, dry_run=dry_run)
        except Exception as exc:
            logger.warning("[%s] rebench worker errored: %s",
                           b.name, str(exc)[:200])
            return RebenchOutcome(bundle_dir=b, kernel_id=b.name.split("__")[0],
                                  status=REBENCH_BROKEN,
                                  failure_reason=f"worker error: {exc}")
        logger.info("[%s] %s%s",
                    b.name, o.status,
                    f"  cycles_send={o.measured_cycles_send}"
                    if o.measured_cycles_send is not None else "")
        if not dry_run:
            patch_metrics_json(b, o)
        return o

    if concurrency <= 1:
        for b in bundles:
            outcomes.append(_do(b))
    else:
        with ThreadPoolExecutor(max_workers=concurrency) as pool:
            futures = {pool.submit(_do, b): b for b in bundles}
            for fut in as_completed(futures):
                outcomes.append(fut.result())

    if not dry_run:
        n = patch_experiences_jsonl(explored_root, outcomes)
        logger.info("patched %d experiences.jsonl row(s)", n)

    # Summary.
    by_status: Dict[str, int] = {}
    for o in outcomes:
        by_status[o.status] = by_status.get(o.status, 0) + 1
    print()
    print("=" * 60)
    print(f"  rebenched bundles      {len(outcomes)}")
    for st in (REBENCH_PATCHED, REBENCH_NO_CYCLES, REBENCH_BROKEN,
               REBENCH_NO_RUN_PY, REBENCH_SKIPPED):
        if st in by_status:
            print(f"  {st:<35} {by_status[st]}")
    print("=" * 60)
    if not dry_run:
        # List the patched bundles with their measured cycles for human review.
        patched = [o for o in outcomes if o.status == REBENCH_PATCHED]
        if patched:
            print("\nPatched bundles (kernel cycles_send):")
            for o in sorted(patched, key=lambda x: x.measured_cycles_send or 0):
                print(f"  {o.kernel_id:<32}  cycles={o.measured_cycles_send:>10}  "
                      f"run_ms={o.measured_run_time_ms:.0f}")
        broken = [o for o in outcomes if o.status == REBENCH_BROKEN]
        if broken:
            print("\nBroken bundles (rerun failed):")
            for o in broken:
                print(f"  {o.kernel_id:<32}  reason={o.failure_reason}")
        nocycles = [o for o in outcomes if o.status == REBENCH_NO_CYCLES]
        if nocycles:
            print(f"\n{len(nocycles)} bundle(s) run cleanly but lack the cycles_send")
            print("print; re-emit them via explore_csl (Mode B with the same idea)")
            print("to pick up the canonical recipe baked into the prompt.")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--explored-root", default=DEFAULT_EXPLORED_ROOT)
    ap.add_argument("--kernel", default=None,
                    help="Only rebench bundles whose name starts with this "
                         "kernel id (e.g. row_softmax).")
    ap.add_argument("--sdk-root", default=DEFAULT_SDK_ROOT)
    ap.add_argument("--work-root",
                    default=str(THIS_DIR / "sandbox" / "rebench_explored"))
    ap.add_argument("--shell-setup", default=None)
    ap.add_argument("--shell-setup-file", default=None)
    ap.add_argument("--concurrency", type=int, default=1,
                    help="Worker pool size. Conservative default — each worker "
                         "talks to singularity which can wedge under load.")
    ap.add_argument("--enable-singularity-gate", action="store_true",
                    help="Serialise singularity invocations (recommended at "
                         "--concurrency > 1).")
    ap.add_argument("--dry-run", action="store_true",
                    help="Classify each bundle (cycles-print present? bundle "
                         "complete?) without invoking cslc.")
    args = ap.parse_args()
    shell_setup = load_shell_setup(args.shell_setup, args.shell_setup_file)
    return run(
        explored_root=Path(os.path.expanduser(args.explored_root)).resolve(),
        sdk_root=expand_path(args.sdk_root),
        work_root=expand_path(args.work_root),
        shell_setup=shell_setup,
        only_kernel=args.kernel,
        concurrency=max(1, int(args.concurrency)),
        dry_run=args.dry_run,
        enable_singularity_gate=args.enable_singularity_gate,
    )


if __name__ == "__main__":
    sys.exit(main())
