"""Concurrent compiler workers must retain distinct IR hand-off requests."""
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

from tools.cslc_ir import WRAPPER


class CaptureConcurrencyTests(unittest.TestCase):
    def test_overlapping_workers_keep_every_request_and_result(self):
        with tempfile.TemporaryDirectory() as d:
            root=Path(d);cap=root/'capture';wrapper=root/'cslc-backend'
            wrapper.write_text(WRAPPER.format(tool='cslc-backend',cap=str(cap)))
            real=root/'cslc-backend.real'
            real.write_text(f'#!{sys.executable}\nimport sys,time\ntime.sleep(0.05)\nsys.stdout.buffer.write(sys.stdin.buffer.read())\n')
            real.chmod(0o755)
            requests=[f'worker {i}\n'.encode() for i in range(24)]
            def run(data):
                return subprocess.run([sys.executable,wrapper],input=data,capture_output=True,check=True).stdout
            with ThreadPoolExecutor(max_workers=12) as pool:
                self.assertEqual(list(pool.map(run,requests)),requests)
            stored=list(cap.glob('*.request'))
            self.assertEqual(len(stored),len(requests))
            self.assertEqual({p.read_bytes() for p in stored},set(requests))
            for p in stored:
                self.assertEqual(p.with_suffix('.stdout').read_bytes(),p.read_bytes())
                self.assertTrue(p.with_suffix('.json').exists())


if __name__=='__main__':unittest.main()
