"""Audit registered inputs/builds and summarize complete sweep cases."""
import argparse,csv,gzip,hashlib,json,statistics,struct
from pathlib import Path
ROOT=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()

def elf_memory(path):
 b=path.read_bytes();assert b[:6]==b'\x7fELF\x02\x01';h=struct.unpack_from('<HHIQQQIHHHHHH',b,16)
 ss=[struct.unpack_from('<IIQQQQIIQQ',b,h[5]+i*h[10])for i in range(h[11])]
 s=ss[h[12]];names=b[s[4]:s[4]+s[5]];sections=[]
 for s in ss:
  if s[2]&2 and s[5] and s[3]<49152:
   name=names[s[0]:].split(b'\0')[0].decode();sections.append(dict(name=name,address=s[3],bytes=s[5]))
 return dict(sections=sections,low_address_allocated_section_bytes=sum(s['bytes']for s in sections),low_address_end=max(s['address']+s['bytes']for s in sections))

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--complete',action='store_true');args=ap.parse_args()
 reg=json.loads((ROOT/'registration.json').read_text());rows=[];cases=[];observations={};controls=[];registered_launches=0
 for name,digest in reg['source_hashes'].items():assert sha(ROOT/name)==digest,name
 for name in reg['frozen_cases']:
  d=ROOT/'cases'/name;c=json.loads((d/'case.json').read_text());assert sha(d/'case.json')==reg['case_hashes'][name]
  for file,digest in c['source_hashes'].items():assert sha(d/file)==digest,str(d/file)
  registered_launches+=len(c['sessions'])*2*(c['repetitions']+1)
  info={k:c[k]for k in ('id','group','M','K','N','P','R','degree','variant','W','AC','BC','OC','declared_application_bytes')}
  if not (d/'result.json').exists():info['status']='pending';cases.append(info);continue
  result=json.loads((d/'result.json').read_text());info.update(status=result['status'],phases=result['phases'],queue_wait_seconds=result.get('queue_wait_seconds',0))
  for path,h in result.get('elf_sha256',{}).items():assert sha(d/path)==h,(name,path)
  for path,h in result.get('source_sha256',{}).items():assert sha(d/path)==h,(name,path)
  assert result['case_sha256']==sha(d/'case.json')
  partial=result['status']=='run_failed' and any(p['phase']=='run' and p['returncode']==124 for p in result['phases'])
  if result['status']!='pass' and not partial:cases.append(info);continue
  observation_file=d/'observations.json'
  if not observation_file.exists():observation_file=d/'observations.partial.json'
  if not observation_file.exists():cases.append(info);continue
  o=json.loads(observation_file.read_text());assert o['case']==c
  info['timing_evidence']='verified_records_from_timeout' if partial else 'complete_case'
  if not partial:
   assert o['status']=='pass' and len(o['records'])==len(c['sessions'])*2
   assert len(o['controls'])==c['repetitions']+1
  else:assert len(o['records'])<=len(c['sessions'])*2
  all_elf=list((d/'out/bin').glob('*.elf'));assert 1<=len(all_elf)<=c['P']
  info['unique_application_programs']=len(all_elf)
  mem={p.name:elf_memory(p)for p in all_elf};info['elf_memory']=mem
  info['max_allocated_section_bytes']=max(x['low_address_allocated_section_bytes']for x in mem.values())
  info['max_low_address_end']=max(x['low_address_end']for x in mem.values())
  observations[name]=o;cases.append(info);seen=set()
  for idx,r in enumerate(o['records']):
   spec=c['sessions'][idx//2]
   for key,value in spec.items():assert r[key]==value,(name,key)
   assert r['mode']==('broadcast'if idx%2==0 else 'resident')
   assert sorted(i for group in r['row_assignment']for i in group)==list(range(c['M']))
   assert max(map(len,r['row_assignment']))<=c['R']
   assert len(r['samples'])==c['repetitions']+1
   for i,s in enumerate(r['samples']):
    assert s['correct'] and s['root_ack']==c['P'] and s['warmup']==(i==0)
    assert len(s['local_compute_cycles'])==c['P']
    raw=s['raw_timestamps'];assert len(raw)==c['P']
    assert s['root_span_cycles']==(raw[0][3]-raw[0][0])%(2**48)
    assert s['local_compute_cycles']==[(v[2]-v[1])%(2**48)for v in raw]
    assert s['local_precompute_cycles']==[(v[1]-v[0])%(2**48)for v in raw]
   samples=[s for s in r['samples']if not s['warmup']];spans=[s['root_span_cycles']for s in samples]
   compute=[statistics.median(s['local_compute_cycles'][p]for s in samples)for p in range(c['P'])]
   mean=statistics.mean(compute);key=(r['pattern'],r['policy'],r['changed'],r['mode']);initial=key not in seen and not r['changed'];seen.add(key)
   row=dict(case=name,case_status=result['status'],timing_evidence=info['timing_evidence'],group=c['group'],M=c['M'],K=c['K'],N=c['N'],P=c['P'],degree=c['degree'],variant=c['variant'],W=c['W'],
    pattern=r['pattern'],policy=r['policy'],changed=r['changed'],session_index=idx//2,mode=r['mode'],initial=initial,matrix_hashes=r['matrix_hashes'],
    root_cycles=statistics.median(spans),root_min=min(spans),root_max=max(spans),local_cycles=compute,local_max=max(compute),local_mean=mean,
    compute_imbalance=max(compute)/mean,products=sum(r['products_per_pe']),products_per_pe=r['products_per_pe'],output_nnz=sum(r['output_nnz_per_pe']),outputs_per_pe=r['output_nnz_per_pe'],
    product_imbalance=max(r['products_per_pe'])/statistics.mean(r['products_per_pe']),
    useful_flops_per_root_cycle=2*sum(r['products_per_pe'])/statistics.median(spans),B_bytes=4*r['B_words'],
    declared_application_bytes=c['declared_application_bytes'],accumulator_bytes=c['W']*6,
    max_compiled_allocated_section_bytes=info['max_allocated_section_bytes'],
    host_preparation=r['host_preparation'],host_h2d_seconds=r['host_h2d_seconds'],
    host_launch_seconds=statistics.median(s['host_launch_seconds']for s in samples))
   rows.append(row)
  for s in o['controls']:assert s['root_ack']==c['P']
  values=[s['root_span_cycles']for s in o['controls']if not s['warmup']]
  if values:controls.append(dict(case=name,P=c['P'],N=c['N'],B_bytes=4*o['records'][-1]['B_words'],root_cycles=statistics.median(values),root_min=min(values),root_max=max(values)))
 # Strictly match global matrices before calculating strong-scaling speedups or algorithm comparisons.
 base={}
 for r in rows:
  if r['initial'] and r['P']==1:base[(r['group'],r['M'],r['K'],r['N'],r['degree'],r['variant'],r['pattern'],r['mode'])]=r
 for r in rows:
  k=(r['group'],r['M'],r['K'],r['N'],r['degree'],r['variant'],r['pattern'],r['mode']);b=base.get(k)
  if b and r['initial']:
   assert b['matrix_hashes']==r['matrix_hashes']
   r['strong_speedup']=b['root_cycles']/r['root_cycles'];r['strong_efficiency']=r['strong_speedup']/r['P'];r['baseline_case_status']=b['case_status']
  else:r['strong_speedup']=None;r['strong_efficiency']=None;r['baseline_case_status']=None
 # Match broadcast/resident and full/tiled global inputs, not packed per-PE array hashes.
 bykey={(r['group'],r['M'],r['K'],r['N'],r['P'],r['degree'],r['variant'],r['pattern'],r['policy'],r['mode']):r for r in rows if r['initial']}
 comparisons=[]
 for key,r in bykey.items():
  if r['variant']=='tiled':
   counterpart=list(key);counterpart[6]='full';b=bykey.get(tuple(counterpart))
   if b:
    assert b['matrix_hashes']==r['matrix_hashes']
    comparisons.append(dict(kind='accumulator',case=r['case'],case_status=r['case_status'],reference_case_status=b['case_status'],N=r['N'],P=r['P'],pattern=r['pattern'],policy=r['policy'],mode=r['mode'],ratio_tiled_over_full=r['root_cycles']/b['root_cycles'],full_cycles=b['root_cycles'],tiled_cycles=r['root_cycles']))
  if r['policy']=='product_balanced':
   counterpart=list(key);counterpart[8]='row_blocks';b=bykey.get(tuple(counterpart))
   if b:
    assert b['matrix_hashes']==r['matrix_hashes']
    comparisons.append(dict(kind='partition',case=r['case'],case_status=r['case_status'],reference_case_status=b['case_status'],N=r['N'],P=r['P'],pattern=r['pattern'],mode=r['mode'],speedup_balanced=b['root_cycles']/r['root_cycles'],blocks_cycles=b['root_cycles'],balanced_cycles=r['root_cycles'],blocks_compute_imbalance=b['compute_imbalance'],balanced_compute_imbalance=r['compute_imbalance']))
 statuses={s:sum(c['status']==s for c in cases)for s in sorted(set(c['status']for c in cases))}
 total_checks=sum(len(r['samples'])for o in observations.values()for r in o['records']);total_pe_checks=sum(o['case']['P']*len(r['samples'])for o in observations.values()for r in o['records'])
 result=dict(framework_base=reg['framework_base'],case_statuses=statuses,registered_cases=len(cases),registered_numerical_launches=registered_launches,
  verified_distributed_launches=total_checks,verified_PE_numerical_results=total_pe_checks,verified_communication_controls=sum(len(o['controls'])for o in observations.values()),
  cases=cases,rows=rows,controls=controls,comparisons=comparisons,
  timeout_cases_with_verified_timings=[c['id']for c in cases if c.get('timing_evidence')=='verified_records_from_timeout'],
  all_registered_complete=not any(c['status']=='pending'for c in cases))
 extras=[]
 for p in sorted((ROOT/'interrupted-attempts').glob('*/result.json')):
  record=json.loads(p.read_text());extras.append(dict(path=str(p.parent.relative_to(ROOT)),case=record['case'],status=record['status'],reason=record['reason'],verified_distributed_launches=record['verified_distributed_launches']))
 result['additional_attempts']=extras
 attempts={status:count for status,count in statuses.items()if status!='pending'}
 for attempt in extras:attempts[attempt['status']]=attempts.get(attempt['status'],0)+1
 result['completed_attempt_statuses']=attempts
 result['coordination_failures']=[dict(path=str(p.parent.relative_to(ROOT)),**json.loads(p.read_text()))for p in sorted((ROOT/'coordination-failures').glob('*/result.json'))]
 result['admission_events']=json.loads((ROOT/'admission-events.json').read_text())if(ROOT/'admission-events.json').exists()else []
 result['execution_protocol_revisions']={c['id']:json.loads((ROOT/'cases'/c['id']/'result.json').read_text()).get('execution_protocol_revision','original')for c in cases if c['status']!='pending'}
 if args.complete:assert result['all_registered_complete'],statuses
 (ROOT/'summary.json').write_text(json.dumps(result,indent=2)+'\n')
 payload=json.dumps(observations,separators=(',',':')).encode()
 (ROOT/'measurements.json.gz').write_bytes(gzip.compress(payload,mtime=0))
 scalar_fields=['case','case_status','timing_evidence','baseline_case_status','group','M','K','N','P','degree','variant','W','pattern','policy','changed','session_index','mode','initial','root_cycles','root_min','root_max','local_max','local_mean','compute_imbalance','products','output_nnz','product_imbalance','B_bytes','declared_application_bytes','accumulator_bytes','max_compiled_allocated_section_bytes','strong_speedup','strong_efficiency','host_launch_seconds']
 with (ROOT/'timings.csv').open('w',newline='')as f:
  w=csv.DictWriter(f,fieldnames=scalar_fields,lineterminator='\n');w.writeheader()
  for r in rows:w.writerow({k:r[k]for k in scalar_fields})
 print(json.dumps(dict(statuses=statuses,distributed_launches=total_checks,PE_checks=total_pe_checks)))
if __name__=='__main__':main()
