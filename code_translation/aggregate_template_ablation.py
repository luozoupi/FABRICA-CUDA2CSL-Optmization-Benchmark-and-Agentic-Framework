#!/usr/bin/env python3
"""Aggregate results from the 2-arm template ablation experiment.

Reads benchmark.json files from each (arm, kernel, seed) directory and produces:
  1. Per-arm pass rate with 95% Wilson score binomial CI
  2. Per-kernel pass comparison table
  3. Cycles comparison for passing runs (median, best)
  4. Error family distribution per arm
  5. Delta summary (template effect on pass rate and cycles)

Usage:
    python aggregate_template_ablation.py --results-root results/template_ablation_*/
"""
import argparse
import collections
import glob
import json
import math
import os
import sys
from pathlib import Path


# ---- Reference cycles for speedup computation ----
REF_CYCLES = {
    "ReLU-1PE": 11787,
    "SAXPY-1PE": 11276,
    "Histogram-1PE": 6191,
    "GEMV": 4007,
    "Laplacian2D-Halo": 1709,
    "Wide-Multiplication": 81741,
    "Game-of-Life": 7838,
    "PDFT-Pi-Pipeline": 128308,
}

KERNEL_SPLIT = {
    "ReLU-1PE": "test",
    "SAXPY-1PE": "test",
    "Histogram-1PE": "test",
    "GEMV": "train",
    "Laplacian2D-Halo": "test",
    "Wide-Multiplication": "test",
    "Game-of-Life": "test",
    "PDFT-Pi-Pipeline": "test",
}

KERNEL_ORDER = list(REF_CYCLES.keys())

ARM_DIRS = collections.OrderedDict([
    ("A_no_template", "A (no-template)"),
    ("B_template", "B (template)"),
])


# ---- Wilson score interval ----
def wilson_ci(successes, trials, z=1.96):
    """95% Wilson score confidence interval for a binomial proportion.

    Returns (lower, upper) as proportions in [0, 1].
    """
    if trials == 0:
        return (0.0, 0.0)
    p_hat = successes / trials
    denom = 1 + z * z / trials
    centre = (p_hat + z * z / (2 * trials)) / denom
    margin = (z / denom) * math.sqrt(
        p_hat * (1 - p_hat) / trials + z * z / (4 * trials * trials)
    )
    lo = max(0.0, centre - margin)
    hi = min(1.0, centre + margin)
    return (lo, hi)


# ---- Data loading ----
def find_benchmark_json(seed_dir):
    """Find the most recent benchmark.json under a seed directory."""
    candidates = sorted(
        glob.glob(os.path.join(seed_dir, "run_*", "*", "benchmark.json")),
        key=os.path.getmtime,
        reverse=True,
    )
    if candidates:
        return candidates[0]
    return None


def load_results(roots):
    """Load all benchmark results from one or more result root directories.

    Returns: {arm_label: {kernel: [list of benchmark dicts per seed]}}
    """
    data = collections.OrderedDict()
    for arm_dir, arm_label in ARM_DIRS.items():
        data[arm_label] = collections.OrderedDict()
        for kernel in KERNEL_ORDER:
            data[arm_label][kernel] = []

    for root in roots:
        root = str(root)
        for arm_dir, arm_label in ARM_DIRS.items():
            arm_path = os.path.join(root, arm_dir)
            if not os.path.isdir(arm_path):
                continue
            for kernel in KERNEL_ORDER:
                kernel_path = os.path.join(arm_path, kernel)
                if not os.path.isdir(kernel_path):
                    continue
                for seed_entry in sorted(os.listdir(kernel_path)):
                    if not seed_entry.startswith("seed_"):
                        continue
                    seed_dir = os.path.join(kernel_path, seed_entry)
                    bj_path = find_benchmark_json(seed_dir)
                    if bj_path:
                        try:
                            with open(bj_path) as f:
                                bj = json.load(f)
                            bj["_seed_dir"] = seed_dir
                            bj["_seed"] = seed_entry
                            data[arm_label][kernel].append(bj)
                        except (json.JSONDecodeError, OSError):
                            data[arm_label][kernel].append({
                                "status": "fail",
                                "failure_reason": "json_parse_error",
                                "_seed_dir": seed_dir,
                                "_seed": seed_entry,
                            })
                    else:
                        data[arm_label][kernel].append({
                            "status": "fail",
                            "failure_reason": "no_benchmark",
                            "_seed_dir": seed_dir,
                            "_seed": seed_entry,
                        })
    return data


def median(values):
    """Compute median of a list of numbers."""
    if not values:
        return None
    s = sorted(values)
    n = len(s)
    if n % 2 == 1:
        return s[n // 2]
    return (s[n // 2 - 1] + s[n // 2]) / 2


# ---- Analysis functions ----
def pass_count(results_list):
    """Count passing runs from a list of benchmark dicts."""
    return sum(1 for r in results_list if r.get("status") == "pass")


def get_cycles(results_list):
    """Extract cycles_send from passing runs."""
    cycles = []
    for r in results_list:
        if r.get("status") == "pass":
            c = r.get("cycles_send")
            if isinstance(c, (int, float)) and c > 0:
                cycles.append(int(c))
    return cycles


def get_failure_reasons(results_list):
    """Extract failure reasons from failing runs."""
    reasons = []
    for r in results_list:
        if r.get("status") != "pass":
            reason = r.get("failure_reason") or "unknown"
            reasons.append(reason)
    return reasons


# ---- Output formatters ----
def print_section(title):
    print(f"\n{'=' * 70}")
    print(f"  {title}")
    print(f"{'=' * 70}\n")


def format_table(headers, rows, alignments=None):
    """Format a markdown-style table.

    alignments: list of 'l', 'r', or 'c' per column.
    """
    if alignments is None:
        alignments = ["l"] * len(headers)

    # Compute column widths
    widths = [len(h) for h in headers]
    for row in rows:
        for i, cell in enumerate(row):
            widths[i] = max(widths[i], len(str(cell)))

    def fmt_cell(val, width, align):
        s = str(val)
        if align == "r":
            return s.rjust(width)
        elif align == "c":
            return s.center(width)
        return s.ljust(width)

    # Header
    hdr = "| " + " | ".join(
        fmt_cell(h, widths[i], alignments[i]) for i, h in enumerate(headers)
    ) + " |"

    # Separator
    seps = []
    for i, a in enumerate(alignments):
        w = widths[i]
        if a == "r":
            seps.append("-" * (w - 1) + ":")
        elif a == "c":
            seps.append(":" + "-" * (w - 2) + ":")
        else:
            seps.append("-" * w)
    sep = "| " + " | ".join(seps) + " |"

    # Rows
    lines = [hdr, sep]
    for row in rows:
        line = "| " + " | ".join(
            fmt_cell(row[i], widths[i], alignments[i]) for i in range(len(headers))
        ) + " |"
        lines.append(line)

    return "\n".join(lines)


# ---- Report sections ----
def report_pass_rates(data):
    """Section 1: Per-arm pass rate with Wilson CI."""
    print_section("1. Per-Arm Pass Rate (95% Wilson CI)")

    headers = ["Arm", "Pass", "Total", "Rate", "95% CI"]
    rows = []
    for arm_label in ARM_DIRS.values():
        total_pass = 0
        total_n = 0
        for kernel in KERNEL_ORDER:
            results = data[arm_label][kernel]
            total_pass += pass_count(results)
            total_n += len(results)
        if total_n == 0:
            continue
        rate = total_pass / total_n
        lo, hi = wilson_ci(total_pass, total_n)
        rows.append([
            arm_label,
            str(total_pass),
            str(total_n),
            f"{rate:.1%}",
            f"[{lo:.1%}, {hi:.1%}]",
        ])

    print(format_table(headers, rows, ["l", "r", "r", "r", "r"]))


def report_per_kernel(data):
    """Section 2: Per-kernel pass comparison table."""
    print_section("2. Per-Kernel Pass Comparison")

    arm_labels = list(ARM_DIRS.values())
    headers = ["Kernel", "Split"] + arm_labels + ["Delta", "Verdict"]
    rows = []

    for kernel in KERNEL_ORDER:
        row = [kernel, KERNEL_SPLIT.get(kernel, "?")]
        pass_vals = []
        for arm_label in arm_labels:
            results = data[arm_label][kernel]
            n = len(results)
            p = pass_count(results)
            pass_vals.append((p, n))
            if n > 0:
                row.append(f"{p}/{n}")
            else:
                row.append("---")

        # Delta: template - no-template
        if len(pass_vals) == 2 and pass_vals[0][1] > 0 and pass_vals[1][1] > 0:
            delta = pass_vals[1][0] - pass_vals[0][0]
            if delta > 0:
                verdict = "TEMPLATE_WINS"
            elif delta < 0:
                verdict = "TEMPLATE_LOSES"
            else:
                verdict = "TIE"
            row.append(f"{delta:+d}")
            row.append(verdict)
        else:
            row.append("---")
            row.append("---")
        rows.append(row)

    # Totals row
    total_row = ["**TOTAL**", ""]
    total_delta_p = 0
    for arm_label in arm_labels:
        tp = sum(pass_count(data[arm_label][k]) for k in KERNEL_ORDER)
        tn = sum(len(data[arm_label][k]) for k in KERNEL_ORDER)
        if arm_label == arm_labels[0]:
            total_a = (tp, tn)
        else:
            total_b = (tp, tn)
        if tn > 0:
            total_row.append(f"**{tp}/{tn}**")
        else:
            total_row.append("---")
    if total_a[1] > 0 and total_b[1] > 0:
        td = total_b[0] - total_a[0]
        total_row.append(f"{td:+d}")
        total_row.append("TEMPLATE_WINS" if td > 0 else ("TEMPLATE_LOSES" if td < 0 else "TIE"))
    else:
        total_row.append("---")
        total_row.append("---")
    rows.append(total_row)

    print(format_table(
        headers, rows,
        ["l", "c"] + ["c"] * len(arm_labels) + ["r", "c"]
    ))


def report_cycles(data):
    """Section 3: Cycles comparison for passing runs."""
    print_section("3. Cycles Comparison (Passing Runs)")

    arm_labels = list(ARM_DIRS.values())

    headers = ["Kernel", "Ref"]
    for al in arm_labels:
        headers.append(f"{al} med(best)")
    headers.append("Best Arm")
    headers.append("Best Speedup")

    rows = []
    for kernel in KERNEL_ORDER:
        ref = REF_CYCLES[kernel]
        row = [kernel, str(ref)]
        best_median = None
        best_arm = None

        for al in arm_labels:
            cycles = get_cycles(data[al][kernel])
            if cycles:
                med = median(cycles)
                best = min(cycles)
                row.append(f"{med:.0f} ({best})")
                if best_median is None or med < best_median:
                    best_median = med
                    best_arm = al
            else:
                row.append("---")

        row.append(best_arm or "---")
        if best_median and best_median > 0:
            speedup = ref / best_median
            row.append(f"{speedup:.2f}x")
        else:
            row.append("---")

        rows.append(row)

    print(format_table(
        headers, rows,
        ["l", "r"] + ["r"] * len(arm_labels) + ["c", "r"]
    ))


def report_error_families(data):
    """Section 4: Error family distribution per arm."""
    print_section("4. Error Family Distribution Per Arm")

    arm_labels = list(ARM_DIRS.values())

    # Collect all failure reasons across all arms
    all_reasons = set()
    arm_reason_counts = {}
    for arm_label in arm_labels:
        counter = collections.Counter()
        for kernel in KERNEL_ORDER:
            reasons = get_failure_reasons(data[arm_label][kernel])
            counter.update(reasons)
        arm_reason_counts[arm_label] = counter
        all_reasons.update(counter.keys())

    if not all_reasons:
        print("  (No failures recorded)\n")
        return

    reason_list = sorted(all_reasons)

    headers = ["Failure Reason"] + arm_labels
    rows = []
    for reason in reason_list:
        row = [reason]
        for al in arm_labels:
            cnt = arm_reason_counts[al].get(reason, 0)
            row.append(str(cnt) if cnt > 0 else "-")
        rows.append(row)

    # Totals
    total_row = ["**TOTAL FAILURES**"]
    for al in arm_labels:
        total_row.append(str(sum(arm_reason_counts[al].values())))
    rows.append(total_row)

    print(format_table(headers, rows, ["l"] + ["r"] * len(arm_labels)))


def report_delta_summary(data):
    """Section 5: Delta summary (template effect on pass rate and cycles)."""
    print_section("5. Template Effect Delta Summary")

    arm_labels = list(ARM_DIRS.values())
    if len(arm_labels) != 2:
        print("  (Need exactly 2 arms for delta summary)\n")
        return

    arm_a, arm_b = arm_labels[0], arm_labels[1]

    # Pass rates
    a_pass = sum(pass_count(data[arm_a][k]) for k in KERNEL_ORDER)
    a_total = sum(len(data[arm_a][k]) for k in KERNEL_ORDER)
    b_pass = sum(pass_count(data[arm_b][k]) for k in KERNEL_ORDER)
    b_total = sum(len(data[arm_b][k]) for k in KERNEL_ORDER)

    if a_total == 0 or b_total == 0:
        print("  (Insufficient data)\n")
        return

    a_rate = a_pass / a_total
    b_rate = b_pass / b_total
    delta_pp = (b_rate - a_rate) * 100

    a_lo, a_hi = wilson_ci(a_pass, a_total)
    b_lo, b_hi = wilson_ci(b_pass, b_total)

    print("**Pass-rate effect:**\n")
    headers = ["Metric", arm_a, arm_b, "Delta"]
    rows = [
        [
            "Pass rate",
            f"{a_rate:.1%} [{a_lo:.1%}, {a_hi:.1%}]",
            f"{b_rate:.1%} [{b_lo:.1%}, {b_hi:.1%}]",
            f"{delta_pp:+.1f}pp",
        ],
        [
            "Passes",
            f"{a_pass}/{a_total}",
            f"{b_pass}/{b_total}",
            f"{b_pass - a_pass:+d}",
        ],
    ]
    print(format_table(headers, rows, ["l", "r", "r", "r"]))

    # CI overlap check
    ci_overlap = a_lo <= b_hi and b_lo <= a_hi
    if ci_overlap:
        print("\n  Note: Wilson 95% CIs OVERLAP -- difference is NOT statistically significant.")
    else:
        direction = "higher" if b_rate > a_rate else "lower"
        print(f"\n  Note: Wilson 95% CIs do NOT overlap -- template arm is significantly {direction}.")

    # Cycles comparison for kernels that pass in both arms
    print("\n\n**Cycles effect (kernels passing in both arms):**\n")
    headers2 = ["Kernel", f"{arm_a} med", f"{arm_b} med", "Ref",
                "Speedup A", "Speedup B", "Template Effect"]
    rows2 = []

    for kernel in KERNEL_ORDER:
        a_cyc = get_cycles(data[arm_a][kernel])
        b_cyc = get_cycles(data[arm_b][kernel])
        ref = REF_CYCLES[kernel]

        if not a_cyc or not b_cyc:
            continue

        a_med = median(a_cyc)
        b_med = median(b_cyc)
        a_speedup = ref / a_med if a_med > 0 else 0
        b_speedup = ref / b_med if b_med > 0 else 0

        if a_med > 0:
            pct_change = (a_med - b_med) / a_med * 100
            if pct_change > 0:
                effect = f"-{pct_change:.0f}% (faster)"
            elif pct_change < 0:
                effect = f"+{-pct_change:.0f}% (slower)"
            else:
                effect = "0% (same)"
        else:
            effect = "---"

        rows2.append([
            kernel,
            f"{a_med:.0f}",
            f"{b_med:.0f}",
            str(ref),
            f"{a_speedup:.2f}x",
            f"{b_speedup:.2f}x",
            effect,
        ])

    if rows2:
        print(format_table(headers2, rows2, ["l", "r", "r", "r", "r", "r", "r"]))
    else:
        print("  (No kernels pass in both arms yet)\n")

    # Per-kernel win/loss/tie summary
    wins, losses, ties = 0, 0, 0
    for kernel in KERNEL_ORDER:
        a_p = pass_count(data[arm_a][kernel])
        b_p = pass_count(data[arm_b][kernel])
        d = b_p - a_p
        if d > 0:
            wins += 1
        elif d < 0:
            losses += 1
        else:
            ties += 1

    print(f"\n**Per-kernel verdict:**")
    print(f"  Template wins:  {wins}/{len(KERNEL_ORDER)} kernels")
    print(f"  Template loses: {losses}/{len(KERNEL_ORDER)} kernels")
    print(f"  Ties:           {ties}/{len(KERNEL_ORDER)} kernels")

    verdict = "NOT PROVEN"
    if not ci_overlap and b_rate > a_rate:
        verdict = "PROVEN POSITIVE"
    elif not ci_overlap and b_rate < a_rate:
        verdict = "PROVEN NEGATIVE"

    print(f"\n  OVERALL VERDICT: {verdict}")
    if verdict == "NOT PROVEN":
        print("  (CIs overlap; cannot claim template is a statistically significant lever)")


# ---- Main ----
def main():
    parser = argparse.ArgumentParser(
        description="Aggregate 2-arm template ablation results"
    )
    parser.add_argument(
        "--results-root",
        nargs="+",
        required=True,
        help="One or more result root directories (glob-expanded by shell)",
    )
    args = parser.parse_args()

    # Expand and validate roots
    roots = []
    for pattern in args.results_root:
        expanded = glob.glob(pattern)
        if expanded:
            roots.extend(expanded)
        else:
            roots.append(pattern)  # let load_results handle missing

    valid_roots = [r for r in roots if os.path.isdir(r)]
    if not valid_roots:
        print(f"ERROR: No valid result directories found in: {args.results_root}",
              file=sys.stderr)
        sys.exit(1)

    print(f"Loading results from {len(valid_roots)} root(s): {valid_roots}")

    data = load_results(valid_roots)

    # Check if we have any data
    total_entries = sum(
        len(data[al][k]) for al in data for k in data[al]
    )
    if total_entries == 0:
        print("ERROR: No benchmark results found.", file=sys.stderr)
        sys.exit(1)

    print(f"Loaded {total_entries} total benchmark entries.\n")

    # Run all reports
    report_pass_rates(data)
    report_per_kernel(data)
    report_cycles(data)
    report_error_families(data)
    report_delta_summary(data)

    print(f"\n{'=' * 70}")
    print(f"  Analysis complete. {total_entries} runs across {len(valid_roots)} root(s).")
    print(f"{'=' * 70}")


if __name__ == "__main__":
    main()
