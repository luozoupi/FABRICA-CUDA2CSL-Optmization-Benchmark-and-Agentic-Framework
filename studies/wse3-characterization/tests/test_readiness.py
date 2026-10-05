import copy
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
sys.path.insert(0, str(ROOT/'tools'))
from readiness import bits, f32, check_values, compare, is_nop
from microbench.readiness.capture import patch_delay


class ReadinessAudit(unittest.TestCase):
    def test_low_payload_halves_and_independent_arithmetic_are_required(self):
        payload = [0x3f800101, 0xbf900202]
        local = [bits(8), bits(8.125)]
        expected = [bits(f32(a)+f32(b)) for a,b in zip(payload,local)]
        result = dict(case=dict(words=2), payload_bits=payload, local_bits=local,
            expected_bits=expected, correct=True,
            observed=dict(buf_0=payload.copy(), buf_1=payload.copy(), loc_1=local.copy(), res_1=expected.copy()))
        check_values(result)
        for field in ('buf_0', 'buf_1', 'loc_1', 'res_1'):
            bad = copy.deepcopy(result); bad['observed'][field][0] ^= 1
            with self.assertRaisesRegex(ValueError, 'readback'):
                check_values(bad)
        bad = copy.deepcopy(result)
        bad['expected_bits'][0] ^= 1; bad['observed']['res_1'] = bad['expected_bits'].copy()
        with self.assertRaisesRegex(ValueError, 'reference'):
            check_values(bad)

    def test_delay_keeps_original_ir_and_uses_side_effecting_nops(self):
        ir = 'define internal void @run() !dbg !1 {\n  ret void\n}\n'
        for n in (0,16,64,256):
            patched = patch_delay(ir,n)
            nop = '  call void asm sideeffect "nop", ""()\n'
            self.assertEqual(patched.count(nop),n)
            self.assertEqual(patched.replace(nop,''),ir)
        with self.assertRaises(ValueError):
            patch_delay('define void @other() {\n}\n',64)
        self.assertTrue(is_nop('nop 0x0'))
        self.assertFalse(is_nop('nop 0x8'))

    def rows(self):
        metrics = dict(send_dispatch=100, receive_dispatch=80, source_first=104, source_last=111,
            receive_first=110, receive_last=118, use_last=130, send_to_last_use=30)
        base = dict(group='test',words=1,sender_sha256='same',terms=[dict(bits=0x3f800101,events=[dict(cycle=104)])],
            run_assembly={'1,0':[dict(instruction='imov32.nf [dds2] = [s1ds2]')]},
            metrics=metrics,case_id='b1-d0-r0',receiver_nops=0)
        delayed = copy.deepcopy(base)
        delayed.update(case_id='b1-d64-r0',receiver_nops=64)
        delayed['run_assembly']['1,0'].insert(0,dict(instruction='nop 0x0'))
        delayed['metrics']['receive_dispatch'] += 64
        return [base,delayed]

    def test_comparison_requires_fixed_sender_payload_and_receiver_body(self):
        rows=self.rows(); comparisons,_=compare(rows)
        self.assertEqual(comparisons[1]['delta']['receive_dispatch'],64)
        for kind in ('sender','payload','body'):
            rows=self.rows()
            if kind=='sender': rows[1]['sender_sha256']='different'
            if kind=='payload': rows[1]['terms'][0]['bits'] ^= 1
            if kind=='body': rows[1]['run_assembly']['1,0'][-1]['instruction']='jmp r15'
            with self.assertRaises(ValueError): compare(rows)

    def test_repetitions_report_timing_differences_instead_of_hiding_them(self):
        base=self.rows()[0]; repeated=copy.deepcopy(base); repeated['case_id']='b1-d0-r1'
        _,checks=compare([base,repeated]);self.assertTrue(checks[0]['timing_and_values_identical'])
        repeated['terms'][0]['events'][0]['cycle'] += 1
        _,checks=compare([base,repeated]);self.assertFalse(checks[0]['timing_and_values_identical'])


if __name__ == '__main__':
    unittest.main()
