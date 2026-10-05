"""Tests for the SDK-free ``--generate-only`` translation path."""
from __future__ import annotations

import os
import sys
import tempfile
import unittest
from unittest.mock import MagicMock, patch

HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path:
    sys.path.insert(0, HERE)

import cuda2csl  # noqa: E402


REFERENCE_COMPUTE = """\
var distinctive_reference_buffer_name_for_generate_only_test = @zeros([16]f32);
fn distinctive_reference_function_for_generate_only_test() void {}
"""


def make_orchestrator(work_root: str) -> cuda2csl.CUDA2CSLOrchestrator:
    with patch.object(cuda2csl, "ExperienceStore", return_value=MagicMock()):
        orch = cuda2csl.CUDA2CSLOrchestrator(
            model="dummy-model",
            api_key_file="/dev/null",
            api_key_command=None,
            base_url=None,
            max_tokens=1024,
            turns_limit=2,
            work_root=work_root,
            sdk_root="/sdk/that/must/not/be-used",
            arch="wse3",
            commands_script="commands_wse3.sh",
            shell_setup=None,
        )
    # Keep this unit test focused on the initial implementer response. Analysis
    # and architecture are still exercised in real generate-only runs.
    orch.cuda_analysis = "CUDA analysis supplied by the test"
    orch.decomposition_plan = "decomposition supplied by the test"
    return orch


class GenerateOnlyTests(unittest.TestCase):
    def test_generate_only_returns_unverified_without_benchmark(self):
        code = "\n".join(["const value: i16 = 1;"] * 25)
        reply = f"```csl\n{code}\n```"
        with tempfile.TemporaryDirectory() as tmp:
            orch = make_orchestrator(tmp)
            with patch.object(orch, "_llm_call", return_value=reply), \
                    patch.object(orch, "_benchmark_current_code") as benchmark:
                actual, result = orch.translate(
                    kernel_name="Generate-Only-Test",
                    cuda_code="__global__ void test() {}",
                    reference_dir=tmp,
                    target_relpath="pe.csl",
                    reference_contract="host contract",
                    reference_compute_file=REFERENCE_COMPUTE,
                    layout_text="const layout_value: i16 = 1;",
                    generate_only=True,
                )

        benchmark.assert_not_called()
        self.assertEqual(actual, code)
        self.assertEqual(result["status"], "unverified")
        self.assertTrue(result["generated_only"])
        self.assertTrue(result["verification_required"])
        self.assertFalse(result["success_marker"])
        self.assertEqual(orch.run_log, [result])

    def test_generate_only_best_of_never_compile_checks(self):
        short = "\n".join(["const short_value: i16 = 1;"] * 20)
        long = "\n".join(["const long_value: i16 = 2;"] * 30)
        replies = [f"```csl\n{short}\n```", f"```csl\n{long}\n```"]
        with tempfile.TemporaryDirectory() as tmp, \
                patch.dict(os.environ, {"XKERNEL_BEST_OF_N": "2"}):
            orch = make_orchestrator(tmp)
            with patch.object(orch, "_llm_call", side_effect=replies), \
                    patch.object(orch, "_benchmark_current_code") as benchmark:
                actual, result = orch.translate(
                    kernel_name="Generate-Only-Best-Of-Test",
                    cuda_code="__global__ void test() {}",
                    reference_dir=tmp,
                    target_relpath="pe.csl",
                    reference_contract="host contract",
                    reference_compute_file=REFERENCE_COMPUTE,
                    layout_text="const layout_value: i16 = 1;",
                    generate_only=True,
                )

        benchmark.assert_not_called()
        self.assertEqual(actual, long)
        self.assertEqual(result["status"], "unverified")

    def test_generate_only_environment_report_skips_all_sdk_probes(self):
        with patch.object(cuda2csl, "agent_env_report", return_value={"ready": True}), \
                patch.object(cuda2csl, "legacy_venv_report") as legacy_probe, \
                patch.object(cuda2csl, "sdk_report") as sdk_probe:
            report = cuda2csl.build_env_report(
                api_key_file="/tmp/key",
                sdk_root="/missing/sdk",
                skip_sdk_probes=True,
            )

        legacy_probe.assert_not_called()
        sdk_probe.assert_not_called()
        self.assertEqual(report["overall_status"], "ready")
        self.assertEqual(report["sdk"]["status"], "skipped")
        self.assertEqual(report["sdk"]["cslc_launch"]["status"], "skipped")
        self.assertEqual(report["sdk"]["cs_python_launch"]["status"], "skipped")


if __name__ == "__main__":
    unittest.main()
