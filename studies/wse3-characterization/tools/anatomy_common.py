#!/usr/bin/env python3
"""Shared decoding for the anatomy pages: operand values per executed instruction,
typed rendering, wavelet field bits, and compiled route tables.

OPERAND VALUES.  `hwm_pipe_trace_entry` records at stage 6 (execute) carry the
operands the datapath actually used: `dest`, `src0`, `src1`, `src2` (0xFFFFFFFF =
not applicable), plus `data` = element index and `simdi` = SIMD lane for DSD
instructions, which emit ONE stage-6 record PER ELEMENT.  Stage-3 (decode) records
carry no values.  Checked against Cerebras's own decoder
(`SimfabInstructionTraceCtf.get_instruction_trace_at`): identical values, e.g.
`SUB16.NF dest=5555 src0=1234 src1=61215`.  Evidence: `simulator`.

WAVELET FIELDS.  The opaque 16-bit `fields` word of `wavelet_trace_entry` was
joined to csdb's `wavelet read-trace` rendering for 3,021 wavelets (0 mismatches):
bits 0-4 colour, bit 5 ctrl, bit 7 always set, bit 10 = on the PE's ramp (R),
otherwise bits 8-9 select the link {0: E, 1: N, 3: S}; bits 11-15 repeat the colour.
Link value 2 (W) was not observed and is inferred from the pattern.  Evidence:
`documented` by equivalence with the vendor tool.

ROUTES.  `cslc --out-routes` prints, per layout PE and colour, the receive side
(`rx`) and transmit side(s) (`tx`) among R (ramp), E, W, N, S, plus switch
positions.  `parse_routes` reads that table; coordinates are layout-relative and
`fabric_offsets` maps them to fabric coordinates.  Evidence: `compiled`.
"""
from __future__ import annotations
import gzip, json, re, struct
from pathlib import Path

SENTINEL = 0xFFFFFFFF

def f16(v):
    try: return struct.unpack("<e", struct.pack("<H", v & 0xFFFF))[0]
    except Exception: return None
def f32(v):
    try: return struct.unpack("<f", struct.pack("<I", v & 0xFFFFFFFF))[0]
    except Exception: return None
def i16(v): v &= 0xFFFF; return v - 0x10000 if v & 0x8000 else v
def i32(v): v &= 0xFFFFFFFF; return v - 0x100000000 if v & 0x80000000 else v

F16_OPS = ("faddh", "fsubh", "fmulh", "fmach", "fmovh", "fmaxh", "fminh", "fnegh", "fabsh", "fs2h")
F32_OPS = ("fadds", "fsubs", "fmuls", "fmacs", "fmovs", "fmaxs", "fmins", "fh2s", "fnegs", "fabss")
I32_OPS = ("ld32", "st32", "imov32", "add32", "sub32", "or32", "and32", "xor32", "eq32", "lt32", "ld16rp", "sll32", "slr32", "sar32")
DSR_OPS = ("lddwds", "lds0wds", "lds1wds", "ldsr", "ldxds")

AMB16_OPS = ("ld16", "st16", "fmov16", "imov16", "movri", "mov16")   # 16-bit moves: the bits carry no type

def kind_of(mnemonic: str) -> str:
    m = mnemonic.lower()
    if m.startswith(DSR_OPS): return "dsr"
    if m.startswith(F16_OPS): return "f16"
    if m.startswith(F32_OPS): return "f32"
    if m.startswith(I32_OPS): return "i32"
    if m.startswith(AMB16_OPS): return "amb16"
    return "i16"

def typed(kind: str, v, role: str = "dest") -> str:
    """Render one 32-bit trace value in the type the instruction implies."""
    if v is None or v == SENTINEL: return ""
    if kind == "dsr": return f"0x{v:08x}"
    if kind == "f16" or (kind == "f32" and role != "dest" and v <= 0xFFFF and False):
        return f"{f16(v):g} (0x{v & 0xFFFF:04x})"
    if kind == "f32": return f"{f32(v):g} (0x{v:08x})"
    if kind == "amb16": return f"0x{v & 0xFFFF:04x} (i16 {i16(v)} · f16 {f16(v):g})"
    if kind == "i32": return f"{i32(v)} (0x{v:08x})"
    return f"{i16(v)} (0x{v & 0xFFFF:04x})"

def typed_for(mnemonic: str, v, role: str = "dest") -> str:
    """fh2s reads f16 and writes f32; fs2h the reverse; everything else is one kind."""
    m = mnemonic.lower()
    if m.startswith("fh2s"): return typed("f16" if role != "dest" else "f32", v, role)
    if m.startswith("fs2h"): return typed("f32" if role != "dest" else "f16", v, role)
    return typed(kind_of(m), v, role)

def load_pipe(events: Path, tiles) -> dict:
    """(tile, uid) -> {'dec', 'exe', 'elems': [{cycle, idx, lane, dest, src0, src1, src2, cflag, imm}]}"""
    out = {}
    def val(x): return None if x in (None, SENTINEL) else x
    with gzip.open(events, "rt") as fh:
        for line in fh:
            if '"hwm_pipe_trace_entry"' not in line: continue
            e = json.loads(line); t = e.get("tile_index")
            if t not in tiles: continue
            k = (t, e["uid"]); r = out.setdefault(k, {"dec": None, "exe": None, "elems": []})
            st = e.get("stage"); c = e["cycle"]
            if st == 3: r["dec"] = c if r["dec"] is None else min(r["dec"], c)
            elif st == 6:
                r["exe"] = c if r["exe"] is None else min(r["exe"], c)
                d, s0, s1, s2 = (val(e.get(x)) for x in ("dest", "src0", "src1", "src2"))
                if any(v is not None for v in (d, s0, s1, s2)):
                    r["elems"].append({"cycle": c, "idx": e.get("data"), "lane": e.get("simdi"), "dest": d, "src0": s0, "src1": s1, "src2": s2,
                                       "cflag": None if e.get("cflag") in (None, 255) else e.get("cflag"), "imm": None if e.get("imm") in (None, 255) else e.get("imm")})
    for r in out.values():
        r["elems"].sort(key=lambda x: (x["cycle"], x["idx"] if isinstance(x["idx"], int) else 0))
    return out

LINK = {0: "E", 1: "N", 2: "W", 3: "S"}
def wavelet_fields(fields: int) -> dict:
    f = int(fields or 0)
    on_ramp = bool(f >> 10 & 1)
    return {"colour": f & 0x1F, "ctrl": bool(f >> 5 & 1), "link": "R" if on_ramp else LINK[(f >> 8) & 3],
            "link_evidence": "documented" if on_ramp or ((f >> 8) & 3) != 2 else "inferred", "colour_out": (f >> 11) & 0x1F}

def parse_routes(path: Path, fabric_offsets=(0, 0)) -> dict:
    """{(fabric_x, fabric_y): {colour: {'rx': 'R', 'tx': ['E'], 'sw': ['rx=R', '', '']}}} from `cslc --out-routes` text."""
    routes = {}; cur = None; ox, oy = fabric_offsets
    for line in Path(path).read_text().splitlines():
        if not line.startswith("|"): continue
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) < 4 or cells[1] in ("color", ""): 
            if len(cells) >= 4 and cells[1] == "color": continue
        if cells[0]:
            m = re.match(r"(\d+),(\d+)", cells[0])
            if not m: continue
            cur = (int(m.group(1)) + ox, int(m.group(2)) + oy); routes.setdefault(cur, {})
        if cur is None or not cells[1].isdigit(): continue
        routes[cur][int(cells[1])] = {"rx": cells[2], "tx": [t for t in cells[3].split(",") if t], "sw": cells[4:7]}
    return routes

# ---------------------------------------------------------------------------
# ORIGIN.  An instruction belongs to the application or to the <memcpy>/system
# runtime because of the source file its code came from -- never because a mnemonic
# or operand happened to decode.  Every PE's ELF contains both, so the disassembly
# is read whole and each PC is labelled; a PC absent from the ELF is "unknown" and
# stays visible rather than being dropped, because dropping it invents pipeline
# bubbles in any interval computed from the remaining stream.
RUNTIME_SRC = {"memcpy.csl", "memcpyh2d.csl", "memcpyd2h.csl", "sys.csl", "internal.csl",
               "tile_config.csl", "input_queue_config.csl", "layout.csl"}

def origin_of(basename: str, app_src: str = "pe.csl") -> str:
    if not basename: return "unclassified"
    if basename == app_src: return "application"
    if basename in RUNTIME_SRC: return "runtime"
    return "unclassified"

def load_disasm(fn, app_src: str = "pe.csl") -> dict:
    """pc -> {'text', 'source_file', 'origin'} for EVERY instruction in the ELF."""
    rows = json.loads(Path(fn).read_text()); rows = rows["records"] if isinstance(rows, dict) else rows
    out = {}
    for r in rows:
        base = (r.get("source_file") or "").split("/")[-1]
        out[r["pc"]] = {"text": r["instruction"], "source_file": base, "origin": origin_of(base, app_src)}
    return out

def completion(dispatch: int, x_last) -> int | None:
    """Verified completion latency: last execute record minus dispatch.

    This is the only boundary at which a result is known to exist.  The interval to a
    consumer's dispatch is NOT a latency -- an in-order machine dispatches the consumer
    as soon as it reaches the head of the stream, which can be well before the producer
    has executed (a DSD op's last element can execute after its consumer has dispatched).
    """
    return None if x_last is None or dispatch is None else x_last - dispatch


# ============================================================ code ladder: intent / C / CSL
# For each operation the anatomy pages dissect, the equivalent a C programmer would write, so
# the machine listing can be read without knowing CSL. `differs` is the point of the table: it
# names where the C form and the WSE form are NOT in correspondence. Empty `differs` means the
# lowering is one-to-one with the C.
LADDER = {
 # ---- microbench/atomic_add
 "scalar_i16": dict(intent="add two 16-bit integers in memory, store the sum",
   c="int16_t a[1], b[1], c[1];\nc[0] = a[0] + b[0];", differs=""),
 "scalar_f16": dict(intent="add two half-precision floats in memory, store the sum",
   c="_Float16 a[1], b[1], c[1];\nc[0] = a[0] + b[0];", differs=""),
 "dsd8": dict(intent="add eight half-precision elements pairwise",
   c="for (int i = 0; i < 8; i++)\n    c[i] = a[i] + b[i];",
   differs="The C loop's counter, bound test and branch have no counterpart. Three descriptors carry base, length and stride, and one instruction runs the whole loop in hardware."),
 "dsd16": dict(intent="add sixteen half-precision elements pairwise",
   c="for (int i = 0; i < 16; i++)\n    c[i] = a[i] + b[i];",
   differs="Same three descriptors and same single instruction as the 8-element form; only the length field changes."),
 "dsd64": dict(intent="add sixty-four half-precision elements pairwise",
   c="for (int i = 0; i < 64; i++)\n    c[i] = a[i] + b[i];",
   differs="Still one instruction. Its completion latency grows with the element count (8 lanes per 2 cycles), but the instruction count does not."),
 # ---- microbench/atomic_ops, arithmetic and logic
 "sub_i16": dict(intent="integer subtract", c="ci[0] = ai[0] - bi[0];", differs=""),
 "mul_i16": dict(intent="integer multiply", c="ci[1] = ai[0] * bi[0];",
   differs="No extra latency over an add at this level: `imul16` behaves like `add16`."),
 "mul_f16": dict(intent="half-precision multiply", c="cf[0] = af[0] * bf[0];", differs=""),
 "fma_f16": dict(intent="half-precision multiply then add",
   c="cf[1] = af[0] * bf[0] + af[1];",
   differs="A C compiler may contract this to one fused instruction. Here it did not: the scalar form is a multiply then a separate add, and the fused `fmach` exists only as a vector (DSD) instruction."),
 "and_i16": dict(intent="bitwise and", c="ci[2] = ai[0] & bi[0];", differs=""),
 "or_i16":  dict(intent="bitwise or",  c="ci[3] = ai[0] | bi[0];", differs=""),
 "xor_i16": dict(intent="bitwise exclusive or", c="ci[4] = ai[0] ^ bi[0];", differs=""),
 "shl_i16": dict(intent="shift left by a constant", c="ci[5] = ai[0] << 3;",
   differs="The shift amount is an instruction immediate, so no register holds it."),
 "shr_i16": dict(intent="arithmetic shift right by a constant", c="ci[6] = ai[0] >> 2;",
   differs="`sar16` keeps the sign, matching C's `>>` on a signed type."),
 # ---- control
 "br_taken": dict(intent="choose between two constants on a runtime comparison",
   c="if (ai[2] < bi[2]) ci[7] = 11;\nelse                ci[7] = 22;",
   differs="No branch is emitted. A compare writes a condition flag and a predicated move applies only if the flag allows, so both outcomes cost the same and no misprediction is possible."),
 "br_not": dict(intent="the same choice, with the comparison false",
   c="if (ai[3] < bi[3]) ci[8] = 11;\nelse                ci[8] = 22;",
   differs="Identical cost to the taken case, for the same reason: predication, not branching."),
 "loop2": dict(intent="accumulate over a run-time number of elements",
   c="for (uint16_t k = 0; k < bi[1]; k++)\n    ci[9] += ai[k];",
   differs="Here real jumps DO appear, because the bound is a run-time value the compiler cannot resolve. Each `jmp` has no execute record in the trace; where it resolves is not observed."),
 # ---- conversion
 "f16_to_f32": dict(intent="widen half to single precision", c="c32[0] = (float) af[0];",
   differs="One instruction, `fh2s`, into a 32-bit register pair."),
 "f32_to_f16": dict(intent="narrow single to half precision", c="cf[2] = (_Float16) a32[0];",
   differs="One instruction, `fs2h`."),
 # ---- memory movement through the DSD engine
 "dsd_fill8": dict(intent="fill eight elements with a constant",
   c="for (int i = 0; i < 8; i++)\n    c[i] = 1.5f;   /* like memset */",
   differs="A register broadcast into a destination stream: one descriptor, no source descriptor at all."),
 "dsd_copy8": dict(intent="copy eight elements",
   c="memcpy(c + 8, a, 8 * sizeof(_Float16));",
   differs="Two descriptors and one move instruction, whatever the length."),
 "dsd_stride2": dict(intent="copy every second element",
   c="for (int i = 0; i < 8; i++)\n    c[16 + i] = a[2 * i];",
   differs="The same instruction as the unit-stride copy. The stride lives in the descriptor, so a strided gather costs no extra instructions, only address-generator throughput."),
 "dsd_reduce8": dict(intent="sum eight elements into a scalar",
   c="_Float16 acc = 0;\nfor (int i = 0; i < 8; i++)\n    acc += a[i];",
   differs="A DSD op whose destination is a register rather than a stream. It is the one form where the element count shows up as latency, because each element depends on the last."),
 # ---- vector arithmetic
 "dsd_mulh8": dict(intent="multiply eight elements pairwise",
   c="for (int i = 0; i < 8; i++)\n    c[24 + i] = a[i] * b[i];", differs=""),
 "dsd_fmach8": dict(intent="fused multiply-add over eight elements against a scalar",
   c="for (int i = 0; i < 8; i++)\n    c[32 + i] = a[i] + b[i] * 0.5f;",
   differs="This is the fused form the scalar case could not reach; the multiplier comes from a register."),
 "dsd_add16x8": dict(intent="add eight 16-bit integers pairwise",
   c="for (int i = 0; i < 8; i++)\n    ic8[i] = ia8[i] + ib8[i];", differs=""),
 "dsd_fadds8": dict(intent="add eight single-precision floats pairwise",
   c="for (int i = 0; i < 8; i++)\n    c32[8 + i] = a32[i] + b32[i];",
   differs="Same shape as the half-precision form; single precision halves the lane throughput."),
}

# The fabric primitive has no C equivalent at all, so it gets a message-passing analogue.
FABRIC_LADDER = dict(
 intent="move eight words from one processing element to its neighbour",
 c="/* sender */                              /* receiver */\n"
   "MPI_Send(buf, 8, MPI_FLOAT,               MPI_Recv(buf, 8, MPI_FLOAT,\n"
   "         east, tag, comm);                         west, tag, comm, &st);",
 differs="There is no send instruction and no receive instruction. Both sides issue an ordinary "
         "DSD copy; what makes one a send is that its destination descriptor names a fabric output "
         "queue, and what makes the other a receive is that its source descriptor names an input "
         "queue. The receiver's copy is dispatched before any data exists and the trace records it dispatched "
         "again when the first wavelet arrives: it waits, the way a blocking load would.")

SCENE_LADDER = {
 "relay": FABRIC_LADDER,
 "ops": dict(intent="run 22 basic operations once each, as the compiler scheduled them",
   c="/* the whole basic set, back to back */\nci[0] = ai[0] - bi[0];\nci[1] = ai[0] * bi[0];\ncf[0] = af[0] * bf[0];\n/* ... 19 more, see the ISA page ... */",
   differs="The compiler is free to reorder these: it loads the two operands once and feeds seven "
           "integer operations from them, so the instructions do not appear in source order."),
 "ops_optnone": dict(intent="the same 22 operations with optimisation disabled per function",
   c="/* identical C; compiled with function-local\n   optnone: most LLVM optimisations off */",
   differs="Now each operation is exactly its own loads, operation and store, in source order. "
           "The isolation costs 267 cycles against 171 for the optimised build, measured from the first marker's dispatch to the END marker's dispatch."),
}

def ladder(name):
    """Intent, C equivalent and divergence note for one dissected operation, or None."""
    return LADDER.get(name)
