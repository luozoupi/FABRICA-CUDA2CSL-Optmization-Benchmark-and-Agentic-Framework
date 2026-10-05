"""Bind final handoff to sources, frozen inputs, binaries and accepted observations."""
import hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
results=json.loads((ROOT/'results.json').read_text());pending=[b['id']for b in results['wse_builds']if b['status']=='pending']
if pending:raise RuntimeError('Refusing final handoff while WSE cells are pending: '+str(pending))
files={str(p.relative_to(ROOT)):sha(p)for p in ROOT.iterdir()if p.is_file()and p.name not in ('handoff-manifest.json',)and p.suffix in ('.py','.cu','.cuh','.md','.json','.csv','.html','.svg','.pdf')}
for p in (ROOT/'wse').glob('*/acceptance.json'):files[str(p.relative_to(ROOT))]=sha(p)
for directory in ('gpu','gpu-capacity','gpu-replay1','gpu-replay2'):
    for p in (ROOT/directory).glob('*/result.json'):files[str(p.relative_to(ROOT))]=sha(p)
for p in (ROOT/'inputs').glob('*manifest.json'):files[str(p.relative_to(ROOT))]=sha(p)
manifest=dict(schema=1,framework_local='c7ad437d80de5b3f077a15576cfbaca18112e657',framework_remote='b48041ef6787568ec66bf294efac2d001e8c6d83',paper_base='d1f9e720642fd030f0a7e1ec8334975ceeb4a99e',sdk_image='/home/USER/cs_sdk/sdk-cbcore-2.10.1-sdk-202606181328-8faf87a26e.sif',sdk_image_sha256='fff17e81c61dcb6012bdee2941a6fdc570f5c8604967530e7b7108651258193d',counts=results['counts'],wse_builds=results['wse_builds'],pending=[],running=[],sha256=files,gpu_binary_sha256=sha(ROOT/'gpu-bench'))
(ROOT/'handoff-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print('Final handoff:',results['counts'])
