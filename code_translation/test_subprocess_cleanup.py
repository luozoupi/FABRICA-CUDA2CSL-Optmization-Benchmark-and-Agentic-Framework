"""A timed-out generated program must not keep running after its shell exits."""
import tempfile
import time
import unittest
from pathlib import Path
from workflow_common import run_subprocess


class ProcessCleanupTest(unittest.TestCase):
    def test_timeout_kills_child_and_retains_output(self):
        with tempfile.TemporaryDirectory() as d:
            marker=Path(d)/'escaped'
            # This background child survives if only the immediate bash is killed.
            # Allow shell startup on the shared node before enforcing the timeout.
            result=run_subprocess('(sleep 5; touch escaped) & echo started; wait',cwd=d,timeout=3)
            self.assertTrue(result.timed_out)
            self.assertEqual(result.returncode,124)
            self.assertIn('started',result.stdout)
            time.sleep(2.2)
            self.assertFalse(marker.exists())

    def test_normal_output_and_failure_code(self):
        result=run_subprocess('echo output; echo error >&2; exit 7',timeout=2)
        self.assertEqual(result.returncode,7)
        self.assertEqual(result.stdout.strip(),'output')
        self.assertEqual(result.stderr.strip(),'error')


if __name__=='__main__': unittest.main()
