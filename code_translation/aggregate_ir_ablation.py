#!/usr/bin/env python3
"""Aggregate results from the 2x2 IR ablation experiment.

Reads benchmark.json files from each (cell, kernel, seed) directory and produces:
  1. Per-cell pass rate with 95% Wilson score binomial CI
  2. Per-kernel x per-cell heatmap (pass counts out of 5)
  3. Interaction analysis: IR x Harness super-additivity test
  4. Error family distribution per cell
  5. Cycles comparison for passing runs (median, best)
  6. Formatted markdown tables suitable for the paper

Usage:
    python aggregate_ir_ablation.py --results-root results/ir_ablation_2x2_*/
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

CELL_DIRS = collections.OrderedDict([
    ("A_bare_baseline", "A (bare)"),
    ("B_harness_only", "B (harness)"),
    ("C_ir_only", "C (IR)"),
    ("D_full_stack", "D (full)"),
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

    Returns: {cell_label: {kernel: [list of benchmark dicts per seed]}}
    """
    data = collections.OrderedDict()
    for cell_dir, cell_label in CELL_DIRS.items():
        data[cell_label] = collections.OrderedDict()
        for kernel in KERNEL_ORDER:
            data[cell_label][kernel] = []

    for root in roots:
        root = str(root)
        for cell_dir, cell_label in CELL_DIRS.items():
            cell_path = os.path.join(root, cell_dir)
            if not os.path.isdir(cell_path):
                continue
            for kernel in KERNEL_ORDER:
                kernel_path = os.path.join(cell_path, kernel)
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
                            data[cell_label][kernel].append(bj)
                        except (json.JSONDecodeError, OSError):
                            data[cell_label][kernel].append({
                                "status": "fail",
                                "failure_reason": "json_parse_error",
                                "_seed_dir": seed_dir,
                                "_seed": seed_entry,
                            })
                    else:
                        data[cell_label][kernel].append({
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


def report_pass_rates(data):
    """Section 1: Per-cell pass rate with Wilson CI."""
    print_section("1. Per-Cell Pass Rate (95% Wilson CI)")

    headers = ["Cell", "Pass", "Total", "Rate", "95% CI"]
    rows = []
    for cell_label in CELL_DIRS.values():
        total_pass = 0
        total_n = 0
        for kernel in KERNEL_ORDER:
            results = data[cell_label][kernel]
            total_pass += pass_count(results)
            total_n += len(results)
        if total_n == 0:
            continue
        rate = total_pass / total_n
        lo, hi = wilson_ci(total_pass, total_n)
        rows.append([
            cell_label,
            str(total_pass),
            str(total_n),
            f"{rate:.1%}",
            f"[{lo:.1%}, {hi:.1%}]",
        ])

    print(format_table(headers, rows, ["l", "r", "r", "r", "r"]))


def report_heatmap(data):
    """Section 2: Per-kernel x per-cell heatmap."""
    print_section("2. Per-Kernel x Per-Cell Pass Heatmap")

    cell_labels = list(CELL_DIRS.values())
    headers = ["Kernel", "Split"] + cell_labels
    rows = []

    for kernel in KERNEL_ORDER:
        row = [kernel, KERNEL_SPLIT.get(kernel, "?")]
        for cell_label in cell_labels:
            results = data[cell_label][kernel]
            n = len(results)
            p = pass_count(results)
            if n > 0:
                row.append(f"{p}/{n}")
            else:
                row.append("---")
        rows.append(row)

    # Totals row
    total_row = ["**TOTAL**", ""]
    for cell_label in cell_labels:
        tp = sum(pass_count(data[cell_label][k]) for k in KERNEL_ORDER)
        tn = sum(len(data[cell_label][k]) for k in KERNEL_ORDER)
        if tn > 0:
            total_row.append(f"**{tp}/{tn}**")
        else:
            total_row.append("---")
    rows.append(total_row)

    print(format_table(
        headers, rows,
        ["l", "c"] + ["c"] * len(cell_labels)
    ))


def report_interaction(data):
    """Section 3: Interaction analysis (super-additivity test)."""
    print_section("3. Interaction Analysis: IR x Harness Super-Additivity")

    cell_labels = list(CELL_DIRS.values())
    has_all = all(
        any(len(data[cl][k]) > 0 for k in KERNEL_ORDER)
        for cl in cell_labels
    )
    if not has_all:
        print("  (Insufficient data -- need all 4 cells populated)\n")
        return

    print("  Formula: interaction = D - (A + (B-A) + (C-A)) = D - B - C + A\n")
    print("  Positive interaction = super-additive (IR + Harness together")
    print("  are worth more than each alone)\n")

    headers = ["Kernel", "A", "B", "C", "D", "Expected", "Actual", "Delta", "Verdict"]
    rows = []

    total_a, total_b, total_c, total_d = 0, 0, 0, 0

    for kernel in KERNEL_ORDER:
        a = pass_count(data["A (bare)"][kernel])
        b = pass_count(data["B (harness)"][kernel])
        c = pass_count(data["C (IR)"][kernel])
        d = pass_count(data["D (full)"][kernel])
        n = max(len(data["A (bare)"][kernel]), 1)

        total_a += a
        total_b += b
        total_c += c
        total_d += d

        # Expected additive = A + harness_effect + ir_effect = A + (B-A) + (C-A) = B + C - A
        expected = b + c - a
        expected = max(0, min(n, expected))  # clamp to [0, n]
        interaction = d - expected
        if interaction > 0:
            verdict = "SUPER-ADD"
        elif interaction < 0:
            verdict = "SUB-ADD"
        else:
            verdict = "ADDITIVE"

        rows.append([
            kernel,
            f"{a}", f"{b}", f"{c}", f"{d}",
            f"{expected}", f"{d}", f"{interaction:+d}",
            verdict,
        ])

    # Aggregate
    exp_total = total_b + total_c - total_a
    int_total = total_d - exp_total
    agg_verdict = "SUPER-ADD" if int_total > 0 else ("SUB-ADD" if int_total < 0 else "ADDITIVE")
    rows.append([
        "**TOTAL**",
        f"{total_a}", f"{total_b}", f"{total_c}", f"{total_d}",
        f"{exp_total}", f"{total_d}", f"{int_total:+d}",
        agg_verdict,
    ])

    print(format_table(
        headers, rows,
        ["l", "r", "r", "r", "r", "r", "r", "r", "c"]
    ))


def report_error_families(data):
    """Section 4: Error family distribution per cell."""
    print_section("4. Error Family Distribution Per Cell")

    cell_labels = list(CELL_DIRS.values())

    # Collect all failure reasons across all cells
    all_reasons = set()
    cell_reason_counts = {}
    for cell_label in cell_labels:
        counter = collections.Counter()
        for kernel in KERNEL_ORDER:
            reasons = get_failure_reasons(data[cell_label][kernel])
            counter.update(reasons)
        cell_reason_counts[cell_label] = counter
        all_reasons.update(counter.keys())

    if not all_reasons:
        print("  (No failures recorded)\n")
        return

    reason_list = sorted(all_reasons)

    headers = ["Failure Reason"] + cell_labels
    rows = []
    for reason in reason_list:
        row = [reason]
        for cl in cell_labels:
            cnt = cell_reason_counts[cl].get(reason, 0)
            row.append(str(cnt) if cnt > 0 else "-")
        rows.append(row)

    # Totals
    total_row = ["**TOTAL FAILURES**"]
    for cl in cell_labels:
        total_row.append(str(sum(cell_reason_counts[cl].values())))
    rows.append(total_row)

    print(format_table(headers, rows, ["l"] + ["r"] * len(cell_labels)))


def report_cycles(data):
    """Section 5: Cycles comparison for passing runs."""
    print_section("5. Cycles Comparison (Passing Runs)")

    cell_labels = list(CELL_DIRS.values())

    # Table: kernel | ref | cell_A median (best) | cell_B median (best) | ...
    headers = ["Kernel", "Ref"]
    for cl in cell_labels:
        headers.append(f"{cl} med(best)")
    headers.append("Best Cell")
    headers.append("Best Speedup")

    rows = []
    for kernel in KERNEL_ORDER:
        ref = REF_CYCLES[kernel]
        row = [kernel, str(ref)]
        best_median = None
        best_cell = None

        for cl in cell_labels:
            cycles = get_cycles(data[cl][kernel])
            if cycles:
                med = median(cycles)
                best = min(cycles)
                row.append(f"{med:.0f} ({best})")
                if best_median is None or med < best_median:
                    best_median = med
                    best_cell = cl
            else:
                row.append("---")

        row.append(best_cell or "---")
        if best_median and best_median > 0:
            speedup = ref / best_median
            row.append(f"{speedup:.2f}x")
        else:
            row.append("---")

        rows.append(row)

    print(format_table(
        headers, rows,
        ["l", "r"] + ["r"] * len(cell_labels) + ["c", "r"]
    ))


def report_marginal_effects(data):
    """Section 6: Marginal effect summary for the paper."""
    print_section("6. Marginal Effects Summary (Paper Table)")

    cell_labels = list(CELL_DIRS.values())

    # Pass rates
    cell_rates = {}
    for cl in cell_labels:
        tp = sum(pass_count(data[cl][k]) for k in KERNEL_ORDER)
        tn = sum(len(data[cl][k]) for k in KERNEL_ORDER)
        cell_rates[cl] = (tp, tn)

    a_p, a_n = cell_rates.get("A (bare)", (0, 0))
    b_p, b_n = cell_rates.get("B (harness)", (0, 0))
    c_p, c_n = cell_rates.get("C (IR)", (0, 0))
    d_p, d_n = cell_rates.get("D (full)", (0, 0))

    print("**Pass-rate marginal effects:**\n")
    headers = ["Effect", "Formula", "Value", "Delta (pp)"]
    rows = []

    def rate(p, n):
        return p / n if n > 0 else 0.0

    a_rate = rate(a_p, a_n)
    b_rate = rate(b_p, b_n)
    c_rate = rate(c_p, c_n)
    d_rate = rate(d_p, d_n)

    harness_effect = b_rate - a_rate
    ir_effect = c_rate - a_rate
    interaction = d_rate - b_rate - c_rate + a_rate

    rows.append(["Baseline (A)", "A", f"{a_rate:.1%}", "---"])
    rows.append(["Harness marginal", "B - A", f"{harness_effect:+.1%}", f"{harness_effect*100:+.1f}pp"])
    rows.append(["IR marginal", "C - A", f"{ir_effect:+.1%}", f"{ir_effect*100:+.1f}pp"])
    rows.append(["Interaction", "D - B - C + A", f"{interaction:+.1%}", f"{interaction*100:+.1f}pp"])
    rows.append(["Full stack (D)", "D", f"{d_rate:.1%}", f"{(d_rate - a_rate)*100:+.1f}pp vs A"])

    print(format_table(headers, rows, ["l", "c", "r", "r"]))

    # Cycles: for kernels that pass in all 4 cells, compare medians
    print("\n\n**Cycles median comparison (kernels passing in >= 2 cells):**\n")
    headers2 = ["Kernel", "A cyc", "B cyc", "C cyc", "D cyc", "Best", "Ref", "Best/Ref"]
    rows2 = []

    for kernel in KERNEL_ORDER:
        ref = REF_CYCLES[kernel]
        cell_medians = {}
        for cl in cell_labels:
            cycles = get_cycles(data[cl][kernel])
            if cycles:
                cell_medians[cl] = median(cycles)

        if len(cell_medians) < 2:
            continue

        row = [kernel]
        best_val = None
        best_cl = None
        for cl in cell_labels:
            if cl in cell_medians:
                v = cell_medians[cl]
                row.append(f"{v:.0f}")
                if best_val is None or v < best_val:
                    best_val = v
                    best_cl = cl
            else:
                row.append("---")
        row.append(best_cl or "---")
        row.append(str(ref))
        row.append(f"{ref / best_val:.2f}x" if best_val else "---")
        rows2.append(row)

    if rows2:
        print(format_table(headers2, rows2, ["l"] + ["r"] * 4 + ["c", "r", "r"]))
    else:
        print("  (No kernels pass in >= 2 cells yet)\n")


# ---- Main ----
def main():
    parser = argparse.ArgumentParser(
        description="Aggregate 2x2 IR ablation results"
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
        len(data[cl][k]) for cl in data for k in data[cl]
    )
    if total_entries == 0:
        print("ERROR: No benchmark results found.", file=sys.stderr)
        sys.exit(1)

    print(f"Loaded {total_entries} total benchmark entries.\n")

    # Run all reports
    report_pass_rates(data)
    report_heatmap(data)
    report_interaction(data)
    report_error_families(data)
    report_cycles(data)
    report_marginal_effects(data)

    print(f"\n{'=' * 70}")
    print(f"  Analysis complete. {total_entries} runs across {len(valid_roots)} root(s).")
    print(f"{'=' * 70}")


if __name__ == "__main__":
    main()
