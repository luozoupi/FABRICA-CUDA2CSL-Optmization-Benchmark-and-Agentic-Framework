"""error_family.classify_attempt on real stderr snippets from the preserved corpus (2026-09-08 mining)."""
import json
import tempfile
import unittest
from pathlib import Path

import error_family as ef


def _attempt(step, text, rc=1, **kw):
    a = {"status": "fail", "success_marker": False, "failure_reason": "command_failed",
         "transcript": [{"step": "compile", "status": "pass", "stderr": "", "stdout": "", "returncode": 0}]}
    if step == "compile":
        a["transcript"] = [{"step": "compile", "status": "fail", "stderr": text, "stdout": "", "returncode": rc}]
    else:
        a["transcript"].append({"step": "run", "status": "fail", "stderr": text, "stdout": "", "returncode": rc})
    a.update(kw)
    return a


COMPILE_CASES = [
    ("syntax_error", "./pe.csl:84:3: error: Unexpected character at this location"),
    ("undeclared_identifier", "./pe.csl:70:46: error: use of undeclared identifier"),
    ("uninitialized_param", "/cb/toolchains/cslang/rel-sdk-1.4.0/x/csl-libs/collectives_2d/pe.csl:3:1: error: "
                            "only 'var' and 'extern const' variables may be uninitialized"),
    ("uninitialized_param", "./src/../../benchmark-libs/stencil_3d_7pts/wse3/pe.csl:82:34: error: expected integer expression, got: 'void'"),
    ("type_mismatch", "./pe.csl:84:5: error: operand types do not match expectations"),
    ("type_mismatch", "./pe.csl:109:27: error: expected type 'i16', got: 'u16'"),
    ("comptime_misuse", "./pe.csl:148:10: error: 'inline' while-loops not supported"),
    ("comptime_misuse", "./pe.csl:93:12: error: exceeded the maximum of 50 inlined iterations"),
    ("queue_or_ut_id", "./src/../../benchmark-libs/stencil_3d_7pts/wse3/pe.csl:779:9: error: initialization for this queue has already been set"),
    ("queue_or_ut_id", "/x/memcpy/wse3/memcpyd2h.csl:542:36: error: task ID '21' bound to more than one task"),
    ("call_arity", "./pe.csl:118:12: error: builtin requires 4 argument(s), 3 provided"),
    ("bad_import", "error: Unable to open /x/csl-libs/timestamp/timestamp.csl: no such file or directory"),
    ("contract_entrypoint", "./pe.csl:82:5: error: name 'x_tile' was not declared during layout evaluation"),
    ("dsd_construction", "./pe.csl:116:57: error: invalid use of non-loop variable in affine expression"),
    ("dsd_construction", "./pe.csl:37:22: error: too many dimensions for memory DSD of type 'mem1d_dsd'"),
    ("dsr_arity_mismatch", "./pe.csl:274:5: error: destination DSR Id(1) does not match first source DSR Id(2)"),
    ("export_mutability", "./pe.csl:112:20: error: exported symbol mutability mismatch\n    @export_symbol(ptr_O, \"O\");\n"
                          "./layout.csl:46:3: note: expected name to be mutable"),
    ("task_binding", "./pe.csl:381:20: error: non-task provided as the task argument of bind_local_task"),
    ("sdk_env_blocked", "LLVM ERROR: pthread_create failed: Resource temporarily unavailable"),
    ("sdk_env_blocked", "cslc-driver: ../../../llvm/lib/Support/Unix/Program.inc:386: llvm::sys::ProcessInfo llvm::sys::Wait(...)"),
    ("link_oom", "ld.lld: error: ran out of PE memory"),
    ("shadow_or_decl", "./ucode_2d.csl:12:5: error: declaration shadows another symbol"),
    ("unknown_builtin", "./pe_program.csl:40:9: error: unknown builtin @add32"),
    ("queue_or_ut_id", "./pe.csl:9:1: error: expected task ID in the range [0,32), got: 40"),
    ("queue_or_ut_id", "./histogram.csl:3:1: error: expected color ID in the range [0,24), got: 31"),
    ("contract_entrypoint", "./pe.csl:200:1: error: no symbol was exported with name 'maxmin_time'"),
    ("layout_error", "./layout.csl:30:3: error: no @set_tile_code called for coordinates (1, 0)"),
    ("cslc_internal_crash", "cslc-driver: /x/Types.h:288: U mlir::Type::cast() const [with U = mlir::FunctionType]: Assertion `isa<U>()' failed."),
    ("bad_import", "error: Unable to open ./memcpy: no such file or directory"),
    ("dsd_construction", "./residual.csl:70:5: error: only DSD/DSR operands are allowed for async operations"),
    ("type_mismatch", "./ucode_2d.csl:88:20: error: expected unsigned value for shift amount"),
    ("other_compile_error", "./pe.csl:1:1: error: something the table has never seen"),
]

RUN_CASES = [
    ("runtime_stall", "terminate called after throwing an instance of 'std::runtime_error'\n"
                      "  what():  the received length (0 bytes) is not expected (256 bytes), could be a kernel stall", 134),
    ("runtime_fatal_ut", "what():  Stopping due to fatal error: P4.2 (hwtile) P4.2: Id: 22, Instr: 909, Seq: 0, Pipe: 3, "
                         "Msg: trying to term ut_instr[2], but it's not ours, Instr: 901", 134),
    ("runtime_fatal_hcf", "what():  Stopping due to fatal error: P4.2 (hwtile) P4.2: Id: 26, Instr: 1589, Seq: 0, Pipe: 6, "
                          "Msg: FATAL: hcf (halt and catch fire)", 134),
    ("verify_mismatch", "Traceback (most recent call last):\n  File \"run.py\", line 142, in <module>\n"
                        "    np.testing.assert_allclose(y, y_expected, atol=0.01, rtol=0)\nAssertionError: \nNot equal to tolerance\n"
                        "SDKR050 ERROR: SdkRuntime::stop() has not been called before runtime destruction.", 1),
    ("missing_export_symbol", "Traceback (most recent call last):\nTypeError: memcpy_h2d(): incompatible function arguments. "
                              "The following argument types are supported:", 1),
    ("runtime_python_error", "Traceback (most recent call last):\n  File \"run.py\", line 9\nZeroDivisionError: float division by zero", 1),
    ("runtime_crash", "terminate called recursively\n", 139),
    ("runtime_crash", "Fontconfig error: Cannot load default config file\n", 139),
]


class ClassifyAttemptTests(unittest.TestCase):
    def test_compile_families(self):
        for fam, text in COMPILE_CASES:
            with self.subTest(fam=fam, text=text[:50]):
                self.assertEqual(ef.classify_attempt(_attempt("compile", text))["family"], fam)

    def test_run_families(self):
        for fam, text, rc in RUN_CASES:
            with self.subTest(fam=fam):
                self.assertEqual(ef.classify_attempt(_attempt("run", text, rc))["family"], fam)

    def test_noise_lines_do_not_decide(self):
        text = ("INFO:    Environment variable SINGULARITYENV_XKERNEL_ERROR_GOTCHA is set, but APPTAINERENV_ is preferred\n"
                "Fontconfig error: Cannot load default config file\n./pe.csl:5:1: error: use of undeclared identifier")
        self.assertEqual(ef.classify_attempt(_attempt("compile", text))["family"], "undeclared_identifier")

    def test_gate_families_take_precedence(self):
        base = _attempt("compile", "irrelevant")
        for reason, fam in (("heldout_seed_mismatch seed=101: ...", "heldout_mismatch"),
                            ("implausible_cycles_send=0 (<100): dead timer", "implausible_cycles"),
                            ("missing_success_marker", "missing_success_marker"),
                            ("contract_violation: f_toc_dev call site removed", "contract_violation"),
                            ("no_csl_block", "no_csl_block")):
            a = dict(base, failure_reason=reason, transcript=[])
            self.assertEqual(ef.classify_attempt(a)["family"], fam, reason)
        self.assertEqual(ef.classify_attempt({"status": "blocked", "failure_reason": "blocked_container_runtime",
                                              "transcript": []})["family"], "sdk_env_blocked")
        self.assertEqual(ef.classify_attempt({"status": "pass", "success_marker": True})["family"], "pass")
        self.assertEqual(ef.classify_attempt({"status": "pass", "success_marker": False, "failure_reason": None,
                                              "transcript": [{"step": "run", "status": "pass"}]})["family"], "pass_unverified")
        self.assertEqual(ef.classify_attempt({"status": "pass", "success_marker": False, "failure_reason": None,
                                              "cycles_send": None, "run_time_ms": 0,
                                              "transcript": [{"step": "compile", "status": "pass"}]})["family"], "compile_only_check")

    def test_heldout_eval_dict_uses_the_real_schema(self):
        """evaluate_heldout returns {"passed", "failing_seed", "per_seed", "reason"} --
        there is no "status" key, so a check on one could never fire."""
        a = {"status": "fail", "success_marker": True, "failure_reason": "",
             "heldout_eval": {"passed": False, "failing_seed": 202, "reason": "seed 202 mismatch"},
             "transcript": []}
        r = ef.classify_attempt(a)
        self.assertEqual(r["family"], "heldout_mismatch")
        self.assertIn("202", r["evidence"])

    def test_passing_heldout_does_not_become_a_failure(self):
        a = {"status": "pass", "success_marker": True,
             "heldout_eval": {"passed": True, "failing_seed": None, "reason": "passed all 3 held-out seeds"}}
        self.assertEqual(ef.classify_attempt(a)["family"], "pass")

    def test_evidence_is_the_matching_line(self):
        r = ef.classify_attempt(_attempt("compile", "noise\n./pe.csl:70:46: error: use of undeclared identifier\nmore"))
        self.assertIn("undeclared identifier", r["evidence"])
        self.assertEqual(r["step"], "compile")


class ClassifyRunTests(unittest.TestCase):
    def test_run_dir_roundtrip(self):
        with tempfile.TemporaryDirectory() as d:
            rd = Path(d)
            attempts = [_attempt("compile", "./pe.csl:1:1: error: use of undeclared identifier"),
                        _attempt("run", "what():  the received length (0 bytes) is not expected (8 bytes), could be a kernel stall", 134),
                        {"status": "pass", "success_marker": True, "transcript": []}]
            (rd / "final_result.json").write_text(json.dumps({"attempts": attempts}))
            res = ef.classify_run(rd)
            self.assertEqual(res["n_attempts"], 3)
            self.assertEqual(res["final_family"], "pass")
            self.assertEqual(res["counts"], {"undeclared_identifier": 1, "runtime_stall": 1, "pass": 1})

    def test_missing_final_result(self):
        with tempfile.TemporaryDirectory() as d:
            self.assertEqual(ef.classify_run(Path(d))["final_family"], "no_attempts")


if __name__ == "__main__":
    unittest.main()
