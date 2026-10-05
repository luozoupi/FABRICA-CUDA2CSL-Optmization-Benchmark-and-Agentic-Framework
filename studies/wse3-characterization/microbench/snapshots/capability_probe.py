#!/usr/bin/env python3
"""Read-only search for supported simulator stepping / watchpoint controls."""
import importlib
import json
from pathlib import Path
import shutil
import subprocess

r={'modules':{},'source_hits':[],'commands':[]}
for name in ['cerebras.sdk.runtime.sdkruntimepybind','cerebras.sdk.debug.lib.rectangleopspybind']:
    module=importlib.import_module(name);r['modules'][name]={'exports':{n:getattr(getattr(module,n),'__doc__',None) for n in dir(module) if not n.startswith('_')}}
for p in Path('/cbcore/py_root/cerebras').rglob('*.py'):
    try:lines=p.read_text().splitlines()
    except (OSError,UnicodeError):continue
    for i,line in enumerate(lines):
        if any(w in line for w in ['savepointInterval','memwatch','SIMFAB_CONFIG','run_until_cycle','step_cycle']):
            r['source_hits'].append({'path':str(p),'line':i+1,'context':'\n'.join(lines[max(0,i-2):i+4])})
bins=set()
for directory in ['/cbcore/bin','/usr/local/bin']:
    if Path(directory).exists():bins.update(str(p) for p in Path(directory).iterdir() if 'simfab' in p.name or 'simfabric' in p.name)
for name in ['simfab','simfabric']:
    p=shutil.which(name)
    if p:bins.add(p)
for binary in sorted(bins):
    try:
        p=subprocess.run([binary,'--help'],text=True,capture_output=True,timeout=15)
        r['commands'].append({'argv':[binary,'--help'],'returncode':p.returncode,'stdout':p.stdout,'stderr':p.stderr})
    except Exception as e:r['commands'].append({'binary':binary,'error':str(e)})
commands='target --help\nregister --help\ntrace --help\nrectangle --help\nexit\n'
p=subprocess.run(['csdb','.'],input=commands,text=True,capture_output=True,timeout=30)
r['csdb_help']={'input':commands,'stdout':p.stdout,'stderr':p.stderr}
Path('capabilities.json').write_text(json.dumps(r,indent=2)+'\n')
print('source matches',len(r['source_hits']),'executables',len(bins),flush=True)
for h in r['source_hits'][:20]:print(h)
