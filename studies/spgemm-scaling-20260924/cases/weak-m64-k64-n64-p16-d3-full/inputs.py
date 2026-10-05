"""Deterministic sparse inputs, a separate sparse oracle, and row assignment."""
import hashlib,random,time,json
import numpy as np

def digest(a):return hashlib.sha256(np.ascontiguousarray(a).tobytes()).hexdigest()
def problem(m,k,n,degree,pattern,changed=False):
 def entries(rows,cols,which):
  result=[]
  for i in range(rows):
   d=min(degree,cols)
   if pattern=='skewed' and which==0:
    d=min(17 if i<max(1,rows//8) else 0 if i<rows//2 else 2,cols)
   if pattern=='banded': ix=sorted({(i+t)%cols for t in range(d)})
   else:
    rng=random.Random(90210+which*100000+i*31+cols*7)
    ix=sorted(rng.sample(range(cols),d))
   if changed:ix=sorted((j+1)%cols for j in ix)
   result.append([(j,float(((-1 if (i+j+which)%3==0 else 1)*(1+(i*3+j*2+which)%3))*(-1 if changed else 1))) for j in ix])
  return result
 return entries(m,k,0),entries(k,n,1)
def matrix_hash(rows,cols):
 return hashlib.sha256(json.dumps(dict(shape=[len(rows),cols],rows=rows),separators=(",", ":")).encode()).hexdigest()

def product_counts(a,b):
 return [sum(len(b[k])for k,v in row)for row in a]

def oracle(a,b):
 # Independent dictionary accumulation with Python FP64 arithmetic; structural zeros retained.
 out=[];products=[]
 for row in a:
  values={};p=0
  for k,av in row:
   for j,bv in b[k]:values[j]=values.get(j,0.)+av*bv;p+=1
  out.append(sorted(values.items()));products.append(p)
 return out,products

def assign(rows,products,pes,policy):
 cap=(len(rows)+pes-1)//pes
 if policy=='row_blocks':return [list(range(p*cap,min((p+1)*cap,len(rows)))) for p in range(pes)]
 groups=[[]for _ in range(pes)];loads=[0]*pes
 for i in sorted(range(len(rows)),key=lambda i:(-products[i],i)):
  p=min((p for p in range(pes) if len(groups[p])<cap),key=lambda p:(loads[p],len(groups[p]),p))
  groups[p].append(i);loads[p]+=products[i]
 return [sorted(g)for g in groups]

def pack_csr(rows,capacity):
 ptr=[0];idx=[];values=[]
 for row in rows:
  idx.extend(j for j,v in row);values.extend(v for j,v in row);ptr.append(len(idx))
 assert len(idx)<=capacity and max(ptr)<65536 and max(idx,default=0)<65536
 return np.array(ptr,np.uint32),np.array(idx,np.uint32),np.array(values,np.float32)

def packed(c,pattern,policy,changed):
 m,k,n,p=c['M'],c['K'],c['N'],c['P'];R,AC,BC,OC=(c[x]for x in ('R','AC','BC','OC'))
 start=time.perf_counter();a,b=problem(m,k,n,c['degree'],pattern,changed);generated=time.perf_counter()-start
 start=time.perf_counter();products=product_counts(a,b);groups=assign(a,products,p,policy);partition_s=time.perf_counter()-start
 start=time.perf_counter();expected,oracle_products=oracle(a,b);oracle_s=time.perf_counter()-start
 assert products==oracle_products
 start=time.perf_counter()
 aa=np.zeros((p,R+1+2*AC),np.uint32)
 for pe,rows in enumerate(groups):
  ptr,idx,val=pack_csr([a[i]for i in rows],AC)
  aa[pe,:len(ptr)]=ptr;aa[pe,len(ptr):R+1]=ptr[-1]
  aa[pe,R+1:R+1+len(idx)]=idx;aa[pe,R+1+AC:R+1+AC+len(val)]=val.view(np.uint32)
 ptr,idx,val=pack_csr(b,BC);bb=np.zeros(k+2+2*BC,np.uint32)
 bb[0]=len(idx);bb[1:k+2]=ptr;bb[k+2:k+2+len(idx)]=idx;bb[k+2+len(idx):k+2+2*len(idx)]=val.view(np.uint32)
 return dict(aa=aa,bb=bb,bwords=k+2+2*len(idx),groups=groups,expected=expected,products=products,
  counts=[sum(products[i]for i in g)for g in groups],outputs=[sum(len(expected[i])for i in g)for g in groups],
  input_hashes=dict(A=digest(aa),B=digest(bb)),matrix_hashes=dict(A=matrix_hash(a,k),B=matrix_hash(b,n)),a=a,b=b,host_costs=dict(input_generation_s=generated,partition_s=partition_s,oracle_s=oracle_s,packing_s=time.perf_counter()-start))
