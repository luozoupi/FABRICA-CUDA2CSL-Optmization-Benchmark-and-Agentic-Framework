#!/usr/bin/env python3
"""Autonomous CSL exploration workflow.

Independent of and parallel to ``cuda2csl.py``: lives in its own process,
reads its own provider, writes only to ``~/xkernel/knowledge/explored/``
(and, on promotion, to ``kernels/<new_name>/`` via ``explore_promote.py``).
The existing translation/optimisation workflows do NOT consume this
workflow's outputs except through the leak-checked tutorial corpus the
promotion stage produces.

Three modes:
  * variation  — propose N tweaks of an existing passing kernel, score
    each against the baseline.
  * idea       — pick high-gap ideas from ``seeds/idea_seeds.yaml``, ask
    the implementer to author a fresh bundle.
  * cuda-nl    — pick widely-tried CUDA kernels from the catalog, reduce
    them to a natural-language SPEC, then design wafer-native CSL from
    the SPEC (the CUDA source is NEVER shown to the architect/implementer).

See ``/home/USER/.claude/plans/hi-you-are-now-velvet-toast.md`` for the
design rationale and integration map.
"""

from __future__ import annotations

import argparse
import logging
import os
import re
import shutil
import sys
import tempfile
import traceback
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any, Callable, Dict, List, Optional, Tuple

# Local imports (siblings — they assume this file sits in code_translation/).
THIS_DIR = Path(__file__).resolve().parent
if str(THIS_DIR) not in sys.path:
    sys.path.insert(0, str(THIS_DIR))

from benchmark_csl import benchmark_translated_compute_file  # type: ignore
from contract_check import validate_against_reference  # type: ignore
import csl_knowledge_base  # type: ignore
from debugger_agent import DebuggerAgent, DebuggerInput  # type: ignore
from explore_modes import Candidate  # type: ignore
from explore_modes import mode_idea, mode_variation, mode_cuda_nl  # type: ignore
from explore_modes.idea_sampler import IdeaSampler, load_seeds  # type: ignore
from knowledge_persistence import (  # type: ignore
    DEFAULT_EXPLORED_ROOT,
    CandidateArtifacts,
    ExplorationStore,
)
from mesh_gate import check_mesh_gate  # type: ignore
import numeric_check  # type: ignore
from prompt_cuda2csl import (  # type: ignore
    CYCLES_SEND_RECIPE,
    Instruction_system_explore,
    csl_explore_bundle_fix,
    builtin_whitelist_block,
)
from workflow_common import (  # type: ignore
    DEFAULT_API_KEY_FILE,
    ProviderHandle,
    ensure_directory,
    expand_path,
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
logger = logging.getLogger("explore_csl")


REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SDK_ROOT = default_sdk_root()


# ---------------------------------------------------------------------------
# Bundle parsing
# ---------------------------------------------------------------------------

FENCED_RE = {
    "design":   re.compile(r"```design\s*\n(.*?)```", re.DOTALL),
    "layout":   re.compile(r"```layout\s*\n(.*?)```", re.DOTALL),
    "pe":       re.compile(r"```(?:pe|csl)\s*\n(.*?)```", re.DOTALL),
    "run":      re.compile(r"```(?:run|python|py)\s*\n(.*?)```", re.DOTALL),
    "commands": re.compile(r"```(?:commands|bash|sh)\s*\n(.*?)```", re.DOTALL),
}


def parse_bundle_reply(text: str) -> Dict[str, str]:
    """Extract the five fenced sections an implementer reply should contain.

    Tolerant of missing pieces (a partial bundle is logged and downstream
    code decides whether to count it as a failure). The pe/run/commands
    fences also accept the language tags ``csl`` / ``python`` / ``bash`` so
    older / external prompts still parse.
    """
    out: Dict[str, str] = {}
    if not text:
        return out
    for key, regex in FENCED_RE.items():
        m = regex.search(text)
        if m:
            out[key] = m.group(1).strip()
    return out


DEFAULT_COMMANDS_SH = (
    "#!/usr/bin/env bash\n"
    "set -e\n"
    "cslc --arch=wse3 ./layout.csl --fabric-dims=11,6 --fabric-offsets=4,1 "
    "--memcpy --channels=1 -o out\n"
    "cs_python run.py --name out\n"
)


# ---------------------------------------------------------------------------
# ExplorationOrchestrator
# ---------------------------------------------------------------------------

@dataclass
class CandidateOutcome:
    candidate: Candidate
    bundle: Dict[str, str]                    # parsed bundle (possibly empty)
    benchmark: Optional[Dict[str, Any]] = None
    status: str = "unknown"                   # success | failure | numeric_check_failed | infeasible
    failure_reason: Optional[str] = None
    diagnosis: Optional[str] = None
    lessons: List[str] = field(default_factory=list)
    raw_reply: str = ""


class ExplorationOrchestrator:
    """Composes provider + persistence + mode handlers.

    Deliberately NOT a subclass of CUDA2CSLOrchestrator: that class is built
    around a specific CUDA→CSL conversation pattern (analyse→design→
    translate→repair) which doesn't fit the bundle-emit-and-verify flow of
    exploration. We reuse helpers (llm_complete, benchmark_csl,
    csl_knowledge_base, debugger_agent) — not state machines.
    """

    def __init__(self,
                 *,
                 provider: ProviderHandle,
                 store: ExplorationStore,
                 sdk_root: str,
                 work_root: str,
                 shell_setup: Optional[str],
                 max_tokens: int = 8192,
                 max_repair_attempts: int = 2,
                 simfabric_only: bool = True,
                 enable_singularity_gate: bool = False) -> None:
        self.provider = provider
        self.store = store
        self.sdk_root = sdk_root
        self.work_root = ensure_directory(expand_path(work_root))
        self.shell_setup = shell_setup
        self.max_tokens = max_tokens
        self.max_repair_attempts = max_repair_attempts
        self.simfabric_only = simfabric_only
        if enable_singularity_gate:
            os.environ["XKERNEL_SINGULARITY_GATE"] = "1"
        # Force the debugger on for explore mode; it's the cheapest way to
        # turn bucket-B retries into actionable patches.
        os.environ.setdefault("XKERNEL_DEBUGGER", "1")

    # ----- LLM call (single point of dispatch) -----------------------------

    def llm(self, prompt: str, *, max_tokens: Optional[int] = None,
            system: Optional[str] = None) -> str:
        messages = [
            {"role": "system", "content": system or Instruction_system_explore},
            {"role": "user", "content": prompt},
        ]
        return llm_complete(self.provider.client,
                            self.provider.model,
                            messages,
                            max_tokens or self.max_tokens)

    def llm_call_for_debugger(self, messages, max_tokens=None):
        return llm_complete(self.provider.client, self.provider.model,
                            messages, max_tokens or self.max_tokens)

    # ----- bundle materialisation ------------------------------------------

    def stage_bundle(self, bundle: Dict[str, str], scratch: str) -> Dict[str, str]:
        """Write a parsed bundle into a fresh directory, return file paths."""
        ensure_directory(scratch)
        paths: Dict[str, str] = {}
        if bundle.get("layout"):
            p = os.path.join(scratch, "layout.csl")
            with open(p, "w", encoding="utf-8") as fh:
                fh.write(bundle["layout"])
            paths["layout"] = p
        if bundle.get("pe"):
            p = os.path.join(scratch, "pe.csl")
            with open(p, "w", encoding="utf-8") as fh:
                fh.write(bundle["pe"])
            paths["pe"] = p
        if bundle.get("run"):
            p = os.path.join(scratch, "run.py")
            with open(p, "w", encoding="utf-8") as fh:
                fh.write(bundle["run"])
            paths["run"] = p
        if bundle.get("commands"):
            p = os.path.join(scratch, "commands_wse3.sh")
            with open(p, "w", encoding="utf-8") as fh:
                fh.write(bundle["commands"])
        else:
            p = os.path.join(scratch, "commands_wse3.sh")
            with open(p, "w", encoding="utf-8") as fh:
                fh.write(DEFAULT_COMMANDS_SH)
        paths["commands"] = p
        os.chmod(p, 0o755)
        if bundle.get("design"):
            with open(os.path.join(scratch, "DESIGN.md"), "w", encoding="utf-8") as fh:
                fh.write(bundle["design"])
        return paths

    # ----- benchmark wrapper -----------------------------------------------

    def benchmark_bundle(self, bundle_dir: str) -> Dict[str, Any]:
        """Run the staged bundle and return the benchmark dict.

        Exploration bundles are self-contained, so the reference_dir IS the
        bundle dir itself; the translated_path is the compute file inside
        the bundle. ``benchmark_translated_compute_file`` will copy the bundle
        once more into a sandbox before running.
        """
        bundle = Path(bundle_dir)
        pe_path = bundle / "pe.csl"
        if not pe_path.is_file():
            return {
                "status": "fail",
                "failure_reason": "missing pe.csl",
                "transcript": [],
            }
        work_dir = tempfile.mkdtemp(prefix="explore_bench_", dir=self.work_root)
        try:
            return benchmark_translated_compute_file(
                translated_path=str(pe_path),
                reference_dir=str(bundle),
                target_relpath="pe.csl",
                work_dir=work_dir,
                sdk_root=self.sdk_root,
                shell_setup=self.shell_setup,
                commands_script="commands_wse3.sh",
                arch="wse3",
                keep_staged_bundle=False,
                num_runs=1,
            )
        finally:
            shutil.rmtree(work_dir, ignore_errors=True)

    # ----- one candidate end-to-end ----------------------------------------

    def run_candidate(self, cand: Candidate) -> CandidateOutcome:
        outcome = CandidateOutcome(candidate=cand, bundle={})

        # Step 1: if mode-C, the architect prompt runs first (separate call).
        # Its DESIGN gets folded into the implementer's "prior_lessons" slot
        # to keep the implementer aware of the wafer-side decomposition.
        impl_prompt = cand.implementer_prompt
        if cand.architect_prompt:
            try:
                design = self.llm(cand.architect_prompt, max_tokens=2048)
            except Exception as exc:
                logger.warning("[%s] architect call failed: %s", cand.id, str(exc)[:200])
                design = ""
            if design and "{filled in by orchestrator with the DESIGN.md}" in impl_prompt:
                impl_prompt = impl_prompt.replace(
                    "(filled in by orchestrator with the DESIGN.md)",
                    design.strip()[:3500],
                )

        # Step 2: implementer (or proposer for Mode A — same shape).
        try:
            reply = self.llm(impl_prompt)
        except Exception as exc:
            outcome.status = "failure"
            outcome.failure_reason = f"implementer call errored: {exc}"
            logger.warning("[%s] implementer call errored: %s",
                           cand.id, str(exc)[:200])
            outcome.raw_reply = ""
            return outcome
        outcome.raw_reply = reply
        outcome.bundle = parse_bundle_reply(reply)

        missing = [k for k in ("layout", "pe", "run") if not outcome.bundle.get(k)]
        if missing:
            outcome.status = "failure"
            outcome.failure_reason = (
                f"implementer omitted required block(s): {','.join(missing)}"
            )
            return outcome

        # Step 3: numeric-check gate BEFORE we burn cslc on a degenerate
        # candidate. Bad / missing assert_allclose → fail fast.
        nc = numeric_check.validate_run_py(outcome.bundle["run"])
        if nc is not None:
            outcome.status = "numeric_check_failed"
            outcome.failure_reason = nc
            return outcome

        # Step 3b: mesh gate. Parse @set_rectangle(W, H) from the LLM's
        # layout.csl, resolve const/--params, and reject if W*H is below
        # the seed's hard floor. Catches the single-PE collapse of
        # hard-tier seeds (e.g. matmul_summa_2d, stencil_5pt_2d) before
        # we burn cslc on a trivially-correct but useless bundle.
        if cand.min_pe_count > 1:
            gate = check_mesh_gate(
                outcome.bundle["layout"],
                outcome.bundle.get("commands", ""),
                min_pe_count=cand.min_pe_count,
            )
            if not gate.passed:
                outcome.status = "failure"
                outcome.failure_reason = gate.reason or "mesh_too_small"
                logger.info("[%s] mesh gate REJECTED: %s",
                            cand.id, outcome.failure_reason)
                return outcome
            if gate.mesh and gate.mesh.pe_count is not None:
                outcome.bundle.setdefault("_mesh_pe_count",
                                          str(gate.mesh.pe_count))

        # Step 4: stage + benchmark.
        scratch = tempfile.mkdtemp(prefix=f"explore_{cand.id}_", dir=self.work_root)
        try:
            self.stage_bundle(outcome.bundle, scratch)
            outcome.benchmark = self.benchmark_bundle(scratch)
        except Exception as exc:
            outcome.status = "failure"
            outcome.failure_reason = f"benchmark error: {exc}"
            logger.warning("[%s] benchmark error: %s", cand.id, str(exc)[:200])
            return outcome
        finally:
            # We keep the scratch dir on disk until promotion runs so the
            # operator can inspect partial state. The benchmark wrapper
            # already cleans its own work_dir.
            pass

        success_marker = bool(outcome.benchmark.get("success_marker"))
        status = outcome.benchmark.get("status") if outcome.benchmark else "fail"
        if status != "pass" or not success_marker:
            outcome.status = "failure"
            outcome.failure_reason = outcome.benchmark.get(
                "failure_reason", "command_failed" if status != "pass"
                                  else "missing_success_marker")
            outcome.diagnosis = self.maybe_diagnose(cand, outcome.bundle,
                                                    outcome.benchmark)
            # Repair loop: feed the debugger's diagnosis back in via the
            # csl_explore_bundle_fix prompt. Capped at max_repair_attempts
            # so a stuck candidate can't run away with cost.
            for attempt in range(self.max_repair_attempts):
                logger.info("[%s] repair attempt %d/%d",
                            cand.id, attempt + 1, self.max_repair_attempts)
                repaired = self.repair_round(cand, outcome)
                if repaired is None:
                    break
                outcome = repaired
                if outcome.status == "success":
                    return outcome
            return outcome

        outcome.status = "success"
        return outcome

    def repair_round(self,
                     cand: Candidate,
                     prev: CandidateOutcome) -> Optional[CandidateOutcome]:
        """One repair iteration: feed prev bundle + diagnosis into
        csl_explore_bundle_fix, re-parse, re-benchmark. Returns the new
        outcome, or None if the repair call itself errored.
        """
        transcript_text = format_command_transcript(
            (prev.benchmark or {}).get("transcript", [])
        )
        layout_req = (
            f"Mesh floor: W*H >= {cand.min_pe_count}. "
            "Single-PE collapses are forbidden for this tier and will be "
            "rejected by the parse-time mesh gate before cslc is even "
            "invoked."
        ) if cand.min_pe_count > 1 else (
            "No mesh floor for this tier; pick whatever shape is correct."
        )
        fix_prompt = csl_explore_bundle_fix.format(
            brief=f"{cand.title}: {cand.summary[:600]}",
            current_layout=prev.bundle.get("layout", "")[:4000],
            current_pe=prev.bundle.get("pe", "")[:6000],
            current_run_py=prev.bundle.get("run", "")[:3500],
            benchmark_status=(prev.benchmark or {}).get("status", "fail"),
            failure_reason=prev.failure_reason or "unknown",
            command_transcript=transcript_text[:4000],
            prior_round_diagnosis=prev.diagnosis or "(no diagnosis available)",
            layout_requirements=layout_req,
            builtin_whitelist=builtin_whitelist_block(),
            cycles_send_recipe=CYCLES_SEND_RECIPE,
        )
        try:
            reply = self.llm(fix_prompt)
        except Exception as exc:
            logger.warning("[%s] repair LLM call errored: %s",
                           cand.id, str(exc)[:200])
            return None

        new_outcome = CandidateOutcome(candidate=cand, bundle={})
        new_outcome.raw_reply = reply
        new_outcome.bundle = parse_bundle_reply(reply)
        # If the fix omitted a block, fall back to the prior bundle's copy
        # so we don't regress (the repair prompt may legitimately leave
        # layout / run.py unchanged).
        for k in ("layout", "pe", "run", "commands"):
            if not new_outcome.bundle.get(k) and prev.bundle.get(k):
                new_outcome.bundle[k] = prev.bundle[k]

        nc = numeric_check.validate_run_py(new_outcome.bundle.get("run", ""))
        if nc is not None:
            new_outcome.status = "numeric_check_failed"
            new_outcome.failure_reason = nc
            return new_outcome

        if cand.min_pe_count > 1:
            gate = check_mesh_gate(
                new_outcome.bundle.get("layout", ""),
                new_outcome.bundle.get("commands", ""),
                min_pe_count=cand.min_pe_count,
            )
            if not gate.passed:
                new_outcome.status = "failure"
                new_outcome.failure_reason = gate.reason or "mesh_too_small"
                logger.info("[%s] repair mesh gate REJECTED: %s",
                            cand.id, new_outcome.failure_reason)
                return new_outcome

        scratch = tempfile.mkdtemp(prefix=f"explore_{cand.id}_repair_",
                                   dir=self.work_root)
        try:
            self.stage_bundle(new_outcome.bundle, scratch)
            new_outcome.benchmark = self.benchmark_bundle(scratch)
        except Exception as exc:
            new_outcome.status = "failure"
            new_outcome.failure_reason = f"repair benchmark error: {exc}"
            return new_outcome

        success_marker = bool((new_outcome.benchmark or {}).get("success_marker"))
        status = (new_outcome.benchmark or {}).get("status", "fail")
        if status == "pass" and success_marker:
            new_outcome.status = "success"
            return new_outcome
        new_outcome.status = "failure"
        new_outcome.failure_reason = (new_outcome.benchmark or {}).get(
            "failure_reason",
            "command_failed" if status != "pass" else "missing_success_marker",
        )
        new_outcome.diagnosis = self.maybe_diagnose(
            cand, new_outcome.bundle, new_outcome.benchmark or {},
        )
        return new_outcome

    # ----- diagnosis (optional debugger) -----------------------------------

    def maybe_diagnose(self,
                       cand: Candidate,
                       bundle: Dict[str, str],
                       benchmark: Dict[str, Any]) -> Optional[str]:
        try:
            dbg = DebuggerAgent(llm_call=self.llm_call_for_debugger,
                                max_tokens=1024)
            stderr_tail = ""
            for entry in (benchmark.get("transcript") or []):
                if entry.get("status") != "pass":
                    stderr_tail = (entry.get("stderr") or "")[-2000:]
                    break
            inp = DebuggerInput(
                current_csl=bundle.get("pe", ""),
                stderr_tail=stderr_tail,
                failure_reason=str(benchmark.get("failure_reason") or ""),
                reviewer_rationale="(no reviewer — explore mode)",
                reviewer_debug_action="inspect cslc stderr and propose patch",
                reference_contract=bundle.get("layout", ""),
                layout_csl=bundle.get("layout", ""),
            )
            report = dbg.diagnose(inp)
            return report.to_prompt_block()
        except Exception as exc:
            logger.warning("[%s] debugger errored: %s", cand.id, str(exc)[:200])
            return None

    # ----- per-mode dispatch -----------------------------------------------

    def propose(self, mode: str, args: argparse.Namespace,
                store: ExplorationStore) -> List[Candidate]:
        if mode == "idea":
            seen = store.seen_idea_hashes()
            infeasible = store.infeasible_idea_hashes()
            # Build a coarse "attempt count" map from the records.
            counts: Dict[str, int] = {}
            for r in store.list_records():
                h = r.get("idea_hash")
                if not h:
                    continue
                counts[h] = counts.get(h, 0) + 1
            diff_filter = None if getattr(args, "difficulty", "all") == "all" \
                          else args.difficulty
            sampler = IdeaSampler(
                seeds=load_seeds(args.seed_catalog) if args.seed_catalog else None,
                seen_hashes=seen,
                infeasible_hashes=infeasible,
                prior_attempt_counts=counts,
                difficulty_filter=diff_filter,
                layout_complexity_filter=getattr(args, "layout_complexity", None),
                compute_complexity_filter=getattr(args, "compute_complexity", None),
            )
            if not sampler.seeds:
                logger.warning("[propose] no seeds match filters "
                               "(difficulty=%s layout=%s compute=%s)",
                               diff_filter,
                               getattr(args, "layout_complexity", None),
                               getattr(args, "compute_complexity", None))
                return []
            return mode_idea.propose_candidates(
                sampler=sampler,
                n_candidates=args.candidates_per_round,
                explored_root=str(store.root),
            )
        if mode == "cuda-nl":
            seen = store.seen_idea_hashes()
            only_ids = args.cuda_nl_ids.split(",") if args.cuda_nl_ids else None
            spec_caller = (lambda p: self.llm(p, max_tokens=2048)) if not args.dry_run else None
            return mode_cuda_nl.propose_candidates(
                n_candidates=args.candidates_per_round,
                catalog_path=args.seed_catalog or None,
                only_ids=only_ids,
                seen_hashes=seen,
                spec_caller=spec_caller,
            )
        if mode == "variation":
            if not args.seed_kernel:
                raise ValueError("--mode variation requires --seed-kernel PATH")
            return mode_variation.propose_candidates(
                baseline_dir=args.seed_kernel,
                n_variants=args.candidates_per_round,
                proposer_caller=lambda p: self.llm(p, max_tokens=2048),
            )
        raise ValueError(f"unknown mode: {mode!r}")

    # ----- one round end-to-end --------------------------------------------

    def run_round(self, candidates: List[Candidate],
                  concurrency: int = 1) -> List[CandidateOutcome]:
        if not candidates:
            return []
        outcomes: List[CandidateOutcome] = []
        if concurrency <= 1:
            for cand in candidates:
                outcomes.append(self.run_candidate(cand))
                self.persist_outcome(outcomes[-1])
            return outcomes
        with ThreadPoolExecutor(max_workers=concurrency) as pool:
            futures = {pool.submit(self.run_candidate, c): c for c in candidates}
            for fut in as_completed(futures):
                try:
                    outcome = fut.result()
                except Exception as exc:
                    cand = futures[fut]
                    logger.warning("[%s] worker errored: %s", cand.id,
                                   str(exc)[:200])
                    outcome = CandidateOutcome(
                        candidate=cand, bundle={},
                        status="failure",
                        failure_reason=f"worker exception: {exc}",
                    )
                outcomes.append(outcome)
                self.persist_outcome(outcome)
        return outcomes

    # ----- persistence dispatch --------------------------------------------

    def persist_outcome(self, outcome: CandidateOutcome) -> None:
        cand = outcome.candidate
        kernel_id = cand.id
        chunks_used = cand.features
        if outcome.status == "success" and outcome.benchmark:
            artifacts = CandidateArtifacts(
                pe_csl=outcome.bundle.get("pe", ""),
                layout_csl=outcome.bundle.get("layout", ""),
                run_py=outcome.bundle.get("run", ""),
                commands_sh=outcome.bundle.get("commands", "") or DEFAULT_COMMANDS_SH,
                design_md=outcome.bundle.get("design", ""),
                spec_yaml=self._render_spec_yaml(cand, outcome),
            )
            lessons = outcome.lessons or self._distill_lessons(cand, outcome)
            baseline_cycles = self._baseline_cycles(cand)
            self.store.record_success(
                mode=cand.mode,
                idea=cand.idea,
                kernel_id=kernel_id,
                artifacts=artifacts,
                benchmark_result=outcome.benchmark,
                baseline_ref=cand.baseline_dir,
                baseline_cycles=baseline_cycles,
                lessons=lessons,
                design_choices=[cand.title, cand.summary[:200]],
                chunks_used=chunks_used,
                provider=self.provider.kind,
                model=self.provider.model,
            )
            logger.info("[%s] SUCCESS persisted (cycles=%s)",
                        kernel_id,
                        outcome.benchmark.get("cycles_send"))
            return
        # Failure / numeric / infeasible bucket.
        # Capture the full last-step stdout+stderr (not just the first
        # non-pass step). `missing_success_marker` failures have all
        # transcript entries marked pass, so the earlier "first non-pass"
        # search would yield nothing. We need the run step's actual output.
        stderr_tail = ""
        if outcome.benchmark:
            transcript = outcome.benchmark.get("transcript") or []
            non_pass = [e for e in transcript if e.get("status") != "pass"]
            target = non_pass[0] if non_pass else (transcript[-1] if transcript else None)
            if target:
                stderr_tail = "\n".join([
                    f"step={target.get('step')} status={target.get('status')} "
                    f"returncode={target.get('returncode')} "
                    f"elapsed_ms={target.get('elapsed_ms')}",
                    "---- stdout (tail) ----",
                    str(target.get("stdout") or "")[-1500:],
                    "---- stderr (tail) ----",
                    str(target.get("stderr") or "")[-1500:],
                ])
        if not stderr_tail:
            stderr_tail = outcome.failure_reason or "(no stderr captured)"
        if outcome.status == "numeric_check_failed":
            outcome.lessons.append(
                f"run.py missing valid assert_allclose: {outcome.failure_reason}"
            )
        # Distill lessons from ALL failure types (not just numeric_check).
        if not outcome.lessons and stderr_tail:
            try:
                fail_prompt = (
                    "A Cerebras CSL kernel FAILED. In 1-2 bullet points (≤25 words each), "
                    "distill what went wrong and what to avoid next time. Focus on the "
                    "transferable lesson, NOT the specific kernel.\n\n"
                    f"Kernel: {cand.title}\n"
                    f"Failure: {outcome.failure_reason or 'unknown'}\n"
                    f"Stderr tail: {stderr_tail[-800:]}\n"
                    "Return as bullets only.\n"
                )
                reply = self.llm(fail_prompt, max_tokens=200)
                for line in reply.splitlines():
                    line = line.strip().lstrip("-*•").strip()
                    if line and len(line) > 5:
                        outcome.lessons.append(line[:160])
                    if len(outcome.lessons) >= 2:
                        break
            except Exception:
                outcome.lessons.append(
                    f"failed: {outcome.failure_reason or 'unknown'}"[:120]
                )
        self.store.record_failure(
            mode=cand.mode,
            idea=cand.idea,
            kernel_id=kernel_id,
            last_pe_csl=outcome.bundle.get("pe", ""),
            failure_reason=outcome.failure_reason or "unknown",
            stderr_tail=stderr_tail,
            diagnosis=outcome.diagnosis,
            lessons=outcome.lessons,
            design_choices=[cand.title, cand.summary[:200]],
            chunks_used=chunks_used,
            benchmark_result=outcome.benchmark,
            provider=self.provider.kind,
            model=self.provider.model,
            last_layout_csl=outcome.bundle.get("layout", ""),
            last_run_py=outcome.bundle.get("run", ""),
            last_commands_sh=outcome.bundle.get("commands", ""),
        )
        logger.info("[%s] FAILURE persisted (%s)", kernel_id, outcome.status)

    # ----- helpers ---------------------------------------------------------

    def _baseline_cycles(self, cand: Candidate) -> Optional[int]:
        if cand.mode != "variation" or not cand.baseline_dir:
            return None
        # Look for kernels/X/baselines_wse3.json or kernels/baselines_wse3.json.
        candidates = [
            Path(cand.baseline_dir).parent / "baselines_wse3.json",
            REPO_ROOT / "kernels" / "baselines_wse3.json",
        ]
        for p in candidates:
            if p.is_file():
                try:
                    import json as _json
                    data = _json.loads(p.read_text(encoding="utf-8"))
                    val = data.get(Path(cand.baseline_dir).name)
                    if isinstance(val, dict):
                        c = val.get("cycles_send") or val.get("wse3_reference")
                        if isinstance(c, (int, float)):
                            return int(c)
                except Exception:
                    pass
        return None

    def _distill_lessons(self,
                         cand: Candidate,
                         outcome: CandidateOutcome) -> List[str]:
        """One short LLM call for 1–2 lesson bullets. Best-effort: returns
        a coarse fallback when the call fails."""
        if outcome.benchmark is None:
            return []
        cycles = outcome.benchmark.get("cycles_send")
        prompt = (
            "You just succeeded at writing a Cerebras CSL kernel. In 1 or 2 short "
            "bullet points (each ≤ 25 words), distill what worked. Focus on the "
            "transferable lesson (pattern name, common gotcha avoided), NOT on "
            "the specific kernel.\n\n"
            f"Kernel: {cand.title}\n"
            f"Mode: {cand.mode}\n"
            f"Cycles: {cycles}\n"
            f"Mesh: {cand.suggested_mesh}\n"
            "Return as bullets only, no preamble.\n"
        )
        try:
            reply = self.llm(prompt, max_tokens=300)
        except Exception:
            return [f"succeeded with mesh={cand.suggested_mesh} on {cand.mode}"]
        # Cheap bullet extractor.
        bullets = []
        for line in reply.splitlines():
            line = line.strip().lstrip("-*•").strip()
            if line and len(line) > 5:
                bullets.append(line[:160])
            if len(bullets) >= 2:
                break
        return bullets or [reply.strip()[:160]]

    def _render_spec_yaml(self, cand: Candidate,
                          outcome: CandidateOutcome) -> str:
        cycles = (outcome.benchmark or {}).get("cycles_send", "null")
        return (
            f"kernel_id: {cand.id}\n"
            f"title: {cand.title}\n"
            f"mode: {cand.mode}\n"
            f"difficulty: {cand.difficulty}\n"
            f"suggested_mesh: {cand.suggested_mesh}\n"
            f"features: [{', '.join(cand.features)}]\n"
            f"acceptance_numerics: |\n  "
            + (cand.acceptance_numerics or "").replace("\n", "\n  ")
            + "\n"
            f"wse3_reference:\n  cycles_send: {cycles}\n"
            f"build_command: bash commands_wse3.sh\n"
            f"verify: |\n  assert_allclose inside run.py (host-side reference)\n"
            f"provenance:\n  provider: {self.provider.kind}\n"
            f"  model: {self.provider.model}\n"
        )


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def build_argparser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description="Autonomous CSL kernel exploration (independent of cuda2csl)",
    )
    p.add_argument("--mode", choices=["variation", "idea", "cuda-nl"], required=True)
    p.add_argument("--seed-kernel", type=str, default=None,
                   help="Mode A: path to an existing kernels/<X>/ baseline. "
                        "Mode C: optional pre-curated CUDA reference dir.")
    p.add_argument("--seed-catalog", type=str, default=None,
                   help="Mode B: path to idea_seeds.yaml (default: "
                        "code_translation/seeds/idea_seeds.yaml). "
                        "Mode C: path to cuda_nl_catalog.jsonl.")
    p.add_argument("--cuda-nl-ids", type=str, default=None,
                   help="Mode C: comma-separated list of catalog IDs to try.")
    p.add_argument("--n-rounds", type=int, default=1)
    p.add_argument("--candidates-per-round", type=int, default=2)
    p.add_argument("--difficulty",
                   choices=["easy", "medium", "hard", "all"],
                   default="all",
                   help="Mode B/C: filter seeds by overall difficulty tier "
                        "(derived as max(layout_complexity, compute_complexity)). "
                        "Default: all.")
    p.add_argument("--layout-complexity", type=int, default=None,
                   choices=[1, 2, 3],
                   help="Mode B: pin the layout-complexity axis (1=single-PE, "
                        "2=1D mesh, 3=2D mesh / collectives / halo). "
                        "Composes with --compute-complexity if both set.")
    p.add_argument("--compute-complexity", type=int, default=None,
                   choices=[1, 2, 3],
                   help="Mode B: pin the compute-complexity axis (1=elementwise, "
                        "2=fused multi-pass, 3=iterative / wafer-scale).")
    p.add_argument("--require-mesh-resolved", action="store_true",
                   help="Mesh gate: when the layout's @set_rectangle arguments "
                        "cannot be resolved (arithmetic the narrow parser does "
                        "not handle), treat as a violation instead of letting "
                        "cslc decide. Default: false (fail-open).")
    p.add_argument("--provider", choices=["auto", "alcf", "argo", "openai"],
                   default="auto")
    p.add_argument("--alcf-endpoint", choices=["metis", "sophia"], default="metis")
    p.add_argument("--model", type=str, default=None,
                   help="Override the default model for the chosen provider.")
    p.add_argument("--api-key-file", type=str, default=DEFAULT_API_KEY_FILE)
    p.add_argument("--api-key-command", type=str, default=None)
    p.add_argument("--require-provider", action="store_true",
                   help="Disable silent fallback if the chosen provider fails.")
    p.add_argument("--concurrency", type=int,
                   default=max(1, min(4, (os.cpu_count() or 4) // 2)),
                   help="Worker pool size for benchmarking. Defaults conservative.")
    p.add_argument("--simfabric-only", action="store_true",
                   help="Skip live-WSE runs; simulator only (default behaviour).")
    p.add_argument("--enable-singularity-gate", action="store_true",
                   help="Serialise singularity invocations across workers. "
                        "Strongly recommended at --concurrency > 1.")
    p.add_argument("--export-dir", type=str, default=DEFAULT_EXPLORED_ROOT,
                   help="Root for knowledge/explored/ writes.")
    p.add_argument("--sdk-root", type=str, default=DEFAULT_SDK_ROOT)
    p.add_argument("--work-root", type=str,
                   default=str(Path(__file__).resolve().parent / "sandbox" / "explore_csl"))
    p.add_argument("--shell-setup", type=str, default=None)
    p.add_argument("--shell-setup-file", type=str, default=None)
    p.add_argument("--max-tokens", type=int, default=8192)
    p.add_argument("--repair-attempts", type=int, default=2,
                   help="Max repair iterations per candidate after the first "
                        "failure (each iteration = one debugger diagnosis + "
                        "one implementer fix + one re-benchmark). "
                        "0 disables the repair loop entirely. Default: 2.")
    p.add_argument("--dry-run", action="store_true",
                   help="Skip LLM + cslc; emit a synthetic outcome per candidate. "
                        "Useful for testing CLI wiring + persistence.")
    p.add_argument("--promote-after", action="store_true",
                   help="After this run, invoke explore_promote on new successes.")
    p.add_argument("--auto-promote", action="store_true",
                   help="Promote unpromoted successes after EACH round (not just at end).")
    return p


def synthesize_dry_outcome(cand: Candidate,
                            store: ExplorationStore) -> CandidateOutcome:
    """Make a fake-success outcome that exercises the persistence layer
    without burning any LLM tokens or cslc cycles. Used by --dry-run + tests."""
    return CandidateOutcome(
        candidate=cand,
        bundle={
            "design": f"# Dry-run design for {cand.title}",
            "layout": "// dry-run layout.csl placeholder\n",
            "pe": "// dry-run pe.csl placeholder\n",
            "run": ("import numpy as np\n"
                    "import numpy.testing\n"
                    "# placeholder dry-run run.py\n"
                    "expected = np.zeros(1); device = np.zeros(1)\n"
                    "numpy.testing.assert_allclose(device, expected)\n"),
            "commands": DEFAULT_COMMANDS_SH,
        },
        benchmark={
            "status": "pass",
            "failure_reason": None,
            "compile_time_ms": 0.0,
            "run_time_ms": 0.0,
            "cycles_send": 0,
            "transcript": [],
            "success_marker": True,
        },
        status="success",
        lessons=["dry-run: pipeline exercised without external calls"],
    )


def main() -> int:
    args = build_argparser().parse_args()
    shell_setup = load_shell_setup(args.shell_setup, args.shell_setup_file)
    store = ExplorationStore(args.export_dir)

    # Provider — required even for dry-run so we exercise the resolver path
    # (set --require-provider in tests if you want resolver failures to be
    # loud). When --dry-run is on we fall back to a stub if resolution fails.
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
        if args.dry_run:
            logger.warning("[main] provider unavailable in dry-run; using stub: %s",
                           str(exc)[:200])
            provider = ProviderHandle(kind="stub", client=None, model="stub")
        else:
            logger.error("[main] provider resolution failed: %s", exc)
            return 2

    orch = ExplorationOrchestrator(
        provider=provider,
        store=store,
        sdk_root=expand_path(args.sdk_root),
        work_root=args.work_root,
        shell_setup=shell_setup,
        max_tokens=args.max_tokens,
        max_repair_attempts=max(0, int(args.repair_attempts)),
        simfabric_only=args.simfabric_only,
        enable_singularity_gate=args.enable_singularity_gate,
    )

    total_outcomes: List[CandidateOutcome] = []
    for round_idx in range(args.n_rounds):
        logger.info("[main] === round %d/%d (mode=%s) ===",
                    round_idx + 1, args.n_rounds, args.mode)
        try:
            cands = orch.propose(args.mode, args, store)
        except Exception as exc:
            logger.error("[main] propose failed: %s\n%s", exc, traceback.format_exc())
            return 3
        if not cands:
            logger.info("[main] no candidates produced this round; stopping")
            break
        if args.dry_run:
            outcomes = [synthesize_dry_outcome(c, store) for c in cands]
            for o in outcomes:
                orch.persist_outcome(o)
        else:
            outcomes = orch.run_round(cands, concurrency=args.concurrency)
        total_outcomes.extend(outcomes)
        passes = sum(1 for o in outcomes if o.status == "success")
        logger.info("[main] round %d: %d/%d candidates passed",
                    round_idx + 1, passes, len(outcomes))

        # Failure-pattern clustering: group failures by error family.
        failures = [o for o in outcomes if o.status != "success"]
        if failures:
            try:
                from error_gotcha_retrieval import _ERROR_GOTCHA_TABLE
                from collections import Counter
                family_counts: Counter = Counter()
                for o in failures:
                    stderr = ""
                    if o.benchmark:
                        for e in (o.benchmark.get("transcript") or []):
                            stderr += str(e.get("stderr", "")) + "\n"
                    stderr += o.failure_reason or ""
                    matched = False
                    for pattern, label, _ in _ERROR_GOTCHA_TABLE:
                        if pattern.search(stderr):
                            family_counts[label] += 1
                            matched = True
                    if not matched:
                        family_counts["other"] += 1
                if family_counts:
                    summary_line = ", ".join(f"{k}={v}" for k, v in family_counts.most_common(5))
                    logger.info("[main] failure families: %s", summary_line)
            except Exception:
                pass

        # Auto-promote after each round if requested.
        if args.auto_promote and passes > 0:
            try:
                import explore_promote
                explore_promote.promote_pending(
                    explored_root=str(store.root),
                    llm_caller=lambda p: orch.llm(p, max_tokens=2048),
                )
                logger.info("[main] auto-promoted successes from round %d",
                            round_idx + 1)
            except Exception as exc:
                logger.warning("[main] auto-promote failed: %s", exc)

    if args.promote_after:
        try:
            import explore_promote  # type: ignore
            explore_promote.promote_pending(explored_root=str(store.root),
                                            llm_caller=lambda p: orch.llm(
                                                p, max_tokens=2048))
        except Exception as exc:
            logger.warning("[main] promotion step errored: %s", exc)

    summary = {
        "total_candidates": len(total_outcomes),
        "success": sum(1 for o in total_outcomes if o.status == "success"),
        "failure": sum(1 for o in total_outcomes if o.status == "failure"),
        "numeric_check_failed": sum(
            1 for o in total_outcomes if o.status == "numeric_check_failed"
        ),
        "explored_root": str(store.root),
    }
    print()
    print("=" * 60)
    for k, v in summary.items():
        print(f"  {k:<25} {v}")
    print("=" * 60)
    return 0 if summary["success"] > 0 or args.dry_run else 1


if __name__ == "__main__":
    sys.exit(main())
