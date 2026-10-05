"""SDK 1.4 <-> 2.10 syntax compatibility: the fix-up rewrites exactly the removed
constructs, is the identity at the 1.4 default, and the gates leave 1.4 prompts untouched."""
import os
import unittest
from pathlib import Path

import sdk_compat as sc

HERE = Path(__file__).resolve().parent
REPO = HERE.parent


class FixupTests(unittest.TestCase):
    def test_param_form(self):
        src = "param memcpy_params: comptime_struct;\nparam n: u16;\n"
        out, n = sc.fixup_csl_for_sdk(src, "2.10.0")
        self.assertEqual(n, 1)
        self.assertEqual(out, "param memcpy_params;\nparam n: u16;\n")   # typed scalar params untouched

    def test_identity_for_1_4_and_for_2x_text(self):
        src = "param memcpy_params: comptime_struct;\n"
        self.assertEqual(sc.fixup_csl_for_sdk(src, "1.4.0"), (src, 0))
        out, _ = sc.fixup_csl_for_sdk(src, "2.10.0")
        self.assertEqual(sc.fixup_csl_for_sdk(out, "2.10.0"), (out, 0))

    def test_const_and_fn_return_forms(self):
        src = "const p: comptime_struct = .{ .a = 1 };\nfn mk() comptime_struct {\n"
        out, n = sc.fixup_csl_for_sdk(src, "2.10.0")
        self.assertEqual(n, 2)
        self.assertIn("const p = .{ .a = 1 };", out)
        self.assertIn("fn mk() anytype {", out)

    def test_concat_structs_inlined_in_layout(self):
        lay = 'const a = .{ .x = 1, .y = 2 };\nconst b = .{ .z = 3 };\n@set_tile_code(0, 0, "pe.csl", @concat_structs(a, b));\n'
        out, n = sc.fixup_csl_for_sdk(lay, "2.10.0", is_layout=True)
        self.assertEqual(n, 1)
        self.assertIn('@set_tile_code(0, 0, "pe.csl", .{ .x = 1, .y = 2, .z = 3 });', out)

    def test_unresolvable_concat_left_alone(self):
        lay = "@set_tile_code(0, 0, \"pe.csl\", @concat_structs(memcpy.get_params(0), extra));\n"
        out, n = sc.fixup_csl_for_sdk(lay, "2.10.0", is_layout=True)
        self.assertEqual((out, n), (lay, 0))

    def _legacy_spmv(self):
        # the SpMV-CSR reference as it read before 2026-09-16 (SDK 1.4 typed memcpy param)
        src = (REPO / "kernels" / "SpMV-CSR" / "CSL" / "pe.csl").read_text()
        self.assertIn("param memcpy_params;", src)
        return src.replace("param memcpy_params;", "param memcpy_params: comptime_struct;", 1)

    def test_spmv_csr_reference(self):
        out, n = sc.fixup_csl_for_sdk(self._legacy_spmv(), "2.10.0")
        self.assertEqual(n, 1)
        self.assertNotIn("comptime_struct", out)
        self.assertIn("param memcpy_params;", out)

    def test_bundle_fixup(self):
        import tempfile, shutil
        with tempfile.TemporaryDirectory() as d:
            shutil.copytree(REPO / "kernels" / "SpMV-CSR" / "CSL", Path(d) / "b")
            (Path(d) / "b" / "pe.csl").write_text(self._legacy_spmv())
            self.assertEqual(sc.fixup_bundle(Path(d) / "b", "2.10.0"), 1)
            self.assertNotIn("comptime_struct", (Path(d) / "b" / "pe.csl").read_text())
            self.assertEqual(sc.fixup_bundle(Path(d) / "b", "2.10.0"), 0)


class GateTests(unittest.TestCase):
    def setUp(self):
        self._saved = {k: os.environ.get(k) for k in ("XKERNEL_TARGET_SDK", "XKERNEL_SDK210_FIXUP")}
        for k in self._saved:
            os.environ.pop(k, None)

    def tearDown(self):
        for k, v in self._saved.items():
            os.environ.pop(k, None)
            if v is not None:
                os.environ[k] = v

    def test_default_is_1_4(self):
        self.assertFalse(sc.is_sdk2())
        self.assertFalse(sc.fixup_enabled())

    def test_templates_whitelist_knowledge_switch(self):
        import csl_templates, prompt_cuda2csl, csl_knowledge_base as kb
        t14 = csl_templates.get_template("single_pe")
        self.assertEqual(t14, csl_templates._TEMPLATES["single_pe"])          # byte-identical at 1.4
        self.assertIn("@concat_structs", prompt_cuda2csl.builtin_whitelist_block())
        self.assertNotIn("SDK 2.10 syntax", kb.type_rules())
        os.environ["XKERNEL_TARGET_SDK"] = "2.10.0"
        t2 = csl_templates.get_template("single_pe")
        self.assertIn("param memcpy_params;", t2)
        self.assertNotIn("comptime_struct", t2)
        self.assertNotIn("@concat_structs", prompt_cuda2csl.builtin_whitelist_block())
        self.assertIn("SDK 2.10 syntax", kb.type_rules())
        for fn in ("for_implementer", "for_architect", "for_optimization"):
            self.assertNotIn(": comptime_struct;", getattr(kb, fn)())


if __name__ == "__main__":
    unittest.main()
