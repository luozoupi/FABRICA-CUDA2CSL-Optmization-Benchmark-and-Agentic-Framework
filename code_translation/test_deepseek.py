"""Check provider payloads and accounting without a live credential."""
import os
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace as NS
from unittest.mock import patch
import workflow_common as wc
from csl_templates import get_template


class Chat:
    def __init__(self, content="ok"):
        self.chat = NS(completions=self)
        self.content = content

    def with_options(self, **kw):
        return self

    def create(self, **kw):
        self.kw = kw
        return NS(model="deepseek-flash", choices=[NS(finish_reason="stop",
            message=NS(content=self.content, reasoning_content="not an artifact"))],
            usage=NS(prompt_tokens=100, completion_tokens=20, prompt_cache_hit_tokens=64))


class DeepSeekTest(unittest.TestCase):
    def setUp(self):
        wc.USAGE_LOG.clear()

    def test_thinking_budget_usage_and_journal(self):
        with tempfile.TemporaryDirectory() as d, patch.dict(os.environ, {
                "XKERNEL_DEEPSEEK_THINKING": "enabled", "XKERNEL_DEEPSEEK_EFFORT": "high",
                "XKERNEL_DEEPSEEK_MIN_TOKENS": "16384", "XKERNEL_USAGE_JSONL": d+"/usage.jsonl"}):
            c = Chat()
            self.assertEqual(wc.llm_complete(c, "deepseek-v4-flash", [{"role":"user","content":"x"}], 1024), "ok")
            self.assertEqual(c.kw["max_tokens"], 16384)
            self.assertEqual(c.kw["extra_body"], {"thinking":{"type":"enabled"}})
            self.assertEqual(wc.USAGE_LOG[-1]["response_model"], "deepseek-flash")
            self.assertEqual(wc.usage_summary()["totals"]["cache_read_input_tokens"], 64)
            self.assertNotIn("not an artifact", Path(d+"/usage.jsonl").read_text())

    def test_empty_reasoning_only_is_not_an_answer(self):
        with self.assertRaisesRegex(RuntimeError, "no final content"):
            wc.llm_complete(Chat(None), "deepseek-v4-flash", [], 1024)

    def test_truncation_retries_once_and_accounts_for_both_calls(self):
        class Truncated(Chat):
            def __init__(self):
                super().__init__(); self.budgets=[]
            def create(self, **kw):
                self.budgets.append(kw['max_tokens'])
                response=super().create(**kw)
                if len(self.budgets)==1:
                    response.choices[0].finish_reason='length'
                    response.choices[0].message.content=None
                return response
        with patch.dict(os.environ, {'XKERNEL_DEEPSEEK_MIN_TOKENS':'16384',
                                      'XKERNEL_DEEPSEEK_RETRY_TOKENS':'65536'}):
            c=Truncated()
            self.assertEqual(wc.llm_complete(c,'deepseek-v4-flash',[],1024),'ok')
            self.assertEqual(c.budgets,[16384,65536])
            self.assertEqual(wc.usage_summary()['totals']['calls'],2)

    def test_non_thinking_keeps_small_budget(self):
        with patch.dict(os.environ, {"XKERNEL_DEEPSEEK_THINKING":"disabled"}):
            c = Chat()
            wc.llm_complete(c, "deepseek-v4-flash", [], 128)
            self.assertEqual(c.kw["max_tokens"], 128)
            self.assertNotIn("reasoning_effort", c.kw)

    def test_other_chat_provider_unchanged(self):
        c = Chat()
        wc.llm_complete(c, "gpt-oss-120b", [], 128)
        self.assertNotIn("extra_body", c.kw)
        self.assertEqual(c.kw["max_tokens"], 128)

    def test_template_tracks_sdk(self):
        with patch.dict(os.environ, {"XKERNEL_TARGET_SDK":"2.10"}):
            self.assertNotIn("comptime_struct", get_template("single_pe"))
        with patch.dict(os.environ, {"XKERNEL_TARGET_SDK":"1.4.0"}):
            self.assertIn("comptime_struct", get_template("single_pe"))


if __name__ == "__main__":
    unittest.main()
