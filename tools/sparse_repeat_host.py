#!/usr/bin/env cs_python
"""Diagnostic shim: reuse one loaded SDK runtime for four host launches.

Run inside a compiled bundle with cs_python sparse_repeat_host.py --name out.
The original run.py supplies all transfers and numerical assertions.
"""
import json
import os
import runpy
import sys
import numpy as np
from cerebras.sdk.runtime import sdkruntimepybind as sdk

OriginalRuntime=sdk.SdkRuntime

class ReusedRuntime:
    def __init__(self):
        self.runtime=None;self.loaded=False;self.running=False
    def construct(self,*args,**kwargs):
        if self.runtime is None:self.runtime=OriginalRuntime(*args,**kwargs)
        return self
    def load(self,*args,**kwargs):
        if not self.loaded:self.runtime.load(*args,**kwargs);self.loaded=True
    def run(self,*args,**kwargs):
        if not self.running:self.runtime.run(*args,**kwargs);self.running=True
    def stop(self):pass
    def __getattr__(self,name):return getattr(self.runtime,name)

shared=ReusedRuntime();sdk.SdkRuntime=shared.construct
rows=[]
try:
    for index,seed in enumerate((7,101,202,7)):
        os.environ['XKERNEL_EVAL_SEED']=str(seed)
        sys.argv[0]='run.py'
        try:
            values=runpy.run_path('run.py',run_name='__main__')
            if 'starts' in values:
                starts=np.asarray(values['starts']).ravel().astype('int64').tolist()
                ends=np.asarray(values['ends']).ravel().astype('int64').tolist()
            elif 'tsc' in values:
                t=[int(x) for x in values['tsc']]
                starts=[t[0]|(t[1]<<16)|(t[2]<<32)];ends=[t[3]|(t[4]<<16)|(t[5]<<32)]
            else:starts=ends=None
            row=dict(launch=index,seed=seed,numerical_correct=True,starts=starts,ends=ends,
                     cycles=values.get('cycles_send',values.get('cycles')))
        except Exception as exc:
            row=dict(launch=index,seed=seed,numerical_correct=False,error=repr(exc))
        rows.append(row);print('REPEATED_LAUNCH '+json.dumps(row),flush=True)
finally:
    sdk.SdkRuntime=OriginalRuntime
    if shared.runtime is not None and shared.running:shared.runtime.stop()
same_start=any(a.get('starts') is not None and a.get('starts')==b.get('starts') for a,b in zip(rows,rows[1:]))
first,last=rows[0].get('cycles'),rows[-1].get('cycles')
delta=int(last)-int(first) if first is not None and last is not None else None
summary=dict(schema='xkernel.repeated_launch/1',rows=rows,
             numerical_correct=all(r['numerical_correct'] for r in rows),
             repeated_start_timestamp=same_start,repeat_input_cycle_difference=delta,
             timing_status='repeated_interval_consistent' if delta==0 else 'changed_interval_on_identical_input',
             note='Equal timestamps alone do not prove stale state: enabling the counter can reset its clock. Cross-PE clock alignment remains a separate audit.')
with open('repeated_launch.json','w') as f:json.dump(summary,f,indent=2)
print('REPEATED_LAUNCH_SUMMARY '+json.dumps(summary),flush=True)
if not summary['numerical_correct']:raise SystemExit(1)
