#!/usr/bin/env python3
"""Build SFT, DPO and GRPO datasets for CSL code generation from the recorded agent runs.

    python -m posttrain.build_datasets --out results/posttrain_<date> [--target-sdk 2.10.0]
        [--exclude-models claude,gpt-5] [--max-prompts-per-kernel 8]

Sources (all under code_translation/results/):
  * translation runs: translation_log.json (the conversation), final_result.json (per-attempt status
    and compiler transcript), benchmark.json (the final program's verdict), bundle_metadata.json;
  * optimizer runs: candidates/*/{pe.csl, meta.json} (every benchmarked candidate with its cycles);
  * first-correct programs: first_correct/<tag>/<kernel>/ (the optimizer's common start programs).

Outputs (one JSONL record per line, every record carries `meta` with kernel, split, source model,
SDK of the run, sweep and a content hash):
  sft/translate.jsonl        [system, user = code request, assistant = the final passing program]
  sft/translate_compact.jsonl  the same with the retrieved documentation and model-written sections removed
  sft/repair.jsonl           [system, user = failing program + compiler/run error, assistant = the next
                              attempt, which compiled (compile repairs) or passed (run repairs)]
  sft/optimize.jsonl         [system, user = program + cycles + strategy, assistant = accepted candidate]
  sft/trajectories.jsonl     full multi-turn conversations of passing runs; `train_turns` marks the
                              assistant turns to put loss on (the passing one by default)
  dpo/translate_pairs.jsonl  prompt / chosen (passing program) / rejected (a failing attempt)
  dpo/optimize_pairs.jsonl   prompt / chosen (accepted, faster) / rejected (failed or slower), same base
  grpo/translate_prompts.jsonl  prompts + what the reward needs (reference bundle, target file, script)
  grpo/translate_compact_prompts.jsonl  the same prompts without the retrieved documentation (~1/3 length)
  grpo/optimize_prompts.jsonl   start programs + their cycles
  splits.json, manifest.json

Splits are by kernel (posttrain/common.py): the IPDPS sparse benchmark and a fixed general set are
evaluation-only; a leak guard drops training records that contain reference lines unique to an
evaluation kernel. GRPO prompts have the analyst model's 'CUDA analysis' removed, so they contain no
model output. See docs/POSTTRAINING.md.
"""
from __future__ import annotations

import argparse
import collections
import csv
import json
import re
import sys
import time
from pathlib import Path
from typing import Dict, List, Optional, Tuple

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from posttrain import common as C  # noqa: E402

RESULTS = C.CT / "results"
SYSTEM_REPAIR = ("You are an expert in Cerebras CSL for the WSE-3. You fix CSL compute files so that they "
                 "compile with cslc and pass their numerical check, changing only what the error requires.")
SYSTEM_OPT = None   # filled from prompt_cuda2csl at run time (the harness's optimizer system prompt)


# ---------------------------------------------------------------------------------------------------
def load_model_map() -> Dict[str, str]:
    """run_dir (relative to results/) -> model, from docs/data/cost_report.csv."""
    p = C.REPO / "docs" / "data" / "cost_report.csv"
    out: Dict[str, str] = {}
    if p.exists():
        for r in csv.DictReader(open(p)):
            if r.get("run_dir") and r.get("model"):
                out[r["run_dir"].strip("/")] = r["model"]
    return out


def run_model(run_dir: Path, mm: Dict[str, str]) -> str:
    u = run_dir / "usage_log.json"
    if u.exists():
        try:
            ms = json.load(open(u)).get("totals", {}).get("models") or []
            if ms:
                return ",".join(sorted(set(ms)))
        except Exception:
            pass
    rel = str(run_dir.relative_to(RESULTS))
    if rel in mm:
        return mm[rel]
    for k, v in mm.items():
        if rel.endswith(k) or k.endswith(rel):
            return v
    return "unknown"


def jload(p: Path):
    try:
        return json.load(open(p))
    except Exception:
        return None


def compile_error(att: dict) -> Optional[str]:
    for t in att.get("transcript") or []:
        if t.get("step") == "compile" and (t.get("returncode") or 0) != 0:
            return (t.get("stderr") or "") + "\n" + (t.get("stdout") or "")
    return None


def run_error(att: dict) -> Optional[str]:
    if att.get("status") == "pass":
        return None
    out = []
    for t in att.get("transcript") or []:
        if t.get("step") != "compile":
            out.append((t.get("stdout") or "")[-1500:] + "\n" + (t.get("stderr") or "")[-800:])
    reason = att.get("failure_reason") or ""
    return (f"Failure: {reason}\n" + "\n".join(out)).strip()


def trim_error(text: str, n: int = 2500) -> str:
    text = C.redact(text)
    lines = [ln for ln in text.splitlines() if ln.strip() and "[INFO]" not in ln and "Bind path" not in ln
             and "CSL_IMPORT_PATH" not in ln and "Using SIF" not in ln]
    text = "\n".join(lines)
    return text[-n:] if len(text) > n else text


# ---------------------------------------------------------------------------------------------------
class Builder:
    def __init__(self, args):
        self.a = args
        self.mm = load_model_map()
        self.guard = C.eval_only_lines()
        self.excl = [m.strip().lower() for m in (args.exclude_models or "").split(",") if m.strip()]
        # --sdk-ok: kernels whose own reference passes on the target SDK (posttrain.reference_check)
        self.sdk_ok = None
        if args.sdk_ok:
            chk = json.load(open(args.sdk_ok))
            self.sdk_ok = {k for k, v in chk.items() if (v.get("reward") or 0) >= 1.0}
        self.out: Dict[str, List[dict]] = collections.defaultdict(list)
        self.stats = collections.Counter()
        self.seen: Dict[str, set] = collections.defaultdict(set)
        global SYSTEM_OPT
        try:
            from prompt_cuda2csl import Instruction_system_csl_optimization
            SYSTEM_OPT = Instruction_system_csl_optimization
        except Exception:
            SYSTEM_OPT = "You optimize Cerebras CSL compute files for the WSE-3 to reduce their cycle count."

    # -- helpers --------------------------------------------------------------------------------------
    def _excluded_model(self, model: str) -> bool:
        return any(e in model.lower() for e in self.excl)

    def _port(self, code: str, sdk: str) -> Tuple[str, int]:
        if not self.a.target_sdk or sdk.startswith(self.a.target_sdk.split(".")[0] + "."):
            return code, 0
        return C.port_to_sdk(code, self.a.target_sdk)

    def _port_text(self, text: str, sdk: str) -> Tuple[str, int]:
        if not self.a.target_sdk or sdk.startswith(self.a.target_sdk.split(".")[0] + "."):
            return text, 0
        return C.port_fenced(text, self.a.target_sdk)

    def _kernel_ok(self, kernel: str) -> bool:
        return self.sdk_ok is None or kernel in self.sdk_ok

    def _emit(self, name: str, rec: dict, texts: List[str]):
        if not self._kernel_ok(rec["meta"]["kernel"]):
            self.stats[f"{name}:dropped_reference_fails_on_target_sdk"] += 1
            return
        joined = "\n".join(texts)
        if C.looks_secret(joined):
            self.stats[f"{name}:dropped_secret"] += 1
            return
        if rec["meta"]["split"] == "train" and C.leaks(joined, self.guard) >= 3:
            self.stats[f"{name}:dropped_leak"] += 1
            return
        h = C.sha(joined)
        if h in self.seen[name]:
            self.stats[f"{name}:dup"] += 1
            return
        self.seen[name].add(h)
        rec["meta"]["hash"] = h
        self.out[name].append(rec)
        self.stats[f"{name}:{rec['meta']['split']}"] += 1

    # -- translation runs -----------------------------------------------------------------------------
    def translation_runs(self):
        for tl in sorted(RESULTS.rglob("translation_log.json")):
            if "candidates" in tl.parts or "posttrain" in str(tl):
                continue
            d = tl.parent
            self.stats["runs_seen"] += 1
            try:
                self._one_translation(d)
            except Exception as exc:     # a malformed run never stops the build
                self.stats["runs_error"] += 1
                if self.a.verbose:
                    print("error", d, exc, file=sys.stderr)

    def _one_translation(self, d: Path):
        log = jload(d / "translation_log.json") or {}
        msgs = [m for m in (log.get("messages") or []) if isinstance(m.get("content"), str)]
        if not msgs:
            return
        bm = jload(d / "bundle_metadata.json") or {}
        kernel = C.canonical_kernel(bm.get("kernel") or d.name)
        split = C.split_of(kernel)
        sdk = str(bm.get("target_sdk") or "1.4.0")
        target = bm.get("target_relpath") or "pe.csl"
        model = run_model(d, self.mm)
        if self._excluded_model(model):
            self.stats["runs_excluded_model"] += 1
            return
        sweep = d.relative_to(RESULTS).parts[0]
        meta0 = {"kernel": kernel, "split": split, "source_model": model, "run_sdk": sdk, "sweep": sweep,
                 "target_relpath": target}
        system = msgs[0]["content"] if msgs[0].get("role") == "system" else None
        # code replies and the user message that requested the first one
        code_idx = [i for i, m in enumerate(msgs) if m.get("role") == "assistant" and "```csl" in m["content"]]
        if not code_idx:
            return
        req_i = max(i for i in range(code_idx[0]) if msgs[i].get("role") == "user")
        request = msgs[req_i]["content"]
        fr = jload(d / "final_result.json") or {}
        atts = fr.get("attempts") or []
        codes = [C.first_csl(msgs[i]["content"]) for i in code_idx]
        # map code replies to attempts: next unused attempt with the same line count, in order
        mapping: Dict[int, int] = {}
        j = 0
        for k, code in enumerate(codes):
            if not code:
                continue
            n = len(code.splitlines())
            for jj in range(j, len(atts)):
                if atts[jj].get("code_lines") == n:
                    mapping[k] = jj; j = jj + 1; break
        bj = jload(d / "benchmark.json") or {}
        final_ok = bj.get("status") == "pass" and bj.get("success_marker") and (d / target).is_file()
        sys_msgs = [{"role": "system", "content": C.redact(system)}] if system else []
        req_ported, n_req = self._port_text(C.redact(request), sdk)

        if final_ok:
            final_code = (d / target).read_text(errors="replace")
            final_ported, n_fin = self._port(final_code, sdk)
            meta = dict(meta0, kind="translate", cycles=bj.get("cycles_send"), sdk_port_edits=n_req + n_fin,
                        verified_sdk=sdk)
            self._emit("sft/translate", {"messages": sys_msgs + [{"role": "user", "content": req_ported},
                                                                  {"role": "assistant", "content": C.csl_block(final_ported)}],
                                         "meta": meta}, [request, final_code])
            cp = C.compact_prompt(req_ported)
            self._emit("sft/translate_compact", {"messages": sys_msgs + [{"role": "user", "content": cp},
                                                                          {"role": "assistant", "content": C.csl_block(final_ported)}],
                                                 "meta": dict(meta, kind="translate_compact")}, [cp, final_code])
            # trajectory up to the last code reply that passed (loss on that turn)
            last_pass = max([k for k, jj in mapping.items() if atts[jj].get("status") == "pass"], default=None)
            if last_pass is not None:
                end = code_idx[last_pass]
                conv = []
                for m in msgs[: end + 1]:
                    t, _ = self._port_text(C.redact(m["content"]), sdk)
                    conv.append({"role": m["role"], "content": t})
                self._emit("sft/trajectories", {"messages": conv, "train_turns": [len(conv) - 1],
                                                "meta": dict(meta, kind="trajectory", n_turns=len(conv))},
                           [m["content"] for m in msgs[: end + 1]])
            # DPO: the passing program against the first failing attempt of the same run
            fails = [k for k, jj in mapping.items() if atts[jj].get("status") != "pass"]
            if fails:
                rej, _ = self._port(codes[fails[0]], sdk)
                if C.sha(rej) != C.sha(final_ported):
                    self._emit("dpo/translate_pairs", {
                        "prompt": sys_msgs + [{"role": "user", "content": req_ported}],
                        "chosen": [{"role": "assistant", "content": C.csl_block(final_ported)}],
                        "rejected": [{"role": "assistant", "content": C.csl_block(rej)}],
                        "meta": dict(meta, kind="translate_pair",
                                     rejected_failure=str(atts[mapping[fails[0]]].get("failure_reason"))[:200])},
                        [request, final_code, codes[fails[0]]])
        # repair pairs: attempt k failed, attempt k+1 got further
        for k in sorted(mapping):
            if k + 1 not in mapping:
                continue
            a0, a1 = atts[mapping[k]], atts[mapping[k + 1]]
            if a0.get("status") == "pass":
                continue
            cerr = compile_error(a0)
            if cerr is not None:
                if compile_error(a1) is not None:
                    continue        # still does not compile: not a repair
                kind, err = "compile_repair", trim_error(cerr)
            else:
                if a1.get("status") != "pass":
                    continue
                kind, err = "run_repair", trim_error(run_error(a0) or "")
            if not err.strip():
                continue
            c0, n0 = self._port(codes[k], sdk)
            c1, n1 = self._port(codes[k + 1], sdk)
            what = "fails to compile" if kind == "compile_repair" else "compiles but fails when run on the simulator"
            user = (f"The following CSL compute file (`{target}`) for the kernel '{kernel}' {what}.\n\n"
                    f"{C.csl_block(c0)}\n\n{'Compiler' if kind == 'compile_repair' else 'Run'} output:\n```\n{err}\n```\n\n"
                    "Return the corrected complete file in one ```csl block.")
            self._emit("sft/repair", {"messages": [{"role": "system", "content": SYSTEM_REPAIR},
                                                   {"role": "user", "content": user},
                                                   {"role": "assistant", "content": C.csl_block(c1)}],
                                      "meta": dict(meta0, kind=kind, sdk_port_edits=n0 + n1,
                                                   next_status=a1.get("status"),
                                                   failure=str(a0.get("failure_reason"))[:200])},
                       [codes[k], codes[k + 1], err])
        # GRPO prompt (one per distinct request; the analyst's model output is removed)
        bundle = bm.get("reference_dir")
        if bundle:
            rel = C.redact(str(bundle)).replace("<repo>/", "")
            gp = C.strip_model_outputs(req_ported) if self.a.strip_analysis else req_ported
            key = f"{kernel}:{C.sha(gp)}"
            self.stats["grpo_seen"] += 1
            if key not in self.seen["_grpo_keys"]:
                self.seen["_grpo_keys"].add(key)
                base_rec = {"kernel": kernel, "reference_dir": rel, "target_relpath": target,
                            "commands_script": bm.get("commands_script") or "commands_wse3.sh", "split": split}
                self.out["_grpo_candidates"].append(dict(base_rec, prompt=sys_msgs + [{"role": "user", "content": gp}],
                    meta=dict(meta0, kind="grpo_translate", prompt_hash=C.sha(gp),
                              model_outputs_stripped=bool(self.a.strip_analysis))))
                cp = C.compact_prompt(gp)
                self.out["_grpo_compact"].append(dict(base_rec, prompt=sys_msgs + [{"role": "user", "content": cp}],
                    meta=dict(meta0, kind="grpo_translate_compact", prompt_hash=C.sha(cp),
                              model_outputs_stripped=True)))

    # -- optimizer candidates -------------------------------------------------------------------------
    def optimizer_runs(self):
        from prompt_cuda2csl import angle_metadata
        for kdir in sorted({p.parent.parent.parent for p in RESULTS.rglob("candidates/*/meta.json")}):
            if "posttrain" in str(kdir) or "pseudo" in str(kdir):
                continue
            idx = jload(kdir / "candidates" / "index.json") or {}
            cands = idx.get("candidates") or []
            if not cands:
                continue
            bm = jload(kdir / "bundle_metadata.json") or {}
            kernel = C.canonical_kernel(bm.get("kernel") or kdir.name)
            split = C.split_of(kernel)
            sdk = str(bm.get("target_sdk") or "2.10.0")
            model = run_model(kdir, self.mm)
            if self._excluded_model(model):
                continue
            sweep = kdir.relative_to(RESULTS).parts[0]
            target = bm.get("target_relpath") or "pe.csl"

            def code_of(label: str) -> Optional[str]:
                p = kdir / "candidates" / label / target
                return p.read_text(errors="replace") if p.is_file() else None
            base = next((c for c in cands if c.get("label") == "attempt_00_baseline"), None)
            best = code_of("attempt_00_baseline") if base else None
            best_cyc = (base or {}).get("cycles_send")
            if not best or not best_cyc:
                continue
            groups: Dict[str, List[Tuple[dict, str]]] = collections.defaultdict(list)
            for c in sorted(cands, key=lambda c: (c.get("attempt") or 0, c.get("cand_idx") or 0)):
                if c.get("label") == "attempt_00_baseline":
                    continue
                code = code_of(c["label"])
                if not code:
                    continue
                groups[C.sha(best)].append((c, code))
                base_code, base_cyc = best, best_cyc
                faster = (c.get("status") == "pass" and not c.get("contract_violation")
                          and isinstance(c.get("cycles_send"), int) and c["cycles_send"] < base_cyc)
                angle = c.get("angle") or "generic"
                desc = angle_metadata(angle).get("description", angle)
                user = (f"Optimize the following CSL compute file (`{target}`) of the kernel '{kernel}' to reduce "
                        f"its cycle count on the WSE-3. It currently runs in {base_cyc} cycles.\n\n"
                        f"Strategy: {angle}. {desc}\n\n{C.csl_block(self._port(base_code, sdk)[0])}\n\n"
                        "Keep the exported symbols, the entry points, the timing functions and the numerical "
                        "results unchanged. Return the complete updated file in one ```csl block.")
                c["_user"] = user
                if faster and c.get("accepted") is True:      # accepted = faster AND passed the held-out check
                    self._emit("sft/optimize", {"messages": [{"role": "system", "content": C.redact(SYSTEM_OPT)},
                                                             {"role": "user", "content": user},
                                                             {"role": "assistant", "content": C.csl_block(self._port(code, sdk)[0])}],
                                                "meta": {"kernel": kernel, "split": split, "source_model": model,
                                                         "run_sdk": sdk, "sweep": sweep, "kind": "optimize",
                                                         "angle": angle, "base_cycles": base_cyc,
                                                         "cycles": c["cycles_send"],
                                                         "speedup": round(base_cyc / c["cycles_send"], 4)}},
                               [base_code, code])
                    best, best_cyc = code, c["cycles_send"]
            # DPO pairs within one base program: a faster passing candidate against a failed/slower one
            for bh, items in groups.items():
                good = [(c, code) for c, code in items if c.get("status") == "pass" and isinstance(c.get("cycles_send"), int)]
                bad = [(c, code) for c, code in items if c.get("status") != "pass" or c.get("contract_violation")]
                if not good:
                    continue
                gbest = min(good, key=lambda t: t[0]["cycles_send"])
                slower = [(c, code) for c, code in good if c["cycles_send"] > gbest[0]["cycles_send"] * 1.02]
                for c, code in (bad + slower)[: self.a.max_pairs_per_base]:
                    self._emit("dpo/optimize_pairs", {
                        "prompt": [{"role": "system", "content": C.redact(SYSTEM_OPT)}, {"role": "user", "content": gbest[0]["_user"]}],
                        "chosen": [{"role": "assistant", "content": C.csl_block(self._port(gbest[1], sdk)[0])}],
                        "rejected": [{"role": "assistant", "content": C.csl_block(self._port(code, sdk)[0])}],
                        "meta": {"kernel": kernel, "split": split, "source_model": model, "run_sdk": sdk,
                                 "sweep": sweep, "kind": "optimize_pair", "chosen_cycles": gbest[0]["cycles_send"],
                                 "rejected_status": c.get("status"), "rejected_cycles": c.get("cycles_send"),
                                 "rejected_angle": c.get("angle")}},
                        [gbest[0]["_user"], gbest[1], code])

    # -- GRPO optimize prompts from the frozen first-correct programs ---------------------------------
    def first_correct(self):
        seen = set()
        for meta_p in sorted((RESULTS / "first_correct").glob("*/*/meta.json")):
            kdir = meta_p.parent
            m = jload(meta_p) or {}
            kernel = C.canonical_kernel(m.get("kernel") or kdir.name)
            reg = C.registry().get(kernel)
            if not reg:
                continue
            target = m.get("target_relpath") or reg["target"]
            code_p = kdir / target
            if not code_p.is_file():
                continue
            cyc = m.get("fc_cycles_send") or m.get("cycles_send")
            code = code_p.read_text(errors="replace")
            key = (kernel, C.sha(code))
            if key in seen or not cyc or not self._kernel_ok(kernel):
                continue
            seen.add(key)
            tag = kdir.parent.name
            sdk = "2.10.0" if tag.startswith(("sparse", "iter", "o1_retained")) else "1.4.0"
            ported, n = self._port(code, sdk)
            user = (f"Optimize the following CSL compute file (`{target}`) of the kernel '{kernel}' to reduce its "
                    f"cycle count on the WSE-3. It currently runs in {cyc} cycles.\n\n{C.csl_block(ported)}\n\n"
                    "Keep the exported symbols, the entry points, the timing functions and the numerical results "
                    "unchanged. Return the complete updated file in one ```csl block.")
            self.out["grpo/optimize_prompts"].append({
                "prompt": [{"role": "system", "content": C.redact(SYSTEM_OPT)}, {"role": "user", "content": user}],
                "kernel": kernel, "reference_dir": f"kernels/{reg['dir']}/CSL", "target_relpath": target,
                "commands_script": m.get("commands_script") or "commands_wse3.sh", "split": C.split_of(kernel),
                "base_cycles": int(cyc), "base_code": ported, "base_cycles_sdk": sdk,
                "meta": {"kernel": kernel, "split": C.split_of(kernel), "kind": "grpo_optimize", "fc_tag": tag,
                         "run_sdk": sdk, "sdk_port_edits": n, "source_model": m.get("model") or "first-correct program"}})
            self.stats[f"grpo/optimize_prompts:{C.split_of(kernel)}"] += 1

    def finalize_grpo(self):
        for src, dst in (("_grpo_candidates", "grpo/translate_prompts"), ("_grpo_compact", "grpo/translate_compact_prompts")):
            per_kernel = collections.Counter()
            for r in self.out.pop(src, []):
                if per_kernel[r["kernel"]] >= self.a.max_prompts_per_kernel or not self._kernel_ok(r["kernel"]):
                    continue
                per_kernel[r["kernel"]] += 1
                self.out[dst].append(r)
                self.stats[f"{dst}:{r['split']}"] += 1


# ---------------------------------------------------------------------------------------------------
def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--out", required=True)
    ap.add_argument("--target-sdk", default="2.10.0", help="port SDK 1.x code to this SDK ('' keeps it as run)")
    ap.add_argument("--exclude-models", default="", help="comma list of substrings; runs by these models are skipped")
    ap.add_argument("--max-prompts-per-kernel", type=int, default=8)
    ap.add_argument("--max-pairs-per-base", type=int, default=4)
    ap.add_argument("--no-strip-analysis", dest="strip_analysis", action="store_false")
    ap.add_argument("--sdk-ok", help="JSON from posttrain.reference_check: keep only kernels whose reference passes")
    ap.add_argument("--verbose", action="store_true")
    args = ap.parse_args()
    out = Path(args.out)
    if not out.is_absolute():
        out = C.CT / out
    t0 = time.time()
    b = Builder(args)
    b.translation_runs()
    b.optimizer_runs()
    b.first_correct()
    b.finalize_grpo()
    counts = {}
    for name, rows in sorted(b.out.items()):
        if name.startswith("_"):
            continue
        for split in ("train", "eval_sparse", "eval_general"):
            sub = [r for r in rows if (r.get("meta") or {}).get("split", r.get("split")) == split]
            if sub:
                counts[f"{name}.{split}"] = C.write_jsonl(out / f"{name}.{split}.jsonl", sub)
    splits = {"rule": "by kernel; see code_translation/posttrain/common.py",
              "eval_sparse": C.EVAL_SPARSE, "eval_general": C.EVAL_GENERAL,
              "train": sorted(k for k in C.registry() if C.split_of(k) == "train")}
    (out / "splits.json").write_text(json.dumps(splits, indent=2))
    models = collections.Counter()
    for name, rows in b.out.items():
        if not name.startswith("_"):
            for r in rows:
                models[(r.get("meta") or {}).get("source_model", "?")] += 1
    manifest = {"built": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()), "target_sdk": args.target_sdk,
                "exclude_models": args.exclude_models, "strip_analysis": args.strip_analysis,
                "files": counts, "stats": dict(sorted(b.stats.items())), "records_by_source_model": dict(models),
                "sha256": {f.name: C.sha(f.read_text()) for f in sorted(out.rglob("*.jsonl"))},
                "elapsed_s": round(time.time() - t0, 1)}
    (out / "manifest.json").write_text(json.dumps(manifest, indent=2))
    print(json.dumps({"files": counts, "records_by_source_model": dict(models)}, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
