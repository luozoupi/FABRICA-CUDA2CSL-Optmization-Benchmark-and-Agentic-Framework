"""The shared sparse-input module: Matrix Market reading, generators, the seed -> matrix
contract, padding/partitioning, structure features, keys and the readout."""
import json
import os
import tempfile
import unittest
from pathlib import Path

import numpy as np

import sparse_inputs as si

HERE = Path(__file__).resolve().parent
REPO = HERE.parent


def tiny_csr():
    #   [1 2 0 0]
    #   [0 3 0 0]
    #   [4 0 5 6]
    #   [0 0 0 7]
    return si.from_coo(4, 4, [0, 0, 1, 2, 2, 2, 3], [0, 1, 1, 0, 2, 3, 3], [1, 2, 3, 4, 5, 6, 7])


class CsrTests(unittest.TestCase):
    def test_from_coo_sorts_and_sums_duplicates(self):
        c = si.from_coo(2, 2, [1, 0, 0], [0, 1, 1], [5.0, 1.0, 2.0])
        self.assertEqual(c.nnz, 2)
        np.testing.assert_array_equal(c.row_ptr, [0, 1, 2])
        np.testing.assert_array_equal(c.col, [1, 0])
        np.testing.assert_array_equal(c.val, [3.0, 5.0])

    def test_matvec_transpose_dense(self):
        c = tiny_csr(); x = np.arange(1, 5, dtype=float)
        np.testing.assert_allclose(c.matvec(x), c.dense() @ x)
        np.testing.assert_allclose(c.transpose().dense(), c.dense().T)

    def test_features_and_keys(self):
        f = si.features(tiny_csr(), partition={"scheme": "row_block", "pes": 2})
        self.assertEqual((f["n"], f["m"], f["nnz"]), (4, 4, 7))
        self.assertAlmostEqual(f["row_len_mean"], 1.75)
        self.assertEqual(f["row_len_max"], 3)
        self.assertEqual(f["bandwidth"], 2)
        self.assertFalse(f["symmetric_pattern"])
        self.assertEqual(f["partition"]["pe_nnz"], [3, 4])
        self.assertIn("struct_short_rows", f["keys"])
        self.assertIn("struct_accumulator_fits", f["keys"])

    def test_banded_generator_has_few_diagonals(self):
        b = si.banded(16, 2, seed=1)
        f = si.features(b)
        self.assertEqual(f["n_diagonals"], 5)
        self.assertIn("struct_few_diagonals", f["keys"])
        self.assertIn("struct_contiguous_rows", f["keys"])
        self.assertTrue(f["symmetric_pattern"])

    def test_generators_deterministic_and_valid(self):
        for kind, kw in (("banded", dict(n=12, bw=1)), ("uniform_random", dict(n=12, density=0.3)),
                         ("powerlaw_rows", dict(n=24, nnz_total=120)), ("block_diagonal", dict(n=16, block=4))):
            a, b = si.generate(kind, 5, **kw), si.generate(kind, 5, **kw)
            c = si.generate(kind, 6, **kw)
            np.testing.assert_array_equal(a.col, b.col); np.testing.assert_array_equal(a.val, b.val)
            self.assertFalse(a.nnz == c.nnz and np.array_equal(a.val, c.val), kind)
            lens = a.row_lengths()
            for r in range(a.n):                                      # sorted, unique columns per row
                cols = a.col[a.row_ptr[r]:a.row_ptr[r + 1]]
                self.assertTrue(np.all(np.diff(cols) > 0), kind)
            self.assertTrue(np.all(a.col >= 0) and np.all(a.col < a.m))

    def test_uniform_trim_matches_spmv_csr_generator(self):
        u = si.uniform_random(32, seed=7, density=0.25, max_nnz=256)
        self.assertEqual(u.nnz, 256)

    def test_pad_round_trip_and_cap_error(self):
        c = tiny_csr()
        pad = si.csr_pad(c, 6, 10)
        self.assertEqual(pad["row_ptr"].dtype, np.uint32)
        self.assertEqual(int(pad["row_ptr"][6]), 7)                        # rows past n repeat nnz
        self.assertEqual(int(pad["row_ptr"][4]), 7)
        np.testing.assert_array_equal(pad["col"][:7], c.col)
        with self.assertRaises(ValueError):
            si.csr_pad(c, 3, 10)

    def test_partition_row_block_round_trip(self):
        c = tiny_csr(); parts = si.partition_row_block(c, 2)
        self.assertEqual([p.n for p in parts], [2, 2])
        stacked = np.vstack([p.dense() for p in parts])
        np.testing.assert_array_equal(stacked, c.dense())


class MatrixMarketTests(unittest.TestCase):
    def test_pattern_symmetric_expands(self):
        with tempfile.TemporaryDirectory() as d:
            f = Path(d) / "s.mtx"
            f.write_text("%%MatrixMarket matrix coordinate pattern symmetric\n% c\n3 3 4\n1 1\n2 1\n3 2\n3 3\n")
            a = si.read_mtx(f); b = si._read_mtx_numpy(f)
            self.assertEqual(a.nnz, 6)
            np.testing.assert_allclose(a.dense(), b.dense())
            self.assertTrue(si.features(a)["symmetric_pattern"])

    def test_write_then_read(self):
        with tempfile.TemporaryDirectory() as d:
            f = Path(d) / "t.mtx"
            si.write_mtx(f, tiny_csr(), comment="test")
            np.testing.assert_allclose(si.read_mtx(f).dense(), tiny_csr().dense())


class SeedContractTests(unittest.TestCase):
    def test_seed_to_index(self):
        self.assertEqual([si.seed_to_index(s, 7, 4) for s in (7, 101, 202, 303)], [0, 3, 2, 1])
        self.assertEqual(si.seed_to_index(7, 7, 1), 0)
        for s in range(0, 1000):
            self.assertNotEqual(si.seed_to_index(s, 7, 4), 0) if s != 7 else None

    def test_load_manifest_matrix_values_and_generator(self):
        with tempfile.TemporaryDirectory() as d:
            d = Path(d)
            si.write_mtx(d / "a.mtx", tiny_csr()); si.write_mtx(d / "b.mtx", si.banded(6, 1, seed=1))
            man = {"schema": 1, "class": "t", "train_seed": 7, "values": "seeded_uniform",
                   "matrices": [{"id": "T/a", "file": "a.mtx"}, {"id": "T/b", "file": "b.mtx"},
                                {"id": "gen", "generator": {"kind": "banded", "n": 8, "bw": 1}}]}
            (d / "manifest.json").write_text(json.dumps(man))
            c0, e0 = si.load_manifest_matrix(d / "manifest.json", 7)
            self.assertEqual((e0["index"], c0.nnz), (0, 7))
            self.assertTrue(np.all((c0.val >= 0.1) & (c0.val < 1.0)))          # values re-drawn from the seed
            c1, e1 = si.load_manifest_matrix(d / "manifest.json", 101)          # 1 + 101 % 2 = 2 -> generator entry
            self.assertEqual(e1["index"], 2); self.assertEqual(c1.n, 8)
            c2, _ = si.load_manifest_matrix(d / "manifest.json", 202)          # 1 + 202 % 2 = 1
            self.assertEqual(c2.n, 6)
            man["values"] = "mtx"; (d / "manifest.json").write_text(json.dumps(man))
            c3, _ = si.load_manifest_matrix(d / "manifest.json", 7)
            np.testing.assert_array_equal(c3.val, [1, 2, 3, 4, 5, 6, 7])


class ReadoutTests(unittest.TestCase):
    def test_readout_text_and_budget(self):
        f = si.features(si.powerlaw_rows(64, seed=3, nnz_total=400), partition={"scheme": "row_block", "pes": 4},
                        caps={"nrows_pe": 16, "max_nnz_pe": 256})
        txt = si.readout(f, matrix_id="synthetic powerlaw", caps={"nrows_pe": 16, "max_nnz_pe": 256})
        self.assertTrue(txt.startswith("Structure readout (train input"))
        self.assertIn("nnz per PE", txt); self.assertIn("structure keys:", txt)
        self.assertLessEqual(len(si.readout(f, max_chars=300)), 300)

    def test_readout_for_spmv_csr_reference(self):
        txt = si.readout_for_kernel(REPO / "kernels" / "SpMV-CSR" / "CSL")
        self.assertIsNotNone(txt)
        self.assertIn("32 x 32, nnz 256", txt)                       # the generator trimmed to max_nnz

    def test_readout_for_manifest_kernel_names_only_the_train_matrix(self):
        txt = si.readout_for_kernel(REPO / "kernels" / "RowScale-CSR" / "CSL")
        self.assertIn("HB/494_bus", txt)
        for held in ("bcspwr05", "gre_512", "west0479"):
            self.assertNotIn(held, txt)


if __name__ == "__main__":
    unittest.main()
