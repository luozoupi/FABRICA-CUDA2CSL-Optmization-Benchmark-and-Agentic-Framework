#!/usr/bin/env python3
"""Reverse Cuthill-McKee orders for the SpMV-RowBlock 16-256 PE class (manifest_2), keyed by matrix id."""
import json, sys
from pathlib import Path
import numpy as np, scipy.sparse as sp
from scipy.sparse.csgraph import reverse_cuthill_mckee
K = Path(__file__).resolve().parents[2] / "SpMV-RowBlock" / "CSL"
sys.path.insert(0, str(K))
import sparse_inputs as si
out = {}
for seed in (7, 101, 202, 303):
    csr, entry = si.load_manifest_matrix(str(K / "data" / "manifest_2.json"), seed)
    A = sp.csr_matrix((csr.val, csr.col, csr.row_ptr), shape=(csr.n, csr.m))
    out[str(entry.get("id", entry.get("file")))] = [int(v) for v in reverse_cuthill_mckee(A, symmetric_mode=True)]
Path(__file__).with_name("rcm_perm.json").write_text(json.dumps(out))
print({k: len(v) for k, v in out.items()})
