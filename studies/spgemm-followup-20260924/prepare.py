"""Freeze controlled masked-merge transformations before measuring candidates."""
import datetime,hashlib,json,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parent
SOURCE=Path('/home/USER/spgemm-trace-pilot-20260924/cases')
if (ROOT/'registration.json').exists():raise RuntimeError('Do not overwrite a frozen experiment')
variants=['baseline','cached_ends','separate_updates','cached_split','combined','nested']
selection=['banded','uniform','skewed']
final=['empty','diagonal','banded5','uniform5','blocks4','long_rows','random15','random45','dense']
reg=dict(created_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),framework_commit='196523eb1e25b832d9f6fa8a665838c042c751e3',
 sdk_revision='8faf87a26e4ea7ca1816636218fe53dd94e4b34a',application_pes=1,dimensions=[16,16,16],
 masked_variants=variants,selection_patterns=selection,final_patterns=final,sessions=['original','changed','restore'],warmups=1,repetitions=3,
 selection_rule='Among correct merge candidates including baseline, choose smallest geometric mean of original-session cycle ratios to baseline across the three selection patterns; break ties by declared variant order. Freeze choice before any final-test execution. Compare selected, baseline, and nested on final tests; no subsequent candidate revision.',
 hypotheses=['Hoisting end offsets may reduce repeated bounds/address loads.','Explicit control flow may prevent indirect stack updates for cursor selection.','Output tiling can bound general-SpGEMM scratch storage but repeats sparse traversal.'],
 general_variants=['full_row','tile4'],general_patterns=['empty','diagonal','banded','uniform','skewed','dense'],
 general_contract='FP32 arbitrary sparse A times sparse B, sorted CSR output retaining structural zeros; runtime capacity must return failure without out-of-bounds writes. Preallocated worst-case output capacity; no dynamic allocation phase.',
 trace_selection='Baseline and selected merge on uniform and banded, one timed launch each; retain any failed candidate. Trace selected general variants on uniform if needed to explain time.',
 boundary='Local SRAM-resident simulator experiments; no distributed communication, hardware latency, new model calls, or agent-study claims.')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
base=(SOURCE/'merge/pe.csl').read_text();host=(SOURCE/'merge/host.py').read_text()
start=host.index('def inputs(');end=host.index('def csr(',start);host=host[:start]+'from inputs import inputs\n\n'+host[end:]
# Poison output before each session, including structural presence, to audit initialization.
anchor='                samples=[]'
host=host.replace(anchor,"                put('C',np.full(m*n,123456.,np.float32));put('present',np.full(m*n,65535,np.uint32))\n"+anchor)
for name in variants:
 d=ROOT/'selection'/name;d.mkdir(parents=True)
 s=(SOURCE/'nested/pe.csl').read_text() if name=='nested' else base
 if name in ('cached_ends','cached_split','combined'):
  s=s.replace('var p: u16 = @as(u16, row_ptr[i]);','const p_end: u16 = @as(u16,row_ptr[i+1]);\nconst q_end: u16 = @as(u16,row_ptr[j+1]);\nvar p: u16 = @as(u16, row_ptr[i]);')
  s=s.replace('while (p < @as(u16,row_ptr[i+1]) and q < @as(u16,row_ptr[j+1])) {','while (p < p_end and q < q_end) {')
 if name in ('cached_split','combined'):
  s=s.replace('while (p < p_end and q < q_end) {','while (p < p_end) {\nif (q >= q_end) { break; }')
 if name in ('separate_updates','combined'):
  s=s.replace('p += 1; q += 1;\n} else if (ri < rj) { p += 1; } else { q += 1; }','p += 1; q += 1;\ncontinue;\n}\nif (ri < rj) { p += 1; continue; }\nq += 1;')
 (d/'pe.csl').write_text(s);shutil.copy2(SOURCE/'merge/layout.csl',d/'layout.csl');(d/'host.py').write_text(host);shutil.copy2(ROOT/'inputs.py',d/'inputs.py')
 cfg=json.loads((SOURCE/('nested' if name=='nested' else 'merge')/'case.json').read_text());cfg.update(id='masked-'+name,variant=name,patterns=selection,phase='selection')
 cfg['source_hashes']={f:sha(d/f) for f in ('pe.csl','layout.csl','host.py','inputs.py')}
 (d/'case.json').write_text(json.dumps(cfg,indent=2)+'\n')
reg['frozen_files_sha256']={str(p.relative_to(ROOT)):sha(p) for p in ROOT.rglob('*') if p.is_file() and p.suffix in ('.py','.csl','.json')}
(ROOT/'registration.json').write_text(json.dumps(reg,indent=2)+'\n')
print('Frozen',len(variants),'selection variants;',len(final),'untouched final families')
