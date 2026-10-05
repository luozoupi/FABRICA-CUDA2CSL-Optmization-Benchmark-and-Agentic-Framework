# Memory limits of replicated B

The measured implementation places a complete CSR copy of B on every application PE. More PEs reduce local A rows and output capacity, but do not reduce that B copy. The following additional sizes are **analytical allocation calculations only**; they have not been compiled or run in this sweep. The same calculation exactly reproduces all 24 non-weak registered configurations.

| Size | B degree | PEs | Variant | B bytes per PE | Declared application bytes per PE | Array-only assessment |
|---|---:|---:|---|---:|---:|---|
| 512 | 3 | 16 | full | 14,344 | 35,212 | Compiler and runtime check required |
| 512 | 3 | 16 | tiled | 14,344 | 32,236 | Compiler and runtime check required |
| 512 | 3 | 64 | full | 14,344 | 21,964 | Compiler and runtime check required |
| 512 | 3 | 64 | tiled | 14,344 | 18,988 | Compiler and runtime check required |
| 1024 | 3 | 64 | full | 28,680 | 43,788 | Compiler and runtime check required |
| 1024 | 3 | 64 | tiled | 28,680 | 37,740 | Compiler and runtime check required |
| 1024 | 3 | 256 | full | 28,680 | 37,164 | Compiler and runtime check required |
| 1024 | 3 | 256 | tiled | 28,680 | 31,116 | Compiler and runtime check required |
| 1024 | 8 | 256 | full | 69,640 | 78,252 | Exceeds 48 KiB |
| 1024 | 8 | 256 | tiled | 69,640 | 72,204 | Exceeds 48 KiB |
| 2048 | 3 | 256 | full | 57,352 | 74,188 | Exceeds 48 KiB |
| 2048 | 3 | 256 | tiled | 57,352 | 61,996 | Exceeds 48 KiB |

These numbers include declared application arrays and guard slots; they exclude compiler-generated code, collective-library storage, alignment, and dynamic stack use. A number below 48 KiB is not evidence that a compiled program fits. Smaller accumulators can reduce scratch storage, but cannot remove the replicated-B limit.

At size 1,024 with eight entries per B row, the B packet alone occupies 69,640 bytes. At size 2,048 with three entries per B row, it occupies 57,352 bytes. Both exceed 48 KiB independently of the number of PEs. This is a limit of this data placement and representation, not a limit on the matrix size the WSE can process.

Extending the algorithm requires partitioning or streaming B, or a more compact index representation with checked bounds. Row/column blocks can distribute B storage, but then require scheduling remote B rows and possibly merging partial output rows. Splitting costly output rows can address the load imbalance observed in the small sweep, while adding accumulation and communication work. A follow-up must measure those costs and output expansion rather than assuming more PEs alone resolves capacity.


## Measured static allocations

Each row below describes one completed compiled configuration. Capacities cover all its registered input sessions and assignments. The largest static application ELF is shown; its code is loaded separately into each PE that uses it. Static section sums exclude hardware configuration registers and do not measure peak dynamic stack use.

| Matrix size | B degree | PEs | Declared arrays, bytes/PE | Largest static ELF allocation, bytes/PE | Text bytes in that ELF |
|---|---:|---:|---:|---:|---:|
| 16 | 3 | 1 | 2,348 | 7,932 | 4,176 |
| 16 | 3 | 4 | 1,260 | 14,322 | 11,416 |
| 16 | 3 | 16 | 948 | 14,026 | 11,432 |
| 64 | 3 | 1 | 9,228 | 14,812 | 4,176 |
| 64 | 3 | 4 | 6,796 | 19,858 | 11,416 |
| 64 | 3 | 16 | 4,524 | 17,602 | 11,432 |
| 64 | 3 | 64 | 2,868 | 15,946 | 11,432 |
| 64 | 8 | 1 | 42,252 | 47,836 | 4,176 |
| 64 | 8 | 4 | 14,220 | 27,282 | 11,416 |
| 64 | 8 | 16 | 7,212 | 20,290 | 11,432 |
| 64 | 8 | 64 | 5,460 | 18,538 | 11,432 |

One-PE builds use the small local callback adapter; multi-PE builds include the installed collective library. Code/storage changes therefore accompany the reduction in local A/C rows. More PEs do not imply that every component of per-PE storage shrinks.
