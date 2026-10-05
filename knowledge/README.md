# xkernel Knowledge Base

This folder stores local, version-aware documentation knowledge for the
CUDA->CSL translation and optimization agents.

## Current Corpus

- Cerebras SDK cumulative release notes
- Source: `https://sdk.cerebras.net/sdk-release-notes/sdk-rel-notes-cumulative`
- Preferred source format:
  `https://sdk.cerebras.net/_sources/sdk-release-notes/sdk-rel-notes-cumulative.rst.txt`

The processed corpus is written to:

```text
knowledge/data/cerebras_sdk_docs.jsonl
knowledge/data/manifest.json
knowledge/raw/sdk-rel-notes-cumulative.rst.txt
```

`knowledge/data/*.jsonl` (about 1 MB) **is tracked in git** so that every
checkout retrieves from the same corpus the published sweeps used. Provenance:
`cerebras_sdk_docs.jsonl` is chunked from the public SDK release notes;
`cerebras_tutorials*.jsonl` from the Apache-2.0 `csl-examples` repository;
`cerebras_skills.jsonl` from the CSL standard-library documentation;
`cerebras_debug_techniques.jsonl` is hand-written. Refresh only when the target
SDK changes, and commit the regenerated files together with their manifests.

## Refresh

Run through the outbound proxy of your site if one is required (ALCF example):

```bash
export HTTPS_PROXY=http://proxy.alcf.anl.gov:3128
export HTTP_PROXY=http://proxy.alcf.anl.gov:3128
export https_proxy=http://proxy.alcf.anl.gov:3128
export http_proxy=http://proxy.alcf.anl.gov:3128

source xkernel_env.sh && xk_python knowledge/crawl_cerebras_docs.py
```

## Query

```bash
source xkernel_env.sh && xk_python knowledge/cerebras_docs.py \
    --target-sdk 1.4.0 \
    "WSE-3 DSD queues memcpy deprecations"
```

Use `--include-future` to retrieve newer release-note entries, for example SDK
2.10 migration notes. Without it, retrieval filters out chunks newer than the
target SDK so agents do not use features unsupported by the local SDK.

## Agent Interface

`code_translation/csl_knowledge_base.py` loads this corpus automatically when
`knowledge/data/cerebras_sdk_docs.jsonl` exists. It injects a small compatibility
context into CUDA->CSL translation and optimization prompts.

Relevant environment variables:

```text
XKERNEL_TARGET_SDK=1.4.0
XKERNEL_TARGET_ARCH=wse3
```

`cuda2csl.py` also exposes:

```bash
--target-sdk 1.4.0
--arch wse3
```

Keep `--target-sdk 1.4.0` unless `XKERNEL_SDK_ROOT` points at a different SDK release.
