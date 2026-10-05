#!/usr/bin/env python3
"""Run local measurement/export follow-ups after the active smoke releases its lock.

Does not admit main model cells or launch another provider. Every step has its own
log and terminal record. The process can run detached in a pinned checkout.
"""
import argparse,json,subprocess,sys,time
from pathlib import Path
from filelock import FileLock
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
from sparse_study import save

def main():
    p=argparse.ArgumentParser(description=__doc__)
    for flag in ('study','strong','weak','out'):p.add_argument('--'+flag,type=Path,required=True)
    a=p.parse_args();a.out.mkdir(parents=True,exist_ok=True)
    with FileLock(str(a.out/'worker.lock'),timeout=1):
        save(a.out/'progress.json',dict(status='waiting_for_smoke',started=time.time()))
        with FileLock(str(a.study/'.deepseek.lock'),timeout=-1):pass
        steps=[('strong_measure',[sys.executable,str(ROOT/'tools/sparse_strong_scaling.py'),'--study',str(a.study),'--out',str(a.strong),'--run','measure']),
               ('weak_measure',[sys.executable,str(ROOT/'tools/sparse_strong_scaling.py'),'--study',str(a.study),'--out',str(a.weak),'--kind','weak','--run','measure']),
               ('training_export',[sys.executable,str(ROOT/'tools/export_model_artifacts.py'),'--archive',str(a.study/'cells'),
                  '--evaluations',str(a.study/'development_evaluations.jsonl'),'--out',str(a.study/'training_export_v1')])]
        for name,command in steps:
            outcome=a.out/(name+'.json')
            if outcome.exists():continue
            save(a.out/'progress.json',dict(status='running',step=name,command=command,started=time.time()))
            start=time.time()
            with (a.out/(name+'.log')).open('a') as log:
                result=subprocess.run(command,cwd=ROOT,stdout=log,stderr=subprocess.STDOUT)
            save(outcome,dict(step=name,returncode=result.returncode,elapsed_s=time.time()-start,command=command))
        records=[json.loads((a.out/(name+'.json')).read_text()) for name,_ in steps]
        save(a.out/'progress.json',dict(status='completed' if all(r['returncode']==0 for r in records) else 'completed_with_errors',steps=records))

if __name__=='__main__':main()
