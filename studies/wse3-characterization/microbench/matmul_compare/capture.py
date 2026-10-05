#!/usr/bin/env python3
"""Serial simulator capture on the SDK user node; never submits hardware work."""
import argparse,fcntl,hashlib,json,os,signal,subprocess,sys
from pathlib import Path
from generate import materialize
ROOT=Path(__file__).resolve().parents[2];SDK=Path('/software/cerebras/cs_sdk-2.10')
def execute(root,sizes):
    env=dict(os.environ,PATH=f'{SDK}:/usr/bin:/bin:'+os.environ['PATH'],TMPDIR='/tmp')
    with (ROOT/'microbench/matmul_compare/.capture.lock').open('w') as lock:
        fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
        for n in sizes:
            work=root/f'n{n}'
            if not work.exists():materialize(n,work)
            if (work/'capture.json').exists():raise RuntimeError(f'Already captured: {work}')
            commands=[]
            def run(args,log):
                args=list(map(str,args));commands.append(args);print('RUN',n,log,flush=True)
                with (work/log).open('w') as f:
                    process=subprocess.Popen(args,cwd=work,env=env,stdout=f,stderr=subprocess.STDOUT,start_new_session=True)
                    try:code=process.wait(timeout=600)
                    except subprocess.TimeoutExpired:
                        os.killpg(process.pid,signal.SIGTERM);raise
                    if code:raise RuntimeError(f'{log} exited {code}')
            run([sys.executable,ROOT/'tools/cslc_ir.py','capture','-o','ir','--','./layout.csl','--arch=wse3','--fabric-dims=8,3','--fabric-offsets=4,1','-o','out','--memcpy','--channels=1','--width-west-buf=0','--width-east-buf=0'],'compile.log')
            run([SDK/'cs_python','run.py',*(['--no-trace'] if n>=16 else [])],'run.log')
            if n<=8:run([sys.executable,ROOT/'tools/decode_trace.py','.', '-o','events.jsonl.gz'],'decode.log')
            elf=work/'out/bin/out_0_0.elf'
            run([sys.executable,ROOT/'tools/csdisasm.py',elf,'--json','disasm.json'],'disasm.log')
            files=[p for p in work.rglob('*') if p.is_file() and p.name!='manifest.json' and '_bin' not in p.parts]
            (work/'manifest.json').write_text(json.dumps(dict(schema='matmul-compare-manifest/1',commands=commands,sdk=str(SDK),sha256={str(p.relative_to(work)):hashlib.file_digest(p.open('rb'),'sha256').hexdigest() for p in files}),indent=2))
            print('COMPLETE',n,flush=True)
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--root',type=Path,required=True);p.add_argument('--sizes',nargs='+',type=int,choices=[4,8,16,32],default=[4,8,32]);a=p.parse_args();execute(a.root.resolve(),a.sizes)
