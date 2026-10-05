"""Numeric teaching model of HC2022 weight streaming; NOT a device capture.

Reuse captured g1 operands, with W=B.T, so model output is directly checkable.
Steps serialize dependencies for explanation, not vendor scheduling or cycles.
"""
from copy import deepcopy

HC22 = 'https://hc34.hotchips.org/assets/program/conference/day2/Machine%20Learning/HC2022_Cerebras_Final_v02.pdf'
HC24 = 'https://hc2024.hotchips.org/assets/program/conference/day2/72_HC2024.Cerebras.Sean.v03.final.pdf'
BLOG = 'https://www.cerebras.ai/blog/cerebras-architecture-deep-dive-first-look-inside-the-hw-sw-co-design-for-deep-learning'


def build_weight_streaming(scene):
    X, B = [item['values'] for item in scene['host']['inputs']]
    assert len(X) == len(B) == 4 and all(len(r) == 4 for r in X+B)
    W = [list(col) for col in zip(*B)]
    pes = [dict(id=f'{x},{y}', x=x, y=y, samples=list(range(2*y, 2*y+2)),
                features=list(range(2*x, 2*x+2)), outputs=list(range(2*x, 2*x+2)),
                activation=[r[2*x:2*x+2] for r in X[2*y:2*y+2]])
           for y in range(2) for x in range(2)]
    partial = {pe['id']: [0, 0] for pe in pes}
    output = [[None]*4 for _ in range(4)]
    steps = []

    def emit(phase, title, description, **kw):
        steps.append(dict(phase=phase, title=title, description=description,
                          partial=deepcopy(partial), output=deepcopy(output),
                          cycle=None, calculations=[], flows=[], **kw))

    emit('overview', 'The same GEMM, a different placement',
         'Y = X × Wᵀ, with X = captured A and W = captured Bᵀ. '
         'Horizontal PE position partitions input features; vertical position partitions samples (batch × sequence).')
    emit('place', 'Keep activation slices in local SRAM',
         'Each PE receives a 2 × 2 activation slice. These values stay local throughout this layer. '
         'MemoryX retains the weight matrix outside the wafer. This placement is a teaching model, not a captured upload.')
    for o in range(4):
        partial = {pe['id']: [0, 0] for pe in pes}
        owner = o//2
        emit('reset', f'Output feature {o} · clear local partial vectors',
             'Each PE starts two partial sums, one per local sample. Output features are handled one at a time in this serialized lesson.', o=o, owner=owner)
        for k in range(4):
            w = W[o][k]
            if w == 0:
                emit('skip', f'W[{o},{k}] = 0 · no weight packet',
                     'A zero coefficient makes no contribution. The weight-streaming model omits its injection and AXPY.', o=o, k=k, weight=w, owner=owner)
                continue
            x = k//2
            flows = [dict(source='MemoryX', destination=f'{x},0', kind='weight', values=[w]),
                     dict(source=f'{x},0', destination=f'{x},1', kind='weight', values=[w])]
            emit('broadcast', f'W[{o},{k}] = {w} · broadcast along PE column {x}',
                 'The indexed scalar reaches both sample slices sharing input feature k. '
                 'It is a transient fabric operand; no full W array is allocated in these PEs. '
                 'Entry edge, packet order and queue details are illustrative.', o=o, k=k, weight=w, owner=owner)
            steps[-1]['flows'] = flows
            calculations = []
            for pe in pes:
                if pe['x'] != x:
                    continue
                old = partial[pe['id']][:]
                values = [X[b][k] for b in pe['samples']]
                products = [v*w for v in values]
                partial[pe['id']] = [a+b for a,b in zip(old,products)]
                calculations.append(dict(pe=pe['id'], samples=pe['samples'], activation=values,
                                         before=old, products=products, after=partial[pe['id']][:]))
            emit('axpy', f'Local AXPY · p[:,{o}] += X[:,{k}] × {w}',
                 'The weight index selects a resident activation column. Scalar × vector updates the local partial vector. '
                 'The vendor explanation places frequently accessed partial sums in a software-managed local cache.',
                 o=o, k=k, weight=w, owner=owner)
            steps[-1]['calculations'] = calculations
        emit('command', f'PSUM / FSUM · reduce feature {o}',
             f'PSUM initiates row reduction; FSUM selects a final-sum owner. This example assigns output features {2*owner}–{2*owner+1} to PE column {owner}. '
             'This contiguous owner policy is illustrative; the command encoding and schedule are not captured.', o=o, owner=owner)
        reduced = {}
        flows = []
        for y in range(2):
            dest, src = f'{owner},{y}', f'{1-owner},{y}'
            reduced[dest] = [a+b for a,b in zip(partial[dest],partial[src])]
            flows.append(dict(source=src, destination=dest, kind='partial', values=partial[src][:],
                              local=partial[dest][:], result=reduced[dest][:]))
        emit('reduce', f'Across PE rows · combine both K partitions',
             'The two-column example reduces to one peer transfer per row. A larger vendor mapping uses a row ring. '
             'Local partials remain displayed separately from the received and combined values.', o=o, owner=owner, reduced=reduced)
        steps[-1]['flows'] = flows
        for pe, values in reduced.items():
            y = int(pe.split(',')[1])
            for b, value in zip(range(2*y,2*y+2), values):
                output[b][o] = value
        emit('store', f'Y[:,{o}] · store on output-owning PEs',
             'Final values become an SRAM-resident activation slice for the next layer. '
             'A local partial sum is not a final output until the row reduction completes.', o=o, owner=owner, reduced=reduced)
    reference = [[sum(X[b][k]*W[o][k] for k in range(4)) for o in range(4)] for b in range(4)]
    assert output == reference == scene['host']['output']
    emit('complete', 'All output tiles verified',
         'PASS: every value equals both an independent matrix product and the retained g1 host output. '
         'Outputs stay on wafer for a following layer; host readback is an optional separate action.')
    return dict(schema='weight-streaming-lesson/1', evidence='documented-model', X=X, W=W,
                reference=reference, pes=pes, steps=steps,
                verification=dict(passed=True, compared_scene=scene['id'], output_cells=16,
                                  nonzero_weights=sum(v!=0 for row in W for v in row),
                                  modeled_products=4*sum(v!=0 for row in W for v in row)),
                sources=[dict(title='HC2022 · WSE-2 memory and streaming · pp. 9, 20–25', url=HC22+'#page=21'),
                         dict(title='Official explanation · local AXPY and row reduction', url=BLOG),
                         dict(title='HC2024 · WSE-3 core · p. 29; inference · p. 41', url=HC24+'#page=29')],
                limits=['This is a numerical illustration of a documented algorithm, not a newly executed WSE-3 kernel or a MemoryX trace.',
                        'Teaching steps are dependency boundaries, not cycles. Vendor overlap, physical ingress and exact cache contents are not observed.',
                        'HC2022 describes WSE-2 (256 B cache); HC2024 documents WSE-3 (512 B cache, 48 DSRs, 16 GPRs, eight 16-bit lanes).',
                        'No W array in SRAM does not mean no transient weight in a router, input queue or operand register.',
                        'The SUMMA and WaferLLM Cannon captures use different tensor placements and communication schedules.'])
