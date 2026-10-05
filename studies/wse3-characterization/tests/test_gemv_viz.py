import copy
import unittest

from wse3study.gemm_viz import f32bits
from wse3study.gemv_viz import CASES, PHASES, readback, reference
from wse3study.time_slices import state_at

def fixture(case):
    s=reference(case);n,p,t=s['n'],s['p'],s['t'];x,w=s['x'],s['w']
    c={'case':case,'n':n,'p':p,'history':True,'evidence':'simulator',
       'x_bits':[f32bits(v) for v in x],'w_bits':[f32bits(v) for row in w for v in row],'pes':[]}
    totals=[sum(x[k]*w[k][j] for k in range(n)) for j in range(n)]
    for py in range(p):
        for px in range(p):
            row={'x':px,'y':py,'time_words':[5,0,0,1000,0,0],
                 'W':[f32bits(w[k][j]) for k in range(py*t,(py+1)*t) for j in range(px*t,(px+1)*t)],
                 'X':[f32bits(v) for v in x[py*t:(py+1)*t]],
                 **{k:[] for k in ['partial','peer','result','h_w','h_x','h_old','h_new','h_clock','r_old','r_peer','r_new']}}
            for j in range(px*t,(px+1)*t):
                acc=0
                for k in range(py*t,(py+1)*t):
                    for key,val in [('h_w',w[k][j]),('h_x',x[k]),('h_old',acc),('h_new',acc+x[k]*w[k][j])]:row[key].append(f32bits(val))
                    row['h_clock'] += [100+k,0,0];acc+=x[k]*w[k][j]
                top=sum(x[k]*w[k][j] for k in range(t))
                row['partial'].append(f32bits(acc));row['peer'].append(f32bits(top if p>1 else 0));row['result'].append(f32bits(totals[j]))
                for key,val in [('r_old',acc),('r_peer',top),('r_new',totals[j])]:row[key].append(f32bits(val if p>1 and py==p-1 else 0))
            active=['inputs','local','final']+(['peer'] if p>1 else [])+(['reduced'] if p>1 and py==p-1 else [])
            row['phase_flags']=[i+1 if phase in active else 0 for i,phase in enumerate(PHASES)]
            row['phase_clock']=[v for i in range(5) for v in [100+i*50,0,0]];c['pes'].append(row)
    return c

class GemvTests(unittest.TestCase):
    def test_hand_worked_partition_and_reduction(self):
        s=reference('v1');o=s['outputs'][0]
        self.assertEqual([v['expected'] for v in s['outputs']],[41,46,51,56])
        self.assertEqual(o['parts'],[11,30])
        self.assertEqual([q['acc'] for q in o['terms']],[1,11,-9,30])
        self.assertEqual(o['root'],'0,1');self.assertEqual(o['replicas'],['0,0','0,1'])
        self.assertEqual(o['terms'][2]['pe'],'0,1')

    def test_eight_input_case(self):
        self.assertEqual([o['expected'] for o in reference('v2')['outputs']],[158,164,170,176,182,188,194,200])

    def test_all_history_and_control_readbacks(self):
        for case in CASES:
            s=reference(case);c=fixture(case)
            self.assertTrue(readback(s,c)['passed'])
            self.assertFalse(s['dynamic'])
            self.assertNotIn('multiply_cycle',s['outputs'][0]['terms'][0]['observed'])
            c['history']=False
            self.assertTrue(readback(reference(case),c,False)['passed'])

    def test_bad_history_peer_and_replica_are_rejected(self):
        for field,index in [('h_new',0),('peer',0),('result',0),('r_new',0),('phase_flags',4)]:
            c=fixture('v1');c['pes'][3][field][index]=f32bits(999)
            self.assertFalse(readback(reference('v1'),c)['passed'],field)

    def test_wrong_input_and_duplicate_pe_fail(self):
        c=fixture('v1');c['x_bits'][0]=0
        with self.assertRaisesRegex(ValueError,'input identity'):readback(reference('v1'),c)
        c=fixture('v1');c['pes'][1]=copy.deepcopy(c['pes'][0])
        with self.assertRaisesRegex(ValueError,'duplicate'):readback(reference('v1'),c)

    def test_time_slice_never_backfills_future_readback(self):
        s={'slots':1,'pes':[{'id':'0,0'},{'id':'0,1'}],'events':[
            {'cycle':10,'pe':'0,0','kind':'accumulate','index':0,'value':11},
            {'cycle':10,'pe':'0,1','kind':'accumulate','index':0,'value':30},
            {'cycle':20,'pe':'0,1','kind':'reduce','index':0,'value':41},
            {'cycle':30,'pe':'0,0','kind':'checkpoint','phase':'final','values':{'result':[41]}}]}
        self.assertEqual(state_at(s,9)['0,0']['partial'],[None])
        self.assertEqual(state_at(s,10)['0,0']['partial'],[11])
        self.assertEqual(state_at(s,10)['0,1']['partial'],[30])
        self.assertEqual(state_at(s,20)['0,0']['result'],[None])
        self.assertEqual(state_at(s,20)['0,1']['result'],[41])
        self.assertEqual(state_at(s,29)['0,0']['result'],[None])
        self.assertEqual(state_at(s,30)['0,0']['result'],[41])

if __name__=='__main__':unittest.main()
