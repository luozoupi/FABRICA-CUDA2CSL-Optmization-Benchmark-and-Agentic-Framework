#!/usr/bin/env python3
"""Read-only SDK inventory; run inside cs_python. No compilation or device jobs.

Captures installed command help and Python debug API surfaces, so public
documentation claims can be checked against the exact local SDK version.
"""
import hashlib
import importlib
import json
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'results/architecture-review'


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    report = {'schema': 'sdk-architecture-probe/1', 'commands': [], 'modules': {}}
    commands = [
        ['cslc', '--version'], ['cslc-driver', '--version'], ['cslc', '--help'],
        ['cslc-driver', '--help-hidden'], ['cslc-backend', '--help'],
        ['cs-readelf', '--help'], ['elf2am', '--help'],
        ['sdk_debug_shell', '--help'],
        ['sdk_debug_shell', 'visualize', '--help'],
        ['sdk_debug_shell', 'instr-trace', '--help'],
        ['sdk_debug_shell', 'wavelet-trace', '--help'],
        ['sdk_debug_shell', 'simulate', '--help'], ['csdb', '--help'],
    ]
    sample = str(ROOT / 'results/readiness/try-20260916b/b16-d256-r0')
    for group in ['instr-trace', 'wavelet-trace']:
        commands.append(['sdk_debug_shell', group, '--artifact_dir', sample,
                         '--x', '4', '--y', '1', 'trace', '--help'])
    commands.append(['sdk_debug_shell', 'wavelet-trace', '--artifact_dir', sample,
                     '--x', '4', '--y', '1', '--color', '6', '--fmt', 'f32',
                     '--backpressure', 'trace'])
    commands.append(['cs-readelf', '--units=byte', '--sym', str(ROOT /
                     'results/gemv-walkthrough/try-20260915a/v1-history/out/bin/out_1_0.elf')])
    for cmd in commands:
        exe = shutil.which(cmd[0])
        item = {'argv': cmd, 'executable': exe}
        if exe:
            try:
                r = subprocess.run(cmd, input='', text=True, capture_output=True, timeout=30)
                item.update(returncode=r.returncode, stdout=r.stdout, stderr=r.stderr)
                item['executable_sha256'] = hashlib.sha256(Path(exe).read_bytes()).hexdigest()
            except subprocess.TimeoutExpired:
                item['error'] = 'help timed out after 30 seconds'
        report['commands'].append(item)
    csdb_input = ('wavelet read-timeline --help\nwavelet read-trace --help\n'
                  'memory read --help\nregister read --help\nexit\n')
    try:
        r = subprocess.run(['csdb', sample], input=csdb_input, text=True,
                           capture_output=True, timeout=30)
        report['csdb_help'] = dict(stdin=csdb_input, returncode=r.returncode,
                                   stdout=r.stdout, stderr=r.stderr)
    except subprocess.TimeoutExpired:
        report['csdb_help'] = {'error': 'timeout'}
    for name in ['cerebras.sdk.debug.lib.symbol.csldebugpybind',
                 'cerebras.sdk.runtime.sdkruntimepybind']:
        try:
            m = importlib.import_module(name)
            info = {'file': m.__file__, 'exports': [n for n in dir(m) if not n.startswith('_')]}
            for cls in ['SimfabInstructionTraceCtf', 'SimfabWaveletTraceCtf',
                        'SimfabConfig', 'SdkRuntime']:
                if hasattr(m, cls):
                    obj = getattr(m, cls)
                    info[cls] = {n: getattr(getattr(obj, n), '__doc__', None)
                                 for n in dir(obj) if not n.startswith('_')}
                    info[cls]['__init__'] = obj.__init__.__doc__
            report['modules'][name] = info
        except Exception as exc:
            report['modules'][name] = {'error': str(exc)}
    (OUT / 'tool-probe.json').write_text(json.dumps(report, indent=2) + '\n')
    for item in report['commands']:
        print(' '.join(item['argv']), '->', item.get('returncode', item.get('error', 'absent')),
              item['executable'])
    print(OUT / 'tool-probe.json')


if __name__ == '__main__':
    main()
