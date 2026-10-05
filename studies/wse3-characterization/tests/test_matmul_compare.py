import collections,hashlib,json,struct,unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
class MatmulComparisonTests(unittest.TestCase):
 @classmethod
 def setUpClass(cls):cls.bundle=json.loads((ROOT/'viewer/public/matmul-bundle.json').read_text())
 def test_exact_outputs_and_repeated_measurements(self):
  self.assertEqual([c['n'] for c in self.bundle['cases']],[4,8,32])
  for c in self.bundle['cases']:
   A,B=c['inputs']['A'],c['inputs']['B'];n=c['n'];ref=[[sum(A[i][k]*B[k][j] for k in range(n)) for j in range(n)] for i in range(n)]
   self.assertEqual(c['reference'],ref)
   self.assertEqual(hashlib.sha256((ROOT/c['source']).read_bytes()).hexdigest(),c['sha256'])
   for v in c['variants']:
    self.assertEqual(len(v['cycles']),3);self.assertTrue(all(cyc>0 for cyc in v['cycles']))
    self.assertEqual(v['passed'],v['name']!='ijk_bad')
    self.assertEqual(v['output'],ref if v['passed'] else [[A[i][-1]*B[-1][j] for j in range(n)] for i in range(n)])
 def test_step_coverage_and_all_intermediate_arithmetic(self):
  for c in self.bundle['cases']:
   if c['n']>8:continue
   n=c['n']
   for v in c['variants']:
    covered=[];state=[[0]*n for _ in range(n)]
    for st in v['steps']:
     self.assertEqual(st['before'],state)
     for u in st['updates']:
      self.assertEqual(u['a'],c['inputs']['A'][u['i']][u['k']]);self.assertEqual(u['b'],c['inputs']['B'][u['k']][u['j']])
      self.assertEqual(u['product'],u['a']*u['b'])
      self.assertEqual(u['value'],u['product'] if st['op']=='FMULH' else u['old']+u['product'])
      if st['op']!='FMULH':
       covered.append((u['i'],u['j'],u['k']))
       self.assertEqual(u['old'],0 if v['name']=='ijk_bad' else state[u['i']][u['j']]);state[u['i']][u['j']]=u['value']
     self.assertEqual(st['after'],state)
    self.assertCountEqual(covered,[(i,j,k) for i in range(n) for j in range(n) for k in range(n)])
    self.assertEqual(state,v['output'])
 def test_bound_trace_values_and_cycle_order(self):
  count=0
  decode=lambda b:struct.unpack('<e',int(b&65535).to_bytes(2,'little'))[0]
  for c in self.bundle['cases']:
   for v in c['variants']:
    for st in v.get('steps',[]):
     if v['name']=='ijk_scalar':self.assertNotIn('trace',st);continue
     tr=st['trace'];self.assertEqual(tr['op'],st['op']);self.assertEqual(tr['length'],len(st['updates']))
     for u,r in zip(st['updates'],sorted(tr['records'],key=lambda r:r['element'])):
      count+=1;self.assertGreaterEqual(r['cycle'],tr['cycle']);self.assertEqual(decode(r['dest']),u['value'])
      if st['op']=='FMACH':
       self.assertEqual(decode(r['src0']),u['old']);self.assertEqual(decode(r['src1'])*decode(r['src2']),u['product'])
      elif st['op']=='FMULH':self.assertEqual(decode(r['src0'])*decode(r['src1']),u['product'])
      else:self.assertEqual(decode(r['src0']),u['old']);self.assertEqual(decode(r['src1']),u['product'])
  self.assertEqual(count,8640)
 def test_transpose_and_packed_tile_layouts(self):
  for c in self.bundle['cases']:
   n,t=c['n'],c['tile'];B=c['inputs']['B']
   self.assertEqual(c['inputs']['Bt'],[[B[k][j] for k in range(n)] for j in range(n)])
   self.assertEqual(c['inputs']['Bp'],[B[k][j] for jb in range(0,n,t) for k in range(n) for j in range(jb,jb+t)])
if __name__=='__main__':unittest.main()
