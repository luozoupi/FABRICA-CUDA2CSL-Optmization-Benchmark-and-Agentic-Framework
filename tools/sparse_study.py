#!/usr/bin/env python3
"""Frozen, resumable two-provider sparse study; each node runs its assigned model.

prepare -> preflight -> smoke -> translate -> freeze-starts -> optimize -> audit.
Every phase writes durable outcomes; no completed cell is silently rerolled.
"""
from __future__ import annotations
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
sys.path.insert(0, str(ROOT / 'code_translation'))
from benchmark_csl import benchmark_translated_compute_file
from cuda2csl import KERNEL_REGISTRY
from model_artifacts import code_hash, canonical_hash

DEFAULT_PROTOCOL = ROOT / 'studies/ipdps_sparse_20260921/protocol.json'
GATES = ['SPARSE_MAPPING', 'STRUCTURE_READOUT', 'SPARSE_ANGLES', 'MODEL_GUIDED',
         'MODEL_ANGLES', 'IR_READOUT']


def sha(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as f:
        for block in iter(lambda: f.read(8 * 1024 * 1024), b''): h.update(block)
    return h.hexdigest()


def save(path, obj):
    path = Path(path); path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_suffix(path.suffix + '.tmp')
    temp.write_text(json.dumps(obj, indent=2) + '\n'); temp.replace(path)


def read(path, default=None):
    return json.loads(Path(path).read_text()) if Path(path).is_file() else default


def passed(b):
    return (b.get('status') == 'pass' and b.get('success_marker') is True
            and (b.get('heldout_eval') or {}).get('passed') is True)


def condition_environment(condition):
    env = {'XKERNEL_' + g: '0' for g in GATES}
    if condition in ('T1', 'smoke', 'O1', 'O1I', 'O1_no_structure', 'O1_no_hardware_cost'):
        env.update(XKERNEL_SPARSE_MAPPING='1', XKERNEL_STRUCTURE_READOUT='1')
    if condition in ('O1', 'O1I', 'O1_no_structure', 'O1_no_hardware_cost'):
        env.update(XKERNEL_SPARSE_ANGLES='1', XKERNEL_MODEL_GUIDED='1', XKERNEL_MODEL_ANGLES='1')
    if condition in ('O1I', 'smoke'):
        env['XKERNEL_IR_READOUT'] = '1'
    if condition == 'smoke': env['XKERNEL_SPARSE_ANGLES'] = '1'
    if condition == 'O1_no_structure': env['XKERNEL_STRUCTURE_READOUT'] = '0'
    if condition == 'O1_no_hardware_cost': env['XKERNEL_MODEL_GUIDED'] = '0'
    return env


def cells(protocol, phase, provider):
    if phase == 'smoke':
        return [(k, 'smoke', 1) for k in protocol['smoke_tasks']]
    if phase == 'translate':
        conditions, tasks, count = protocol['translation_conditions'], protocol['tasks'], protocol['repetitions']
    elif phase == 'optimize':
        conditions, tasks, count = protocol['optimization_conditions'], protocol['tasks'], protocol['repetitions']
    elif phase == 'ablate':
        conditions, tasks, count = protocol['ablation_conditions'], protocol['ablation_tasks'], protocol['ablation_repetitions']
    else: return []
    # Complete one repetition across the suite before the next. Reverse arms
    # on alternate repetitions to limit time/order effects on provider service.
    return [(task, cond, rep) for rep in range(1, count + 1) for task in tasks
            for cond in (conditions if rep % 2 else list(reversed(conditions)))]


def require_full_study_admission(out, manifest):
    admission = read(out/'full_study_admission.json', {})
    if (admission.get('framework_commit') != manifest['source_commit'] or
            admission.get('protocol_sha256') != manifest['protocol_sha256'] or
            admission.get('inputs_sha256') != manifest.get('inputs_sha256')):
        raise RuntimeError('Full study awaits recorded agreement on revision, protocol and inputs; see study README')
    for gate in ('nvidia_node_acknowledged', 'wse_node_acknowledged',
                 'final_test_manifest_frozen', 'repeated_launch_validation_passed',
                 'timing_scope_audited'):
        if admission.get(gate) is not True:
            raise RuntimeError('Full study prerequisite incomplete: '+gate)
    for field in ('final_test_manifest', 'repeated_launch_report', 'timing_audit_report'):
        evidence = admission.get(field, {})
        path = out/str(evidence.get('path', ''))
        if not path.is_file() or sha(path) != evidence.get('sha256'):
            raise RuntimeError('Missing or changed admission evidence: '+field)


def base_environment(protocol, sdk):
    env = dict(os.environ)
    # Preserve the actual production switches in one pinned source revision.
    text = (ROOT / 'run_sparse_translate_sweep.sh').read_text()
    block = text.split('# ---------- Production stack', 1)[1].split('if [ -n "$KERNEL_LIST"', 1)[0]
    env.update(dict(re.findall(r'(XKERNEL_\w+)=(\d+)', block)))
    env.update(XKERNEL_ROOT=str(ROOT), XKERNEL_SDK_ROOT=str(sdk), XKERNEL_SDK_FLAVOR='2.10',
               XKERNEL_TARGET_SDK=protocol['sdk']['target'], XKERNEL_SDK210_FIXUP='1',
               XKERNEL_SINGULARITY_GATE='1', XKERNEL_KEEP_CANDIDATES='1',
               XKERNEL_HELDOUT_EVAL='1', XKERNEL_STRICT_VALIDATION='1',
               XKERNEL_IR_CAPTURE='best', XKERNEL_IR_HAZARD_POLICY='heldout',
               XKERNEL_TRACE_PROFILE='1', XKERNEL_PROFILE_TRAIN_REPLAY='1',
               XKERNEL_FREEZE_MEASURED_BASELINE='1', XKERNEL_EVAL_SEED='7',
               APPTAINERENV_XKERNEL_EVAL_SEED='7', XKERNEL_LLM_TIMEOUT_S='600',
               XKERNEL_LLM_TOKEN_CAP=str(protocol['token_cap']),
               XKERNEL_DEEPSEEK_MIN_TOKENS='65536', XKERNEL_DEEPSEEK_RETRY_TOKENS='65536',
               XKERNEL_DEEPSEEK_THINKING='enabled', XKERNEL_DEEPSEEK_EFFORT='high',
               XKERNEL_OPENAI_MIN_TOKENS='16384', XKERNEL_OPENAI_REASONING_EFFORT='medium',
               XKERNEL_DATA_PARTITION='development', OMP_NUM_THREADS='1', OPENBLAS_NUM_THREADS='1', MKL_NUM_THREADS='1')
    for k in ('OPENAI_API_KEY', 'CSL_SUPPRESS_SIMFAB_TRACE', 'SINGULARITYENV_CSL_SUPPRESS_SIMFAB_TRACE'):
        env.pop(k, None)
    env['APPTAINERENV_CSL_SUPPRESS_SIMFAB_TRACE'] = '1'
    env['PATH'] = str(sdk) + ':' + env['PATH']
    return env


def prepare(args, protocol):
    out = args.out
    manifest_path = out / 'inputs/manifest.json'
    if manifest_path.exists(): return read(manifest_path)
    state = subprocess.check_output(['git', 'status', '--porcelain', '--untracked-files=no'], cwd=ROOT, text=True)
    if state.strip() and not args.allow_dirty:
        raise RuntimeError('Commit the shared implementation before freezing a study; --allow-dirty is for preflight development only.')
    commit = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
    tasks = {}
    for name in protocol['tasks']:
        spec = dict(KERNEL_REGISTRY[name]); src = Path(spec['reference_csl_dir']); dst = out/'inputs'/name/'CSL'
        shutil.copytree(src, dst, ignore=shutil.ignore_patterns('out', 'out_*', 'simfab*', '*.log', '*.elf', '__pycache__', '_combined_kernel.csl'))
        shutil.copy2(src.parent/'spec.yaml', dst.parent/'spec.yaml')
        cuda = dst.parent/'kernel.cu'; shutil.copy2(spec['cuda_path'], cuda)
        tasks[name] = dict(spec, reference_csl_dir=str(dst), cuda_path=str(cuda))
    hashes = {str(p.relative_to(out/'inputs')): sha(p) for p in (out/'inputs').rglob('*') if p.is_file()}
    sifs = sorted(args.sdk_root.glob('sdk-cbcore-2.10*.sif'))
    if len(sifs) != 1: raise RuntimeError('Expected exactly one SDK 2.10 image; select an unambiguous SDK root.')
    manifest = dict(schema='xkernel.sparse_inputs/1', source_commit=commit, protocol=protocol,
                    protocol_sha256=sha(args.protocol), tasks=tasks, sha256=hashes,
                    inputs_sha256=canonical_hash(hashes),
                    sdk_image_name=sifs[0].name, sdk_image_sha256=sha(sifs[0]),
                    dirty_development_snapshot=bool(state.strip()))
    save(manifest_path, manifest); shutil.copy2(args.protocol, out/'protocol.json')
    return manifest


def verify_frozen(args, manifest):
    if sha(args.protocol) != manifest['protocol_sha256']: raise RuntimeError('Protocol changed since freeze')
    commit = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
    if commit != manifest['source_commit']: raise RuntimeError('Framework commit changed since freeze')
    if not args.allow_dirty:
        if manifest['dirty_development_snapshot']: raise RuntimeError('Development snapshot cannot run model cells')
        changed = subprocess.check_output(['git', 'status', '--porcelain', '--untracked-files=no'], cwd=ROOT, text=True)
        if changed.strip(): raise RuntimeError('Tracked implementation changed since freeze')
    for name, expected in manifest['sha256'].items():
        if sha(args.out/'inputs'/name) != expected: raise RuntimeError('Frozen input changed: ' + name)
    if sha(args.sdk_root/manifest['sdk_image_name']) != manifest['sdk_image_sha256']:
        raise RuntimeError('SDK image changed since freeze')


def bench(path, spec, destination, sdk):
    b = benchmark_translated_compute_file(translated_path=str(path), reference_dir=spec['reference_csl_dir'],
        target_relpath=spec['target_relpath'], work_dir=str(destination), sdk_root=str(sdk),
        commands_script=spec['commands_script'], keep_staged_bundle=True, num_runs=3, heldout_eval=True)
    save(destination/'benchmark.json', b); save(destination/'source.json', {'sha256':sha(path), 'path':str(path)})
    return b


def reference(args, manifest, names):
    for name in names:
        dest = args.out/'reference'/name; old = read(dest/'benchmark.json')
        if old:
            if not passed(old): raise RuntimeError('Previously failed reference needs a new explicit study version: '+name)
            continue
        print('REFERENCE', name, flush=True)
        spec = manifest['tasks'][name]
        b = bench(Path(spec['reference_csl_dir'])/spec['target_relpath'], spec, dest, args.sdk_root)
        print('REFERENCE_RESULT', name, b.get('status'), b.get('cycles_send'), flush=True)
        if not passed(b): raise RuntimeError('Reference preflight failed: '+name)


def run_cell(args, manifest, phase, name, condition, rep):
    protocol=manifest['protocol']; model=protocol['models'][args.provider]
    cell_id='/'.join([phase,args.provider,name,condition,str(rep)])
    directory=args.out/'cells'/phase/args.provider/name/condition/f'repeat_{rep}'
    outcome=directory/'outcome.json'
    if outcome.exists():
        audit_cell(args,manifest,directory)
        return read(outcome)
    directory.mkdir(parents=True,exist_ok=True)
    spec=manifest['tasks'][name]
    if not passed(read(args.out/'reference'/name/'benchmark.json',{})):
        raise RuntimeError('Missing passing reference: '+name)
    env=base_environment(protocol,args.sdk_root);env.update(condition_environment(condition))
    env.update(XKERNEL_CELL_ID=cell_id, XKERNEL_FROZEN_COMMIT=manifest['source_commit'],
               XKERNEL_PROTOCOL_SHA256=manifest['protocol_sha256'],
               XKERNEL_CALL_ARCHIVE=str(directory/'model_artifacts'),
               XKERNEL_USAGE_JSONL=str(directory/'usage.jsonl'), XKERNEL_RESOURCE_JSONL=str(directory/'resources.jsonl'),
               XKERNEL_EXPERIENCE_STORE=str(directory/'experience.jsonl'), XKERNEL_EXPECT_RESPONSE_MODEL=model['response_model'])
    attempts=protocol['smoke_attempts'] if phase=='smoke' else protocol['translation_candidate_cap']
    cmd=[sys.executable,str(ROOT/'code_translation/cuda2csl.py'),'--kernel',name,'--cuda',spec['cuda_path'],
         '--reference-csl-dir',spec['reference_csl_dir'],'--target-relpath',spec['target_relpath'],
         '--commands-script',spec['commands_script'],'--size','small', '--sdk-root',str(args.sdk_root),
         '--target-sdk',protocol['sdk']['target'],'--api-key-file',str(args.key_file),
         '--base-url',model['base_url'],'--model',model['model'],'--max-tokens',str(model['initial_output_tokens']),
         '--reviewer-max-attempts',str(attempts),'--turns',str(attempts),'--num-runs','3','--optimize-num-runs','3',
         '--profile-feedback','--keep-profile-bundles','--no-measure-reference',
         '--output',str(directory/'artifacts'),'--work-root',str(directory/'scratch')]
    if phase in ('optimize','ablate'):
        start=args.out/'first_correct'/name/'pe.csl'
        if not start.is_file():
            result=dict(cell_id=cell_id,status='missing_start',kernel=name,phase=phase,condition=condition,repeat=rep,provider=args.provider)
            save(outcome,result);return result
        cmd+=['--optimize-only','--csl-path',str(start)]
    if phase in ('smoke','optimize','ablate'):
        count=protocol['smoke_attempts'] if phase=='smoke' else protocol['optimization_proposals']
        cmd+=['--auto-optimize','--min-optimize-attempts',str(count),'--max-optimize-attempts',str(count)]
    save(directory/'invocation.json',dict(cell_id=cell_id,command=cmd,environment={k:v for k,v in env.items()
         if k.startswith(('XKERNEL_','APPTAINERENV_')) and 'KEY' not in k},framework_commit=manifest['source_commit']))
    save(args.out/'progress.json',dict(status='running',cell_id=cell_id,pid=os.getpid()))
    start=time.monotonic(); print('START',cell_id,flush=True)
    with (directory/'run.log').open('w') as log:
        proc=subprocess.Popen(cmd,cwd=ROOT,env=env,stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
        save(directory/'process.json',dict(pid=proc.pid,started=time.time()))
        try: rc=proc.wait(timeout=protocol['workflow_limit_s'])
        except subprocess.TimeoutExpired:
            import psutil
            try:
                children=psutil.Process(proc.pid).children(recursive=True)
                for child in reversed(children):
                    try: child.kill()
                    except psutil.NoSuchProcess: pass
            except psutil.NoSuchProcess: pass
            try: os.killpg(proc.pid,signal.SIGKILL)
            except ProcessLookupError: pass
            proc.wait();rc=124
    files=sorted((directory/'artifacts').glob('run_*/*/benchmark.json'))
    artifact=files[-1].parent if files else None;b=read(files[-1],{}) if files else {}
    calls=[json.loads(x) for x in (directory/'usage.jsonl').read_text().splitlines()] if (directory/'usage.jsonl').exists() else []
    identities=sorted({x.get('response_model','missing') for x in calls})
    identity_ok=bool(calls) and identities==[model['response_model']]
    resource=[json.loads(x) for x in (directory/'resources.jsonl').read_text().splitlines()] if (directory/'resources.jsonl').exists() else []
    result=dict(cell_id=cell_id,kernel=name,phase=phase,condition=condition,repeat=rep,provider=args.provider,
        status='timeout' if rc==124 else 'pass' if rc==0 and passed(b) and identity_ok else 'failed',
        returncode=rc,elapsed_s=time.monotonic()-start,cycles=b.get('cycles_send'),
        failure_reason=b.get('failure_reason'),api_calls=len(calls),model_identity_ok=identity_ok,response_models=identities,
        input_tokens=sum(x.get('input_tokens') or 0 for x in calls),output_tokens=sum(x.get('output_tokens') or 0 for x in calls),
        cache_read_input_tokens=sum(x.get('cache_read_input_tokens') or 0 for x in calls),
        api_elapsed_s=sum(x.get('elapsed_s') or 0 for x in calls),
        sdk_queue_wait_s=sum(x['queue_wait_s'] for x in resource),sdk_lock_held_s=sum(x['sdk_lock_held_s'] for x in resource),
        artifact_dir=str(artifact) if artifact else None,framework_commit=manifest['source_commit'],protocol_sha256=manifest['protocol_sha256'])
    save(outcome,result)
    print('DONE',json.dumps(result),flush=True)
    audit_cell(args,manifest,directory)
    report(args)
    return result


def audit_cell(args,manifest,directory):
    outcome=read(directory/'outcome.json',{})
    if not outcome.get('artifact_dir'): return
    artifact=Path(outcome['artifact_dir']);spec=manifest['tasks'][outcome['kernel']]
    for label,path in [('initial',artifact/'candidates/attempt_00_baseline'/spec['target_relpath']),
                       ('final',artifact/spec['target_relpath'])]:
        if not path.is_file(): continue
        dest=directory/'audit'/label
        if not (dest/'benchmark.json').exists():
            print('AUDIT',outcome['cell_id'],label,flush=True)
            before=sha(path);b=bench(path,spec,dest,args.sdk_root)
            if sha(path)!=before: raise RuntimeError('Audit mutated source')
        else: b=read(dest/'benchmark.json')
        save(dest/'evaluation.json',dict(cell_id=outcome['cell_id'],code_sha256=code_hash(path.read_text()),
             source_sha256=sha(path),partition='validation',correct=passed(b),cycles=b.get('cycles_send'),
             cycles_runs=b.get('cycles_send_runs'),evidence=str(dest/'benchmark.json')))


def freeze_starts(args,manifest):
    upstream=ROOT/manifest['protocol']['first_correct_directory']
    for name in manifest['protocol']['tasks']:
        dest=args.out/'first_correct'/name
        if (dest/'meta.json').exists(): continue
        source=upstream/name/'pe.csl';provenance='committed shared start'
        if not source.is_file():
            # Cross-node agreement is necessary: do not opportunistically choose
            # this node's available run while the other model is still running.
            required=[args.out/'cells/translate'/provider/name/'T0'/f'repeat_{rep}'/'outcome.json'
                      for rep in range(1,6) for provider in sorted(manifest['protocol']['models'])]
            if not all(p.is_file() for p in required):
                print('WAITING_FOR_BASELINE_CELLS',name,flush=True);continue
            source=None
            for p in required:
                r=read(p);ev=read(p.parent/'audit/final/evaluation.json',{})
                if r.get('status')=='pass' and ev.get('correct'):
                    source=Path(r['artifact_dir'])/'pe.csl';provenance=r['cell_id'];break
            if source is None:
                save(dest/'meta.json',dict(status='no_correct_start'));continue
        spec=manifest['tasks'][name]
        b=bench(source,spec,dest/'audit',args.sdk_root)
        if not passed(b): raise RuntimeError('Committed/selected start failed independent audit: '+name)
        shutil.copy2(source,dest/'pe.csl')
        save(dest/'meta.json',dict(status='pass',source=str(source),source_sha256=sha(source),selection=provenance,cycles=b['cycles_send']))


def report(args):
    outcomes=[read(p) for p in sorted((args.out/'cells').rglob('outcome.json'))]
    rows=[];evaluations=[]
    for r in outcomes:
        row={k:v for k,v in r.items() if k not in ('response_models',)}
        d=args.out/'cells'/r['phase']/r['provider']/r['kernel']/r['condition']/f"repeat_{r['repeat']}"
        for label in ('initial','final'):
            ev=read(d/'audit'/label/'evaluation.json',{})
            if ev: evaluations.append(ev)
            row[label+'_audited_correct']=ev.get('correct');row[label+'_audited_cycles']=ev.get('cycles')
        reference_b=read(args.out/'reference'/r['kernel']/'benchmark.json',{})
        row['reference_cycles']=reference_b.get('cycles_send')
        c=row['final_audited_cycles']
        row['reference_speedup']=row['reference_cycles']/c if row['final_audited_correct'] and c else None
        rows.append(row)
    save(args.out/'summary.json',rows)
    if rows:
        fields=sorted(set().union(*(r.keys() for r in rows)))
        with (args.out/'summary.csv').open('w',newline='') as f:
            w=csv.DictWriter(f,fieldnames=fields);w.writeheader();w.writerows(rows)
    with (args.out/'development_evaluations.jsonl').open('w') as f:
        for row in evaluations:f.write(json.dumps(row)+'\n')
    return rows


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--phase',choices=['prepare','preflight','smoke','bootstrap-smoke','translate','freeze-starts','optimize','ablate','audit','report','all-local'],required=True)
    p.add_argument('--provider',choices=['deepseek','luna'],default='deepseek')
    p.add_argument('--protocol',type=Path,default=DEFAULT_PROTOCOL)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--sdk-root',type=Path,default=Path(os.getenv('XKERNEL_SDK_ROOT',str(Path.home()/'cs_sdk'))))
    p.add_argument('--key-file',type=Path)
    p.add_argument('--names',nargs='+');p.add_argument('--max-cells',type=int)
    p.add_argument('--allow-dirty',action='store_true',help='Preflight-only development snapshot; model phases reject dirty snapshots.')
    args=p.parse_args();args.out=args.out.resolve();args.sdk_root=args.sdk_root.resolve()
    args.key_file=args.key_file or Path.home()/('deepseek-api.txt' if args.provider=='deepseek' else 'gpt-key.txt')
    protocol=read(args.protocol);args.out.mkdir(parents=True,exist_ok=True)
    from filelock import FileLock
    with FileLock(str(args.out/('.'+args.provider+'.lock')),timeout=1):
        manifest=prepare(args,protocol);verify_frozen(args,manifest)
        env=base_environment(protocol,args.sdk_root);os.environ.update(env)
        names=args.names or protocol['tasks']
        if args.phase=='prepare':return
        if args.phase in ('preflight','all-local','bootstrap-smoke'):reference(args,manifest,names)
        if args.phase=='freeze-starts':freeze_starts(args,manifest)
        if args.phase in ('smoke','translate','optimize','ablate','all-local','bootstrap-smoke'):
            if manifest['dirty_development_snapshot']:raise RuntimeError('Commit before running model calls')
            phases=['smoke','translate'] if args.phase=='all-local' else ['smoke'] if args.phase=='bootstrap-smoke' else [args.phase]
            for phase in phases:
                if phase != 'smoke': require_full_study_admission(args.out,manifest)
                done=0
                for name,condition,rep in cells(protocol,phase,args.provider):
                    if name not in names:continue
                    run_cell(args,manifest,phase,name,condition,rep);done+=1
                    if args.max_cells and done>=args.max_cells:break
                if phase=='smoke':
                    rows=[r for r in report(args) if r['phase']=='smoke' and r['provider']==args.provider]
                    if (len(rows) != len(protocol['smoke_tasks']) or
                            any(not r.get('model_identity_ok') for r in rows) or
                            not any(r.get('final_audited_correct') for r in rows)):
                        raise RuntimeError('Smoke transport/model/correctness gate did not pass')
            if args.phase=='all-local':freeze_starts(args,manifest)
        if args.phase=='audit':
            for path in sorted((args.out/'cells').rglob('outcome.json')):audit_cell(args,manifest,path.parent)
        report(args)
        save(args.out/'progress.json',dict(status='phase_completed',phase=args.phase,provider=args.provider,pid=os.getpid()))


if __name__=='__main__':main()
