#!/usr/bin/env python3
"""Verifiable rewards for CSL code generation, computed with the Cerebras SDK (cslc + simulator).

A completion is scored by the same harness that produced the study's numbers
(benchmark_csl.benchmark_translated_compute_file): the CSL file is extracted from the completion,
overlaid on the task's reference bundle, compiled, run on the SDK simulator and checked numerically by
the bundle's own run.py, optionally on the held-out inputs too.

Reward (translation prompts, record without `base_cycles`):
    0.00  no ```csl block              0.30  compiles, does not run correctly
    0.05  fails the static check       0.60  runs and passes the visible input, fails held-out
    0.10  does not compile             1.00  passes (visible + held-out when enabled)
                                       + speed term w * clip(log2(ref_cycles / cycles), -1, 1) if
                                         `ref_cycles` is given (default w = 0.25)
Reward (optimization prompts, record with `base_cycles`): the same tiers, but a correct program
scores 1 + clip(log2(base_cycles / cycles), -1, 1), so correct-but-slower programs score below 1 and
a 2x speedup scores 2; candidates that violate the frozen-function contract or move work out of the
timed window score 0.05 like a static failure.

Levels: "compile" (compile only; seconds, no simulator) and "run" (compile + simulate + verify).
Results are cached in a SQLite file by (kernel, level, sha256(code)).

Usage from TRL (GRPOTrainer):  reward_funcs=[make_trl_reward(level="run", workers=8)]
Usage from veRL:                custom_reward_function.path=posttrain/csl_reward.py, name=verl_compute_score
CLI:
  python -m posttrain.csl_reward --smoke SpMV-CSR                 # the reference itself must score 1.0
  python -m posttrain.csl_reward --check FILE.jsonl --limit 50    # re-verify SFT responses on this SDK
  python -m posttrain.csl_reward --remeasure-base FILE.jsonl      # base_cycles of optimize prompts on this SDK

Environment: XKERNEL_SDK_ROOT (the SDK directory, e.g. .../cs_sdk-2.10.0), XKERNEL_REWARD_CACHE
(SQLite path), XKERNEL_REWARD_TMP (scratch for staged bundles; one directory per call, removed after).
"""
from __future__ import annotations

import argparse
import concurrent.futures as cf
import hashlib
import json
import math
import os
import shutil
import sqlite3
import sys
import tempfile
import threading
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from posttrain import common as C  # noqa: E402

SDK_ROOT = os.environ.get("XKERNEL_SDK_ROOT", "/software/cerebras/cs_sdk-2.10")
# Most training kernels' reference bundles are SDK 1.4 code; on an SDK 2.x machine the harness ports the
# staged bundle and the candidate (removed comptime_struct / @concat_structs) when these are set.
os.environ.setdefault("XKERNEL_TARGET_SDK", "2.10.0")
os.environ.setdefault("XKERNEL_SDK210_FIXUP", "1")
CACHE = Path(os.environ.get("XKERNEL_REWARD_CACHE", str(Path.home() / ".cache" / "csl_reward.sqlite")))
TMP = Path(os.environ.get("XKERNEL_REWARD_TMP", tempfile.gettempdir()))
_lock = threading.Lock()


def _cache() -> sqlite3.Connection:
    CACHE.parent.mkdir(parents=True, exist_ok=True)
    con = sqlite3.connect(str(CACHE), timeout=60, check_same_thread=False)
    con.execute("CREATE TABLE IF NOT EXISTS r (k TEXT PRIMARY KEY, v TEXT)")
    return con


def _key(kernel: str, level: str, heldout: bool, code: str) -> str:
    return hashlib.sha256(f"{kernel}|{level}|{int(heldout)}|{code}".encode()).hexdigest()


def _completion_text(c: Any) -> str:
    """TRL passes str (standard format) or a list of messages (conversational format)."""
    if isinstance(c, str):
        return c
    if isinstance(c, list) and c and isinstance(c[-1], dict):
        return str(c[-1].get("content") or "")
    if isinstance(c, dict):
        return str(c.get("content") or "")
    return str(c or "")


def _resolve(rec: Dict[str, Any]) -> Tuple[Path, str, str, str]:
    ref = Path(rec["reference_dir"])
    if not ref.is_absolute():
        ref = C.REPO / ref
    return ref, rec.get("target_relpath") or "pe.csl", rec.get("commands_script") or "commands_wse3.sh", \
        C.canonical_kernel(rec.get("kernel") or ref.parent.name)


def evaluate(code: str, rec: Dict[str, Any], level: str = "run", heldout: bool = True,
             timeout: int = 900) -> Dict[str, Any]:
    """Compile (and run) one CSL file in the task's reference bundle. Never raises."""
    ref, target, script, kernel = _resolve(rec)
    k = _key(kernel, level, heldout, code)
    with _lock:
        con = _cache()
        row = con.execute("SELECT v FROM r WHERE k=?", (k,)).fetchone()
        con.close()
    if row:
        return json.loads(row[0])
    from benchmark_csl import benchmark_translated_compute_file, check_csl_syntax
    info: Dict[str, Any] = {"kernel": kernel, "level": level}
    syn = check_csl_syntax(code)
    if not syn.get("syntax_valid", True):
        info.update(stage="static", status="fail", reason="; ".join(syn.get("warnings") or [])[:300])
    else:
        violation = None
        if rec.get("base_code"):
            try:
                from contract_check import spec_frozen_lists, validate_against_reference
                from cuda2csl import load_kernel_spec
                ff, fp = spec_frozen_lists(load_kernel_spec(str(ref)))
                violation = validate_against_reference(code, rec["base_code"], frozen_functions=ff, frozen_params=fp)
            except Exception:
                violation = None
        if violation:
            info.update(stage="contract", status="fail", reason=str(violation)[:300])
        else:
            work = Path(tempfile.mkdtemp(prefix="cslreward_", dir=str(TMP)))
            try:
                src = work / "candidate.csl"
                src.write_text(code)
                r = benchmark_translated_compute_file(
                    translated_path=str(src), reference_dir=str(ref), target_relpath=target,
                    work_dir=str(work / "w"), sdk_root=SDK_ROOT, commands_script=script, timeout=timeout,
                    num_runs=1, keep_staged_bundle=False, compile_only=(level == "compile"),
                    heldout_eval=(heldout and level == "run"))
                compiled = any(t.get("step") == "compile" and (t.get("returncode") or 0) == 0
                               for t in (r.get("transcript") or []))
                info.update(stage=level, status=r.get("status"), compiled=compiled,
                            cycles=r.get("cycles_send"), success_marker=r.get("success_marker"),
                            reason=str(r.get("failure_reason") or "")[:300],
                            heldout=(r.get("heldout_eval") or {}).get("passed") if isinstance(r.get("heldout_eval"), dict) else None)
            except Exception as exc:
                info.update(stage="harness", status="error", reason=f"{type(exc).__name__}: {exc}"[:300])
            finally:
                shutil.rmtree(work, ignore_errors=True)
    with _lock:
        con = _cache()
        con.execute("INSERT OR REPLACE INTO r VALUES (?, ?)", (k, json.dumps(info)))
        con.commit()
        con.close()
    return info


def reward_from(info: Dict[str, Any], rec: Dict[str, Any], speed_weight: float = 0.25) -> float:
    if info.get("stage") in ("static", "contract"):
        return 0.05
    if info.get("status") == "error":
        return 0.0
    if not info.get("compiled"):
        return 0.10
    if info.get("level") == "compile":
        return 0.30 if info.get("status") == "pass" else 0.10
    if info.get("status") != "pass" or not info.get("success_marker"):
        if info.get("heldout") is False:          # visible input correct, a held-out input wrong
            return 0.60
        return 0.30
    cyc = info.get("cycles")
    if rec.get("base_cycles") and cyc:
        return 1.0 + max(-1.0, min(1.0, math.log2(float(rec["base_cycles"]) / float(cyc))))
    if rec.get("ref_cycles") and cyc:
        return 1.0 + speed_weight * max(-1.0, min(1.0, math.log2(float(rec["ref_cycles"]) / float(cyc))))
    return 1.0


def score(completion: Any, rec: Dict[str, Any], level: str = "run", heldout: bool = True) -> Tuple[float, Dict]:
    code = C.first_csl(_completion_text(completion))
    if not code:
        return 0.0, {"stage": "extract", "status": "fail", "reason": "no csl block"}
    info = evaluate(code, rec, level=level, heldout=heldout)
    return reward_from(info, rec), info


# ---------------------------------------------------------------------------------------------------
# Framework adapters
# ---------------------------------------------------------------------------------------------------
_RECORD_KEYS = ("kernel", "reference_dir", "target_relpath", "commands_script", "base_cycles", "base_code", "ref_cycles")


def make_trl_reward(level: str = "run", heldout: bool = True, workers: int = 8):
    """A TRL GRPO reward function: f(prompts, completions, **dataset_columns) -> list[float]."""
    def csl_reward(prompts, completions, **kw) -> List[float]:
        n = len(completions)
        recs = [{k: (kw[k][i] if k in kw and kw[k] is not None else None) for k in _RECORD_KEYS} for i in range(n)]
        with cf.ThreadPoolExecutor(max_workers=workers) as ex:   # each call shells out to the SDK
            futs = [ex.submit(score, completions[i], recs[i], level, heldout) for i in range(n)]
            return [f.result()[0] for f in futs]
    csl_reward.__name__ = f"csl_{level}_reward"
    return csl_reward


def verl_compute_score(data_source, solution_str, ground_truth, extra_info=None, **_):
    """veRL custom reward: the record's fields travel in extra_info (see docs/POSTTRAINING.md)."""
    rec = dict(extra_info or {})
    level = rec.pop("reward_level", "run")
    return float(score(solution_str, rec, level=level, heldout=bool(rec.pop("heldout", True)))[0])


# ---------------------------------------------------------------------------------------------------
def _cli() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--smoke", metavar="KERNEL")
    ap.add_argument("--check", metavar="JSONL", help="re-verify the assistant program of SFT records")
    ap.add_argument("--remeasure-base", metavar="JSONL", help="measure base_cycles of GRPO optimize prompts")
    ap.add_argument("--level", default="run", choices=("compile", "run"))
    ap.add_argument("--no-heldout", action="store_true")
    ap.add_argument("--limit", type=int, default=0)
    ap.add_argument("--workers", type=int, default=4)
    ap.add_argument("--out")
    a = ap.parse_args()
    heldout = not a.no_heldout
    if a.smoke:
        reg = C.registry()[a.smoke]
        ref = C.REPO / "kernels" / reg["dir"] / "CSL"
        rec = {"kernel": a.smoke, "reference_dir": str(ref), "target_relpath": reg["target"]}
        r, info = score(C.csl_block((ref / reg["target"]).read_text()), rec, level=a.level, heldout=heldout)
        print(json.dumps({"reward": r, **info}, indent=2))
        return 0 if r >= 1.0 else 1
    path = Path(a.check or a.remeasure_base or "")
    if not path.is_file():
        ap.error("give --smoke, --check or --remeasure-base")
    rows = [json.loads(l) for l in open(path)]
    if a.limit:
        rows = rows[: a.limit]

    def job(row):
        if a.check:
            reg = C.registry().get(row["meta"]["kernel"]) or {}
            rec = {"kernel": row["meta"]["kernel"], "reference_dir": f"kernels/{reg.get('dir')}/CSL",
                   "target_relpath": row["meta"].get("target_relpath") or reg.get("target")}
            r, info = score(row["messages"][-1]["content"], rec, level=a.level, heldout=heldout)
            row["meta"]["verified_reward"] = r; row["meta"]["verified_info"] = info
            row["meta"]["verified_sdk_root"] = SDK_ROOT
        else:
            r, info = score(C.csl_block(row["base_code"]), {k: row.get(k) for k in _RECORD_KEYS if k != "base_cycles"},
                            level="run", heldout=False)
            if info.get("status") == "pass" and info.get("cycles"):
                row["base_cycles"] = int(info["cycles"]); row["base_cycles_sdk"] = SDK_ROOT
            row.setdefault("meta", {})["base_check"] = info
        return row
    with cf.ThreadPoolExecutor(max_workers=a.workers) as ex:
        rows = list(ex.map(job, rows))
    out = Path(a.out) if a.out else path.with_suffix(".verified.jsonl" if a.check else ".remeasured.jsonl")
    C.write_jsonl(out, rows)
    ok = sum(1 for r in rows if (r["meta"].get("verified_reward", 0) >= 1.0 if a.check else r["meta"]["base_check"].get("status") == "pass"))
    print(f"wrote {out}: {ok}/{len(rows)} pass")
    return 0


if __name__ == "__main__":
    sys.exit(_cli())
