#!/usr/bin/env python3
"""Sparse inputs for the S task suite (IPDPS 2027 sparse study).

Matrix Market reading, synthetic structure classes, the seed -> matrix contract,
CSR padding and partitioning, structure features, structure keys and the prose
readout.  numpy only (scipy is used when present, never required), because one
byte-identical copy of this file lives in every ``kernels/<Task>/CSL/`` directory:
``run.py`` executes inside the SDK container and can only import a sibling.
``test_sparse_suite.py`` keeps the copies in sync with this canonical one.

The seed -> matrix contract (docs/IPDPS_PREREG.md v2): a per-kernel
``data/manifest.json`` lists the train matrix first and the held-out matrices
after it.  ``run.py`` maps ``XKERNEL_EVAL_SEED`` to an index with
``seed_to_index``; the train seed always maps to 0, and the suite's held-out
seeds 101/202/303 map to 3/2/1 when there are three held-out matrices, so the
held-out gate never re-tests the train input.  The agent's own loop always runs
on the pinned train matrix, which keeps cycles deterministic.
"""
from __future__ import annotations

import json
import math
import os
import sys
from pathlib import Path

import numpy as np

SCHEMA = "structure_readout/1"
STRUCTURE_KEYS = (
    "struct_uniform_rows", "struct_skewed_rows", "struct_short_rows", "struct_dense_rows",
    "struct_contiguous_rows", "struct_few_diagonals", "struct_banded", "struct_hypersparse",
    "struct_symmetric", "struct_blocked", "struct_pe_imbalance", "struct_accumulator_fits",
    "struct_dense_tile",
)


# --------------------------------------------------------------------------------------
# A minimal CSR container (numpy only)
# --------------------------------------------------------------------------------------
class CSR:
    """Compressed sparse rows: ``row_ptr`` (n+1, int64), ``col`` (nnz, int64) sorted within
    each row, ``val`` (nnz, float64)."""

    def __init__(self, n, m, row_ptr, col, val):
        self.n = int(n); self.m = int(m)
        self.row_ptr = np.asarray(row_ptr, dtype=np.int64)
        self.col = np.asarray(col, dtype=np.int64)
        self.val = np.asarray(val, dtype=np.float64)
        assert self.row_ptr.shape == (self.n + 1,), "row_ptr must have n+1 entries"
        assert self.col.shape == self.val.shape == (int(self.row_ptr[-1]),), "col/val length must equal nnz"

    @property
    def nnz(self):
        return int(self.row_ptr[-1])

    def row_lengths(self):
        return np.diff(self.row_ptr)

    def rows(self):
        """Row index of every nonzero (nnz,)."""
        return np.repeat(np.arange(self.n, dtype=np.int64), self.row_lengths())

    def dense(self):
        d = np.zeros((self.n, self.m), dtype=np.float64)
        d[self.rows(), self.col] = self.val
        return d

    def matvec(self, x):
        x = np.asarray(x, dtype=np.float64)
        return np.bincount(self.rows(), weights=self.val * x[self.col], minlength=self.n)

    def matmat(self, dense):
        """Float64 sparse-dense oracle without materializing a dense sparse operand."""
        dense = np.asarray(dense, dtype=np.float64)
        if dense.ndim != 2 or dense.shape[0] != self.m:
            raise ValueError("dense operand has incompatible dimensions")
        result = np.zeros((self.n, dense.shape[1]), dtype=np.float64)
        for row in range(self.n):
            a, b = self.row_ptr[row:row + 2]
            result[row] = np.sum(self.val[a:b, None] * dense[self.col[a:b]], axis=0)
        return result

    def masked_gram(self, mask_rows, mask_cols):
        """Values and structural existence of A.T @ A at explicit mask positions."""
        columns = self.transpose()
        values = np.zeros(len(mask_rows), dtype=np.float64)
        exists = np.zeros(len(mask_rows), dtype=bool)
        for k, (i, j) in enumerate(zip(mask_rows, mask_cols)):
            a, b = columns.row_ptr[int(i):int(i) + 2]
            c, d = columns.row_ptr[int(j):int(j) + 2]
            _, ia, ib = np.intersect1d(columns.col[a:b], columns.col[c:d],
                                     assume_unique=True, return_indices=True)
            exists[k] = bool(len(ia))
            if exists[k]:
                values[k] = np.dot(columns.val[a:b][ia], columns.val[c:d][ib])
        return values, exists

    def transpose(self):
        return from_coo(self.m, self.n, self.col, self.rows(), self.val, sum_duplicates=False)

    def to_scipy(self):
        from scipy.sparse import csr_matrix
        return csr_matrix((self.val, self.col, self.row_ptr), shape=(self.n, self.m))


def from_coo(n, m, rows, cols, vals, sum_duplicates=True):
    """Build a CSR from coordinate triples; sorts by (row, col) and sums duplicates."""
    rows = np.asarray(rows, dtype=np.int64); cols = np.asarray(cols, dtype=np.int64)
    vals = np.asarray(vals, dtype=np.float64)
    if rows.size:
        if rows.min() < 0 or rows.max() >= n or cols.min() < 0 or cols.max() >= m:
            raise ValueError("coordinate out of range")
    order = np.lexsort((cols, rows))
    rows, cols, vals = rows[order], cols[order], vals[order]
    if sum_duplicates and rows.size:
        key_change = np.ones(rows.size, dtype=bool)
        key_change[1:] = (rows[1:] != rows[:-1]) | (cols[1:] != cols[:-1])
        groups = np.cumsum(key_change) - 1
        vals = np.bincount(groups, weights=vals)
        rows, cols = rows[key_change], cols[key_change]
    row_ptr = np.zeros(n + 1, dtype=np.int64)
    np.add.at(row_ptr, rows + 1, 1)
    row_ptr = np.cumsum(row_ptr)
    return CSR(n, m, row_ptr, cols, vals)


def from_scipy(sp):
    sp = sp.tocsr(); sp.sort_indices(); sp.sum_duplicates()
    return CSR(sp.shape[0], sp.shape[1], sp.indptr, sp.indices, sp.data)


# --------------------------------------------------------------------------------------
# Matrix Market
# --------------------------------------------------------------------------------------
def read_mtx(path):
    """Read a Matrix Market coordinate/array file into a CSR (symmetric storage expanded,
    pattern matrices get unit values).  Uses scipy when available, else a small parser."""
    path = str(path)
    try:
        from scipy.io import mmread
        return from_scipy(mmread(path).tocsr())
    except ImportError:
        return _read_mtx_numpy(path)


def _read_mtx_numpy(path):
    with open(path, "r") as fh:
        header = fh.readline().strip().split()
        if len(header) < 5 or header[0] != "%%MatrixMarket" or header[1].lower() != "matrix":
            raise ValueError("not a Matrix Market matrix: " + path)
        fmt, field, sym = header[2].lower(), header[3].lower(), header[4].lower()
        if fmt != "coordinate":
            raise ValueError("only coordinate format is supported by the fallback parser")
        line = fh.readline()
        while line.startswith("%"):
            line = fh.readline()
        n, m, nz = (int(t) for t in line.split()[:3])
        data = np.loadtxt(fh, ndmin=2)
    rows = data[:, 0].astype(np.int64) - 1
    cols = data[:, 1].astype(np.int64) - 1
    vals = data[:, 2] if field != "pattern" and data.shape[1] > 2 else np.ones(rows.size)
    if sym in ("symmetric", "skew-symmetric", "hermitian"):
        off = rows != cols
        sgn = -1.0 if sym == "skew-symmetric" else 1.0
        rows, cols, vals = (np.concatenate([rows, cols[off]]), np.concatenate([cols, rows[off]]),
                            np.concatenate([vals, sgn * vals[off]]))
    return from_coo(n, m, rows, cols, vals)


def write_mtx(path, csr, comment=""):
    with open(path, "w") as fh:
        fh.write("%%MatrixMarket matrix coordinate real general\n")
        if comment:
            for l in comment.splitlines():
                fh.write("% " + l + "\n")
        fh.write(f"{csr.n} {csr.m} {csr.nnz}\n")
        for r, c, v in zip(csr.rows(), csr.col, csr.val):
            fh.write(f"{int(r) + 1} {int(c) + 1} {float(v)!r}\n")


# --------------------------------------------------------------------------------------
# Synthetic structure classes (deterministic in the seed)
# --------------------------------------------------------------------------------------
def _values(rng, k):
    return rng.uniform(0.1, 1.0, size=k)


def banded(n, bw, seed, m=None):
    """All entries with |i-j| <= bw filled: the vectorised-axis best case (DIA form)."""
    m = n if m is None else m
    rng = np.random.default_rng(seed)
    rows, cols = [], []
    for d in range(-bw, bw + 1):
        i = np.arange(max(0, -d), min(n, m - d))
        rows.append(i); cols.append(i + d)
    rows = np.concatenate(rows); cols = np.concatenate(cols)
    return from_coo(n, m, rows, cols, _values(rng, rows.size))


def uniform_random(n, seed, m=None, density=None, nnz_per_row=None, max_nnz=None):
    """Independent uniform positions (the SpMV-CSR generator's structure class).  With
    ``max_nnz`` the entries past the cap are dropped in row-major order, exactly as
    ``kernels/SpMV-CSR/CSL/run.py`` trims its matrix to ``max_nnz``."""
    m = n if m is None else m
    rng = np.random.default_rng(seed)
    if nnz_per_row is not None:
        k = min(int(nnz_per_row), m)
        cols = np.concatenate([np.sort(rng.choice(m, size=k, replace=False)) for _ in range(n)])
        rows = np.repeat(np.arange(n), k)
    else:
        mask = rng.random((n, m)) < float(density)
        rows, cols = np.nonzero(mask)          # row-major order, as in SpMV-CSR's run.py
    if max_nnz is not None and rows.size > int(max_nnz):
        rows, cols = rows[: int(max_nnz)], cols[: int(max_nnz)]
    return from_coo(n, m, rows, cols, _values(rng, rows.size))


def powerlaw_rows(n, seed, nnz_total, alpha=1.2, max_row=None, m=None):
    """Zipf-distributed row lengths: a few long rows, many short ones (load imbalance)."""
    m = n if m is None else m
    max_row = m if max_row is None else int(max_row)
    rng = np.random.default_rng(seed)
    ranks = rng.permutation(n) + 1
    w = ranks.astype(np.float64) ** (-alpha)
    lens = np.minimum(np.maximum(1, np.round(w / w.sum() * nnz_total)).astype(np.int64), max_row)
    rows, cols = [], []
    for i in range(n):
        c = rng.choice(m, size=int(lens[i]), replace=False)
        rows.append(np.full(c.size, i)); cols.append(c)
    rows = np.concatenate(rows); cols = np.concatenate(cols)
    return from_coo(n, m, rows, cols, _values(rng, rows.size))


def block_diagonal(n, block, seed, fill=0.9):
    rng = np.random.default_rng(seed)
    rows, cols = [], []
    for b0 in range(0, n, block):
        b1 = min(n, b0 + block)
        mask = rng.random((b1 - b0, b1 - b0)) < fill
        r, c = np.nonzero(mask)
        rows.append(r + b0); cols.append(c + b0)
    rows = np.concatenate(rows); cols = np.concatenate(cols)
    return from_coo(n, n, rows, cols, _values(rng, rows.size))


def block_random(n, seed, block=4, blocks_per_row=3, fill=0.9):
    """Dense block x block tiles: the diagonal tile of every block row plus blocks_per_row - 1 others
    at random block columns, each entry present with probability fill (a block-sparse class for BSR;
    the random block columns spread the nonzeros over many diagonals)."""
    rng = np.random.default_rng(seed)
    nb = n // block
    rows, cols = [], []
    for br in range(nb):
        others = rng.choice([c for c in range(nb) if c != br], size=min(blocks_per_row - 1, nb - 1), replace=False)
        for bc in [br] + sorted(int(c) for c in others):
            mask = rng.random((block, block)) < fill
            r, c = np.nonzero(mask)
            rows.append(r + br * block); cols.append(c + bc * block)
    rows = np.concatenate(rows); cols = np.concatenate(cols)
    return from_coo(n, n, rows, cols, _values(rng, rows.size))


GENERATORS = {"banded": banded, "uniform_random": uniform_random,
              "powerlaw_rows": powerlaw_rows, "block_diagonal": block_diagonal,
              "block_random": block_random}


def generate(kind, seed, **params):
    if kind not in GENERATORS:
        raise KeyError(f"unknown generator {kind!r}; known: {sorted(GENERATORS)}")
    return GENERATORS[kind](seed=seed, **params)


# --------------------------------------------------------------------------------------
# The seed -> matrix contract
# --------------------------------------------------------------------------------------
EVAL_ENV_FILE = ".xkernel_eval_env.json"


def resolve_eval_seed(default=7, env_name="XKERNEL_EVAL_SEED", where=None):
    """The evaluation seed: the environment variable if set, else the harness's
    ``.xkernel_eval_env.json`` in the bundle directory (written by
    ``benchmark_csl._run_step_command`` for held-out runs; the container binds the
    bundle directory, whereas an ssh relay in front of `singularity` drops the
    environment), else ``default``.  Also honours the SINGULARITYENV_/APPTAINERENV_
    forms in case the variable reached the process un-stripped."""
    for name in (env_name, f"SINGULARITYENV_{env_name}", f"APPTAINERENV_{env_name}"):
        v = os.environ.get(name)
        if v not in (None, ""):
            return int(v)
    dirs = [where] if where else []
    dirs += [os.getcwd(), os.path.dirname(os.path.abspath(sys.argv[0])) if sys.argv and sys.argv[0] else os.getcwd()]
    for d in dirs:
        f = os.path.join(d, EVAL_ENV_FILE)
        if os.path.isfile(f):
            try:
                v = json.loads(open(f).read()).get(env_name)
                if v not in (None, ""):
                    return int(v)
            except (ValueError, OSError):
                pass
    return int(default)


def seed_to_index(seed, train_seed, n_matrices):
    """0 for the train seed; otherwise 1 + seed % (n_matrices - 1), never 0."""
    seed = int(seed); n_matrices = int(n_matrices)
    if seed == int(train_seed) or n_matrices <= 1:
        return 0
    return 1 + seed % (n_matrices - 1)


def load_manifest(manifest_path):
    manifest_path = Path(manifest_path)
    man = json.loads(manifest_path.read_text())
    man["_dir"] = str(manifest_path.parent)
    return man


def load_manifest_matrix(manifest_path, seed):
    """Return (CSR, entry) for this seed.  ``values``: ``mtx`` keeps stored values,
    ``seeded_uniform`` (default) replaces them by rng(seed) values in [0.1, 1); a
    ``generator`` entry is synthesised with this seed instead of read from a file."""
    man = load_manifest(manifest_path)
    entries = man["matrices"]
    idx = seed_to_index(seed, man.get("train_seed", 7), len(entries))
    entry = dict(entries[idx]); entry["index"] = idx
    if "generator" in entry:
        g = dict(entry["generator"]); kind = g.pop("kind")
        csr = generate(kind, seed, **g)
    else:
        csr = read_mtx(Path(man["_dir"]) / entry["file"])
        if man.get("values", "seeded_uniform") == "seeded_uniform":
            rng = np.random.default_rng(int(seed))
            csr = CSR(csr.n, csr.m, csr.row_ptr, csr.col, rng.uniform(0.1, 1.0, size=csr.nnz))
    return csr, entry


# --------------------------------------------------------------------------------------
# Padding and partitioning (host-side, into the device contract)
# --------------------------------------------------------------------------------------
def csr_pad(csr, nrows_cap, nnz_cap):
    """Pad to fixed capacities: row_ptr[nrows_cap+1] u32 (rows past n repeat nnz),
    col[nnz_cap] u32, val[nnz_cap] f32.  Raises if the matrix exceeds a cap."""
    if csr.n > nrows_cap or csr.nnz > nnz_cap:
        raise ValueError(f"matrix {csr.n}x{csr.m} nnz {csr.nnz} exceeds caps rows {nrows_cap} nnz {nnz_cap}")
    row_ptr = np.full(nrows_cap + 1, csr.nnz, dtype=np.uint32); row_ptr[: csr.n + 1] = csr.row_ptr
    col = np.zeros(nnz_cap, dtype=np.uint32); col[: csr.nnz] = csr.col
    val = np.zeros(nnz_cap, dtype=np.float32); val[: csr.nnz] = csr.val
    return {"row_ptr": row_ptr, "col": col, "val": val}


def csc_pad(csr, ncols_cap, nnz_cap):
    t = csr.transpose()
    p = csr_pad(t, ncols_cap, nnz_cap)
    return {"col_ptr": p["row_ptr"], "row": p["col"], "val": p["val"]}


def partition_row_block(csr, P, rows_per_pe=None):
    """P consecutive row blocks (local row numbering, global columns)."""
    rows_per_pe = int(math.ceil(csr.n / P)) if rows_per_pe is None else int(rows_per_pe)
    parts = []
    for p in range(P):
        r0, r1 = p * rows_per_pe, min(csr.n, (p + 1) * rows_per_pe)
        if r0 >= csr.n:
            parts.append(CSR(0, csr.m, np.zeros(1, dtype=np.int64), np.zeros(0), np.zeros(0))); continue
        a, b = csr.row_ptr[r0], csr.row_ptr[r1]
        parts.append(CSR(r1 - r0, csr.m, csr.row_ptr[r0:r1 + 1] - a, csr.col[a:b], csr.val[a:b]))
    return parts


def partition_row_tiles(csr, Py):
    return partition_row_block(csr, Py, int(math.ceil(csr.n / Py)))


# --------------------------------------------------------------------------------------
# Structure features, keys and readout
# --------------------------------------------------------------------------------------
def features(csr, partition=None, caps=None):
    """Structural facts of one matrix.  ``partition``: {"scheme": "row_block"|"row_tiles",
    "pes": P}; ``caps``: {"nrows_pe": .., "max_nnz_pe": ..} (or nrows/max_nnz for 1 PE)."""
    n, m, nnz = csr.n, csr.m, csr.nnz
    lens = csr.row_lengths().astype(np.float64)
    rows = csr.rows()
    off = csr.col - rows
    f = {"schema": SCHEMA, "n": n, "m": m, "nnz": nnz,
         "density": (nnz / (n * m)) if n and m else 0.0,
         "row_len_mean": float(lens.mean()) if n else 0.0,
         "row_len_max": int(lens.max()) if n else 0, "row_len_min": int(lens.min()) if n else 0,
         "row_len_cv": float(lens.std() / lens.mean()) if n and lens.mean() > 0 else 0.0,
         "empty_rows_frac": float((lens == 0).mean()) if n else 0.0,
         "bandwidth": int(np.abs(off).max()) if nnz else 0}
    if nnz:
        a = np.sort(np.abs(off))
        f["band95"] = int(a[min(nnz - 1, int(math.ceil(0.95 * nnz)) - 1)])
        f["frac_within_band1"] = float((a <= 1).mean())
        diag, cnt = np.unique(off, return_counts=True)
        cnt = np.sort(cnt)[::-1]
        f["n_diagonals"] = int(diag.size)
        f["n_diagonals_for_90pct"] = int(np.searchsorted(np.cumsum(cnt), 0.9 * nnz) + 1)
        # rows whose columns form one contiguous run
        first = csr.col[csr.row_ptr[:-1][lens > 0]]
        last = csr.col[csr.row_ptr[1:][lens > 0] - 1]
        f["contiguous_run_rows_frac"] = float(((last - first + 1) == lens[lens > 0]).mean()) if (lens > 0).any() else 0.0
        f["symmetric_pattern"] = bool(n == m and _pattern_symmetric(csr))
        f["block_density_4x4"] = _block_density(csr, 4)
    else:
        f.update(band95=0, frac_within_band1=0.0, n_diagonals=0, n_diagonals_for_90pct=0,
                 contiguous_run_rows_frac=0.0, symmetric_pattern=bool(n == m), block_density_4x4=0.0)
    f["accumulator_fits"] = bool(m * 4 <= 16384)
    if partition:
        P = int(partition.get("pes", 1)); scheme = partition.get("scheme", "row_block")
        if scheme in ("row_block", "row_tiles") and P > 1:
            parts = partition_row_block(csr, P, partition.get("rows_per_pe"))
            pe_nnz = [p.nnz for p in parts]
            f["partition"] = {"scheme": scheme, "pes": P, "pe_nnz": pe_nnz,
                              "imbalance": (max(pe_nnz) / (sum(pe_nnz) / P)) if sum(pe_nnz) else 1.0}
    if caps:
        nnz_cap = caps.get("max_nnz_pe", caps.get("max_nnz"))
        local_nnz = max(f["partition"]["pe_nnz"]) if "partition" in f else nnz
        if nnz_cap:
            f["cap_fill"] = float(local_nnz / nnz_cap)
    f["keys"] = structure_keys(f)
    return f


def _pattern_symmetric(csr):
    rows = csr.rows()
    a = set(zip(rows.tolist(), csr.col.tolist()))
    return all((c, r) in a for r, c in a)


def _block_density(csr, b):
    rows = csr.rows()
    blocks = set(zip((rows // b).tolist(), (csr.col // b).tolist()))
    return float(csr.nnz / (len(blocks) * b * b)) if blocks else 0.0


def structure_keys(f):
    keys = []
    if f["nnz"] == 0:
        return keys
    cv, mean, mx = f["row_len_cv"], f["row_len_mean"], f["row_len_max"]
    if cv < 0.25: keys.append("struct_uniform_rows")
    if cv > 1.0 or (mean > 0 and mx / mean > 8): keys.append("struct_skewed_rows")
    if mean < 8: keys.append("struct_short_rows")
    if mean >= 32: keys.append("struct_dense_rows")
    if f["contiguous_run_rows_frac"] >= 0.9: keys.append("struct_contiguous_rows")
    if f["n_diagonals_for_90pct"] <= 16: keys.append("struct_few_diagonals")
    if f["band95"] <= 0.1 * max(f["n"], 1): keys.append("struct_banded")
    if f["nnz"] < f["n"]: keys.append("struct_hypersparse")
    if f["symmetric_pattern"]: keys.append("struct_symmetric")
    if f["block_density_4x4"] >= 0.75: keys.append("struct_blocked")
    if f.get("partition", {}).get("imbalance", 1.0) > 1.5: keys.append("struct_pe_imbalance")
    if f["accumulator_fits"]: keys.append("struct_accumulator_fits")
    if f["density"] >= 0.08 and f["n"] * f["m"] <= 4096: keys.append("struct_dense_tile")   # 2026-10-04
    return keys


def readout(f, matrix_id=None, caps=None, max_chars=600):
    """Prose for a prompt: the train input only, never the held-out list."""
    parts = []
    head = f"matrix {matrix_id}: " if matrix_id else "input matrix: "
    parts.append(head + f"{f['n']} x {f['m']}, nnz {f['nnz']}, density {100 * f['density']:.2f}%")
    parts.append(f"row lengths mean {f['row_len_mean']:.2f}, max {f['row_len_max']}, min {f['row_len_min']}, "
                 f"CV {f['row_len_cv']:.2f}, empty rows {100 * f['empty_rows_frac']:.0f}%")
    parts.append(f"bandwidth {f['bandwidth']}; 95% of nnz within |i-j| <= {f['band95']}; "
                 f"{f['n_diagonals_for_90pct']} diagonals hold 90% of nnz; "
                 f"{100 * f['contiguous_run_rows_frac']:.0f}% of rows are one contiguous column run"
                 + ("; symmetric pattern" if f["symmetric_pattern"] else ""))
    if "partition" in f:
        p = f["partition"]
        parts.append(f"{p['scheme']} over {p['pes']} PEs: nnz per PE {p['pe_nnz']}, imbalance {p['imbalance']:.2f}")
    if caps:
        fill = f" (fill {100 * f['cap_fill']:.0f}%)" if "cap_fill" in f else ""
        parts.append("device caps " + ", ".join(f"{k} {v}" for k, v in caps.items()) + fill)
    if f.get("keys"):
        parts.append("structure keys: " + ", ".join(f["keys"]))
    text = "Structure readout (train input; held-out inputs are other matrices of the same class):\n  " + "\n  ".join(parts)
    return text if len(text) <= max_chars else text[: max_chars - 3] + "..."


def emit_structure_line(f):
    """For generator-based run.py: one stdout line the harness can capture."""
    slim = {k: v for k, v in f.items() if k not in ("schema",)}
    print("xkernel_structure = " + json.dumps(slim, default=float))


def readout_for_kernel(reference_dir):
    """Harness side: read ../spec.yaml's ``structure`` block and compute the readout on the
    train entry only.  Returns None when the spec has no structure block or readout is off."""
    import yaml  # harness environment only
    ref = Path(reference_dir)
    spec_path = ref.parent / "spec.yaml"
    if not spec_path.exists():
        return None
    spec = yaml.safe_load(spec_path.read_text()) or {}
    st = spec.get("structure") or {}
    if not st or not st.get("readout", False):
        return None
    caps = st.get("caps") or {}
    part = st.get("partition") or {}
    partition = None
    if part.get("scheme") in ("row_block", "row_tiles"):
        mesh = str(part.get("mesh", "1x1")).lower().replace("px", "").replace("x", " ").split()
        pes = int(mesh[0]) if mesh and mesh[0].isdigit() else int(part.get("pes", 1))
        partition = {"scheme": part["scheme"], "pes": pes, "rows_per_pe": caps.get("nrows_pe")}
    train_seed = int((spec.get("eval") or {}).get("train_seed", 7))
    if st.get("manifest"):
        man_path = ref.parent / st["manifest"]
        csr, entry = load_manifest_matrix(man_path, train_seed)
        mid = entry.get("id", entry.get("file"))
    elif st.get("generator"):
        g = dict(st["generator"]); kind = g.pop("kind")
        sizes = spec.get("sizes") or []
        params = (sizes[0].get("params") if sizes else {}) or {}
        n = int(params.get("nrows", params.get("n", 32)))
        if kind == "uniform_random":
            csr = uniform_random(n, train_seed, m=int(params.get("ncols", n)), density=g.get("density", 0.25),
                                 max_nnz=params.get("max_nnz"))
        else:
            csr = generate(kind, train_seed, n=n, **g)
        mid = f"synthetic {kind}"
    else:
        return None
    return readout(features(csr, partition=partition, caps=caps), matrix_id=mid, caps=caps or None)


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("mtx", nargs="+", help="Matrix Market files")
    ap.add_argument("--pes", type=int, default=1)
    a = ap.parse_args()
    for p in a.mtx:
        c = read_mtx(p)
        f = features(c, partition={"scheme": "row_block", "pes": a.pes} if a.pes > 1 else None)
        print(readout(f, matrix_id=Path(p).stem))
