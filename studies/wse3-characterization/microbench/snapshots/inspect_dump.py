#!/usr/bin/env python3
"""Inspect retained dumps through vendor tools; never executes the workload."""
import inspect
import json
from pathlib import Path
import subprocess
from cerebras.elf.cself import ELFLoader, ELFMemory

root=Path.cwd()
report={'ELFLoader_methods':[n for n in dir(ELFLoader) if not n.startswith('_')],
        'ELFMemory_methods':[n for n in dir(ELFMemory) if not n.startswith('_')]}
report['ELFLoader_source']=inspect.getsource(ELFLoader)
report['ELFMemory_source']=inspect.getsource(ELFMemory)
Path('elf-reader-api.json').write_text(json.dumps(report,indent=2))
for phase in ['loaded','computed','stopped']:
    commands=(f'context select out\ntarget create --core-file {phase}/corefile.cs1\n'
              'help\nconfig --help\nmemory read --help\n'
              'memory read --name A --stdoutput\nmemory read --name B --stdoutput\nmemory read --name C --stdoutput\n'
              'memory read --name buf --stdoutput\nmemory read --name loc --stdoutput\nmemory read --name res --stdoutput\n'
              'register read --stdoutput\nexit\n')
    r=subprocess.run(['csdb',str(root)],input=commands,text=True,capture_output=True,timeout=45)
    (root/phase/'inspection.log').write_text(commands+'\n'+r.stdout+'\nSTDERR\n'+r.stderr)
    print(phase,r.returncode,len(r.stdout),'bytes',flush=True)
print('API saved',report['ELFLoader_methods'],report['ELFMemory_methods'])
