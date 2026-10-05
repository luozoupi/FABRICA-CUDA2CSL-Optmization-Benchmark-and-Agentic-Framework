"""Prepare exact-binary masked A^T A replays; keep general SpGEMM separate."""
import argparse
import datetime
import hashlib
import json
from pathlib import Path
import shutil
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--source-root',type=Path,default=Path('/home/USER/wse-matmul-microbench/builds'))
parser.add_argument('--output-root',type=Path,default=Path(__file__).resolve().parent)
args=parser.parse_args()
ROOT=args.output_root.resolve();ROOT.mkdir(parents=True,exist_ok=True)
SOURCE=args.source_root.resolve()
if (ROOT/'registration.json').exists():raise RuntimeError('Do not overwrite a registered pilot')
registration=dict(created_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),framework_commit='3b8ebd80b0452e9245fb50601975aa11b48c81c5',scope='Masked sparse A^T A at positions present in A; one PE; fixed output and structural-presence buffers. Not general SpGEMM.',cases=['merge','nested'],dimensions=[16,16,16],patterns=['banded','uniform','skewed'],sessions=['original','changed values and column pattern','restore original'],warmups=1,timing_repetitions=3,expected_kernel_launches=72,timer_controls_per_case=3,prediction='Replay the existing algorithm ranking reversal; use executed index comparisons, branch successors and arithmetic events to explain why dimensions, density and degree do not suffice.',new_compilations=0,new_api_calls=0,hardware_runs=0)
(ROOT/'registration.json').write_text(json.dumps(registration,indent=2)+'\n')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
for variant in registration['cases']:
 src=SOURCE/f'perf-masked-{variant}-16x16x16-r'; d=ROOT/'cases'/variant;d.mkdir(parents=True)
 acceptance=json.loads((src/'acceptance.json').read_text());assert acceptance['status']=='pass'
 assert sha(src/'observations.json')==acceptance['observations_sha256']
 for name in ['case.json','pe.csl','layout.csl','host.py','observations.json','acceptance.json','disassembly.json']:
  shutil.copy2(src/name,d/('baseline.json' if name=='observations.json' else name))
 shutil.copytree(src/'out',d/'out')
 binding={str(p.relative_to(src/'out')):sha(p) for p in (src/'out').rglob('*.elf')}
 for rel,h in binding.items():assert sha(d/'out'/rel)==h
 (d/'elf-binding.json').write_text(json.dumps(dict(original=str(src),elf_sha256=binding,original_observations_sha256=sha(src/'observations.json')),indent=2)+'\n')
 host=(src/'host.py').read_text();anchor='    Path(args.output).write_text'
 assert host.count(anchor)==1
 extra='''    baseline=json.loads(Path('baseline.json').read_text())
    assert len(records)==len(baseline['records'])
    for fresh,old in zip(records,baseline['records']):
        assert fresh['pattern']==old['pattern'] and fresh['changed']==old['changed']
        assert fresh['input_sha256']==old['input_sha256']
        assert len(fresh['samples'])==len(old['samples'])
        for a,b in zip(fresh['samples'],old['samples']):
            assert a['cycles']==b['cycles'],(fresh['pattern'],a['cycles'],b['cycles'])
            assert a['output_sha256']==b['output_sha256']
            a['matches_original_timing_and_output']=True
'''
 (d/'trace_host.py').write_text(host.replace(anchor,extra+anchor))
print('Prepared two exact measured sparse-product binaries')
