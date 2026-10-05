"""Expert wafer-level mapping for SpMV-RowBlock: balance nonzeros across PEs.

The host splits the (permuted) rows into consecutive blocks of `nrows_pe` rows, one block per PE,
and the slowest PE sets the time. This orders the rows so that every block holds about the same
number of nonzeros: longest-processing-time greedy, each row (longest first) goes to the block with
the fewest nonzeros that still has a free row slot. Returns a permutation of range(n).
"""
import heapq


def row_order(row_nnz, P, nrows_pe):
    n = len(row_nnz)
    nblocks = min(P, -(-n // nrows_pe))
    slots = [nrows_pe] * nblocks
    slots[-1] = n - nrows_pe * (nblocks - 1)
    heap = [(0, b) for b in range(nblocks)]          # (nonzeros so far, block)
    blocks = [[] for _ in range(nblocks)]
    for r in sorted(range(n), key=lambda i: -row_nnz[i]):
        full = []
        while True:
            load, b = heapq.heappop(heap)
            if len(blocks[b]) < slots[b]:
                break
            full.append((load, b))                   # block is full: set it aside for good
        blocks[b].append(r)
        heapq.heappush(heap, (load + row_nnz[r], b))
    return [r for b in blocks for r in sorted(b)]
