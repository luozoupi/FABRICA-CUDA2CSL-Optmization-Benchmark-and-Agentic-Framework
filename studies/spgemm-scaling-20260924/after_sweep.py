"""Run the saved timing audit only after all registered sweep attempts end."""
import json,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parent
registered=json.loads((ROOT/'registration.json').read_text())['frozen_cases']
while not all((ROOT/'cases'/name/'result.json').exists()for name in registered):time.sleep(30)
commands=[['python3','summarize.py','--complete'],['python3','timing_audit.py'],['python3','check_broadcast_model.py'],['python3','check_output_model.py'],['python3','local_work_model.py'],['python3','memory_notes.py'],['python3','report.py'],['python3','write_handoff.py'],['/home/USER/sparse-crossarch-20260922/.plot-venv/bin/python','plot.py'],['python3','explorer.py'],['python3','verify_explorer.py']]
for cmd in commands:
 print('RUN',cmd,flush=True);subprocess.run(cmd,cwd=ROOT,check=True)
print('Post-sweep audit and reporting finished; evidence still requires review before packaging.',flush=True)
