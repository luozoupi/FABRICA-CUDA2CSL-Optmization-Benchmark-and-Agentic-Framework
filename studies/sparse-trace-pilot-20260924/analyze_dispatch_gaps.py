"""Account for intervals between dispatches, without treating them as instruction latency."""
import argparse
from collections import defaultdict
import hashlib
import json
from pathlib import Path
import re
import sys


def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--root',type=Path,required=True)
    ap.add_argument('--trace-library',type=Path,required=True);ap.add_argument('--cases',nargs='+',default=['descriptor-n1','scalar-n4'])
    args=ap.parse_args();sys.path.insert(0,str(args.trace_library));from wse3study.trace import CtfTraceReader
    results=[]
    for name in args.cases:
        d=args.root/'cases'/name
        validated=json.loads((d/'trace-analysis.json').read_text())
        assert validated['passed']
        rows=[r for v in json.loads((d/'disassembly.json').read_text()).values() for r in v];asm={r['pc']:r for r in rows}
        reader=CtfTraceReader(d/'simfab_traces');events=[]
        for e in reader.iter_events():
            if e.get('tile_index')==12 and e['event_type']=='hwm_dispatch_trace_entry':
                events.append((e['cycle'],e['inst_ptr'],e['uid']))
        assert not reader.warnings and reader.discarded_events_total==0
        events.sort();windows=[]
        for w in validated['windows']:
            if w['session']!=0 or w['repetition']!=1:continue
            selected=[e for e in events if w['trace_start']<=e[0]<=w['trace_end']]
            assert selected[0][0]==w['trace_start'] and selected[-1][0]==w['trace_end']
            assert len(selected)-1==w['dispatches']
            groups=defaultdict(list);branches=defaultdict(list)
            for a,b in zip(selected,selected[1:]):
                cycle,pc,uid=a;gap=b[0]-cycle;assert gap>=0
                groups[pc].append(gap)
                instruction=asm[pc]['instruction']
                branch=re.search(r'jmp (0x[0-9a-f]+)',instruction)
                if branch:
                    target=int(branch[1],16)
                    fallthrough=pc+2; visited=set()
                    while fallthrough in asm and fallthrough not in visited:
                        visited.add(fallthrough)
                        direct=re.fullmatch(r'jmp (0x[0-9a-f]+)',asm[fallthrough]['instruction'])
                        if not direct: break
                        fallthrough=int(direct[1],16)
                    assert b[1] in (target,pc+2,fallthrough),(pc,b[1],target,fallthrough)
                    outcome=('target' if b[1]==target else 'fallthrough' if b[1]==pc+2 else 'fallthrough_via_static_jump')
                    branches[(pc,outcome)].append(gap)
            assert sum(sum(v) for v in groups.values())==w['cycles']
            pc_gaps={str(pc):dict(count=len(v),cycle_sum=sum(v),min=min(v),max=max(v),histogram={str(x):v.count(x) for x in sorted(set(v))},assembly=asm[pc]['instruction'],source=asm[pc].get('source')) for pc,v in groups.items()}
            branch_gaps=[dict(pc=pc,outcome=outcome,count=len(v),cycle_sum=sum(v),histogram={str(x):v.count(x) for x in sorted(set(v))},assembly=asm[pc]['instruction']) for (pc,outcome),v in branches.items()]
            windows.append(dict(family=w['family'],cycles=w['cycles'],dispatches=w['dispatches'],pc_gaps=pc_gaps,branches=branch_gaps))
        result=dict(case=name,windows=windows,validation_sha256=sha(d/'trace-analysis.json'))
        results.append(result)
        print(name,'dispatch-gap accounting PASS',flush=True)
    (args.root/('dispatch-gap-'+'-'.join(args.cases)+'.json')).write_text(json.dumps(dict(analyzer_sha256=sha(Path(__file__)),results=results,scope='Intervals from each dispatch to the next, including the ending timestamp anchor. These partition elapsed simulator cycles but are not instruction execution latency or hardware stall counters.'),indent=2)+'\n')

if __name__=='__main__':main()
