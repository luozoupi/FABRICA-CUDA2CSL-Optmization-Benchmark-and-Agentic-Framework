"""Build-script hygiene and the compile-only step selection.

Regression for 2026-09-08: the attention tasks' commands_wse3*.sh used shell
variables (`P=4` ... `--params=P:${P}`); the dry check kept only the cslc step,
so the runner hit an unbound variable under `set -u` and died before the first
step marker -> every attempt was `missing_transcript` and the reviewer reasoned
about empty transcripts.
"""
import glob
import os
import re
import tempfile
import unittest

import benchmark_csl as bc

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
KERNELS = os.path.join(REPO, "kernels")


class CompileOnlySelectionTests(unittest.TestCase):
    def test_keeps_assignments_before_cslc_and_drops_runs(self):
        cmds = ["P=4", "St_q=4", "cslc --arch=wse3 ./layout.csl --params=P:${P},St_q:${St_q} -o out",
                "cs_python run.py --name out"]
        self.assertEqual(bc.select_compile_only_commands(cmds), cmds[:3])

    def test_multiple_compiles_keep_everything_up_to_last_compile(self):
        cmds = ["export X=1", "cslc a.csl -o a", "cs_python run_a.py", "cslc b.csl -o b", "cs_python run_b.py"]
        self.assertEqual(bc.select_compile_only_commands(cmds), ["export X=1", "cslc a.csl -o a", "cslc b.csl -o b"])

    def test_no_compile_step_keeps_non_run_commands(self):
        self.assertEqual(bc.select_compile_only_commands(["echo hi", "cs_python run.py"]), ["echo hi"])

    def test_runner_does_not_abort_on_unbound_variable_in_a_step(self):
        with tempfile.TemporaryDirectory() as d:
            runner = bc.write_instrumented_runner(d, ['echo "P=${P_UNSET_XYZ}"', "echo second"], None, num_runs=1)
            text = open(runner).read()
            self.assertIn("set -u", text)
            self.assertIn("set +u", text)
            res = bc.run_subprocess(f"bash {runner}", cwd=d, env=dict(os.environ), timeout=30)
            transcript = bc.parse_instrumented_stdout(res.stdout)
            self.assertEqual(len(transcript), 2, res.stdout[-400:])
            self.assertEqual(transcript[1]["stdout"].strip(), "second")


class CommandsScriptHygieneTests(unittest.TestCase):
    def _scripts(self):
        pats = ["*/CSL/commands_wse3*.sh", "*/CSL/commands.sh"]
        out = []
        for p in pats:
            out += glob.glob(os.path.join(KERNELS, p))
        return sorted(out)

    def test_cslc_lines_use_literal_params(self):
        """`--params=` and `--fabric-dims=` must be literal: the dry check, the hardware
        porter and hw_replay all read the cslc line verbatim."""
        offenders = []
        for path in self._scripts():
            cmds = bc.parse_command_script(path)
            for c in cmds:
                if bc.classify_command_step(c) == "compile" and re.search(r"\$\{|\$\(\(|\$[A-Za-z_]", c):
                    offenders.append(os.path.relpath(path, KERNELS))
        self.assertEqual(offenders, [], f"shell variables in cslc lines: {offenders}")

    def test_spec_sizes_reference_existing_scripts(self):
        try:
            import yaml  # type: ignore
        except ImportError:
            self.skipTest("PyYAML not installed")
        missing = []
        for spec_path in glob.glob(os.path.join(KERNELS, "*", "spec.yaml")):
            spec = yaml.safe_load(open(spec_path)) or {}
            for size in spec.get("sizes") or []:
                script = (size or {}).get("commands_script")
                if script and not os.path.isfile(os.path.join(os.path.dirname(spec_path), "CSL", script)):
                    missing.append(f"{os.path.basename(os.path.dirname(spec_path))}:{script}")
        self.assertEqual(missing, [], f"sizes[].commands_script not found: {missing}")

    def test_spec_size_params_match_the_script(self):
        """Each size's params must appear literally in its script's --params (guards
        against a spec/script drift that would mislabel a measurement)."""
        try:
            import yaml  # type: ignore
        except ImportError:
            self.skipTest("PyYAML not installed")
        drift = []
        for spec_path in glob.glob(os.path.join(KERNELS, "*", "spec.yaml")):
            spec = yaml.safe_load(open(spec_path)) or {}
            for size in spec.get("sizes") or []:
                script = (size or {}).get("commands_script")
                params = (size or {}).get("params") or {}
                sp = os.path.join(os.path.dirname(spec_path), "CSL", script or "")
                if not (script and params and os.path.isfile(sp)):
                    continue
                cslc = [c for c in bc.parse_command_script(sp) if bc.classify_command_step(c) == "compile"]
                m = re.search(r"--params=(\S+)", cslc[0]) if cslc else None
                if not m:
                    continue
                given = dict(kv.split(":", 1) for kv in m.group(1).split(",") if ":" in kv)
                for k, v in params.items():
                    if k in given and str(given[k]) != str(v):
                        drift.append(f"{os.path.basename(os.path.dirname(spec_path))}/{size.get('name')}: {k} spec={v} script={given[k]}")
        self.assertEqual(drift, [], "\n".join(drift))


if __name__ == "__main__":
    unittest.main()
