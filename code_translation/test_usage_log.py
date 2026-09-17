"""Provider-reported token usage is recorded for every llm_complete() call."""
import unittest
from types import SimpleNamespace

import workflow_common as wc


class _AnthropicFake:
    def __init__(self):
        self.messages = self

    def with_options(self, **kw):
        return self

    def create(self, **kwargs):
        return SimpleNamespace(content=[SimpleNamespace(text="ok")],
                               usage=SimpleNamespace(input_tokens=120, output_tokens=7,
                                                     cache_read_input_tokens=100, cache_creation_input_tokens=0))


class _ChatFake:
    def __init__(self):
        self.chat = SimpleNamespace(completions=self)

    def with_options(self, **kw):
        return self

    def create(self, **kwargs):
        return SimpleNamespace(choices=[SimpleNamespace(message=SimpleNamespace(content="hi", reasoning=None))],
                               usage=SimpleNamespace(prompt_tokens=50, completion_tokens=3))


def _call_from_named_phase(client, model):
    def review_failure():  # the recorded phase is the nearest non-plumbing caller
        return wc.llm_complete(client, model, [{"role": "user", "content": "x" * 40}], 64)
    return review_failure()


class UsageLogTest(unittest.TestCase):
    def setUp(self):
        wc.USAGE_LOG.clear()

    def test_anthropic_usage_recorded_with_phase(self):
        out = _call_from_named_phase(_AnthropicFake(), "claude-test-model")
        self.assertEqual(out, "ok")
        self.assertEqual(len(wc.USAGE_LOG), 1)
        rec = wc.USAGE_LOG[0]
        self.assertEqual(rec["provider"], "anthropic")
        self.assertEqual(rec["input_tokens"], 120)
        self.assertEqual(rec["output_tokens"], 7)
        self.assertEqual(rec["cache_read_input_tokens"], 100)
        self.assertEqual(rec["phase"], "review_failure")
        self.assertEqual(rec["prompt_chars"], 40)

    def test_chat_usage_and_summary(self):
        _call_from_named_phase(_ChatFake(), "gpt-oss-120b")
        _call_from_named_phase(_ChatFake(), "gpt-oss-120b")
        s = wc.usage_summary()
        self.assertEqual(s["totals"]["calls"], 2)
        self.assertEqual(s["totals"]["input_tokens"], 100)
        self.assertEqual(s["by_phase"]["review_failure"]["output_tokens"], 6)
        self.assertEqual(s["by_phase"]["review_failure"]["missing_usage"], 0)


if __name__ == "__main__":
    unittest.main()
