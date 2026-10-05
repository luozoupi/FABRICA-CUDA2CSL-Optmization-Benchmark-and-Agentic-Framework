"""Fixed small integer inputs. Selection and final-test families are separate."""
import numpy as np

def inputs(c,pattern,changed=False):
    m,k,n=c['M'],c['K'],c['N'];ii,kk=np.indices((m,k))
    A=(((ii*2+kk*3+1)%7)-3).astype(np.float32);A[A==0]=1
    mask=np.zeros((m,k),bool)
    if pattern=='empty':pass
    elif pattern=='diagonal':np.fill_diagonal(mask,True)
    elif pattern in ('banded','banded5'):
        width=1 if pattern=='banded' else 2
        for i in range(m):mask[i,[(i+t)%k for t in range(-width,width+1)]]=True
    elif pattern in ('uniform','uniform5'):
        degree=3 if pattern=='uniform' else 5
        for i in range(m):mask[i,[(i*3+t*5)%k for t in range(degree)]]=True
    elif pattern=='skewed':
        for i in range(m):
            count=0 if i%4==1 else k if i%4==0 else 1
            mask[i,[(i*3+t)%k for t in range(count)]]=True
    elif pattern=='blocks4':mask=(ii//4==kk//4)
    elif pattern=='dense':mask[:]=True
    elif pattern=='long_rows':mask[0,:]=True;mask[-1,:]=True
    elif pattern in ('random15','random45'):
        mask=np.random.default_rng(917 if pattern=='random15' else 918).random((m,k)) < (.15 if pattern=='random15' else .45)
    else:raise ValueError(pattern)
    A*=mask;rr,jj=np.indices((k,n));B=(((rr*3+jj*2)%7)-3).astype(np.float32)
    if changed:A=np.roll(A,1,axis=1)*-2;B=np.flip(B,axis=0).copy()+1
    return A,B

def sparse_pair(pattern,changed=False):
    cfg=dict(M=16,K=16,N=16);A,_=inputs(cfg,pattern,False)
    # Different sparse operands; no fixed mask and no requirement that B=A.T.
    B=np.roll(np.flip(A,axis=0),2,axis=1).copy()
    nz=B!=0;B[nz]=((B[nz]*2+1)%7)-3;B[nz&(B==0)]=1
    if changed:A=np.roll(A,1,axis=1)*-2;B=np.roll(B,3,axis=0)*-1
    return A,B

_original_sparse_pair=sparse_pair
def sparse_pair(pattern,changed=False):
    assert not changed
    A,_=_original_sparse_pair('uniform',False)
    seed={'probe928':928,'probe930':930}[pattern]
    rng=np.random.default_rng(seed);B=np.zeros((16,16),np.float32)
    for row in range(16):
        cols=rng.choice(16,3,replace=False)
        B[row,cols]=rng.choice(np.array([-3,-2,-1,1,2,3],np.float32),3)
    return A,B
