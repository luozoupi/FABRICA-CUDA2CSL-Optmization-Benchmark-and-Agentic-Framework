#!/usr/bin/env python3
"""CUDA sources and cuSPARSE with inputs from the frozen CSL host programs.

The trusted host prefix executes on CPU, stopping before SdkRuntime construction.
Resident operation timing includes required resets. Setup/H2D is separate.
"""
from __future__ import annotations
import argparse, ast, contextlib, hashlib, io, json, os
from pathlib import Path
import statistics, subprocess, sys, tempfile
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'code_translation'))
import sparse_inputs as si

def sha(path): return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def host_inputs(bundle,params,seed):
    path=bundle/'run.py';body=[];found=False
    for node in ast.parse(path.read_text()).body:
        if isinstance(node,ast.ImportFrom) and (node.module or '').startswith('cerebras'):continue
        if isinstance(node,ast.Assign) and isinstance(node.value,ast.Call) and isinstance(node.value.func,ast.Name) and node.value.func.id=='SdkRuntime':
            found=True;break
        body.append(node)
    if not found:raise RuntimeError('Host prefix boundary not found')
    old_argv=sys.argv[:];old_path=sys.path[:];old_seed=os.environ.get('XKERNEL_EVAL_SEED')
    namespace={'__file__':str(path),'__name__':'__main__'}
    try:
        with tempfile.TemporaryDirectory() as d:
            (Path(d)/'out.json').write_text(json.dumps({'params':params}))
            sys.argv=[str(path),'--name',d];os.environ['XKERNEL_EVAL_SEED']=str(seed)
            log=io.StringIO()
            with contextlib.redirect_stdout(log):exec(compile(ast.Module(body=body,type_ignores=[]),str(path),'exec'),namespace)
            return namespace,log.getvalue()
    finally:
        sys.argv=old_argv;sys.path[:]=old_path
        if old_seed is None:os.environ.pop('XKERNEL_EVAL_SEED',None)
        else:os.environ['XKERNEL_EVAL_SEED']=old_seed

def configuration(name,z):
    nnz=int(z.get('nnz',z.get('nnz_total',0)));csr=z.get('csr');rtol=1e-4;atol=1e-5
    expected=None;reset=''
    if name in ('SpMV-RowBlock','SpMM-CSR-Dense'):
        M=int(z['P']*(z['Mt'] if name.startswith('SpMM') else z['nrows_pe']))
        K=int(z['K'] if name.startswith('SpMM') else z['ncols']);N=int(z['N']) if name.startswith('SpMM') else 1
        pad=si.csr_pad(csr,M,nnz)
        inputs=dict(rp=pad['row_ptr'],ci=pad['col'],v=pad['val'],b=z['B'] if N>1 else z['x'])
        y=np.zeros((M,N),np.float32);y[:csr.n]=z['C_ref'] if N>1 else np.asarray(z['y_ref_full'])[:,None]
        launch=(f'spmm_csr_dense<<<({M}+7)/8,256,0,stream>>>({M},{N},d_rp,d_ci,d_v,d_b,d_y);' if N>1 else
                f'spmv_csr_vector<<<({M}+7)/8,256,0,stream>>>({M},d_rp,d_ci,d_v,d_b,d_y);')
    elif name=='SpMV-CSR':
        M=int(z['nrows']);K=int(z['ncols']);N=1;rtol=atol=1e-5
        inputs=dict(rp=z['row_ptr'],ci=z['col_idx'][:nnz],v=z['val'][:nnz],b=z['x']);y=z['y_ref']
        launch=f'spmv_csr<<<({M}+255)/256,256,0,stream>>>(d_rp,d_ci,d_v,d_b,d_y,{M});'
    elif name in ('RowScale-CSR','ColScale-CSR','RowReduce-CSR'):
        M=int(z['nrows']);K=M;N=1
        inputs=dict(rp=z['row_ptr'],ci=z['col_idx'][:nnz],v=z['val'][:nnz],d=z['d'])
        if name=='RowScale-CSR':
            y=z['c_ref'];rtol=1e-6;atol=0
            launch=f'rowscale_csr<<<({nnz}+255)/256,256,0,stream>>>({M},{nnz},d_rp,d_v,d_d,d_y);'
        elif name=='ColScale-CSR':
            y=z['c_ref'];rtol=1e-6;atol=0
            launch=f'colscale_csr<<<({nnz}+255)/256,256,0,stream>>>({nnz},d_ci,d_v,d_d,d_y);'
        else:
            expected=dict(y=np.asarray(z['y_ref'],np.float32),total=np.asarray([z['total_ref']],np.float32))
            reset='CHECK(cudaMemsetAsync(d_total,0,sizeof(float),stream));'
            launch=f'rowsum_csr<<<({M}+7)/8,256,0,stream>>>({M},d_rp,d_v,d_y);reduce_to_scalar<<<({nnz}+255)/256,256,0,stream>>>({nnz},d_v,d_total);'
    elif name=='SpGEMM-Masked-Dot':
        M=int(z['n']);K=M;N=1;rtol=1e-5;atol=1e-6
        inputs=dict(rp=z['col_ptr'],ci=z['row_idx'][:nnz],v=z['val'][:nnz])
        expected=dict(y=np.asarray(z['c_ref'],np.float32),rows=np.asarray(z['c_row_ref'],np.uint32).view(np.int32),zombies=np.asarray([z['nzombies_ref']],np.int32))
        reset='CHECK(cudaMemsetAsync(d_zombies,0,sizeof(int),stream));'
        launch=f'spgemm_masked_dot_vsvs<<<({nnz}+255)/256,256,0,stream>>>({M},{nnz},d_rp,d_ci,d_v,d_y,d_rows,d_zombies);'
    else:raise ValueError(name)
    inputs={k:np.asarray(a,dtype=np.int32 if k in ('rp','ci') else np.float32) for k,a in inputs.items()}
    return dict(inputs=inputs,expected=expected if expected is not None else {'y':np.asarray(y,np.float32)},launch=launch,reset=reset,M=M,K=K,N=N,nnz=nnz,rtol=rtol,atol=atol)

HEADER=r'''
#include <cuda_runtime.h>
#include <cusparse.h>
#include <cstdio>
#include <cstdlib>
#include <vector>
#include <fstream>
#include <chrono>
#define CHECK(c) do {auto cuda_status_=(c);if(cuda_status_!=cudaSuccess){fprintf(stderr,"CUDA %s\n",cudaGetErrorString(cuda_status_));exit(2);}}while(0)
#define SP(c) do {auto sparse_status_=(c);if(sparse_status_!=CUSPARSE_STATUS_SUCCESS){fprintf(stderr,"cuSPARSE %d\n",int(sparse_status_));exit(3);}}while(0)
template<class T>T* load(const char* f,size_t n){std::vector<T> h(n);std::ifstream s(f,std::ios::binary);if(!s.read((char*)h.data(),n*sizeof(T)))exit(4);T*p;CHECK(cudaMalloc(&p,(n?n:1)*sizeof(T)));CHECK(cudaMemcpy(p,h.data(),n*sizeof(T),cudaMemcpyHostToDevice));return p;}
template<class T>T* alloc(size_t n){T*p;CHECK(cudaMalloc(&p,(n?n:1)*sizeof(T)));CHECK(cudaMemset(p,0,n*sizeof(T)));return p;}
template<class T>void save(const char*f,T*p,size_t n){std::vector<T>h(n);CHECK(cudaMemcpy(h.data(),p,n*sizeof(T),cudaMemcpyDeviceToHost));std::ofstream s(f,std::ios::binary);s.write((char*)h.data(),n*sizeof(T));}
'''

def driver(cfg,source,vendor):
    M,K,N,nnz=(cfg[k] for k in ('M','K','N','nnz'))
    code=HEADER+'\n#define main original_main\n'+source+'\n#undef main\nint main(){\n'
    code+='CHECK(cudaSetDevice(0));cudaDeviceProp prop;CHECK(cudaGetDeviceProperties(&prop,0));cudaStream_t stream;CHECK(cudaStreamCreate(&stream));auto setup_start=std::chrono::steady_clock::now();\n'
    for key,a in cfg['inputs'].items():
        typ='int' if a.dtype==np.int32 else 'float';code+=f'auto d_{key}=load<{typ}>("{key}.bin",{a.size});\n'
    for key,a in cfg['expected'].items():
        typ='int' if a.dtype==np.int32 else 'float';code+=f'auto d_{key}=alloc<{typ}>({a.size});\n'
    call=cfg['reset']+cfg['launch'];version='0'
    if vendor:
        code+='cusparseHandle_t handle;SP(cusparseCreate(&handle));SP(cusparseSetStream(handle,stream));int spversion;SP(cusparseGetVersion(handle,&spversion));float alpha=1,beta=0;cusparseSpMatDescr_t A;\n'
        code+=f'SP(cusparseCreateCsr(&A,{M},{K},{nnz},d_rp,d_ci,d_v,CUSPARSE_INDEX_32I,CUSPARSE_INDEX_32I,CUSPARSE_INDEX_BASE_ZERO,CUDA_R_32F));size_t bytes=0;void*buffer;\n'
        if N==1:
            code+=f'cusparseDnVecDescr_t B,C;SP(cusparseCreateDnVec(&B,{K},d_b,CUDA_R_32F));SP(cusparseCreateDnVec(&C,{M},d_y,CUDA_R_32F));\n'
            args='handle,CUSPARSE_OPERATION_NON_TRANSPOSE,&alpha,A,B,&beta,C,CUDA_R_32F,CUSPARSE_SPMV_CSR_ALG2';fn='cusparseSpMV'
        else:
            code+=f'cusparseDnMatDescr_t B,C;SP(cusparseCreateDnMat(&B,{K},{N},{N},d_b,CUDA_R_32F,CUSPARSE_ORDER_ROW));SP(cusparseCreateDnMat(&C,{M},{N},{N},d_y,CUDA_R_32F,CUSPARSE_ORDER_ROW));\n'
            args='handle,CUSPARSE_OPERATION_NON_TRANSPOSE,CUSPARSE_OPERATION_NON_TRANSPOSE,&alpha,A,B,&beta,C,CUDA_R_32F,CUSPARSE_SPMM_CSR_ALG2';fn='cusparseSpMM'
        code+=f'SP({fn}_bufferSize({args},&bytes));CHECK(cudaMalloc(&buffer,bytes?bytes:1));\n'
        call=f'SP({fn}({args},buffer));';version='spversion'
    code+='CHECK(cudaDeviceSynchronize());double setup_ms=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-setup_start).count();\n'
    code+='auto launch=[&](){'+call+'CHECK(cudaGetLastError());};launch();CHECK(cudaStreamSynchronize(stream));\n'
    code+='CHECK(cudaStreamBeginCapture(stream,cudaStreamCaptureModeGlobal));for(int i=0;i<100;i++)launch();cudaGraph_t g;CHECK(cudaStreamEndCapture(stream,&g));cudaGraphExec_t e;CHECK(cudaGraphInstantiate(&e,g,0));\n'
    code+='cudaEvent_t a,b;CHECK(cudaEventCreate(&a));CHECK(cudaEventCreate(&b));std::vector<double>single,graph;\n'
    code+='for(int i=-10;i<3;i++){CHECK(cudaEventRecord(a,stream));launch();CHECK(cudaEventRecord(b,stream));CHECK(cudaEventSynchronize(b));float ms;CHECK(cudaEventElapsedTime(&ms,a,b));if(i>=0)single.push_back(ms*1000.0);}\n'
    code+='for(int i=-10;i<3;i++){CHECK(cudaEventRecord(a,stream));CHECK(cudaGraphLaunch(e,stream));CHECK(cudaEventRecord(b,stream));CHECK(cudaEventSynchronize(b));float ms;CHECK(cudaEventElapsedTime(&ms,a,b));if(i>=0)graph.push_back(ms*10.0);}\n'
    for key,a in cfg['expected'].items():code+=f'save("{key}_actual.bin",d_{key},{a.size});\n'
    code+=f'printf("{{\\"device\\":\\"%s\\",\\"cusparse_version\\":%d,\\"setup_and_h2d_ms\\":%.9f,",prop.name,{version},setup_ms);\n'
    code+='printf("\\"single_launch_us\\":[");for(size_t i=0;i<single.size();i++)printf("%s%.9f",i?",":"",single[i]);printf("],\\"graph_operation_us\\":[");for(size_t i=0;i<graph.size();i++)printf("%s%.9f",i?",":"",graph[i]);printf("]}\\n");return 0;}\n'
    return code

def run_one(name,seed,manifest,out,vendor,nvcc):
    spec=manifest['tasks'][name];bundle=Path(spec['reference_csl_dir']);work=out/name/str(seed)/('cusparse' if vendor else 'cuda_source');work.mkdir(parents=True,exist_ok=False)
    import yaml
    ks=yaml.safe_load((bundle.parent/'spec.yaml').read_text());params=next(s['params'] for s in ks['sizes'] if s['name']=='small')
    z,log=host_inputs(bundle,params,seed);cfg=configuration(name,z);(work/'host_input.log').write_text(log)
    source=Path(spec['cuda_path']);(work/'source.cu').write_bytes(source.read_bytes());(work/'driver.cu').write_text(driver(cfg,source.read_text(),vendor))
    for key,a in cfg['inputs'].items():np.ascontiguousarray(a).tofile(work/(key+'.bin'))
    for key,a in cfg['expected'].items():np.ascontiguousarray(a).tofile(work/(key+'_expected.bin'))
    cmd=[str(nvcc),'-O3','-arch=sm_120','-std=c++17','driver.cu','-lcusparse','-o','benchmark']
    result=dict(kernel=name,seed=seed,baseline='cusparse' if vendor else 'cuda_source',framework_commit=manifest['source_commit'],inputs_sha256=manifest['inputs_sha256'],host_sha256=sha(bundle/'run.py'),source_sha256=sha(source),driver_sha256=sha(work/'driver.cu'),params=params,compile_command=cmd,rtol=cfg['rtol'],atol=cfg['atol'],input_hashes={p.name:sha(p) for p in work.glob('*.bin')},timing_scope='resident operation including required resets; setup and H2D separate; single GPU',repetitions=3,graph_operations=100,status='failed')
    result.update({k:cfg[k] for k in ('M','K','N','nnz')})
    result['measurement_tool_sha256']=sha(__file__)
    try:
        p=subprocess.run(cmd,cwd=work,capture_output=True,text=True,timeout=180);(work/'compile.log').write_text(p.stdout+p.stderr)
        if p.returncode:raise RuntimeError('compile failed: '+p.stderr[-1200:])
        p=subprocess.run(['./benchmark'],cwd=work,capture_output=True,text=True,timeout=180);(work/'run.log').write_text(p.stdout+p.stderr)
        if p.returncode:raise RuntimeError('execution failed: '+p.stderr[-1200:])
        result.update(json.loads(p.stdout));result['binary_sha256']=sha(work/'benchmark');errors={}
        for key,a in cfg['expected'].items():
            actual=np.fromfile(work/(key+'_actual.bin'),dtype=a.dtype).reshape(a.shape)
            if a.dtype==np.int32:np.testing.assert_array_equal(actual,a)
            else:np.testing.assert_allclose(actual,a,rtol=cfg['rtol'],atol=cfg['atol'])
            errors[key]=float(np.max(np.abs(actual.astype(float)-a.astype(float)))) if a.size else 0
        result.update(status='pass',max_abs_errors=errors)
        for metric in ('single_launch_us','graph_operation_us'):result[metric+'_median']=statistics.median(result[metric])
    except Exception as exc:result['reason']=str(exc)
    (work/'benchmark.json').write_text(json.dumps(result,indent=2)+'\n');return result

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--study',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--names',nargs='+',default=['SpMV-CSR','SpMV-RowBlock','SpMM-CSR-Dense']);p.add_argument('--seeds',nargs='+',type=int,default=[7,101,202,303]);p.add_argument('--nvcc',type=Path,default=Path('/usr/local/cuda/bin/nvcc'))
    a=p.parse_args();manifest=json.loads((a.study/'inputs/manifest.json').read_text());a.out.mkdir(parents=True,exist_ok=True)
    for rel,digest in manifest['sha256'].items():
        if sha(a.study/'inputs'/rel)!=digest:raise RuntimeError('Frozen input changed: '+rel)
    rows=[]
    for name in a.names:
        for seed in a.seeds:
            for vendor in ([False,True] if name in ('SpMV-CSR','SpMV-RowBlock','SpMM-CSR-Dense') else [False]):
                path=a.out/name/str(seed)/('cusparse' if vendor else 'cuda_source')/'benchmark.json'
                r=json.loads(path.read_text()) if path.exists() else run_one(name,seed,manifest,a.out,vendor,a.nvcc)
                rows.append(r);print(json.dumps({k:r.get(k) for k in ('kernel','seed','baseline','status','single_launch_us_median','graph_operation_us_median','reason')}),flush=True)
                all_rows=[json.loads(p.read_text()) for p in sorted(a.out.glob('*/*/*/benchmark.json'))]
                (a.out/'summary.json').write_text(json.dumps(all_rows,indent=2)+'\n')
    if any(r['status']!='pass' for r in rows):raise SystemExit(1)

if __name__=='__main__':main()
