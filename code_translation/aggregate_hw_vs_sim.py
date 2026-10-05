#!/usr/bin/env python3
"""Turn hw_replay.py output into the finished hardware-vs-simulator report.

Reads one or both result files -- the agent-artifact pass and (if present) the
reference pass -- and emits a Markdown document with the comparison tables.

Deliberately standalone and dependency-free: run it whenever the cluster runs
finish, in any session.

    python3 aggregate_hw_vs_sim.py \\
        --agent results/hw_replay_agent_artifacts.json \\
        --reference results/hw_replay_reference.json \\
        --out ../docs/HW_VS_SIM_20260806.md

WHAT THE THREE NUMBERS MEAN
    sweep_sim   SDK 1.4.0 local simulator -- the number every sweep and the
                paper currently report.
    sim_2.10    SDK 2.10 appliance simulator, SAME bundle. Differs from
                sweep_sim only via the SDK version + the mechanical port.
    hw          Real WSE-3 silicon, SAME bundle, SAME host run.py.

sim_2.10 vs hw isolates the target; sweep_sim vs sim_2.10 isolates the port.
Quoting hw against sweep_sim -- as results/hardware_validation/*.json does --
conflates the two.
"""

from __future__ import annotations

import argparse
import json
import statistics
from pathlib import Path
from typing import Dict, List, Optional

MIN_PLAUSIBLE_CYCLES = 100


def load(path: Optional[str]) -> List[Dict]:
    if not path:
        return []
    p = Path(path)
    return json.loads(p.read_text(encoding="utf-8")) if p.is_file() else []


def arm(row: Dict, which: str) -> Dict:
    return (row.get("arms") or {}).get(which) or {}


def fmt(v, spec: str = "") -> str:
    if v is None:
        return "-"
    return format(v, spec) if spec else str(v)


def geomean(xs: List[float]) -> Optional[float]:
    xs = [x for x in xs if x and x > 0]
    return statistics.geometric_mean(xs) if xs else None


def kernel_rows(rows: List[Dict]) -> List[Dict]:
    """Flatten one pass into per-kernel records."""
    out = []
    for r in sorted(rows, key=lambda x: str(x.get("kernel"))):
        s, h = arm(r, "sim"), arm(r, "hw")
        cmp_ = r.get("hw_vs_sim") or {}
        port = r.get("sdk210_vs_sdk140") or {}
        bad = [f"{n}:{a.get('status')}" for n, a in (("sim", s), ("hw", h))
               if a.get("status") not in (None, "pass")]
        # Older result files predate the flag; fall back to the ratio itself.
        # Nothing cleanly timed came anywhere near 2x, and every contaminated
        # kernel was >15x, so the gap is unambiguous.
        comparable = r.get("hw_comparable")
        if comparable is None:
            comparable = not (cmp_.get("ratio") and cmp_["ratio"] > 2.0)
        out.append({
            "kernel": r.get("kernel", "?"),
            "sweep_sim": r.get("sweep_sim_cycles"),
            "sim": s.get("cycles_send"),
            "hw": h.get("cycles_send"),
            "ratio": cmp_.get("ratio"),
            "port_ratio": port.get("ratio"),
            "status": ", ".join(bad) or "ok",
            "failed": bool(bad),
            "comparable": bool(comparable),
            "timing": r.get("timing_method",
                            "device_internal" if comparable
                            else "host_launched_tic_toc"),
        })
    return out


def table(recs: List[Dict]) -> List[str]:
    lines = ["| kernel | sweep_sim | sim_2.10 | hw | hw/sim | port | status |",
             "|---|---:|---:|---:|---:|---:|---|"]
    for d in recs:
        lines.append(
            f"| {d['kernel']} | {fmt(d['sweep_sim'])} | {fmt(d['sim'])} | "
            f"{fmt(d['hw'])} | {fmt(d['ratio'], '.3f')} | "
            f"{fmt(d['port_ratio'], '.3f')} | {d['status']} |")
    return lines


def summarize(recs: List[Dict], label: str) -> List[str]:
    paired = [d for d in recs if d["ratio"]]
    valid = [d for d in paired if d["comparable"]]
    contam = [d for d in paired if not d["comparable"]]
    ports = [d["port_ratio"] for d in recs if d["port_ratio"]]

    lines = [f"\n### {label} summary\n"]
    lines.append(f"- kernels attempted: **{len(recs)}**")
    lines.append(f"- paired hw+sim measurements: **{len(paired)}**")
    lines.append(f"- failed on at least one arm: **{sum(1 for d in recs if d['failed'])}**")

    if valid:
        g = geomean([d["ratio"] for d in valid])
        slower = [d for d in valid if d["ratio"] > 1]
        best = min(valid, key=lambda d: d["ratio"])
        worst = max(valid, key=lambda d: d["ratio"])
        lines.append("")
        lines.append(f"**Comparable kernels (timing inside a single device "
                     f"launch), n={len(valid)}:**")
        lines.append("")
        lines.append(f"- geomean hw/sim: **{g:.3f}**")
        lines.append(f"- range: **{best['ratio']:.3f}** ({best['kernel']}) to "
                     f"**{worst['ratio']:.3f}** ({worst['kernel']})")
        lines.append(f"- hardware slower on {len(slower)}/{len(valid)}, "
                     f"faster on {len(valid) - len(slower)}/{len(valid)}")
        if g:
            verdict = ("neither systematically optimistic nor conservative"
                       if 0.95 <= g <= 1.05 else
                       ("optimistic (hardware slower)" if g > 1
                        else "conservative (hardware faster)"))
            lines.append(f"- **the simulator is {verdict}** on this population")

    if contam:
        lines.append("")
        lines.append(f"**Excluded from the aggregate, n={len(contam)}:** these "
                     "bracket the timed region with separate host launches "
                     "(`f_tic`/`f_toc`), so on the appliance the window spans "
                     "~2 host RPCs (~488us each) and measures network latency, "
                     "not device time. Two unrelated kernels here land within "
                     "0.05% of each other (~829,400 cycles), which is the "
                     "overhead, not the kernels.")
        lines.append("")
        lines.append("| kernel | apparent hw/sim | what it actually measures |")
        lines.append("|---|---:|---|")
        for d in sorted(contam, key=lambda x: x["ratio"]):
            lines.append(f"| {d['kernel']} | {d['ratio']:.1f} | host RPC latency |")
        lines.append("")
        lines.append("Their **simulator** numbers are unaffected, so published "
                     "simulator results and speedups stand. They simply cannot "
                     "be quoted for hardware until re-instrumented to time "
                     "inside a single device launch.")

    if ports:
        gp = geomean(ports)
        exact = sum(1 for p in ports if abs(p - 1.0) < 1e-9)
        lines.append("")
        lines.append(f"- SDK 2.10 port delta: geomean **{gp:.4f}**, "
                     f"exactly cycle-neutral on **{exact}/{len(ports)}** kernels")
    return lines


def size_effect(recs: List[Dict]) -> List[str]:
    """Is the hw/sim gap a fixed overhead? Bucket by simulator cycle count."""
    paired = [d for d in recs if d["ratio"] and d["sim"]]
    if len(paired) < 4:
        return []
    buckets = [("< 1k cycles", lambda c: c < 1_000),
               ("1k - 10k", lambda c: 1_000 <= c < 10_000),
               ("10k - 100k", lambda c: 10_000 <= c < 100_000),
               (">= 100k", lambda c: c >= 100_000)]
    lines = ["\n### Does the gap scale with kernel size?\n",
             "If the hardware penalty were a fixed per-launch overhead, the",
             "*relative* gap would shrink as kernels get longer.\n",
             "| simulator cycles | n | geomean hw/sim |", "|---|---:|---:|"]
    for name, pred in buckets:
        sel = [d["ratio"] for d in paired if pred(d["sim"])]
        if sel:
            lines.append(f"| {name} | {len(sel)} | {geomean(sel):.3f} |")
    return lines


def build_report(agent: List[Dict], reference: List[Dict]) -> str:
    out: List[str] = []
    w = out.append

    w("# Hardware vs Simulator: WSE-3 silicon against the SDK simulator\n")
    w("Generated by `code_translation/aggregate_hw_vs_sim.py`.\n")

    w("## Method\n")
    w("Each row is ONE bundle, ported to SDK 2.10 once, then compiled and run")
    w("**both** ways through the same appliance client and driven by the")
    w("kernel's **own `run.py`**. The host sequence is therefore identical on")
    w("both arms and the `f_enable_timer` launch cannot go missing on one side")
    w("-- which is how the July 2026 attempt produced sub-100-cycle readings.")
    w("Both arms are checked for the SUCCESS marker and screened against the")
    w(f"same {MIN_PLAUSIBLE_CYCLES}-cycle dead-timer floor.\n")
    w("| column | meaning |")
    w("|---|---|")
    w("| `sweep_sim` | SDK 1.4.0 local simulator -- what every sweep reports |")
    w("| `sim_2.10` | SDK 2.10 appliance simulator, same bundle |")
    w("| `hw` | real WSE-3 silicon, same bundle |")
    w("| `hw/sim` | hardware cost relative to simulator (>1 = hardware slower) |")
    w("| `port` | `sim_2.10 / sweep_sim`, the SDK-version + port delta |")

    agent_recs = kernel_rows(agent)
    w("\n## Agent-generated kernels\n")
    out.extend(table(agent_recs))
    out.extend(summarize(agent_recs, "Agent kernels"))
    out.extend(size_effect(agent_recs))

    ref_recs = kernel_rows(reference)
    if ref_recs:
        w("\n## Reference (human-written) kernels\n")
        out.extend(table(ref_recs))
        out.extend(summarize(ref_recs, "Reference kernels"))

        # The payoff: a beats-expert ratio with both halves on the same target.
        w("\n## Beats-expert, measured natively on each target\n")
        w("The speedups reported in the sweeps divide agent cycles by a")
        w("*simulator* reference. With both halves measured on the same target,")
        w("the ratio can be stated for silicon directly.\n")
        w("Kernels whose timed window spans host RPCs are excluded: the same")
        w("~829k-cycle overhead lands on BOTH the agent and the reference run,")
        w("which compresses their ratio toward 1.0 and understates the speedup.")
        w("(Laplacian2D-Halo shows 2.58x -> 1.14x for exactly this reason -- an")
        w("artifact of the instrumentation, not a property of the silicon.)\n")
        w("| kernel | speedup on simulator | speedup on hardware | changed by |")
        w("|---|---:|---:|---:|")
        ref_by = {d["kernel"]: d for d in ref_recs}
        sim_sp, hw_sp = [], []
        excluded: List[str] = []
        for a in agent_recs:
            r = ref_by.get(a["kernel"])
            if not r:
                continue
            s_sp = (r["sim"] / a["sim"]) if (r.get("sim") and a.get("sim")) else None
            h_sp = (r["hw"] / a["hw"]) if (r.get("hw") and a.get("hw")) else None
            if s_sp is None and h_sp is None:
                continue
            if not (a["comparable"] and r["comparable"]):
                excluded.append(a["kernel"])
                continue
            if s_sp:
                sim_sp.append(s_sp)
            if h_sp:
                hw_sp.append(h_sp)
            delta = f"{100 * (h_sp / s_sp - 1):+.1f}%" if (s_sp and h_sp) else "-"
            w(f"| {a['kernel']} | {fmt(s_sp, '.2f')}x | {fmt(h_sp, '.2f')}x | {delta} |")
        gs, gh = geomean(sim_sp), geomean(hw_sp)
        if gs and gh:
            w(f"\n- kernels in this comparison: **{len(hw_sp)}**")
            w(f"- geomean speedup on simulator: **{gs:.2f}x**")
            w(f"- geomean speedup on hardware: **{gh:.2f}x**")
            w(f"- the beats-expert claim changes by **{100 * (gh / gs - 1):+.1f}%** "
              "when measured on silicon")
        if excluded:
            w(f"\nExcluded (host-bracketed timing on one or both arms): "
              f"{', '.join(sorted(excluded))}")
    else:
        w("\n## Reference pass: not yet run\n")
        w("Without the human-written bundles measured on the same two targets,")
        w("no beats-expert ratio can be quoted for hardware: the recorded")
        w("speedups divide agent cycles by a SIMULATOR reference, so both")
        w("halves have to sit on the same machine before the ratio means")
        w("anything on silicon. Run:\n")
        w("```")
        w("~/cs_appliance_sdk/bin/python code_translation/hw_replay.py \\")
        w("    --sweep code_translation/results/full_template_sweep_20260722_192305 \\")
        w("    --reference --arms sim,hw \\")
        w("    --out code_translation/results/hw_replay_reference.json")
        w("```")

    failed = [d for d in agent_recs if d["failed"]]
    if failed:
        w("\n## Failures\n")
        w("| kernel | status |")
        w("|---|---|")
        for d in failed:
            w(f"| {d['kernel']} | {d['status']} |")

    return "\n".join(out) + "\n"


def write_fidelity_csv(agent_rows: List[Dict], path: Path) -> int:
    """One row per hardware-measured candidate that also carries the simulator count
    the agent saw (sweep_sim_cycles, SDK 1.4) and the silicon-model prediction made at
    benchmark time (predicted_cycles). hw_cycles is the median of the batched trials;
    hw_max_over_min flags noisy windows (> 1.05 is excluded downstream)."""
    import csv
    n = 0
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["kernel", "candidate", "sim_cycles", "pred_cycles", "hw_cycles", "hw_max_over_min"])
        for r in agent_rows:
            hw = (r.get("arms") or {}).get("hw") or {}
            hw_c = hw.get("cycles_send")
            if hw.get("status") != "pass" or not isinstance(hw_c, int) or hw_c < MIN_PLAUSIBLE_CYCLES:
                continue
            sim_c, pred_c = r.get("sweep_sim_cycles"), r.get("predicted_cycles")
            if not sim_c or not pred_c:
                continue
            spread = ""
            if hw.get("cycles_send_min") and hw.get("cycles_send_max"):
                spread = round(hw["cycles_send_max"] / hw["cycles_send_min"], 4)
            cand = "__".join(x for x in (str(r.get("label") or ""), str(r.get("version") or "final")) if x) or "final"
            w.writerow([r.get("kernel"), cand, sim_c, pred_c, hw_c, spread])
            n += 1
    return n


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--agent", required=True)
    ap.add_argument("--reference")
    ap.add_argument("--out")
    ap.add_argument("--fidelity-csv", default=None,
                    help="write the paper's figures/ipdps_fidelity.csv "
                         "(kernel,candidate,sim_cycles,pred_cycles,hw_cycles,hw_max_over_min) from the "
                         "agent pass; rows need a passing hw arm, the sweep simulator count and the "
                         "silicon-model prediction (hw_replay --versions on a XKERNEL_KEEP_CANDIDATES sweep)")
    args = ap.parse_args()
    if args.fidelity_csv:
        n = write_fidelity_csv(load(args.agent), Path(args.fidelity_csv))
        print(f"fidelity csv: {n} rows -> {args.fidelity_csv}")
    text = build_report(load(args.agent), load(args.reference))
    print(text)
    if args.out:
        Path(args.out).write_text(text, encoding="utf-8")
        print(f"\n[wrote {args.out}]")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
