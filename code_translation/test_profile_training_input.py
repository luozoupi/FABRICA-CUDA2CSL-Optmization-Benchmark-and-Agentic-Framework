"""Execution profiles must describe training inputs after held-out validation."""
import os
from pathlib import Path
import tempfile
import unittest
from unittest import mock

import benchmark_csl as bc


class ProfileTrainingInputTests(unittest.TestCase):
    def run_case(self, heldout_ok=True, train_ok=True, compile_only=False):
        with tempfile.TemporaryDirectory() as td:
            root=Path(td);ref=root/'reference/CSL';ref.mkdir(parents=True)
            (ref/'pe.csl').write_text('fn compute() void {}\n')
            (ref/'commands.sh').write_text('cslc layout.csl -o out\ncs_python run.py --name out\n')
            (ref.parent/'spec.yaml').write_text('eval:\n  train_seed: 7\n  heldout_seeds: [101, 202, 303]\n')
            staged=dict(status='pass',failure_reason=None,compile_time_ms=1,run_time_ms=1,
                cycles_send=100,success_marker=True,transcript=[],script_command='commands.sh',
                script_elapsed_ms=2,shell_setup_applied=False)
            with mock.patch.dict(os.environ,{'XKERNEL_HELDOUT_EVAL':'1','XKERNEL_PROFILE_TRAIN_REPLAY':'1'}), \
                 mock.patch.object(bc,'run_staged_bundle',return_value=staged), \
                 mock.patch.object(bc,'evaluate_heldout',side_effect=[{'passed':heldout_ok},{'passed':train_ok}]) as check:
                result=bc.benchmark_translated_compute_file(str(ref/'pe.csl'),str(ref),'pe.csl',
                    str(root/'work'),'/sdk',commands_script='commands.sh',keep_staged_bundle=True,
                    compile_only=compile_only)
            return result,check.call_args_list

    def test_restores_training_input_after_heldout_checks(self):
        result,calls=self.run_case()
        self.assertEqual(result['status'],'pass')
        self.assertEqual(calls[0].kwargs['heldout_seeds'],[101,202,303])
        self.assertEqual(calls[1].args[2],[7])
        self.assertTrue(calls[1].kwargs['enable_trace'])
        self.assertEqual(result['profile_input_seed'],7)

    def test_failed_heldout_is_not_replaced_by_training_pass(self):
        result,calls=self.run_case(heldout_ok=False)
        self.assertEqual(result['status'],'fail')
        self.assertEqual(len(calls),1)

    def test_failed_training_replay_rejects_the_profile(self):
        result,_=self.run_case(train_ok=False)
        self.assertEqual(result['status'],'fail')
        self.assertEqual(result['failure_reason'],'profile_train_replay_failed')

    def test_compile_only_does_not_run_heldout_simulations(self):
        result,calls=self.run_case(compile_only=True)
        self.assertEqual(result['status'],'pass')
        self.assertEqual(calls,[])


if __name__=='__main__':unittest.main()
