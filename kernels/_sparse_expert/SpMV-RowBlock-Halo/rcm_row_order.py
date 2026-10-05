"""row_order hook for the BROADCAST reference: the RCM row order of the halo variant (rows only), so the
broadcast and halo programs are compared on the same row-to-PE assignment. Matrices are told apart by n."""
import json, os

def row_order(row_nnz, P, nrows_pe):
    here = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(here, "rcm_perm.json"), encoding="utf-8") as fh:
        perms = list(json.load(fh).values())
    for q in perms:
        if len(q) == len(row_nnz):
            return q
    return list(range(len(row_nnz)))
