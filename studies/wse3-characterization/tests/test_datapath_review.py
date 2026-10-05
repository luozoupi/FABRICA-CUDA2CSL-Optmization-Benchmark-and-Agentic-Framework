"""Evidence-boundary tests for the independent raw-trace review."""
import gzip
import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from datapath_review import SENTINEL, trace


class RawReview(unittest.TestCase):
    def test_placeholder_is_not_completion_and_tiles_do_not_share_uids(self):
        events = []
        for tile, value_cycle in [(12, 15), (13, 13)]:
            events.append(dict(event_type='hwm_dispatch_trace_entry', tile_index=tile, uid=8,
                               cycle=10, inst_ptr=20, task_color=1, ut_id=255, num_data=1, name='LD16'))
            events.append(dict(event_type='hwm_pipe_trace_entry', tile_index=tile, uid=8,
                               cycle=10, stage=3))
            for c in range(13, value_cycle+1):
                events.append(dict(event_type='hwm_pipe_trace_entry', tile_index=tile, uid=8,
                                   cycle=c, stage=6, **{k:SENTINEL for k in ['dest','src0','src1','src2']}))
            events.append(dict(event_type='hwm_pipe_trace_entry', tile_index=tile, uid=8,
                               cycle=value_cycle, stage=6, dest=0, src1=0))
        with tempfile.TemporaryDirectory() as tmp:
            p = Path(tmp)/'events.jsonl.gz'
            with gzip.open(p,'wt') as f:
                for e in events: f.write(json.dumps(e)+'\n')
            asm = {t:{20:dict(text='ld16 r5 = [0x10]', origin='application')} for t in [12,13]}
            seq, _ = trace(p, asm)
        self.assertEqual([i['dx_value'] for i in seq], [5,3])
        self.assertEqual([i['uid'] for i in seq], [8,8])
        self.assertEqual(seq[0]['execute'][0]['row'], 3)
        self.assertFalse(seq[0]['execute'][0]['has_payload'])
        self.assertTrue(seq[0]['execute'][-1]['has_payload'])
        self.assertEqual(seq[0]['execute'][-1]['dest'], 0)
        self.assertEqual(len(seq[0]['execute']), 4)


if __name__ == '__main__': unittest.main()
