import hashlib,json,os,shutil,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def main():
    if (ROOT/'packaging-manifest.json').exists():
        raise RuntimeError('Preserve the recorded study: use prepare_replay.py in a new directory')
    provenance=json.loads((ROOT/'vendor/ge-spmm/source.json').read_text())
    src=ROOT/'vendor/ge-spmm/spmm_test.cu';text=src.read_text();body=text[text.index('template<typename T>'):text.index('int main(')]
    for name,expected in provenance['sha256'].items():
        if sha(src.parent/name)!=expected:raise RuntimeError('GE source hash mismatch: '+name)
    (ROOT/'ge_kernels.cuh').write_text('// Extracted without modifications from vendor/ge-spmm/spmm_test.cu.\n// MIT License, Copyright (c) 2020 Guyue Huang. See vendor/ge-spmm/LICENSE.\n'+body)
    command=[os.environ.get('NVCC') or shutil.which('nvcc') or '/usr/local/cuda/bin/nvcc','-O3','-arch=sm_120','-std=c++17','--default-stream','per-thread','-lineinfo','--ptxas-options=-v',str(ROOT/'gpu.cu'),'-lcusparse','-o',str(ROOT/'gpu-bench')]
    p=subprocess.run(command,capture_output=True,text=True);(ROOT/'compile.log').write_text(p.stdout+p.stderr)
    meta=dict(command=command,returncode=p.returncode,ge_commit=provenance['commit'],extraction='Exact text from first template<typename T> through before int main; kernel bodies and spmmWrapper unchanged',hashes={f:sha(ROOT/f)for f in ('gpu.cu','ge_kernels.cuh','vendor/ge-spmm/spmm_test.cu','vendor/ge-spmm/LICENSE')})
    if p.returncode==0:meta['hashes']['gpu-bench']=sha(ROOT/'gpu-bench')
    (ROOT/'gpu-build.json').write_text(json.dumps(meta,indent=2)+'\n');print(p.stdout+p.stderr);raise SystemExit(p.returncode)
if __name__=='__main__':main()
