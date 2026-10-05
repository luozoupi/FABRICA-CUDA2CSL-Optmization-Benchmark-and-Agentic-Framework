#!/usr/bin/env python3
"""Audit and present the controlled two-PE readiness simulator captures."""
from __future__ import annotations
import argparse
from collections import defaultdict
import gzip
import hashlib
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from pe_hops import read_capture, packets_for, messages_for, copy_candidates, f32, bits
from wse3study.gemv_viz import function_ranges
from wse3study.inventory import _Elf64


def require(condition, message):
    if not condition:
        raise ValueError(message)


def is_nop(instruction):
    return instruction in ('nop', 'nop 0x0')


def sha(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as f:
        for block in iter(lambda: f.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()


def check_values(result):
    spec = result['case']; n = spec['words']
    payload, local = result['payload_bits'], result['local_bits']
    require(len(payload) == len(local) == n, 'Input length mismatch')
    expected = [bits(f32(a) + f32(b)) for a, b in zip(payload, local)]
    obs = result['observed']
    require(result['correct'] and obs['buf_0'] == obs['buf_1'] == payload
            and obs['loc_1'] == local and obs['res_1'] == result['expected_bits'] == expected,
            'Exact readback/reference mismatch')
    require(len(set(payload)) == n and all(v & 65535 for v in payload),
            'Sentinels must be unique and have nonzero low halves')


def compact_event(e, **extra):
    return {k: e[k] for k in ('cycle', 'row')} | extra


def build_case(work):
    work = Path(work).resolve()
    manifest = json.loads((work/'manifest.json').read_text())
    spec = json.loads((work/'case.json').read_text())
    result = json.loads((work/'result.json').read_text())
    placement = json.loads((work/'placement.json').read_text())
    require(manifest['case'] == spec == result['case'], 'Case identity mismatch')
    hashes = {}
    for name, expected in manifest['sha256'].items():
        path = work/name
        require(sha(path) == expected, f'Capture hash changed: {path}')
        hashes[str(path.relative_to(ROOT))] = expected
    for name, expected in manifest['ir_sha256'].items():
        require(sha(ROOT/name) == expected, f'Original IR/ELF changed: {name}')
        hashes[name] = expected
    hashes[str((work/'manifest.json').relative_to(ROOT))] = sha(work/'manifest.json')
    check_values(result)
    ranges, asm, executed_ir = {}, {}, {}
    for pe, p in placement.items():
        elf = work/p['elf']
        require(_Elf64(elf).program_tile_ids() == [p['tile']], 'ELF placement mismatch')
        require([p['tile'] % 9, p['tile'] // 9] == p['fabric'], 'Coordinate mismatch')
        ranges[pe] = function_ranges(elf)
        require('run' in ranges[pe], 'Missing run function in ELF')
        asm[pe] = json.loads((work/p['disasm']).read_text())['records']
        # Rebuild directories retain the final optnone IR and the exact linked ELF.
        cap = ROOT/manifest['base']/'ir'/('out_' + Path(p['elf']).stem)
        candidates = [p.parent/'program.ll' for p in cap.glob('cslc_ir_*/program.elf')
                      if sha(p) == sha(elf)]
        require(bool(candidates), 'No retained rebuilt IR matches the executed ELF')
        require(len({p.read_text() for p in candidates}) == 1, 'Ambiguous executed IR')
        ir = candidates[0]
        executed_ir[pe] = str(ir.relative_to(ROOT)); hashes[executed_ir[pe]] = sha(ir)
    require(sha(work/placement['0,0']['elf']) == manifest['sender_sha256'], 'Sender ELF mismatch')
    sim = json.loads((work/'simfab_traces/global_simdata.json').read_text())
    require(int(sim['xsize']) == 9, 'Unexpected trace fabric width')

    waves, instructions = read_capture(work, placement, [6])
    packets, unresolved = packets_for(waves)
    require(not unresolved and len(packets) == spec['words'], 'Incomplete or ambiguous packet observations')
    messages = messages_for(packets)
    require(len(messages) == 1, 'Expected one fixed-extent message')
    message = messages[0]
    require(message['source'] == '0,0' and message['destination'] == '1,0'
            and message['control'] is None, 'Unexpected route/control packet')
    packets = message['packets']
    require([p['word'] for p in packets] == result['payload_bits'], 'Packet order/payload mismatch')
    transfers = {}
    for side, pe in [('send', '0,0'), ('receive', '1,0')]:
        lo, hi = ranges[pe]['run']
        # Host upload has the same words: restrict to the application run function.
        candidates = [i for i in copy_candidates(instructions, message, side) if lo <= i['pc'] < hi]
        require(len(candidates) == 1, f'{side}: ambiguous instruction binding')
        instruction = candidates[0]
        instruction['execute'].sort(key=lambda e: (e['index'], e['lane']))
        transfers[side] = instruction
    arithmetic = [i for i in instructions if i['pe'] == '1,0' and i['name'] == 'FADDS'
                  and i['count'] == spec['words'] and (i['source_file'] or '').endswith('/pe.csl')]
    require(len(arithmetic) == 1, 'Expected one receiver vector addition')
    add = arithmetic[0]; add['execute'].sort(key=lambda e: (e['index'], e['lane']))
    require([e['index'] for e in add['execute']] == list(range(spec['words'])), 'Incomplete arithmetic lanes')

    # Check both the static NOP prefix and its actual dynamic execution.
    run_asm, nop_pcs, run_dispatch = {}, {}, defaultdict(list)
    for pe in placement:
        lo, hi = ranges[pe]['run']
        rows = sorted((r for r in asm[pe] if lo <= r['pc'] < hi), key=lambda r: r['pc'])
        nop_pcs[pe] = [r['pc'] for r in rows if is_nop(r['instruction'])]
        run_asm[pe] = rows
        count = spec['sender_nops'] if pe == '0,0' else spec['receiver_nops']
        require(len(nop_pcs[pe]) == count, f'{pe}: static NOP count differs from treatment')
        require(all(is_nop(r['instruction']) for r in rows[:count]), 'Delay is not a run prefix')
    tile_to_pe = {p['tile']: pe for pe, p in placement.items()}
    with gzip.open(work/'events.jsonl.gz', 'rt') as fh:
        for row, line in enumerate(fh, 1):
            e = json.loads(line); pe = tile_to_pe.get(e.get('tile_index'))
            if pe is None or e['event_type'] != 'hwm_dispatch_trace_entry':
                continue
            lo, hi = ranges[pe]['run']
            if lo <= e['inst_ptr'] < hi:
                run_dispatch[pe].append(dict(cycle=e['cycle'], row=row, pc=e['inst_ptr'], uid=e['uid']))
    delay_checks = {}
    for pe in placement:
        observed = [e for e in run_dispatch[pe] if e['pc'] in nop_pcs[pe]]
        require([e['pc'] for e in observed] == nop_pcs[pe], 'Missing/repeated/out-of-order NOP dispatch')
        delay_checks[pe] = dict(static_nops=len(nop_pcs[pe]), dynamic_nops=len(observed),
            first_cycle=observed[0]['cycle'] if observed else None,
            last_cycle=observed[-1]['cycle'] if observed else None,
            run_entry=run_dispatch[pe][0], dispatches=observed,
            consecutive=all(b['cycle']-a['cycle'] == 1 for a, b in zip(observed, observed[1:])))
    terms = []
    for slot, (packet, send, receive, operation) in enumerate(zip(packets,
            transfers['send']['execute'], transfers['receive']['execute'], add['execute'])):
        word, local, output = result['payload_bits'][slot], result['local_bits'][slot], result['expected_bits'][slot]
        require(sorted([operation['src0'], operation['src1']]) == sorted([word, local])
                and operation['dest'] == output, 'Arithmetic operand/result mismatch')
        events = [compact_event(send, kind='send', label='Send S6', pe='0,0'),
                  compact_event(packet['observations'][0], kind='source', label='Source router', pe='0,0'),
                  compact_event(packet['observations'][1], kind='destination', label='Destination router', pe='1,0'),
                  compact_event(receive, kind='receive', label='Receive S6', pe='1,0'),
                  compact_event(operation, kind='use', label='Add S6', pe='1,0')]
        require(all(b['cycle'] >= a['cycle'] for a, b in zip(events, events[1:])), 'Value lineage violates observed time')
        intervals = [b['cycle']-a['cycle'] for a, b in zip(events, events[1:])]
        terms.append(dict(slot=slot, bits=word, value=f32(word), local=f32(local), output=f32(output),
            local_bits=local, output_bits=output, packet=packet, events=events, intervals=intervals))
    send_cycle = transfers['send']['dispatch'][0]['cycle']
    receive_cycle = transfers['receive']['dispatch'][0]['cycle']
    metrics = dict(send_dispatch=send_cycle, receive_dispatch=receive_cycle,
        readiness_offset=receive_cycle-send_cycle,
        source_first=min(t['events'][1]['cycle'] for t in terms),
        source_last=max(t['events'][1]['cycle'] for t in terms),
        destination_first=min(t['events'][2]['cycle'] for t in terms),
        destination_last=max(t['events'][2]['cycle'] for t in terms),
        receive_first=min(t['events'][3]['cycle'] for t in terms),
        receive_last=max(t['events'][3]['cycle'] for t in terms),
        use_first=min(t['events'][4]['cycle'] for t in terms),
        use_last=max(t['events'][4]['cycle'] for t in terms),
        router_intervals=[t['intervals'][1] for t in terms],
        landing_to_receive=[t['intervals'][2] for t in terms])
    metrics['send_to_last_use'] = metrics['use_last']-send_cycle
    metrics['source_span'] = metrics['source_last']-metrics['source_first']
    return dict(spec, id=work.parent.name+'/'+work.name, group=work.parent.name,
        case_id=spec['id'], source=str(work.relative_to(ROOT)), placement=placement,
        transfers=transfers, arithmetic=add, terms=terms, metrics=metrics, delay_checks=delay_checks,
        run_assembly=run_asm, executed_ir=executed_ir, sender_sha256=manifest['sender_sha256'],
        verification=dict(exact_readbacks=True, bound_words=len(terms), discarded_events=0,
                          manifest_files=len(hashes)), hashes=hashes)


def compare(cases):
    groups = defaultdict(list)
    for case in cases:
        groups[case['group'], case['words']].append(case)
    comparisons, repeats = [], []
    for (group, n), rows in groups.items():
        require(len({r['sender_sha256'] for r in rows}) == 1, 'Sender changed within delay comparison')
        require(len({tuple(t['bits'] for t in r['terms']) for r in rows}) == 1, 'Payload changed within comparison')
        bodies = {tuple(i['instruction'] for i in r['run_assembly']['1,0'] if not is_nop(i['instruction'])) for r in rows}
        require(len(bodies) == 1, 'Receiver run body changed beyond NOP prefix')
        baselines = [r for r in rows if r['receiver_nops'] == 0]
        require(bool(baselines), 'Comparison needs an undelayed baseline')
        base = baselines[0]
        for r in rows:
            r['id'] = r['group']+'/'+r['case_id']
            r['baseline'] = base['group']+'/'+base['case_id']
            r['delta'] = {k: r['metrics'][k]-base['metrics'][k]
                for k in ('send_dispatch', 'receive_dispatch', 'source_first', 'source_last',
                          'receive_first', 'receive_last', 'use_last', 'send_to_last_use')}
            comparisons.append(dict(case=r['id'], baseline=r['baseline'], words=n,
                                    receiver_nops=r['receiver_nops'], delta=r['delta']))
        by_delay = defaultdict(list)
        for r in rows:
            by_delay[r['receiver_nops']].append(r)
        for d, rs in by_delay.items():
            if len(rs) > 1:
                signatures = [json.dumps(dict(metrics=r['metrics'], terms=[
                    dict(bits=t['bits'], events=[e['cycle'] for e in t['events']]) for t in r['terms']]), sort_keys=True) for r in rs]
                repeats.append(dict(group=group, words=n, receiver_nops=d, count=len(rs),
                                    timing_and_values_identical=len(set(signatures)) == 1))
    return comparisons, repeats


def export(roots, out):
    cases = [build_case(p.parent) for root in roots for p in sorted(root.glob('b*-d*-r*/manifest.json'))]
    require(bool(cases), 'No completed readiness captures')
    cases.sort(key=lambda c: (c['words'], c['group'], c['receiver_nops'], c['repeat']))
    comparisons, repeats = compare(cases)
    data = dict(schema='readiness-view/1', evidence='simulator', cases=cases,
        comparisons=comparisons, repeats=repeats,
        limits=['Router interval is between recorded observations, not isolated physical link latency.',
                'Receive S6 is operand evidence, not a measured SRAM commit time.',
                'Arrivals before receive do not establish queue depth or queue occupancy.',
                'The sender has a fixed 64-NOP prefix in this pilot; actual receive-minus-send dispatch is reported.',
                'These are scalar-control/DSD simulator experiments, not silicon performance measurements.'])
    out.mkdir(parents=True, exist_ok=True)
    (out/'readiness.json').write_text(json.dumps(data, indent=2)+'\n')
    packed = json.dumps(data, separators=(',', ':')).replace('<', '\\u003c')
    template = Path(__file__).with_suffix('.html.tpl').read_text()
    (out/'readiness.html').write_text(template.replace('__READINESS_DATA__', packed))
    print(json.dumps(dict(cases=len(cases), words=sum(len(c['terms']) for c in cases),
                         comparisons=len(comparisons), repeats=repeats, out=str(out)), indent=2))
    return data


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('roots', nargs='+', type=Path)
    ap.add_argument('--out', type=Path, default=ROOT/'results/readiness')
    a = ap.parse_args()
    export([r.resolve() for r in a.roots], a.out.resolve())


if __name__ == '__main__':
    main()
