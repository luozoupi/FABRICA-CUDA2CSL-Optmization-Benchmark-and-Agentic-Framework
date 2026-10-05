"""Verify exact-binary masked sparse-product traces and independent operation counts."""
import argparse
from collections import Counter, defaultdict
import hashlib
import json
import math
from pathlib import Path
import re
import struct
import sys
from audit_common import require, sha, elf_text, f32, round32


def algorithm_counts(A):
    n=len(A); columns=[[r for r in range(n) if A[r][j]!=0] for j in range(n)]
    counts=Counter(); output=[[0.0]*n for _ in range(n)]; structural=[]
    for j,cj in enumerate(columns):
        for i in cj:
            ci=columns[i]; counts['mask_positions']+=1
            counts['nested_comparisons']+=len(ci)*len(cj)
            intersection=sorted(set(ci)&set(cj))
            counts['products']+=len(intersection)
            if intersection:structural.append((i,j));counts['structural_output_positions']+=1
            output[i][j]=sum(A[k][i]*A[k][j] for k in intersection)
            if intersection and output[i][j]==0:counts['cancelled_output_positions']+=1
            p=q=0
            while p<len(ci) and q<len(cj):
                counts['merge_comparisons']+=1
                if ci[p]==cj[q]:p+=1;q+=1;counts['merge_equal']+=1
                elif ci[p]<cj[q]:p+=1;counts['merge_left_advance']+=1
                else:q+=1;counts['merge_right_advance']+=1
    counts['merge_less_than_comparisons']=counts['merge_left_advance']+counts['merge_right_advance']
    counts['unmasked_products']=sum(len(c)**2 for c in [[j for j in range(n) if A[i][j]!=0] for i in range(n)])
    counts['unmasked_structural_output_positions']=sum(bool(set(a)&set(b)) for a in columns for b in columns)
    counts['nnz']=sum(len(c) for c in columns)
    counts['column_lengths']=[len(c) for c in columns]
    counts['row_lengths']=[sum(v!=0 for v in row) for row in A]
    return dict(counts),output


def analyze(d,reader_type):
    cfg=json.loads((d/'case.json').read_text());binding=json.loads((d/'elf-binding.json').read_text());old=Path(binding['original'])
    require(sha(old/'observations.json')==binding['original_observations_sha256'],'Original observations changed')
    for rel,h in binding['elf_sha256'].items():require(sha(d/'out'/rel)==h==sha(old/'out'/rel),'ELF changed')
    for rel,h in cfg['source_hashes'].items():require(sha(d/rel)==h,'Source changed')
    require(sha(d/'disassembly.json')==sha(old/'disassembly.json'),'Disassembly changed')
    rows=[r for block in json.loads((d/'disassembly.json').read_text()).values() for r in block];asm={r['pc']:r for r in rows}
    require(len(rows)==len(asm),'Ambiguous disassembly')
    timers=sorted(r['pc'] for r in rows if re.match(r'ld16 .*\[0x7b30\]',r['instruction']))
    require(len(timers)==3,'Expect compute/control/shared-end timer sites')
    fp_sites={r['pc'] for r in rows if 'C[i*N+j] += values[p] * values[q]' in r.get('source','') and r['instruction'].split()[0] in ('fmuls','fadds')}
    equality=[r['pc'] for r in rows if r['instruction'].startswith('eq') and ('if (ri == rj)' in r.get('source','') or 'if (col_idx[p] == col_idx[q])' in r.get('source',''))]
    less=[r['pc'] for r in rows if r['instruction'].startswith('ltu') and 'else if (ri < rj)' in r.get('source','')]
    require(len(fp_sites)==2 and len(equality)==1,'Unexpected kernel sites')
    sections=[elf_text(p) for p in (d/'out/bin').glob('*.elf')];require(len(sections)==1,'Single PE required')
    geometry=json.loads((d/'simfab_traces/global_simdata.json').read_text());require((geometry['xsize'],geometry['ysize'])==(8,3),'Fabric changed')
    reader=reader_type(d/'simfab_traces');dispatch={};arithmetic={};anchors=[]
    for e in reader.iter_events():
        if e.get('tile_index')!=12:continue
        uid=e.get('uid')
        if e['event_type']=='hwm_dispatch_trace_entry':
            require(uid not in dispatch,'Duplicate UID')
            dispatch[uid]={k:e[k] for k in ('uid','cycle','inst_ptr','inst_bin','name')}
            if e['inst_ptr'] in timers:anchors.append(dispatch[uid])
        elif e['event_type']=='hwm_pipe_trace_entry' and e['stage']==6 and e['dest']!=0xffffffff:
            inst=dispatch.get(uid)
            if not inst or inst['inst_ptr'] not in fp_sites:continue
            vals={k:f32(e[k]) for k in ('src0','src1','dest')}
            require(all(math.isfinite(v) for v in vals.values()),'Nonfinite FP event')
            op=inst['name'].split()[0].upper()
            expected=round32(vals['src0']*vals['src1'] if op=='FMULS' else vals['src0']+vals['src1'])
            require(vals['dest']==expected,'FP operand/result mismatch')
            arithmetic.setdefault(uid,[]).append(dict(cycle=e['cycle'],lane=e['simdi'],values=vals))
    require(not reader.warnings and reader.discarded_events_total==0,'Incomplete trace')
    anchors.sort(key=lambda e:e['cycle']);obs=json.loads((d/'observations.json').read_text())
    samples=[(i,r,s) for i,r in enumerate(obs['records']) for s in r['samples']]
    require(len(samples)==36 and len(anchors)==78,'Unexpected launch/anchor count')
    seen=set();windows=[]
    for n,(ri,record,sample) in enumerate(samples):
        counts,oracle=algorithm_counts(record['A'])
        require(oracle==record['output'],'Independent sparse oracle disagrees')
        a,b=anchors[2*n:2*n+2];require([a['inst_ptr'],b['inst_ptr']]==[timers[0],timers[2]],'Timer path changed')
        require(b['cycle']-a['cycle']==sample['cycles']==sample['end']-sample['start'],'Timer mismatch')
        require(all(sample[k] for k in ('correct','structural_correct','matches_original_timing_and_output')),'Host validation failed')
        active=sorted((e for e in dispatch.values() if a['cycle']<=e['cycle']<b['cycle']),key=lambda e:e['cycle'])
        pcs=Counter();ops=Counter();fp=Counter();examples=[];gap=defaultdict(list);branches=defaultdict(list)
        for e,next_e in zip(active,active[1:]+[b]):
            pc=e['inst_ptr'];addr=2*pc;require(pc in asm,'Unknown PC')
            require(any(base<=addr<=base+len(data)-4 and struct.unpack_from('<I',data,addr-base)[0]==e['inst_bin'] for base,data in sections),'ELF encoding mismatch')
            pcs[pc]+=1;op=e['name'].split()[0].upper();ops[op]+=1
            delta=next_e['cycle']-e['cycle'];require(delta>=0,'Unordered dispatch');gap[pc].append(delta)
            branch=re.search(r'jmp (0x[0-9a-f]+)',asm[pc]['instruction'])
            if branch:
                target=int(branch[1],16);fallthrough=pc+2;visited=set()
                while fallthrough in asm and fallthrough not in visited:
                    visited.add(fallthrough);direct=re.fullmatch(r'jmp (0x[0-9a-f]+)',asm[fallthrough]['instruction'])
                    if not direct:break
                    fallthrough=int(direct[1],16)
                require(next_e['inst_ptr'] in (target,pc+2,fallthrough),f'Branch successor mismatch {pc}: {next_e["inst_ptr"]}')
                outcome='target' if next_e['inst_ptr']==target else 'fallthrough' if next_e['inst_ptr']==pc+2 else 'fallthrough_via_static_jump'
                branches[(pc,outcome)].append(delta)
            if pc in fp_sites:
                require(e['uid'] in arithmetic,'Missing FP result');events=arithmetic[e['uid']];seen.add(e['uid'])
                require(len(events)==1 and a['cycle']<=events[0]['cycle']<b['cycle'],'Unexpected scalar result event')
                fp[op]+=1
                if len(examples)<4:examples.append(dict(pc=pc,assembly=asm[pc]['instruction'],dispatch_cycle=e['cycle'],result=events[0]))
        require(fp['FMULS']==fp['FADDS']==counts['products'],'Wrong product count')
        require(pcs[equality[0]]==counts[d.name+'_comparisons'],'Wrong comparison count')
        if d.name=='merge':require(len(less)==1 and pcs[less[0]]==counts['merge_less_than_comparisons'],'Wrong merge branch count')
        require(sum(sum(v) for v in gap.values())==sample['cycles'],'Gaps do not partition elapsed cycles')
        windows.append(dict(pattern=record['pattern'],session=ri%3,changed=record['changed'],repetition=sample['repetition'],warmup=sample['warmup'],
            cycles=sample['cycles'],trace_start=a['cycle'],trace_end=b['cycle'],tsc_start=sample['start'],tsc_end=sample['end'],
            dispatches=len(active),algorithm_counts=counts,opcode_dispatches=dict(sorted(ops.items())),pc_counts=dict(sorted(pcs.items())),floating_results=dict(fp),arithmetic_examples=examples,
            pc_gaps={pc:dict(count=len(v),cycle_sum=sum(v),histogram=dict(Counter(v)),assembly=asm[pc]['instruction'],source=asm[pc].get('source')) for pc,v in gap.items()},
            branches=[dict(pc=pc,outcome=o,count=len(v),cycle_sum=sum(v),histogram=dict(Counter(v)),assembly=asm[pc]['instruction']) for (pc,o),v in branches.items()]))
    require(seen==set(arithmetic),'Unmatched arithmetic')
    for i,c in enumerate(obs['timer_control']):
        a,b=anchors[72+2*i:74+2*i];require([a['inst_ptr'],b['inst_ptr']]==timers[1:] and b['cycle']-a['cycle']==c['cycles'],'Timer control mismatch')
    files=['case.json','pe.csl','layout.csl','host.py','trace_host.py','elf-binding.json','disassembly.json','observations.json','baseline.json','replay-result.json']
    hashes={f:sha(d/f) for f in files};hashes.update({str(p.relative_to(d)):sha(p) for p in (d/'simfab_traces').iterdir() if p.is_file()})
    return dict(id=d.name,passed=True,windows=windows,hashes=hashes,elf_sha256=binding['elf_sha256'],timer_pcs=timers,equality_pc=equality[0],less_than_pcs=less,
        floating_pcs=sorted(fp_sites),timer_control_cycles=[x['cycles'] for x in obs['timer_control']],discarded_events=reader.discarded_events_total,
        scope='One application PE. Masked A^T A; output clearing included, host copies and preprocessing excluded. Dispatch events are not retired instructions; dispatch intervals are not instruction latencies or stall counters.')


def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--root',type=Path,required=True);ap.add_argument('--trace-library',type=Path,required=True);args=ap.parse_args()
    sys.path.insert(0,str(args.trace_library));from wse3study.trace import CtfTraceReader
    results=[]
    for d in sorted((args.root/'cases').iterdir()):
        require(json.loads((d/'replay-result.json').read_text())['status']=='pass','Replay failed')
        result=analyze(d,CtfTraceReader);results.append(result);(d/'trace-analysis.json').write_text(json.dumps(result,indent=2)+'\n')
        print(d.name,'PASS',len(result['windows']),'windows',flush=True)
    payload=dict(analyzer_sha256=sha(Path(__file__)),helper_sha256=sha(Path(__file__).with_name('audit_common.py')),parser_sha256=sha(args.trace_library/'wse3study/trace.py'),results=results)
    (args.root/'trace-analysis.json').write_text(json.dumps(payload,indent=2)+'\n')
    compact=[]
    for result in results:
        for w in result['windows']:
            if w['repetition']==1:compact.append(dict(case=result['id'],**{k:w[k] for k in ('pattern','session','changed','cycles','dispatches','algorithm_counts','floating_results')}))
    (args.root/'summary.json').write_text(json.dumps(dict(passed=True,kernel_launches=sum(len(r['windows']) for r in results),rows=compact),indent=2)+'\n')
if __name__=='__main__':main()
