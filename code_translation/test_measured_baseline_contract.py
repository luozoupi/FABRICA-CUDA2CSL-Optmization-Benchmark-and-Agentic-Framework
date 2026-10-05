"""Freeze a translated wrapper without importing hidden reference dependencies."""
import unittest
from contract_check import splice_frozen_functions, validate_against_reference

REFERENCE = '''param nrows: u16; param iters: u16;
fn compute() void { tic(); for (@range(u16,iters)) |_| { rowscale(); } toc(); }
'''
BASELINE = '''param nrows: u16;
fn compute() void { tic(); translated_rowscale(); toc(); }
fn translated_rowscale() void { work(); }
'''

class MeasuredBaselineContractTests(unittest.TestCase):
    def check(self, candidate, baseline=BASELINE):
        return validate_against_reference(candidate, REFERENCE, ['compute'],
                                          ['nrows','iters'], frozen_function_src=baseline)

    def test_wrapper_preserves_translation_dependencies(self):
        candidate=BASELINE.replace('tic(); translated_rowscale(); toc();','translated_rowscale();')
        fixed,names=splice_frozen_functions(candidate,BASELINE,['compute'])
        self.assertEqual(names,['compute'])
        self.assertIsNone(self.check(fixed))
        self.assertNotIn('@range',fixed)
        self.assertIn('translated_rowscale();',fixed)

    def test_missing_or_modified_wrapper_is_rejected(self):
        self.assertIn('missing',self.check(BASELINE.replace('fn compute','fn elsewhere')))
        self.assertIn('body changed',self.check(BASELINE.replace('tic();','')))

    def test_original_workload_params_remain_protected(self):
        self.assertIn("FROZEN param 'iters'",self.check(BASELINE+'const iters = 0;'))

    def test_default_still_freezes_human_reference(self):
        self.assertIsNotNone(validate_against_reference(BASELINE,REFERENCE,['compute'],['nrows','iters']))

    def test_reference_device_timing_protocol_remains_required(self):
        reference='fn f_tic_dev() void {} fn f_toc_dev() void {}'
        violation=validate_against_reference(BASELINE,reference,[],[],frozen_function_src=BASELINE)
        self.assertIn('helpers missing',violation)

    def test_absent_baseline_helper_does_not_disable_reference_guard(self):
        baseline=BASELINE.replace('fn compute','fn elsewhere')
        self.assertIn("FROZEN function 'compute' is missing",self.check(baseline,baseline=baseline))

if __name__=='__main__': unittest.main()
