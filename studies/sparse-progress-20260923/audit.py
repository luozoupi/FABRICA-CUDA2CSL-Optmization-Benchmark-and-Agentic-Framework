#!/usr/bin/env python3
"""Audit pinned remote/paper summaries and local progress without device or API calls."""
import argparse
import csv
import hashlib
import itertools
import json
import math
from pathlib import Path
import re
import statistics

ROOT = Path(__file__).resolve().parent


def require(condition, message):
    if not condition:
        raise ValueError(message)


def keyed(rows, fields):
    result = {}
    for row in rows:
        key = tuple(str(row[f]) for f in fields)
        require(key not in result, f'Duplicate observation: {key}')
        result[key] = row
    return result


def same_rows(left, right, keys, fields):
    a, b = keyed(left, keys), keyed(right, keys)
    require(a.keys() == b.keys(), f'Observation coverage differs for {keys}')
    for key in a:
        for field in fields:
            require(str(a[key][field]) == str(b[key][field]), f'Data mismatch: {key}, {field}')


def geomean(values):
    require(bool(values) and all(v > 0 for v in values), 'Geomean needs positive observations')
    return math.exp(statistics.mean(math.log(v) for v in values))


def rank_agreement(pairs):
    """Report tie-aware Kendall tau-b and the paper's current untied-pair statistic."""
    counts = dict(concordant=0, discordant=0, tied_sim_only=0, tied_hw_only=0, tied_both=0)
    for (x1, y1), (x2, y2) in itertools.combinations(pairs, 2):
        dx, dy = x1 - x2, y1 - y2
        field = ('tied_both' if dx == dy == 0 else 'tied_sim_only' if dx == 0 else
                 'tied_hw_only' if dy == 0 else 'concordant' if dx * dy > 0 else 'discordant')
        counts[field] += 1
    c, d = counts['concordant'], counts['discordant']
    denominator = math.sqrt((c + d + counts['tied_sim_only']) * (c + d + counts['tied_hw_only']))
    return dict(**counts, tau_b=(c - d) / denominator if denominator else None,
                untied_pair_ratio=(c - d) / (c + d) if c + d else None)


def trial_coverage(rows):
    full, partial, passed, attempted = 0, [], 0, 0
    for row in rows:
        match = re.fullmatch(r'(\d+)/(\d+)(?: repeats passed)?', str(row['hw_repeats_passed']))
        require(match is not None, 'Unknown hardware trial count')
        p, n = map(int, match.groups())
        require(0 <= p <= n and n > 0, 'Invalid hardware trial count')
        passed += p
        attempted += n
        if p == n and row['hw_status'] == 'pass':
            full += 1
        else:
            partial.append({k: row[k] for k in ('kernel', 'series', 'seed', 'hw_status', 'hw_repeats_passed')})
    return dict(full_success_records=full, incomplete_records=partial,
                reported_passing_trials=passed, reported_trials=attempted)


def audit(root=ROOT):
    manifest = json.loads((root / 'evidence-manifest.json').read_text())
    for name, record in manifest['files'].items():
        data = (root / 'evidence' / name).read_bytes()
        require(hashlib.sha256(data).hexdigest() == record['sha256'], 'Evidence changed: ' + name)

    def read_json(name):
        return json.loads((root / 'evidence' / name).read_text())

    def read_csv(name):
        with (root / 'evidence' / name).open(newline='') as f:
            return list(csv.DictReader(f))

    runs = read_csv('online/runs.csv')
    paper_runs = read_csv('paper/ipdps_sparse_optimizer_runs.csv')
    same_rows(runs, paper_runs, ('kernel', 'arm', 'seed'), tuple(runs[0]))
    cells = keyed(runs, ('kernel', 'arm', 'seed'))
    tasks = sorted({r['kernel'] for r in runs})
    arms = sorted({r['arm'] for r in runs})
    seeds = sorted({r['seed'] for r in runs})
    require(set(cells) == set(itertools.product(tasks, arms, seeds)), 'Incomplete optimizer design')
    medians = {}
    for task, arm in itertools.product(tasks, arms):
        group = [r for r in runs if r['kernel'] == task and r['arm'] == arm]
        kept = [r for r in group if r['retained_pass'] == 'True' and r['final_cycles']]
        medians[(task, arm)] = statistics.median(float(r['final_cycles']) for r in kept)
    arm_ratios = {label: geomean([medians[(t, base)] / medians[(t, treatment)] for t in tasks])
                  for label, base, treatment in [('O1_over_O0', 'O0', 'O1'), ('O1I_over_O1', 'O1', 'O1I')]}
    candidates = read_csv('online/candidates.csv')
    keyed(candidates, ('kernel', 'arm', 'seed', 'attempt'))
    for row in candidates:
        require(tuple(row[k] for k in ('kernel', 'arm', 'seed')) in cells, 'Orphan candidate')
    for key, row in cells.items():
        selected = [c for c in candidates if tuple(c[k] for k in ('kernel', 'arm', 'seed')) == key]
        require(len(selected) == int(row['n_candidates']), 'Candidate count mismatch: ' + str(key))

    hardware = read_json('online/hw_s2_retained_20260922.json')
    same_rows(hardware, read_csv('paper/ipdps_sparse_hw_retained.csv'),
              ('kernel', 'series', 'seed'), tuple(hardware[0]))
    hw_keys = set(keyed(hardware, ('kernel', 'series', 'seed')))
    expected_hw = set(cells) | {(t, 'FC', '1') for t in tasks}
    require(hw_keys <= expected_hw, 'Unexpected hardware cell')
    missing_hw = [dict(zip(('kernel', 'arm', 'seed'), key)) for key in sorted(expected_hw - hw_keys)]
    ratios = []
    for row in hardware:
        if row['series'] != 'FC':
            run = cells[(row['kernel'], row['series'], str(row['seed']))]
            require(int(run['final_cycles']) == row['sweep_sim_cycles'], 'Hardware/sweep identity mismatch')
        require(row['appliance_sim_cycles'] == row['sweep_sim_cycles'], 'Simulator paths differ')
        ratio = row['hw_cycles'] / row['appliance_sim_cycles']
        require(abs(ratio - row['hw_over_sim']) <= 0.000051, 'Rounded hardware ratio mismatch')
        ratios.append(ratio)
    ranking = {t: rank_agreement([(r['appliance_sim_cycles'], r['hw_cycles']) for r in hardware
                                 if r['kernel'] == t]) for t in tasks}

    transfer = read_json('online/transfer_20260922.json')['rows']
    keyed(transfer, ('kernel', 'series', 'seed', 'eval_seed'))
    fc = {(r['kernel'], r['eval_seed']): r for r in transfer if r['series'] == 'FC'}
    normalized = []
    for row in transfer:
        if row['series'] == 'FC':
            continue
        baseline = fc[(row['kernel'], row['eval_seed'])]
        run = cells[(row['kernel'], row['series'], str(row['seed']))]
        require(row['train_cycles'] == int(run['final_cycles']), 'Transfer source/sweep timing mismatch')
        require(row['matrix'] == baseline['matrix'], 'Transfer/FC matrix mismatch')
        normalized.append(dict(kernel=row['kernel'], arm=row['series'], seed=row['seed'],
                               train_matrix=row['train_matrix'], eval_matrix=row['matrix'],
                               status=row['status'], cycles=row['cycles'], fc_cycles=baseline['cycles'], nnz=row['nnz']))
    paper_transfer = read_csv('paper/ipdps_sparse_transfer.csv')
    same_rows(normalized, paper_transfer, ('kernel', 'arm', 'seed', 'eval_matrix'), tuple(normalized[0]))
    require(len(normalized) == len(runs) * 3, 'Missing transfer observations')
    transfer_summary = {}
    for task in tasks:
        rows = [r for r in normalized if r['kernel'] == task]
        transfer_summary[task] = dict(rows=len(rows), passed=sum(r['status'] == 'pass' for r in rows),
            speedup=geomean([r['fc_cycles'] / r['cycles'] for r in rows if r['status'] == 'pass']),
            per_arm={a: dict(rows=sum(r['arm'] == a for r in rows),
                            beats_fc=sum(r['arm'] == a and r['status'] == 'pass' and r['cycles'] < r['fc_cycles'] for r in rows)) for a in arms})

    macros = dict(re.findall(r'^\\newcommand\{\\(\w+)\}\{(.+)\}(?:\s*%.*)?$',
                            (root / 'evidence/paper/numbers.tex').read_text(), re.M))
    expected_macros = {'optGeomeanOOneOverOZero': f"{arm_ratios['O1_over_O0']:.3f}",
                       'optGeomeanOOneIOverOOne': f"{arm_ratios['O1I_over_O1']:.3f}",
                       'hwRetainedPrograms': str(len(hardware)), 'hwRetainedRatioMin': f'{min(ratios):.3f}',
                       'hwRetainedRatioMax': f'{max(ratios):.3f}', 'hwRetainedRatioGeomean': f'{geomean(ratios):.3f}',
                       'trRows': str(len(normalized)), 'trPassed': str(sum(r['status'] == 'pass' for r in normalized))}
    for task, short in [('SpGEMM-Masked-Dot', 'Spgemm'), ('SpMM-CSR-Dense', 'Spmm'), ('SpMV-RowBlock', 'Spmv')]:
        expected_macros['tr' + short + 'Heldout'] = f"{transfer_summary[task]['speedup']:.2f}"
    for key, expected in expected_macros.items():
        require(macros.get(key) == expected, 'Paper macro mismatch: ' + key)

    scaling = read_json('local/scaling.json')
    keyed(scaling, ('kind', 'kernel', 'application_pes'))
    for row in scaling:
        if row['status'] == 'pass':
            require(row['success_marker'] and row['heldout_passed'] and len(row['samples']) == 3,
                    'Incomplete accepted scaling record')
            require(row['cycles'] == statistics.median(row['samples']), 'Scaling timing mismatch')
            require(len(row['heldout_seed_echoes']) == 3 and all(s['seed'] == s['echo'] for s in row['heldout_seed_echoes']),
                    'Scaling held-out input mismatch')
    smoke = read_csv('local/deepseek-smoke.csv')
    training = read_json('local/training-export-summary.json')
    require(all(training['hash_checks'].values()), 'Training export hash failure')
    return dict(schema=1, status='summary_consistency_pass', revisions=manifest['revisions'],
                evidence_level=manifest['evidence_level'], checked_paper_macros=expected_macros,
                optimizer=dict(cells=len(runs), retained=sum(r['retained_pass'] == 'True' for r in runs),
                    candidate_records=len(candidates), attempts_used=sorted({int(r['attempts_used']) for r in runs}),
                    arm_speedup_ratios=arm_ratios,
                    medians=[dict(kernel=k, arm=a, cycles=v) for (k, a), v in medians.items()]),
                hardware=dict(records=len(hardware), expected_records=len(expected_hw), missing=missing_hw,
                    coverage=trial_coverage(hardware), ratio_min=min(ratios), ratio_max=max(ratios),
                    ratio_geomean=geomean(ratios), rankings=ranking,
                    identity_limit='Tables have no source/ELF hashes or raw per-trial records; arithmetic joins are not independent artifact replay.'),
                transfer=dict(retained_rows=len(normalized), baseline_rows=len(fc), tasks=transfer_summary,
                    split_scope='These are the matrices used by the retained-pass acceptance gate, not untouched final-test matrices.'),
                local=dict(scaling_rows=len(scaling), scaling_passed=sum(r['status'] == 'pass' for r in scaling),
                    scaling_timing_admission='Provisional simulator cross-PE timestamp spans; clock alignment not audited. No hardware latency or scaling efficiency admitted.',
                    deepseek_cells=len(smoke), deepseek_recorded_pass=sum(r['status'] == 'pass' for r in smoke),
                    deepseek_calls=sum(int(r['api_calls']) for r in smoke),
                    deepseek_improved_from_initial=sum(int(r['final_audited_cycles']) < int(r['initial_audited_cycles']) for r in smoke),
                    training_counts=training['manifest']['counts'], training_record_counts=training['record_counts'],
                    raw_training_records_published=False))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, help='Write the machine-readable audit; default prints it')
    args = parser.parse_args()
    result = audit()
    text = json.dumps(result, indent=2) + '\n'
    if args.out:
        args.out.write_text(text)
        print('Summary consistency passed:', args.out)
    else:
        print(text, end='')


if __name__ == '__main__':
    main()
