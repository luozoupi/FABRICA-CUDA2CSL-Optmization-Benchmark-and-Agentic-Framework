"""Finish registered groups serially so simulator lock waiters do not starve."""
import json,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent
for group in ('general','model','final','traces'):
 if group=='traces':subprocess.run([sys.executable,str(ROOT/'prepare_traces.py')],check=True)
 cmd=[sys.executable,'-u',str(ROOT/'run_sdk.py'),'--group',group]
 if group=='traces':cmd.append('--trace')
 subprocess.run(cmd,check=True)
 results=json.loads((ROOT/(group+'-progress.json')).read_text())
 assert results,group
 if group=='final':
  assert all(r['status']=='pass' or (r['case']=='nested' and any(p['returncode']==124 for p in r['phases']) and (ROOT/'final/nested/partial-observations.json').exists()) for r in results),group+' has non-watchdog failures'
 else:assert all(r['status']=='pass' for r in results),group+' has retained failures; inspect before proceeding'
subprocess.run([sys.executable,'-u',str(ROOT/'audit_traces.py'),'--trace-library','/home/USER/xkernel-profiling-review-20260924/studies/wse3-characterization'],check=True)
subprocess.run([sys.executable,str(ROOT/'summarize.py')],check=True)
