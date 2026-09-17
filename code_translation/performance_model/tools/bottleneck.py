#!/usr/bin/env python3
"""Attribute a kernel's cycles to a bottleneck class, from measured hardware models.

Combines three measured artefacts:
  * the instruction mix          (isa_probe.py -- what the core actually issued)
  * the PE layout and routing    (fabric_probe.py -- where data moved)
  * the silicon cost models      (single-PE throughput, fabric latency)

and emits a diagnosis that names the *class* of fix worth trying, rather than a
generic "compute vs memory" label.

The three discriminators, all cheap to compute and all measured rather than assumed:

  IPC       dispatches on the busiest PE / total cycle span.
            1.0 = issuing every cycle. Below ~0.35 the core is waiting, so the fix
            is overlap (microthreads, async DSDs), not fewer instructions.

  float %   share of issued instructions that are floating-point arithmetic.
            Below ~8% there is almost no math to speed up; the instruction budget
            is going to addressing and control.  NOTE this counts *dispatches*, so
            a vectorised kernel looks arithmetic-poor -- always read it next to
            elements/dispatch before concluding "vectorise".

  el/disp   mean elements covered per dispatched instruction.  >~4 means the code
            already issues wide DSD work, so "vectorise it" is not the advice --
            WaferLLM's MeshGEMV runs 16-wide FMAs and still reads as 2.8% float.

  wav/disp  fabric wavelets per dispatched instruction. Above ~0.8 the kernel moves
            more data than it computes -- the fixed memcpy cost dominates and the
            answer is to make the kernel bigger, fuse it, or batch it.

Evidence: `simulator` for the traces, `silicon` for the cost-model constants.
"""
from __future__ import annotations

import argparse, json, glob, os, sys
from pathlib import Path

# --- silicon-measured constants (see the published readout) -------------------
FP16_FMA_ELEM_PER_CYC = 2.92     # measured on CS-3
FP32_FMA_ELEM_PER_CYC = 0.50
DSD_SETUP_CYCLES      = 16       # 15-17 across ops
FABRIC_CYC_PER_HOP    = 2.00
FABRIC_CYC_PER_WAVELET = 1.00
FABRIC_CYC_PER_TURN   = 20       # silicon (FINDINGS §4); the simulator-era fit was 33

IPC_STALL_THRESHOLD   = 0.35
FLOAT_PCT_THRESHOLD   = 8.0
WAV_PER_DISP_IO       = 0.8


def is_float(m: str) -> bool:
    b = m.split(".")[0].lower()
    return (b.startswith("f") and not b.startswith("fmov")) or b.startswith("xp162")


def analyse(isa_path: Path, fabric_path: Path | None = None) -> dict:
    """Path wrapper: read the isa_probe JSON (+ optional fabric_probe JSON and the
    runtime-model %bound next to it) and classify."""
    d = json.loads(isa_path.read_text())
    app_pes = None
    if fabric_path and fabric_path.exists():
        pes = json.loads(fabric_path.read_text())["pes"]
        app_pes = sum(1 for v in pes.values() if v.get("role") == "application")
    # Optimality gap from the runtime-model components, when they exist: the
    # lower bound is max(busiest link, E/N + 2L, FP floor) -- HPDC'24 style.
    rm = fabric_path.parent.parent / "runtime_model" / f"{isa_path.stem}.json" if fabric_path else None
    pct_bound = None
    if rm and rm.exists():
        pct_bound = json.loads(rm.read_text()).get("pct_of_bound")
    return analyse_docs(d, app_pes=app_pes, pct_bound=pct_bound, kernel=isa_path.stem)


def analyse_docs(d: dict, app_pes: int | None = None, pct_bound=None,
                 kernel: str = "") -> dict:
    """Classify from an already-loaded isa_probe document (importable API)."""
    span = d.get("cycle_span")
    cycles = (span[1] - span[0]) if span else 0
    tiles = d.get("tiles", {})
    # The busiest tile is the application PE. Averaging over tiles is wrong: the
    # memcpy infrastructure PEs dispatch a little and idle most of the run, which
    # drags a mean IPC down to a meaningless number.
    hot = max(tiles.values()) if tiles else d["counts"]["dispatch"]
    mix = {m["name"]: m["count"] for m in d["instruction_mix"]}
    total = sum(mix.values()) or 1
    float_pct = 100.0 * sum(c for m, c in mix.items() if is_float(m)) / total
    wav = d["counts"]["wavelet"]
    disp = max(d["counts"]["dispatch"], 1)
    ipc = hot / cycles if cycles else 0.0
    wpd = wav / disp
    el_per_disp = d.get("elements_per_dispatch", {}).get("mean_elements_per_dispatch", 1.0) or 1.0
    already_wide = el_per_disp >= 4.0
    # f16 arithmetic carries a 16-bit mnemonic marker (FMACH, FMOV16, FADDH...);
    # its presence means "move operands to f16" is advice the code has already taken.
    # f16 vs f32 arithmetic.  The discriminator is the operand-width suffix on the
    # *arithmetic* mnemonics (FMACH/FMULH = half, FMACS/FMULS = single).  Moves
    # (FMOV16/FMOV32) and converts (FS2XP16, FH2S) carry a width too but say
    # nothing about the precision the math runs at, so both are excluded.
    _mix = d.get("instruction_mix") or []
    _entries = _mix if isinstance(_mix, list) else [{"name": k, "count": v} for k, v in _mix.items()]
    f16_arith = f32_arith = 0
    for _e in _entries:
        _m = str(_e.get("name", "")).upper().split(".")[0]
        if not _m.startswith("F") or _m.startswith("FMOV") or "2" in _m:
            continue
        if _m.endswith("H"):
            f16_arith += int(_e.get("count", 0))
        elif _m.endswith("S"):
            f32_arith += int(_e.get("count", 0))
    _tot_arith = f16_arith + f32_arith
    f16_pct = 100.0 * f16_arith / _tot_arith if _tot_arith else 0.0
    already_f16 = f16_pct >= 50.0

    if wpd > WAV_PER_DISP_IO:
        cls, fix = "io_dominated", (
            "Fixed memcpy cost rules. Make the kernel bigger, fuse passes into one "
            "launch, or batch -- a 1-PE kernel already carries 23 infrastructure PEs.")
    elif ipc < IPC_STALL_THRESHOLD:
        cls, fix = "stalled", (
            "The core is waiting, not over-issuing. Overlap it: async DSDs on distinct "
            "microthreads (ut_id 0-7; the corpus uses at most 2), or break the "
            "dependency chain.")
    elif float_pct < FLOAT_PCT_THRESHOLD:
        cls = "overhead_bound"
        fix = ("Almost no arithmetic to speed up. Attack addressing and control: hoist "
               "comptime constants, chain DSD offsets, fix strides, specialise params.")
        fix += (" NOTE this code is ALREADY vectorised (%.1f elements/dispatch) -- do not "
                "read the low float%% as an invitation to vectorise; the budget is going "
                "to data movement, so target that." % el_per_disp) if already_wide else (
                " Vectorising will not help.")
    else:
        cls = "arithmetic_bound"
        spent = []
        if already_wide:
            spent.append(f"{el_per_disp:.1f} elements/dispatch")
        if already_f16:
            spent.append(f"{f16_pct:.0f}% of float arithmetic already f16")
        if spent:
            fix = (
                f"Real math in the instruction stream, but the width and precision levers "
                f"are already spent ({'; '.join(spent)}). Remaining headroom is occupancy, "
                f"not width: IPC is {ipc:.3f} against a 1.0 issue ceiling, so the gap is "
                f"stall -- look at dependency chains, microthread count, and fabric waits.")
        else:
            fix = (
                f"Real math in the instruction stream. Vectorise via DSD builtins and move "
                f"operands to f16: silicon gives {FP16_FMA_ELEM_PER_CYC}/cyc vs "
                f"{FP32_FMA_ELEM_PER_CYC}/cyc, a {FP16_FMA_ELEM_PER_CYC/FP32_FMA_ELEM_PER_CYC:.2f}x "
                f"ceiling. Keep vector length well above the {DSD_SETUP_CYCLES}-cycle DSD setup.")

    return {"kernel": kernel, "cycles": cycles, "hot_pe_dispatches": hot,
            "pct_of_lower_bound": pct_bound,
            "ipc": round(ipc, 3), "float_pct": round(float_pct, 1),
            "elements_per_dispatch": round(el_per_disp, 2), "already_vectorised": already_wide, "already_f16": already_f16,
            "f16_arith_pct": round(f16_pct, 1),
            "wavelets_per_dispatch": round(wpd, 2), "application_pes": app_pes,
            "bottleneck": cls, "recommended_fix": fix,
            "evidence": {"traces": "simulator", "cost_model": "silicon"}}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("results_dir", nargs="?",
                    default=str(Path(__file__).resolve().parent.parent / "results"),
                    help="directory holding isa-profiles/ and fabric-profiles/")
    ap.add_argument("--kernel", help="analyse just this kernel")
    ap.add_argument("--json", help="write results here")
    a = ap.parse_args()

    root = Path(a.results_dir)
    out = []
    for f in sorted((root / "isa-profiles").glob("*.json")):
        if a.kernel and f.stem != a.kernel:
            continue
        out.append(analyse(f, root / "fabric-profiles" / f.name))
    if not out:
        print("no isa-profiles found; run isa_probe.py first", file=sys.stderr)
        return 1

    order = {"arithmetic_bound": 0, "overhead_bound": 1, "stalled": 2, "io_dominated": 3}
    # Sub-group by advice, not just by class: two kernels can share a bottleneck
    # class and still need opposite advice (a 29-elements/dispatch f16 GEMM is
    # arithmetic-bound, but telling it to "vectorise" is wrong).
    out.sort(key=lambda r: (order.get(r["bottleneck"], 9), r["recommended_fix"], -r["cycles"]))
    print(f"{'kernel':<24}{'cycles':>8}{'IPC':>7}{'float%':>8}{'el/disp':>9}{'wav/disp':>9}{'%bound':>8}  bottleneck")
    last = None
    for r in out:
        key = (r["bottleneck"], r["recommended_fix"])
        if key != last:
            spent = r.get("already_vectorised") or r.get("already_f16")
            tag = " (width/precision levers already spent)" if spent else ""
            print(f"\n  -- {r['bottleneck'].replace('_',' ').upper()}{tag} --")
            print(f"     {r['recommended_fix']}\n")
            last = key
        print(f"{r['kernel']:<24}{r['cycles']:>8}{r['ipc']:>7.3f}"
              f"{r['float_pct']:>8.1f}{r['elements_per_dispatch']:>9.2f}"
              f"{r['wavelets_per_dispatch']:>9.2f}"
              f"{(str(r['pct_of_lower_bound']) + '%') if r.get('pct_of_lower_bound') is not None else '--':>8}")
    if a.json:
        Path(a.json).write_text(json.dumps(out, indent=1))
    return 0


if __name__ == "__main__":
    sys.exit(main())
