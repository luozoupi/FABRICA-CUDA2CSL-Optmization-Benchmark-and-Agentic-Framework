import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from model_artifacts import archive_call, archive_candidate, code_hash, export_records
import workflow_common as wc


class ModelArtifactTests(unittest.TestCase):
    def test_failed_candidate_keeps_source_and_build_hashes(self):
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {
                "XKERNEL_CALL_ARCHIVE": str(Path(tmp)/'archive')}):
            bundle=Path(tmp)/'bundle';bundle.mkdir()
            (bundle/'layout.csl').write_text('layout source')
            path=archive_candidate('bad source', {'staged_bundle':str(bundle),
                                   'status':'fail','failure_reason':'compiler error'})
            record=json.loads((Path(path)/'evaluation.json').read_text())
            self.assertEqual((Path(path)/'pe.csl').read_text(),'bad source')
            self.assertEqual(record['benchmark']['status'],'fail')
            self.assertIn('layout.csl',record['build_files'])

    def test_export_requires_correct_matching_cell_and_excludes_final_test(self):
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {
                "XKERNEL_CALL_ARCHIVE": tmp, "XKERNEL_CELL_ID": "c1",
                "XKERNEL_DATA_PARTITION": "development"}):
            messages = [{"role": "user", "content": "Write CSL."}]
            good = "fn work() void {}"
            archive_call({"model": "deepseek-flash", "response_model": "deepseek-flash"},
                         messages, "```csl\n" + good + "\n```")
            archive_call({"finish_reason": "length"}, messages, "```csl\npartial")
            verdict = {"code_sha256": code_hash(good), "cell_id": "c1",
                       "partition": "validation", "correct": True}
            report = export_records(tmp, [verdict], Path(tmp) / "export")
            self.assertEqual(report["counts"]["correct"], 1)
            self.assertEqual(report["counts"]["truncated"], 1)
            verdict["partition"] = "final_test"
            report = export_records(tmp, [verdict], Path(tmp) / "export2")
            self.assertEqual(report["counts"]["correct"], 0)
            verdict.update(partition="validation", cell_id="another")
            report = export_records(tmp, [verdict], Path(tmp) / "export3")
            self.assertEqual(report["counts"]["correct"], 0)

    def test_final_test_cannot_call_a_model(self):
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {
                "XKERNEL_CALL_ARCHIVE": tmp, "XKERNEL_DATA_PARTITION": "final_test"}):
            with self.assertRaisesRegex(RuntimeError, "forbidden"):
                archive_call({}, [], "x")

    def test_model_mismatch_is_preserved_and_rejected(self):
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {
                "XKERNEL_CALL_ARCHIVE": tmp, "XKERNEL_DATA_PARTITION": "development",
                "XKERNEL_EXPECT_RESPONSE_MODEL": "deepseek-flash"}):
            with self.assertRaisesRegex(RuntimeError, "identity"):
                wc._record_usage("deepseek", "deepseek-flash", [], 100, {}, "code",
                                 response_model="wrong-model")
            paths = list(Path(tmp).glob("calls/*.json"))
            self.assertEqual(len(paths), 1)
            self.assertEqual(json.loads(paths[0].read_text())["usage"]["response_model"], "wrong-model")


if __name__ == "__main__":
    unittest.main()
