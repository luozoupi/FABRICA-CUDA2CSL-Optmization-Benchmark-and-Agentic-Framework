#!/usr/bin/env python3
"""Prepare strong/weak SpMV/SpMM scaling and record compiler infeasibility.

Strong scaling fixes matrices, values, global output width and iterations.
Weak scaling fixes local stored nonzeros and output work. Matrix distribution
is the framework reference scaffold. SpMM uses preloaded replicated operands.
"""
import argparse,json,math,os,re,shutil,sys
from pathlib import Path
import yaml
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'code_translation'));sys.path.insert(0,str(ROOT/'tools'))
import sparse_inputs as si
from benchmark_csl import benchmark_translated_compute_file
from sparse_study import base_environment,sha,save

def prepare(study,out,manifest,kind='strong'):
    cells=[]
    for name in ('SpMV-RowBlock','SpMM-CSR-Dense'):
        spec=manifest['tasks'][name];reference=Path(spec['reference_csl_dir']);ks=yaml.safe_load((reference.parent/'spec.yaml').read_text())
        old=next(s['params'] for s in ks['sizes'] if s['name']=='small')
        n=int(old['P']*old.get('Mt',old.get('nrows_pe')))
        global_width=int(old['P']*old['Nt']) if name.startswith('SpMM') else 1
        matrices=[si.load_manifest_matrix(reference/'data/manifest.json',seed)[0] for seed in (7,101,202,303)]
        for pes in (1,4,16,64,256):
            side=math.isqrt(pes) if name.startswith('SpMM') else pes
            if kind=='weak':
                local=128 if name.startswith('SpMM') else 32;n=side*local
                columns=256 if name.startswith('SpMM') else n
                global_width=side*8 if name.startswith('SpMM') else 1
                matrices=[si.uniform_random(n,seed,m=columns,nnz_per_row=4) for seed in (7,101,202,303)]
                cap=local*4
            else:
                local=math.ceil(n/side)
                cap=max(max(part.nnz for part in si.partition_row_block(c,side,local)) for c in matrices)
            params=dict(old,P=side,max_nnz_pe=max(1,cap))
            params['Mt' if name.startswith('SpMM') else 'nrows_pe']=local
            if kind=='weak':params['K' if name.startswith('SpMM') else 'ncols']=columns
            if name.startswith('SpMM'):
                if global_width%side:raise ValueError('Fixed output width cannot be partitioned evenly')
                params['Nt']=global_width//side
            dest=out/name/str(pes);bundle=dest/'reference/CSL'
            bundle.parent.mkdir(parents=True,exist_ok=True);shutil.copytree(reference,bundle)
            shutil.copy2(reference.parent/'spec.yaml',bundle.parent/'spec.yaml')
            if kind=='weak':
                shutil.rmtree(bundle/'data');(bundle/'data').mkdir();entries=[]
                for i,c in enumerate(matrices):
                    path=bundle/'data'/f'weak_{i}.mtx';si.write_mtx(path,c,comment='Generated weak-scaling matrix; four nonzeros per row.')
                    entries.append(dict(id=f'weak/{name}/{pes}/{i}',file=path.name,sha256=sha(path),n=c.n,m=c.m,nnz=c.nnz))
                save(bundle/'data/manifest.json',dict(schema=1,train_seed=7,values='original',matrices=entries))
            text=(bundle/spec['commands_script']).read_text()
            text=re.sub(r'--params=\S+','--params='+','.join(f'{k}:{v}' for k,v in params.items()),text)
            text=re.sub(r'--fabric-dims=\d+,\d+',f'--fabric-dims={side+7},{side+2 if name.startswith("SpMM") else 3}',text)
            (bundle/'commands_scaling.sh').write_text(text)
            row=dict(kernel=name,scaling_kind=kind,application_pes=pes,params=params,global_rows=n,global_output_width=global_width,
                     source_sha256=sha(bundle/spec['target_relpath']),reference_dir=str(bundle),target_relpath=spec['target_relpath'],
                     commands_script='commands_scaling.sh',input_matrix_sha256={p.name:sha(p) for p in (bundle/'data').glob('*.mtx')},
                     timing_scope='existing reference device window; cross-PE clock audit required',
                     framework_scaffold='equal-row strip and vector broadcast' if name.startswith('SpMV') else 'row/column tiles, host-preloaded replicated operands; no device communication')
            save(dest/'configuration.json',row);cells.append(row)
    save(out/'manifest.json',dict(schema='xkernel.scaling/1',kind=kind,framework_commit=manifest['source_commit'],inputs_sha256=manifest['inputs_sha256'],
         work_definition='SpMV: constant local rows and nonzeros; vector and communication volume grow. SpMM: constant locally stored nonzeros and output tile work; operands are replicated across mesh columns.',cells=cells))
    return cells

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--study',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--kind',choices=['strong','weak'],default='strong')
    p.add_argument('--run',choices=['compile','measure']);p.add_argument('--sdk-root',type=Path,default=Path.home()/'cs_sdk');a=p.parse_args()
    manifest=json.loads((a.study/'inputs/manifest.json').read_text())
    for rel,digest in manifest['sha256'].items():
        if sha(a.study/'inputs'/rel)!=digest:raise RuntimeError('Frozen input changed')
    cells=json.loads((a.out/'manifest.json').read_text())['cells'] if (a.out/'manifest.json').exists() else prepare(a.study,a.out,manifest,a.kind)
    if not a.run:print('Prepared',len(cells),a.kind,'scaling cells');return
    os.environ.update(base_environment(manifest['protocol'],a.sdk_root));os.environ.update(XKERNEL_PROFILE_TRAIN_REPLAY='0',XKERNEL_IR_CAPTURE='0')
    results=[]
    for cell in cells:
        dest=a.out/cell['kernel']/str(cell['application_pes'])/a.run
        if (dest/'result.json').exists():results.append(json.loads((dest/'result.json').read_text()));continue
        compile_result=dest.parent/'compile/result.json'
        if a.run=='measure' and compile_result.exists():
            prior=json.loads(compile_result.read_text())
            if prior['status']!='pass':
                prior.update(mode='measure',measurement_skipped='compiled configuration is infeasible')
                save(dest/'result.json',prior);results.append(prior);save(a.out/'measure_summary.json',results)
                print(cell['kernel'],cell['application_pes'],'infeasible; retained compile failure',flush=True)
                continue
        b=benchmark_translated_compute_file(str(Path(cell['reference_dir'])/cell['target_relpath']),cell['reference_dir'],cell['target_relpath'],str(dest),str(a.sdk_root),commands_script=cell['commands_script'],keep_staged_bundle=True,num_runs=3,heldout_eval=a.run=='measure',compile_only=a.run=='compile')
        result=dict(configuration=cell,platform='simulator',mode=a.run,status=b['status'],failure_reason=b.get('failure_reason'),cycles=b.get('cycles_send'),benchmark=b)
        result['failure_category']='PE_memory_capacity' if 'ran out of PE memory' in str(b.get('transcript')) else b.get('failure_reason')
        save(dest/'result.json',result);results.append(result);save(a.out/(a.run+'_summary.json'),results)
        print(cell['kernel'],cell['application_pes'],b['status'],b.get('cycles_send'),flush=True)

if __name__=='__main__':main()
