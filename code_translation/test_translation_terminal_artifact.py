import os
from types import SimpleNamespace
import unittest
from unittest.mock import Mock,patch
import cuda2csl as c

class TerminalArtifactTests(unittest.TestCase):
    def test_exhausted_budget_returns_the_tested_program_without_another_repair(self):
        tested='fn compute() void {}';failure={'status':'fail','failure_reason':'compile_error'}
        o=SimpleNamespace(codesign_layout=False,cuda_analysis='analysis',decomposition_plan='plan',
            kernel_group='',_compute_canary=None,messages=[],skip_reviewer=False,
            reviewer_max_attempts=1,turns_limit=1,
            _set_compute_canary=Mock(),_append=Mock(),_llm_call=Mock(return_value=tested),
            _extract_translation=Mock(return_value=tested),
            _benchmark_current_code=Mock(return_value=failure),review_failure=Mock())
        with patch.dict(os.environ,{'XKERNEL_DRY_CHECK':'0','XKERNEL_BEST_OF_N':'1','XKERNEL_TRANSLATION_FACTS':'0'}),patch.object(c.csl_knowledge_base,'for_implementer',return_value=''):
            program,result=c.CUDA2CSLOrchestrator.translate(o,'K','CUDA','/unused','pe.csl','interface','reference')
        self.assertEqual(program,tested);self.assertIs(result,failure)
        o._llm_call.assert_called_once();o._benchmark_current_code.assert_called_once()
        o.review_failure.assert_not_called()

if __name__=='__main__':unittest.main()
