"""Post-training data helpers and reward tiers (1 Oct 2026); CPU only, no SDK."""
import unittest

from posttrain import common as C
from posttrain import csl_reward as R


class SplitTest(unittest.TestCase):
    def test_sparse_benchmark_and_general_set_are_held_out(self):
        for k in C.EVAL_SPARSE:
            self.assertEqual(C.split_of(k), "eval_sparse")
        for k in C.EVAL_GENERAL:
            self.assertEqual(C.split_of(k), "eval_general")
        self.assertEqual(C.split_of("GEMM"), "train")

    def test_directory_names_resolve_to_registry_names(self):
        self.assertEqual(C.canonical_kernel("GEMV Collectives 2D"), "GEMV-Collectives-2D")
        self.assertEqual(C.split_of("GEMV Collectives 2D"), "eval_general")

    def test_every_eval_kernel_is_registered(self):
        reg = C.registry()
        for k in C.EVAL_SPARSE + C.EVAL_GENERAL:
            self.assertIn(k, reg, k)


class RedactionTest(unittest.TestCase):
    def test_paths_hosts_jobs_mail_and_keys(self):
        # no real account or host names here: the publication scrub must not alter this test
        t = ("/home/USER/xkernel/kernels/a /home/USER/x cer-" + "usn-02 wsjob-abc123 a.b@c.edu "
             "sk-ant-" + "A" * 30 + " /software/cerebras/cs_sdk-2.10/bin \x1b[34mINFO\x1b[0m")
        r = C.redact(t)
        for bad in ("/home/USER", "cer-" + "usn", "wsjob-abc", "a.b@c.edu", "sk-ant-", "cs_sdk-2.10", "\x1b["):
            self.assertNotIn(bad, r)
        self.assertTrue(C.looks_secret("x sk-proj-" + "B" * 24))


class PromptTest(unittest.TestCase):
    P = ("Complete the template.\nCRITICAL RULES:\n1. rule\n## CSL Type Rules\ndocs docs\n# DESIGN.md — x\ndesign\n"
         "## layout.csl — the EXACT interface\nlayout\nTask description:\ntask\nCUDA analysis:\nmodel text\n"
         "CUDA source:\n__global__ void k() {}\n")

    def test_model_outputs_are_removed(self):
        s = C.strip_model_outputs(self.P)
        self.assertNotIn("model text", s)
        self.assertNotIn("design", s)
        self.assertIn("CUDA source:", s)
        self.assertIn("## layout.csl", s)

    def test_compact_drops_documentation_keeps_interface(self):
        c = C.compact_prompt(self.P)
        self.assertNotIn("docs docs", c)
        self.assertIn("CRITICAL RULES", c)
        self.assertIn("## layout.csl", c)
        self.assertIn("__global__", c)

    def test_sdk_port_of_fenced_code(self):
        txt = "```csl\nparam memcpy_params: comptime_struct;\n```"
        out, n = C.port_fenced(txt, "2.10.0")
        self.assertGreaterEqual(n, 1)
        self.assertNotIn("comptime_struct", out)


class RewardTierTest(unittest.TestCase):
    REC = {"kernel": "X", "reference_dir": "kernels/X/CSL"}

    def test_tiers(self):
        f = R.reward_from
        self.assertEqual(f({"stage": "static"}, self.REC), 0.05)
        self.assertEqual(f({"compiled": False}, self.REC), 0.10)
        self.assertEqual(f({"compiled": True, "level": "compile", "status": "pass"}, self.REC), 0.30)
        self.assertEqual(f({"compiled": True, "level": "run", "status": "fail"}, self.REC), 0.30)
        self.assertEqual(f({"compiled": True, "level": "run", "status": "fail", "heldout": False}, self.REC), 0.60)
        ok = {"compiled": True, "level": "run", "status": "pass", "success_marker": True, "cycles": 100}
        self.assertEqual(f(ok, self.REC), 1.0)
        self.assertEqual(f(ok, dict(self.REC, base_cycles=200)), 2.0)
        self.assertEqual(f(ok, dict(self.REC, base_cycles=50)), 0.0)
        self.assertAlmostEqual(f(ok, dict(self.REC, ref_cycles=200)), 1.25)

    def test_no_code_scores_zero(self):
        self.assertEqual(R.score("plain text", self.REC)[0], 0.0)

    def test_conversational_completion(self):
        self.assertEqual(R._completion_text([{"role": "assistant", "content": "abc"}]), "abc")


if __name__ == "__main__":
    unittest.main()
