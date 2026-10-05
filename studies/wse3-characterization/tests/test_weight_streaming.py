import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class WeightStreamingTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.bundle = json.loads((ROOT/'viewer/public/matmul-bundle.json').read_text())
        cls.model = cls.bundle['hardware_dataflow']

    def test_placement_and_reference_are_bound_to_capture(self):
        m = self.model
        g = next(s for s in self.bundle['mesh_scenes'] if s['id']=='g1')
        self.assertEqual(m['X'], g['host']['inputs'][0]['values'])
        self.assertEqual(m['W'], list(map(list, zip(*g['host']['inputs'][1]['values']))))
        cells = []
        for pe in m['pes']:
            for i,b in enumerate(pe['samples']):
                for j,k in enumerate(pe['features']):
                    cells.append((b,k))
                    self.assertEqual(pe['activation'][i][j],m['X'][b][k])
        self.assertCountEqual(cells,[(b,k) for b in range(4) for k in range(4)])
        reference = [[sum(m['X'][b][k]*m['W'][o][k] for k in range(4)) for o in range(4)] for b in range(4)]
        self.assertEqual(reference,g['host']['output'])
        self.assertEqual(m['steps'][-1]['output'],reference)

    def test_each_nonzero_contribution_and_partial_is_correct(self):
        m=self.model
        running={p['id']:[0,0] for p in m['pes']}
        coverage=[]
        broadcasts=[]
        skipped=[]
        for s in m['steps']:
            self.assertIsNone(s['cycle'])
            if s['phase']=='reset':
                running={p['id']:[0,0] for p in m['pes']}
            if s['phase']=='skip':
                skipped.append((s['o'],s['k']))
                self.assertEqual(m['W'][s['o']][s['k']],0)
                self.assertEqual(s['flows'],[])
                self.assertEqual(s['calculations'],[])
            if s['phase']=='broadcast':
                broadcasts.append((s['o'],s['k']))
                x=s['k']//2
                self.assertEqual([(f['source'],f['destination']) for f in s['flows']], [('MemoryX',f'{x},0'),(f'{x},0',f'{x},1')])
                self.assertTrue(all(f['values']==[m['W'][s['o']][s['k']]] for f in s['flows']))
            for c in s['calculations']:
                pe=next(p for p in m['pes'] if p['id']==c['pe'])
                self.assertIn(s['k'],pe['features'])
                self.assertEqual(c['before'],running[c['pe']])
                self.assertEqual(c['activation'],[m['X'][b][s['k']] for b in pe['samples']])
                for i,b in enumerate(pe['samples']):
                    product=m['X'][b][s['k']]*m['W'][s['o']][s['k']]
                    self.assertEqual(c['products'][i],product)
                    running[c['pe']][i]+=product
                    coverage.append((b,s['o'],s['k']))
                self.assertEqual(c['after'],running[c['pe']])
            self.assertEqual(s['partial'],running)
        self.assertCountEqual(coverage,[(b,o,k) for b in range(4) for o in range(4) for k in range(4) if m['W'][o][k]!=0])
        self.assertCountEqual(broadcasts,[(o,k) for o in range(4) for k in range(4) if m['W'][o][k]!=0])
        self.assertCountEqual(skipped,[(o,k) for o in range(4) for k in range(4) if m['W'][o][k]==0])

    def test_row_reduction_and_output_ownership(self):
        m=self.model
        writes=[]
        previous=[[None]*4 for _ in range(4)]
        for s in m['steps']:
            if s['phase']=='reduce':
                self.assertEqual(len(s['flows']),2)
                for f in s['flows']:
                    sx,sy=map(int,f['source'].split(','));dx,dy=map(int,f['destination'].split(','))
                    self.assertEqual(sy,dy);self.assertNotEqual(sx,dx);self.assertEqual(dx,s['o']//2)
                    self.assertEqual(f['values'],s['partial'][f['source']])
                    self.assertEqual(f['local'],s['partial'][f['destination']])
                    expected=[sum(m['X'][b][k]*m['W'][s['o']][k] for k in range(4)) for b in range(dy*2,dy*2+2)]
                    self.assertEqual(f['result'],expected)
                    self.assertEqual(s['reduced'][f['destination']],expected)
            for b in range(4):
                for o in range(4):
                    if previous[b][o]!=s['output'][b][o]:
                        self.assertEqual(s['phase'],'store')
                        self.assertEqual(o,s['o']);self.assertEqual(s['owner'],o//2)
                        self.assertEqual(s['output'][b][o],m['reference'][b][o])
                        writes.append((b,o))
            previous=s['output']
        self.assertCountEqual(writes,[(b,o) for b in range(4) for o in range(4)])


if __name__ == '__main__':
    unittest.main()
