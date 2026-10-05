#!/usr/bin/env python3
"""Bounded Luna sparse translation/optimization pilot on the local SDK 2.10.1.

Four tasks, one generation run each, three timing repeats, and independent
replay against the original host checks plus three held-out inputs. No keys
are stored in the result tree. All SDK subprocesses use the node-wide gate.
"""
import argparse
import csv
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/'code_translation'))
from cuda2csl import KERNEL_REGISTRY
from benchmark_csl import benchmark_translated_compute_file

NAMES = ['RowScale-CSR', 'SpMV-CSR', 'SpMM-CSR-Dense', 'SpGEMM-Masked-Dot']
SDK = Path('/home/USER/cs_sdk')
SIF = SDK/'sdk-cbcore-2.10.1-sdk-202606181328-8faf87a26e.sif'


def save(path, obj):
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(path.suffix+'.tmp')
    tmp.write_text(json.dumps(obj, indent=2)+'\n')
    tmp.replace(path)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def environment():
    env = dict(os.environ)
    text = (ROOT/'run_sparse_translate_sweep.sh').read_text()
    settings = text.split('# ---------- Production stack', 1)[1].split('if [ -n "$KERNEL_LIST"', 1)[0]
    env.update(dict(re.findall(r'(XKERNEL_\w+)=(\d+)', settings)))
    env.update(XKERNEL_ROOT=str(ROOT), XKERNEL_SDK_ROOT=str(SDK),
        XKERNEL_SDK_FLAVOR='2.10', XKERNEL_TARGET_SDK='2.10.1', XKERNEL_SDK210_FIXUP='1',
        XKERNEL_SINGULARITY_GATE='1', XKERNEL_KEEP_CANDIDATES='1',
        XKERNEL_SPARSE_MAPPING='1', XKERNEL_STRUCTURE_READOUT='1', XKERNEL_SPARSE_ANGLES='1',
        XKERNEL_MODEL_GUIDED='0', XKERNEL_MODEL_ANGLES='0',
        XKERNEL_IR_CAPTURE='disasm', XKERNEL_IR_READOUT='1', XKERNEL_IR_HAZARD_POLICY='heldout',
        XKERNEL_EVAL_SEED='7', APPTAINERENV_XKERNEL_EVAL_SEED='7',
        XKERNEL_OPENAI_REASONING_EFFORT='medium', XKERNEL_OPENAI_MIN_TOKENS='8192',
        XKERNEL_LLM_TIMEOUT_S='300', XKERNEL_PYTHON=sys.executable,
        XKERNEL_TRACE_PROFILE='1', XKERNEL_PROFILE_TRAIN_REPLAY='1', CS_SDK_SIF=str(SIF),
        XKERNEL_FREEZE_MEASURED_BASELINE='1',
        OMP_NUM_THREADS='1', OPENBLAS_NUM_THREADS='1', MKL_NUM_THREADS='1')
    for k in ['OPENAI_API_KEY', 'CSL_SUPPRESS_SIMFAB_TRACE',
              'APPTAINERENV_CSL_SUPPRESS_SIMFAB_TRACE', 'SINGULARITYENV_CSL_SUPPRESS_SIMFAB_TRACE']:
        env.pop(k, None)
    # Timing repeats and held-out checks need no trace. The final training
    # replay explicitly removes these switches and records the profile once.
    env['APPTAINERENV_CSL_SUPPRESS_SIMFAB_TRACE']='1'
    env['PATH'] = f'{SDK}:/home/USER/.local/opt/apptainer-1.5.3/bin:'+env.get('PATH','')
    return env


def prepare(out):
    p = out/'inputs/manifest.json'
    if p.exists(): return json.loads(p.read_text())
    tasks = {}
    for name in NAMES:
        spec = KERNEL_REGISTRY[name]
        src = Path(spec['reference_csl_dir']); dst = out/'inputs'/name/'CSL'
        shutil.copytree(src, dst, ignore=shutil.ignore_patterns('out', 'out_*', 'simfab*', '*.log',
            '*.elf', '__pycache__', '_combined_kernel.csl'))
        shutil.copy2(src.parent/'spec.yaml', dst.parent/'spec.yaml')
        cuda = dst.parent/'kernel.cu'; shutil.copy2(spec['cuda_path'], cuda)
        tasks[name] = dict(spec, reference_csl_dir=str(dst), cuda_path=str(cuda))
    hashes = {str(p.relative_to(out/'inputs')):sha(p) for p in (out/'inputs').rglob('*') if p.is_file()}
    manifest = dict(tasks=tasks, sha256=hashes,
        source_commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
        model='gpt-5.6-luna', sdk=str(SIF), timing_repeats=3, eval_seeds=[7,101,202,303],
        translation_attempt_cap=3, optimization_attempt_cap=3,
        scope='Pilot: one generation run per task, small registered size; not a preregistered A/B study')
    save(p, manifest)
    (out/'implementation.patch').write_bytes(subprocess.check_output(['git','diff'],cwd=ROOT))
    return manifest


def bench(path, spec, work):
    result = benchmark_translated_compute_file(
        translated_path=str(path), reference_dir=spec['reference_csl_dir'],
        target_relpath=spec['target_relpath'], work_dir=str(work), sdk_root=str(SDK),
        commands_script=spec['commands_script'], keep_staged_bundle=True,
        num_runs=3, heldout_eval=True)
    save(work/'benchmark.json', result)
    return result


def passed(b):
    return (b.get('status')=='pass' and b.get('success_marker') is True
            and (b.get('heldout_eval') or {}).get('passed') is True)


def reference(out, name, spec):
    work = out/'reference'/name; p = work/'benchmark.json'
    if p.exists(): return json.loads(p.read_text())
    print('REFERENCE',name,flush=True)
    b = bench(Path(spec['reference_csl_dir'])/spec['target_relpath'], spec, work)
    print('REFERENCE_RESULT',name,b.get('status'),b.get('cycles_send'),
          (b.get('heldout_eval') or {}).get('passed'),b.get('failure_reason'),flush=True)
    return b


def run(out, name, spec):
    work=out/'pilot'/name;work.mkdir(parents=True,exist_ok=True)
    if (work/'outcome.json').exists(): return
    env=environment();env['XKERNEL_USAGE_JSONL']=str(work/'usage.jsonl')
    env['XKERNEL_EXPERIENCE_STORE']=str(work/'experience.jsonl')
    cmd=['bash',str(ROOT/'run_cuda2csl_luna.sh'),'--kernel',name,
         '--cuda',spec['cuda_path'],'--reference-csl-dir',spec['reference_csl_dir'],
         '--target-relpath',spec['target_relpath'],'--commands-script',spec['commands_script'],
         '--size','small','--reviewer-max-attempts','3','--turns','3',
         '--auto-optimize','--min-optimize-attempts','3','--max-optimize-attempts','3',
         '--num-runs','3','--optimize-num-runs','3','--profile-feedback','--keep-profile-bundles',
         '--no-measure-reference',
         '--output',str(work/'artifacts'),'--work-root',str(work/'scratch')]
    warm_start=out/'warm_starts'/name/'pe.csl'
    if warm_start.is_file():
        cmd.extend(['--optimize-only','--csl',str(warm_start)])
    save(work/'invocation.json',dict(command=cmd,environment={k:v for k,v in env.items()
         if k.startswith(('XKERNEL_','APPTAINERENV_')) and 'KEY' not in k}))
    save(out/'progress.json',dict(kernel=name,phase='generation',status='running',pid=os.getpid()))
    print('START',name,flush=True);start=time.monotonic()
    with (work/'run.log').open('w') as log:
        proc=subprocess.Popen(cmd,cwd=ROOT,env=env,stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
        save(work/'process.json',dict(pid=proc.pid))
        try: rc=proc.wait(timeout=3600)
        except subprocess.TimeoutExpired:
            # Include SDK command groups created by run_subprocess, without broad process matches.
            import psutil
            for child in reversed(psutil.Process(proc.pid).children(recursive=True)):
                try: child.kill()
                except psutil.NoSuchProcess: pass
            os.killpg(proc.pid,signal.SIGKILL);proc.wait();rc=124
    files=sorted((work/'artifacts').glob('run_*/*/benchmark.json'))
    artifact=files[-1].parent if files else None
    b=json.loads(files[-1].read_text()) if files else {}
    calls=[json.loads(x) for x in (work/'usage.jsonl').read_text().splitlines()] if (work/'usage.jsonl').exists() else []
    result=dict(kernel=name,returncode=rc,status='pass' if rc==0 and passed(b) else 'failed',
        elapsed_s=round(time.monotonic()-start,3),cycles=b.get('cycles_send'),
        heldout_passed=(b.get('heldout_eval') or {}).get('passed'),failure_reason=b.get('failure_reason'),
        api_calls=len(calls),input_tokens=sum(x.get('input_tokens') or 0 for x in calls),
        output_tokens=sum(x.get('output_tokens') or 0 for x in calls),
        cached_input_tokens=sum(x.get('cache_read_input_tokens') or 0 for x in calls),
        response_models=sorted({x['response_model'] for x in calls if x.get('response_model')}),
        artifact_dir=str(artifact) if artifact else None)
    save(work/'outcome.json',result);print('DONE',json.dumps(result),flush=True)


def audit(out, name, spec):
    result_path=out/'pilot'/name/'outcome.json'
    if not result_path.exists(): return
    result=json.loads(result_path.read_text())
    if not result.get('artifact_dir'): return
    artifact=Path(result['artifact_dir'])
    for arm,path in [('w1',artifact/'candidates/attempt_00_baseline'/spec['target_relpath']),
                     ('final',artifact/spec['target_relpath'])]:
        if not path.is_file(): continue
        work=out/'audit'/name/arm
        if (work/'benchmark.json').exists(): continue
        print('AUDIT',name,arm,flush=True)
        before=sha(path);b=bench(path,spec,work);assert sha(path)==before
        save(work/'source.json',dict(path=str(path),sha256=before))
        print('AUDIT_RESULT',name,arm,b.get('status'),b.get('cycles_send'),
              (b.get('heldout_eval') or {}).get('passed'),flush=True)


def summarize(out):
    rows=[]
    for name in NAMES:
        p=out/'pilot'/name/'outcome.json'
        if not p.exists(): continue
        r=json.loads(p.read_text())
        ref=json.loads((out/'reference'/name/'benchmark.json').read_text())
        r['reference_cycles']=ref.get('cycles_send')
        for arm in ['w1','final']:
            p=out/'audit'/name/arm/'benchmark.json'
            b=json.loads(p.read_text()) if p.exists() else {}
            r[arm+'_audited_pass']=passed(b);r[arm+'_audited_cycles']=b.get('cycles_send')
        r['speedup']=r['reference_cycles']/r['final_audited_cycles'] if r['final_audited_pass'] else None
        rows.append(r)
    save(out/'summary.json',rows)
    if rows:
        with (out/'summary.csv').open('w',newline='') as f:
            w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out',type=Path,default=ROOT/'code_translation/results/luna_sparse_20260920')
    p.add_argument('--phase',choices=['prepare','reference','run','audit','all'],default='all')
    p.add_argument('--names',nargs='+',choices=NAMES,default=NAMES)
    a=p.parse_args();out=a.out.resolve();os.environ.update(environment());manifest=prepare(out)
    # Record the actual local integration used by each phase, including files
    # that are not committed yet, without reading credentials or environment secrets.
    sources=['tools/luna_sparse_smoke.py','run_cuda2csl_luna.sh',
             'code_translation/workflow_common.py','code_translation/benchmark_csl.py',
             'code_translation/cuda2csl.py','code_translation/contract_check.py',
             'code_translation/ir_capture.py','tools/fetch_suitesparse.py']
    save(out/('configuration_'+a.phase+'.json'),dict(python=sys.version,
         source_sha256={s:sha(ROOT/s) for s in sources},names=a.names,
         model='gpt-5.6-luna',reasoning_effort='medium'))
    (out/('implementation_'+a.phase+'.patch')).write_bytes(
        subprocess.check_output(['git','diff'],cwd=ROOT))
    if a.phase=='prepare': return
    for name in a.names:
        spec=manifest['tasks'][name]
        if a.phase in ['reference','all']:
            if not passed(reference(out,name,spec)):
                raise RuntimeError('Reference preflight failed: '+name)
        if a.phase in ['run','all']:
            if not passed(reference(out,name,spec)):
                raise RuntimeError('Reference preflight failed: '+name)
            run(out,name,spec)
        if a.phase in ['audit','all']: audit(out,name,spec)
        summarize(out)
    save(out/'progress.json',dict(phase=a.phase,status='completed',names=a.names))


if __name__=='__main__': main()
