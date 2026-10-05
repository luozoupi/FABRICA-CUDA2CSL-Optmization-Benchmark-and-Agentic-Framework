"""Create fixed size/PE configurations; never overwrite an existing case."""
import argparse,datetime,hashlib,json,math,shutil
from pathlib import Path
from inputs import problem,product_counts,assign,matrix_hash
ROOT=Path(__file__).resolve().parent
BASE='3c7e9f383fa1874f24c633f27d64cf1dadec5346'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def make(m,k,n,p,degree,variant,group,smoke=False):
 identifier=f'{group}-m{m}-k{k}-n{n}-p{p}-d{degree}-{variant}'
 d=ROOT/('development' if smoke else 'cases')/identifier
 if d.exists():raise RuntimeError('Existing case: '+str(d))
 s=math.isqrt(p);assert s*s==p
 R=(m+p-1)//p;W=n if variant=='full' else min(16,n//4)
 patterns=['uniform'] if group=='weak' or degree==8 else ['banded','uniform','skewed']
 sessions=[]
 for pattern in patterns:
  sessions.append(dict(pattern=pattern,policy='row_blocks',changed=False))
  if pattern=='skewed' and p>1:sessions.append(dict(pattern=pattern,policy='product_balanced',changed=False))
 # Changed sparsity and values, then original values restored, with balanced work for the skewed case.
 if smoke: sessions=[dict(pattern='uniform',policy='row_blocks',changed=False),dict(pattern='skewed',policy='product_balanced',changed=True)]
 else:
  sessions += [dict(pattern=patterns[-1],policy='product_balanced' if p>1 and patterns[-1]=='skewed' else 'row_blocks',changed=x)for x in (True,False)]
 AC=OC=BC=0
 for spec in sessions:
  a,b=problem(m,k,n,degree,spec['pattern'],spec['changed']);products=product_counts(a,b)
  spec['matrix_hashes']=dict(A=matrix_hash(a,k),B=matrix_hash(b,n))
  groups=assign(a,products,p,spec['policy'])
  AC=max(AC,max(sum(len(a[i])for i in g)for g in groups));BC=max(BC,sum(map(len,b)))
  # Conservative candidate-product bound; no symbolic output pattern needed to allocate.
  OC=max(OC,max(sum(min(n,products[i])for i in g)for g in groups))
 AC=max(AC,1);OC=max(OC,1)
 data_bytes=4*(R+1+2*AC + k+2+2*BC + R+1+2*(OC+4))+6*W+8+48+24+12
 cfg=dict(id=identifier,group=group,M=m,K=k,N=n,P=p,S=s,R=R,AC=AC,BC=BC,OC=OC,W=W,degree=degree,variant=variant,
  sessions=sessions,repetitions=1 if smoke else 3,declared_application_bytes=data_bytes,
  allocation_rule='Per-PE max over frozen sessions/partitions of sum(min(N,row candidate products)); input capacities likewise. Includes guard slots. No numerical oracle result used to choose capacity.',
  preflight='application_arrays_exceed_48KiB' if data_bytes>49152 else 'compile_required',source_hashes={})
 d.mkdir(parents=True)
 for src,dst in [('single_collective.csl','single_collective.csl'),('pe.csl.in','pe.csl'),('layout.csl.in','layout.csl'),('host.py','host.py'),('inputs.py','inputs.py')]:shutil.copy2(ROOT/src,d/dst);cfg['source_hashes'][dst]=sha(d/dst)
 if p==1:
  source=(d/'pe.csl').read_text().replace('<collectives_2d/pe>','single_collective.csl');(d/'pe.csl').write_text(source);cfg['source_hashes']['pe.csl']=sha(d/'pe.csl')
 (d/'case.json').write_text(json.dumps(cfg,indent=2)+'\n')
 return cfg

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--smoke',action='store_true');args=ap.parse_args()
 if args.smoke:
  print(make(16,16,16,4,3,'full','strong',True)['id']);return
 if (ROOT/'registration.json').exists():raise RuntimeError('Do not overwrite registration')
 cases=[]
 for n in (16,64,256):
  for p in (1,4,16,64):
   if p>n:continue
   cases.append(make(n,n,n,p,3,'full','strong'))
   if (n==16 and p in (1,4)) or n==64 or (n==256 and p in (4,16,64)):
    cases.append(make(n,n,n,p,3,'tiled','strong'))
 for p in (1,4,16,64):cases.append(make(4*p,64,64,p,3,'full','weak'))
 for p in (1,4,16,64):cases.append(make(64,64,64,p,8,'full','density'))
 registration=dict(created_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),framework_base=BASE,
  origin='NVIDIA GPU node, SDK 2.10.1 simulator, WSE-3; manual reference/control kernels',
  purpose='SpGEMM matrix-size, row-distribution, accumulator and PE strong/weak scaling with actual fabric distribution',
  frozen_cases=[c['id']for c in cases],case_hashes={c['id']:sha(ROOT/'cases'/c['id']/'case.json')for c in cases},
  scope='A output rows distributed by host; B replicated by actual row-then-column broadcast from PE(0,0); output remains distributed CSR. Host packing/H2D/output gather and library init excluded from device interval; measured separately as host costs. No compiler/trace instrumentation inside local kernel.',
  timing='Root same-clock span begins before causal broadcast and ends after column-then-top-row completion reduction; root must receive P unit contributions. Per-PE compute/precompute durations subtract only same-PE timestamps. No cross-PE clock subtraction or overlap-derived percentages.',
  candidate_selection='No optimizer or model; both predetermined implementations retained. Strong scaling fixes both matrix inputs for each size across P. Weak scaling fixes K=N=64, degree=3, four complete output rows per PE; replicated B storage is constant per PE.',
  limits=dict(compile_seconds=600,run_seconds=2400,lock_wait_seconds=600),
  failure_policy='Retain preflight infeasibility, compiler failures, runtime failures, partial checkpoints and timeouts; never interpret a missing point as a performance win.',
  next_scope='64 PEs is the maximum for this bounded SDK sweep. 256 PE and physical WSE replay remain separate future experiments.',
  source_hashes={p.name:sha(p)for p in ROOT.iterdir()if p.is_file()and p.suffix in ('.py','.in','.csl','.md')})
 (ROOT/'registration.json').write_text(json.dumps(registration,indent=2)+'\n')
 print('Frozen',len(cases),'cases;',sum(c['preflight']!='compile_required'for c in cases),'preflight capacity exclusions')
if __name__=='__main__':main()
