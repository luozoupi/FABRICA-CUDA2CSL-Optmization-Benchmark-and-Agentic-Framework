"""anatomy_common: operand typing, wavelet field bits (csdb-equivalent), route tables."""
import json, sys, tempfile, unittest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "tools"))
import anatomy_common as ac

# (fields, colour, ctrl, link) rows taken from the 3,021-wavelet join with csdb's wavelet read-trace
CSDB_ROWS = [(0x0080, 0, False, "E"), (0x2885, 5, False, "E"), (0x1c83, 3, False, "R"), (0xb4b6, 22, True, "R"),
             (0xb0b6, 22, True, "E"), (0x2b85, 5, False, "S"), (0x0180, 0, False, "N"), (0xacb5, 21, True, "R"),
             (0xa895, 21, False, "E"), (0x3486, 6, False, "R"), (0x3086, 6, False, "E"), (0x0380, 0, False, "S")]

class WaveletFields(unittest.TestCase):
    def test_matches_csdb(self):
        for f, colour, ctrl, link in CSDB_ROWS:
            d = ac.wavelet_fields(f)
            self.assertEqual((d["colour"], d["ctrl"], d["link"]), (colour, ctrl, link), hex(f))
            self.assertEqual(d["colour_out"], colour)
            self.assertEqual(d["link_evidence"], "documented")
    def test_west_is_inferred(self):
        d = ac.wavelet_fields(0x0280)
        self.assertEqual(d["link"], "W"); self.assertEqual(d["link_evidence"], "inferred")

class Typed(unittest.TestCase):
    def test_kinds(self):
        self.assertEqual(ac.typed_for("sub16.nf", 5555), "5555 (0x15b3)")
        self.assertEqual(ac.typed_for("imul16", 41838), "-23698 (0xa36e)")
        self.assertEqual(ac.typed_for("fmulh", 46592), "-0.375 (0xb600)")
        self.assertEqual(ac.typed_for("fadds", 1081081856), "3.75 (0x40700000)")
        self.assertEqual(ac.typed_for("fh2s", 15872, "src0"), "1.5 (0x3e00)")
        self.assertEqual(ac.typed_for("fh2s", 1069547520), "1.5 (0x3fc00000)")
        self.assertEqual(ac.typed_for("fs2h", 15872), "1.5 (0x3e00)")
        self.assertEqual(ac.typed_for("lddwds", 123469832), "0x075c0008")
        self.assertEqual(ac.typed_for("ld16", 15872), "0x3e00 (i16 15872 · f16 1.5)")
        self.assertEqual(ac.typed_for("fmov16.nf", 48128), "0xbc00 (i16 -17408 · f16 -1)")
        self.assertEqual(ac.typed_for("ld16", None), ""); self.assertEqual(ac.typed_for("ld16", ac.SENTINEL), "")

class Routes(unittest.TestCase):
    TABLE = """+----------+-------+-----------+-----------+-------+-------+-------+
|    PE    | color | rx        | tx        | sw-1  | sw-2  | sw-3  |
+----------+-------+-----------+-----------+-------+-------+-------+
|    0,0   | 6     | R         | E         |       |       |       |
|          | 22    | W         | R,E       |       |       |       |
+----------+-------+-----------+-----------+-------+-------+-------+
|    1,0   | 6     | W         | R         |       |       |       |
+----------+-------+-----------+-----------+-------+-------+-------+
Total 3 row(s).
"""
    def test_parse_with_offsets(self):
        with tempfile.TemporaryDirectory() as d:
            p = Path(d) / "routes.txt"; p.write_text(self.TABLE)
            r = ac.parse_routes(p, (4, 1))
        self.assertEqual(set(r), {(4, 1), (5, 1)})
        self.assertEqual(r[(4, 1)][6], {"rx": "R", "tx": ["E"], "sw": ["", "", ""]})
        self.assertEqual(r[(4, 1)][22]["tx"], ["R", "E"])
        self.assertEqual(r[(5, 1)][6]["rx"], "W")

class Origin(unittest.TestCase):
    """An instruction is application or runtime by the source its code came from -- never by
    whether its mnemonic decoded. Dropping undecoded instructions invents pipeline bubbles."""
    def test_classification(self):
        self.assertEqual(ac.origin_of("pe.csl"), "application")
        self.assertEqual(ac.origin_of("kernel.csl", app_src="kernel.csl"), "application")
        for r in ("memcpy.csl", "memcpyd2h.csl", "memcpyh2d.csl", "sys.csl", "internal.csl",
                  "tile_config.csl", "input_queue_config.csl", "layout.csl"):
            self.assertEqual(ac.origin_of(r), "runtime", r)
        self.assertEqual(ac.origin_of("pe.csl", app_src="other.csl"), "unclassified")
        self.assertEqual(ac.origin_of(""), "unclassified")
    def test_load_disasm_keeps_runtime(self):
        with tempfile.TemporaryDirectory() as d:
            f = Path(d) / "disasm.json"
            f.write_text(json.dumps([
                {"pc": 2, "instruction": "add16.nf r1 = r2, r3", "source_file": "/x/y/pe.csl"},
                {"pc": 4, "instruction": "ld16 r5 = [0x2]", "source_file": "/sdk/memcpy/memcpy.csl"},
                {"pc": 6, "instruction": "nop", "source_file": "/sdk/weird.csl"},
            ]))
            d2 = ac.load_disasm(f)
        self.assertEqual(set(d2), {2, 4, 6})          # nothing filtered out
        self.assertEqual(d2[2]["origin"], "application")
        self.assertEqual(d2[4]["origin"], "runtime")
        self.assertEqual(d2[6]["origin"], "unclassified")
        self.assertEqual(d2[4]["source_file"], "memcpy.csl")

class Completion(unittest.TestCase):
    """Completion latency is dispatch -> LAST execute record. The interval to a consumer's
    dispatch is not a latency: the reduction dispatches at 10390, its store dispatches at 10403,
    but the reduction's last element executes at 10407."""
    def test_last_execute_not_first(self):
        self.assertEqual(ac.completion(10390, 10407), 17)
        self.assertNotEqual(ac.completion(10390, 10407), 13)
    def test_missing(self):
        self.assertIsNone(ac.completion(10, None)); self.assertIsNone(ac.completion(None, 10))

if __name__ == "__main__":
    unittest.main()
