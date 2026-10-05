"""Explain the measured/analytical memory boundary without claiming unrun points fit."""
import json
from pathlib import Path
r=Path(__file__).resolve().parent;e=json.loads((r/'capacity-envelope.json').read_text())['records']
lines=['# Memory limits of replicated B','',
'The measured implementation places a complete CSR copy of B on every application PE. More PEs reduce local A rows and output capacity, but do not reduce that B copy. The following additional sizes are **analytical allocation calculations only**; they have not been compiled or run in this sweep. The same calculation exactly reproduces all 24 non-weak registered configurations.','',
'| Size | B degree | PEs | Variant | B bytes per PE | Declared application bytes per PE | Array-only assessment |','|---|---:|---:|---|---:|---:|---|']
for x in e:
 if (x['N'],x['P'],x['degree'])not in ((512,16,3),(512,64,3),(1024,64,3),(1024,256,3),(1024,256,8),(2048,256,3)):continue
 lines.append(f"| {x['N']} | {x['degree']} | {x['P']} | {x['variant']} | {x['B_bytes']:,} | {x['declared_application_bytes']:,} | {'Exceeds 48 KiB'if x['arrays_exceed_48KiB']else 'Compiler and runtime check required'} |")
lines+=['','These numbers include declared application arrays and guard slots; they exclude compiler-generated code, collective-library storage, alignment, and dynamic stack use. A number below 48 KiB is not evidence that a compiled program fits. Smaller accumulators can reduce scratch storage, but cannot remove the replicated-B limit.','',
'At size 1,024 with eight entries per B row, the B packet alone occupies 69,640 bytes. At size 2,048 with three entries per B row, it occupies 57,352 bytes. Both exceed 48 KiB independently of the number of PEs. This is a limit of this data placement and representation, not a limit on the matrix size the WSE can process.','',
'Extending the algorithm requires partitioning or streaming B, or a more compact index representation with checked bounds. Row/column blocks can distribute B storage, but then require scheduling remote B rows and possibly merging partial output rows. Splitting costly output rows can address the load imbalance observed in the small sweep, while adding accumulation and communication work. A follow-up must measure those costs and output expansion rather than assuming more PEs alone resolves capacity.','']
summary=json.loads((r/'summary.json').read_text())
lines+=['','## Measured static allocations','',
'Each row below describes one completed compiled configuration. Capacities cover all its registered input sessions and assignments. The largest static application ELF is shown; its code is loaded separately into each PE that uses it. Static section sums exclude hardware configuration registers and do not measure peak dynamic stack use.','',
'| Matrix size | B degree | PEs | Declared arrays, bytes/PE | Largest static ELF allocation, bytes/PE | Text bytes in that ELF |',
'|---|---:|---:|---:|---:|---:|']
for c in sorted(summary['cases'],key=lambda x:(x['N'],x['degree'],x['P'])):
 if c['status']!='pass' or c['group']=='weak' or c['variant']!='full':continue
 memory=max(c['elf_memory'].values(),key=lambda x:x['low_address_allocated_section_bytes'])
 text_bytes=sum(x['bytes']for x in memory['sections']if x['name']=='.text')
 lines.append(f"| {c['N']} | {c['degree']} | {c['P']} | {c['declared_application_bytes']:,} | {c['max_allocated_section_bytes']:,} | {text_bytes:,} |")
lines+=['','One-PE builds use the small local callback adapter; multi-PE builds include the installed collective library. Code/storage changes therefore accompany the reduction in local A/C rows. More PEs do not imply that every component of per-PE storage shrinks.','']
(r/'MEMORY.md').write_text('\n'.join(lines))
