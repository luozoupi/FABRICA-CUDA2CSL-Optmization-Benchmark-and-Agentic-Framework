"""Package compact evidence; retain large traces and original ELF bundles locally."""
import argparse
import gzip
import json
from pathlib import Path
import shutil
import tarfile
from audit_common import sha

ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--destination',type=Path,required=True);args=ap.parse_args()
root=Path(__file__).resolve().parent;dest=args.destination.resolve();dest.mkdir(parents=True,exist_ok=True)
analysis=json.loads((root/'trace-analysis.json').read_text())
assert len(analysis['results'])==2 and all(r['passed'] for r in analysis['results'])
assert sum(len(r['windows']) for r in analysis['results'])==72
archive=root/'replay-inputs.tar.gz'
if not archive.exists():
    with tarfile.open(archive,'w:gz') as tar:
        for name in ('merge','nested'):
            binding=json.loads((root/'cases'/name/'elf-binding.json').read_text());original=Path(binding['original'])
            for item in ['case.json','pe.csl','layout.csl','host.py','observations.json','acceptance.json','disassembly.json','out']:
                tar.add(original/item,arcname=str(Path(original.name)/item))
with gzip.GzipFile(filename=str(root/'trace-analysis.json.gz'),mode='wb',mtime=0) as f:f.write((root/'trace-analysis.json').read_bytes())
files=['README.md','HANDOFF.md','registration.json','prepare_replays.py','run_replays.py','audit_common.py','analyze_spgemm.py','summarize_evidence.py','package_evidence.py','summary.json','findings.json','replay-summary.json','trace-analysis.json.gz']
for name in files:
    if (root/name).resolve()!=(dest/name).resolve():shutil.copy2(root/name,dest/name)
for name in ('merge','nested'):
    fixture=dest/'fixtures'/name;fixture.mkdir(parents=True,exist_ok=True)
    for item in ['case.json','pe.csl','layout.csl','host.py','elf-binding.json','acceptance.json','observations.json']:
        source_item='baseline.json' if item=='observations.json' else item
        shutil.copy2(root/'cases'/name/source_item,fixture/item)
trace_files={str(root/'cases'/r['id']/name):digest for r in analysis['results'] for name,digest in r['hashes'].items()}
trace_files[str(root/'trace-analysis.json')]=sha(root/'trace-analysis.json')
trace_files[str(archive)]=sha(archive)
manifest=dict(origin='NVIDIA GPU node with Cerebras SDK; no physical WSE measurements',framework_base='3b8ebd80b0452e9245fb50601975aa11b48c81c5',
 sparse_branch='7413ed46fa0f572f4b46e7fd9b7056462a31a770',paper_base='bb7f61ad30873f64ebca758101f5e03d313c37d9',
 artifact_origin='Deterministically generated reference microbenchmarks; not API/model completions',sdk_simulator_revision='8faf87a26e4ea7ca1816636218fe53dd94e4b34a',
 local_root=str(root),portable_original_build_archive=dict(path=str(archive),sha256=sha(archive),bytes=archive.stat().st_size),
 local_evidence_sha256=trace_files,elf_sha256={r['id']:r['elf_sha256'] for r in analysis['results']},
 compact_sha256={str(p.relative_to(dest)):sha(p) for p in dest.rglob('*') if p.is_file() and p.name!='evidence-manifest.json'})
(root/'evidence-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
if root!=dest:shutil.copy2(root/'evidence-manifest.json',dest/'evidence-manifest.json')
print('Packaged',len(manifest['compact_sha256']),'compact files; original-build archive',archive.stat().st_size,'bytes')
