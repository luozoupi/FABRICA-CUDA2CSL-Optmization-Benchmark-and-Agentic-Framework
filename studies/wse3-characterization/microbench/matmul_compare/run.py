#!/usr/bin/env python3
"""Exact integer-valued f16 validation, repeated on-device kernel timing."""
import argparse,json,time
from pathlib import Path
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime,MemcpyDataType,MemcpyOrder
p=argparse.ArgumentParser();p.add_argument('--trials',type=int,default=3);p.add_argument('--warmups',type=int,default=1);p.add_argument('--no-trace',action='store_true');a=p.parse_args()
m=json.loads(Path('meta.json').read_text());n=m['n'];t=m['tile'];variants=m['variants']
rng=np.random.default_rng(m['seed']);A=rng.integers(-2,3,(n,n)).astype(np.float16);B=rng.integers(-2,3,(n,n)).astype(np.float16)
ref=A.astype(np.int64)@B.astype(np.int64)
p0=time.perf_counter_ns();Bp=np.concatenate([B[:,j:j+t].ravel() for j in range(0,n,t)]);pack_ns=time.perf_counter_ns()-p0
matrices={'A':A,'B':B,'Bt':np.ascontiguousarray(B.T),'Bp':Bp}
rt=SdkRuntime('out',suppress_simfab_trace=a.no_trace);rt.load();rt.run();runs=[]
def read(sym,count,narrow=False):
    out=np.zeros(count,np.uint32);rt.memcpy_d2h(out,rt.get_id(sym),0,0,1,1,count,streaming=False,data_type=MemcpyDataType.MEMCPY_16BIT if narrow else MemcpyDataType.MEMCPY_32BIT,order=MemcpyOrder.ROW_MAJOR,nonblock=False);return out
try:
    for name,arr in matrices.items():rt.memcpy_h2d(rt.get_id(name),arr.ravel().view(np.uint16).astype(np.uint32),0,0,1,1,arr.size,streaming=False,data_type=MemcpyDataType.MEMCPY_16BIT,order=MemcpyOrder.ROW_MAJOR,nonblock=False)
    for rep in range(a.warmups+a.trials):
        rt.call('compute',[],nonblock=False)
        words=read('cycles',len(variants)*3);co=read('Cout',len(variants)*n*n,True).astype(np.uint16).view(np.float16).reshape(len(variants),n,n)
        results=[]
        for i,name in enumerate(variants):
            w=[int(x) for z in words[i*3:i*3+3] for x in (z&65535,z>>16)]
            start=w[0]+(w[1]<<16)+(w[2]<<32);end=w[3]+(w[4]<<16)+(w[5]<<32)
            got=co[i].astype(np.float32);passed=bool(np.array_equal(got,ref))
            results.append(dict(name=name,cycles=(end-start)%(1<<48),tsc_start=start,tsc_end=end,passed=passed,max_abs_err=float(abs(got-ref).max()),output=got.tolist()))
        runs.append(dict(warmup=rep<a.warmups,variants=results));print('trial',rep,[(x['name'],x['cycles'],x['passed']) for x in results],flush=True)
finally:rt.stop()
report=dict(schema='matmul-compare/1',trace_enabled=not a.no_trace,**m,inputs={k:v.tolist() for k,v in matrices.items()},reference=ref.tolist(),runs=runs,host_pack_ns=pack_ns,packing_note='Host B packing is outside kernel TSC timing; one wall-clock sample is not a packing benchmark.',timing_scope='zero_C and save_C excluded; kernel descriptor setup included; simulator cycles; fixed variant order')
Path('capture.json').write_text(json.dumps(report,indent=2))
assert all(v['passed'] for r in runs for v in r['variants'] if v['name']!='ijk_bad'),'Corrected variant failed'
assert all(not v['passed'] for r in runs for v in r['variants'] if v['name']=='ijk_bad'),'Diagnostic failed to distinguish last-product code'
