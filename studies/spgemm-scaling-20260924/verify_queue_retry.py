"""Check admission retries and preservation of failed SDK evidence, without an SDK run."""
from pathlib import Path
import tempfile,unittest
from queue_retry import run_with_admission_retry

class AdmissionTests(unittest.TestCase):
    def test_contention_retries_until_admitted(self):
        with tempfile.TemporaryDirectory() as tmp:
            calls=[];events=[]
            def operation(path):
                calls.append(path)
                if len(calls)<3:raise TimeoutError('simulator queue wait')
                return {'status':'pass'}
            result=run_with_admission_retry(Path(tmp),operation,events.append)
            self.assertEqual(len(calls),3);self.assertEqual(result,{'status':'pass'})
            self.assertEqual(len(events),2);self.assertTrue(all(not e['phase_launched'] and e['wait_seconds']>=0 for e in events))
    def test_unrelated_timeout_is_not_retried(self):
        with tempfile.TemporaryDirectory() as tmp:
            events=[]
            def operation(path):raise TimeoutError('SDK execution timeout')
            with self.assertRaisesRegex(TimeoutError,'SDK execution timeout'):run_with_admission_retry(Path(tmp),operation,events.append)
            self.assertEqual(events,[])
    def test_partial_sdk_artifacts_block_admission_retry(self):
        with tempfile.TemporaryDirectory() as tmp:
            p=Path(tmp);(p/'run.log').write_text('retained output');events=[]
            def operation(path):raise TimeoutError('simulator queue wait')
            with self.assertRaisesRegex(RuntimeError,'SDK artifacts exist'):run_with_admission_retry(p,operation,events.append)
            self.assertEqual((p/'run.log').read_text(),'retained output');self.assertEqual(events,[])
    def test_sdk_failure_result_is_returned_once(self):
        with tempfile.TemporaryDirectory() as tmp:
            calls=[]
            def operation(path):calls.append(path);return {'status':'run_failed'}
            self.assertEqual(run_with_admission_retry(Path(tmp),operation,lambda event:None),{'status':'run_failed'})
            self.assertEqual(len(calls),1)
if __name__=='__main__':unittest.main()
