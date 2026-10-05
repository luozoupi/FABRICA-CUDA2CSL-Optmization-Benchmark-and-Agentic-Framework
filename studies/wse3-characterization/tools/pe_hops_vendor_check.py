#!/usr/bin/env cs_python
"""Read existing CTF through the installed SDK and check the hop export exactly."""
import collections
import hashlib
import inspect
import json
from pathlib import Path
from cerebras.sdk import sdk_debug_wavelet_trace as sdk
from cerebras.sdk.debug.shell_lib.trace import SimfabWaveletTraceCtf
from cerebras.das_common.das_commonpybind import Coordinate

ROOT=Path(__file__).resolve().parents[1]
data=json.loads((ROOT/'results/pe-hops/hops.json').read_text())
checks=[]
for scene in data['scenes']:
    trace=SimfabWaveletTraceCtf(str(ROOT/scene['trace_dir']))
    checked=0
    for pe,placement in scene['placement'].items():
        x,y=placement['fabric']
        actual=[]
        for w in trace.get_wavelet_trace_per_colors_at(Coordinate(x,y),scene['colors'],'hex'):
            actual.append((w.cycle,w.color,w.link,bool(w.ctrl),int(w.wavelet_header_bits,16),int(w.wavelet_data_bits,16)))
        expected=[(w['cycle'],w['color'],w['link'],w['control'],w['index'],w['data']) for w in scene['wavelets'] if w['pe']==pe]
        assert collections.Counter(actual)==collections.Counter(expected),(scene['id'],pe,'SDK/raw mismatch')
        checked+=len(actual)
    for message in scene['messages']:
        for term in message['terms']:
            for w in term['packet']['observations']:
                assert float(sdk.format_wavelet_bits('f32',w['index'],w['data']))==term['value']
    checks.append(dict(scene=scene['id'],sdk_observations_checked=checked,all_exposed_fields_match=True,all_bound_f32_values_match=True))
    print(checks[-1],flush=True)
source_checks=manifest_checks=0
for name,expected in data['sources'].items():
    assert hashlib.sha256((ROOT/name).read_bytes()).hexdigest()==expected,('Source changed',name)
    source_checks+=1
for scene in data['scenes']:
    base=(ROOT/scene['source']).parent
    manifest=json.loads((base/'manifest.json').read_text())
    for name,expected in data['sources'].items():
        path=ROOT/name
        if path.is_relative_to(base):
            relative=str(path.relative_to(base))
            if relative in manifest['sha256']:
                assert expected==manifest['sha256'][relative],('Original capture hash mismatch',name)
                manifest_checks+=1
module=Path(inspect.getsourcefile(sdk))
result=dict(checks=checks,module=str(module),module_sha256=hashlib.sha256(module.read_bytes()).hexdigest(),
            sources_unchanged=source_checks,captured_manifest_hashes_matched=manifest_checks,
            export_sha256=hashlib.sha256((ROOT/'results/pe-hops/hops.json').read_bytes()).hexdigest(),
            note='Native SDK CTF reader and local JSONL matched cycle, color, link code, control bit, both 16-bit halves and multiplicity. The SDK CTF display API omits ident; packet identity is checked in raw JSONL only. SDK f32 formatting checked on every bound endpoint.')
(ROOT/'results/pe-hops/vendor_parity.json').write_text(json.dumps(result,indent=2)+'\n')
