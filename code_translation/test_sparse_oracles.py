import unittest
import numpy as np
from sparse_inputs import from_coo


class SparseOracleTests(unittest.TestCase):
    def test_rectangular_with_empty_rows_and_cancellation(self):
        a=from_coo(5,4,[0,0,2,3,3],[0,2,1,0,3],[1,-1,0,2,3])
        b=np.arange(12).reshape(4,3)
        np.testing.assert_allclose(a.matmat(b), a.dense() @ b)

    def test_masked_gram_preserves_structural_zero_products(self):
        a=from_coo(4,3,[0,0,1,1,2],[0,1,0,1,2],[1,1,1,-1,0])
        rows=np.array([0,0,1,2,0]);cols=np.array([0,1,1,2,2])
        val, exists=a.masked_gram(rows,cols)
        np.testing.assert_allclose(val,(a.dense().T @ a.dense())[rows,cols])
        self.assertEqual(exists.tolist(),[True,True,True,True,False])
        self.assertEqual(val[1],0)  # cancellation is not absence

    def test_empty_and_incompatible_operand(self):
        a=from_coo(10,5,[],[],[])
        self.assertEqual(a.matmat(np.ones((5,2))).shape,(10,2))
        with self.assertRaises(ValueError):a.matmat(np.ones((4,2)))


if __name__=='__main__':unittest.main()
