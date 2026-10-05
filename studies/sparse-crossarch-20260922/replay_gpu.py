"""Registered stability check: two further full replays of seven selected cases."""
import json,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent
cases=['65536x65536-'+f+'-n64'for f in ('uniform8','block8','skew8')]+['262144x262144-'+f+'-n'+str(n)for f in ('uniform8','block8')for n in (64,128)]
registration=ROOT/'replay-registration.json'
if not registration.exists():registration.write_text(json.dumps(dict(cases=cases,additional_repetitions=2,reason='Check whether the observed structure-dependent ranking survives independent process launches and uncontrolled clock variation; selected all four capacity extension cases, plus three degree-matched smaller controls.',selection='after initial results; confirmatory replay, not independent final-test data'),indent=2)+'\n')
for rep in (1,2):
    for case in cases:
        cmd=[sys.executable,str(ROOT/'run_gpu.py'),'--only',case,'--out',f'gpu-replay{rep}']
        if case.startswith('262144'):cmd+=['--manifest','inputs/capacity-manifest.json']
        subprocess.run(cmd,check=True)
