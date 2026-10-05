#!/usr/bin/env python3
"""Serial MeshGEMV simulator captures, with independent history-free controls."""
import argparse
import datetime
import fcntl
from pathlib import Path
import sys

STUDY=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(STUDY))
from microbench.gemv_walkthrough.generate import CASES, PHASES, materialize
from microbench.gemm_walkthrough.capture import execute

def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--execute',action='store_true')
    ap.add_argument('--cases',nargs='+',choices=CASES,default=list(CASES));ap.add_argument('--out',type=Path)
    ap.add_argument('--sdk',type=Path,default=Path('/software/cerebras/cs_sdk-2.10'))
    a=ap.parse_args();root=(a.out or STUDY/'results/gemv-walkthrough'/datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')).resolve()
    if not a.execute:print('Simulator only:',a.cases,'output:',root,'(pass --execute to run)');return
    root.mkdir(parents=True,exist_ok=False)
    with (STUDY/'microbench/gemm_walkthrough/.capture.lock').open('w') as lock:
        fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
        for case in a.cases:
            for history in [True,False]:
                execute(case,root,history,a.sdk,cases=CASES,materializer=materialize,
                        functions=('gemv','combine',*[f'phase_{s}' for s in PHASES]),family='gemv')

if __name__=='__main__':main()
