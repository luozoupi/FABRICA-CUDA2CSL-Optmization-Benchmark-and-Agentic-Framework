"""Analytical allocation envelope for the same replicated-B row-owner design.
These are declared-array bounds, not compiled or measured additional configurations.
"""
import json
from pathlib import Path
from inputs import assign
ROOT=Path(__file__).resolve().parent;records=[]
for n in (16,64,256,512,1024,2048):
 for p in (1,4,16,64,256):
  if p>n:continue
  R=(n+p-1)//p
  for degree in (3,8):
   patterns=['uniform','skewed']if degree==3 else ['uniform'];AC=OC=0
   for pattern in patterns:
    lengths=[degree]*n
    if pattern=='skewed':lengths=[min(17,n)if i<max(1,n//8)else 0 if i<n//2 else 2 for i in range(n)]
    dummy=[None]*n;products=[l*degree for l in lengths]
    for policy in ('row_blocks','product_balanced'):
     groups=assign(dummy,products,p,policy)
     AC=max(AC,max(sum(lengths[i]for i in g)for g in groups));OC=max(OC,max(sum(min(n,products[i])for i in g)for g in groups))
   BC=n*degree
   for variant,W in [('full',n),('tiled',min(16,n//4))]:
    arrays=4*(R+1+2*AC+n+2+2*BC+R+1+2*(OC+4))+6*W+8+48+24+12
    records.append(dict(N=n,P=p,degree=degree,variant=variant,R=R,AC=AC,BC=BC,OC=OC,accumulator_bytes=6*W,
     B_bytes=4*(n+2+2*BC),declared_application_bytes=arrays,arrays_exceed_48KiB=arrays>49152,
     status='analytical_infeasible_for_this_allocation'if arrays>49152 else 'requires_compilation_and_runtime_validation'))
# Confirm the formula reproduces every corresponding registered allocation exactly.
checked=0
for f in (ROOT/'cases').glob('*/case.json'):
 c=json.loads(f.read_text())
 if c['group']=='weak':continue
 matches=[r for r in records if all(r[k]==c[k]for k in ('N','P','degree','variant'))]
 assert len(matches)==1 and matches[0]['declared_application_bytes']==c['declared_application_bytes'],c['id'];checked+=1
(ROOT/'capacity-envelope.json').write_text(json.dumps(dict(scope='Analytical declared arrays only; compiler/library/code/dynamic stack allocation and execution have not been validated at additional sizes.',registered_allocation_matches=checked,records=records),indent=2)+'\n')
print('Allocation formula matches',checked,'registered cases;',len(records),'analytical points')
