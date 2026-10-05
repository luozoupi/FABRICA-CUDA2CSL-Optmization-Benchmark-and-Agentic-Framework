"""Cross-check the independent sparse oracle and allocation bounds before SDK sweeps."""
import json
from pathlib import Path
import numpy as np
from inputs import problem,oracle,product_counts,assign
checks=[]
for n in (16,64,256):
 for degree in (3,8):
  for pattern in ('banded','uniform','skewed'):
   for changed in (False,True):
    a,b=problem(n,n,n,degree,pattern,changed);out,products=oracle(a,b)
    assert products==product_counts(a,b)
    A=np.zeros((n,n),np.float64);B=A.copy();C=A.copy();present=np.zeros((n,n),bool)
    for matrix,rows in ((A,a),(B,b),(C,out)):
     for i,row in enumerate(rows):
      for j,v in row:matrix[i,j]=v
    for i,row in enumerate(out):
     for j,v in row:present[i,j]=True
    np.testing.assert_array_equal(C,A@B)
    np.testing.assert_array_equal(present,(A!=0).astype(np.int32)@(B!=0).astype(np.int32)>0)
    for p in (1,4,16,64):
     if p>n:continue
     for policy in ('row_blocks','product_balanced'):
      groups=assign(a,products,p,policy)
      assert sorted(i for g in groups for i in g)==list(range(n))
      assert max(map(len,groups))<=(n+p-1)//p
      for g in groups:assert sum(len(out[i])for i in g)<=sum(min(n,products[i])for i in g)
    checks.append(dict(N=n,degree=degree,pattern=pattern,changed=changed,products=sum(products),output_nnz=sum(map(len,out)),cancellation=sum(v==0 for row in out for j,v in row)))
Path('oracle-checks.json').write_text(json.dumps(dict(passed=True,cases=checks),indent=2)+'\n')
print('PASS',len(checks),'independent numerical/structural oracle cases and both partition/allocation checks')
