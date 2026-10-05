"""Resume the authorized frozen batch with a supervisor independent of the chat turn."""
import datetime,json,os,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent
state=dict(pid=os.getpid(),started_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),status='running')
def save(**fields):
 state.update(fields);p=ROOT/'supervisor-state.json';tmp=p.with_suffix('.tmp');tmp.write_text(json.dumps(state,indent=2)+'\n');tmp.replace(p)
commands=[['python3','run.py'],['python3','after_sweep.py'],['python3','local_work_model.py'],['python3','model_report.py'],['python3','report.py'],['python3','write_handoff.py']]
try:
 for command in commands:
  save(command=command);print('RUN',command,flush=True);subprocess.run(command,cwd=ROOT,check=True)
 save(status='awaiting_final_evidence_review',finished_utc=datetime.datetime.now(datetime.timezone.utc).isoformat())
 print('All registered attempts and queued audits ended. Final evidence review and publication remain.',flush=True)
except BaseException as exc:
 save(status='supervisor_failed',error=repr(exc));raise
