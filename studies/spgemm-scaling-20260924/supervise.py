"""Durable, journaled queue recovery around the unchanged registered SDK runner."""
import datetime,fcntl,hashlib,json,os,subprocess,threading
from pathlib import Path
import run as registered_runner
from queue_retry import run_with_admission_retry
ROOT=Path(__file__).resolve().parent
REVISION='queue-admission-v2'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
now=lambda:datetime.datetime.now(datetime.timezone.utc).isoformat()
def atomic(path,value):
    tmp=path.with_suffix(path.suffix+'.tmp');tmp.write_text(json.dumps(value,indent=2)+'\n');tmp.replace(path)
def main():
    unique=(ROOT/'supervisor.lock').open('a');fcntl.flock(unique,fcntl.LOCK_EX|fcntl.LOCK_NB)
    reg=json.loads((ROOT/'registration.json').read_text());admission=json.loads((ROOT/'queue-recovery-registration.json').read_text())
    for name,h in reg['source_hashes'].items():assert sha(ROOT/name)==h,name
    for name,h in admission['driver_sha256'].items():assert sha(ROOT/name)==h,name
    state=dict(pid=os.getpid(),started_utc=now(),status='starting',execution_protocol_revision=REVISION)
    mutex=threading.Lock();stop=threading.Event();active=[None]
    events_path=ROOT/'admission-events.json';events=json.loads(events_path.read_text())if events_path.exists()else []
    def save(**fields):
        with mutex:state.update(fields,last_updated_utc=now());atomic(ROOT/'supervisor-state.json',state)
    def heartbeat():
        while not stop.wait(15):
            d=active[0]
            if d:
                phase='run'if(d/'run.log').exists()else 'compile'if(d/'compile.log').exists()else 'waiting_for_shared_sdk'
                save(sdk_phase=phase,active_case=d.name)
            else:save()
    def wait_event(event):
        event.update(recorded_utc=now(),execution_protocol_revision=REVISION);events.append(event);atomic(events_path,events)
        print('SDK admission timed out; no SDK phase launched; keeping case queued:',event,flush=True)
        save(status='waiting_for_shared_sdk',queue_timeouts=len(events))
    thread=threading.Thread(target=heartbeat,daemon=True);thread.start()
    try:
        dirs=sorted((ROOT/'cases').iterdir(),key=lambda p:(json.loads((p/'case.json').read_text())['N'],json.loads((p/'case.json').read_text())['P'],p.name))
        for d in dirs:
            if(d/'result.json').exists():continue
            assert not any((d/name).exists()for name in ('compile.log','run.log','out','observations.partial.json','observations.json')),f'Unfinished SDK evidence requires review: {d}'
            c=json.loads((d/'case.json').read_text());assert sha(d/'case.json')==reg['case_hashes'][d.name]
            for name,h in c['source_hashes'].items():assert sha(d/name)==h,name
            active[0]=d;save(status='executing_registered_case',active_case=d.name,sdk_phase='waiting_for_shared_sdk')
            result=run_with_admission_retry(d,registered_runner.run,wait_event,lambda:save(status='executing_registered_case',sdk_phase='waiting_for_shared_sdk'))
            result.update(execution_protocol_revision=REVISION,admission_retry_wait_seconds=sum(e['wait_seconds']for e in events if e['case']==d.name))
            atomic(d/'result.json',result);active[0]=None
            atomic(ROOT/'progress.json',[json.loads((p/'result.json').read_text())for p in dirs if(p/'result.json').exists()])
            save(status='refreshing_results',active_case=None,sdk_phase=None)
            subprocess.run(['python3','summarize.py'],cwd=ROOT,check=True)
        commands=[['python3','after_sweep.py'],['python3','local_work_model.py'],['python3','model_report.py'],['python3','report.py'],['python3','write_handoff.py']]
        for command in commands:
            save(status='postprocessing',command=command,active_case=None,sdk_phase=None);print('RUN',command,flush=True);subprocess.run(command,cwd=ROOT,check=True)
        save(status='awaiting_final_evidence_review',finished_utc=now())
    except BaseException as error:
        save(status='supervisor_failed',error=repr(error));raise
    finally:stop.set();thread.join(timeout=2);unique.close()
if __name__=='__main__':main()
