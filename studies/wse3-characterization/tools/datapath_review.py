#!/usr/bin/env python3
"""Re-audit retained GEMM, Add and memory traces; build an offline comparison.

No compilation or execution. Join by (capture, tile, uid), then PC to ELF
disassembly. Preserve every S3/S6 record and its 1-based decompressed JSONL row.
Only operand-bearing S6 records define value timing. A payload-free record is
not, by itself, evidence of a stall. No IF/MEM/WB timing is fabricated.
"""
from __future__ import annotations
import gzip
import hashlib
import json
import re
import statistics
import struct
from collections import Counter, defaultdict
from pathlib import Path

from anatomy_common import load_disasm, typed_for
from pe_model import resources

ROOT = Path(__file__).resolve().parent.parent
SENTINEL = 0xffffffff
FIELDS = ('dest', 'src0', 'src1', 'src2')


def read_json(path):
    return json.loads((ROOT / path).read_text())


def payload(record):
    return any(record.get(k) not in (None, SENTINEL) for k in FIELDS)


def trace(path, disassembly):
    """Read all instructions on selected tiles, including runtime and unknown PCs."""
    instructions = {}
    counts = Counter()
    discarded = 0
    with gzip.open(ROOT / path, 'rt') as fh:
        for line_number, line in enumerate(fh, 1):
            e = json.loads(line)
            counts[e['event_type']] += 1
            discarded = max(discarded, e.get('packet_context', {}).get('events_discarded', 0))
            if e.get('tile_index') not in disassembly or 'uid' not in e:
                continue
            key = (e['tile_index'], e['uid'])
            ins = instructions.setdefault(key, dict(tile=key[0], uid=key[1], dispatch=[], decode=[], execute=[]))
            rec = dict(cycle=e['cycle'], row=line_number)
            if e['event_type'] == 'hwm_dispatch_trace_entry':
                ins.update(pc=e['inst_ptr'], task=e['task_color'], ut=e['ut_id'], elements=e['num_data'], name=e['name'])
                ins['dispatch'].append(rec)
            elif e['event_type'] == 'hwm_pipe_trace_entry':
                if e['stage'] == 3:
                    ins['decode'].append(rec)
                elif e['stage'] == 6:
                    rec.update({k: e.get(k) for k in FIELDS})
                    rec.update(element=e.get('data'), lane=e.get('simdi'))
                    ins['execute'].append(rec)
    seq = []
    for ins in instructions.values():
        if not ins['dispatch']:
            continue
        ins.update(disassembly[ins['tile']].get(ins['pc'], dict(text=ins['name'].lower(), origin='unknown')))
        ins.update(resources(ins['text']))
        # Scalar fmov32 can address memory directly; it is not a stream op.
        if ins['text'].startswith('fmov32') and ins['unit'] != 'lanes':
            if any(k == 'sram' for k, _ in ins['reads']): ins['unit'] = 'load'
            if any(k == 'sram' for k, _ in ins['writes']): ins['unit'] = 'store'
        values = [v for v in ins['execute'] if payload(v)]
        ins['d'] = min(r['cycle'] for r in ins['dispatch'])
        ins['s3'] = min((r['cycle'] for r in ins['decode']), default=None)
        ins['v_first'] = min((r['cycle'] for r in values), default=None)
        ins['v_last'] = max((r['cycle'] for r in values), default=None)
        ins['dx_value'] = ins['v_first'] - ins['s3'] if values and ins['s3'] is not None else None
        for v in ins['execute']:
            v['has_payload'] = payload(v)
            v['display'] = {k: typed_for(ins['name'].lower(), v[k], k) for k in FIELDS}
        seq.append(ins)
    return sorted(seq, key=lambda i: (i['tile'], i['d'], i['uid'])), dict(counts=counts, max_discarded_counter=discarded)


def around(seq, selected, before=2, after=2):
    same = [i for i in seq if i['tile'] == selected['tile']]
    n = same.index(selected)
    return same[max(0, n-before):n+after+1]


def window(scenes, id, title, path, seq, focus, before=2, after=2, note=''):
    items = around(seq, focus, before, after)
    scenes.append(dict(id=id, title=title, source=path, focus_uid=focus['uid'], instructions=items, note=note))


def build():
    sources = set()
    scenes, audit, sweeps, gemms = [], {}, {}, []
    def load(base, placement=None):
        path = f'{base}/events.jsonl.gz'
        asm = {12: load_disasm(ROOT / base / 'disasm.json')} if placement is None else {
            p['tile']: load_disasm(ROOT / base / f'disasm_{pe.replace(",", "_")}.json') for pe, p in placement.items()}
        sources.add(path)
        sources.update(f'{base}/{f.name}' for f in (ROOT / base).glob('disasm*.json'))
        sources.add(f'{base}/pe.csl')
        seq, meta = trace(path, asm)
        audit[base] = meta
        print(f'Read {base}: {len(seq)} instructions', flush=True)
        return seq, path

    seq, path = load('microbench/atomic_add')
    app = [i for i in seq if i['origin'] == 'application' and i['d'] > 5000]
    add = next(i for i in app if i['text'].startswith('add16.nf r'))
    window(scenes, 'scalar-add', 'Scalar Add: load → add → store', path, seq, add, note='1234 + (−4321) = −3087. Functional transfers are selected by assembly operands; their physical wiring is unobserved.')
    av = next(v for v in add['execute'] if payload(v))
    assert av['dest'] & 0xffff == (-3087 & 0xffff)
    for op in (i for i in app if i['text'].startswith('faddh [dds')):
        window(scenes, f'add-{op["elements"]}', f'Vector Add: {op["elements"]} f16 elements', path, seq, op, 3, 1,
               'Descriptor loads carry control state. Element operands appear in the vector instruction’s S6 records. Lane groups do not establish the number of physical SRAM ports.')
    sources.add('microbench/atomic_add/results.json')
    assert all(r['verified'] for r in read_json('microbench/atomic_add/results.json')['rows'])

    seq, path = load('microbench/atomic_ops')
    app = [i for i in seq if i['origin'] == 'application' and i['d'] > 5000]
    copies = [i for i in app if i['text'].startswith('fmov16.nf [dds')]
    for op, name in zip(copies, ['Fill: scalar → eight destinations', 'Copy: eight contiguous elements', 'Copy: eight elements, stride 2'], strict=True):
        window(scenes, f'memory-{op["pc"]}', name, path, seq, op, 2, 1,
               'Values and element/lane records come from the trace. Address stride is established by CSL and descriptor setup; it is not encoded in the copy mnemonic.')
    sources.add('microbench/atomic_ops/results.json')
    assert all(r['ok'] for r in read_json('microbench/atomic_ops/results.json')['rows'])

    results = read_json('microbench/pcsweep/results.json')
    sources.add('microbench/pcsweep/results.json')
    pair_count = 0
    for cls, case in results.items():
        seq, path = load(f'microbench/pcsweep/cases/{cls}')
        by_d = defaultdict(list)
        for i in seq: by_d[i['d']].append(i)
        rows = []
        assert case['verify']['ok']
        for pair in case['pairs']:
            assert 'error' not in pair
            prod = next(i for i in by_d[pair['prod_disp']] if i['text'] == pair['producer'])
            cons = next(i for i in by_d[pair['cons_disp']] if i['text'] == pair['consumer'])
            # Recompute against raw events, not copied cached metrics.
            spacing = cons['d'] - prod['d']
            dx = cons['dx_value']
            assert spacing == pair['spacing']
            assert dx == pair['cons_dx_value'], (cls, pair['pair'], dx, pair['cons_dx_value'])
            between = [i for i in seq if i['tile'] == prod['tile'] and prod['d'] < i['d'] < cons['d']]
            nops = sum(i['text'].startswith('nop') for i in between)
            assert nops == pair['k_nop']
            bubble = spacing - len(between) - 1
            assert bubble == pair['dispatch_bubble']
            rows.append(dict(k=nops, prepared=pair['prepared'], spacing=spacing, bubble=bubble, dx_value=dx,
                             producer=dict(uid=prod['uid'], pc=prod['pc'], cycle=prod['d']),
                             consumer=dict(uid=cons['uid'], pc=cons['pc'], cycle=cons['d']),
                             taken=pair.get('taken')))
            pair_count += 1
            if cls in ('mem', 'gpr', 'dsr_s1last', 'f16chain_asm', 'i16chain_asm', 'reduce') and nops in (0, 1, 2, 3) and not pair['prepared']:
                window(scenes, f'{cls}-{nops}', f'{cls}: {nops} intervening nop(s)', path, seq, cons, len(between)+2, 4,
                       f'Controlled {cls} pair. Dispatch spacing {spacing}; S3 → first operand-bearing S6 {dx} cycles. '+
                       ('Markers checked; this assembly-chain class has no numerical output check.' if case['meta'].get('expect') == 'none' else 'Retained output and marker checks passed.'))
        sweeps[cls] = dict(source=path, rows=rows, verification=case['verify'])

    bundle = read_json('viewer/public/bundle.json')
    sources.add('viewer/public/bundle.json')
    for scene in bundle['scenes']:
        assert scene['verification']['passed'] and scene['control']['correct']
        info = dict(id=scene['id'], n=scene['n'], p=scene['p'], products=0, arithmetic_checks=0,
                    outputs=len(scene['cells']), history_cycles=[p['cycles'] for p in scene['pes']],
                    control_cycles=[p['cycles'] for p in scene['control']['pes']], modes={})
        for mode, base in [('history', scene['provenance']['run']), ('control', scene['control']['run'])]:
            placement = read_json(f'{base}/placement.json')
            sources.add(f'{base}/placement.json')
            seq, path = load(base, placement)
            by_uid = {(i['tile'], i['uid']): i for i in seq}
            app_fp = [i for i in seq if i['origin'] == 'application' and i['name'] in ('FMULS', 'FADDS')]
            info['modes'][mode] = {name: dict(count=sum(i['name'] == name for i in app_fp),
                dx_value=dict(Counter(i['dx_value'] for i in app_fp if i['name'] == name))) for name in ('FMULS', 'FADDS')}
            if mode == 'history':
                for cell in scene['cells']:
                    for term in cell['terms']:
                        for id, expected in zip(term['arithmetic_ids'], [(term['product'], term['a'], term['b']), (term['acc'], term['old'], term['product'])], strict=True):
                            item = scene['dynamic'][id]
                            raw = by_uid[(placement[item['pe']]['tile'], item['uid'])]
                            values = [v for v in raw['execute'] if payload(v)]
                            assert len(values) == 1
                            v = values[0]
                            bits = tuple(struct.unpack('<I', struct.pack('<f', float(x)))[0] for x in expected)
                            assert tuple(v[k] for k in ('dest', 'src0', 'src1')) == bits
                            assert raw['pc'] == item['pc']
                            info['arithmetic_checks'] += 1
                        info['products'] += 1
                first = scene['cells'][0]['terms'][0]
                d = scene['dynamic'][first['arithmetic_ids'][1]]
                focus = by_uid[(placement[d['pe']]['tile'], d['uid'])]
            else:
                focus = next(i for i in app_fp if i['name'] == 'FADDS')
            window(scenes, f'{scene["id"]}-{mode}', f'{scene["id"].upper()} {scene["n"]}×{scene["n"]} GEMM / {mode}', path, seq, focus, 7, 4,
                   'Scalar f32 optnone teaching build. The visible stack stores/reloads and older work can delay later records. Do not transfer the f16 sweep’s latency to this f32 instruction. '+
                   ('All products independently rematched to raw operand/result bits.' if mode == 'history' else 'History-free control with retained passing output check; individual values are not bound to tensor indices here.'))
        gemms.append(info)

    sources.update(['microbench/singlepe/A/results.json', 'microbench/singlepe/A/pe.csl', 'microbench/bank/bank_results.json'])
    memory = read_json('microbench/singlepe/A/results.json')
    assert memory['verification']['pass']
    # Compare accepted, non-warmup silicon trials; keep exact ledger row references.
    ledger_path = 'results/wse3-full/ledger.jsonl'
    sources.add(ledger_path)
    bank = defaultdict(list)
    with (ROOT / ledger_path).open() as fh:
        for n, line in enumerate(fh, 1):
            if 'single-pe-bank-stride' not in line: continue
            e = json.loads(line)
            if not e.get('accepted') or e.get('warmup') or e.get('arm') != 'hardware': continue
            r = e['result']
            assert r['correctness']
            bank[r['case_id']].append(dict(cycles=r['elapsed_cycles'], row=n))
    silicon = {k:dict(trials=len(v), median=statistics.median(r['cycles'] for r in v), rows=[r['row'] for r in v]) for k,v in sorted(bank.items())}
    output = dict(schema='wse3-datapath-review/1', scope='Retained simulator captures; silicon timings only in bank_ledger',
        scenes=scenes, sweeps=sweeps, gemm=gemms, memory=memory,
        bank_simulator=read_json('microbench/bank/bank_results.json'), bank_ledger=silicon,
        audit=dict(captures=audit, sweep_pairs=pair_count, gemm_products=sum(g['products'] for g in gemms),
                   gemm_arithmetic_checks=sum(g['arithmetic_checks'] for g in gemms)),
        sources={p:dict(bytes=(ROOT/p).stat().st_size, sha256=hashlib.sha256((ROOT/p).read_bytes()).hexdigest()) for p in sorted(sources)},
        documentation=['https://sdk.cerebras.ai/csl/language/dsrs', 'https://sdk.cerebras.ai/csl/language/dsds'])
    out = ROOT/'results/anatomy'
    out.mkdir(parents=True, exist_ok=True)
    (out/'datapath_review.json').write_text(json.dumps(output, indent=2)+'\n')
    template = (ROOT/'tools/datapath_review.html.tpl').read_text()
    (out/'datapath_review.html').write_text(template.replace('__DATA__', json.dumps(output).replace('<', '\\u003c')))
    print(json.dumps(dict(scenes=len(scenes), pairs=pair_count, gemm=gemms, bank=silicon), indent=2))


if __name__ == '__main__':
    build()
