"""Validate complete sparse A*B with canonical CSR output and explicit capacity failure."""
import hashlib,json,statistics,time
from pathlib import Path
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime,MemcpyDataType,MemcpyOrder
from inputs import sparse_pair

def digest(a):return hashlib.sha256(np.ascontiguousarray(a).tobytes()).hexdigest()
def csr(A):
 ptr=[0];idx=[];val=[]
 for row in A:
  for j,v in enumerate(row):
   if v!=0:idx.append(j);val.append(v)
  ptr.append(len(idx))
 assert len(idx)<=256 and max(ptr)<65536
 return np.array(ptr,np.uint32),np.pad(np.array(idx,np.uint32),(0,256-len(idx))),np.pad(np.array(val,np.float32),(0,256-len(val)))
def main():
 cfg=json.loads(Path('case.json').read_text())
 for f,h in cfg['source_hashes'].items():assert hashlib.sha256(Path(f).read_bytes()).hexdigest()==h,f
 r=SdkRuntime('out');r.load();r.run();records=[];capacity_records=[]
 def put(name,a,small=False):
  a=np.ascontiguousarray(a,dtype=np.uint32 if small or name not in ('av','bv','cv') else np.float32)
  r.memcpy_h2d(r.get_id(name),a,0,0,1,1,len(a),streaming=False,data_type=MemcpyDataType.MEMCPY_16BIT if small else MemcpyDataType.MEMCPY_32BIT,order=MemcpyOrder.ROW_MAJOR,nonblock=False)
 def get(name,n,kind='u32'):
  a=np.zeros(n,np.uint32);r.memcpy_d2h(a,r.get_id(name),0,0,1,1,n,streaming=False,data_type=MemcpyDataType.MEMCPY_16BIT if kind=='u16' else MemcpyDataType.MEMCPY_32BIT,order=MemcpyOrder.ROW_MAJOR,nonblock=False)
  return a.view(np.float32) if kind=='f32' else a
 def load(A,B,limit):
  for prefix,a in (('a',A),('b',B)):
   ptr,idx,val=csr(a);put(prefix+'p',ptr);put(prefix+'j',idx);put(prefix+'v',val)
  put('limit',np.array([limit],np.uint32),True)
  put('cp',np.full(17,0xdeadbeef,np.uint32));put('cj',np.full(260,0xdeadbeef,np.uint32));put('cv',np.full(260,123456.,np.float32))
  put('count',np.array([65535],np.uint32),True);put('status',np.array([65535],np.uint32),True)
 def check(A,B,limit,rep):
  oracle=A.astype(np.float64)@B.astype(np.float64)
  structural=(A!=0).astype(np.int32)@(B!=0).astype(np.int32)>0
  expected_nnz=int(structural.sum());row,col=np.nonzero(structural);values=oracle[row,col]
  t=time.perf_counter();r.launch('compute',nonblock=False);wall=time.perf_counter()-t
  words=list(map(int,get('time_words',6,'u16')));start=words[0]|words[1]<<16|words[2]<<32;end=words[3]|words[4]<<16|words[5]<<32
  count=int(get('count',1,'u16')[0]);status=int(get('status',1,'u16')[0]);cp=get('cp',17);cj=get('cj',260);cv=get('cv',260,'f32')
  expected_count=min(limit,expected_nnz);assert count==expected_count,(count,expected_count)
  assert status==int(expected_nnz>limit),(status,expected_nnz,limit)
  np.testing.assert_array_equal(cj[:count],col[:count]);np.testing.assert_array_equal(cv[:count],values[:count])
  if status==0:np.testing.assert_array_equal(cp,np.r_[0,np.cumsum(structural.sum(axis=1))])
  np.testing.assert_array_equal(cj[count:],np.full(260-count,0xdeadbeef,np.uint32))
  np.testing.assert_array_equal(cv[count:],np.full(260-count,123456.,np.float32))
  return dict(repetition=rep,warmup=rep==0,correct=True,status=status,output_nnz=count,expected_nnz=expected_nnz,cancelled_positions=int(np.count_nonzero(structural&(oracle==0))),
   cycles=(end-start)%2**48,start=start,end=end,host_launch_s=wall,output_sha256=digest(np.concatenate([cp.view(np.float32),cj[:count].view(np.float32),cv[:count]])))
 try:
  r.launch('enable_timer',nonblock=False)
  for pattern in cfg['patterns']:
   for session,changed in enumerate([False,True,False]):
    t=time.perf_counter();A,B=sparse_pair(pattern,changed);prep=time.perf_counter()-t;load(A,B,256);samples=[]
    for rep in range(cfg['repetitions']+1):samples.append(check(A,B,256,rep))
    P=int(sum(np.count_nonzero(B[k]) for i,k in np.argwhere(A!=0)))
    records.append(dict(pattern=pattern,session=session,changed=changed,A=A.tolist(),B=B.tolist(),input_sha256=dict(A=digest(A),B=digest(B)),input_nnz=[int(np.count_nonzero(A)),int(np.count_nonzero(B))],intermediate_products=P,preparation_s=prep,samples=samples,median_cycles=statistics.median(s['cycles'] for s in samples if not s['warmup'])))
  for pattern,limit in [('dense',0),('dense',64),('dense',255),('dense',256),('empty',0)]:
   A,B=sparse_pair(pattern);load(A,B,limit);sample=check(A,B,limit,1)
   capacity_records.append(dict(pattern=pattern,limit=limit,sample=sample))
  # Restore after overflow; all state must be initialized by the next launch.
  A,B=sparse_pair('diagonal',True);load(A,B,256);capacity_records.append(dict(pattern='diagonal_after_capacity_tests',limit=256,sample=check(A,B,256,1)))
 finally:r.stop()
 out=dict(status='pass',execution='sdk_simulator',case=cfg,records=records,capacity_checks=capacity_records,timing_scope='one PE; input CSR already resident; scratch reset, discovery, numerical accumulation, capacity checks, sorted CSR emission, timer reads included; input preparation/transfers and output allocation excluded',elf_hashes={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in Path('out').rglob('*.elf')})
 Path('observations.json').write_text(json.dumps(out,indent=2)+'\n');print('PASS',cfg['id'],len(records)*4,'full-product launches +',len(capacity_records),'capacity/reset checks',flush=True)
if __name__=='__main__':main()
