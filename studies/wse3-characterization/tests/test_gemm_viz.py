"""Numerical and evidence-contract tests; no SDK or browser required."""
import copy
import json
from pathlib import Path
import tempfile
import unittest

from wse3study.gemm_viz import bind_readback, checked_manifest, f32bits, reference, sha256, tick


def capture_fixture(case):
    """Independent loop implementation of the host's PE readback layout."""
    s=reference(case);n,p,t=s['n'],s['p'],s['t'];a,b=s['a'],s['b']
    cap={'case':case,'n':n,'p':p,'history':True,'evidence':'simulator',
         'a_bits':[f32bits(v) for row in a for v in row],
         'b_bits':[f32bits(v) for row in b for v in row],'pes':[]}
    for y in range(p):
        for x in range(p):
            row={'x':x,'y':y,'c_bits':[],'time_words':[5,0,0,1000,0,0],
                 **{key:[] for key in ['h_a','h_b','h_old','h_new','h_clock','a_seen','b_seen']}}
            positions=[(ii,jj) for ii in range(t) for jj in range(t)] if p==1 else [(ii,jj) for jj in range(t) for ii in range(t)]
            for ii,jj in positions:
                acc=0
                for k in range(n):
                    av,bv=a[y*t+ii][k],b[k][x*t+jj]
                    for key,value in [('h_a',av),('h_b',bv),('h_old',acc),('h_new',acc+av*bv)]:row[key].append(f32bits(value))
                    acc+=av*bv;row['h_clock'] += [100+k,0,0]
                row['c_bits'].append(f32bits(acc))
            for round_ in range(p):
                for ii,jj in positions:
                    row['a_seen'].append(f32bits(a[y*t+ii][round_*t+jj]))
                    row['b_seen'].append(f32bits(b[round_*t+ii][x*t+jj]))
            cap['pes'].append(row)
    return cap


class GemmVizTests(unittest.TestCase):
    def test_hand_calculated_examples_and_ownership(self):
        s=reference('g1');c=s['cells'][10]
        self.assertEqual([q['acc'] for q in s['cells'][0]['terms']],[1,1,7,11])
        self.assertEqual([q['acc'] for q in c['terms']],[27,47,58,58])
        self.assertEqual(c['pe'],'1,1')
        self.assertEqual(c['terms'][0]['a_origin'],[0,1])
        self.assertEqual(c['terms'][0]['b_origin'],[1,0])
        self.assertEqual(s['cells'][15]['expected'],140)

    def test_layouts_have_equivalent_results_but_different_offsets(self):
        g0,g1=reference('g0'),reference('g1')
        self.assertEqual([c['expected'] for c in g0['cells']],[c['expected'] for c in g1['cells']])
        self.assertEqual(g0['cells'][1]['c_offset_bytes'],4)
        self.assertEqual(g1['cells'][1]['c_offset_bytes'],8)

    def test_all_contributions_and_panel_readbacks(self):
        for case in ['g0','g1','g2']:
            s=reference(case);bind_readback(s,capture_fixture(case))
            self.assertTrue(s['verification']['passed'])
            self.assertEqual(s['verification']['contributions'],s['n']**3)
            self.assertEqual(s['trace'],None)
            self.assertFalse(s['dynamic'])
            self.assertNotIn('multiply_cycle',s['cells'][0]['terms'][0]['observed'])

    def test_bad_history_does_not_pass_even_with_correct_final(self):
        c=capture_fixture('g1');c['pes'][3]['h_old'][1]=f32bits(999)
        s=reference('g1');bind_readback(s,c)
        self.assertFalse(s['verification']['passed'])
        self.assertEqual(s['verification']['mismatches'][0]['kind'],'old')

    def test_wrong_panels_detected(self):
        c=capture_fixture('g2');c['pes'][0]['a_seen'][0]=f32bits(-123)
        s=reference('g2');bind_readback(s,c)
        self.assertEqual(s['verification']['mismatches'][0]['kind'],'panel')

    def test_input_and_duplicate_pe_rejected(self):
        c=capture_fixture('g0');c['a_bits'][0]=0
        with self.assertRaisesRegex(ValueError,'input identity'):bind_readback(reference('g0'),c)
        c=capture_fixture('g1');c['pes'][1]=copy.deepcopy(c['pes'][0])
        with self.assertRaisesRegex(ValueError,'duplicate'):bind_readback(reference('g1'),c)

    def test_48_bit_timer(self):
        self.assertEqual(tick([0xffff,2,3]),(3<<32)+(2<<16)+0xffff)

    def test_manifest_tampering_and_missing_hashes(self):
        with tempfile.TemporaryDirectory() as d:
            root=Path(d);files=['capture.json','placement.json','pe.csl','layout.csl','events.jsonl.gz','simfab_traces/global_simdata.json']
            for f in files:
                p=root/f;p.parent.mkdir(parents=True,exist_ok=True);p.write_text('original')
            manifest={'schema':'gemm-run/1','sha256':{f:sha256(root/f) for f in files}}
            (root/'manifest.json').write_text(json.dumps(manifest));checked_manifest(root)
            (root/'pe.csl').write_text('changed')
            with self.assertRaisesRegex(ValueError,'hash mismatch'):checked_manifest(root)
            manifest['sha256']={};(root/'manifest.json').write_text(json.dumps(manifest))
            with self.assertRaisesRegex(ValueError,'Incomplete'):checked_manifest(root)


if __name__=='__main__':unittest.main()
