"""Capture orchestration with the container tools mocked: argv extraction, ELF selection,
hash comparison, cleanup and failure isolation."""
import hashlib
import json
import os
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import ir_capture as ic


class ArgvTests(unittest.TestCase):
    def test_single_plain_compile_step(self):
        tr = [{"step": "compile", "command": "cslc ./layout.csl --arch=wse3 --fabric-dims=8,3 -o out --memcpy"},
              {"step": "run", "command": "cs_python run.py --name out"}]
        self.assertEqual(ic.compile_argv_from_transcript(tr, "S"), ["./layout.csl", "--arch=wse3", "--fabric-dims=8,3", "-o", "S", "--memcpy"])

    def test_rejects_shell_constructs_two_compiles_or_none(self):
        self.assertIsNone(ic.compile_argv_from_transcript([{"step": "compile", "command": "cslc a.csl -o out && echo x"}], "S"))
        self.assertIsNone(ic.compile_argv_from_transcript([{"step": "compile", "command": "cslc a.csl -o out"}] * 2, "S"))
        self.assertIsNone(ic.compile_argv_from_transcript([{"step": "run", "command": "cs_python run.py"}], "S"))
        self.assertIsNone(ic.compile_argv_from_transcript([{"step": "compile", "command": "cslc a.csl"}], "S"))

    def test_modes(self):
        with mock.patch.dict(os.environ, {"XKERNEL_IR_CAPTURE": "best"}):
            self.assertEqual(ic.mode_from_env(), "best")
        with mock.patch.dict(os.environ, {"XKERNEL_IR_CAPTURE": "bogus"}):
            self.assertEqual(ic.mode_from_env(), "0")
        self.assertEqual([ic.wants_ir(m) for m in ic.MODES], [False, False, True, True])


class OrchestrationTests(unittest.TestCase):
    def make_bundle(self, n_pes=3):
        d = Path(tempfile.mkdtemp()); (d / "out" / "bin").mkdir(parents=True)
        for i in range(n_pes):
            (d / "out" / "bin" / f"out_{i}_0.elf").write_bytes(b"ELF" + bytes([i]) * 8)
        return d

    def test_application_elfs_ordered_and_limited(self):
        d = self.make_bundle(12)
        names = [p.name for p in ic.application_elfs(str(d))]
        self.assertEqual(names, ["out_0_0.elf", "out_1_0.elf"])
        self.assertEqual(len(ic.application_elfs(str(d), limit=64)), 12)

    def test_mode_zero_is_a_noop(self):
        r = ic.capture_ir_artifacts("/nonexistent", [], "/sdk", "0")
        self.assertEqual(r["status"], "skipped")

    def test_disasm_and_ir_with_mocked_tools(self):
        d = self.make_bundle(2)
        tr = [{"step": "compile", "command": "cslc ./layout.csl --arch=wse3 -o out --memcpy"}]
        sha0 = hashlib.sha256((d / "out" / "bin" / "out_0_0.elf").read_bytes()).hexdigest()[:16]

        def fake_run(cmd, cwd, env, timeout):
            if "csdisasm.py" in cmd[1]:
                out = Path(cmd[cmd.index("--json") + 1]); out.parent.mkdir(parents=True, exist_ok=True)
                out.write_text(json.dumps({"schema": "csdisasm/1", "records": [{"pc": 0, "instruction": "nop", "source": "", "source_file": "pe.csl"}]}))
            elif "cslc_ir.py" in cmd[1]:
                cap = Path(cmd[cmd.index("-o") + 1]); prog = cap / "out_out_0_0"; prog.mkdir(parents=True)
                (prog / "program.ll").write_text("define void @compute() {\n  ret void\n}\n")
                (prog / "meta.json").write_text(json.dumps({"elf": str(d / "out" / "bin" / "out_0_0.elf"), "elf_sha": sha0}))
                (Path(cwd) / ".xkernel_ir" / "shadow_out").mkdir(parents=True, exist_ok=True)
            return mock.Mock(returncode=0, stdout="", stderr="")

        with mock.patch.object(ic, "_run", side_effect=fake_run), mock.patch.object(ic, "study_root", return_value=ic.REPO_ROOT / "studies/wse3-characterization"):
            r = ic.capture_ir_artifacts(str(d), tr, "/software/cerebras/cs_sdk-2.10", "best")
        self.assertEqual(r["status"], "ok", r)
        self.assertEqual(len(r["disasm"]), 2)
        self.assertTrue(r["elf_matches_benchmark"])
        self.assertEqual(r["programs"][0]["name"], "out_out_0_0")
        self.assertFalse((d / ".xkernel_ir" / "shadow_out").exists())          # cleaned up
        self.assertTrue((d / ".xkernel_ir" / "disasm" / "out_0_0.json").is_file())

    def test_tool_failure_is_isolated(self):
        d = self.make_bundle(1)
        with mock.patch.object(ic, "_run", return_value=mock.Mock(returncode=1, stdout="", stderr="boom")), \
             mock.patch.object(ic, "study_root", return_value=ic.REPO_ROOT / "studies/wse3-characterization"):
            r = ic.capture_ir_artifacts(str(d), [{"step": "compile", "command": "cslc a.csl -o out"}], "/sdk", "best")
        self.assertEqual(r["status"], "failed")
        self.assertIn("boom", r["reason"])


if __name__ == "__main__":
    unittest.main()
