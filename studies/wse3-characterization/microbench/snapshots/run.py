#!/usr/bin/env python3
"""Simulator-only boundary snapshots; no claim of arbitrary-cycle stopping.

Run from a fresh compiled case directory. Retain failed debugger probes as evidence.
"""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import (
    SdkRuntime, SimfabConfig, get_simulator, MemcpyDataType, MemcpyOrder)


def main():
    root = Path.cwd()
    case = json.loads(Path('case.json').read_text())
    report = dict(schema='snapshot-experiment/1', case=case, evidence='simulator',
                  snapshots=[], readbacks={}, symbol_reads={}, api={})
    report['api'] = {k: getattr(SdkRuntime, k).__doc__ for k in dir(SdkRuntime)
                     if not k.startswith('_')}
    report['simulator_constructor'] = get_simulator.__doc__
    platform = get_simulator(SimfabConfig(dump_core=True))
    rt = SdkRuntime(str(root/'out'), platform)
    narrow = case['kind'] == 'single'
    opts = dict(streaming=False, data_type=MemcpyDataType.MEMCPY_16BIT if narrow
                else MemcpyDataType.MEMCPY_32BIT, order=MemcpyOrder.ROW_MAJOR, nonblock=False)
    if narrow:
        uploads = [('A', 0, [7, 19, 4660, 22136]), ('B', 0, [5, 23, 17, 33]),
                   ('C', 0, [0, 0, 43981, 48350])]
        expected = {f'{n}@{x},0': v[:] for n, x, v in uploads}
        expected['C@0,0'] = [12, 42, 43981, 48350]
    else:
        word = lambda v: np.asarray(v, np.float32).view(np.uint32).tolist()
        uploads = [('buf', 0, word([11.])), ('loc', 1, word([30.]))]
        expected = {'buf@0,0': word([11.]), 'buf@1,0': word([11.]),
                    'loc@1,0': word([30.]), 'res@1,0': word([41.])}
    report['uploads'] = [dict(symbol=n, pe=[x, 0], bits=v) for n,x,v in uploads]
    report['expected'] = expected
    def snapshot(phase):
        dest = root/phase
        dest.mkdir()
        entry = dict(phase=phase, boundary='after blocking API' if phase!='stopped' else 'after stop', files=[], errors={})
        # Exact basename, and cwd, as required by the public SDK documentation.
        os.chdir(dest)
        try:
            for method, name in [('dump_core', 'corefile.cs1'), ('dump_elf_core', 'state.elf')]:
                try: getattr(rt, method)(name)
                except Exception as e: entry['errors'][method] = repr(e)
        finally: os.chdir(root)
        entry['files'] = [dict(path=str(p.relative_to(root)), bytes=p.stat().st_size,
                               sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in dest.rglob('*') if p.is_file()]
        report['snapshots'].append(entry)
    rt.load(); rt.run()
    for name,x,values in uploads:
        rt.memcpy_h2d(rt.get_id(name), np.array(values,np.uint32), x,0,1,1,len(values), **opts)
    snapshot('loaded')
    rt.call('compute' if narrow else 'run', [], nonblock=False)
    snapshot('computed')  # before readback traffic can disturb state
    for key, values in expected.items():
        name, xy = key.split('@'); x,y=map(int,xy.split(','))
        a=np.zeros(len(values),np.uint32)
        rt.memcpy_d2h(a,rt.get_id(name),x,y,1,1,len(a),**opts)
        report['readbacks'][key]=a.tolist()
    rt.stop()
    snapshot('stopped')
    for key in expected:
        name,xy=key.split('@');x,y=map(int,xy.split(','))
        # SDK read_symbol coordinates are checked independently at both origins.
        for coord in [(x,y),(x+4,y+1)]:
            try:
                value=rt.read_symbol(*coord,name,dtype='uint16' if narrow else 'uint32')
                report['symbol_reads'][f'{name}@{coord}']=np.asarray(value).tolist()
            except Exception as e: report['symbol_reads'][f'{name}@{coord}']={'error':repr(e)}
    report['correct']=report['readbacks']==expected
    for phase in ['loaded','computed','stopped']:
        # Inspect both the documented basename and the produced index path.
        for filename in ['corefile.cs1','corefile.cs1.idx','state.elf']:
            commands = (f'context select out\ntarget create --core-file {phase}/{filename}\n'
                        'memory read --name A --stdoutput\n'
                        'register read --help\nregister read --stdoutput\nexit\n')
            try:
                p=subprocess.run(['csdb',str(root)],input=commands,text=True,capture_output=True,timeout=35)
                text=commands+'\nSTDOUT\n'+p.stdout+'\nSTDERR\n'+p.stderr
            except subprocess.TimeoutExpired as e: text='TIMEOUT\n'+str(e.stdout)+str(e.stderr)
            (root/phase/(filename+'.csdb.log')).write_text(text)
    Path('report.json').write_text(json.dumps(report,indent=2)+'\n')
    print('SNAPSHOTS',case,'readback correct:',report['correct'],flush=True)
    print('symbol_reads',report['symbol_reads'],flush=True)
    assert report['correct']


if __name__=='__main__': main()
