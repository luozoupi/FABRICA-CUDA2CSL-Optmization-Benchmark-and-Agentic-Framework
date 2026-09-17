"""error_gotcha_retrieval: compile-error -> hint micro-retrieval (gate, dedupe, new entries)."""
import os
import unittest
from unittest import mock

import error_gotcha_retrieval as eg


class GotchaRetrievalTests(unittest.TestCase):
    def test_export_mutability_hint(self):
        stderr = ("./pe.csl:112:20: error: exported symbol mutability mismatch\n"
                  "    @export_symbol(ptr_O, \"O\");\n"
                  "./layout.csl:46:3: note: expected name to be mutable\n")
        block = eg.retrieve_gotchas(stderr)
        self.assertIn("[export-mutability]", block)
        self.assertIn("@export_name(name, type, mutable)", block)
        # one hint per label even though two lines match
        self.assertEqual(block.count("[export-mutability]"), 1)

    def test_gate_off_returns_empty(self):
        with mock.patch.dict(os.environ, {"XKERNEL_ERROR_GOTCHA": "0"}):
            self.assertEqual(eg.retrieve_gotchas("error: exported symbol mutability mismatch"), "")

    def test_no_match_returns_empty(self):
        self.assertEqual(eg.retrieve_gotchas("./pe.csl:1:1: error: something novel"), "")

    def test_max_hints_respected(self):
        stderr = ("error: exported symbol mutability mismatch\n"
                  "error: initialization for this queue has already been set\n"
                  "error: use of undeclared identifier\n"
                  "error: expected type 'i16', got: 'u16'\n")
        block = eg.retrieve_gotchas(stderr, max_hints=2)
        self.assertEqual(sum(1 for ln in block.splitlines() if ln.startswith("- [")), 2)


if __name__ == "__main__":
    unittest.main()
