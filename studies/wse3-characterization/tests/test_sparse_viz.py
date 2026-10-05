import sys
import unittest
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
from sparse_viz import merge_dot,mac


class SparseSemantics(unittest.TestCase):
    def test_empty_and_disjoint_columns_have_no_structural_result(self):
        steps,value,exists=merge_dot([0,0,1],[3],[2.0],0,1)
        self.assertEqual((steps,value,exists),([],0.0,False))
        steps,value,exists=merge_dot([0,1,2],[0,1],[2.0,3.0],0,1)
        self.assertEqual((value,exists),(0.0,False))
        self.assertEqual([s['action'] for s in steps],['advance left'])
        self.assertIsNone(steps[0]['product'])

    def test_cancellation_is_not_a_structural_zombie(self):
        steps,value,exists=merge_dot([0,2,4],[0,1,0,1],[1.0,1.0,1.0,-1.0],0,1)
        self.assertTrue(exists);self.assertEqual(value,0.0)
        self.assertEqual([s['acc'] for s in steps],[1.0,0.0])

    def test_two_pointer_skips_then_matches(self):
        steps,value,exists=merge_dot([0,2,4],[0,2,1,2],[7.0,3.0,8.0,4.0],0,1)
        self.assertTrue(exists);self.assertEqual(value,12.0)
        self.assertEqual([s['action'] for s in steps],['advance left','advance right','match'])
        self.assertEqual((steps[-1]['pa'],steps[-1]['pb']),(1,3))

    def test_round_each_f32_operation(self):
        product,result=mac(16777216.0,1.0,1.0)
        self.assertEqual(product,1.0);self.assertEqual(result,16777216.0)


if __name__=='__main__':unittest.main()
