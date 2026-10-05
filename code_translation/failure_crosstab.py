#!/usr/bin/env python3
"""Do LLMs understand CSL? -- corpus mining over the preserved translation attempts.

Joins docs/data/cost_report.csv (one row per run: model, sweep, kernel, run_dir) with a
per-attempt classification of every run's final_result.json (error_family.classify_run)
and writes, under docs/data/:

  failure_by_model.csv          model x family attempt counts and shares (effective denominator)
  failure_by_model_concept.csv  model x concept group (syntax, types, comptime, resource ids, DSD,
                                fabric protocol, numerics, harness) -- the "language vs protocol" view
  attempts_to_first_compile.csv per run: compile@1, first attempt that compiled, first pass, never-compiled
  first_vs_last_family.csv      attempt-1 family -> final family transition counts, per model

Denominators: `compile_only_check` (dry-check bookkeeping) and `sdk_env_blocked` (infrastructure)
are excluded from the EFFECTIVE attempt count; both are still reported. Models with fewer than
MIN_ATTEMPTS effective attempts are pooled as `other_open_weight` (all of them are open-weight).
The corpus confounds model with sweep configuration and date, so the tables are written twice:
over the whole corpus and restricted to the matched 28-kernel cross-model sweeps (`_matched`).
"""
from __future__ import annotations

import argparse
import csv
import json
import sys
from collections import Counter, defaultdict
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO / "code_translation"))
import error_family as ef  # noqa: E402

RESULTS = REPO / "code_translation" / "results"
DATA = REPO / "docs" / "data"
MIN_ATTEMPTS = 100
NON_EFFECTIVE = {"compile_only_check", "sdk_env_blocked"}
COMPILE_FAMILIES = {name for name, _ in ef.COMPILE_TABLE} | {"no_csl_block", "llm_error", "compile_only_check", "sdk_env_blocked"}

CONCEPTS = {
    "syntax_lexical": ["syntax_error", "no_csl_block", "unknown_builtin", "call_arity"],
    "types_declarations": ["type_mismatch", "uninitialized_param", "undeclared_identifier", "shadow_or_decl", "export_mutability"],
    "comptime_model": ["comptime_misuse", "layout_error"],
    "resource_ids_interface": ["queue_or_ut_id", "task_binding", "dsr_arity_mismatch", "contract_entrypoint", "missing_export_symbol", "bad_import"],
    "dsd_semantics": ["dsd_construction"],
    "fabric_protocol_runtime": ["runtime_stall", "runtime_fatal_ut", "runtime_fatal_hcf", "runtime_timeout", "runtime_crash"],
    "numerics_verification": ["verify_mismatch", "heldout_mismatch", "implausible_cycles", "missing_success_marker"],
    "pass": ["pass"],
}
LANGUAGE_GROUPS = ("syntax_lexical", "types_declarations", "comptime_model", "dsd_semantics")
PROTOCOL_GROUPS = ("resource_ids_interface", "fabric_protocol_runtime")
MATCHED_SWEEPS = ("alcf_oss_sweep_20260629_020833", "alcf_oss_full_20260629_202711", "alcf_oss_extra_20260629_033812",
                  "alcf_extra_models_20260701_210129", "opus48_sweep_20260627_032158", "opus48_sweep_20260629_182742",
                  "opus48_sweep_20260629_182744")


def concept_of(family: str) -> str:
    for g, fams in CONCEPTS.items():
        if family in fams:
            return g
    return "harness_environment"


def load_runs(cost_csv: Path):
    with open(cost_csv, newline="") as fh:
        for row in csv.DictReader(fh):
            rd = (row.get("run_dir") or "").strip()
            if rd:
                yield row, RESULTS / rd


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--cost-report", default=str(DATA / "cost_report.csv"))
    ap.add_argument("--out", default=str(DATA))
    ap.add_argument("--limit", type=int, default=0, help="debug: stop after N runs")
    a = ap.parse_args()
    out = Path(a.out); out.mkdir(parents=True, exist_ok=True)

    per_run = []                       # (model, sweep, kernel, run_dir, [families...])
    missing = 0
    for i, (row, run_dir) in enumerate(load_runs(Path(a.cost_report))):
        if a.limit and i >= a.limit:
            break
        if not (run_dir / "final_result.json").is_file():
            missing += 1; continue
        cr = ef.classify_run(run_dir)
        fams = [p["family"] for p in cr["attempts"]]
        per_run.append((row.get("model") or "unknown", row.get("sweep") or "", row.get("kernel") or "", str(run_dir), fams))
    print(f"runs joined: {len(per_run)}   without final_result.json: {missing}")

    def write_tables(rows, suffix=""):
        eff_by_model = Counter()
        for model, _, _, _, fams in rows:
            eff_by_model[model] += sum(1 for f in fams if f not in NON_EFFECTIVE)
        def col(model):
            return model if eff_by_model[model] >= MIN_ATTEMPTS else "other_open_weight"
        fam_tab, con_tab, tot_all, tot_eff = defaultdict(Counter), defaultdict(Counter), Counter(), Counter()
        trans = defaultdict(Counter)
        atfc = []
        for model, sweep, kernel, run_dir, fams in rows:
            m = col(model)
            for f in fams:
                fam_tab[m][f] += 1; tot_all[m] += 1
                if f not in NON_EFFECTIVE:
                    con_tab[m][concept_of(f)] += 1; tot_eff[m] += 1
            eff = [f for f in fams if f not in NON_EFFECTIVE]
            if eff:
                trans[m][(eff[0], eff[-1])] += 1
                compiled_idx = next((i + 1 for i, f in enumerate(eff) if f not in COMPILE_FAMILIES), None)
                pass_idx = next((i + 1 for i, f in enumerate(eff) if f == "pass"), None)
                atfc.append({"model": model, "sweep": sweep, "kernel": kernel, "run_dir": Path(run_dir).relative_to(RESULTS),
                             "n_attempts_effective": len(eff), "compile_at_1": int(eff[0] not in COMPILE_FAMILIES),
                             "first_compiled_attempt": compiled_idx or "", "first_pass_attempt": pass_idx or "",
                             "never_compiled": int(compiled_idx is None), "final_family": eff[-1],
                             "first_family": eff[0], "first_concept": concept_of(eff[0]), "final_concept": concept_of(eff[-1])})
        models = sorted(fam_tab, key=lambda k: -tot_eff[k])
        families = sorted({f for c in fam_tab.values() for f in c}, key=lambda f: -sum(c[f] for c in fam_tab.values()))
        with open(out / f"failure_by_model{suffix}.csv", "w", newline="") as fh:
            w = csv.writer(fh); w.writerow(["family", "concept"] + [f"{m}_n" for m in models] + [f"{m}_share_eff" for m in models])
            for f in families:
                w.writerow([f, concept_of(f)] + [fam_tab[m][f] for m in models]
                           + [round(fam_tab[m][f] / tot_eff[m], 4) if (tot_eff[m] and f not in NON_EFFECTIVE) else "" for m in models])
            w.writerow(["ALL_attempts", ""] + [tot_all[m] for m in models] + ["" for _ in models])
            w.writerow(["EFFECTIVE_attempts", ""] + [tot_eff[m] for m in models] + ["" for _ in models])
        with open(out / f"failure_by_model_concept{suffix}.csv", "w", newline="") as fh:
            w = csv.writer(fh); groups = list(CONCEPTS) + ["harness_environment"]
            w.writerow(["concept"] + [f"{m}_n" for m in models] + [f"{m}_share_eff" for m in models])
            for g in groups:
                w.writerow([g] + [con_tab[m][g] for m in models] + [round(con_tab[m][g] / tot_eff[m], 4) if tot_eff[m] else "" for m in models])
            lang = {m: sum(con_tab[m][g] for g in LANGUAGE_GROUPS) for m in models}
            prot = {m: sum(con_tab[m][g] for g in PROTOCOL_GROUPS) for m in models}
            w.writerow(["LANGUAGE_total"] + [lang[m] for m in models] + [round(lang[m] / tot_eff[m], 4) if tot_eff[m] else "" for m in models])
            w.writerow(["PROTOCOL_total"] + [prot[m] for m in models] + [round(prot[m] / tot_eff[m], 4) if tot_eff[m] else "" for m in models])
            w.writerow(["EFFECTIVE_attempts"] + [tot_eff[m] for m in models] + ["" for _ in models])
        with open(out / f"attempts_to_first_compile{suffix}.csv", "w", newline="") as fh:
            w = csv.DictWriter(fh, fieldnames=list(atfc[0].keys()) if atfc else ["model"]); w.writeheader()
            for r in atfc:
                w.writerow(r)
        with open(out / f"first_vs_last_family{suffix}.csv", "w", newline="") as fh:
            w = csv.writer(fh); w.writerow(["model", "first_family", "final_family", "runs"])
            for m in models:
                for (f0, f1), n in sorted(trans[m].items(), key=lambda kv: -kv[1]):
                    w.writerow([m, f0, f1, n])
        print(f"{suffix or 'whole corpus'}: runs {len(rows)}; models {models}; effective attempts {dict(tot_eff)}")
        for m in models:
            if tot_eff[m]:
                print(f"  {m:24s} language {lang[m] / tot_eff[m]:.1%}  protocol {prot[m] / tot_eff[m]:.1%}  pass {con_tab[m]['pass'] / tot_eff[m]:.1%}")

    write_tables(per_run)
    matched = [r for r in per_run if r[1] in MATCHED_SWEEPS]
    if matched:
        write_tables(matched, "_matched")
    return 0


if __name__ == "__main__":
    sys.exit(main())
