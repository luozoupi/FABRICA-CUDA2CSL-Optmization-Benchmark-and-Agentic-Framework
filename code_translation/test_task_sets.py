"""task_sets: the study's membership is data, and it must agree with the repository.

This is the guard that stopped the pre-registration from drifting: sets that name a
kernel with no frozen first-correct program describe an experiment that cannot run.
"""
import unittest

import task_sets as ts


class SetShapeTests(unittest.TestCase):
    def test_sets_are_disjoint_and_nonempty(self):
        for name, members in ts.SETS.items():
            self.assertTrue(members, f"set {name} is empty")
            self.assertEqual(len(members), len(set(members)), f"set {name} repeats a kernel")
        pairs = [("H", "M"), ("H", "A"), ("M", "A")]
        for a, b in pairs:
            self.assertEqual(set(ts.SETS[a]) & set(ts.SETS[b]), set(), f"{a} and {b} overlap")

    def test_all_is_the_union(self):
        self.assertEqual(sorted(ts.ALL), sorted(ts.H + ts.M + ts.A))
        self.assertEqual(len(ts.ALL), len(set(ts.ALL)))

    def test_excluded_kernels_carry_a_reason_and_are_not_in_the_study(self):
        for k, reason in ts.EXCLUDED.items():
            self.assertTrue(reason.strip(), f"{k} excluded without a reason")
            self.assertNotIn(k, ts.ALL, f"{k} is both excluded and in the study")


class KernelsOfTests(unittest.TestCase):
    def test_set_names_expand(self):
        self.assertEqual(ts.kernels_of("H"), ts.H)
        self.assertEqual(ts.kernels_of("M,A"), ts.M + ts.A)
        self.assertEqual(ts.kernels_of("all"), ts.ALL)

    def test_explicit_kernel_names_pass_through(self):
        self.assertEqual(ts.kernels_of("ReLU-1PE,GELU-1PE"), ["ReLU-1PE", "GELU-1PE"])

    def test_duplicates_collapse_and_order_is_kept(self):
        self.assertEqual(ts.kernels_of("A,A"), ts.A)
        self.assertEqual(ts.kernels_of("ReLU-1PE,H")[0], "ReLU-1PE")

    def test_blank_parts_ignored(self):
        self.assertEqual(ts.kernels_of("H,, ,"), ts.H)


class PartitionTests(unittest.TestCase):
    def test_partition_covers_the_study_exactly_once(self):
        owned = []
        for key in ("A", "B"):                       # the v1 study's two accounts
            owned.extend(ts.PARTITION[key]["kernels"])
        self.assertEqual(sorted(owned), sorted(ts.ALL))
        self.assertEqual(len(owned), len(set(owned)), "a kernel is owned by two accounts")

    def test_sparse_partition_covers_set_s_exactly_once(self):
        owned = list(ts.PARTITION["S-A"]["kernels"]) + list(ts.PARTITION["S-B"]["kernels"])
        self.assertEqual(sorted(owned), sorted(ts.S))
        self.assertEqual(len(owned), len(set(owned)))

    def test_verify_sparse_passes_against_this_checkout(self):
        ok, msgs = ts.verify_sparse()
        self.assertTrue(ok, "\n".join(msgs))
        self.assertTrue(any(m.startswith("OK") for m in msgs), msgs)

    def test_every_cell_documents_who_runs_it(self):
        for key, cell in ts.PARTITION.items():
            self.assertTrue(str(cell.get("who", "")).strip(), f"partition {key} has no owner")


class RepositoryAgreementTests(unittest.TestCase):
    def test_verify_passes_against_this_checkout(self):
        ok, msgs = ts.verify()
        self.assertTrue(ok, "\n".join(msgs))

    def test_verify_reports_a_missing_frozen_program(self):
        import tempfile
        from pathlib import Path
        with tempfile.TemporaryDirectory() as d:
            ok, msgs = ts.verify(Path(d))          # empty first_correct root
            self.assertFalse(ok)
            self.assertTrue(any("no frozen first-correct program" in m for m in msgs))


if __name__ == "__main__":
    unittest.main()
