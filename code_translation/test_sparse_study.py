import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('sparse_study', ROOT/'tools/sparse_study.py')
study = importlib.util.module_from_spec(spec); spec.loader.exec_module(study)
from profile_csl import _parse_sim_log
import workflow_common as wc
import benchmark_csl as bc


class SparseStudyTests(unittest.TestCase):
    def test_strict_validation_requires_seed_echo_and_success(self):
        with tempfile.TemporaryDirectory() as d, patch.dict(os.environ, {'XKERNEL_STRICT_VALIDATION':'1'}):
            (Path(d)/'commands_wse3.sh').write_text('cs_python run.py --name out\n')
            for stdout,success in [('SUCCESS',True), ('eval_seed = 101',False),
                                   ('eval_seed = 7\nSUCCESS',True)]:
                with patch.object(bc,'_run_step_command',return_value={
                        'ok':True,'returncode':0,'stdout':stdout,'stderr':'','success_marker':success}):
                    result=bc.evaluate_heldout(d,'commands_wse3.sh',[101],'/unused')
                    self.assertFalse(result['passed'])

    def test_main_study_cannot_start_without_shared_inputs_and_evidence(self):
        with tempfile.TemporaryDirectory() as d:
            with self.assertRaisesRegex(RuntimeError, 'agreement'):
                study.require_full_study_admission(Path(d),
                    {'source_commit':'abc','protocol_sha256':'def'})

    def test_frozen_cell_counts_and_uniqueness(self):
        protocol = json.loads(study.DEFAULT_PROTOCOL.read_text())
        for phase, n in [('smoke',4),('translate',70),('optimize',105),('ablate',24)]:
            cells=study.cells(protocol,phase,'deepseek')
            self.assertEqual(len(cells),n);self.assertEqual(len(set(cells)),n)

    def test_conditions_change_only_the_intended_guidance(self):
        full=study.condition_environment('O1')
        for condition,key in [('O1_no_structure','XKERNEL_STRUCTURE_READOUT'),
                              ('O1_no_hardware_cost','XKERNEL_MODEL_GUIDED')]:
            reduced=study.condition_environment(condition)
            self.assertEqual({k for k in full if full[k]!=reduced[k]},{key})
        self.assertEqual(study.condition_environment('O0')['XKERNEL_IR_READOUT'],'0')
        self.assertEqual(study.condition_environment('O1I')['XKERNEL_IR_READOUT'],'1')

    def test_no_trace_is_not_zero_activity(self):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'sim.log';p.write_text('CTF Stats: num_inst_dispatch = 0\nCTF Stats: num_wavelets = 0\n')
            r=_parse_sim_log(str(p))
            self.assertFalse(r['counters_available'])
            self.assertIsNone(r['ctf_stats']['num_inst_dispatch'])
            self.assertEqual(r['bottleneck_label'],'unavailable')

    def test_final_test_is_rejected_before_api_access(self):
        with patch.dict(os.environ,{'XKERNEL_DATA_PARTITION':'final_test'}):
            with self.assertRaisesRegex(RuntimeError,'forbidden'):
                wc.llm_complete(object(),'deepseek-flash',[],100)


if __name__=='__main__':unittest.main()
