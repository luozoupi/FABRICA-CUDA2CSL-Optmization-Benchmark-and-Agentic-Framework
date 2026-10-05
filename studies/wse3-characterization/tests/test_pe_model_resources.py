"""pe_model.resources(): operand -> functional-resource classification, and the pcsweep IR patcher."""
import sys, unittest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "tools"))
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "microbench" / "pcsweep"))
import pe_model as pm

class Resources(unittest.TestCase):
    def r(self, text, hint=None): return pm.resources(text, hint)
    def test_scalar_load_add_store(self):
        ld = self.r("ld16 r5 = [0x78e]"); self.assertEqual(ld["unit"], "load"); self.assertIn(("sram", "0x78e"), ld["reads"]); self.assertIn(("gpr", "r5"), ld["writes"])
        add = self.r("add16.nf r5 = r8, r5"); self.assertEqual(add["unit"], "alu"); self.assertEqual(set(add["reads"]), {("gpr", "r8"), ("gpr", "r5")}); self.assertEqual(add["writes"], [("gpr", "r5")])
        st = self.r("st16 [0x792] = r5"); self.assertEqual(st["unit"], "store"); self.assertIn(("sram", "0x792"), st["writes"]); self.assertIn(("gpr", "r5"), st["reads"])
    def test_descriptor_load_moves_control_state_only(self):
        d = self.r("lds1wds s1ds1 = [0x8]")
        self.assertEqual(d["unit"], "dsr-load"); self.assertEqual(d["writes"], [("dsr", "s1ds1")])
        self.assertIn(("dmem", "0x8"), d["reads"]); self.assertFalse(any(k == "sram" for k, _ in d["reads"] + d["writes"]))
    def test_vector_op_reads_dsrs_and_streams(self):
        v = self.r("faddh [dds1] = [s0ds1], [s1ds1]")
        self.assertEqual(v["unit"], "lanes")
        self.assertEqual({n for k, n in v["reads"] if k == "dsr"}, {"dds1", "s0ds1", "s1ds1"})
        self.assertIn(("sram-stream", "via dds1"), v["writes"]); self.assertIn(("sram-stream", "via s0ds1"), v["reads"])
    def test_fabric_hint_changes_stream_kind(self):
        send = self.r("fmov32.nf [dds1] = [s1ds1]", {"dds1": "fabout"}); self.assertIn(("fabout", "via dds1"), send["writes"])
        recv = self.r("fmov32.nf [dds1] = [s1ds1]", {"s1ds1": "fabin"}); self.assertIn(("fabin", "via s1ds1"), recv["reads"])
    def test_flags_predication_jump_task(self):
        c = self.r("lt16.and cflag0 = r14, r9"); self.assertEqual(c["unit"], "compare"); self.assertEqual(c["writes"], [("cflag", "cflag0")])
        p = self.r("!cflag0 ? imov16.nf r14 = 0x16"); self.assertTrue(p["predicated"]); self.assertIn(("cflag", "cflag0"), p["reads"]); self.assertIn(("gpr", "r14"), p["writes"])
        j = self.r("cflag0 ? jmp 0x1ac"); self.assertEqual(j["unit"], "sequencer"); self.assertEqual(j["writes"], [("pc", "0x1ac")])
        t = self.r("actvt 0x9"); self.assertEqual(t["unit"], "task"); self.assertEqual(t["writes"], [("task", "0x9")])
    def test_reduction_writes_register_reads_stream(self):
        v = self.r("faddh r5 = r5, [s1ds1]"); self.assertEqual(v["unit"], "lanes"); self.assertIn(("gpr", "r5"), v["writes"]); self.assertIn(("gpr", "r5"), v["reads"])

class Dependencies(unittest.TestCase):
    def test_raw_war_waw(self):
        win = [dict(text=t, dispatch=k, x_first=k + 3, x_last=k + 3, **pm.resources(t)) for k, t in enumerate(["ld16 r5 = [0x10]", "ld16 r8 = [0x12]", "add16.nf r5 = r8, r5", "st16 [0x14] = r5"])]
        deps = pm.dependencies(win); kinds = {(e["kind"], e["cls"], e["resource"], e["producer"], e["consumer"]) for e in deps}
        self.assertIn(("RAW", "gpr", "r5", 0, 2), kinds); self.assertIn(("RAW", "gpr", "r8", 1, 2), kinds); self.assertIn(("RAW", "gpr", "r5", 2, 3), kinds)
        self.assertIn(("WAW", "gpr", "r5", 0, 2), kinds)
        e = next(e for e in deps if e["kind"] == "RAW" and e["producer"] == 1 and e["consumer"] == 2); self.assertEqual(e["spacing"], 1); self.assertEqual(e["x_gap"], 1)

class SweepPatcher(unittest.TestCase):
    IR = """define internal void @compute() !dbg !3 {
  store i16 24576, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i1 false), align 2
  %1 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i16 0, i1 false), align 2
  %2 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i16 0, i1 false), align 2
  %3 = add i16 %1, %2
  store i16 %3, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i1 false), align 2
  store i16 24577, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i2 1), align 2
  call void @llvm.sdr.actvt.r(i16 9)
  ret void
}
"""
    def test_nops_land_after_the_second_load(self):
        import build as B
        out, rep = B.patch_ir(self.IR, {"pairs": 1, "k": [3], "producer": "gpr"})
        body = out.split("{\n", 1)[1]; lines = [l.strip() for l in body.splitlines()]
        i = next(k for k, l in enumerate(lines) if "@b," in l); self.assertTrue(all("nop" in lines[i + 1 + j] for j in range(3)))
        self.assertTrue(lines[i + 4].startswith("%3 = add")); self.assertEqual(rep, [{"pair": 0, "k": 3}])

if __name__ == "__main__":
    unittest.main()
