"""Export a standalone view of audited measurements; no synthetic packet timings."""
import gzip,json
from pathlib import Path
ROOT=Path(__file__).resolve().parent
s=json.loads((ROOT/'summary.json').read_text())
o=json.loads(gzip.decompress((ROOT/'measurements.json.gz').read_bytes()))
rows=[]
for r in s['rows']:
 if not r['initial']:continue
 raw=o[r['case']]['records'][r['session_index']*2+(r['mode']=='resident')]
 assert raw['matrix_hashes']==r['matrix_hashes']
 phases=[]
 for sample in raw['samples']:
  if sample['warmup']:continue
  stamps=sample['raw_timestamps'][0]
  intervals=[(stamps[i+1]-stamps[i])%(2**48)for i in range(3)]
  assert sum(intervals)==sample['root_span_cycles']
  assert intervals[1]==sample['local_compute_cycles'][0]
  phases.append(intervals)
 rows.append(dict(r,row_assignment=raw['row_assignment'],root_samples=[x['root_span_cycles']for x in raw['samples']if not x['warmup']],root_phases=phases))
payload=dict(cases=s['cases'],rows=rows,statuses=s['case_statuses'],launches=s['verified_distributed_launches'],pe_checks=s['verified_PE_numerical_results'],complete=s['all_registered_complete'],extra_attempts=len(s.get('additional_attempts',[])))
text=(ROOT/'explorer-template.html').read_text().replace('__MEASUREMENTS__',json.dumps(payload,separators=(',',':')).replace('<','\\u003c'))
(ROOT/'explorer.html').write_text(text)
print('Exported',len(rows),'audited measurement records')
