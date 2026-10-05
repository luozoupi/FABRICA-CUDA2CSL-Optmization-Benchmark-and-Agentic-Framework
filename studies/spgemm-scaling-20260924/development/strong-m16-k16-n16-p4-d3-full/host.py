"""Multi-PE correctness, actual broadcasts, root-clock spans, and local durations."""
import hashlib,json,time
from pathlib import Path
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime,MemcpyDataType,MemcpyOrder
from inputs import packed,digest

def main():
 c=json.loads(Path('case.json').read_text())
 for name,h in c['source_hashes'].items():assert hashlib.sha256(Path(name).read_bytes()).hexdigest()==h,name
 P,S,R,OC=(c[k]for k in ('P','S','R','OC'));clen=R+1+2*(OC+4)
 r=SdkRuntime('out');r.load();r.run();records=[];controls=[]
 def put(name,a,small=False,root=False):
  a=np.ascontiguousarray(a,dtype=np.uint32);length=a.size if root else a.size//P
  r.memcpy_h2d(r.get_id(name),a.reshape(-1),0,0,1 if root else S,1 if root else S,length,streaming=False,data_type=MemcpyDataType.MEMCPY_16BIT if small else MemcpyDataType.MEMCPY_32BIT,order=MemcpyOrder.ROW_MAJOR,nonblock=False)
 def get(name,length,small=False,root=False):
  result=np.zeros((1 if root else P,length),np.uint32)
  r.memcpy_d2h(result.reshape(-1),r.get_id(name),0,0,1 if root else S,1 if root else S,length,streaming=False,data_type=MemcpyDataType.MEMCPY_16BIT if small else MemcpyDataType.MEMCPY_32BIT,order=MemcpyOrder.ROW_MAJOR,nonblock=False)
  return result
 def save():
  Path('observations.partial.json').write_text(json.dumps(dict(case=c,records=records,controls=controls),indent=2)+'\n')
 def check(data,mode,rep):
  t=time.perf_counter();r.launch('start',nonblock=False);launch=time.perf_counter()-t
  t=time.perf_counter();report=get('report',24,True);ack=get('total_sum',1,root=True).view(np.float32)[0,0]
  assert ack==P,('ack',ack,P)
  stamps=report[:,:12].reshape(P,4,3).astype(np.uint64)
  stamps=stamps[:,:,0]+(stamps[:,:,1]<<16)+(stamps[:,:,2]<<32)
  compute=((stamps[:,2]-stamps[:,1])%(2**48)).tolist()
  spans=((stamps[:,3]-stamps[:,0])%(2**48)).tolist()
  pre=((stamps[:,1]-stamps[:,0])%(2**48)).tolist()
  numerical=True;hashout=None
  if mode!=2:
   out=get('cc',clen);hashout=digest(out)
   for pe,rows in enumerate(data['groups']):
    assert report[pe,13]==0,('capacity',pe)
    expected=[pair for i in rows for pair in data['expected'][i]];cnt=len(expected)
    assert int(report[pe,12])==cnt
    cp=np.r_[0,np.cumsum([len(data['expected'][i])for i in rows])]
    np.testing.assert_array_equal(out[pe,:len(cp)],cp)
    np.testing.assert_array_equal(out[pe,R+1:R+1+cnt],[j for j,v in expected])
    np.testing.assert_array_equal(out[pe,R+1+OC+4:R+1+OC+4+cnt].view(np.float32),[v for j,v in expected])
    np.testing.assert_array_equal(out[pe,R+1+cnt:R+1+OC+4],np.full(OC+4-cnt,0xdeadbeef,np.uint32))
    np.testing.assert_array_equal(out[pe,R+1+OC+4+cnt:],np.full(OC+4-cnt,0xdeadbeef,np.uint32))
  return dict(repetition=rep,warmup=rep==0,correct=numerical,root_ack=float(ack),root_span_cycles=int(spans[0]),
   local_compute_cycles=list(map(int,compute)),local_precompute_cycles=list(map(int,pre)),raw_timestamps=stamps.tolist(),
   host_launch_seconds=launch,host_d2h_and_validation_seconds=time.perf_counter()-t,output_sha256=hashout)
 try:
  r.launch('init',nonblock=False)
  for spec in c['sessions']:
   t=time.perf_counter();data=packed(c,spec['pattern'],spec['policy'],spec['changed']);prep=time.perf_counter()-t
   # Only root has B; all receivers start poisoned. A and outputs are explicitly initialized.
   t=time.perf_counter();put('aa',data['aa']);put('bb',np.full((P,len(data['bb'])),0xdeadbeef,np.uint32));put('bb',data['bb'],root=True)
   put('cc',np.full((P,clen),0xdeadbeef,np.uint32));h2d=time.perf_counter()-t
   cfg=np.zeros((P,4),np.uint32);cfg[:,0]=[len(g)for g in data['groups']];cfg[:,1]=data['bwords'];cfg[:,3]=OC
   for mode in (0,1):
    cfg[:,2]=mode;put('config',cfg,True);samples=[]
    for rep in range(c['repetitions']+1):samples.append(check(data,mode,rep))
    # Compare all received B words, independently of numerical output use.
    if mode==0:
     actual=get('bb',len(data['bb']));np.testing.assert_array_equal(actual[:,:data['bwords']],np.broadcast_to(data['bb'][:data['bwords']],(P,data['bwords'])))
    records.append(dict(**spec,mode='broadcast' if mode==0 else 'resident',input_hashes=data['input_hashes'],row_assignment=data['groups'],
     products_per_pe=data['counts'],output_nnz_per_pe=data['outputs'],B_words=data['bwords'],preprocessing_including_oracle_seconds=prep,host_h2d_seconds=h2d,samples=samples))
    save();print('PASS',c['id'],spec,'mode',mode,'root',samples[-1]['root_span_cycles'],'local_max',max(samples[-1]['local_compute_cycles']),flush=True)
  # No-compute control retains the same B payload and completion protocol; no subtraction from primary timing.
  cfg[:,2]=2;put('config',cfg,True)
  for rep in range(c['repetitions']+1):controls.append(check(data,2,rep))
 finally:r.stop()
 result=dict(status='pass',case=c,records=records,controls=controls,
  timing_scope='root local clock: causal start/B broadcast through all-PE completion reduction; local kernel duration uses same-PE subtraction; host packing/transfers, library init and output gather excluded; resident mode broadcasts a one-word start token',
  elf_hashes={str(p):hashlib.sha256(p.read_bytes()).hexdigest()for p in Path('out').rglob('*.elf')})
 Path('observations.json').write_text(json.dumps(result,indent=2)+'\n')
 print('COMPLETE',c['id'],sum(len(x['samples'])for x in records),'verified distributed launches',flush=True)
if __name__=='__main__':main()
