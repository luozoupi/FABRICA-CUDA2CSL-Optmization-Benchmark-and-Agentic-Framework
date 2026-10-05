import math
import unittest

from audit import audit, keyed, rank_agreement, same_rows, trial_coverage


class EvidenceAuditTests(unittest.TestCase):
    def test_partial_hardware_trials_are_not_full_successes(self):
        rows = [dict(kernel='SpMV', series='O0', seed=str(i), hw_status=status,
                     hw_repeats_passed=count)
                for i, (status, count) in enumerate([('pass', '3/3'), ('fail', '2/3 repeats passed')])]
        result = trial_coverage(rows)
        self.assertEqual(result['full_success_records'], 1)
        self.assertEqual(result['reported_passing_trials'], 5)
        self.assertEqual(result['reported_trials'], 6)
        self.assertEqual(len(result['incomplete_records']), 1)

    def test_rank_ties_are_not_discarded_from_tau_b(self):
        result = rank_agreement([(1, 1), (1, 2), (2, 3)])
        self.assertAlmostEqual(result['tau_b'], 2 / math.sqrt(6))
        self.assertEqual(result['untied_pair_ratio'], 1)
        self.assertIsNone(rank_agreement([(1, 1), (1, 1)])['tau_b'])

    def test_duplicate_and_missing_cells_fail(self):
        rows = [dict(task='a', cycles='10')]
        with self.assertRaisesRegex(ValueError, 'Duplicate'):
            keyed(rows * 2, ('task',))
        with self.assertRaisesRegex(ValueError, 'coverage'):
            same_rows(rows, [], ('task',), ('cycles',))

    def test_changed_paper_measurement_fails(self):
        with self.assertRaisesRegex(ValueError, 'Data mismatch'):
            same_rows([dict(task='a', cycles='10')], [dict(task='a', cycles='9')],
                      ('task',), ('cycles',))

    def test_current_snapshot_preserves_missing_and_failed_evidence(self):
        result = audit()
        self.assertEqual(result['optimizer']['cells'], 27)
        self.assertEqual(result['hardware']['records'], 21)
        self.assertEqual(len(result['hardware']['missing']), 9)
        self.assertEqual({x['arm'] for x in result['hardware']['missing']}, {'O1I'})
        self.assertEqual(result['hardware']['coverage']['full_success_records'], 19)
        self.assertEqual(result['transfer']['retained_rows'], 81)
        self.assertEqual(result['local']['scaling_passed'], 17)
        self.assertEqual(result['local']['deepseek_improved_from_initial'], 1)


if __name__ == '__main__':
    unittest.main()
