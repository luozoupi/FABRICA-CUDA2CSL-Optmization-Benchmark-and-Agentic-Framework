#!/usr/bin/env python3
"""A/B replay harness for the translation_facts slot.

Reads captured translation_log.json files from a prior W1 sweep, finds the
implementer's translate call, fires it twice — once WITHOUT the facts block
and once WITH the facts block injected — and scores both responses against
a cheap structural-class checker that detects the W1 failure patterns
(c2d_params field names, @fmacs arity, queue collisions, task-id reuse).

Goal: per-attempt signal on whether the facts block prevents specific
known-error-classes, without the cost of a full cslc compile + simulator
run per arm.

Usage:
    # Dry run (no LLM calls), just verify the harness can walk the corpus
    # and the structural checker fires:
    python3 tools/ab_translation_facts.py \\
        --sweep-root code_translation/results/resweep_w1_opus_rag_20260603 \\
        --dry-run

    # Real A/B (requires Argo proxy at 127.0.0.1:23984 + Opus 4.7):
    python3 tools/ab_translation_facts.py \\
        --sweep-root code_translation/results/resweep_w1_opus_rag_20260603 \\
        --model claude-opus-4-7 --provider argo \\
        --out tools/ab_translation_facts_$(date -u +%Y%m%d).csv
"""

from __future__ import annotations

import argparse
import csv
import json
import logging
import os
import re
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

# Make sibling-package imports work when run from repo root.
_REPO_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(_REPO_ROOT / "code_translation"))

from translation_facts import render_facts_block  # noqa: E402

logger = logging.getLogger("ab_facts")

# Anchor line in the implementer prompt: text that sits immediately BEFORE
# where {translation_facts} renders in the current prompt template. We use
# this as the splice point: when injecting facts into a captured prompt,
# we insert the block after this anchor.
_FACTS_INSERT_ANCHOR = (
    "must each end with `sys_mod.unblock_cmd_stream();`\n"
    "     so the host can chain the next `simulator.launch(...)` call."
)


def _is_implementer_call(msg: Dict[str, str]) -> bool:
    """Detect the user message that contains the translate prompt."""
    if msg.get("role") != "user":
        return False
    c = msg.get("content", "")
    return ("Translate the following CUDA kernel into a CSL compute file"
            in c)


def _find_kernel_dir(kernel_name: str) -> Optional[Path]:
    """Map a kernel name from the result dir to its source kernel dir.

    Result dirs use dashes, source dirs use spaces. Build a few common
    normalizations and try each. Falls back to a fuzzy match over the
    kernels/ directory when none of the explicit candidates work.
    """
    candidates = [
        kernel_name,
        kernel_name.replace("-", " "),
        kernel_name.replace("-", " ").strip(),
        # Special-case kernels with mixed dashes + numeric suffixes:
        # 'FFT-1D-2D' -> 'FFT 1D-2D' (keep one dash).
        re.sub(r"^([A-Za-z]+)-(\d.*)$",
               lambda m: f"{m.group(1)} {m.group(2)}", kernel_name),
    ]
    for c in candidates:
        p = _REPO_ROOT / "kernels" / c
        if (p / "CSL" / "layout.csl").is_file() or (p / "layout.csl").is_file():
            return p
    # Fuzzy fallback: ignore case and non-alphanumeric.
    norm = re.sub(r"[^a-z0-9]", "", kernel_name.lower())
    for entry in (_REPO_ROOT / "kernels").iterdir():
        if not entry.is_dir():
            continue
        ename = re.sub(r"[^a-z0-9]", "", entry.name.lower())
        if ename == norm:
            return entry
    return None


def _inject_facts(prompt: str, facts_block: str) -> str:
    """Insert the facts block at the spot the current production template has it."""
    if _FACTS_INSERT_ANCHOR in prompt:
        return prompt.replace(
            _FACTS_INSERT_ANCHOR,
            _FACTS_INSERT_ANCHOR + "\n\n" + facts_block,
            1,
        )
    # Fallback: prepend as a section. Better than silently dropping.
    return facts_block + "\n\n" + prompt


def _extract_csl_block(reply: str) -> Optional[str]:
    """Pull the first ```csl fenced block from a model reply."""
    m = re.search(r"```csl\n(.*?)```", reply, flags=re.DOTALL)
    if not m:
        return None
    return m.group(1)


# ----- structural-class checker -------------------------------------------
#
# Each check returns (pass: bool, error_class: str). pass=True means the
# CSL does NOT exhibit the failure pattern. The aggregate "structural_ok"
# is the AND over all enabled checks.

def _check_no_c2d_dim_size(csl: str) -> Tuple[bool, str]:
    """W1 verdict: 'c2d_params.x.dim_size doesn't exist'."""
    if re.search(r"c2d_params\s*\.\s*(?:x|y)\s*\.\s*dim_size", csl):
        return False, "uses c2d_params.x.dim_size (does not exist)"
    if re.search(r"\bc2d_params\.dim_size\b", csl):
        return False, "uses c2d_params.dim_size (does not exist)"
    return True, ""


def _check_fmacs_arity(csl: str) -> Tuple[bool, str]:
    """W1 verdict: '@fmacs requires 4 args, but call passes only 3'."""
    # Find every @fmacs( ... ) call, count top-level commas in the arg list.
    bad = []
    for m in re.finditer(r"@fmacs\s*\(", csl):
        depth = 1
        i = m.end()
        start = i
        while i < len(csl) and depth > 0:
            ch = csl[i]
            if ch == "(":
                depth += 1
            elif ch == ")":
                depth -= 1
            i += 1
        args = csl[start:i - 1]
        # Count top-level commas.
        d = 0
        commas = 0
        for ch in args:
            if ch == "(":
                d += 1
            elif ch == ")":
                d -= 1
            elif ch == "," and d == 0:
                commas += 1
        if commas != 3:  # 4 args = 3 top-level commas
            bad.append(f"@fmacs with {commas + 1} args at offset {m.start()}")
    if bad:
        return False, "; ".join(bad[:3])
    return True, ""


def _check_no_reserved_queue_usage(csl: str,
                                   facts: Dict[str, Any]) -> Tuple[bool, str]:
    """If memcpy reserves queues 0,1, the compute file must not @get_input_queue(0|1)."""
    reserved = facts.get("memcpy_reserved_input_queues") or []
    if not isinstance(reserved, list):
        return True, ""
    for q in reserved:
        if re.search(rf"@get_input_queue\s*\(\s*{q}\s*\)", csl):
            return False, f"@get_input_queue({q}) collides with memcpy reservation"
    return True, ""


def _check_no_task_id_reuse(csl: str,
                            facts: Dict[str, Any]) -> Tuple[bool, str]:
    """Compute file must not @get_local_task_id with an ID layout.csl already owns."""
    owned = facts.get("task_ids_owned_by_layout") or []
    if not isinstance(owned, list):
        return True, ""
    bad = []
    for m in re.finditer(r"@get_local_task_id\s*\(\s*(\d+)\s*\)", csl):
        n = int(m.group(1))
        if n in owned:
            bad.append(f"@get_local_task_id({n}) — already owned by layout.csl")
    if bad:
        return False, "; ".join(bad[:3])
    return True, ""


def score_csl(csl: Optional[str],
              facts: Dict[str, Any]) -> Dict[str, Any]:
    """Apply all structural checks; return verdict dict."""
    if not csl:
        return {"structural_ok": False, "error_class": "no ```csl fence in reply",
                "checks": {}}
    checks: Dict[str, Tuple[bool, str]] = {
        "no_c2d_dim_size": _check_no_c2d_dim_size(csl),
        "fmacs_arity": _check_fmacs_arity(csl),
        "no_reserved_queue": _check_no_reserved_queue_usage(csl, facts),
        "no_task_id_reuse": _check_no_task_id_reuse(csl, facts),
    }
    all_ok = all(p for p, _ in checks.values())
    error_class = ""
    if not all_ok:
        for name, (p, e) in checks.items():
            if not p:
                error_class = f"{name}: {e}"
                break
    return {
        "structural_ok": all_ok,
        "error_class": error_class,
        "checks": {k: {"ok": v[0], "msg": v[1]} for k, v in checks.items()},
    }


# ----- LLM call wrapper ---------------------------------------------------

def _build_provider(provider: str, model: str):
    from workflow_common import resolve_provider  # type: ignore
    return resolve_provider(provider=provider, model=model, require=True)


def _fire_one(provider, messages: List[Dict[str, str]],
              max_tokens: int = 8192) -> str:
    from workflow_common import llm_complete  # type: ignore
    return llm_complete(provider.client, provider.model, messages, max_tokens)


# ----- main loop ----------------------------------------------------------

def _walk_attempts(sweep_root: Path) -> List[Tuple[str, Path]]:
    """Return list of (kernel_name, translation_log_path) tuples to A/B."""
    out: List[Tuple[str, Path]] = []
    for run_dir in sorted(sweep_root.glob("run_*")):
        for kdir in sorted(run_dir.iterdir()):
            if not kdir.is_dir():
                continue
            tl = kdir / "translation_log.json"
            if tl.is_file():
                out.append((kdir.name, tl))
    return out


def _kernel_passed(kdir: Path) -> bool:
    """Skip kernels that already passed — we want signal from FAILING attempts."""
    bj = kdir / "benchmark.json"
    if not bj.is_file():
        return False
    try:
        d = json.loads(bj.read_text())
        return d.get("status") == "pass"
    except Exception:
        return False


def run(args: argparse.Namespace) -> int:
    sweep_root = Path(args.sweep_root).resolve()
    if not sweep_root.is_dir():
        logger.error("sweep-root not found: %s", sweep_root)
        return 2

    rows: List[Dict[str, Any]] = []
    cases = _walk_attempts(sweep_root)
    logger.info("found %d attempt logs under %s", len(cases), sweep_root)

    if not args.dry_run:
        provider = _build_provider(args.provider, args.model)
        logger.info("provider=%s model=%s", provider.kind, provider.model)
    else:
        provider = None

    fired = 0
    for kernel, tl_path in cases:
        if args.skip_passing and _kernel_passed(tl_path.parent):
            logger.info("[%s] already passed; skipping", kernel)
            continue
        kdir = _find_kernel_dir(kernel)
        if not kdir:
            logger.warning("[%s] could not resolve source kernel dir; skipping",
                           kernel)
            continue
        try:
            data = json.loads(tl_path.read_text())
        except Exception as exc:
            logger.warning("[%s] failed to parse log: %s", kernel, exc)
            continue
        messages = data.get("messages") or []
        # Find every implementer call in the captured transcript.
        impl_indices = [i for i, m in enumerate(messages)
                        if _is_implementer_call(m)]
        if not impl_indices:
            logger.warning("[%s] no implementer call found", kernel)
            continue
        # Render the facts block for the WITH arm.
        try:
            facts_block = render_facts_block(kdir)
        except Exception as exc:
            logger.warning("[%s] facts render failed: %s", kernel, exc)
            continue
        # Re-extract the facts dict for the structural checker.
        from translation_facts import extract_layout_facts
        try:
            facts_dict = extract_layout_facts(kdir)
        except Exception:
            facts_dict = {}

        for attempt_id, idx in enumerate(impl_indices, 1):
            if attempt_id > args.max_attempts_per_kernel:
                break
            captured_prompt = messages[idx]["content"]
            # Without arm: replay captured prompt verbatim.
            msgs_without = messages[: idx + 1]
            # With arm: same prefix, but the implementer call has facts injected.
            modified_call = dict(messages[idx])
            modified_call["content"] = _inject_facts(captured_prompt, facts_block)
            msgs_with = messages[: idx] + [modified_call]

            tokens_without = sum(len(m.get("content") or "")
                                  for m in msgs_without)
            tokens_with = sum(len(m.get("content") or "")
                              for m in msgs_with)
            row: Dict[str, Any] = {
                "kernel": kernel,
                "attempt_id": attempt_id,
                "prior_error_class": "unknown",
                "without_facts_structural_ok": None,
                "with_facts_structural_ok": None,
                "without_facts_error": "",
                "with_facts_error": "",
                "tokens_without_chars": tokens_without,
                "tokens_with_chars": tokens_with,
                "tokens_delta_chars": tokens_with - tokens_without,
            }

            if args.dry_run:
                # Score the captured response (= "without facts" arm) only.
                if idx + 1 < len(messages):
                    captured_reply = messages[idx + 1].get("content", "")
                    csl = _extract_csl_block(captured_reply)
                    verdict = score_csl(csl, facts_dict)
                    row["without_facts_structural_ok"] = verdict["structural_ok"]
                    row["without_facts_error"] = verdict["error_class"]
                rows.append(row)
                continue

            # Fire both arms.
            try:
                reply_without = _fire_one(provider, msgs_without)
            except Exception as exc:
                logger.error("[%s] attempt %d without-arm failed: %s",
                             kernel, attempt_id, str(exc)[:200])
                continue
            try:
                reply_with = _fire_one(provider, msgs_with)
            except Exception as exc:
                logger.error("[%s] attempt %d with-arm failed: %s",
                             kernel, attempt_id, str(exc)[:200])
                continue
            csl_w = _extract_csl_block(reply_without)
            csl_wf = _extract_csl_block(reply_with)
            v_w = score_csl(csl_w, facts_dict)
            v_wf = score_csl(csl_wf, facts_dict)
            row["without_facts_structural_ok"] = v_w["structural_ok"]
            row["with_facts_structural_ok"] = v_wf["structural_ok"]
            row["without_facts_error"] = v_w["error_class"]
            row["with_facts_error"] = v_wf["error_class"]
            rows.append(row)
            fired += 1
            logger.info("[%s] attempt %d: without=%s with=%s delta_chars=%d",
                        kernel, attempt_id,
                        v_w["structural_ok"], v_wf["structural_ok"],
                        row["tokens_delta_chars"])

    # Write CSV.
    out_path = Path(args.out).resolve()
    out_path.parent.mkdir(parents=True, exist_ok=True)
    if rows:
        fieldnames = list(rows[0].keys())
        with open(out_path, "w", newline="", encoding="utf-8") as f:
            w = csv.DictWriter(f, fieldnames=fieldnames)
            w.writeheader()
            for r in rows:
                w.writerow(r)
        logger.info("wrote %d rows -> %s", len(rows), out_path)

    # Summary.
    total = len(rows)
    if not args.dry_run:
        wins = sum(1 for r in rows
                   if r["with_facts_structural_ok"]
                   and not r["without_facts_structural_ok"])
        losses = sum(1 for r in rows
                     if not r["with_facts_structural_ok"]
                     and r["without_facts_structural_ok"])
        ties = total - wins - losses
        if total > 0:
            median_delta = sorted(r["tokens_delta_chars"] for r in rows)[total // 2]
        else:
            median_delta = 0
        print("\n================ A/B SUMMARY ================")
        print(f"Total attempts replayed: {total}  (fired both arms: {fired})")
        print(f"  WIN  (with-facts ok, without-facts not): {wins}")
        print(f"  LOSS (without-facts ok, with-facts not): {losses}")
        print(f"  TIE  (both same):                        {ties}")
        print(f"  Median prompt delta (chars):             {median_delta}")
        print(f"CSV: {out_path}")
        print("=============================================")
    else:
        failing = sum(1 for r in rows
                      if r["without_facts_structural_ok"] is False)
        passing = sum(1 for r in rows
                      if r["without_facts_structural_ok"] is True)
        print("\n============== DRY-RUN SUMMARY ==============")
        print(f"Total attempts walked: {total}")
        print(f"  captured-reply structural_ok=True:  {passing}")
        print(f"  captured-reply structural_ok=False: {failing}")
        print(f"CSV (dry-run, without-arm only): {out_path}")
        print("=============================================")
    return 0


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--sweep-root", required=True,
                   help="Path to results/resweep_w1_*_<date>/ directory")
    p.add_argument("--out", default="tools/ab_translation_facts.csv",
                   help="Output CSV path")
    p.add_argument("--provider", default="argo",
                   help="Provider for LLM calls (argo, openai, alcf)")
    p.add_argument("--model", default="claude-opus-4-7",
                   help="Model name")
    p.add_argument("--max-attempts-per-kernel", type=int, default=8,
                   help="Cap on attempts replayed per kernel")
    p.add_argument("--skip-passing", action="store_true", default=True,
                   help="Skip kernels that already passed (default ON)")
    p.add_argument("--no-skip-passing", action="store_false",
                   dest="skip_passing")
    p.add_argument("--dry-run", action="store_true",
                   help="Walk corpus + score captured replies; no LLM calls")
    p.add_argument("-v", "--verbose", action="store_true")
    args = p.parse_args()
    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    )
    return run(args)


if __name__ == "__main__":
    raise SystemExit(main())
