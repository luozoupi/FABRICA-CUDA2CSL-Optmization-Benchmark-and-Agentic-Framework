"""Numerical and state-reset audit; raw per-PE device cycles and host costs."""
import argparse
import hashlib
import json
import statistics
import time
from pathlib import Path
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder

def digest(a):return hashlib.sha256(np.ascontiguousarray(a).tobytes()).hexdigest()
def inputs(c,pattern,changed=False):
    m,k,n=c['M'],c['K'],c['N']
    ii,kk=np.indices((m,k));A=(((ii*2+kk*3+1)%7)-3).astype(np.float32)
    A[A==0]=1
    if c['op']!='gemm':
        mask=np.zeros((m,k),bool)
        if pattern=='banded':
            for i in range(m):mask[i,[(i+t)%k for t in (-1,0,1)]]=True
        elif pattern=='uniform':
            for i in range(m):mask[i,[(i*3+t*5)%k for t in range(min(3,k))]]=True
        else:
            for i in range(m):
                count=0 if i%4==1 else k if i%4==0 else 1
                mask[i,[(i*3+t)%k for t in range(count)]]=True
        A*=mask
    rr,jj=np.indices((k,n));B=(((rr*3+jj*2)%7)-3).astype(np.float32)
    if pattern=='page':
        A=np.array([[2,1,3,1],[1,4,0,2],[3,0,2,1],[0,2,1,3]],np.float32)
        B=np.array([[1,2,0,1],[3,1,2,0],[0,1,1,2],[2,0,3,1]],np.float32)
    if changed:A=np.roll(A,1,axis=1)*-2;B=np.flip(B,axis=0).copy()+1
    return A,B

def csr(a,capacity):
    ptr=[0];ix=[];val=[]
    for row in a:
        for j,v in enumerate(row):
            if v!=0:ix.append(j);val.append(v)
        ptr.append(len(ix))
    assert len(val)<=capacity and max(ptr)<65536 and max(ix,default=0)<65536
    return np.array(ptr,np.uint32),np.pad(np.array(ix,np.uint32),(0,capacity-len(ix))),np.pad(np.array(val,np.float32),(0,capacity-len(val)))

def journal_oracle(c,A,B,ptr,ix,val,meta,snapshots):
    m,k,n=c['M'],c['K'],c['N'];C=np.zeros((m,n),np.float32);events=[]
    for seq,fields in enumerate(meta):
        i,j,kk,p,extent,kind=map(int,fields);terms=[]
        if kind==0:terms=[(i,j,kk)]
        elif kind==1:terms=[(i,j+t,kk)for t in range(extent)]
        elif kind==2:terms=[(t,j,kk)for t in range(extent)]
        elif kind==3:terms=[(i,j,t)for t in range(extent)]
        elif kind==4:terms=[(i,0,int(ix[t]))for t in range(int(ptr[i]),int(ptr[i+1]))]
        elif kind==5:terms=[(i,j,kk)]
        else:raise AssertionError(kind)
        updates=[]
        for row,col,shared in terms:
            a=float(A[shared,row] if c['op']=='masked' else A[row,shared]);b=float(A[shared,col] if c['op']=='masked' else B[shared,col]);before=float(C[row,col])
            C[row,col]=before+a*b
            ao=shared*m+row if c['layout']=='column-major' else row*k+shared
            bo=col*k+shared if c['layout']=='column-major' else shared*n+col
            co=col*m+row if c['layout']=='column-major' else row*n+col
            def slot(r,k):
                positions=[t for t in range(int(ptr[r]),int(ptr[r+1]))if ix[t]==k]
                assert len(positions)==1
                return positions[0]
            a_buffer='A';a_offset=ao;b_buffer='B';b_offset=bo
            if c['op']=='sparse':a_buffer='values';a_offset=slot(row,shared)
            if c['op']=='masked':a_buffer='values';a_offset=slot(row,shared);b_buffer='values';b_offset=slot(col,shared)
            updates.append(dict(i=row,j=col,k=shared,a=a,b=b,before=before,after=float(C[row,col]),a_buffer=a_buffer,a_offset=a_offset,b_buffer=b_buffer,b_offset=b_offset,c_offset=co))
        np.testing.assert_array_equal(snapshots[seq],C,err_msg=f'journal step {seq}')
        events.append(dict(step=seq+1,metadata=list(map(int,fields)),updates=updates,C=snapshots[seq].tolist(),verified=True))
    products=sum(len(e['updates'])for e in events)
    if c['op']=='gemm':expected_products=m*k*n
    elif c['op']=='sparse':expected_products=int(np.count_nonzero(A))*n
    else:expected_products=sum(int(np.count_nonzero((A[:,i]!=0)&(A[:,j]!=0)))for i,j in np.argwhere(A!=0))
    assert products==expected_products,(products,expected_products)
    return events

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--cmaddr');ap.add_argument('--name',default='out');ap.add_argument('--output',default='observations.json');args=ap.parse_args()
    c=json.loads(Path('case.json').read_text());m,k,n=c['M'],c['K'],c['N'];order='F' if c['layout']=='column-major' else 'C'
    for name,sha in c['source_hashes'].items():assert hashlib.sha256(Path(name).read_bytes()).hexdigest()==sha,name
    r=SdkRuntime(args.name,cmaddr=args.cmaddr);records=[];journal=[]
    def put(name,a):
        typ,size=c['buffers'][name];small=typ=='u16'
        data=np.ascontiguousarray(a,dtype=np.float32 if typ=='f32' else np.uint32).ravel()
        assert len(data)==size
        if small:assert np.all(data<65536)
        r.memcpy_h2d(r.get_id(name),data,0,0,1,1,size,streaming=False,data_type=MemcpyDataType.MEMCPY_16BIT if small else MemcpyDataType.MEMCPY_32BIT,order=MemcpyOrder.ROW_MAJOR,nonblock=False)
    def get(name,size=None):
        typ,cap=c['buffers'][name];size=cap if size is None else size;out=np.zeros(size,np.uint32)
        r.memcpy_d2h(out,r.get_id(name),0,0,1,1,size,streaming=False,data_type=MemcpyDataType.MEMCPY_16BIT if typ=='u16' else MemcpyDataType.MEMCPY_32BIT,order=MemcpyOrder.ROW_MAJOR,nonblock=False)
        return out.view(np.float32) if typ=='f32' else out
    def stamps():
        t=list(map(int,get('time_words')));start=t[0]|(t[1]<<16)|(t[2]<<32);end=t[3]|(t[4]<<16)|(t[5]<<32)
        return dict(start=start,end=end,cycles=(end-start)%2**48,words=t)
    r.load();r.run()
    try:
        r.launch('enable_timer',nonblock=False)
        for pattern in c['patterns']:
            for changed in ([False] if c['debug'] else [False,True,False]):
                t=time.perf_counter();A,B=inputs(c,pattern,changed);ptr,ix,val=csr(A.T if c['op']=='masked' else A,m*k)
                expected=np.where(A!=0,A.T.astype(np.float64)@A.astype(np.float64),0) if c['op']=='masked' else A.astype(np.float64)@B.astype(np.float64)
                packedA=A.flatten(order=order);packedB=B.flatten(order=order);preprocess=time.perf_counter()-t
                t=time.perf_counter()
                if c['op']=='gemm':put('A',packedA)
                else:put('row_ptr',ptr);put('col_idx',ix);put('values',val)
                if c['op']!='masked':put('B',packedB)
                transfer=time.perf_counter()-t
                samples=[]
                for rep in range(1 if c['debug'] else c['repetitions']+1):
                    t=time.perf_counter();r.launch('compute',nonblock=False);host_launch=time.perf_counter()-t
                    C=get('C').reshape(m,n,order=order);ts=stamps()
                    np.testing.assert_array_equal(C,expected)
                    structural=True
                    if c['op']=='masked':
                        present=get('present').reshape(m,n)
                        ep=((A!=0).astype(np.int32).T@(A!=0).astype(np.int32)>0)&(A!=0)
                        np.testing.assert_array_equal(present,ep.astype(np.uint32))
                    sample=dict(repetition=rep,warmup=not c['debug'] and rep==0,correct=True,structural_correct=structural,host_launch_s=host_launch,output_sha256=digest(C),**ts);samples.append(sample)
                    if c['debug']:
                        count=int(get('journal_count')[0]);meta=get('journal_meta',count*6).reshape(count,6)
                        raw=get('journal_C',count*m*n);snapshots=np.array([row.reshape(m,n,order=order)for row in raw.reshape(count,m*n)])
                        events=journal_oracle(c,A,B,ptr,ix,val,meta,snapshots)
                        # Journal must explain the complete final result, including empty rows.
                        if events:np.testing.assert_array_equal(events[-1]['C'],C)
                        else:np.testing.assert_array_equal(C,np.zeros_like(C))
                        journal.append(dict(pattern=pattern,A=A.tolist(),B=B.tolist(),row_ptr=ptr.tolist(),col_idx=ix[:int(ptr[-1])].tolist(),values=val[:int(ptr[-1])].tolist(),events=events,output=C.tolist(),passed=True))
                cycle_values=[s['cycles']for s in samples if not s['warmup']]
                records.append(dict(pattern=pattern,changed=changed,A=A.tolist(),B=B.tolist(),input_sha256=dict(A=digest(A),B=digest(B)),nnz=int(np.count_nonzero(A)),row_lengths=np.count_nonzero(A,axis=1).tolist(),preprocessing_and_oracle_s=preprocess,host_h2d_s=transfer,samples=samples,median_cycles=statistics.median(cycle_values),min_cycles=min(cycle_values),max_cycles=max(cycle_values),output=C.tolist()))
        controls=[]
        for _ in range(3):r.launch('timer_control',nonblock=False);controls.append(stamps())
    finally:r.stop()
    result=dict(status='pass',execution='physical_wse' if args.cmaddr else 'sdk_simulator',case=c,records=records,journals=journal,timer_control=controls,timing_scope='one PE, output reset + synchronous kernel + two device timestamp reads; input packing/H2D/D2H excluded; no overhead subtraction',debug_timing_excluded=c['debug'],elf_hashes={str(p):hashlib.sha256(p.read_bytes()).hexdigest()for p in Path(args.name).glob('bin/*.elf')})
    Path(args.output).write_text(json.dumps(result,indent=2)+'\n')
    print('PASS',c['id'],len(records),'input sessions',sum(len(x['samples'])for x in records),'checked launches',flush=True)

if __name__=='__main__':main()
