# FABRICA knowledge corpus

`data/` contains the version-aware SDK release-note, tutorial, skill, and diagnostic
corpora consumed by `code_translation/csl_knowledge_base.py`. These JSONL files are
runtime inputs, not generated benchmark logs. Their manifests preserve provenance.

`explored/**/ingest/` preserves promoted experience chunks and general optimization
rules. Raw run ledgers are omitted. The framework keeps exploration knowledge
separate from benchmark translation prompts; see [the knowledge boundaries](../code_translation/FIREWALL.md).
Optional corpus paths now resolve relative to this checkout.

```bash
python knowledge/cerebras_docs.py --target-sdk 1.4.0 "WSE-3 DSD queues memcpy"
```

The crawler and ingestion scripts can refresh source material when needed; inspect
`--help` and provide local upstream source paths explicitly. Changing a corpus changes
the evaluation context. Local paths in retained provenance were made portable during
source packaging; source URLs and original source-content hashes were retained.
