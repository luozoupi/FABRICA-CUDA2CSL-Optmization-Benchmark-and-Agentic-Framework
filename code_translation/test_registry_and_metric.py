#!/usr/bin/env python3
"""Tests for KERNEL_REGISTRY coverage + the metric-class policy (resolve_metric).

Guards two invariants as the suite grows:
  - every registered kernel resolves a real CUDA source, reference dir, target
    compute file, and build script (so the agent track can actually run it);
  - the spec.yaml `metric:` field parses into a valid class with back-compat
    default 'cycles'.
"""

import os
import sys
import unittest

_HERE = os.path.dirname(os.path.abspath(__file__))
if _HERE not in sys.path:
    sys.path.insert(0, _HERE)

import cuda2csl  # noqa: E402


class RegistryCoverageTest(unittest.TestCase):
    def test_every_registry_entry_resolves_its_files(self):
        missing = []
        for name, e in cuda2csl.KERNEL_REGISTRY.items():
            if not os.path.isfile(e["cuda_path"]):
                missing.append(f"{name}: cuda_path {e['cuda_path']}")
            if not os.path.isdir(e["reference_csl_dir"]):
                missing.append(f"{name}: reference_csl_dir {e['reference_csl_dir']}")
            tgt = os.path.join(e["reference_csl_dir"], e["target_relpath"])
            if not os.path.isfile(tgt):
                missing.append(f"{name}: target {tgt}")
            cmd = os.path.join(e["reference_csl_dir"], e["commands_script"])
            if not os.path.isfile(cmd):
                missing.append(f"{name}: commands_script {cmd}")
        self.assertEqual(missing, [], "registry entries with missing files:\n" + "\n".join(missing))

    def test_jacobi_is_registered(self):
        # T1 (2026-06-24): Jacobi-2D-5pt added to the registry.
        self.assertIn("Jacobi-2D-5pt", cuda2csl.KERNEL_REGISTRY)
        e = cuda2csl.KERNEL_REGISTRY["Jacobi-2D-5pt"]
        self.assertEqual(e["target_relpath"], "pe.csl")
        self.assertTrue(e["commands_script"].endswith("wse3.sh"))


class ResolveMetricTest(unittest.TestCase):
    def test_default_is_cycles(self):
        self.assertEqual(cuda2csl.resolve_metric(None)["class"], "cycles")
        self.assertEqual(cuda2csl.resolve_metric({"tasks": ["x"]})["class"], "cycles")

    def test_string_form(self):
        self.assertEqual(
            cuda2csl.resolve_metric({"metric": "correctness_only"})["class"],
            "correctness_only")

    def test_dict_form_with_work_unit(self):
        r = cuda2csl.resolve_metric(
            {"metric": {"class": "normalized_cycles", "work_unit": "2*nnz+m",
                        "reason": "sparse"}})
        self.assertEqual(r["class"], "normalized_cycles")
        self.assertEqual(r["work_unit"], "2*nnz+m")

    def test_unknown_class_falls_back_to_cycles(self):
        self.assertEqual(cuda2csl.resolve_metric({"metric": "bogus"})["class"], "cycles")

    def test_all_specced_kernels_have_valid_metric(self):
        # every kernel with a spec.yaml resolves a valid metric class
        import glob
        repo = os.path.normpath(os.path.join(_HERE, ".."))
        for spec_path in glob.glob(os.path.join(repo, "kernels", "*", "spec.yaml")):
            ref = os.path.join(os.path.dirname(spec_path), "CSL")
            spec = cuda2csl.load_kernel_spec(ref)
            cls = cuda2csl.resolve_metric(spec)["class"]
            self.assertIn(cls, cuda2csl._VALID_METRIC_CLASSES,
                          f"{spec_path}: invalid metric class {cls}")


if __name__ == "__main__":
    unittest.main(verbosity=2)
