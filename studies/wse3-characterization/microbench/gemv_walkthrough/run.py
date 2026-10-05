#!/usr/bin/env python3
"""Record all local partials and replicated outputs of a tiny X @ W."""
import hashlib
import json
from pathlib import Path
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder

def bits(values):return np.asarray(values,np.float32).view(np.uint32).ravel().copy()

def main():
    spec=json.loads(Path('case.json').read_text());n,p=spec['n'],spec['p'];t=n//p
    W=np.arange(1,n*n+1,dtype=np.float32).reshape(n,n)
    X=np.array([1,2,-1,3] if n==4 else [1,2,-1,3,0,-2,1,2],np.float32)
    rt=SdkRuntime('out');rt.load();rt.run();rows=[]
    u32,u16,rm=MemcpyDataType.MEMCPY_32BIT,MemcpyDataType.MEMCPY_16BIT,MemcpyOrder.ROW_MAJOR
    def read(name,x,y,count,narrow=False):
        data=np.zeros(count,np.uint32)
        rt.memcpy_d2h(data,rt.get_id(name),x,y,1,1,count,streaming=False,data_type=u16 if narrow else u32,order=rm,nonblock=False)
        return data.tolist()
    try:
        for y in range(p):
            for x in range(p):
                for name,data in [('W',W[y*t:(y+1)*t,x*t:(x+1)*t]),('X',X[y*t:(y+1)*t])]:
                    packed=bits(data)
                    rt.memcpy_h2d(rt.get_id(name),packed,x,y,1,1,len(packed),streaming=False,data_type=u32,order=rm,nonblock=False)
        rt.call('run',[],nonblock=False)
        for y in range(p):
            for x in range(p):
                row={'x':x,'y':y,'time_words':read('time_words',x,y,6,True)}
                for name in ['W','X','partial','peer','result']:
                    row[name]=read(name,x,y,t*t if name=='W' else t)
                if spec['history']:
                    for name in ['h_w','h_x','h_old','h_new']:row[name]=read(name,x,y,t*t)
                    for name in ['r_old','r_peer','r_new']:row[name]=read(name,x,y,t)
                    row['h_clock']=read('h_clock',x,y,3*t*t,True)
                    row['phase_clock']=read('phase_clock',x,y,15,True)
                    row['phase_flags']=read('phase_flags',x,y,5,True)
                rows.append(row)
    finally:rt.stop()
    expected=X@W
    correct=all(np.array_equal(np.asarray(r['result'],np.uint32).view(np.float32),expected[r['x']*t:(r['x']+1)*t]) for r in rows)
    result={'schema':'gemv-capture/1','evidence':'simulator',**spec,'x_bits':bits(X).tolist(),
            'w_bits':bits(W).tolist(),'pes':rows,'reference':expected.tolist(),'correct':correct,
            'sources':{f:hashlib.sha256(Path(f).read_bytes()).hexdigest() for f in ['pe.csl','layout.csl','run.py','case.json']}}
    Path('capture.json').write_text(json.dumps(result,indent=2))
    print('MeshGEMV',spec['case'],'correct',correct,'Y',expected.tolist(),flush=True)
    assert correct,'MeshGEMV output mismatch'

if __name__=='__main__':main()
