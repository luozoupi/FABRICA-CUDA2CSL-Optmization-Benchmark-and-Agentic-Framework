#!/usr/bin/env python3
"""Serial tiny simulator captures. Requires --execute; uses unique run directories."""
from __future__ import annotations
import argparse
import datetime
import fcntl
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time
if __package__:
    from .generate import CASES, materialize
else:
    from generate import CASES, materialize

STUDY = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(STUDY))
from wse3study.inventory import _Elf64


def execute(case, root, history, sdk, *, cases=CASES, materializer=materialize,
            functions=('gemm',), family='gemm'):
    n,p = cases[case]
    work = root / f'{case}-{"history" if history else "control"}'
    materializer(case,work,history)
    env = dict(os.environ, PATH=f'{sdk}:/usr/bin:/bin:'+os.environ['PATH'])
    tmp = work / 'scratch';tmp.mkdir()
    # The existing IR interceptor recognizes /tmp/cslc-* hand-off directories.
    # This script runs on the SDK node itself, so its /tmp is container-visible.
    env['TMPDIR'] = '/tmp'
    log = work / 'capture.log'
    commands=[]
    def run(argv):
        commands.append([str(x) for x in argv])
        print('RUN',work.name,' '.join(str(x) for x in argv),flush=True)
        with log.open('a') as f:
            subprocess.run([str(x) for x in argv],cwd=work,env=env,stdout=f,stderr=subprocess.STDOUT,check=True,timeout=900)
    args = ['./layout.csl','--arch=wse3',f'--fabric-dims={8 if p==1 else 9},{3 if p==1 else 4}',
            '--fabric-offsets=4,1',f'--params=N:{n},P:{p},HISTORY:{int(history)}','-o','out','--memcpy',
            '--channels=1','--width-west-buf=0','--width-east-buf=0','--out-routes']
    run([sys.executable,STUDY/'tools/cslc_ir.py','capture','-o','ir','--',*args])
    originals={}; ir_by_elf={}
    for cap in sorted((work/'ir').glob('*')):
        mp=cap/'meta.json'
        if not mp.exists():continue
        meta=json.loads(mp.read_text());elf=Path(meta['elf'])
        originals[str(elf.relative_to(work))]=hashlib.sha256(elf.read_bytes()).hexdigest()
        ir=(cap/'program.ll').read_text()
        selected=[fn for fn in functions if f'define internal void @{fn}(' in ir]
        if functions[0] not in selected:continue
        ir_by_elf[str(elf.relative_to(work))]=str(cap.relative_to(work))
        shutil.copy2(elf,cap/'original.elf')
        flags=[flag for fn in selected for flag in ['--optnone',fn]]
        run([sys.executable,STUDY/'tools/cslc_ir.py','rebuild',cap,*flags,'--keep-work','-o',elf])
    placement={}
    width=8 if p==1 else 9
    for elf in sorted((work/'out/bin').glob('*.elf')):
        rel=str(elf.relative_to(work))
        if rel not in ir_by_elf:raise RuntimeError(f'Application IR missing: {rel}')
        for tile in _Elf64(elf).program_tile_ids():
            x,y=tile%width-4,tile//width-1
            if not (0<=x<p and 0<=y<p):raise RuntimeError('Unexpected application placement')
            key=f'{x},{y}'
            if key in placement:raise RuntimeError('Duplicate application placement')
            placement[key]={'elf':rel,'ir':ir_by_elf[rel],'tile':tile,'fabric':[x+4,y+1]}
    if len(placement)!=p*p:raise RuntimeError('Incomplete application placement')
    (work/'placement.json').write_text(json.dumps(placement,indent=2))
    run([sdk/'cs_python','run.py'])
    for _ in range(30):
        if (work/'simfab_traces/stream0').exists():break
        time.sleep(1)
    run([sys.executable,STUDY/'tools/decode_trace.py','.', '-o','events.jsonl.gz'])
    for y in range(p):
        for x in range(p):
            run([sys.executable,STUDY/'tools/csdisasm.py',placement[f'{x},{y}']['elf'],'--json',f'disasm_{x}_{y}.json'])
    hashes={}
    for path in work.rglob('*'):
        if path.is_file() and 'scratch' not in path.parts and path.name!='capture.log':
            h=hashlib.sha256()
            with path.open('rb') as f:
                for b in iter(lambda:f.read(1024*1024),b''):h.update(b)
            hashes[str(path.relative_to(work))]=h.hexdigest()
    manifest={'schema':f'{family}-run/1','case':case,'history':history,'mode':'optnone '+', '.join(functions),
              'sdk':str(sdk),'sif':[str(s) for s in sdk.glob('*.sif')],
              'commands':commands,'original_elf_sha256':originals,'sha256':hashes}
    (work/'manifest.json').write_text(json.dumps(manifest,indent=2))
    print('COMPLETE',work,flush=True)


def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--execute',action='store_true')
    ap.add_argument('--cases',nargs='+',choices=CASES,default=list(CASES))
    ap.add_argument('--out',type=Path)
    ap.add_argument('--sdk',type=Path,default=Path('/software/cerebras/cs_sdk-2.10'))
    ap.add_argument('--history-only',action='store_true')
    a=ap.parse_args()
    root=(a.out or STUDY/'results/gemm-walkthrough'/datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')).resolve()
    if not a.execute:
        print(json.dumps({'cases':a.cases,'out':str(root),'hardware':False,'execute':False},indent=2));return
    root.mkdir(parents=True,exist_ok=False)
    with (STUDY/'microbench/gemm_walkthrough/.capture.lock').open('w') as lock:
        fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
        for case in a.cases:
            execute(case,root,True,a.sdk)
            if not a.history_only:execute(case,root,False,a.sdk)


if __name__=='__main__':main()
