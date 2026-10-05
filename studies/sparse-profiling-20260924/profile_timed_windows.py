#!/usr/bin/env python3
"""Audit retained single-PE GEMM CTF traces inside verified timestamp windows.

Offline only: does not compile, simulate, contact an API, or mutate source traces.
These are dispatch and simulator result events, not hardware retired instructions.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import statistics
import struct
import sys


def require(condition, message):
    if not condition:
        raise ValueError(message)


def sha256(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return digest.hexdigest()


def text_section(path):
    binary = path.read_bytes()
    require(binary[:6] == b'\x7fELF\x02\x01', f'Unsupported ELF: {path}')
    header = struct.unpack_from('<HHIQQQIHHHHHH', binary, 16)
    sections = [struct.unpack_from('<IIQQQQIIQQ', binary, header[5] + i * header[10])
                for i in range(header[11])]
    strings = sections[header[12]]
    names = binary[strings[4]:strings[4] + strings[5]]
    for section in sections:
        if names[section[0]:].split(b'\0')[0] == b'.text':
            return section[3], binary[section[4]:section[4] + section[5]]
    raise ValueError(f'Missing .text: {path}')


def describe(values):
    return dict(min=min(values), median=statistics.median(values), max=max(values))


def analyze(directory, root, reader_class):
    case = json.loads((directory / 'case.json').read_text())
    require(case['op'] == 'gemm' and case['application_pes'] == 1 and not case['debug'],
            'This analyzer accepts only the retained single-PE performance GEMM cases')
    replay = json.loads((directory / 'trace-observations.json').read_text())
    binding = json.loads((directory / 'elf-binding.json').read_text())
    original = root / 'builds' / binding['original_build']
    for relative, expected in binding['matched_elf_hashes'].items():
        require(sha256(directory / 'out' / relative) == expected,
                f'Replay ELF hash mismatch: {relative}')
        require(sha256(original / 'out' / relative) == expected,
                f'Original measured ELF hash mismatch: {relative}')
    for name in ('pe.csl', 'layout.csl'):
        require(sha256(directory / name) == case['source_hashes'][name], f'Source changed: {name}')
    require(sha256(directory / 'disassembly.json') == sha256(original / 'disassembly.json'),
            'Retained disassembly differs from original build disassembly')
    assembly = [row for rows in json.loads((directory / 'disassembly.json').read_text()).values()
                for row in rows]
    source_map = {row['pc']: row for row in assembly}
    require(len(source_map) == len(assembly), 'Ambiguous PC mapping')
    timer_pcs = sorted(row['pc'] for row in assembly
                       if re.match(r'ld16 .*\[0x7b30\]', row['instruction']))
    require(len(timer_pcs) >= 2, f'Expected SDK timestamp anchor PCs, got {timer_pcs}')
    coordinates = json.loads((directory / 'simfab_traces/global_simdata.json').read_text())
    require(coordinates['xsize'] == 8 and coordinates['ysize'] == 3,
            'Unsupported simulator geometry for this frozen microbenchmark')
    tile_index = 1 * coordinates['xsize'] + 4
    sections = [text_section(p) for p in (directory / 'out/bin').glob('*.elf')]
    require(len(sections) == 1, 'Expected one application ELF')
    reader = reader_class(directory / 'simfab_traces')
    dispatch = {}
    floating = {}
    for event in reader.iter_events():
        if event.get('tile_index') != tile_index:
            continue
        uid = event.get('uid')
        if event['event_type'] == 'hwm_dispatch_trace_entry':
            require(uid not in dispatch, f'Reused dispatch UID: {uid}')
            dispatch[uid] = {k: event[k] for k in ('uid', 'cycle', 'inst_ptr', 'inst_bin', 'name')}
        elif event['event_type'] == 'hwm_pipe_trace_entry' and event['stage'] == 6 and event['dest'] != 0xffffffff:
            instruction = dispatch.get(uid)
            if not instruction or instruction['name'].split()[0].upper() not in ('FMACS', 'FMULS', 'FADDS'):
                continue
            instance = floating.setdefault(uid, {'cycles': [], 'lanes': Counter()})
            instance['cycles'].append(event['cycle'])
            # The documented lane field is retained if this SDK metadata supplies it.
            instance['lanes'][str(event.get('simdi', 'not_in_metadata'))] += 1
    require(not reader.warnings and reader.discarded_events_total == 0,
            f'Incomplete trace: {reader.warnings}')
    anchors = sorted((event for event in dispatch.values() if event['inst_ptr'] in timer_pcs),
                     key=lambda event: event['cycle'])
    samples = replay['samples']
    require(len(anchors) == 2 * len(samples), 'Timestamp anchor count does not match launches')
    observed_pair = [anchors[0]['inst_ptr'], anchors[1]['inst_ptr']]
    require(observed_pair[0] != observed_pair[1], 'Ambiguous timer pair')
    windows = []
    for i, sample in enumerate(samples):
        start, end = anchors[2*i:2*i+2]
        require([start['inst_ptr'], end['inst_ptr']] == observed_pair,
                'Unexpected timestamp control flow')
        cycles = end['cycle'] - start['cycle']
        require(cycles == sample['cycles'] == sample['end'] - sample['start'],
                'Trace timestamp interval differs from saved device timing')
        require(sample['correct'] and sample['equals_original_measurement'],
                'Original replay did not pass correctness and timing comparison')
        selected = {uid: event for uid, event in dispatch.items()
                    if start['cycle'] <= event['cycle'] < end['cycle']}
        counts = Counter()
        fp_counts = Counter()
        fp_elements = Counter()
        fp_cycles = set()
        fma_spans = []
        first_result_delays = []
        lane_counts = Counter()
        for uid, event in selected.items():
            require(event['inst_ptr'] in source_map, 'Dispatch PC absent from disassembly')
            address = 2 * event['inst_ptr']  # Cerebras PC is word-addressed; ELF is byte-addressed.
            require(any(base <= address <= base + len(data) - 4
                        and struct.unpack_from('<I', data, address-base)[0] == event['inst_bin']
                        for base, data in sections), 'Dispatch encoding differs from measured ELF')
            opcode = event['name'].split()[0].upper()
            counts[opcode] += 1
            if uid in floating:
                instance = floating[uid]
                require(all(start['cycle'] <= c < end['cycle'] for c in instance['cycles']),
                        'Floating results cross a timer boundary')
                fp_counts[opcode] += 1
                fp_elements[opcode] += len(instance['cycles'])
                fp_cycles.update(instance['cycles'])
                lane_counts.update(instance['lanes'])
                if opcode == 'FMACS':
                    fma_spans.append(max(instance['cycles']) - min(instance['cycles']) + 1)
                    first_result_delays.append(min(instance['cycles']) - event['cycle'])
        expected = case['M'] * case['K'] * case['N']
        require(fp_elements['FMACS'] + fp_elements['FMULS'] == expected,
                'Timed region does not cover exactly M*K*N multiplication results')
        require(fp_elements['FMULS'] == fp_elements['FADDS'], 'Unpaired scalar multiply/add')
        require(sum(len(instance['cycles']) for uid, instance in floating.items()
                    if uid not in selected and any(start['cycle'] <= c < end['cycle']
                                                  for c in instance['cycles'])) == 0,
                'Arithmetic inside timer window originated outside it')
        windows.append(dict(
            repetition=sample['repetition'], warmup=sample['warmup'], cycles=cycles,
            trace_start_cycle=start['cycle'], trace_end_cycle=end['cycle'],
            recorded_tsc_start=sample['start'], recorded_tsc_end=sample['end'],
            dispatches=len(selected), opcode_dispatches=dict(sorted(counts.items())),
            floating_dispatches=dict(fp_counts), floating_result_elements=dict(fp_elements),
            floating_result_event_cycles=len(fp_cycles), lane_field_counts=dict(lane_counts),
            fma_result_span_cycles=describe(fma_spans) if fma_spans else None,
            fma_dispatch_to_first_result_cycles=describe(first_result_delays) if first_result_delays else None,
            conventional_flops=2*expected, conventional_flops_per_cycle=2*expected/cycles,
            cycles_per_dispatch=cycles/len(selected)))
    require(len(windows) == 4 and sum(not w['warmup'] for w in windows) == 3,
            'Expected one warmup plus three measurements')
    require(sum(sum(w['floating_result_elements'].values()) for w in windows)
            == sum(len(instance['cycles']) for instance in floating.values()),
            'Unexpected arithmetic outside all measured and warmup windows')
    paths = [directory / name for name in ('case.json','trace-observations.json','elf-binding.json',
                                         'disassembly.json','pe.csl','layout.csl')]
    paths += sorted((directory / 'simfab_traces').iterdir())
    return dict(id=directory.name, passed=True, evidence='retained WSE-3 simulator trace; offline analysis',
                case_directory=str(directory), compute_tile=dict(x=4,y=1,index=tile_index),
                timer_candidate_pcs=timer_pcs, observed_timer_pair=observed_pair, windows=windows,
                discarded_events=reader.discarded_events_total, warnings=reader.warnings,
                elf_sha256=binding['matched_elf_hashes'],
                input_sha256={str(p.relative_to(directory)):sha256(p) for p in paths if p.is_file()})


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--microbench-root', type=Path, required=True)
    parser.add_argument('--trace-library', type=Path, required=True,
                        help='Directory containing the existing wse3study package')
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--cases', nargs='+', default=['perf-gemm-row_dsd-16x16x16-r',
                        'perf-gemm-column_dsd-16x16x16-r','perf-gemm-scalar_ijk-16x16x16-r'])
    args = parser.parse_args()
    sys.path.insert(0, str(args.trace_library.resolve()))
    from wse3study.trace import CtfTraceReader
    results = []
    for name in args.cases:
        result = analyze(args.microbench_root / 'performance-traces' / name,
                         args.microbench_root, CtfTraceReader)
        results.append(result)
        sample = result['windows'][1]
        print(name, 'PASS', sample['cycles'], 'cycles;', sample['dispatches'],
              'dispatches;', sample['floating_result_elements'], flush=True)
    payload = dict(schema_version=1, analyzer_sha256=sha256(Path(__file__)),
                   trace_parser_sha256=sha256(args.trace_library/'wse3study/trace.py'),
                   scope='SDK timestamp low-word-read dispatch anchors, start inclusive/end exclusive. '
                         'Includes in-window timestamp plumbing and output initialization; excludes host transfers. '
                         'Recorded replay correctness is checked, not re-executed. Results are simulator events, '
                         'not hardware retirement, stall attribution, or arithmetic utilization.',
                   results=results)
    args.output.write_text(json.dumps(payload, indent=2)+'\n')


if __name__ == '__main__':
    main()
