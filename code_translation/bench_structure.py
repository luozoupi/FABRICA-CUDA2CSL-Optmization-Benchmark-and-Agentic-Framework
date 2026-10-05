"""Bench-structure scanner: discover what the LLM can actually edit.

The optimization loop today hands the LLM a single compute file and asks
it to reduce cycles_send. For "shell" kernels (BiCGSTAB, CG, PCG, Power
Method) the compute file is an orchestration dispatcher and the real
hot loops live in imported CSL modules (blas.csl, the shared
benchmark-libs/stencil_3d_7pts/, the shared benchmark-libs/allreduce/).
The optimizer is blind to those imports — that's why those kernels are
0/15+ accepts.

This module solves the "blind to where compute lives" problem WITHOUT
hardcoding any kernel-specific assumptions. It walks the bench dir,
parses every `@import_module(...)` in the root compute file, classifies
each import as stdlib (`<angle-bracketed>`, not editable) or local
(relative path, IS editable), resolves the local ones to absolute
paths, and computes an arithmetic-density score per editable file.

Output is a `BenchStructure` dataclass the planner (Piece 2) consumes.
Pure-code, no LLM calls, no flags. Identifies thin-dispatcher kernels
automatically by density threshold (root <2% suggests the real work is
elsewhere).
"""

from __future__ import annotations

import argparse
import json
import logging
import os
import re
import sys
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple

logger = logging.getLogger("bench_structure")


# ---------------------------------------------------------------------------
# Import-string parser
# ---------------------------------------------------------------------------
#
# @import_module accepts one string argument: either an angle-bracketed
# stdlib name (`<time>`, `<math>`, `<memcpy/memcpy>`, `<collectives_2d/pe>`)
# or a quoted relative path (`"blas.csl"`, `"../../benchmark-libs/.../pe.csl"`).
# The struct arg that may follow is comptime params, not part of the import.
# We split on the leading char of the string body to discriminate.

# Matches `@import_module("STRING"...)` or `@import_module( "STRING" ...)`.
# Captures STRING — quotes stripped. Handles spaces around args and the
# optional comma+struct that may follow.
_IMPORT_RE = re.compile(
    r"@import_module\s*\(\s*['\"]([^'\"]+)['\"]"
)


def parse_imports(csl_text: str) -> List[str]:
    """Return every import target string from a CSL source. Order matches
    the source. Duplicates are kept — a kernel can legitimately import the
    same module twice with different params (mpi_x / mpi_y pattern)."""
    if not csl_text:
        return []
    return [m.group(1) for m in _IMPORT_RE.finditer(csl_text)]


def is_stdlib_import(target: str) -> bool:
    """Stdlib imports are angle-bracketed (e.g. `<time>`, `<memcpy/memcpy>`).
    Anything else — bare filename, relative path — is a local editable
    module the LLM is allowed to modify.

    Note: the angle-bracket convention is the actual CSL compiler
    convention for resolving via CSL_IMPORT_PATH vs. resolving relative
    to the current file. We use the same discriminator the compiler uses
    so our classification matches what's actually editable on disk.
    """
    return target.startswith("<") and target.endswith(">")


def resolve_local_import(target: str, from_file: Path) -> Optional[Path]:
    """Resolve a non-stdlib import target to an absolute Path on disk,
    relative to the importing file. Returns None when the target doesn't
    resolve to an existing file (e.g. the path is wrong, or the import
    is via CSL_IMPORT_PATH that we can't reproduce without invoking the
    compiler). The caller treats None as "not editable" rather than an
    error so the scanner stays best-effort.

    Path.resolve() is too aggressive: it collapses ``src/../../foo`` by
    physical-path semantics, but the CSL compiler resolves it
    LEXICALLY (the way the cslc tool resolves CSL_IMPORT_PATH).
    Concretely, for kernel files at ``kernels/<K>/CSL/src/kernel_*.csl``
    importing ``../../benchmark-libs/.../pe.csl``, .resolve() walks
    `src/../../benchmark-libs` to `kernels/<K>/benchmark-libs` — the
    wrong place. We do lexical normalization (Path with .. stripped)
    and check both that AND .resolve() before giving up.
    """
    if is_stdlib_import(target):
        return None
    base = from_file.parent
    raw = base / target
    # Lexical normalization without collapsing symlinks.
    lex_parts: List[str] = []
    for part in raw.parts:
        if part == "..":
            if lex_parts and lex_parts[-1] not in (".", ".."):
                lex_parts.pop()
            else:
                lex_parts.append("..")
        elif part != ".":
            lex_parts.append(part)
    lex = Path(*lex_parts) if lex_parts else raw
    if lex.is_file():
        return lex
    # Fallback to .resolve() in case the bench uses symlinks.
    real = raw.resolve()
    if real.is_file():
        return real
    # Fallback to the xkernel benchmark-libs convention: at runtime,
    # benchmark_csl._stage_benchmark_libs copies kernels/benchmark-libs/
    # alongside the staged bundle so `../../benchmark-libs/...` resolves
    # to the staged copy. On the source tree the same path is broken
    # (kernels/<K>/CSL/src/../../benchmark-libs lands at
    # kernels/<K>/benchmark-libs, which doesn't exist). When we see a
    # benchmark-libs/ segment in an unresolved target, retry against
    # kernels/benchmark-libs/.
    if "benchmark-libs" in target:
        # Find the kernels/ root by walking up from from_file.
        for ancestor in from_file.parents:
            kernels_root = ancestor / "kernels"
            if kernels_root.is_dir():
                # The target is .../benchmark-libs/<rest>; extract <rest>
                # and look it up under kernels/benchmark-libs/.
                m = re.search(r"benchmark-libs/(.*)$", target)
                if m:
                    candidate = kernels_root / "benchmark-libs" / m.group(1)
                    if candidate.is_file():
                        return candidate
                break
    return None


# ---------------------------------------------------------------------------
# Arithmetic-density scorer
# ---------------------------------------------------------------------------
#
# Density = (lines that contain real arithmetic) / (non-blank non-comment).
# "Real arithmetic" is broader than just the @fmacs family because some
# CSL libraries (notably blas.csl) implement their reductions as a
# small scalar `fn` body that's then dispatched via @map(...) — the
# scalar fn has no @fmacs but contains `xval * yval`, `sum.* + ...`.
# We count those scalar arithmetic operators alongside the DSD-level
# intrinsics so blas.csl shows up as compute-dense, not orchestration.
#
# Three classes contribute:
#   1. DSD-level compute intrinsics: @fmacs, @fadds, @fmuls, @fmovs, @fsubs
#   2. @map dispatchers (route to a scalar fn in this file)
#   3. Scalar arithmetic in lines that contain `* `, ` + `, ` - `, ` / `
#      between identifiers — guarded against false positives from index
#      arithmetic by requiring the line to also reference an f32/f16
#      variable name OR be inside a fn body. We check #3 only when #1
#      and #2 are absent on a line, and only count it as "compute" if
#      the file declares fn bodies with floating-point return types.

_COMPUTE_INTRINSICS = re.compile(r"@(?:fmac[sh]?|fadd[sh]?|fmul[sh]?|fmov[sh]?|fsub[sh]?|map)\b")
_FLOAT_FN_RE = re.compile(r"\bfn\s+\w+\s*\([^)]*\)\s*(?:f16|f32|f64)\s*\{")
# Scalar arithmetic: line contains a binary op surrounded by identifier
# / paren / numeric context AND no comment-only marker.
_SCALAR_ARITH_RE = re.compile(
    r"(?<!\w)(?:[A-Za-z_][\w.\[\]]*|\)|\d)\s*[*/+\-]\s*(?:[A-Za-z_][\w.\[\]*]*|\(|\d)"
)
_COMMENT_LINE_RE = re.compile(r"^\s*(?://|/\*|\*|$)")


@dataclass
class FileStats:
    """Per-file structural numbers."""
    path: str                # absolute path
    relpath: str             # relative to the bench root (or empty if outside)
    loc: int                 # total line count
    code_loc: int            # non-blank, non-comment lines
    compute_loc: int         # lines containing a compute intrinsic
    density: float           # compute_loc / max(code_loc, 1)

    @property
    def is_thin_dispatcher(self) -> bool:
        """Density < 2% AND the file has at least 50 lines of code — small
        files (<50 LOC) are too noisy for density to be meaningful."""
        return self.code_loc >= 50 and self.density < 0.02


def compute_density(csl_text: str) -> Tuple[int, int, int, float]:
    """Return (loc, code_loc, compute_loc, density).

    code_loc excludes blank and pure-comment lines (`//`, `/*`, `*`).
    Lines with code AND a trailing comment count as code.

    A line counts toward compute_loc when:
      (a) it matches the DSD-intrinsic regex (@fmacs, @fadds, @map, ...),
          OR
      (b) the file defines at least one fn returning a float, AND the
          line is inside a fn body, AND it contains a scalar arithmetic
          op (* + - /) in an expression context (not just `i*Nt` index
          math). This catches blas.csl-style scalar reductions where
          the work is `sum + xval * yval` inside a `fn reduce_dot(...)
          f32`.
    """
    if not csl_text:
        return 0, 0, 0, 0.0
    lines = csl_text.splitlines()
    loc = len(lines)
    # First pass: does this file declare any float-returning fns? If yes,
    # turn on scalar-arithmetic counting; otherwise stay strict on
    # DSD intrinsics only (avoids false positives from header-style files
    # with #define arithmetic in comments).
    float_fns = bool(_FLOAT_FN_RE.search(csl_text))
    code_loc = 0
    compute_loc = 0
    in_fn_body = False
    brace_depth = 0
    for ln in lines:
        if _COMMENT_LINE_RE.match(ln):
            continue
        code_loc += 1
        # Fn-body tracking (simple brace counter; good enough for CSL).
        if not in_fn_body:
            if _FLOAT_FN_RE.search(ln):
                in_fn_body = True
                brace_depth = ln.count("{") - ln.count("}")
                if brace_depth <= 0 and "{" in ln:
                    brace_depth = 1
        else:
            brace_depth += ln.count("{") - ln.count("}")
            if brace_depth <= 0:
                in_fn_body = False
        if _COMPUTE_INTRINSICS.search(ln):
            compute_loc += 1
            continue
        if float_fns and in_fn_body and _SCALAR_ARITH_RE.search(ln):
            # Exclude pure index-arithmetic lines (i*Nt + 1 with no
            # f32 context). Heuristic: if the line has no identifier
            # that looks like a value (xval, sum, yval, mantissa, etc),
            # skip it. Cheap proxy: require at least one of *, +, - to
            # appear OUTSIDE square brackets (i.e. not inside [...]).
            stripped = re.sub(r"\[[^\]]*\]", "", ln)
            if _SCALAR_ARITH_RE.search(stripped):
                compute_loc += 1
    density = (compute_loc / code_loc) if code_loc else 0.0
    return loc, code_loc, compute_loc, density


def stat_file(path: Path, bench_root: Optional[Path] = None) -> FileStats:
    """Compute structural stats for one CSL file.

    relpath is the path RELATIVE TO bench_root using os.path.relpath
    (so files outside bench_root come back as ``../../foo/bar.csl``
    rather than absolute paths). This keeps planner output uniform —
    every file the planner can reference is identified by the same
    relpath form the @import_module statement would use, which makes
    the planner's focus_files list machine-checkable against the
    file's import target.
    """
    text = path.read_text(encoding="utf-8", errors="ignore")
    loc, code_loc, compute_loc, density = compute_density(text)
    relpath = str(path)
    if bench_root:
        try:
            relpath = os.path.relpath(str(path), str(bench_root))
        except ValueError:
            # Different drive on Windows; absolute path is the best we can do.
            relpath = str(path)
    return FileStats(
        path=str(path),
        relpath=relpath,
        loc=loc,
        code_loc=code_loc,
        compute_loc=compute_loc,
        density=round(density, 4),
    )


# ---------------------------------------------------------------------------
# Bench-level scanner
# ---------------------------------------------------------------------------

@dataclass
class BenchStructure:
    """Snapshot of a bench's editable surface area, used by the planner
    to decide which files to expose to the LLM in each optimization round.
    """
    bench_root: str               # absolute path to the CSL/ dir
    root_compute: FileStats       # the file _find_compute_file picked
    editable_modules: List[FileStats] = field(default_factory=list)
    stdlib_imports: List[str] = field(default_factory=list)
    unresolved_imports: List[str] = field(default_factory=list)
    # Transitive: imports of imports. Same classification rules. The
    # planner uses these to identify deeply-nested compute (e.g.
    # benchmark-libs/stencil_3d_7pts/pe.csl re-imports its wse3/pe.csl).
    transitive_modules: List[FileStats] = field(default_factory=list)

    @property
    def root_is_thin_dispatcher(self) -> bool:
        return self.root_compute.is_thin_dispatcher

    @property
    def total_editable_loc(self) -> int:
        return (self.root_compute.code_loc
                + sum(m.code_loc for m in self.editable_modules)
                + sum(m.code_loc for m in self.transitive_modules))

    @property
    def total_editable_compute_loc(self) -> int:
        return (self.root_compute.compute_loc
                + sum(m.compute_loc for m in self.editable_modules)
                + sum(m.compute_loc for m in self.transitive_modules))

    @property
    def aggregate_density(self) -> float:
        """Density across root + all editable modules combined. A thin-
        dispatcher root with a high-density library will register a low
        ROOT density but a higher aggregate — that's the signal that
        opening the library to the LLM is worthwhile."""
        total = self.total_editable_loc
        return round(self.total_editable_compute_loc / max(total, 1), 4)

    def to_dict(self) -> Dict:
        d = asdict(self)
        d["root_is_thin_dispatcher"] = self.root_is_thin_dispatcher
        d["total_editable_loc"] = self.total_editable_loc
        d["total_editable_compute_loc"] = self.total_editable_compute_loc
        d["aggregate_density"] = self.aggregate_density
        return d


def scan_bench(bench_csl_dir: str | Path,
               root_compute_relpath: str,
               max_transitive_depth: int = 2) -> BenchStructure:
    """Scan a bench directory and return its editable structure.

    bench_csl_dir is the CSL/ dir (e.g. kernels/BiCGSTAB/CSL/).
    root_compute_relpath is the relpath of the file the orchestrator's
    `_find_compute_file` picked (e.g. "src/kernel_bicgstab.csl" or
    "pe.csl").

    Transitive resolution walks imports of imports up to
    max_transitive_depth (default 2 — enough to reach the
    benchmark-libs/stencil_3d_7pts/wse3/pe.csl from the bench's
    src/kernel_*.csl in one hop).
    """
    bench_root = Path(bench_csl_dir).resolve()
    root_path = (bench_root / root_compute_relpath).resolve()
    if not root_path.is_file():
        raise FileNotFoundError(
            f"root compute file does not exist: {root_path}"
        )

    root_stats = stat_file(root_path, bench_root)
    root_text = root_path.read_text(encoding="utf-8", errors="ignore")
    raw_imports = parse_imports(root_text)

    stdlib: List[str] = []
    unresolved: List[str] = []
    editable: List[FileStats] = []
    editable_paths: Set[Path] = set()

    for t in raw_imports:
        if is_stdlib_import(t):
            if t not in stdlib:
                stdlib.append(t)
            continue
        resolved = resolve_local_import(t, root_path)
        if resolved is None:
            if t not in unresolved:
                unresolved.append(t)
            continue
        # Skip when the import is the root itself (some kernels do this
        # for layout/launch re-use) — we already have stats for root.
        if resolved == root_path:
            continue
        if resolved in editable_paths:
            continue
        editable_paths.add(resolved)
        editable.append(stat_file(resolved, bench_root))

    # Transitive walk: same rules, applied to each editable's imports,
    # but skip anything we've already classified (root + first-level
    # editable).
    transitive: List[FileStats] = []
    transitive_paths: Set[Path] = set()
    frontier = list(editable_paths)
    seen_paths: Set[Path] = {root_path} | set(editable_paths)
    for depth in range(max_transitive_depth):
        if not frontier:
            break
        next_frontier: List[Path] = []
        for f in frontier:
            text = f.read_text(encoding="utf-8", errors="ignore")
            for t in parse_imports(text):
                if is_stdlib_import(t):
                    if t not in stdlib:
                        stdlib.append(t)
                    continue
                resolved = resolve_local_import(t, f)
                if resolved is None:
                    if t not in unresolved:
                        unresolved.append(t)
                    continue
                if resolved in seen_paths or resolved in transitive_paths:
                    continue
                transitive_paths.add(resolved)
                seen_paths.add(resolved)
                transitive.append(stat_file(resolved, bench_root))
                next_frontier.append(resolved)
        frontier = next_frontier

    return BenchStructure(
        bench_root=str(bench_root),
        root_compute=root_stats,
        editable_modules=editable,
        stdlib_imports=stdlib,
        unresolved_imports=unresolved,
        transitive_modules=transitive,
    )


# ---------------------------------------------------------------------------
# CLI for ad-hoc inspection
# ---------------------------------------------------------------------------

def _print_human(struct: BenchStructure) -> None:
    print(f"\nbench_root: {struct.bench_root}")
    rc = struct.root_compute
    flag = " [THIN-DISPATCHER]" if struct.root_is_thin_dispatcher else ""
    print(f"\nROOT compute  : {rc.relpath}  loc={rc.loc} "
          f"code={rc.code_loc} compute={rc.compute_loc} "
          f"density={rc.density:.1%}{flag}")
    if struct.editable_modules:
        print(f"\nEDITABLE imports ({len(struct.editable_modules)}):")
        for m in struct.editable_modules:
            print(f"  {m.relpath:<60} "
                  f"loc={m.loc:>4} code={m.code_loc:>4} "
                  f"compute={m.compute_loc:>3} density={m.density:.1%}")
    else:
        print("\nEDITABLE imports: (none — root is self-contained)")
    if struct.transitive_modules:
        print(f"\nTRANSITIVE modules ({len(struct.transitive_modules)}):")
        for m in struct.transitive_modules:
            print(f"  {m.relpath:<60} "
                  f"loc={m.loc:>4} code={m.code_loc:>4} "
                  f"compute={m.compute_loc:>3} density={m.density:.1%}")
    print(f"\nstdlib imports ({len(struct.stdlib_imports)}): "
          f"{struct.stdlib_imports}")
    if struct.unresolved_imports:
        print(f"unresolved imports ({len(struct.unresolved_imports)}): "
              f"{struct.unresolved_imports}")
    print(f"\nAggregate: editable_loc={struct.total_editable_loc} "
          f"editable_compute_loc={struct.total_editable_compute_loc} "
          f"aggregate_density={struct.aggregate_density:.1%}")


def main() -> int:
    p = argparse.ArgumentParser(
        description="Scan a kernel bench's editable structure.",
    )
    p.add_argument("--bench", required=False,
                   help="Path to a CSL/ dir (e.g. kernels/BiCGSTAB/CSL).")
    p.add_argument("--target-relpath", default=None,
                   help="Compute-file relpath inside the bench. Default: "
                        "auto-pick via optimize_explore._find_compute_file.")
    p.add_argument("--audit-all", action="store_true",
                   help="Scan every kernel under kernels/ — useful for "
                        "quickly seeing which are dispatchers.")
    p.add_argument("--json", action="store_true",
                   help="Emit JSON instead of human-readable text.")
    p.add_argument("--depth", type=int, default=2,
                   help="Transitive import walk depth (default 2).")
    args = p.parse_args()

    if args.audit_all:
        return _audit_all_kernels(emit_json=args.json, depth=args.depth)

    if not args.bench:
        p.error("--bench is required unless --audit-all is set")

    bench = Path(args.bench).expanduser().resolve()
    if (bench / "CSL").is_dir():
        bench = bench / "CSL"
    relpath = args.target_relpath
    if not relpath:
        # Lazy import to avoid cycle when bench_structure is imported by
        # optimize_explore itself.
        sys.path.insert(0, str(Path(__file__).parent))
        from optimize_explore import _find_compute_file  # type: ignore
        relpath = _find_compute_file(bench)
        if not relpath:
            print(f"could not auto-pick compute file in {bench}; "
                  "pass --target-relpath PATH")
            return 1
    struct = scan_bench(bench, relpath, max_transitive_depth=args.depth)
    if args.json:
        print(json.dumps(struct.to_dict(), indent=2))
    else:
        _print_human(struct)
    return 0


def _audit_all_kernels(emit_json: bool = False, depth: int = 2) -> int:
    """Scan every kernel under kernels/ and print a one-line summary
    per kernel. Useful as a smoke test of the scanner + a fast snapshot
    of which kernels are dispatchers vs self-contained."""
    sys.path.insert(0, str(Path(__file__).parent))
    from optimize_explore import _find_compute_file  # type: ignore

    kernels_root = Path(__file__).resolve().parents[1] / "kernels"
    if not kernels_root.is_dir():
        print(f"kernels dir not found: {kernels_root}")
        return 1
    rows = []
    for kdir in sorted(kernels_root.iterdir()):
        if not kdir.is_dir() or kdir.name.startswith((".", "_")):
            continue
        bench = kdir / "CSL" if (kdir / "CSL").is_dir() else kdir
        if not bench.is_dir():
            continue
        relpath = _find_compute_file(bench)
        if not relpath:
            rows.append({"kernel": kdir.name, "status": "no_compute_file"})
            continue
        try:
            struct = scan_bench(bench, relpath, max_transitive_depth=depth)
        except Exception as exc:
            rows.append({"kernel": kdir.name, "status": f"scan_error: {exc}"})
            continue
        rows.append({
            "kernel": kdir.name,
            "status": "ok",
            "root": struct.root_compute.relpath,
            "root_density": struct.root_compute.density,
            "root_code_loc": struct.root_compute.code_loc,
            "thin_dispatcher": struct.root_is_thin_dispatcher,
            "n_editable": len(struct.editable_modules),
            "n_transitive": len(struct.transitive_modules),
            "aggregate_density": struct.aggregate_density,
            "editable_compute_loc": struct.total_editable_compute_loc,
        })

    if emit_json:
        print(json.dumps(rows, indent=2))
        return 0

    # Pretty table.
    print(f"\n{'kernel':<28} {'root_density':>12} {'code_loc':>9} "
          f"{'n_edit':>7} {'agg_dens':>9} {'thin?':>6}")
    print("-" * 84)
    for r in rows:
        if r["status"] != "ok":
            print(f"  {r['kernel']:<28} {r['status']}")
            continue
        flag = " ✓" if r["thin_dispatcher"] else ""
        print(f"  {r['kernel']:<28} "
              f"{r['root_density']:>11.1%} "
              f"{r['root_code_loc']:>9} "
              f"{r['n_editable']:>7} "
              f"{r['aggregate_density']:>8.1%} "
              f"{flag:>6}")
    print()
    print(f"  {'thin?'} column: ✓ = root has <2% arithmetic density "
          "+ ≥50 LOC (planner should open editable imports)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
