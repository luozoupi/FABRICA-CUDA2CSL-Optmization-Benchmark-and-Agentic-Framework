"""Persistence layer for explore_csl runs.

Lives at ``/home/USER/xkernel/knowledge/explored/`` and is the single source
of truth for everything an exploration round produces:

    explored/
        index.md                              # one-line summary per attempt
        experiences.jsonl                     # typed records (full bundle answers)
        successes/<kernel_id>__<ts>/{pe.csl,layout.csl,run.py,spec.yaml,
                                     DESIGN.md,metrics.json,lessons.md}
        failures/<kernel_id>__<ts>/{last_pe.csl,error_log.txt,
                                    diagnosis.md,lessons.md}
        tutorials/<kernel_id>_tutorial.md     # produced later by explore_promote
        ingest/explored_experiences.jsonl     # KB-ready, audience-tagged
        ingest/explored_tutorials.jsonl       # KB-ready, audience-tagged
        promoted.jsonl                        # what was copied to kernels/

The split between ``experiences.jsonl`` (full answers, NEVER seen by the
existing translation agents) and ``ingest/explored_tutorials.jsonl``
(distilled tutorial-style guides, freely retrievable) is the firewall the
user asked for. The promotion stage in explore_promote.py is what bridges
them — under leak-checked control.
"""

from __future__ import annotations

import hashlib
import json
import logging
import os
import shutil
import tempfile
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional


DEFAULT_EXPLORED_ROOT = os.path.expanduser("~/xkernel/knowledge/explored")


# ---------------------------------------------------------------------------
# Data shapes
# ---------------------------------------------------------------------------

@dataclass
class CandidateArtifacts:
    """Bundle of files an exploration candidate produced.

    Any field may be empty when not applicable. The persistence layer writes
    only the populated ones.
    """
    pe_csl: str = ""
    layout_csl: str = ""
    run_py: str = ""
    launch_csl: str = ""
    commands_sh: str = ""
    design_md: str = ""
    spec_yaml: str = ""  # full text of a spec.yaml-like block


@dataclass
class ExplorationRecord:
    """Typed record appended to experiences.jsonl AND used to derive the
    other persisted artefacts.
    """
    ts: str
    mode: str                            # variation | idea | cuda-nl
    kernel_id: str
    idea: str
    idea_hash: str
    outcome: str                         # success | failure | numeric_check_failed
    failure_reason: Optional[str]
    run_time_ms: Optional[float]
    compile_time_ms: Optional[float]
    cycles_send: Optional[int]
    baseline_ref: Optional[str]
    baseline_cycles: Optional[int]
    speedup: Optional[float]
    design_choices: List[str]
    lessons: List[str]
    chunks_used: List[str]
    diagnosis: Optional[str]             # from debugger / reviewer
    provider: Optional[str]
    model: Optional[str]
    artifacts_dir: str                   # relative to explored root


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _now_iso() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def hash_idea(idea: str) -> str:
    return hashlib.sha1((idea or "").encode("utf-8")).hexdigest()[:12]


def _slug(s: str) -> str:
    out = []
    for ch in (s or "").lower():
        if ch.isalnum():
            out.append(ch)
        elif out and out[-1] != "_":
            out.append("_")
    return "".join(out).strip("_")[:48] or "untitled"


def _atomic_write_text(path: str | Path, text: str) -> None:
    p = Path(path)
    p.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp_name = tempfile.mkstemp(prefix=".tmp_", dir=str(p.parent))
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as fh:
            fh.write(text)
        os.replace(tmp_name, p)
    except Exception:
        try:
            os.unlink(tmp_name)
        except OSError:
            pass
        raise


def _atomic_append_jsonl(path: str | Path, row: Dict[str, Any]) -> None:
    p = Path(path)
    p.parent.mkdir(parents=True, exist_ok=True)
    # JSONL append is naturally atomic if the write is < PIPE_BUF; the
    # marshalled rows here are well under that, and the failure mode is a
    # truncated last line rather than corruption.
    line = json.dumps(row, ensure_ascii=False, sort_keys=False)
    with open(p, "a", encoding="utf-8") as fh:
        fh.write(line + "\n")


# ---------------------------------------------------------------------------
# ExplorationStore
# ---------------------------------------------------------------------------

class ExplorationStore:
    """Owns the explored/ directory.

    Constructed once per process. Thread-safe-ish for append-only writers
    (the bottleneck is the single JSONL append; if two workers race the OS
    interleaves their bytes but per-line newline preserves parseability).
    """

    def __init__(self, root: str | Path = DEFAULT_EXPLORED_ROOT) -> None:
        self.root = Path(os.path.expanduser(str(root))).resolve()
        for sub in ("successes", "failures", "tutorials", "ingest"):
            (self.root / sub).mkdir(parents=True, exist_ok=True)
        # Touch index.md so promotion-time grep doesn't trip on missing file.
        if not (self.root / "index.md").exists():
            _atomic_write_text(
                self.root / "index.md",
                "# explored_csl index\n"
                "# ts | mode | kernel_id | idea_hash | outcome | path\n",
            )

    # ----- core writers -----------------------------------------------------

    def record_success(self,
                       *,
                       mode: str,
                       idea: str,
                       kernel_id: str,
                       artifacts: CandidateArtifacts,
                       benchmark_result: Dict[str, Any],
                       baseline_ref: Optional[str] = None,
                       baseline_cycles: Optional[int] = None,
                       lessons: Optional[List[str]] = None,
                       design_choices: Optional[List[str]] = None,
                       chunks_used: Optional[List[str]] = None,
                       provider: Optional[str] = None,
                       model: Optional[str] = None) -> ExplorationRecord:
        """Persist a successful candidate. Writes per-bundle artefacts AND
        appends one row to experiences.jsonl + one line to index.md."""
        ts = _now_iso()
        slug = _slug(kernel_id)
        rel = f"successes/{slug}__{ts}"
        bundle_dir = self.root / rel
        bundle_dir.mkdir(parents=True, exist_ok=True)

        for name, body in [
            ("pe.csl", artifacts.pe_csl),
            ("layout.csl", artifacts.layout_csl),
            ("run.py", artifacts.run_py),
            ("launch.csl", artifacts.launch_csl),
            ("commands_wse3.sh", artifacts.commands_sh),
            ("DESIGN.md", artifacts.design_md),
            ("spec.yaml", artifacts.spec_yaml),
        ]:
            if body and body.strip():
                _atomic_write_text(bundle_dir / name, body)

        metrics = {
            "status": benchmark_result.get("status"),
            "compile_time_ms": benchmark_result.get("compile_time_ms"),
            "run_time_ms": benchmark_result.get("run_time_ms"),
            "cycles_send": benchmark_result.get("cycles_send"),
            "cycles_send_runs": benchmark_result.get("cycles_send_runs"),
            "success_marker": benchmark_result.get("success_marker"),
            "baseline_ref": baseline_ref,
            "baseline_cycles": baseline_cycles,
        }
        _atomic_write_text(bundle_dir / "metrics.json",
                           json.dumps(metrics, indent=2))

        lessons = list(lessons or [])
        if lessons:
            _atomic_write_text(
                bundle_dir / "lessons.md",
                "# Lessons distilled from this success\n\n"
                + "\n".join(f"- {ln}" for ln in lessons) + "\n",
            )

        cycles_send = benchmark_result.get("cycles_send")
        speedup = None
        if (isinstance(baseline_cycles, (int, float)) and baseline_cycles > 0
                and isinstance(cycles_send, (int, float)) and cycles_send > 0):
            speedup = float(baseline_cycles) / float(cycles_send)

        rec = ExplorationRecord(
            ts=ts,
            mode=mode,
            kernel_id=kernel_id,
            idea=idea,
            idea_hash=hash_idea(idea),
            outcome="success",
            failure_reason=None,
            run_time_ms=_as_float(benchmark_result.get("run_time_ms")),
            compile_time_ms=_as_float(benchmark_result.get("compile_time_ms")),
            cycles_send=_as_int(cycles_send),
            baseline_ref=baseline_ref,
            baseline_cycles=_as_int(baseline_cycles),
            speedup=speedup,
            design_choices=list(design_choices or []),
            lessons=lessons,
            chunks_used=list(chunks_used or []),
            diagnosis=None,
            provider=provider,
            model=model,
            artifacts_dir=rel,
        )
        self._append_record(rec)
        return rec

    def record_failure(self,
                       *,
                       mode: str,
                       idea: str,
                       kernel_id: str,
                       last_pe_csl: str,
                       failure_reason: str,
                       stderr_tail: str,
                       diagnosis: Optional[str] = None,
                       lessons: Optional[List[str]] = None,
                       design_choices: Optional[List[str]] = None,
                       chunks_used: Optional[List[str]] = None,
                       benchmark_result: Optional[Dict[str, Any]] = None,
                       provider: Optional[str] = None,
                       model: Optional[str] = None,
                       last_layout_csl: str = "",
                       last_run_py: str = "",
                       last_commands_sh: str = "") -> ExplorationRecord:
        ts = _now_iso()
        slug = _slug(kernel_id)
        rel = f"failures/{slug}__{ts}"
        bundle_dir = self.root / rel
        bundle_dir.mkdir(parents=True, exist_ok=True)

        if last_pe_csl and last_pe_csl.strip():
            _atomic_write_text(bundle_dir / "last_pe.csl", last_pe_csl)
        if last_layout_csl and last_layout_csl.strip():
            _atomic_write_text(bundle_dir / "last_layout.csl", last_layout_csl)
        if last_run_py and last_run_py.strip():
            _atomic_write_text(bundle_dir / "last_run.py", last_run_py)
        if last_commands_sh and last_commands_sh.strip():
            _atomic_write_text(bundle_dir / "last_commands_wse3.sh",
                               last_commands_sh)
        _atomic_write_text(bundle_dir / "error_log.txt",
                           (stderr_tail or "(no stderr captured)").rstrip() + "\n")
        if diagnosis:
            _atomic_write_text(bundle_dir / "diagnosis.md",
                               "# Debugger / reviewer diagnosis\n\n"
                               + diagnosis.strip() + "\n")
        lessons = list(lessons or [])
        if lessons:
            _atomic_write_text(
                bundle_dir / "lessons.md",
                "# Lessons from this failure (anti-patterns)\n\n"
                + "\n".join(f"- {ln}" for ln in lessons) + "\n",
            )

        br = benchmark_result or {}
        rec = ExplorationRecord(
            ts=ts,
            mode=mode,
            kernel_id=kernel_id,
            idea=idea,
            idea_hash=hash_idea(idea),
            outcome="failure",
            failure_reason=failure_reason[:300] if failure_reason else None,
            run_time_ms=_as_float(br.get("run_time_ms")),
            compile_time_ms=_as_float(br.get("compile_time_ms")),
            cycles_send=_as_int(br.get("cycles_send")),
            baseline_ref=None,
            baseline_cycles=None,
            speedup=None,
            design_choices=list(design_choices or []),
            lessons=lessons,
            chunks_used=list(chunks_used or []),
            diagnosis=diagnosis,
            provider=provider,
            model=model,
            artifacts_dir=rel,
        )
        self._append_record(rec)
        return rec

    # ----- optimization records --------------------------------------------
    #
    # Optimization exploration writes to a parallel tree:
    #   ~/xkernel/knowledge/explored/optimization/
    #     experiences.jsonl          # one row per attempt (accepted or not)
    #     accepted/<kernel>__<angle>__<ts>/{pe.csl, diff_summary.md, metrics.json}
    #
    # Keeping it separate from the kernel-generation tree prevents the
    # exploration aggregator from confusing "kernel works" rows with
    # "optimization helped" rows. Both feed into for_explorer / for_optimizer
    # via their own KB accessors.

    def record_optimization(self,
                            *,
                            kernel: str,
                            kernel_group: str,
                            angle: str,
                            baseline_cycles: Optional[int],
                            candidate_cycles: Optional[int],
                            accepted: bool,
                            reject_reason: Optional[str],
                            optimized_pe_csl: str,
                            diff_summary: Optional[str],
                            benchmark_result: Dict[str, Any],
                            bottlenecks: Optional[List[str]] = None,
                            provider: Optional[str] = None,
                            model: Optional[str] = None,
                            # Failure-side artefacts (only used when accepted=False).
                            # Without these, the orchestrator throws away every
                            # broken candidate and we can't see WHY the LLM
                            # failed → can't encode new gotchas → can't improve.
                            failure_pe_csl: str = "",
                            failure_layout_csl: str = "",
                            failure_stderr_tail: str = "",
                            failure_diagnosis: Optional[str] = None,
                            # Multi-file extras: dict of {relpath: text} for
                            # any file beyond the root (e.g. src/blas.csl
                            # when optimizing the BiCGSTAB-family kernels).
                            # Used by both accept and fail paths so we can
                            # audit aux-file edits offline without re-running.
                            # The root file's text continues to come through
                            # ``optimized_pe_csl`` / ``failure_pe_csl`` for
                            # backward compatibility.
                            extra_files: Optional[Dict[str, str]] = None,
                            ) -> Dict[str, Any]:
        """Append one optimization attempt to optimization/experiences.jsonl.

        - ``accepted=True``  → bundle written under ``accepted/<kernel>__<angle>__<ts>/``
        - ``accepted=False`` AND any failure_* is populated
          → bundle written under ``failures/<kernel>__<angle>__<ts>/``
            (last_pe.csl, last_layout.csl, error_log.txt, diagnosis.md).

        Both paths append a row to ``experiences.jsonl`` with full metrics.
        """
        opt_root = self.root / "optimization"
        (opt_root / "accepted").mkdir(parents=True, exist_ok=True)
        (opt_root / "failures").mkdir(parents=True, exist_ok=True)
        (opt_root / "ingest").mkdir(parents=True, exist_ok=True)
        ts = _now_iso()
        speedup = None
        if (isinstance(baseline_cycles, (int, float)) and baseline_cycles > 0
                and isinstance(candidate_cycles, (int, float))
                and candidate_cycles > 0):
            speedup = float(baseline_cycles) / float(candidate_cycles)

        artifacts_rel = ""
        if accepted and optimized_pe_csl:
            slug = _slug(f"{kernel}__{angle}")
            bundle_dir = opt_root / "accepted" / f"{slug}__{ts}"
            bundle_dir.mkdir(parents=True, exist_ok=True)
            _atomic_write_text(bundle_dir / "pe.csl", optimized_pe_csl)
            # Multi-file edits: persist every aux focus file alongside
            # pe.csl, preserving the relpath so offline audit + the
            # promotion path can find them. Without this, multi-file
            # accepts lose the helper edits and the bundle is
            # indistinguishable from a root-only accept.
            for rel, text in (extra_files or {}).items():
                if not text:
                    continue
                dst = bundle_dir / rel
                dst.parent.mkdir(parents=True, exist_ok=True)
                _atomic_write_text(dst, text)
            if diff_summary:
                _atomic_write_text(bundle_dir / "diff_summary.md",
                                   "# Why this variant was faster\n\n"
                                   + diff_summary.strip() + "\n")
            metrics = {
                "kernel": kernel,
                "kernel_group": kernel_group,
                "angle": angle,
                "baseline_cycles": baseline_cycles,
                "candidate_cycles": candidate_cycles,
                "speedup": speedup,
                "compile_time_ms": benchmark_result.get("compile_time_ms"),
                "run_time_ms": benchmark_result.get("run_time_ms"),
            }
            _atomic_write_text(bundle_dir / "metrics.json",
                               json.dumps(metrics, indent=2))
            artifacts_rel = str(bundle_dir.relative_to(self.root))

        # Failure-side artefacts: persist the broken candidate + diagnosis
        # so the operator can inspect what the LLM did wrong AND so the
        # repair-round prompt has real source/stderr to feed back next try.
        if not accepted and (failure_pe_csl or failure_layout_csl
                              or failure_stderr_tail
                              or failure_diagnosis
                              or extra_files):
            slug = _slug(f"{kernel}__{angle}")
            fail_dir = opt_root / "failures" / f"{slug}__{ts}"
            fail_dir.mkdir(parents=True, exist_ok=True)
            if failure_pe_csl and failure_pe_csl.strip():
                _atomic_write_text(fail_dir / "last_pe.csl", failure_pe_csl)
            if failure_layout_csl and failure_layout_csl.strip():
                _atomic_write_text(fail_dir / "last_layout.csl",
                                   failure_layout_csl)
            # Multi-file extras: persist every aux file the LLM emitted
            # so the operator can see WHICH aux edits were attempted on
            # a rejected round (the live-runs surfaced cases where
            # blas.csl was edited but invisible to offline audit).
            for rel, text in (extra_files or {}).items():
                if not text:
                    continue
                dst = fail_dir / rel
                dst.parent.mkdir(parents=True, exist_ok=True)
                _atomic_write_text(dst, text)
            _atomic_write_text(
                fail_dir / "error_log.txt",
                (failure_stderr_tail or "(no stderr captured)").rstrip() + "\n",
            )
            if failure_diagnosis:
                _atomic_write_text(fail_dir / "diagnosis.md",
                                   "# Debugger / reviewer diagnosis\n\n"
                                   + failure_diagnosis.strip() + "\n")
            artifacts_rel = str(fail_dir.relative_to(self.root))

        # Persist the per-run cycles array so future runs can compute
        # empirical noise per kernel and set epsilon accordingly. Dropping
        # it (the original bug) means we can't tell a 1% real win from
        # 5% noise on the median.
        runs = benchmark_result.get("cycles_send_runs") or []
        runs_list = [int(x) for x in runs if isinstance(x, (int, float))]
        row = {
            "ts": ts,
            "kernel": kernel,
            "kernel_group": kernel_group,
            "angle": angle,
            "baseline_cycles": _as_int(baseline_cycles),
            "candidate_cycles": _as_int(candidate_cycles),
            "cycles_send_runs": runs_list,
            "cycles_send_min": (min(runs_list) if runs_list else None),
            "cycles_send_max": (max(runs_list) if runs_list else None),
            "num_runs": len(runs_list) if runs_list else
                          _as_int(benchmark_result.get("num_runs")),
            "speedup": speedup,
            "accepted": bool(accepted),
            "reject_reason": reject_reason,
            "diff_summary": (diff_summary or "")[:1500] if accepted else None,
            "bottlenecks": list(bottlenecks or []),
            "status": benchmark_result.get("status"),
            "failure_reason": benchmark_result.get("failure_reason"),
            "compile_time_ms": _as_float(benchmark_result.get("compile_time_ms")),
            "run_time_ms": _as_float(benchmark_result.get("run_time_ms")),
            "provider": provider,
            "model": model,
            "artifacts_dir": artifacts_rel,
        }
        _atomic_append_jsonl(opt_root / "experiences.jsonl", row)
        # Append a per-attempt index line so humans can scan one file.
        idx_line = (f"{ts} | {kernel} | {kernel_group:<10} | {angle:<25} | "
                    f"baseline={baseline_cycles or '?'} cand={candidate_cycles or '?'} "
                    f"speedup={f'{speedup:.2f}x' if speedup else '?'} "
                    f"{'ACCEPT' if accepted else 'REJECT'}"
                    + (f" ({reject_reason})" if reject_reason else "") + "\n")
        with open(opt_root / "index.md", "a", encoding="utf-8") as fh:
            fh.write(idx_line)
        # Re-emit a KB-ready chunk for accepted attempts so for_optimizer_explored
        # surfaces this lesson next time.
        if accepted and diff_summary:
            self._write_optimization_chunk_for_kb(row, optimized_pe_csl[:1500])
        return row

    def _write_optimization_chunk_for_kb(self, row: Dict[str, Any],
                                          code_excerpt: str) -> None:
        opt_root = self.root / "optimization"
        text = "\n".join([
            f"Kernel: {row['kernel']} (group={row['kernel_group']})",
            f"Angle applied: {row['angle']}",
            (f"Speedup: {row['speedup']:.2f}x "
             f"({row['baseline_cycles']} → {row['candidate_cycles']} cycles)"
             if row.get('speedup') else ""),
            "What changed:",
            (row.get('diff_summary') or "").strip(),
        ])
        chunk = {
            "chunk_id": f"opt_{row['kernel_group']}_{row['angle']}_{row['ts']}",
            "source_url": row.get("artifacts_dir", ""),
            "source_rst_url": "",
            "title": f"{row['kernel']} optimized via {row['angle']}",
            "sdk_version": os.getenv("XKERNEL_TARGET_SDK", "1.4.0"),
            "release_date": row['ts'][:8],
            "section": f"optimization_{row['kernel_group']}",
            "topic_tags": ["optimization", row['kernel_group'], row['angle']],
            "introduced_in": None,
            "deprecated_in": None,
            "removed_in": None,
            "text": text.strip(),
        }
        _atomic_append_jsonl(opt_root / "ingest" / "optimization_experiences.jsonl",
                              chunk)

    def load_optimization_records(self) -> List[Dict[str, Any]]:
        p = self.root / "optimization" / "experiences.jsonl"
        if not p.is_file():
            return []
        out: List[Dict[str, Any]] = []
        with open(p, "r", encoding="utf-8") as fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                try:
                    out.append(json.loads(line))
                except json.JSONDecodeError:
                    pass
        return out

    def aggregate_angle_rewards(self) -> Dict[str, Dict[str, Any]]:
        """Group optimization records by (kernel_group, angle) and compute
        attempts / accepts / mean_speedup / best_speedup.

        Returns a dict keyed by "<group>::<angle>" so the optimizer prompt
        can render a compact "what historically helped this group" table.
        """
        rows = self.load_optimization_records()
        agg: Dict[str, Dict[str, Any]] = {}
        for r in rows:
            key = f"{r.get('kernel_group','?')}::{r.get('angle','?')}"
            slot = agg.setdefault(key, {
                "kernel_group": r.get('kernel_group','?'),
                "angle": r.get('angle','?'),
                "attempts": 0,
                "accepts": 0,
                "speedups": [],
            })
            slot["attempts"] += 1
            if r.get("accepted"):
                slot["accepts"] += 1
                if isinstance(r.get("speedup"), (int, float)):
                    slot["speedups"].append(float(r["speedup"]))
        # Finalise summary stats.
        for k, v in agg.items():
            sp = v.pop("speedups")
            v["accept_rate"] = (v["accepts"] / v["attempts"]) if v["attempts"] else 0.0
            v["mean_speedup"] = (sum(sp) / len(sp)) if sp else None
            v["best_speedup"] = max(sp) if sp else None
        return agg

    def mark_infeasible(self, idea: str, mode: str, reason: str) -> None:
        """Append an infeasible-tagged row so IdeaSampler skips this idea
        next time. Cheaper than full record_failure (no per-bundle dir)."""
        ts = _now_iso()
        rec = ExplorationRecord(
            ts=ts,
            mode=mode,
            kernel_id="(infeasible)",
            idea=idea,
            idea_hash=hash_idea(idea),
            outcome="infeasible",
            failure_reason=reason[:200] if reason else None,
            run_time_ms=None,
            compile_time_ms=None,
            cycles_send=None,
            baseline_ref=None,
            baseline_cycles=None,
            speedup=None,
            design_choices=[],
            lessons=[reason or "marked infeasible"],
            chunks_used=[],
            diagnosis=None,
            provider=None,
            model=None,
            artifacts_dir="",
        )
        self._append_record(rec)

    # ----- queries ----------------------------------------------------------

    def list_records(self) -> List[Dict[str, Any]]:
        p = self.root / "experiences.jsonl"
        if not p.is_file():
            return []
        out: List[Dict[str, Any]] = []
        with open(p, "r", encoding="utf-8") as fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                try:
                    out.append(json.loads(line))
                except json.JSONDecodeError:
                    pass
        return out

    def seen_idea_hashes(self) -> set:
        """Return idea_hashes for all recorded attempts (success, failure,
        or infeasible). IdeaSampler uses this to dedup before sampling."""
        return {r.get("idea_hash") for r in self.list_records()
                if r.get("idea_hash")}

    def infeasible_idea_hashes(self) -> set:
        """Hashes the sampler should HARD-skip (not just deprioritize)."""
        return {r.get("idea_hash") for r in self.list_records()
                if r.get("outcome") == "infeasible"}

    def consecutive_compile_fails_for_idea(self, idea_hash: str) -> int:
        """Count consecutive compile failures for an idea in chronological
        order, ending at the latest record. Used to decide infeasibility."""
        count = 0
        for r in self.list_records():
            if r.get("idea_hash") != idea_hash:
                continue
            if r.get("outcome") == "failure" and (
                "compile" in (r.get("failure_reason") or "").lower()
                or r.get("compile_time_ms") in (0, None)
            ):
                count += 1
            elif r.get("outcome") == "success":
                count = 0
        return count

    # ----- KB-ready ingest (only the safe distillations) --------------------

    def write_experience_chunk_for_explorer_kb(self,
                                                rec: ExplorationRecord) -> None:
        """Append a chunk to ingest/explored_experiences.jsonl.

        This is the for_explorer-only corpus — it contains the full design
        choices and metrics. The existing for_architect/for_implementer/
        for_reviewer DO NOT read this file (firewall). Only used by the
        new for_explorer() accessor in csl_knowledge_base.
        """
        if rec.outcome not in ("success", "failure"):
            return
        text_parts = [
            f"Kernel: {rec.kernel_id}",
            f"Mode: {rec.mode}",
            f"Outcome: {rec.outcome}",
            f"Idea: {rec.idea}",
        ]
        if rec.failure_reason:
            text_parts.append(f"Failure reason: {rec.failure_reason}")
        if rec.cycles_send:
            text_parts.append(f"Cycles (median): {rec.cycles_send}")
        if rec.speedup is not None:
            text_parts.append(f"Speedup vs baseline {rec.baseline_ref}: {rec.speedup:.2f}x")
        if rec.design_choices:
            text_parts.append("Design choices:\n" +
                              "\n".join(f"  - {c}" for c in rec.design_choices))
        if rec.lessons:
            text_parts.append("Lessons:\n" +
                              "\n".join(f"  - {ln}" for ln in rec.lessons))
        if rec.diagnosis:
            text_parts.append(f"Diagnosis:\n{rec.diagnosis.strip()}")

        chunk = {
            "chunk_id": f"explored_{rec.outcome[:1]}_{rec.idea_hash}_{rec.ts}",
            "source_url": rec.artifacts_dir,
            "source_rst_url": "",
            "title": f"{rec.kernel_id} ({rec.outcome})",
            "sdk_version": os.getenv("XKERNEL_TARGET_SDK", "1.4.0"),
            "release_date": rec.ts[:8],
            "section": f"explored_experience_{rec.mode}",
            "topic_tags": ["explored", rec.mode, rec.outcome],
            "introduced_in": None,
            "deprecated_in": None,
            "removed_in": None,
            "text": "\n\n".join(text_parts),
        }
        _atomic_append_jsonl(self.root / "ingest" / "explored_experiences.jsonl",
                              chunk)

    # ----- internal ---------------------------------------------------------

    def _append_record(self, rec: ExplorationRecord) -> None:
        row = asdict(rec)
        _atomic_append_jsonl(self.root / "experiences.jsonl", row)
        path_or_dash = rec.artifacts_dir or "-"
        index_line = (f"{rec.ts} | {rec.mode} | {rec.kernel_id} | "
                      f"{rec.idea_hash} | {rec.outcome} | {path_or_dash}\n")
        with open(self.root / "index.md", "a", encoding="utf-8") as fh:
            fh.write(index_line)
        # Also write the KB-ready chunk (for_explorer only) so the next
        # exploration round can recall this attempt.
        try:
            self.write_experience_chunk_for_explorer_kb(rec)
        except Exception as exc:
            logging.warning("[explored] KB chunk write failed: %s", str(exc)[:200])


def _as_float(v: Any) -> Optional[float]:
    if isinstance(v, (int, float)) and not isinstance(v, bool):
        return float(v)
    return None


def _as_int(v: Any) -> Optional[int]:
    if isinstance(v, (int, float)) and not isinstance(v, bool):
        return int(v)
    return None


# ---------------------------------------------------------------------------
# Tutorial leak check (used by explore_promote)
# ---------------------------------------------------------------------------

import re as _re


_IDENT_RE = _re.compile(r"[A-Za-z_][A-Za-z0-9_]{5,}")  # 6+ chars
_NUMERIC_RE = _re.compile(r"\b\d{3,}\b")  # 3+ digit numbers (skip 1-2 digit consts)


def bundle_identifier_set(bundle_text: str) -> set:
    """Tokenise bundle text into a set of identifiers ≥6 chars and numeric
    literals ≥3 digits. Common Python/CSL keywords are excluded as those
    are expected to appear in any tutorial."""
    common = {
        "comptime", "import", "module", "export", "symbol", "function",
        "return", "true", "false", "const", "static", "extern",
        "function", "param", "task", "color", "tensor", "tensor_access",
        "fabric", "fabric_color", "memcpy", "broadcast",
        "import_module", "export_symbol", "set_tile_code", "set_rectangle",
        "fabin_dsd", "fabout_dsd", "mem1d_dsd", "increment_dsd_offset",
        "numpy", "import", "shape", "dtype", "float32", "int32",
        "assert_allclose", "testing", "perf_counter", "MemcpyDataType",
        "MemcpyOrder", "SdkRuntime", "runtime", "compute", "launch",
        "memcpy_h2d", "memcpy_d2h", "get_symbol", "get_id", "stop",
        "argparse", "parse_args", "ArgumentParser",
    }
    out = set()
    for m in _IDENT_RE.finditer(bundle_text or ""):
        tok = m.group(0)
        if tok in common:
            continue
        out.add(tok)
    for m in _NUMERIC_RE.finditer(bundle_text or ""):
        out.add(m.group(0))
    return out


def tutorial_leak_check(tutorial_text: str,
                        bundle_text: str,
                        threshold: int = 3) -> Optional[str]:
    """Return None when the tutorial does NOT echo too many bundle-specific
    tokens; else a short message naming the offending tokens.

    `threshold` is the maximum number of distinct bundle tokens allowed to
    appear verbatim in the tutorial before we flag a leak. Default 3 — a
    tutorial that names ≤3 specific identifiers can still abstract the
    general pattern.
    """
    if not tutorial_text or not bundle_text:
        return None
    bundle_set = bundle_identifier_set(bundle_text)
    if not bundle_set:
        return None
    hits = [tok for tok in bundle_set if tok in tutorial_text]
    hits.sort()
    if len(hits) <= threshold:
        return None
    sample = ", ".join(hits[:10])
    more = "" if len(hits) <= 10 else f" (+{len(hits)-10} more)"
    return (f"tutorial echoes {len(hits)} bundle-specific tokens "
            f"(threshold {threshold}): {sample}{more}")


__all__ = [
    "DEFAULT_EXPLORED_ROOT",
    "CandidateArtifacts",
    "ExplorationRecord",
    "ExplorationStore",
    "hash_idea",
    "bundle_identifier_set",
    "tutorial_leak_check",
]
