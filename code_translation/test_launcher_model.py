"""Every launcher must pass the model the caller selected. run_cuda2csl.sh did not, so a sweep
launched with XKERNEL_MODEL=gpt-5.6-luna on 2026-09-20 ran entirely on cuda2csl.py's default
(gpt-4.1) and only the usage log showed it -- the sweep's own banner printed the model the
caller had asked for."""
import re
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LAUNCHERS = ("run_cuda2csl.sh", "run_cuda2csl_anthropic.sh", "run_cuda2csl_argo.sh")


class LauncherModelTests(unittest.TestCase):
    def test_every_launcher_forwards_a_model(self):
        for name in LAUNCHERS:
            p = ROOT / name
            if not p.is_file():
                continue
            text = p.read_text()
            self.assertIn("--model", text, f"{name} never passes --model to cuda2csl.py")
            self.assertRegex(text, r"XKERNEL_MODEL|ARGO_MODEL",
                             f"{name} ignores the caller's model environment variable")

    def test_openai_launcher_uses_the_env_model(self):
        """Dry-run the argument assembly with a stub python on PATH that just echoes argv."""
        import os, tempfile
        with tempfile.TemporaryDirectory() as td:
            stub = Path(td) / "micromamba"
            stub.write_text("#!/usr/bin/env bash\nshift 3\nexec echo \"$@\"\n")   # drop: run -n <env>
            stub.chmod(0o755)
            env = dict(os.environ, XKERNEL_MICROMAMBA=str(stub), XKERNEL_MODEL="gpt-5.6-luna",
                       XKERNEL_ROOT=str(ROOT), OPENAI_KEY_FILE="/dev/null")
            out = subprocess.run(["bash", str(ROOT / "run_cuda2csl.sh"), "--kernel", "X"],
                                 capture_output=True, text=True, env=env, timeout=60).stdout
            self.assertIn("--model gpt-5.6-luna", out, out[:300])
            self.assertIn("--kernel X", out)

    def test_an_explicit_model_flag_still_wins(self):
        import os, tempfile
        with tempfile.TemporaryDirectory() as td:
            stub = Path(td) / "micromamba"
            stub.write_text("#!/usr/bin/env bash\nshift 3\nexec echo \"$@\"\n")
            stub.chmod(0o755)
            env = dict(os.environ, XKERNEL_MICROMAMBA=str(stub), XKERNEL_MODEL="gpt-5.6-luna",
                       XKERNEL_ROOT=str(ROOT), OPENAI_KEY_FILE="/dev/null")
            out = subprocess.run(["bash", str(ROOT / "run_cuda2csl.sh"), "--model", "gpt-4.1"],
                                 capture_output=True, text=True, env=env, timeout=60).stdout
            # the caller's explicit flag comes last, so argparse takes it
            self.assertLess(out.index("gpt-5.6-luna"), out.index("gpt-4.1"), out[:300])


if __name__ == "__main__":
    unittest.main()
