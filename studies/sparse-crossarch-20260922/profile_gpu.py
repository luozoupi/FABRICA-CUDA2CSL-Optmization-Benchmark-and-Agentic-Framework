"""Profile exact benchmark executable; profiler timings do not enter results."""
import hashlib,json,os,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parent
env=dict(os.environ,CUDA_VISIBLE_DEVICES='6')
def command(case,method,d):
    c=next(c for file in ('manifest.json','capacity-manifest.json')for c in json.loads((ROOT/'inputs'/file).read_text())['cases']if c['id']==case)
    return [str(ROOT/'gpu-bench'),str(ROOT/c['matrix_path']),str(ROOT/c['dense_path']),*[str(c[k])for k in ('M','K','N','nnz')],str(int(c['synthetic'])),str(d),method]
def main():
    out=ROOT/'profiling';out.mkdir(exist_ok=True);results=[]
    for case,method in [('65536x65536-uniform8-n64','ge_plain'),('65536x65536-uniform8-n64','ge_cache'),('65536x65536-uniform8-n64','ge_merge2'),('262144x262144-uniform8-n128','ge_merge2'),('262144x262144-block8-n128','ge_merge2')]:
        d=out/(case+'-'+method);d.mkdir(exist_ok=True)
        cmd=['/usr/local/cuda/bin/ncu','--target-processes','all','--cache-control','none','--clock-control','none','--launch-skip','1','--launch-count','1','--metrics','gpu__time_duration.sum,dram__bytes_read.sum,dram__bytes_write.sum,lts__t_bytes.sum,sm__throughput.avg.pct_of_peak_sustained_elapsed,dram__throughput.avg.pct_of_peak_sustained_elapsed','--csv','--log-file',str(d/'counters.csv'),'-o',str(d/'report')]+command(case,method,d)
        p=subprocess.run(cmd,env=env,capture_output=True,text=True,timeout=240);(d/'stdout.log').write_text(p.stdout);(d/'stderr.log').write_text(p.stderr)
        results.append(dict(case=case,method=method,command=cmd,rc=p.returncode));print(case,method,p.returncode,flush=True)
        content=(d/'counters.csv').read_text()if(d/'counters.csv').exists()else p.stderr
        if 'ERR_NVGPUCTRPERM' in content or 'ERR_NVGPUCTRPERM' in p.stdout+p.stderr:break
    d=out/'sanitizer';d.mkdir(exist_ok=True)
    for method in ('ge_cache','ge_merge2','ge_merge4'):
        cmd=['/usr/local/cuda/bin/compute-sanitizer','--tool','memcheck','--error-exitcode','99','--launch-count','1','--log-file',str(d/(method+'.log'))]+command('32x64-skew8-n4',method,d)
        p=subprocess.run(cmd,env=env,capture_output=True,text=True,timeout=120);(d/(method+'-stdout.log')).write_text(p.stdout+p.stderr);results.append(dict(check='memcheck',method=method,command=cmd,rc=p.returncode));print('memcheck',method,p.returncode,flush=True)
    (out/'manifest.json').write_text(json.dumps(dict(binary_sha256=hashlib.sha256((ROOT/'gpu-bench').read_bytes()).hexdigest(),results=results),indent=2)+'\n')
if __name__=='__main__':main()
