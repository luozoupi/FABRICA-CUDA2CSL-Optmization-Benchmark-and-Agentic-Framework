#!/usr/bin/env python3
"""Compare the ELF core SRAM to known initialization and exact host readbacks."""
import json
from pathlib import Path
import subprocess
import numpy as np
from cerebras.elf.cself import ELFLoader, ELFMemory

root=Path.cwd();report=json.loads(Path('report.json').read_text())
result={'schema':'snapshot-validation/1','phases':{},'symbols':{},'register_scope':'raw csdb register dump; no per-cycle claim'}
locations={}
for elf in Path('out/bin').glob('out_*.elf'):
    memory=ELFMemory(elf);loader=ELFLoader(elf_file=elf)
    for x,y in memory.iter_coordinates():
        locations[f'{x-4},{y-1}']=(elf,loader)
for phase in ['loaded','computed','stopped']:
    core=ELFMemory(Path(phase)/'state.elf'); values={};commands=f'context select out\ntarget create --core-file {phase}/corefile.cs1\nrectangle --help\nrectangle select --help\n'
    for key,expected in report['expected'].items():
        name,xy=key.split('@');x,y=map(int,xy.split(','));elf,loader=locations[xy]
        matches=[n for n in loader.symbols if n==name or n.startswith('$$csl_base_address$$') and n.endswith('$$'+name)]
        if len(matches)!=1:raise RuntimeError(f'Ambiguous ELF symbol {name}: {matches}')
        addr,size=loader.get_symbol_addr(matches[0]);raw=bytes(core.read_data(x+4,y+1,addr,size))
        dtype=np.uint16 if report['case']['kind']=='single' else np.uint32
        values[key]=np.frombuffer(raw,dtype).tolist()
        result['symbols'][key]={'byte_address':addr,'word_address':addr//2,'bytes':size,'elf':str(elf),'fabric':[x+4,y+1]}
        commands+=f'memory read --address {addr//2} --length {size//2} --stdoutput\n'
        commands+=f'memory read --address {addr} --length {size//2} --stdoutput\n'
    result['phases'][phase]={'sram':values}
    # Independent raw ELF reads of the address range identified by csdb as ce_gpr.
    result['phases'][phase]['gpr_u16']={xy:np.frombuffer(bytes(core.read_data(int(xy.split(',')[0])+4,int(xy.split(',')[1])+1,0x7d10*2,32)),np.uint16).tolist() for xy in locations}
    commands+='register read --stdoutput\nexit\n'
    p=subprocess.run(['csdb',str(root)],input=commands,text=True,capture_output=True,timeout=45)
    (Path(phase)/'address-register-check.log').write_text(commands+'\n'+p.stdout+'\nSTDERR\n'+p.stderr)
expected_loaded={key:([0]*len(v)) for key,v in report['expected'].items()}
for u in report['uploads']:expected_loaded[f'{u["symbol"]}@{u["pe"][0]},{u["pe"][1]}']=u['bits']
result['checks']={'loaded_matches_uploads':result['phases']['loaded']['sram']==expected_loaded,
    'computed_matches_expected':result['phases']['computed']['sram']==report['expected'],
    'stopped_matches_readback':result['phases']['stopped']['sram']==report['readbacks']}
Path('validation.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2),flush=True)
