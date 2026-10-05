"""Prepare fresh exact-binary sparse trace replays without altering the original study."""
import argparse
import datetime
import hashlib
import json
from pathlib import Path
import shutil


def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--source-root',type=Path,required=True,help='Original sparse-crossarch study wse directory')
    ap.add_argument('--output-root',type=Path,required=True,help='Fresh directory containing copied replay scripts')
    args=ap.parse_args();root=args.output_root.resolve();original=args.source_root.resolve();root.mkdir(parents=True,exist_ok=True)
    if (root/'cases').exists() or (root/'registration.json').exists():raise RuntimeError('Refusing to overwrite an existing replay registration')
    names=['scalar-n1','descriptor-n1','scalar-n4','descriptor-n4','descriptor-n16','hoisted-n16']
    registration=dict(created_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),framework_commit='cb3785baa4201832b4cdbe7324aff00383f77ea4',scope='Local controlled-kernel profiling pilot; not O1I agent replay. No new compilation or API calls.',original_root=str(original),cases=names,families=['uniform8','skew8'],sessions=['original','changed_indices_values_dense_operand','restored_original'],warmups=1,timing_repetitions=3,launches=144,predictions=['Descriptor setup outweighs work saved at width 1.','Descriptor processing amortizes setup at width 4.','Source descriptor hoisting at width 16 does not reduce emitted per-nonzero setup.'],analysis='Measured ELF and input hash binding; CTF instruction encodings; per-launch timer anchors and arithmetic work. Treat counts as events, not runtime percentages. Preserve all discrepancies.',remote_artifact_gap='O1I SpMV and SpMM candidate source and measured ELF bundles not present locally or committed on origin/sparse_ipdps at review.')
    (root/'registration.json').write_text(json.dumps(registration,indent=2)+'\n')
    for name in names:
        src=original/name;dst=root/'cases'/name;dst.mkdir(parents=True)
        if json.loads((src/'acceptance.json').read_text())['status']!='pass':raise ValueError('Unaccepted source case '+name)
        for f in ['case.json','pe.csl','layout.csl','host.py','disassembly.json','observations.json','acceptance.json']:
            shutil.copy2(src/f,dst/('baseline.json' if f=='observations.json' else f))
        shutil.copytree(src/'out',dst/'out');cfg=json.loads((dst/'case.json').read_text())
        for v in cfg['inputs']:
            if v['family'] in registration['families']:shutil.copytree(src/'inputs'/v['id'],dst/'inputs'/v['id'])
        binding={str(p.relative_to(src/'out')):sha(p) for p in (src/'out').rglob('*.elf')}
        for rel,h in binding.items():
            if sha(dst/'out'/rel)!=h:raise ValueError('Copied ELF changed')
        (dst/'elf-binding.json').write_text(json.dumps(dict(original=str(src),elf_sha256=binding,original_observations_sha256=sha(src/'observations.json')),indent=2)+'\n')
        host=(src/'host.py').read_text()
        if host.count("for case in cfg['inputs']:")!=1 or host.count("Path('observations.json').write_text")!=1:raise ValueError('Unsupported original host version')
        host=host.replace("for case in cfg['inputs']:","for case in cfg['inputs']:\n            if case['family'] not in ('uniform8','skew8'): continue")
        host=host.replace("Path('observations.json').write_text", "baseline=json.loads(Path('baseline.json').read_text())\n    for record in records:\n        old=next(x for x in baseline['records'] if x['input_id']==record['input_id'] and x['session']==record['session'])\n        for fresh, saved in zip(record['samples'],old['samples']):\n            assert fresh['cycles']==saved['cycles'], (record['input_id'],fresh['cycles'],saved['cycles'])\n            assert fresh['output_sha256']==saved['output_sha256']\n            fresh['matches_original_timing_and_output']=True\n    Path('observations.json').write_text")
        (dst/'trace_host.py').write_text(host)
    print('Prepared',len(names),'cases; frozen source study unchanged')

if __name__=='__main__':main()
