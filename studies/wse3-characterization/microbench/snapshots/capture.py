#!/usr/bin/env python3
"""Run bounded one/two-PE simulator probes in fresh directories; never uses hardware."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess

ROOT=Path(__file__).resolve().parents[2]

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out',type=Path,required=True)
    ap.add_argument('--with-gemm',action='store_true',help='Also snapshot the retained g1 four-PE GEMM ELF')
    a=ap.parse_args();dest=a.out.resolve();dest.mkdir(parents=True,exist_ok=False)
    env=dict(os.environ,PATH='/home/USER/bin:'+os.environ['PATH'])
    sdk=Path('/software/cerebras/cs_sdk-2.10')
    for kind in ['single','relay']:
        work=dest/kind;work.mkdir()
        (work/'case.json').write_text(json.dumps({'kind':kind,'pes':1 if kind=='single' else 2}))
        shutil.copy2(Path(__file__).with_name('run.py'),work/'run.py')
        for script in ['validate_dump.py','stopped_phases.py']:
            shutil.copy2(Path(__file__).with_name(script),work/script)
        src=Path(__file__).parent if kind=='single' else ROOT/'microbench/readiness'
        for name in (['layout.csl','single.csl'] if kind=='single' else ['layout.csl','pe.csl']):
            shutil.copy2(src/name,work/name)
        args=[str(sdk/'cslc'),'layout.csl','--arch=wse3',f'--fabric-dims={8 if kind=="single" else 9},3',
              '--fabric-offsets=4,1','-o','out','--memcpy','--channels=1','--width-west-buf=0','--width-east-buf=0','--out-routes']
        if kind=='relay':args+=['--params=B:1']
        commands=[args,[str(sdk/'cs_python'),'run.py'],
                  ['python',str(ROOT/'tools/decode_trace.py'),'.','-o','events.jsonl.gz'],
                  [str(sdk/'cs_python'),'validate_dump.py'],
                  [str(sdk/'cs_python'),'stopped_phases.py','--phase','loaded'],
                  [str(sdk/'cs_python'),'stopped_phases.py','--phase','computed']]
        for cmd in commands:
            print(kind,cmd,flush=True)
            with (work/'capture.log').open('a') as f:
                subprocess.run(cmd,cwd=work,env=env,stdout=f,stderr=subprocess.STDOUT,check=True,timeout=600)
        manifest={str(p.relative_to(work)):hashlib.sha256(p.read_bytes()).hexdigest()
                  for p in work.rglob('*') if p.is_file()}
        (work/'manifest.json').write_text(json.dumps({'commands':commands,'sha256':manifest},indent=2))
    if a.with_gemm:
        work=dest/'gemm'
        subprocess.run(['python',str(Path(__file__).with_name('prepare_gemm.py')),'--out',str(work)],check=True)
        for phase in ['loaded','computed']:
            with (work/f'{phase}.log').open('w') as f:
                subprocess.run([str(sdk/'cs_python'),'stopped_phases.py','--phase',phase],cwd=work,env=env,stdout=f,stderr=subprocess.STDOUT,check=True,timeout=600)
        subprocess.run(['python',str(ROOT/'tools/snapshot_summary.py'),'--root',str(dest),'--out',str(dest/'summary.json')],check=True)

if __name__=='__main__':main()
