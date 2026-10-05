#!/usr/bin/env python3
"""SDK simulator host. Writes observations before asserting numerical success."""
import hashlib
import json
from pathlib import Path
import numpy as np
from cerebras.sdk.runtime.sdkruntimepybind import SdkRuntime, MemcpyDataType, MemcpyOrder


def bits(a):
    return np.asarray(a, np.float32).view(np.uint32).ravel().copy()


def main():
    spec = json.loads(Path('case.json').read_text())
    n, p, history = spec['n'], spec['p'], spec['history']
    t = n // p
    A = np.arange(1, n*n+1, dtype=np.float32).reshape(n, n)
    B = np.array([[1,2,3,4],[0,1,2,3],[2,0,1,2],[1,2,0,1]], np.float32) if n == 4 else np.fromfunction(lambda k,j: (3*k+2*j)%5-2, (n,n)).astype(np.float32)
    rt = SdkRuntime('out')
    rt.load(); rt.run()
    rows = []
    U32, U16, RM = MemcpyDataType.MEMCPY_32BIT, MemcpyDataType.MEMCPY_16BIT, MemcpyOrder.ROW_MAJOR
    def read(name, x, y, length, narrow=False):
        dst = np.zeros(length, np.uint32)
        rt.memcpy_d2h(dst, rt.get_id(name), x, y, 1, 1, length, streaming=False,
                      data_type=U16 if narrow else U32, order=RM, nonblock=False)
        return dst.tolist()
    try:
        for y in range(p):
            for x in range(p):
                for name, mat in [('A', A), ('B', B)]:
                    tile = mat[y*t:(y+1)*t, x*t:(x+1)*t]
                    packed = tile.ravel(order='C' if p == 1 else 'F')
                    rt.memcpy_h2d(rt.get_id(name), bits(packed), x, y, 1, 1, t*t,
                                  streaming=False, data_type=U32, order=RM, nonblock=False)
        rt.call('run', [], nonblock=False)
        C = np.zeros((n,n), np.float32)
        for y in range(p):
            for x in range(p):
                row = {'x':x,'y':y,'c_bits':read('C',x,y,t*t), 'time_words':read('time_words',x,y,6,True)}
                c = np.array(row['c_bits'], np.uint32).view(np.float32).reshape((t,t), order='C' if p == 1 else 'F')
                C[y*t:(y+1)*t,x*t:(x+1)*t] = c
                if history:
                    for name in ['h_a','h_b','h_old','h_new']:row[name] = read(name,x,y,t*t*n)
                    for name in ['a_seen','b_seen']:row[name] = read(name,x,y,p*t*t)
                    row['h_clock'] = read('h_clock',x,y,t*t*n*3,True)
                rows.append(row)
    finally:
        rt.stop()
    expected = A @ B
    ok = bool(np.array_equal(C, expected))
    result = {'schema':'gemm-capture/1','evidence':'simulator',**spec,
              'a_bits':bits(A).tolist(),'b_bits':bits(B).tolist(),'pes':rows,
              'output':C.tolist(),'reference':expected.tolist(),'correct':ok,
              'sources':{f:hashlib.sha256(Path(f).read_bytes()).hexdigest() for f in ['pe.csl','layout.csl','run.py','case.json']}}
    Path('capture.json').write_text(json.dumps(result,indent=2))
    print('GEMM',spec['case'],'history',history,'correct',ok,'C',C.tolist(),flush=True)
    np.testing.assert_array_equal(C,expected)


if __name__ == '__main__':main()
