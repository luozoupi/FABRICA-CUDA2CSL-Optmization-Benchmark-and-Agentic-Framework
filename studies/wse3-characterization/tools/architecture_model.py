#!/usr/bin/env python3
"""Estimate narrowly scoped PE costs from retained, audited simulator evidence.

This is a retrospective calibration/holdout exercise, not a new device run or
a validated whole-workload predictor. No target timing enters a prediction.
Raw S3/S6 anchors for the vector examples and GEMM figure are checked again.
"""
from collections import Counter, defaultdict
import gzip
import hashlib
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'results/architecture-review'


def load(path):
    return json.loads((ROOT / path).read_text())


def digest(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()


def focus(scene):
    return next(i for i in scene['instructions'] if i['uid'] == scene['focus_uid'])


def verify_anchors(scenes, source_hashes):
    wanted = defaultdict(dict)
    for scene in scenes:
        for ins in scene['instructions']:
            for stage, records in [(3, ins['decode']), (6, ins['execute'])]:
                for rec in records:
                    wanted[scene['source']][rec['row']] = (stage, ins, rec)
    count = 0
    for path, rows in wanted.items():
        assert digest(path) == source_hashes[path]['sha256'], f'Changed source: {path}'
        found = set()
        with gzip.open(ROOT / path, 'rt') as f:
            for n, line in enumerate(f, 1):
                if n not in rows:
                    continue
                stage, ins, rec = rows[n]
                e = json.loads(line)
                assert (e['stage'], e['tile_index'], e['uid'], e['cycle']) == (
                    stage, ins['tile'], ins['uid'], rec['cycle']), (path, n)
                if stage == 6:
                    for key in ['dest', 'src0', 'src1', 'src2']:
                        assert e[key] == rec[key], (path, n, key)
                found.add(n)
        assert found == set(rows), path
        count += len(found)
    return count


def vector_fit(scenes):
    a, b, held = [focus(scenes[k]) for k in ['add-8', 'add-16', 'add-64']]
    a_values = [v for v in a['execute'] if v['has_payload']]
    width = max(Counter(v['cycle'] for v in a_values).values())
    first = a['v_first'] - a['s3']
    groups = math.ceil(len([v for v in b['execute'] if v['has_payload']]) / width)
    interval = (b['v_last'] - b['v_first']) / (groups - 1)
    # The held-out workload has a declared extent of 64 in atomic_add/pe.csl.
    # Its trace count is a validation check, never a prediction input.
    n = 64
    pred = first + interval * (math.ceil(n / width) - 1)
    assert len([v for v in held['execute'] if v['has_payload']]) == n
    actual = held['v_last'] - held['s3']
    return dict(formula='S3_to_last_value = first + II * (ceil(elements / width) - 1)',
                scope='This contiguous memory-to-memory FADDH form only; excludes DSR setup and completion.',
                calibration=['add-8', 'add-16'], width=width, first=first, II=interval,
                held_out=dict(scene='add-64', elements=n, predicted=pred, measured=actual,
                              residual=actual-pred),
                optimistic_II1_prediction=first + math.ceil(n / width) - 1)


def hazard_fit(sweeps):
    out = []
    for name in ['dsr_s0last', 'dsr_s1last', 'dsr_dlast', 'f16chain_asm', 'mem', 'gpr']:
        rows = [r for r in sweeps[name]['rows'] if not r['prepared']]
        lo, hi = min(rows, key=lambda r: r['k']), max(rows, key=lambda r: r['k'])
        params = dict(dispatch_floor=hi['bubble'],
                      dispatch_extra=lo['bubble']-hi['bubble'],
                      value_floor=hi['dx_value'], value_extra=lo['dx_value']-hi['dx_value'])
        tests = []
        for r in rows:
            if r['k'] in (lo['k'], hi['k']):
                continue
            bubble = params['dispatch_floor'] + max(0, params['dispatch_extra']-r['k'])
            value = params['value_floor'] + max(0, params['value_extra']-r['k'])
            tests.append(dict(k=r['k'], predicted_bubble=bubble, measured_bubble=r['bubble'],
                              predicted_dx=value, measured_dx=r['dx_value'],
                              consumer_uid=r['consumer']['uid']))
        out.append(dict(name=name, source=sweeps[name]['source'], calibration_k=[lo['k'], hi['k']],
                        parameters=params, held_out=tests))
    return out


def network_fit(cases):
    calibration = [c for c in cases if c['group']=='try-20260916b' and
                   c['words'] in (1, 4) and c['receiver_nops']==0]
    assert len(calibration) == 2
    c4 = next(c for c in calibration if c['words']==4)
    II = c4['metrics']['source_span'] / 3
    hops = {i for c in calibration for i in c['metrics']['router_intervals']}
    assert len(hops) == 1
    hop = hops.pop()
    tests = []
    ids = {c['id'] for c in calibration}
    for c in cases:
        if c['id'] in ids:
            continue
        m = c['metrics']
        pred = (c['words']-1)*II
        tests.append(dict(id=c['id'], words=c['words'], receiver_nops=c['receiver_nops'],
                          actual_readiness_offset=m['readiness_offset'], predicted_source_span=pred,
                          measured_source_span=m['source_span'], residual=m['source_span']-pred,
                          predicted_router_interval=hop, measured_router_intervals=m['router_intervals']))
    return dict(scope='Adjacent static color-6 path. Predict source-router span, not end-to-end completion.',
                calibration=[c['id'] for c in calibration], II=II, router_interval=hop,
                held_out=tests, conclusion='No-blocking rule fails for delayed 16-word transfers; receiver service is required.')


def fixed_work_fit(rows):
    models = []
    for family in ['read', 'copy', 'write']:
        rs = [r for r in rows if r['family']==family and r['total_elems']==8192]
        a = next(r for r in rs if r['elems']==256)
        b = next(r for r in rs if r['elems']==1024)
        slope = (a['cycles']-b['cycles'])/(a['reps']-b['reps'])
        offset = a['cycles']-slope*a['reps']
        tests = [dict(name=r['name'], predicted=offset+slope*r['reps'], measured=r['cycles'],
                      residual=r['cycles']-(offset+slope*r['reps']),
                      relative_error=abs(r['cycles']-(offset+slope*r['reps']))/r['cycles'])
                 for r in rs if r['name'] not in (a['name'], b['name'])]
        models.append(dict(family=family, calibration=[a['name'], b['name']],
                           formula='cycles = fixed_work_intercept + per_repeat * reps',
                           fixed_work_intercept=offset, per_repeat=slope, held_out=tests))
    return dict(scope='8192 total f16 elements in suite A only; code generation varies with extent.',
                identifiability='The fixed-work intercept combines stream cost and window overhead; it cannot identify bandwidth separately.',
                models=models)


def gemv_path():
    hops = load('results/pe-hops/hops.json')
    scene = next(s for s in hops['scenes'] if s['id']=='v1')
    term = next(t for m in scene['messages'] for t in m['terms']
                if t['packet']['ident']=='14310831030273')
    assert digest(scene['source']) == hops['sources'][scene['source']]
    records = [(term[k], 'hwm_pipe_trace_entry') for k in ['send', 'receive', 'consumer']]
    records += [(r, 'wavelet_trace_entry') for r in term['packet']['observations']]
    wanted = {r['row']:(r,kind) for r,kind in records}
    found = set()
    with gzip.open(ROOT / scene['source'], 'rt') as f:
        for n,line in enumerate(f,1):
            if n not in wanted: continue
            r,kind = wanted[n]; e=json.loads(line)
            assert (e['event_type'],e['cycle']) == (kind,r['cycle'])
            if kind=='wavelet_trace_entry':
                assert str(e['ident']) == r['ident']
                assert (e['index'] << 16) | e['data'] == r['word']
            else:
                assert e['stage'] == 6
                for key in ['dest','src0','src1','src2','uid']:
                    if key in r: assert e[key]==r[key]
            found.add(n)
    assert found == set(wanted)
    return dict(source=scene['source'], term=term, raw_records_rechecked=len(found))


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    review = load('results/anatomy/datapath_review.json')
    scenes = {s['id']: s for s in review['scenes']}
    selected = [scenes[k] for k in ['add-8', 'add-16', 'add-64', 'g0-history']]
    anchors = verify_anchors(selected, review['sources'])
    # Reuse the independently audited sweeps; verify their exact capture identities.
    for key in ['dsr_s0last', 'dsr_s1last', 'dsr_dlast', 'f16chain_asm', 'mem', 'gpr']:
        path = review['sweeps'][key]['source']
        assert digest(path) == review['sources'][path]['sha256'], path
    data = dict(schema='wse3-estimated-model/1', evidence='simulator-derived estimates',
                validation='Retrospective split of previously inspected captures; not a blind experiment.',
                raw_anchors_rechecked=anchors, vector=vector_fit(scenes),
                hazards=hazard_fit(review['sweeps']),
                network=network_fit(load('results/readiness/readiness.json')['cases']),
                memory=fixed_work_fit(review['memory']['rows']), gemv_path=gemv_path())
    paths = ['results/anatomy/datapath_review.json', 'results/readiness/readiness.json',
             'results/runtime_model/summary.json', 'results/input-storage.json',
             'results/pe-hops/hops.json']
    data['input_sha256'] = {p:digest(p) for p in paths}
    data['gemm_timeline'] = scenes['g0-history']
    (OUT / 'estimates.json').write_text(json.dumps(data, indent=2) + '\n')
    hs = [r for h in data['hazards'] for r in h['held_out']]
    matches = sum(r['predicted_bubble']==r['measured_bubble'] and
                  r['predicted_dx']==r['measured_dx'] for r in hs)
    print(f'Rechecked {anchors} raw S3/S6 records. Conditional hazard matches: {matches}/{len(hs)}')
    print('Vector held out:',data['vector']['held_out'])
    for m in data['memory']['models']:
        print(m['family'], 'intercept',m['fixed_work_intercept'],'repeat',m['per_repeat'],m['held_out'])
    for c in data['network']['held_out']:
        if c['residual']: print('Network model failure:',c['id'],'residual',c['residual'])


if __name__ == '__main__':
    main()
