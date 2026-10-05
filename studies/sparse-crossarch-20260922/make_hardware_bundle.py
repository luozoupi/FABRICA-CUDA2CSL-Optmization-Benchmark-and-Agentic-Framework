"""Small transfer bundle: exact WSE builds/inputs plus tables and protocol."""
import hashlib,json,tarfile
from pathlib import Path
ROOT=Path(__file__).resolve().parent
selected=['README.md','HANDOFF.md','PROTOCOL.md','CAPACITY_AMENDMENT.md','ANALYSIS.md','RESULTS.md','wse-manifest.json','wse-summary.json','environment.json','compiler-comparison.json','wse-results.csv','gpu-results.csv','wse_host.py','index.html','results.json','partition-analysis.json','comparison-figure.pdf','comparison-figure.svg','audit.json']
target=ROOT/'wse-hardware-replay.tar.gz';files=[ROOT/f for f in selected]+[p for p in (ROOT/'wse').rglob('*')if p.is_file()]
with tarfile.open(target,'w:gz')as tar:
    for p in files:tar.add(p,arcname='sparse-crossarch-replay/'+str(p.relative_to(ROOT)),recursive=False)
manifest=dict(archive=target.name,sha256=hashlib.sha256(target.read_bytes()).hexdigest(),bytes=target.stat().st_size,scope='Exact WSE sources, ELF artifacts and input/output copies; human-readable tables and summarized GPU evidence. Large raw GPU validation outputs and profiler binary reports are not included.',files={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest()for p in files})
(ROOT/'hardware-bundle-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print(target.name,manifest['bytes'],'bytes',manifest['sha256'])
