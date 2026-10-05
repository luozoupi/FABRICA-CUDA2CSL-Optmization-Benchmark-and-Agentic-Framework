#!/usr/bin/env python3
"""Reconstruct frozen inputs and CSL source in a new directory; run no device jobs."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parent


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load_generator(path):
    spec = importlib.util.spec_from_file_location('frozen_input_generator', path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def write_checked(path, array, expected):
    path.parent.mkdir(parents=True, exist_ok=True)
    array.tofile(path)
    actual = sha(path)
    if actual != expected:
        raise RuntimeError(f'Reconstructed input differs from frozen input: {path}')


def prepare(out, scope):
    # Dependencies are checked before creating the destination.
    import numpy as np
    from scipy.io import mmread
    from verify_snapshot import verify
    verify()
    out = out.expanduser().resolve()
    if out == ROOT or ROOT in out.parents:
        raise ValueError('Replay directory must be outside the recorded study')
    out.mkdir(parents=True, exist_ok=False)
    for p in ROOT.iterdir():
        if p.suffix in ('.py', '.cu', '.cuh') and p.name not in (
                'prepare_replay.py', 'verify_snapshot.py', 'finalize.py', 'make_hardware_bundle.py'):
            shutil.copy2(p, out / p.name)
    for name in ('PROTOCOL.md', 'CAPACITY_AMENDMENT.md', 'replay-registration.json', 'viewer-template.html'):
        shutil.copy2(ROOT / name, out / name)
    for directory in ('inputs', 'sources', 'vendor', 'tools'):
        shutil.copytree(ROOT / directory, out / directory,
                        ignore=shutil.ignore_patterns('__pycache__', '*.pyc'))
    manifests = [json.loads((ROOT / 'inputs' / name).read_text())
                 for name in ('manifest.json', 'capacity-manifest.json')]
    cases = [c for manifest in manifests for c in manifest['cases']
             if scope == 'all' or c['shared_wse']]
    wanted = {c['matrix_id'] for c in cases}
    generator = load_generator(out / 'make_inputs.py')
    restored = []
    for matrix in (m for manifest in manifests for m in manifest['matrices'] if m['id'] in wanted):
        if matrix['family'] == 'real':
            source = out / 'sources' / (matrix['id'].removeprefix('HB-') + '.mtx')
            if sha(source) != matrix['values']['sha256']:
                raise RuntimeError('Matrix Market source mismatch: ' + str(source))
            a = mmread(source).tocsr()
            a.sum_duplicates()
            a.sort_indices()
            a.data = a.data.astype(np.float32)
        else:
            a = generator.synthetic(matrix['M'], matrix['K'], matrix['family'])
        if a.nnz != matrix['nnz']:
            raise RuntimeError('Nonzero count mismatch: ' + matrix['id'])
        directory = out / 'inputs' / matrix['id']
        for name, array in [('row_ptr.bin', a.indptr.astype('<i4')),
                            ('col_idx.bin', a.indices.astype('<i4')),
                            ('values.bin', a.data.astype('<f4'))]:
            write_checked(directory / name, array, matrix['sha256'][name])
        for case in (c for c in cases if c['matrix_id'] == matrix['id']):
            b = generator.dense(case['K'], case['N'])
            expected = a.astype(np.float64) @ b.astype(np.float64)
            dense_dir = out / case['dense_path']
            for name, array in [('B.bin', b.astype('<f4')), ('expected.bin', expected.astype('<f8'))]:
                write_checked(dense_dir / name, array, case['sha256'][name])
            (dense_dir / 'case.json').write_text(json.dumps(case, indent=2) + '\n')
            restored.append(case['id'])
    subprocess.run([sys.executable, str(out / 'make_wse.py')], check=True)
    frozen = json.loads((ROOT / 'wse-manifest.json').read_text())
    rebuilt = json.loads((out / 'wse-manifest.json').read_text())
    if rebuilt != frozen:
        raise RuntimeError('Reconstructed CSL configuration/source/input hashes differ')
    receipt = dict(scope=scope, input_cases=restored, checked_csl_builds=len(rebuilt),
                   snapshot_sha256=sha(ROOT / 'packaging-manifest.json'),
                   note='Preparation only. No GPU, simulator or hardware run has been performed.')
    (out / 'replay-provenance.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(f'Prepared {len(restored)} input cases and {len(rebuilt)} exact CSL builds in {out}')
    print('Set CEREBRAS_SDK_DIR to the directory containing cslc and cs_python before run_wse.py.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', required=True, type=Path)
    parser.add_argument('--inputs', choices=('shared-wse', 'all'), default='shared-wse',
                        help='all reconstructs the GPU inputs too and needs several GB of storage')
    args = parser.parse_args()
    prepare(args.out, args.inputs)


if __name__ == '__main__':
    main()
