# Attention-QP

Dense scaled-dot-product attention (one head, fp32). CUDA source: one thread
per query row. CSL reference: hand-written expert kernel from the authors'
attention-wse project (query-parallel PE grid, K/V replicated, DSD + SIMD inner
loops), imported 2026-09-08. See spec.yaml for sizes and provenance.
