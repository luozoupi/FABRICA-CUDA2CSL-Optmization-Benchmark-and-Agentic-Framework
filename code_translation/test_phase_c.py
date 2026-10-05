"""Legacy Ollama-backed prototype driver (pre-v1.0), kept for reference.

It needs the optional `ollama` package (environment-extras.yml). Under
`python -m unittest discover -p 'test_*.py'` the module is skipped, not
reported as an error, when that provider is absent.
"""
import unittest

try:
    from test import AgentOrchestrator
except ImportError as exc:  # optional provider missing
    raise unittest.SkipTest(f"legacy ollama prototype unavailable: {exc}")

if __name__ == "__main__":

    key=""
    max_completion_tokens=1000
    gpt_model="meta-llama/Llama-3.3-70B-Instruct"
    turns_limitation=3
    idx=0
    orchestrator = AgentOrchestrator(
        max_completion_tokens=max_completion_tokens,
        gpt_model=gpt_model,
        turns_limitation=turns_limitation,
        idx=idx)


    orchestrator.run_phase_c()

    print(orchestrator.history)
