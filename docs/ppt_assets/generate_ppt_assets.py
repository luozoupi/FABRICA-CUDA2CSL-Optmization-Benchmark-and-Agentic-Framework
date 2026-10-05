#!/usr/bin/env python3
"""Generate PPT-ready figures and tables from the xkernel progress docs.

The values here are transcribed from:
- docs/SWEEP_RESULTS_20260630.md
- docs/SESSION_PROGRESS_20260702.md
- docs/HARDWARE_VALIDATION_20260706.md
- docs/PROFILING_ARCHITECTURE.md
"""

from __future__ import annotations

import csv
from pathlib import Path

import matplotlib.pyplot as plt
from matplotlib import patches
from matplotlib.ticker import FuncFormatter, NullFormatter


OUT = Path(__file__).resolve().parent
FIG_DIR = OUT / "figures"
TABLE_DIR = OUT / "tables"

BG = "#fbf7ee"
INK = "#1f2933"
MUTED = "#64748b"
GRID = "#d9d6cc"
FRONTIER = "#0f766e"
OPEN = "#d97706"
ACCENT = "#2563eb"
GOOD = "#16a34a"
WARN = "#ca8a04"
BAD = "#dc2626"
SIM = "#334155"
HW = "#14b8a6"


MODEL_ROWS = [
    {
        "model": "Claude Opus 4.8",
        "type": "Frontier",
        "scope": "full 28",
        "pass": 26,
        "total": 28,
        "beats_expert": 16,
    },
    {
        "model": "Claude Sonnet 4.6",
        "type": "Frontier",
        "scope": "full 28",
        "pass": 25,
        "total": 28,
        "beats_expert": 17,
    },
    {
        "model": "Claude Opus 4.6",
        "type": "Frontier",
        "scope": "full 28",
        "pass": 24,
        "total": 28,
        "beats_expert": 14,
    },
    {
        "model": "gpt-oss-20b",
        "type": "Open",
        "scope": "12-kernel probe",
        "pass": 1,
        "total": 12,
        "beats_expert": 0,
    },
    {
        "model": "gpt-oss-120b",
        "type": "Open",
        "scope": "full 28",
        "pass": 2,
        "total": 28,
        "beats_expert": 1,
    },
    {
        "model": "Gemma 4 31B",
        "type": "Open",
        "scope": "full 28",
        "pass": 1,
        "total": 28,
        "beats_expert": 0,
    },
    {
        "model": "Mistral Large 3 675B",
        "type": "Open",
        "scope": "12-kernel probe",
        "pass": 0,
        "total": 12,
        "beats_expert": 0,
    },
    {
        "model": "Llama 4 Maverick",
        "type": "Open",
        "scope": "12-kernel probe",
        "pass": 0,
        "total": 12,
        "beats_expert": 0,
    },
    {
        "model": "Llama 3.3 70B",
        "type": "Open",
        "scope": "12-kernel probe",
        "pass": 0,
        "total": 12,
        "beats_expert": 0,
    },
    {
        "model": "Llama 3.1 70B",
        "type": "Open",
        "scope": "12-kernel probe",
        "pass": 0,
        "total": 12,
        "beats_expert": 0,
    },
    {
        "model": "Gemma 4 E4B",
        "type": "Open",
        "scope": "12-kernel probe",
        "pass": 0,
        "total": 12,
        "beats_expert": 0,
    },
]


HARDWARE_ROWS = [
    {
        "kernel": "Histogram-1PE",
        "sim_cycles": 6191,
        "hw_cycles": 5808,
        "delta_pct": -6.2,
        "reliability": "reliable",
    },
    {
        "kernel": "Histogram-Inline",
        "sim_cycles": 1967,
        "hw_cycles": 1776,
        "delta_pct": -9.7,
        "reliability": "reliable",
    },
    {
        "kernel": "GEMV-RowPart",
        "sim_cycles": 711,
        "hw_cycles": 820,
        "delta_pct": 15.3,
        "reliability": "reliable",
    },
    {
        "kernel": "Single-Tile-Matvec",
        "sim_cycles": 780,
        "hw_cycles": 63,
        "delta_pct": -91.9,
        "reliability": "partial",
    },
    {
        "kernel": "DFT-1PE",
        "sim_cycles": 145233,
        "hw_cycles": 8607,
        "delta_pct": -94.1,
        "reliability": "partial",
    },
    {
        "kernel": "Stencil7pt-1PE",
        "sim_cycles": 40497,
        "hw_cycles": 3579,
        "delta_pct": -91.2,
        "reliability": "partial",
    },
]


PROFILER_ROWS = [
    {
        "kernel": "Jacobi-2D-5pt",
        "expert_cycles": 1566,
        "best_previous_cycles": 738,
        "trace_profiled_cycles": 655,
        "improvement_vs_previous_pct": 11,
        "speedup_vs_expert": 2.39,
    },
    {
        "kernel": "Game-of-Life",
        "expert_cycles": 7849,
        "best_previous_cycles": 3358,
        "trace_profiled_cycles": 2415,
        "improvement_vs_previous_pct": 28,
        "speedup_vs_expert": 3.25,
    },
]


PROFILER_PLAYBOOK_ROWS = [
    {
        "signal": "sim.log stats",
        "diagnosis": "Classify stall-bound, fabric-heavy, or idle-tail behavior.",
        "action": "Unblock queues; reduce fabric traffic; rebalance PE work.",
    },
    {
        "signal": "dispatch traces",
        "diagnosis": "Find idle PEs or data movement dominating arithmetic.",
        "action": "Use DSD chaining; fuse loops; reduce @fmovs.",
    },
    {
        "signal": "backpressure",
        "diagnosis": "Localize congested PE, color, or halo direction.",
        "action": "Reorder send/recv; add async FIFO; split colors.",
    },
    {
        "signal": "wavelet flow traces",
        "diagnosis": "Detect bursty long-tail communication latency.",
        "action": "Stagger phases; overlap receive with compute.",
    },
    {
        "signal": "ELF / symbols",
        "diagnosis": "Expose SRAM pressure, large sections, or task bloat.",
        "action": "Shrink buffers; use comptime constants; repartition.",
    },
    {
        "signal": "debug_util post-mortem",
        "diagnosis": "Spot wrong PE-local state after execution.",
        "action": "Inspect symbols; fix distribution/reduction; rerun.",
    },
]


def pct(row: dict[str, object]) -> float:
    return 100.0 * float(row["pass"]) / float(row["total"])


def style_ax(ax):
    ax.set_facecolor(BG)
    for spine in ax.spines.values():
        spine.set_visible(False)
    ax.tick_params(colors=INK, labelsize=11)
    ax.grid(axis="x", color=GRID, linewidth=1, alpha=0.7)
    ax.set_axisbelow(True)


def title(fig, main: str, sub: str | None = None):
    fig.text(0.055, 0.945, main, fontsize=27, fontweight="bold", color=INK)
    if sub:
        fig.text(0.055, 0.905, sub, fontsize=13, color=MUTED)


def footer(fig, text: str):
    fig.text(0.055, 0.035, text, fontsize=9.5, color=MUTED)


def save(fig, stem: str):
    FIG_DIR.mkdir(parents=True, exist_ok=True)
    for ext in ("png", "pdf", "svg"):
        fig.savefig(FIG_DIR / f"{stem}.{ext}", dpi=220, bbox_inches="tight", facecolor=BG)
    plt.close(fig)


def fig_model_pass_rates():
    rows = sorted(MODEL_ROWS, key=lambda r: (pct(r), r["pass"]), reverse=True)
    fig, ax = plt.subplots(figsize=(13.33, 7.5), facecolor=BG)
    fig.subplots_adjust(top=0.84, bottom=0.12, left=0.27, right=0.94)
    style_ax(ax)

    ys = list(range(len(rows)))
    colors = [FRONTIER if r["type"] == "Frontier" else OPEN for r in rows]
    bars = ax.barh(ys, [pct(r) for r in rows], color=colors, height=0.62)
    for bar, row in zip(bars, rows):
        if row["scope"] == "12-kernel probe":
            bar.set_hatch("//")
            bar.set_edgecolor("#7c2d12")
        label = f"{row['pass']}/{row['total']} ({pct(row):.0f}%)"
        ax.text(
            min(pct(row) + 2.2, 96),
            bar.get_y() + bar.get_height() / 2,
            label,
            va="center",
            fontsize=11,
            color=INK,
        )

    ax.set_yticks(ys)
    ax.set_yticklabels([r["model"] for r in rows])
    ax.invert_yaxis()
    ax.set_xlim(0, 105)
    ax.xaxis.set_major_formatter(FuncFormatter(lambda x, _pos: f"{x:.0f}%"))
    ax.set_xlabel("Pass rate", color=INK, fontsize=12)
    title(
        fig,
        "CUDA-to-CSL remains a frontier-model capability",
        "Full 28-kernel sweeps are solid bars; fixed 12-kernel probes are hatched.",
    )
    ax.text(
        72,
        8.6,
        "Observation: the system stack helps, but base CSL-generation skill is still the gate.",
        fontsize=12,
        color=INK,
        bbox=dict(boxstyle="round,pad=0.45", facecolor="#fff7ed", edgecolor="#fed7aa"),
    )
    footer(
        fig,
        "Sources: SWEEP_RESULTS_20260630.md and SESSION_PROGRESS_20260702.md. "
        "Rates with different denominators should not be over-compared.",
    )
    save(fig, "model_pass_rates")


def fig_ablation_stack():
    configs = [
        ("One-shot\nno KB/repair/W2", 6, 28, 1),
        ("June 25\ncap=20 stack", 17, 25, 10),
        ("Full stack\nOpus 4.8", 26, 28, 16),
    ]
    kernels = [
        ("DFT-1PE", 1.00, 11.20),
        ("PDFT-Pi", 1.00, 7.26),
        ("Stencil7pt", 1.00, 7.37),
        ("Tensor-Transpose", 1.00, 11.71),
        ("GEMV-RowPart", 0.99, 4.94),
    ]
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13.33, 7.5), facecolor=BG)
    fig.subplots_adjust(top=0.80, bottom=0.16, left=0.08, right=0.96, wspace=0.28)
    title(
        fig,
        "The agent stack turns raw translation into a benchmark system",
        "Repair, gotcha retrieval, contracts, best-of-N, and W2 optimization add both correctness and speed.",
    )

    style_ax(ax1)
    xs = range(len(configs))
    rates = [100 * p / t for _, p, t, _ in configs]
    bars = ax1.bar(xs, rates, color=[WARN, ACCENT, FRONTIER], width=0.62)
    for bar, (_, passed, total, beats) in zip(bars, configs):
        ax1.text(
            bar.get_x() + bar.get_width() / 2,
            bar.get_height() + 3,
            f"{passed}/{total}\n{beats} beats expert",
            ha="center",
            fontsize=11,
            color=INK,
        )
    ax1.set_xticks(list(xs))
    ax1.set_xticklabels([c[0] for c in configs], fontsize=11)
    ax1.set_ylim(0, 108)
    ax1.yaxis.set_major_formatter(FuncFormatter(lambda x, _pos: f"{x:.0f}%"))
    ax1.set_ylabel("Pass rate", color=INK)
    ax1.set_title("A. Correctness unlocked", fontsize=15, color=INK, fontweight="bold")
    ax1.text(
        0.08,
        0.94,
        "Full stack adds +20 passing kernels\nrelative to raw one-shot.",
        transform=ax1.transAxes,
        ha="left",
        va="top",
        fontsize=11.5,
        color=INK,
        bbox=dict(boxstyle="round,pad=0.45", facecolor="#ecfeff", edgecolor="#99f6e4"),
    )

    style_ax(ax2)
    y = list(range(len(kernels)))
    one = [k[1] for k in kernels]
    full = [k[2] for k in kernels]
    ax2.scatter(one, y, s=95, color=WARN, label="one-shot", zorder=3)
    ax2.scatter(full, y, s=95, color=FRONTIER, label="full W2", zorder=3)
    for yi, (name, a, b) in zip(y, kernels):
        ax2.plot([a, b], [yi, yi], color=GRID, linewidth=5, solid_capstyle="round")
        ax2.text(b + 0.22, yi, f"{b:.2f}x", va="center", fontsize=11, color=INK)
    ax2.set_yticks(y)
    ax2.set_yticklabels([k[0] for k in kernels])
    ax2.invert_yaxis()
    ax2.set_xlim(0, 12.6)
    ax2.set_xlabel("Speedup vs expert reference", color=INK)
    ax2.set_title("B. Optimizer turns parity into speedups", fontsize=15, color=INK, fontweight="bold")
    ax2.legend(loc="lower right", frameon=False)
    footer(
        fig,
        "Sources: AGENT_SWEEP_SCOREBOARD_20260625.md, SWEEP_RESULTS_20260630.md, "
        "SESSION_PROGRESS_20260702.md.",
    )
    save(fig, "ablation_and_stack")


def fig_hardware_validation():
    fig, ax = plt.subplots(figsize=(13.33, 7.5), facecolor=BG)
    fig.subplots_adjust(top=0.82, bottom=0.20, left=0.10, right=0.96)
    title(
        fig,
        "Real WSE-3 validation breaks the simulator-only barrier",
        "Hardware confirms correctness and exposes where simulator cycles are relative, not absolute.",
    )
    style_ax(ax)

    labels = [r["kernel"] for r in HARDWARE_ROWS]
    xs = list(range(len(labels)))
    width = 0.36
    ax.bar([x - width / 2 for x in xs], [r["sim_cycles"] for r in HARDWARE_ROWS], width, label="Simulator", color=SIM)
    hw_bars = ax.bar([x + width / 2 for x in xs], [r["hw_cycles"] for r in HARDWARE_ROWS], width, label="Real WSE-3", color=HW)
    for x, row, bar in zip(xs, HARDWARE_ROWS, hw_bars):
        if row["reliability"] == "partial":
            bar.set_hatch("//")
            bar.set_edgecolor("#0f766e")
        ax.text(
            x,
            max(row["sim_cycles"], row["hw_cycles"]) * 1.25,
            f"{row['delta_pct']:+.1f}%",
            ha="center",
            va="bottom",
            fontsize=10.5,
            color=INK,
        )
    ax.set_yscale("log")
    ax.yaxis.set_minor_formatter(NullFormatter())
    ax.set_ylabel("Cycles, log scale", color=INK)
    ax.set_xticks(xs)
    ax.set_xticklabels(labels, rotation=20, ha="right")
    ax.legend(loc="upper right", frameon=False)
    ax.text(
        2.15,
        150000,
        "Solid: reliable cycle comparison\nHatched: correctness valid, timing interpretation partial",
        fontsize=11,
        color=INK,
        bbox=dict(boxstyle="round,pad=0.45", facecolor="#ecfeff", edgecolor="#99f6e4"),
    )
    footer(
        fig,
        "Source: HARDWARE_VALIDATION_20260706.md. Hardware wall time includes cluster scheduling; cycles are the compute metric.",
    )
    save(fig, "hardware_validation")


def fig_profiler_feedback():
    fig, ax = plt.subplots(figsize=(13.33, 7.5), facecolor=BG)
    fig.subplots_adjust(top=0.80, bottom=0.18, left=0.16, right=0.92)
    title(
        fig,
        "Profiler feedback gives the optimizer architectural eyes",
        "Trace context improved multi-PE kernels by surfacing PE utilization and communication bottlenecks.",
    )
    style_ax(ax)

    labels = [r["kernel"] for r in PROFILER_ROWS]
    xs = list(range(len(labels)))
    width = 0.25
    ax.bar([x - width for x in xs], [r["expert_cycles"] for r in PROFILER_ROWS], width, color="#94a3b8", label="expert ref")
    ax.bar(xs, [r["best_previous_cycles"] for r in PROFILER_ROWS], width, color=ACCENT, label="best previous")
    trace = ax.bar([x + width for x in xs], [r["trace_profiled_cycles"] for r in PROFILER_ROWS], width, color=FRONTIER, label="trace-profiled")
    for x, row, bar in zip(xs, PROFILER_ROWS, trace):
        ax.text(
            x + width,
            bar.get_height() + 95,
            f"-{row['improvement_vs_previous_pct']}%\nvs previous",
            ha="center",
            va="bottom",
            fontsize=11,
            color=INK,
        )
        ax.text(
            x - width,
            row["expert_cycles"] + 160,
            f"{row['speedup_vs_expert']:.2f}x\nvs expert",
            ha="center",
            va="bottom",
            fontsize=10,
            color=MUTED,
        )
    ax.set_xticks(xs)
    ax.set_xticklabels(labels)
    ax.set_ylabel("Cycles, lower is better", color=INK)
    ax.set_ylim(0, 8800)
    ax.legend(loc="upper left", bbox_to_anchor=(0.0, 1.03), ncol=3, frameon=False)
    ax.text(
        1.22,
        5550,
        "Signals logged for each step:\n"
        "- sim.log bottleneck label\n"
        "- PE utilization stats\n"
        "- backpressure / congestion count\n"
        "- SRAM utilization\n"
        "- reasoning reflection",
        fontsize=11,
        color=INK,
        bbox=dict(boxstyle="round,pad=0.55", facecolor="#f0fdf4", edgecolor="#bbf7d0"),
    )
    footer(
        fig,
        "Sources: HARDWARE_VALIDATION_20260706.md and PROFILING_ARCHITECTURE.md.",
    )
    save(fig, "profiler_feedback")


def rounded_box(ax, xy, wh, text, fc, ec=GRID, fontsize=11.5, weight="normal"):
    box = patches.FancyBboxPatch(
        xy,
        wh[0],
        wh[1],
        boxstyle="round,pad=0.018,rounding_size=0.025",
        linewidth=1.5,
        edgecolor=ec,
        facecolor=fc,
    )
    ax.add_patch(box)
    ax.text(
        xy[0] + wh[0] / 2,
        xy[1] + wh[1] / 2,
        text,
        ha="center",
        va="center",
        fontsize=fontsize,
        color=INK,
        fontweight=weight,
        linespacing=1.25,
    )


def fig_profiler_bottleneck_playbook():
    fig, ax = plt.subplots(figsize=(13.33, 7.5), facecolor=BG)
    fig.subplots_adjust(top=0.84, bottom=0.10, left=0.035, right=0.965)
    ax.set_axis_off()
    title(
        fig,
        "Profiler-to-optimizer bottleneck playbook",
        "A reference CSL benchmark can teach the agent where the cycles go, not just whether the run passed.",
    )

    headers = [
        ("Profiler signal", 0.04, 0.20),
        ("Bottleneck insight", 0.27, 0.34),
        ("CSL action", 0.65, 0.31),
    ]
    for label, x, w in headers:
        rounded_box(ax, (x, 0.76), (w, 0.07), label, "#e2e8f0", "#cbd5e1", fontsize=12.5, weight="bold")

    y = 0.64
    row_h = 0.084
    palette = ["#ecfeff", "#f0fdf4", "#fff7ed", "#eff6ff", "#f8fafc", "#fef2f2"]
    edges = ["#67e8f9", "#86efac", "#fdba74", "#93c5fd", "#cbd5e1", "#fca5a5"]
    for idx, row in enumerate(PROFILER_PLAYBOOK_ROWS):
        fc = palette[idx % len(palette)]
        ec = edges[idx % len(edges)]
        rounded_box(ax, (0.04, y), (0.20, row_h), row["signal"], fc, ec, fontsize=11.2, weight="bold")
        rounded_box(ax, (0.27, y), (0.34, row_h), row["diagnosis"], fc, ec, fontsize=10.3)
        rounded_box(ax, (0.65, y), (0.31, row_h), row["action"], fc, ec, fontsize=10.3)
        arrow(ax, (0.24, y + row_h / 2), (0.27, y + row_h / 2), color=MUTED)
        arrow(ax, (0.61, y + row_h / 2), (0.65, y + row_h / 2), color=MUTED)
        y -= 0.095

    ax.text(
        0.04,
        0.055,
        "Slide takeaway: cycles alone rank candidates; profiler context explains which architectural lever to try next.",
        fontsize=12.5,
        color=INK,
        bbox=dict(boxstyle="round,pad=0.5", facecolor="#ecfeff", edgecolor="#99f6e4"),
    )
    footer(
        fig,
        "Sources: PROFILING_ARCHITECTURE.md and HARDWARE_VALIDATION_20260706.md. "
        "Current implementation logs sim.log/profile context; deeper CTF parsing is the next step.",
    )
    save(fig, "profiler_bottleneck_playbook")


def arrow(ax, start, end, color=INK, rad=0.0):
    ax.annotate(
        "",
        xy=end,
        xytext=start,
        arrowprops=dict(arrowstyle="-|>", color=color, lw=1.8, shrinkA=8, shrinkB=8, connectionstyle=f"arc3,rad={rad}"),
    )


def fig_agentic_workflow():
    fig, ax = plt.subplots(figsize=(13.33, 7.5), facecolor=BG)
    fig.subplots_adjust(top=0.84, bottom=0.08, left=0.04, right=0.96)
    ax.set_axis_off()
    title(
        fig,
        "xkernel agentic CUDA-to-CSL workflow",
        "The system constrains generation to the reference contract, validates in a staged bundle, then optimizes with runtime feedback.",
    )

    rounded_box(ax, (0.03, 0.55), (0.14, 0.18), "CUDA input\n+ kernel spec\n+ hidden reference", "#e0f2fe", "#7dd3fc", weight="bold")
    rounded_box(ax, (0.22, 0.55), (0.15, 0.18), "W1 translate\nbest-of-N\ncontract prompts", "#ccfbf1", "#5eead4", weight="bold")
    rounded_box(ax, (0.42, 0.55), (0.14, 0.18), "Staged CSL\nbundle\nreplace compute", "#fef3c7", "#fcd34d", weight="bold")
    rounded_box(ax, (0.61, 0.55), (0.14, 0.18), "Compile + run\nSDK wrapper\nscore cycles", "#dcfce7", "#86efac", weight="bold")
    rounded_box(ax, (0.80, 0.55), (0.15, 0.18), "Best valid\nartifact\n+ benchmark JSON", "#ede9fe", "#c4b5fd", weight="bold")

    rounded_box(ax, (0.22, 0.20), (0.15, 0.17), "Gotcha KB\nbehavioral\ncontracts", "#fff7ed", "#fdba74")
    rounded_box(ax, (0.42, 0.20), (0.14, 0.17), "Debugger v2\nstdout/stderr\nfile-scoped repair", "#fee2e2", "#fca5a5")
    rounded_box(ax, (0.61, 0.20), (0.14, 0.17), "W2 optimize\ncycle reduction\nkeep best pass", "#f0fdf4", "#86efac")
    rounded_box(ax, (0.80, 0.20), (0.15, 0.17), "Profiler loop\nPE utilization\nbackpressure\nSRAM", "#ecfeff", "#67e8f9")

    arrow(ax, (0.17, 0.64), (0.22, 0.64))
    arrow(ax, (0.37, 0.64), (0.42, 0.64))
    arrow(ax, (0.56, 0.64), (0.61, 0.64))
    arrow(ax, (0.75, 0.64), (0.80, 0.64))
    arrow(ax, (0.68, 0.55), (0.68, 0.37), GOOD)
    arrow(ax, (0.61, 0.29), (0.56, 0.29), BAD)
    arrow(ax, (0.42, 0.29), (0.37, 0.29), BAD)
    arrow(ax, (0.30, 0.37), (0.30, 0.55), ACCENT)
    arrow(ax, (0.75, 0.29), (0.80, 0.29), ACCENT)
    arrow(ax, (0.88, 0.37), (0.88, 0.55), ACCENT)

    ax.text(0.47, 0.44, "failures feed repair", fontsize=11, color=BAD, ha="center")
    ax.text(0.66, 0.44, "passes feed optimization", fontsize=10.5, color=GOOD, ha="center")
    ax.text(0.88, 0.40, "architectural feedback", fontsize=10.5, color=ACCENT, ha="center")
    footer(
        fig,
        "Sources: SESSION_PROGRESS_20260630.md, SESSION_PROGRESS_20260702.md, PROFILING_ARCHITECTURE.md.",
    )
    save(fig, "agentic_workflow")


def fig_porting_status():
    rows = [
        ("Simple", 4, "remove comptime_struct annotations", "Histogram, DFT, Stencil7pt, GEMV-RowPart", GOOD),
        ("Medium", 5, "add default layout params", "Tensor, GEMM, Histogram-Inline, PDFT, Matvec", WARN),
        ("Hard", 5, "rewrite memcpy/struct wiring", "Wide-Mult, Mandelbrot, Jacobi, Residual, multi-PE concat", BAD),
    ]
    fig, ax = plt.subplots(figsize=(13.33, 7.5), facecolor=BG)
    fig.subplots_adjust(top=0.82, bottom=0.14, left=0.10, right=0.94)
    title(
        fig,
        "SDK 2.10 hardware porting is systematic, not mysterious",
        "The first WSE-3 runs revealed three concrete compatibility classes.",
    )
    ax.set_axis_off()

    x0 = 0.03
    widths = [0.22, 0.31, 0.40]
    y = 0.62
    for name, count, fix, examples, color in rows:
        rounded_box(ax, (x0, y), (widths[0], 0.18), f"{name}\n{count} kernels", "#ffffff", color, fontsize=17, weight="bold")
        rounded_box(ax, (x0 + 0.24, y), (widths[1], 0.18), fix, "#ffffff", color, fontsize=12.5)
        rounded_box(ax, (x0 + 0.57, y), (widths[2], 0.18), examples, "#ffffff", color, fontsize=10.8)
        y -= 0.23
    ax.text(0.05, 0.83, "Class", fontsize=12, color=MUTED, fontweight="bold")
    ax.text(0.29, 0.83, "Required fix", fontsize=12, color=MUTED, fontweight="bold")
    ax.text(0.62, 0.83, "Examples", fontsize=12, color=MUTED, fontweight="bold")
    ax.text(
        0.08,
        0.08,
        "Takeaway: hardware execution is now available. The blocker moved from 'can we run?' to 'can we automate SDK-version porting?'",
        fontsize=13,
        color=INK,
        bbox=dict(boxstyle="round,pad=0.55", facecolor="#ecfeff", edgecolor="#99f6e4"),
    )
    footer(fig, "Source: HARDWARE_VALIDATION_20260706.md.")
    save(fig, "sdk210_porting_status")


def write_csv(path: Path, rows: list[dict[str, object]], headers: list[str]):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=headers)
        writer.writeheader()
        for row in rows:
            writer.writerow({h: row.get(h, "") for h in headers})


def write_markdown_table(path: Path, rows: list[dict[str, object]], headers: list[str]):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w") as f:
        f.write("| " + " | ".join(headers) + " |\n")
        f.write("|" + "|".join(["---"] * len(headers)) + "|\n")
        for row in rows:
            f.write("| " + " | ".join(str(row.get(h, "")) for h in headers) + " |\n")


def write_tables():
    model_rows = []
    for row in MODEL_ROWS:
        model_rows.append(
            {
                "Model": row["model"],
                "Type": row["type"],
                "Scope": row["scope"],
                "Pass": f"{row['pass']}/{row['total']}",
                "Rate": f"{pct(row):.0f}%",
                "Beats expert": row["beats_expert"],
            }
        )
    write_csv(TABLE_DIR / "cross_model_summary.csv", model_rows, list(model_rows[0].keys()))
    write_markdown_table(TABLE_DIR / "cross_model_summary.md", model_rows, list(model_rows[0].keys()))

    ablation_rows = [
        {
            "Configuration": "One-shot, no knowledge/repair/W2",
            "Pass": "6/28",
            "Rate": "21%",
            "Beats expert": 1,
            "Presentation note": "Raw model capability; five of six passes are parity/slower.",
        },
        {
            "Configuration": "Full agent stack, Opus 4.8",
            "Pass": "26/28",
            "Rate": "93%",
            "Beats expert": 16,
            "Presentation note": "Whole-system gain; not a component-wise causal ablation.",
        },
    ]
    write_csv(TABLE_DIR / "ablation_summary.csv", ablation_rows, list(ablation_rows[0].keys()))
    write_markdown_table(TABLE_DIR / "ablation_summary.md", ablation_rows, list(ablation_rows[0].keys()))

    hardware_rows = []
    for row in HARDWARE_ROWS:
        hardware_rows.append(
            {
                "Kernel": row["kernel"],
                "Simulator cycles": row["sim_cycles"],
                "Hardware cycles": row["hw_cycles"],
                "Delta": f"{row['delta_pct']:+.1f}%",
                "Reliability": row["reliability"],
            }
        )
    write_csv(TABLE_DIR / "hardware_validation.csv", hardware_rows, list(hardware_rows[0].keys()))
    write_markdown_table(TABLE_DIR / "hardware_validation.md", hardware_rows, list(hardware_rows[0].keys()))

    profiler_rows = [
        {
            "Kernel": row["kernel"],
            "Expert cycles": row["expert_cycles"],
            "Best previous": row["best_previous_cycles"],
            "Trace-profiled": row["trace_profiled_cycles"],
            "Improvement vs previous": f"{row['improvement_vs_previous_pct']}%",
            "Speedup vs expert": f"{row['speedup_vs_expert']:.2f}x",
        }
        for row in PROFILER_ROWS
    ]
    write_csv(TABLE_DIR / "profiler_feedback.csv", profiler_rows, list(profiler_rows[0].keys()))
    write_markdown_table(TABLE_DIR / "profiler_feedback.md", profiler_rows, list(profiler_rows[0].keys()))

    playbook_rows = [
        {
            "Profiler signal": row["signal"],
            "Bottleneck insight": row["diagnosis"],
            "CSL optimization/repair action": row["action"],
        }
        for row in PROFILER_PLAYBOOK_ROWS
    ]
    write_csv(TABLE_DIR / "profiler_bottleneck_playbook.csv", playbook_rows, list(playbook_rows[0].keys()))
    write_markdown_table(TABLE_DIR / "profiler_bottleneck_playbook.md", playbook_rows, list(playbook_rows[0].keys()))

    claims = [
        {
            "Slide claim": "Full xkernel stack reaches 26/28 pass on Opus 4.8.",
            "Evidence": "26/28 pass, 16 beats-expert wins.",
            "Caveat": "Single-draw full sweep; multi-seed robustness still incomplete.",
            "Source": "SWEEP_RESULTS_20260630.md",
        },
        {
            "Slide claim": "System adds 20 passing kernels over raw one-shot.",
            "Evidence": "6/28 one-shot vs 26/28 full stack.",
            "Caveat": "Whole-system ablation, not component-wise attribution.",
            "Source": "SESSION_PROGRESS_20260702.md",
        },
        {
            "Slide claim": "Open models still struggle with CSL generation.",
            "Evidence": "Open models range 0-8% on probes and 4-7% on full sweeps.",
            "Caveat": "Different model access and denominators; keep full/probe labels visible.",
            "Source": "SWEEP_RESULTS_20260630.md; SESSION_PROGRESS_20260702.md",
        },
        {
            "Slide claim": "Real WSE-3 hardware execution is now working.",
            "Evidence": "Reference kernels compile and run correctly on ALCF WSE-3.",
            "Caveat": "Some cycle readbacks are partial/suspicious; correctness is solid.",
            "Source": "HARDWARE_VALIDATION_20260706.md",
        },
        {
            "Slide claim": "Profiler feedback improves multi-PE optimization.",
            "Evidence": "Trace-profiled Jacobi improves 11%; GoL improves 28% vs previous best.",
            "Caveat": "Early evidence on two multi-PE kernels; expand to full suite.",
            "Source": "HARDWARE_VALIDATION_20260706.md; PROFILING_ARCHITECTURE.md",
        },
    ]
    write_csv(TABLE_DIR / "slide_claims_with_caveats.csv", claims, list(claims[0].keys()))
    write_markdown_table(TABLE_DIR / "slide_claims_with_caveats.md", claims, list(claims[0].keys()))


def write_readme():
    readme = OUT / "README.md"
    readme.write_text(
        """# xkernel PPT Asset Pack

Generated from the newer result and insight documents under `docs/`.

## Figures

- `figures/model_pass_rates.*` -- cross-model capability gap across 11 models.
- `figures/ablation_and_stack.*` -- one-shot vs full-stack correctness and W2 speedups.
- `figures/hardware_validation.*` -- simulator vs real WSE-3 cycle comparison.
- `figures/profiler_feedback.*` -- trace profiler feedback improving Jacobi and Game-of-Life.
- `figures/profiler_bottleneck_playbook.*` -- profiler signal to bottleneck/action mapping.
- `figures/agentic_workflow.*` -- slide diagram for the CUDA-to-CSL agent loop.
- `figures/sdk210_porting_status.*` -- SDK 2.10 hardware-porting compatibility classes.

Each figure is emitted as `.png`, `.pdf`, and `.svg`. Use PNG for quick PowerPoint
insertion and SVG/PDF when you want vector editing.

## Tables

- `tables/cross_model_summary.md` / `.csv`
- `tables/ablation_summary.md` / `.csv`
- `tables/hardware_validation.md` / `.csv`
- `tables/profiler_feedback.md` / `.csv`
- `tables/profiler_bottleneck_playbook.md` / `.csv`
- `tables/slide_claims_with_caveats.md` / `.csv`

## Suggested Slide Order

1. Start with `agentic_workflow` to explain the system.
2. Use `ablation_and_stack` for why the agentic stack matters.
3. Use `model_pass_rates` for the CSL capability gap.
4. Use `hardware_validation` to show real WSE-3 validation.
5. Use `profiler_feedback` to motivate feedback-agent upgrades.
6. Use `profiler_bottleneck_playbook` to explain how profiler information becomes action.
7. Use `sdk210_porting_status` for the next engineering frontier.

## Caveats To Say Out Loud

- Full-sweep and 12-kernel probe rates have different denominators.
- One-shot ablation is whole-system, not component-wise attribution.
- Hardware correctness is validated, but several hardware cycle measurements are
  marked partial because of timer/readback interpretation.
- Multi-seed robustness is not yet complete enough for aggregate publication claims.
""",
        encoding="utf-8",
    )


def main():
    plt.rcParams.update(
        {
            "font.family": "DejaVu Sans",
            "axes.titleweight": "bold",
            "axes.labelcolor": INK,
            "xtick.color": INK,
            "ytick.color": INK,
            "text.color": INK,
            "figure.facecolor": BG,
        }
    )
    FIG_DIR.mkdir(parents=True, exist_ok=True)
    TABLE_DIR.mkdir(parents=True, exist_ok=True)
    fig_model_pass_rates()
    fig_ablation_stack()
    fig_hardware_validation()
    fig_profiler_feedback()
    fig_profiler_bottleneck_playbook()
    fig_agentic_workflow()
    fig_porting_status()
    write_tables()
    write_readme()
    print(f"Wrote PPT assets to {OUT}")


if __name__ == "__main__":
    main()
