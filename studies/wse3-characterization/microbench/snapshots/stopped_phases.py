#!/usr/bin/env python3
"""Independent simulator runs stopped at two host boundaries, with no D2H first.

Run in a retained snapshot case. Only writes new stopped-* subdirectories.
"""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import argparse
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, SimfabConfig, get_simulator, MemcpyDataType, MemcpyOrder
from cerebras.elf.cself import ELFLoader, ELFMemory

root=Path.cwd();prior=json.loads(Path('report.json').read_text());narrow=prior['case']['kind']=='single'
ap=argparse.ArgumentParser();ap.add_argument('--phase',choices=['loaded','computed'],required=True);args=ap.parse_args()
results={'schema':'stopped-phase-validation/1','kind':prior['case']['kind'],'phases':{}}
# The installed simulator permits only one instance per Python process.
for phase in [args.phase]:
    work=root/f'stopped-{phase}';work.mkdir(exist_ok=False);shutil.copytree(root/'out',work/'out')
    os.chdir(work)
    rt=SdkRuntime('out',get_simulator(SimfabConfig(dump_core=True)))
    rt.load();rt.run()
    opts=dict(streaming=False,data_type=MemcpyDataType.MEMCPY_16BIT if narrow else MemcpyDataType.MEMCPY_32BIT,order=MemcpyOrder.ROW_MAJOR,nonblock=False)
    for u in prior['uploads']:
        rt.memcpy_h2d(rt.get_id(u['symbol']),np.asarray(u['bits'],np.uint32),*u['pe'],1,1,len(u['bits']),**opts)
    if phase=='computed':rt.call('compute' if narrow else 'run',[],nonblock=False)
    rt.stop()
    rt.dump_core('corefile.cs1');rt.dump_elf_core('state.elf')
    core=ELFMemory('state.elf');values={};gpr={};symbols={};reads={}
    for key in prior['expected']:
        name,xy=key.split('@');x,y=map(int,xy.split(','))
        elf=next(p for p in Path('out/bin').glob('out_*.elf') if (x+4,y+1) in list(ELFMemory(p).iter_coordinates()))
        loader=ELFLoader(elf)
        matches=[n for n in loader.symbols if n==name or n.startswith('$$csl_base_address$$') and n.endswith('$$'+name)]
        if len(matches)!=1:raise RuntimeError(f'Ambiguous ELF symbol {name}: {matches}')
        addr,size=loader.get_symbol_addr(matches[0])
        values[key]=np.frombuffer(bytes(core.read_data(x+4,y+1,addr,size)),np.uint16 if narrow else np.uint32).tolist()
        symbols[key]={'byte_address':addr,'bytes':size,'fabric':[x+4,y+1],'elf_symbol':matches[0]}
        gpr[xy]=np.frombuffer(bytes(core.read_data(x+4,y+1,0x7d10*2,32)),np.uint16).tolist()
        try:reads[key]=np.asarray(rt.read_symbol(x+4,y+1,name,dtype='uint16' if narrow else 'uint32')).tolist()
        except Exception as e:reads[key]={'error':str(e)}
    expected={key:[0]*len(v) for key,v in prior['expected'].items()}
    for u in prior['uploads']:expected[f'{u["symbol"]}@{u["pe"][0]},{u["pe"][1]}']=u['bits']
    if phase=='computed':expected=prior['expected']
    commands='context select out\ntarget create --core-file corefile.cs1\n'+''.join(f'memory read --name "{name}" --stdoutput\n' for name in sorted({v['elf_symbol'] for v in symbols.values()}))+'register read --stdoutput\nexit\n'
    p=subprocess.run(['csdb',str(work)],input=commands,text=True,capture_output=True,timeout=45)
    Path('csdb.log').write_text(commands+'\n'+p.stdout+'\nSTDERR\n'+p.stderr)
    result={'sram':values,'expected':expected,'passed':values==expected,'gpr_u16':gpr,'symbols':symbols,'read_symbol':reads,
            'boundary':'after stop; no host D2H before dump','host_readback_before_dump':False,
            'sha256':{str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in Path('.').glob('*') if p.is_file()}}
    Path('validation.json').write_text(json.dumps(result,indent=2)+'\n');results['phases'][phase]=result
    print(phase,'snapshot matches expected:',result['passed'],values,flush=True)
    os.chdir(root)
for phase in ['loaded','computed']:
    p=root/f'stopped-{phase}'/'validation.json'
    if p.exists():results['phases'][phase]=json.loads(p.read_text())
Path('stopped-validation.json').write_text(json.dumps(results,indent=2)+'\n')
