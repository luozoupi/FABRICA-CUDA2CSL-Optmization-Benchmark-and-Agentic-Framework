#!/usr/bin/env python3
"""Verify the shipped summary/source snapshot without running either platform."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read(name):
    return json.loads((ROOT / name).read_text())


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


def verify():
    manifest = read('packaging-manifest.json')
    for name, record in manifest['files'].items():
        path = ROOT / name
        require(path.is_file() and sha(path) == record['sha256'], 'Snapshot hash mismatch: ' + name)
    build = read('gpu-build.json')
    for name, expected in build['hashes'].items():
        if name != 'gpu-bench':
            require(sha(ROOT / name) == expected, 'Measured GPU source mismatch: ' + name)
    source = (ROOT / 'vendor/ge-spmm/spmm_test.cu').read_text()
    body = source[source.index('template<typename T>'):source.index('int main(')]
    extracted = (ROOT / 'ge_kernels.cuh').read_text().split('\n', 2)[2]
    require(extracted == body, 'GE kernel extraction changed')
    wse = read('wse-manifest.json')
    for case in wse:
        directory = ROOT / 'wse' / case['id']
        for name, expected in case['source_hashes'].items():
            require(sha(directory / name) == expected, f"Measured CSL source mismatch: {case['id']}/{name}")
        require(json.loads((directory / 'case.json').read_text()) == case, 'CSL case mismatch')
    audit = read('audit.json')
    for name, expected in audit['input_manifest_hashes'].items():
        require(sha(ROOT / name) == expected, 'Input manifest mismatch: ' + name)
    results = read('results.json')
    counts = results['counts']
    require(counts == read('handoff-manifest.json')['counts'], 'Frozen result count mismatch')
    require(counts['gpu_cases'] == 124 and counts['gpu_primary_accepted'] == 804
            and counts['gpu_primary_rejected'] == 41, 'GPU summary mismatch')
    require(counts['wse_passed'] == 8 and counts['wse_total'] == len(wse) == 12, 'WSE summary mismatch')
    require(audit['status'] == 'pass' and audit['gpu_independent_output_checks'] == 2706
            and audit['wse_checked_launches'] == 576, 'Audit summary mismatch')
    require(not read('handoff-manifest.json')['pending'] and not read('handoff-manifest.json')['running'],
            'Unfinished experiment reported as complete')
    print(f"Verified {len(manifest['files'])} packaged files, exact GPU sources and {len(wse)} CSL source builds.")
    print('Recorded results: 804 GPU cases accepted / 41 rejected; 8 CSL builds accepted / 4 timed out.')
    print('This integrity check does not repeat the numerical or device runs.')


if __name__ == '__main__':
    verify()
