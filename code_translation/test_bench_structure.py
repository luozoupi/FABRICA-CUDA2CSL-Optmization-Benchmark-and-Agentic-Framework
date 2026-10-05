"""Smoke tests for bench_structure.py.

No LLM, no cslc. Pure unit tests of the import classifier, density
calculator, and bench-level scanner. Plus one integration smoke that
runs the audit across the live kernels/ tree and pins the four immune
linalg kernels as having ≥1 editable import (the signature the planner
will use to route them through the library-aware optimization path).
"""

from __future__ import annotations

import os
import shutil
import sys
import tempfile
import textwrap
import unittest
from pathlib import Path

_HERE = Path(__file__).resolve().parent
if str(_HERE) not in sys.path:
    sys.path.insert(0, str(_HERE))

import bench_structure as bs  # noqa: E402


REPO_ROOT = _HERE.parent
KERNELS = REPO_ROOT / "kernels"


# ---------------------------------------------------------------------------
# Import classifier
# ---------------------------------------------------------------------------

class ImportClassifierTests(unittest.TestCase):

    def test_angle_bracketed_is_stdlib(self) -> None:
        for name in ("<time>", "<math>", "<memcpy/memcpy>",
                     "<collectives_2d/pe>", "<dsd_ops>"):
            self.assertTrue(bs.is_stdlib_import(name),
                            f"expected stdlib: {name}")

    def test_bare_or_relative_is_editable(self) -> None:
        for name in ("blas.csl", "axpy.csl", "common.csl",
                     "src/kernel.csl",
                     "../../benchmark-libs/allreduce/pe.csl",
                     "hypersparse_spmv/pe.csl"):
            self.assertFalse(bs.is_stdlib_import(name),
                             f"expected editable: {name}")

    def test_parse_imports_extracts_all(self) -> None:
        src = textwrap.dedent('''
            const t = @import_module("<time>");
            const m = @import_module("<math>");
            const blas = @import_module("blas.csl");
            const memcpy = @import_module( "<memcpy/get_params>", .{ .width = 4 });
            const reduce_mod = @import_module( "../../benchmark-libs/allreduce/pe.csl",
                                                @concat_structs(rp, .{ .x = 1 }));
        ''')
        imports = bs.parse_imports(src)
        self.assertEqual(imports, [
            "<time>", "<math>", "blas.csl", "<memcpy/get_params>",
            "../../benchmark-libs/allreduce/pe.csl",
        ])

    def test_parse_imports_ignores_comments_lol_not_strict(self) -> None:
        # Best-effort: the regex doesn't strip comments. The current
        # implementation matches inside comments too, which we accept as
        # a false positive — better than missing real imports.
        src = '// const x = @import_module("commented.csl");\n'
        imports = bs.parse_imports(src)
        self.assertEqual(imports, ["commented.csl"])


# ---------------------------------------------------------------------------
# Lexical path resolution
# ---------------------------------------------------------------------------

class LexicalResolveTests(unittest.TestCase):

    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp(prefix="bench_struct_test_"))
        (self.tmp / "kernels" / "K1" / "CSL" / "src").mkdir(parents=True)
        (self.tmp / "kernels" / "benchmark-libs" / "allreduce").mkdir(parents=True)
        # Create the files the importer will look for.
        (self.tmp / "kernels" / "K1" / "CSL" / "src" / "kernel.csl").write_text(
            "// kernel\n", encoding="utf-8")
        (self.tmp / "kernels" / "K1" / "CSL" / "src" / "blas.csl").write_text(
            "// blas\n", encoding="utf-8")
        (self.tmp / "kernels" / "benchmark-libs" / "allreduce"
         / "pe.csl").write_text("// allreduce\n", encoding="utf-8")

    def tearDown(self) -> None:
        shutil.rmtree(self.tmp, ignore_errors=True)

    def test_sibling_import_resolves(self) -> None:
        from_file = self.tmp / "kernels" / "K1" / "CSL" / "src" / "kernel.csl"
        resolved = bs.resolve_local_import("blas.csl", from_file)
        self.assertEqual(resolved, from_file.parent / "blas.csl")

    def test_benchmark_libs_fallback(self) -> None:
        # The xkernel convention: kernels/<K>/CSL/src/kernel_*.csl
        # imports `../../benchmark-libs/...` which LEXICALLY resolves to
        # kernels/<K>/benchmark-libs (wrong) but the real file lives at
        # kernels/benchmark-libs (correct). The scanner's fallback path
        # should find it.
        from_file = self.tmp / "kernels" / "K1" / "CSL" / "src" / "kernel.csl"
        resolved = bs.resolve_local_import(
            "../../benchmark-libs/allreduce/pe.csl", from_file,
        )
        self.assertIsNotNone(resolved)
        self.assertEqual(resolved.name, "pe.csl")
        self.assertIn("benchmark-libs", str(resolved))

    def test_stdlib_returns_none(self) -> None:
        from_file = self.tmp / "kernels" / "K1" / "CSL" / "src" / "kernel.csl"
        self.assertIsNone(bs.resolve_local_import("<time>", from_file))

    def test_missing_file_returns_none(self) -> None:
        from_file = self.tmp / "kernels" / "K1" / "CSL" / "src" / "kernel.csl"
        self.assertIsNone(bs.resolve_local_import("doesnt_exist.csl", from_file))


# ---------------------------------------------------------------------------
# Density scorer
# ---------------------------------------------------------------------------

class DensityTests(unittest.TestCase):

    def test_dsd_intrinsics_count_as_compute(self) -> None:
        src = textwrap.dedent('''
            fn step() void {
                @fmacs(dst, dst, src, scale);
                @fadds(dst, dst, src);
                @fmovs(dst, src);
            }
        ''')
        loc, code, compute, density = bs.compute_density(src)
        self.assertEqual(compute, 3)
        self.assertGreater(density, 0.5)

    def test_scalar_arith_in_float_fn_counts(self) -> None:
        # The blas.csl pattern: scalar fn used via @map.
        src = textwrap.dedent('''
            fn reduce_dot(xval: f32, yval: f32, sum: *f32) f32 {
                return sum.* + xval * yval;
            }
        ''')
        loc, code, compute, density = bs.compute_density(src)
        # The `return` line has both * and + and lives in a float fn.
        self.assertGreaterEqual(compute, 1,
                                  f"expected scalar arith counted; got density={density}")

    def test_index_arith_doesnt_count(self) -> None:
        # Pure index math inside a non-float fn must NOT count.
        src = textwrap.dedent('''
            fn run() void {
                const i = j * Nt + k;
            }
        ''')
        loc, code, compute, density = bs.compute_density(src)
        self.assertEqual(compute, 0)

    def test_comments_excluded_from_code_loc(self) -> None:
        src = textwrap.dedent('''
            // pure comment line
            /* another comment */
            * leading-star line treated as comment
            fn run() void { @fmacs(d, d, s, 1.0); }
        ''')
        loc, code, compute, density = bs.compute_density(src)
        self.assertEqual(code, 1)
        self.assertEqual(compute, 1)
        self.assertEqual(density, 1.0)

    def test_empty_input(self) -> None:
        loc, code, compute, density = bs.compute_density("")
        self.assertEqual((loc, code, compute, density), (0, 0, 0, 0.0))


# ---------------------------------------------------------------------------
# Integration: scan_bench on synthetic + real kernels
# ---------------------------------------------------------------------------

class ScanBenchTests(unittest.TestCase):

    def test_self_contained_kernel_has_no_editable_imports(self) -> None:
        tmp = Path(tempfile.mkdtemp(prefix="self_contained_"))
        try:
            (tmp / "pe.csl").write_text(textwrap.dedent('''
                const m = @import_module("<memcpy/memcpy>", p);
                fn run() void { @fmacs(d, d, s, 1.0); }
            '''), encoding="utf-8")
            (tmp / "layout.csl").write_text("// l\n", encoding="utf-8")
            struct = bs.scan_bench(tmp, "pe.csl")
            self.assertEqual(struct.editable_modules, [])
            self.assertEqual(struct.stdlib_imports, ["<memcpy/memcpy>"])
        finally:
            shutil.rmtree(tmp, ignore_errors=True)

    def test_dispatcher_kernel_finds_sibling_blas(self) -> None:
        tmp = Path(tempfile.mkdtemp(prefix="dispatcher_"))
        try:
            (tmp / "src").mkdir()
            (tmp / "src" / "kernel.csl").write_text(textwrap.dedent('''
                const t = @import_module("<time>");
                const blas = @import_module("blas.csl");
                fn dispatch() void { blas.dot(1, x, y); }
            '''), encoding="utf-8")
            (tmp / "src" / "blas.csl").write_text(textwrap.dedent('''
                fn reduce_dot(xval: f32, yval: f32, sum: *f32) f32 {
                    return sum.* + xval * yval;
                }
                fn dot(n: i16, x: [*]f32, y: [*]f32) f32 {
                    var sum: f32 = 0.0;
                    @map(reduce_dot, mem_x_dsd, mem_y_dsd, &sum, &sum);
                    return sum;
                }
            '''), encoding="utf-8")
            struct = bs.scan_bench(tmp, "src/kernel.csl")
            self.assertEqual(len(struct.editable_modules), 1)
            self.assertEqual(struct.editable_modules[0].path.endswith(
                "src/blas.csl"), True)
            self.assertEqual(struct.stdlib_imports, ["<time>"])
        finally:
            shutil.rmtree(tmp, ignore_errors=True)


@unittest.skipUnless(KERNELS.is_dir(), "kernels/ tree not present in this env")
class LiveKernelAuditTests(unittest.TestCase):
    """Snapshot test against the actual kernels/ tree. Pins the
    structural signal we built the scanner to produce."""

    IMMUNE = ["BiCGSTAB", "Conjugate Gradient",
              "Preconditioned CG", "Power Method"]

    def _scan(self, name: str) -> bs.BenchStructure:
        bench = KERNELS / name / "CSL"
        # Pick compute file the same way optimize_explore does.
        from optimize_explore import _find_compute_file  # type: ignore
        relpath = _find_compute_file(bench)
        return bs.scan_bench(bench, relpath)

    def test_immune_kernels_have_editable_imports(self) -> None:
        for name in self.IMMUNE:
            with self.subTest(kernel=name):
                struct = self._scan(name)
                self.assertGreaterEqual(
                    len(struct.editable_modules), 1,
                    f"{name} should expose at least one editable library "
                    f"import (blas.csl + benchmark-libs/* expected). Got "
                    f"{struct.editable_modules}"
                )
                # All four should reference blas.csl at minimum.
                blas_present = any(
                    m.relpath.endswith("blas.csl")
                    for m in struct.editable_modules
                )
                self.assertTrue(blas_present,
                                f"{name} should expose blas.csl")

    def test_self_contained_winning_kernels_have_no_editable_imports(self) -> None:
        # Cholesky / Laplacian2D-Halo / Game of Life / GEMM Collectives 2D
        # all import only memcpy/layout/collectives infrastructure. The
        # scanner must NOT flag them as having editable imports — that's
        # the planner's signal to keep behaviour unchanged on these.
        for name in ("Cholesky", "Laplacian2D-Halo", "Game of Life",
                     "GEMM Collectives 2D"):
            with self.subTest(kernel=name):
                struct = self._scan(name)
                self.assertEqual(
                    struct.editable_modules, [],
                    f"{name} should have no editable imports (kernel is "
                    f"self-contained); got {[m.relpath for m in struct.editable_modules]}"
                )


if __name__ == "__main__":
    unittest.main(verbosity=2)
