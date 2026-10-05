#!/usr/bin/env cs_python
"""Independently compare readiness router records with the native SDK CTF reader."""
from collections import Counter
import hashlib
import inspect
import json
from pathlib import Path
from cerebras.sdk import sdk_debug_wavelet_trace as sdk
from cerebras.sdk.debug.shell_lib.trace import SimfabWaveletTraceCtf
from cerebras.das_common.das_commonpybind import Coordinate

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT/'results/readiness'
data = json.loads((OUT/'readiness.json').read_text())
checks = []
for case in data['cases']:
    trace = SimfabWaveletTraceCtf(str(ROOT/case['source']/'simfab_traces'))
    waves = [w for t in case['terms'] for w in t['packet']['observations']]
    for pe, p in case['placement'].items():
        actual = [(w.cycle, w.color, w.link, bool(w.ctrl), int(w.wavelet_header_bits,16), int(w.wavelet_data_bits,16))
                  for w in trace.get_wavelet_trace_per_colors_at(Coordinate(*p['fabric']),[6],'hex')]
        expected = [(w['cycle'],w['color'],w['link'],w['control'],w['index'],w['data']) for w in waves if w['pe']==pe]
        assert Counter(actual)==Counter(expected), (case['id'],pe,'SDK/raw mismatch')
    for term in case['terms']:
        for w in term['packet']['observations']:
            assert float(sdk.format_wavelet_bits('f32',w['index'],w['data']))==term['value']
    checks.append(dict(case=case['id'],observations=len(waves),exact_match=True))
module = Path(inspect.getsourcefile(sdk))
report = dict(checks=checks, observations=sum(c['observations'] for c in checks),
    export_sha256=hashlib.sha256((OUT/'readiness.json').read_bytes()).hexdigest(),
    module=str(module),module_sha256=hashlib.sha256(module.read_bytes()).hexdigest(),
    limit='The native display API omits packet identity; identities are verified separately against raw records. All exposed fields and multiplicities agree.')
(OUT/'vendor_parity.json').write_text(json.dumps(report,indent=2)+'\n')
print(len(checks),'captures;',report['observations'],'native SDK observations agree')
