import copy
import json
import unittest
from pathlib import Path
from wse3study.time_slices import gemm,gemv,add_input_evidence

ROOT=Path(__file__).resolve().parents[1]


class InputTiles(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.gp=ROOT/'viewer/public/bundle.json';cls.vp=ROOT/'viewer/public/gemv-bundle.json'
        cls.gs=json.loads(cls.gp.read_text())['scenes'][1];cls.vs=json.loads(cls.vp.read_text())['scenes'][1]
        cls.hop=next(s for s in json.loads((ROOT/'results/pe-hops/hops.json').read_text())['scenes'] if s['id']=='g1')

    def test_gemv_replication_and_global_coordinates(self):
        s=add_input_evidence(gemv(self.vs,self.vp),self.vs)
        a=next(p for p in s['pes'] if p['id']=='0,1')['input_tiles']
        b=next(p for p in s['pes'] if p['id']=='1,1')['input_tiles']
        self.assertEqual(a[0]['values'],[-1,3]);self.assertEqual(a[0]['values'],b[0]['values'])
        self.assertEqual(a[0]['cols'],[2,3]);self.assertEqual(a[1]['rows'],[2,3]);self.assertEqual(a[1]['cols'],[0,1])
        self.assertEqual(a[1]['values'],[9,10,13,14]);self.assertEqual(b[1]['values'],[11,12,15,16])

    def test_gemm_fixed_storage_is_distinct_from_later_round_panel(self):
        s=add_input_evidence(gemm(self.gs,self.gp),self.gs,self.hop)
        a=s['pes'][0]['input_tiles'][0]
        self.assertEqual(a['values'],[1,2,5,6]);self.assertEqual(a['packed'],[1,5,2,6])
        p=next(p for p in s['input_panels'] if p['pe']=='0,0' and p['round']==1 and p['tensor']=='A')
        self.assertEqual((p['storage'],p['source'],p['values']),('abuf','1,0',[3,4,7,8]))
        self.assertEqual(len(s['input_receipts']),32)
        r=[e for e in s['input_receipts'] if e['pe']=='0,0' and e['tensor']=='A']
        self.assertEqual([e['index'] for e in r],[0,2,1,3])
        self.assertEqual([e['value'] for e in r],[3,7,4,8])

    def test_changed_readback_or_hop_word_is_rejected(self):
        v=copy.deepcopy(self.vs);v['pes'][0]['observed']['X'][0]=999
        with self.assertRaisesRegex(ValueError,'Input readback'):add_input_evidence(gemv(v,self.vp),v)
        g=copy.deepcopy(self.gs);g['panels'][0]['observed'][0]=999
        with self.assertRaisesRegex(ValueError,'input tile'):add_input_evidence(gemm(g,self.gp),g)
        h=copy.deepcopy(self.hop);h['messages'][0]['terms'][0]['packet']['word']=0
        with self.assertRaisesRegex(ValueError,'Hop input'):add_input_evidence(gemm(self.gs,self.gp),self.gs,h)


if __name__=='__main__':unittest.main()
