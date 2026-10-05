"""The translation CLI repeat count must reach the actual benchmark harness."""
import tempfile
import unittest
from types import SimpleNamespace
from unittest import mock
import cuda2csl

class TranslationTimingRepeatsTests(unittest.TestCase):
    def check_repeats(self, explicit, expected):
        with tempfile.TemporaryDirectory() as td:
            o=SimpleNamespace(work_root=td,num_runs=3,sdk_root='/sdk',shell_setup=None,
                commands_script='commands.sh',arch='wse3',profile_feedback_enabled=False,
                run_log=[],_last_benchmark=None,_exp_store=mock.Mock(),model='test',current_code='')
            with mock.patch.object(cuda2csl,'benchmark_translated_compute_file',return_value={'status':'fail'}) as bench:
                cuda2csl.CUDA2CSLOrchestrator._benchmark_current_code(o,'test','fn compute() void {}',
                    td,'pe.csl',**({} if explicit is None else {'num_runs':explicit}))
            self.assertEqual(bench.call_args.kwargs['num_runs'],expected)

    def test_uses_configured_translation_repeats(self):
        self.check_repeats(None,3)

    def test_explicit_optimizer_repeats_override_translation_count(self):
        self.check_repeats(5,5)

if __name__=='__main__': unittest.main()
