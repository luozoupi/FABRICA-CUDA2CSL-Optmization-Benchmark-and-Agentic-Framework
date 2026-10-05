"""llm_complete against a reasoning model: a budget consumed entirely by hidden reasoning
returns an EMPTY answer with a successful status, which downstream reads as "the model said
nothing" rather than "the answer was truncated". Observed 2026-09-20 on gpt-5.6-luna, where
every probe item came back empty at the default 2,500-token budget and would have scored 0%.
The client must notice and retry with a larger budget."""
import unittest
from types import SimpleNamespace
from unittest import mock

import workflow_common as wc


def _response(text, truncated):
    return SimpleNamespace(
        output_text=text,
        incomplete_details=SimpleNamespace(reason="max_output_tokens") if truncated else None,
        usage=SimpleNamespace(input_tokens=10, output_tokens=2500,
                              output_tokens_details=SimpleNamespace(reasoning_tokens=2500)),
    )


class FakeClient:
    """Returns the queued responses in order and records the budget of each call."""

    def __init__(self, queue):
        self.queue = list(queue)
        self.budgets = []
        outer = self

        class _Responses:
            def create(self, **kw):
                outer.budgets.append(kw["max_output_tokens"])
                return outer.queue.pop(0)

        self.responses = _Responses()

    def with_options(self, **_kw):
        return self


class ReasoningBudgetTests(unittest.TestCase):
    def setUp(self):
        self._rec = mock.patch.object(wc, "_record_usage", lambda *a, **k: None)
        self._rec.start()
        self.addCleanup(self._rec.stop)

    def test_gpt5_family_uses_the_responses_api(self):
        for m in ("gpt-5.6-luna", "gpt-5", "o3-mini", "o4-mini"):
            self.assertTrue(wc.is_responses_api_model(m), m)
        for m in ("gpt-4.1", "claude-opus-4-8", "meta-llama/Llama-3.3-70B-Instruct"):
            self.assertFalse(wc.is_responses_api_model(m), m)

    def test_empty_truncated_answer_is_retried_with_a_larger_budget(self):
        c = FakeClient([_response("", True), _response("the answer", False)])
        out = wc.llm_complete(c, "gpt-5.6-luna", [{"role": "user", "content": "q"}], max_tokens=2500)
        self.assertEqual(out, "the answer")
        self.assertEqual(c.budgets, [2500, 16000])   # retried, and the retry is big enough

    def test_an_answer_that_arrives_first_time_is_not_retried(self):
        c = FakeClient([_response("fine", False)])
        out = wc.llm_complete(c, "gpt-5.6-luna", [{"role": "user", "content": "q"}], max_tokens=2500)
        self.assertEqual(out, "fine")
        self.assertEqual(c.budgets, [2500])

    def test_a_genuinely_empty_answer_is_not_retried_forever(self):
        # empty but NOT truncated: the model really did answer nothing; one call, no loop
        c = FakeClient([_response("", False)])
        out = wc.llm_complete(c, "gpt-5.6-luna", [{"role": "user", "content": "q"}], max_tokens=2500)
        self.assertEqual(out, "")
        self.assertEqual(c.budgets, [2500])

    def test_a_large_budget_is_not_shrunk_by_the_retry(self):
        c = FakeClient([_response("", True), _response("ok", False)])
        wc.llm_complete(c, "gpt-5.6-luna", [{"role": "user", "content": "q"}], max_tokens=30000)
        self.assertEqual(c.budgets, [30000, 120000])

    def test_partial_truncated_code_is_retried_and_each_call_is_accounted(self):
        c = FakeClient([_response("incomplete code", True), _response("complete code", False)])
        with mock.patch.object(wc, "_record_usage") as record:
            out = wc.llm_complete(c, "gpt-5.6-luna", [], max_tokens=2500)
        self.assertEqual(out, "complete code")
        self.assertEqual(record.call_count, 2)
        self.assertEqual([c.args[3] for c in record.call_args_list], [2500, 16000])

    def test_second_truncation_does_not_return_partial_code(self):
        c = FakeClient([_response("partial", True), _response("still partial", True)])
        with self.assertRaisesRegex(RuntimeError, "truncated"):
            wc.llm_complete(c, "gpt-5.6-luna", [], max_tokens=2500)
        self.assertEqual(len(c.budgets), 2)



class TruncatedAnswerTests(unittest.TestCase):
    """A truncated answer is not an answer even when it is non-empty: measured 2026-09-21,
    gpt-5.6-luna hit a 4,684-token cap exactly and returned 1,823 characters of code with no
    closing fence, which the extractor reports as `no_csl_block` -- about 30% of that sweep's
    optimiser attempts were thrown away that way."""

    def setUp(self):
        self._rec = mock.patch.object(wc, "_record_usage", lambda *a, **k: None)
        self._rec.start()
        self.addCleanup(self._rec.stop)

    def test_non_empty_but_truncated_is_retried(self):
        partial = "```csl\nfn compute() void {\n  // cut off here"
        c = FakeClient([_response(partial, True), _response("```csl\nfn compute() void {}\n```", False)])
        out = wc.llm_complete(c, "gpt-5.6-luna", [{"role": "user", "content": "q"}], max_tokens=4684)
        self.assertIn("```", out)
        self.assertTrue(out.rstrip().endswith("```"), out)
        self.assertEqual(c.budgets, [4684, 18736])

    def test_a_complete_answer_is_never_retried(self):
        c = FakeClient([_response("```csl\nfn compute() void {}\n```", False)])
        wc.llm_complete(c, "gpt-5.6-luna", [{"role": "user", "content": "q"}], max_tokens=4684)
        self.assertEqual(c.budgets, [4684])

    def test_the_retry_happens_at_most_once(self):
        c = FakeClient([_response("partial", True), _response("still partial", True)])
        with self.assertRaisesRegex(RuntimeError, "truncated"):
            wc.llm_complete(c, "gpt-5.6-luna", [{"role": "user", "content": "q"}], max_tokens=4684)
        self.assertEqual(len(c.budgets), 2)


if __name__ == "__main__":
    unittest.main()
