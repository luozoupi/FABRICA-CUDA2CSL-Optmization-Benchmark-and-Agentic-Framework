#!/usr/bin/env python3
"""Serial two-PE simulator sweep. Compile once per length, retain every treatment."""
import argparse
import datetime
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import socket
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
STUDY = HERE.parents[1]
sys.path.insert(0, str(STUDY))
from wse3study.inventory import _Elf64


def sha(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as f:
        for block in iter(lambda: f.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()


def patch_delay(ir, count):
    match = re.search(r'^define internal void @run\(\)[^\n]*\{\n', ir, re.M)
    if not match:
        raise ValueError('Missing run() IR definition')
    return ir[:match.end()] + '  call void asm sideeffect "nop", ""()\n' * count + ir[match.end():]


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--execute', action='store_true')
    ap.add_argument('--lengths', type=int, nargs='+', default=[1, 8, 16])
    ap.add_argument('--delays', type=int, nargs='+', default=[0, 64, 256])
    ap.add_argument('--sender-delay', type=int, default=64)
    ap.add_argument('--repeat', type=int, default=1)
    ap.add_argument('--out', type=Path)
    ap.add_argument('--sdk', type=Path, default=Path('/software/cerebras/cs_sdk-2.10'))
    a = ap.parse_args()
    if (any(n < 1 or n > 64 for n in a.lengths) or
        any(d < 0 or d > 4096 for d in [a.sender_delay, *a.delays]) or a.repeat < 1):
        ap.error('Lengths 1..64, NOP counts 0..4096, repeat >= 1 required')
    if len(set(a.lengths)) != len(a.lengths) or len(set(a.delays)) != len(a.delays):
        ap.error('Duplicate lengths/delays are not treatments; use --repeat')
    root = (a.out or STUDY/'results/readiness'/datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ')).resolve()
    print('Simulator only:', root, a.lengths, a.delays, 'repetitions', a.repeat, flush=True)
    if not a.execute:
        return
    if 'login' in socket.gethostname():
        raise SystemExit('Execute on the SDK user node, not a login node')
    env = dict(os.environ, PATH=f'{a.sdk}:/usr/bin:/bin:' + os.environ['PATH'], TMPDIR='/tmp')
    with (STUDY/'microbench/gemm_walkthrough/.capture.lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        root.mkdir(parents=True, exist_ok=False)
        commands = []
        def run(argv, cwd):
            argv = list(map(str, argv))
            commands.append(dict(cwd=str(cwd), argv=argv))
            print('RUN', cwd.name, ' '.join(argv), flush=True)
            with (cwd/'capture.log').open('a') as f:
                subprocess.run(argv, cwd=cwd, env=env, stdout=f, stderr=subprocess.STDOUT,
                               timeout=900, check=True)

        for n in a.lengths:
            base = root/f'base-b{n}'; base.mkdir()
            for name in ('pe.csl', 'layout.csl', 'run.py'):
                shutil.copy2(HERE/name, base/name)
            run([sys.executable, STUDY/'tools/cslc_ir.py', 'capture', '-o', 'ir', '--',
                 './layout.csl', '--arch=wse3', '--fabric-dims=9,3', '--fabric-offsets=4,1',
                 f'--params=B:{n}', '-o', 'out', '--memcpy', '--channels=1',
                 '--width-west-buf=0', '--width-east-buf=0', '--out-routes'], base)
            caps = {}
            for mp in sorted((base/'ir').glob('*/meta.json')):
                cap = mp.parent; meta = json.loads(mp.read_text()); elf = Path(meta['elf'])
                tiles = _Elf64(elf).program_tile_ids()
                for tile in tiles:
                    if tile in (13, 14):
                        caps[tile - 13] = (cap, elf)
            if set(caps) != {0, 1}:
                raise ValueError(f'Unexpected ELF placement: {caps}')
            for x, (cap, elf) in caps.items():
                shutil.copy2(elf, cap/'original.elf')
            cap, sender = caps[0]
            (cap/'sender.ll').write_text(patch_delay((cap/'program.ll').read_text(), a.sender_delay))
            run([sys.executable, STUDY/'tools/cslc_ir.py', 'rebuild', cap,
                 '--ll', cap/'sender.ll', '--optnone', 'run', '--keep-work', '-o', sender], base)
            sender_hash = sha(sender)
            for delay in a.delays:
                cap, receiver = caps[1]
                patched = cap/f'receiver-d{delay}.ll'
                patched.write_text(patch_delay((cap/'program.ll').read_text(), delay))
                run([sys.executable, STUDY/'tools/cslc_ir.py', 'rebuild', cap,
                     '--ll', patched, '--optnone', 'run', '--keep-work', '-o', receiver], base)
                for repeat in range(a.repeat):
                    case_id = f'b{n}-d{delay}-r{repeat}'
                    work = root/case_id; work.mkdir()
                    shutil.copytree(base/'out', work/'out')
                    for name in ('pe.csl', 'layout.csl', 'run.py'):
                        shutil.copy2(base/name, work/name)
                    shutil.copy2(patched, work/'receiver.ll')
                    shutil.copy2(caps[0][0]/'sender.ll', work/'sender.ll')
                    spec = dict(id=case_id, words=n, receiver_nops=delay,
                                sender_nops=a.sender_delay, repeat=repeat, color=6,
                                fabric=[9, 3], source=[4, 1], destination=[5, 1])
                    (work/'case.json').write_text(json.dumps(spec, indent=2)+'\n')
                    placement = {f'{x},0': dict(tile=13+x, fabric=[4+x, 1],
                        elf=str(elf.relative_to(base)), disasm=f'disasm_{x}_0.json')
                        for x, (_, elf) in caps.items()}
                    (work/'placement.json').write_text(json.dumps(placement, indent=2)+'\n')
                    assert sha(work/placement['0,0']['elf']) == sender_hash
                    run([a.sdk/'cs_python', 'run.py'], work)
                    for _ in range(30):
                        if (work/'simfab_traces/stream0').exists():
                            break
                        time.sleep(1)
                    run([sys.executable, STUDY/'tools/decode_trace.py', '.', '-o', 'events.jsonl.gz'], work)
                    for p in placement.values():
                        run([sys.executable, STUDY/'tools/csdisasm.py', p['elf'], '--json', p['disasm']], work)
                    hashes = {str(p.relative_to(work)): sha(p) for p in work.rglob('*')
                              if p.is_file() and p.name != 'capture.log'}
                    manifest = dict(schema='readiness-run/1', evidence='simulator', case=spec,
                        base=str(base.relative_to(STUDY)), sdk=str(a.sdk), host=socket.gethostname(),
                        sender_sha256=sender_hash, sha256=hashes,
                        ir_sha256={str(p.relative_to(STUDY)): sha(p) for x in caps
                                   for p in [caps[x][0]/'program.ll', caps[x][0]/'original.elf']})
                    (work/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
                    print('COMPLETE', case_id, flush=True)
        (root/'commands.json').write_text(json.dumps(commands, indent=2)+'\n')


if __name__ == '__main__':
    main()
