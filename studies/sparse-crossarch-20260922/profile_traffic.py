"""Second profiler pass with supported total DRAM byte counter."""
import csv,io,json,os,subprocess
from pathlib import Path
from profile_gpu import ROOT,command
env=dict(os.environ,CUDA_VISIBLE_DEVICES='6',PYTHONNOUSERSITE='1')
rows=[]
for case,method in [('65536x65536-uniform8-n64','ge_plain'),('65536x65536-uniform8-n64','ge_cache'),('65536x65536-uniform8-n64','ge_merge2'),('262144x262144-uniform8-n128','ge_merge2'),('262144x262144-block8-n128','ge_merge2')]:
    d=ROOT/'profiling-traffic'/(case+'-'+method);d.mkdir(parents=True,exist_ok=True)
    metrics='gpu__time_duration.sum,dram__bytes.sum,lts__t_bytes.sum,dram__throughput.avg.pct_of_peak_sustained_elapsed,smsp__inst_executed.sum,l1tex__t_sectors_pipe_lsu_mem_global_op_ld.sum'
    cmd=['/usr/local/cuda/bin/ncu','--cache-control','none','--clock-control','none','--launch-skip','1','--launch-count','1','--metrics',metrics,'--log-file',str(d/'capture.log'),'-o',str(d/'report')]+command(case,method,d)
    p=subprocess.run(cmd,env=env,capture_output=True,text=True,timeout=240);(d/'stdout.log').write_text(p.stdout);(d/'stderr.log').write_text(p.stderr)
    result=dict(case=case,method=method,command=cmd,returncode=p.returncode)
    if (d/'report.ncu-rep').exists():
        q=subprocess.run(['/usr/local/cuda/bin/ncu','--import',str(d/'report.ncu-rep'),'--page','raw','--csv','--print-units','base'],env=env,capture_output=True,text=True)
        (d/'raw.csv').write_text(q.stdout);table=list(csv.DictReader(io.StringIO(q.stdout)));result['metrics']={key:table[1].get(key)for key in metrics.split(',')}
    rows.append(result);print(case,method,result.get('metrics'),flush=True)
(ROOT/'profiling-traffic/summary.json').write_text(json.dumps(rows,indent=2)+'\n')
