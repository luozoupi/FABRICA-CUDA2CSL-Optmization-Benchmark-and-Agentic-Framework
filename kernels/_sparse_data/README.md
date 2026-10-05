# Real sparse matrices for the S task suite

Small matrices from the **SuiteSparse Matrix Collection** (T. A. Davis and Y. Hu,
"The University of Florida Sparse Matrix Collection", ACM TOMS 38(1), 2011;
https://sparse.tamu.edu), Harwell-Boeing group, in Matrix Market format. The
collection is distributed under CC-BY 4.0; each file keeps its original header.

`MANIFEST.json` records, per structure class, the matrix id, file, sha256, n, m and
nnz (symmetric storage expanded), and under `installs` which class each task uses,
train matrix first. `tools/fetch_suitesparse.py --fetch --stats --pin --install`
regenerates everything here and copies each task's matrices into
`kernels/<Task>/CSL/data/` together with the per-task `manifest.json` that
`run.py` reads through `sparse_inputs.load_manifest_matrix`.

Values: most power-network matrices are patterns (all ones). Unless a manifest says
`"values": "mtx"`, `run.py` replaces stored values by `rng(XKERNEL_EVAL_SEED)`
values in [0.1, 1), so every seed produces a different numeric answer even on the
same pattern.
