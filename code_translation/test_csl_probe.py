"""The compile-only probe's items and scorers (no LLM, no SDK)."""
import unittest
from pathlib import Path

import yaml

import csl_probe.score_probe as sp

ITEMS = Path(__file__).resolve().parent / "csl_probe" / "items"


class ProbeItemTests(unittest.TestCase):
    def test_items_well_formed(self):
        items = [yaml.safe_load(f.read_text()) for f in sorted(ITEMS.glob("*.yaml"))]
        self.assertGreaterEqual(len(items), 24)
        for it in items:
            for k in ("id", "group", "prompt", "expected", "scoring", "source_citation"):
                self.assertIn(k, it, it.get("id"))
            if it["group"] == "A_syntax":
                self.assertIn("fixed_layout", it); self.assertIn("param memcpy_params;", it["prompt"])
                self.assertIn('@export_name("compute", fn()void);', it["fixed_layout"])
            if it["group"] == "D_api":
                self.assertIn(it["expected"]["choice"], "ABCD"); self.assertEqual(len(it["choices"]), 4)
        groups = {it["group"] for it in items}
        self.assertTrue({"A_syntax", "D_api"} <= groups)

    def test_items_are_not_benchmark_reference_code(self):
        refs = "".join((p / "CSL" / "pe.csl").read_text() for p in (ITEMS.parents[2] / "kernels").glob("*-CSR") if (p / "CSL" / "pe.csl").exists())
        for f in ITEMS.glob("*.yaml"):
            it = yaml.safe_load(f.read_text())
            for line in it["prompt"].splitlines():
                s = line.strip()
                if len(s) > 40 and "@" in s and s in refs:
                    self.fail(f"{it['id']}: prompt contains a reference line: {s[:60]}")


class ScorerTests(unittest.TestCase):
    def test_extract_letter_and_csl(self):
        self.assertEqual(sp.extract_letter("B) because memcpy owns 0 and 1."), "B")
        self.assertEqual(sp.extract_letter("The answer is C."), "C")
        self.assertIsNone(sp.extract_letter("no idea"))
        self.assertEqual(sp.extract_csl("text\n```csl\nparam n: u16;\n```\nmore"), "param n: u16;\n")
        self.assertEqual(sp.extract_csl("param n: u16;"), "param n: u16;\n")



class NumericAnswerTests(unittest.TestCase):
    """Every numeric item asks for "the answer first, then one sentence of justification".
    Reading the LAST numbers instead scored correct replies as wrong whenever the sentence
    mentioned a number -- 2026-09-20, gpt-5.6-luna: 3/12 by that rule, 10/12 by the answer."""

    def test_answer_first_then_a_justification_full_of_numbers(self):
        reply = ("1, 3, 5, 7\n\n`xs` selects the even-indexed elements of `x` -- `x[0]`, "
                 "`x[2]`, `x[4]`, and `x[6]` -- and `@fmovs` copies them into `y`.")
        got, rule = sp.numeric_answer(reply, 4)
        self.assertEqual(got, [1.0, 3.0, 5.0, 7.0])
        self.assertEqual(rule, "first_line")

    def test_a_labelled_answer_line(self):
        got, rule = sp.numeric_answer("Answer: 50, 60, 70\nBecause the offset advances 4 f32.", 3)
        self.assertEqual(got, [50.0, 60.0, 70.0])

    def test_answer_spread_over_the_first_lines(self):
        got, rule = sp.numeric_answer("The values are:\n12\n14\n16\nsince y += a*x.", 3)
        self.assertEqual(got, [12.0, 14.0, 16.0])
        self.assertEqual(rule, "first_anywhere")

    def test_too_few_numbers_is_reported_not_guessed(self):
        got, rule = sp.numeric_answer("I am not sure.", 2)
        self.assertEqual(rule, "too_few")
        self.assertNotEqual(len(got), 2)

    def test_negative_and_decimal_answers_survive(self):
        got, _ = sp.numeric_answer("-1.5, 2.25\nbecause the sign flips.", 2)
        self.assertEqual(got, [-1.5, 2.25])


if __name__ == "__main__":
    unittest.main()
