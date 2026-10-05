"""Audit selected kernels using original ELF encodings, timers, and FP operands."""
import argparse
from collections import Counter,defaultdict
import json,math,re,struct,sys
from pathlib import Path
from audit_common import sha,require,elf_text,f32,round32
ROOT=Path(__file__).resolve().parent

def products(A,B=None):
 n=len(A)
 if B is None:return sum(sum(A[k][i]!=0 and A[k][j]!=0 for k in range(n)) for i in range(n) for j in range(n) if A[i][j]!=0)
 return sum(sum(v!=0 for v in B[k]) for row in A for k,a in enumerate(row) if a!=0)

def analyze(d,reader_class):
 cfg=json.loads((d/'case.json').read_text());bind=json.loads((d/'binding.json').read_text());src=Path(bind['source'])
 require(sha(src/'observations.json')==bind['original_observations_sha256'],'Original measurements changed')
 for f,h in cfg['source_hashes'].items():require(sha(d/f)==h,'Source changed')
 for f,h in bind['elf_sha256'].items():require(sha(d/'out'/f)==h==sha(src/'out'/f),'ELF changed')
 asm={r['pc']:r for v in json.loads((d/'disassembly.json').read_text()).values() for r in v}
 timer_pcs=sorted(pc for pc,r in asm.items() if re.match(r'ld16 .*\[0x7b30\]',r['instruction']))
 general=d.name.startswith('general-');require(len(timer_pcs)==(2 if general else 3),'Unexpected timer sites')
 fp_pcs={pc for pc,r in asm.items() if r['instruction'].split()[0] in ('fmuls','fadds') and ('C[i*N+j] += values[p] * values[q]' in r.get('source','') or 'acc[local_j] += aval * bv[q]' in r.get('source',''))}
 require(len(fp_pcs)==2,'Expected scalar multiply and add')
 sections=[elf_text(p) for p in (d/'out/bin').glob('*.elf')];require(len(sections)==1,'One application ELF expected')
 reader=reader_class(d/'simfab_traces');dispatch={};fp={};anchors=[]
 for e in reader.iter_events():
  if e.get('tile_index')!=12:continue
  uid=e.get('uid')
  if e['event_type']=='hwm_dispatch_trace_entry':
   require(uid not in dispatch,'Repeated UID');dispatch[uid]={k:e[k] for k in ('uid','cycle','inst_ptr','inst_bin','name')}
   if e['inst_ptr'] in timer_pcs:anchors.append(dispatch[uid])
  elif e['event_type']=='hwm_pipe_trace_entry' and e['stage']==6 and e['dest']!=0xffffffff:
   inst=dispatch.get(uid)
   if not inst or inst['inst_ptr'] not in fp_pcs:continue
   v={k:f32(e[k]) for k in ('src0','src1','dest')};require(all(math.isfinite(x) for x in v.values()),'Nonfinite operand')
   op=inst['name'].split()[0].upper();expected=round32(v['src0']*v['src1'] if op=='FMULS' else v['src0']+v['src1'])
   require(v['dest']==expected,'Wrong FP result');fp.setdefault(uid,[]).append(dict(cycle=e['cycle'],lane=e['simdi'],values=v))
 require(not reader.warnings and reader.discarded_events_total==0,'Incomplete trace');anchors.sort(key=lambda e:e['cycle'])
 obs=json.loads((d/'observations.json').read_text());old=json.loads((src/'observations.json').read_text());samples=[(r,s) for r in obs['records'] for s in r['samples']]
 controls=obs.get('timer_control',[]);require(len(anchors)==2*(len(samples)+len(controls)),'Anchor count mismatch')
 windows=[];seen=set()
 for index,(record,sample) in enumerate(samples):
  a,b=anchors[2*index:2*index+2];require([a['inst_ptr'],b['inst_ptr']]==[timer_pcs[0],timer_pcs[-1]],'Wrong timer path')
  require(b['cycle']-a['cycle']==sample['cycles']==sample['end']-sample['start'],'Timer mismatch');require(sample['correct'],'Numerical check failed')
  reference=next(r for r in old['records'] if r['pattern']==record['pattern'] and not r['changed'])
  prior=reference['samples'][sample['repetition']]
  require(record['input_sha256']==reference['input_sha256'] and sample['cycles']==prior['cycles'] and sample['output_sha256']==prior['output_sha256'],'Replay differs from original measurement')
  es=sorted((e for e in dispatch.values() if a['cycle']<=e['cycle']<b['cycle']),key=lambda e:e['cycle']);pcs=Counter();ops=Counter();fps=Counter();gaps=defaultdict(list);branches=defaultdict(list);examples=[]
  for e,nxt in zip(es,es[1:]+[b]):
   pc=e['inst_ptr'];addr=2*pc;require(pc in asm,'Unknown PC')
   require(any(base<=addr<=base+len(data)-4 and struct.unpack_from('<I',data,addr-base)[0]==e['inst_bin'] for base,data in sections),'Encoding mismatch')
   pcs[pc]+=1;op=e['name'].split()[0].upper();ops[op]+=1;gap=nxt['cycle']-e['cycle'];require(gap>=0,'Negative gap');gaps[pc].append(gap)
   branch=re.search(r'jmp (0x[0-9a-f]+)',asm[pc]['instruction'])
   if branch:
    target=int(branch[1],16);fall=pc+2;visited=set()
    while fall in asm and fall not in visited:
     visited.add(fall);jump=re.fullmatch(r'jmp (0x[0-9a-f]+)',asm[fall]['instruction'])
     if not jump:break
     fall=int(jump[1],16)
    require(nxt['inst_ptr'] in (target,pc+2,fall),f'Unexpected branch successor at {pc}')
    outcome='target' if nxt['inst_ptr']==target else 'fallthrough' if nxt['inst_ptr']==pc+2 else 'fallthrough_via_static_jump';branches[(pc,outcome)].append(gap)
   if pc in fp_pcs:
    uid=e['uid'];require(uid in fp and len(fp[uid])==1,'Missing scalar FP event');seen.add(uid);require(a['cycle']<=fp[uid][0]['cycle']<b['cycle'],'FP outside window');fps[op]+=1
    if len(examples)<4:examples.append(dict(pc=pc,assembly=asm[pc]['instruction'],dispatch_cycle=e['cycle'],result=fp[uid][0]))
  expected=products(record['A'],record['B'] if general else None)
  require(fps['FMULS']==fps['FADDS']==expected,'Wrong product count')
  require(sum(sum(v) for v in gaps.values())==sample['cycles'],'Interval sum mismatch')
  windows.append(dict(pattern=record['pattern'],repetition=sample['repetition'],warmup=sample['warmup'],cycles=sample['cycles'],dispatches=len(es),products=expected,opcode_dispatches=dict(ops),pc_counts=dict(pcs),floating_results=dict(fps),arithmetic_examples=examples,
   pc_intervals={pc:dict(count=len(v),cycles=sum(v),histogram=dict(Counter(v)),assembly=asm[pc]['instruction'],source=asm[pc].get('source')) for pc,v in gaps.items()},
   branches=[dict(pc=pc,outcome=o,count=len(v),cycles=sum(v),histogram=dict(Counter(v)),assembly=asm[pc]['instruction']) for (pc,o),v in branches.items()]))
 require(seen==set(fp),'Unmatched arithmetic event')
 for i,c in enumerate(controls):
  a,b=anchors[2*(len(samples)+i):2*(len(samples)+i+1)];require([a['inst_ptr'],b['inst_ptr']]==timer_pcs[1:] and b['cycle']-a['cycle']==c['cycles'],'Control mismatch')
 hashes={str(p.relative_to(d)):sha(p) for p in d.rglob('*') if p.is_file() and (p.suffix in ('.py','.csl','.elf','.json') or p.parent.name=='simfab_traces') and p.name not in ('trace-audit.json',)}
 return dict(case=d.name,passed=True,windows=windows,hashes=hashes,original=str(src),timer_pcs=timer_pcs,fp_pcs=sorted(fp_pcs),scope='Dispatch events and dispatch-interval accounting; not retired-instruction CPI or physical hardware stalls.')

def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--trace-library',type=Path,required=True);a=ap.parse_args();sys.path.insert(0,str(a.trace_library));from wse3study.trace import CtfTraceReader
 results=[]
 for d in sorted((ROOT/'traces').iterdir()):
  require(json.loads((d/'result.json').read_text())['status']=='pass','Trace replay failed');r=analyze(d,CtfTraceReader);results.append(r);(d/'trace-audit.json').write_text(json.dumps(r,indent=2)+'\n');print(d.name,'PASS',len(r['windows']),'windows',flush=True)
 (ROOT/'trace-audit.json').write_text(json.dumps(dict(analyzer_sha256=sha(Path(__file__)),helper_sha256=sha(ROOT/'audit_common.py'),parser_sha256=sha(a.trace_library/'wse3study/trace.py'),results=results),indent=2)+'\n')
if __name__=='__main__':main()
