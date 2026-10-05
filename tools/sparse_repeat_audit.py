#!/usr/bin/env python3
"""Compile frozen references and diagnose changed-input launches in one runtime."""
import argparse,json,os,shutil,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'code_translation'));sys.path.insert(0,str(ROOT/'tools'))
from benchmark_csl import benchmark_translated_compute_file,_run_step_command
from sparse_study import base_environment,sha,save

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--study',required=True,type=Path)
    p.add_argument('--out',required=True,type=Path);p.add_argument('--names',nargs='+')
    p.add_argument('--source-root',type=Path,help='Optional separate kernel source tree; frozen host/data stay fixed')
    p.add_argument('--sdk-root',type=Path,default=Path.home()/'cs_sdk');a=p.parse_args()
    manifest=json.loads((a.study/'inputs/manifest.json').read_text());os.environ.update(base_environment(manifest['protocol'],a.sdk_root))
    os.environ['XKERNEL_PROFILE_TRAIN_REPLAY']='0';os.environ['XKERNEL_IR_CAPTURE']='0'
    rows=[]
    for name in a.names or manifest['protocol']['tasks']:
        dest=a.out/name
        if (dest/'summary.json').exists():rows.append(json.loads((dest/'summary.json').read_text()));continue
        spec=manifest['tasks'][name];source=Path(spec['reference_csl_dir'])/spec['target_relpath']
        if a.source_root:source=a.source_root/name/'CSL'/spec['target_relpath']
        b=benchmark_translated_compute_file(str(source),spec['reference_csl_dir'],spec['target_relpath'],str(dest),str(a.sdk_root),commands_script=spec['commands_script'],keep_staged_bundle=True,compile_only=True)
        save(dest/'compile.json',b)
        result=dict(kernel=name,source_sha256=sha(source),framework_commit=manifest['source_commit'],platform='simulator',status='compile_failed')
        if b['status']=='pass':
            bundle=Path(b['staged_bundle']);shutil.copy2(ROOT/'tools/sparse_repeat_host.py',bundle/'sparse_repeat_host.py')
            step=_run_step_command(str(bundle),'cs_python sparse_repeat_host.py --name out',str(a.sdk_root),timeout=300)
            save(dest/'execution.json',step)
            if (bundle/'repeated_launch.json').exists():
                result.update(json.loads((bundle/'repeated_launch.json').read_text()))
                result['status']='numerical_pass' if result['numerical_correct'] else 'numerical_fail'
            else:result.update(status='runtime_failed',returncode=step['returncode'])
        save(dest/'summary.json',result);rows.append(result);print(json.dumps(result),flush=True)
        save(a.out/'summary.json',rows)

if __name__=='__main__':main()
