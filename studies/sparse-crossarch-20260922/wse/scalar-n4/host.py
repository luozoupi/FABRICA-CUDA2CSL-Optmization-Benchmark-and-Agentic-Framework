import argparse,hashlib,json,time
from pathlib import Path
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime,MemcpyDataType,MemcpyOrder
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def main():
    ap=argparse.ArgumentParser();ap.add_argument('--cmaddr');args=ap.parse_args()
    cfg=json.loads(Path('case.json').read_text());m,k,n=cfg['M'],cfg['K'],cfg['N']
    for p,h in cfg['source_hashes'].items():assert sha(p)==h,p
    r=SdkRuntime('out',cmaddr=args.cmaddr);records=[];last=0
    def put(name,a):
        r.memcpy_h2d(r.get_id(name),np.ascontiguousarray(a),0,0,1,1,len(a),streaming=False,data_type=MemcpyDataType.MEMCPY_32BIT,order=MemcpyOrder.ROW_MAJOR,nonblock=False)
    def get(name,size,small=False):
        a=np.zeros(size,np.uint32);r.memcpy_d2h(a,r.get_id(name),0,0,1,1,size,streaming=False,data_type=MemcpyDataType.MEMCPY_16BIT if small else MemcpyDataType.MEMCPY_32BIT,order=MemcpyOrder.ROW_MAJOR,nonblock=False);return a
    r.load();r.run()
    try:
        r.launch('enable_timer',nonblock=False)
        for case in cfg['inputs']:
            d=Path('inputs')/case['id']
            for name,h in case['input_hashes'].items():assert sha(d/name)==h
            rp=np.fromfile(d/'row_ptr.bin',np.uint32);ix0=np.fromfile(d/'col_idx.bin',np.uint32);v0=np.fromfile(d/'values.bin',np.float32);b0=np.fromfile(d/'B.bin',np.float32).reshape(k,n)
            for session in range(3):
                ix=(ix0+17)%k if session==1 else ix0;v=-2*v0 if session==1 else v0;b=b0+1 if session==1 else b0
                ref=np.zeros((m,n),np.float64)
                for row in range(m):
                    s,e=rp[row:row+2];ref[row]=np.sum(v[s:e,None].astype(np.float64)*b[ix[s:e]].astype(np.float64),axis=0)
                if session!=1:np.testing.assert_array_equal(ref,np.fromfile(d/'expected.bin',np.float64).reshape(m,n))
                put('row_ptr',rp);put('col_idx',np.pad(ix,(0,cfg['capacity']-len(ix))));put('values',np.pad(v,(0,cfg['capacity']-len(v))));put('B',b.ravel());put('C',np.full(m*n,np.nan,np.float32))
                samples=[]
                for rep in range(4):
                    r.launch('compute',nonblock=False);out=get('C',m*n).view(np.float32).reshape(m,n);t=get('time_words',6,True).astype(np.uint64)
                    start=int(t[0])+int(t[1])*2**16+int(t[2])*2**32;end=int(t[3])+int(t[4])*2**16+int(t[5])*2**32
                    assert start>last and end>start;last=end
                    np.testing.assert_array_equal(out,ref)
                    samples.append(dict(rep=rep,warmup=rep==0,start=start,end=end,cycles=end-start,correct=True,output_sha256=hashlib.sha256(out.tobytes()).hexdigest()))
                out.tofile(d/f'output-session{session}.bin')
                records.append(dict(input_id=case['id'],family=case['family'],session=session,changed=session==1,samples=samples,cycles=int(np.median([s['cycles']for s in samples[1:]]))))
    finally:r.stop()
    Path('observations.json').write_text(json.dumps(dict(status='pass',execution='hardware'if args.cmaddr else 'simulator',case=cfg,records=records,elf_hashes={str(p):sha(p)for p in Path('out').glob('bin/*.elf')}),indent=2)+'\n')
    print('PASS',cfg['id'],len(records)*4,'checked launches')
if __name__=='__main__':main()
