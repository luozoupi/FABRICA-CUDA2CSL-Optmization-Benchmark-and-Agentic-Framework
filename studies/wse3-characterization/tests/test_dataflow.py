import importlib.util
import json
from pathlib import Path
import struct
import unittest

ROOT=Path(__file__).resolve().parents[1]
def module(name):
    spec=importlib.util.spec_from_file_location(name,ROOT/'tools'/f'{name}.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
bundle_module=module('dataflow_bundle');server=module('dataflow_server');snapshots=module('snapshot_summary')

class DataflowEvidenceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):cls.bundle=bundle_module.build()
    def test_all_outputs_against_independent_integer_arithmetic(self):
        for scene in self.bundle['scenes']:
            inputs={t['name']:t['values'] for t in scene['host']['inputs']};n=scene['n']
            if scene['kind']=='gemm':expected=[[sum(inputs['A'][i][k]*inputs['B'][k][j] for k in range(n)) for j in range(n)] for i in range(n)]
            else:expected=[[sum(inputs['X'][0][k]*inputs['W'][k][j] for k in range(n)) for j in range(n)]]
            self.assertEqual(scene['host']['output'],expected,scene['id'])
            state=server.frame_at(scene,scene['end'])['pes']
            for pe in scene['pes']:
                observed=state[pe['id']]['result' if scene['kind']=='gemv' else 'partial']
                self.assertEqual(observed,pe['final_expected'],(scene['id'],pe['id']))
    def test_input_ownership_and_packet_words(self):
        count=0
        for scene in self.bundle['scenes']:
            inputs={t['name']:t['values'] for t in scene['host']['inputs']}
            for pe in scene['pes']:
                for tile in pe['input_tiles']:
                    expected=[inputs[tile['tensor']][i][j] for i in tile['rows'] for j in tile['cols']]
                    self.assertEqual(tile['values'],expected)
            for packet in scene['packets']:
                self.assertEqual(struct.unpack('<f',struct.pack('<I',packet['word']))[0],packet['value'])
                self.assertEqual(packet['observations'][0]['pe'],packet['source'])
                self.assertEqual(packet['observations'][-1]['pe'],packet['destination']);count+=1
        self.assertEqual(count,184)
    def test_snapshot_independent_reader_agreement_and_known_results(self):
        summary=snapshots.build(ROOT/'results/snapshots/try-20260918b')
        self.assertFalse(summary['cycle_exact'])
        self.assertEqual(len(summary['cases']),3)
        case=summary['cases'][0]
        self.assertEqual(case['phases']['loaded']['values']['C@0,0'],[0,0,43981,48350])
        self.assertEqual(case['phases']['computed']['values']['C@0,0'],[12,42,43981,48350])
        relay=summary['cases'][1]
        self.assertEqual(relay['phases']['computed']['values']['res@1,0'],[41])
    def test_lineage_contains_each_gemv_reduction(self):
        for scene in self.bundle['scenes']:
            if scene['kind']!='gemv' or scene['p']==1:continue
            for j in range(scene['n']):
                reductions=[e for e in server.lineage(scene,j)['events'] if e['kind']=='reduce']
                self.assertEqual(len(reductions),1)
                self.assertEqual(reductions[0]['value'],scene['host']['output'][0][j])
    def test_teaching_steps_cover_each_captured_operation_once(self):
        for s in self.bundle['scenes']:
            ids=[];n=s['n'];t=s['t'];gemm=s['kind']=='gemm'
            inputs={a['name']:a['values'] for a in s['host']['inputs']}
            for st in s['teaching']['steps']:
                for c in st.get('calculations',[]):
                    pe=next(p for p in s['pes'] if p['id']==c['pe']);k=c['k']
                    for q,value in enumerate(c['after']):
                        i=pe['y']*t+q//t;j=pe['x']*t+q%t
                        expected=sum(inputs['A'][i][kk]*inputs['B'][kk][j] for kk in range(k+1)) if gemm else sum(inputs['X'][0][kk]*inputs['W'][kk][j] for kk in range(pe['y']*t,k+1))
                        self.assertEqual(value,expected,(s['id'],st['id'],c['pe'],q))
                    ids.extend(c['mul_ids']);ids.extend(c['add_ids'])
            expected_ids=[e['id'] for e in s['events'] if e['kind'] in ('multiply','accumulate')]
            self.assertCountEqual(ids,expected_ids,s['id']);self.assertEqual(len(set(ids)),len(ids))
            self.assertEqual(s['teaching']['checked_operations'],n**(3 if gemm else 2))
    def test_teaching_panel_routes_match_packed_values_and_cover_packets(self):
        for s in self.bundle['scenes']:
            used=[]
            for st in s['teaching']['steps']:
                for flow in st.get('flows',[]):
                    packets=[next(q for q in s['packets'] if q['id']==pid) for pid in flow['packet_ids']]
                    used.extend(flow['packet_ids'])
                    self.assertTrue(all(q['source']==flow['source'] and q['destination']==flow['destination'] for q in packets))
                    if st['phase']=='panel':
                        panel=next(t for t in s['input_panels'] if t['pe']==flow['destination'] and t['round']==st['round'] and t['tensor']==st['tensor'])
                        self.assertEqual(flow['values'],panel['packed'])
                        self.assertEqual(flow['source'],panel['source'])
            self.assertCountEqual(used,[q['id'] for q in s['packets']],s['id'])
    def test_teaching_gather_covers_output_once_and_reproduces_readback(self):
        for s in self.bundle['scenes']:
            seen=set();result=[[None for v in r] for r in s['host']['output']]
            teaching=s['teaching']
            for tile in teaching['output_tiles']:
                for q,(i,j) in enumerate((i,j) for i in tile['rows'] for j in tile['cols']):
                    self.assertNotIn((i,j),seen);seen.add((i,j));result[i][j]=tile['values'][q]
            self.assertEqual(result,s['host']['output'])
            final=teaching['steps'][-1]
            self.assertEqual(set(final['resident']),{t['id'] for t in teaching['tiles']})
            for pe in s['pes']:self.assertEqual(final['state'][pe['id']]['result'],pe['final_readback'])

if __name__=='__main__':unittest.main()
