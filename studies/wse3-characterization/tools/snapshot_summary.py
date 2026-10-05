#!/usr/bin/env python3
"""Cross-check csdb memory/GPR reads against ELF-core reads, then export small UI data."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct

ROOT=Path(__file__).resolve().parents[1]
def build(root):
    cases=[]
    for kind in ['single','relay','gemm']:
        path=root/kind/'stopped-validation.json';data=json.loads(path.read_text())
        case=dict(id=kind,title={'single':'One PE · 7 + 5 and 19 + 23','relay':'Two PEs · send 11, add 30','gemm':'Four PEs · 4×4 GEMM'}[kind],phases={},sources=[])
        for phase in ['loaded','computed']:
            row=data['phases'][phase];assert row['passed'],(kind,phase)
            logpath=root/kind/f'stopped-{phase}'/'csdb.log';log=logpath.read_text()
            memory={}
            for x,y,addr,words in re.findall(r'\((\d+),(\d+)\) @ 0x([0-9a-f]+): ([0-9a-f ]+)',log):
                memory[(int(x),int(y),int(addr,16))]=[int(w,16) for w in words.split()]
            for key,values in row['sram'].items():
                sym=row['symbols'][key];x,y=sym['fabric']
                words=values if kind=='single' else [part for v in values for part in [v&65535,v>>16]]
                assert memory[(x,y,sym['byte_address']//2)]==words,(kind,phase,key,'csdb SRAM mismatch')
            registers={}
            for pe,values in row['gpr_u16'].items():
                x,y=map(int,pe.split(','));pattern=rf'\({x+4}, {y+1}\).*ce_gpr\[(\d+)\] value:([0-9a-f]+)'
                observed={int(i):int(v,16) for i,v in re.findall(pattern,log)}
                assert [observed[i] for i in range(16)]==values,(kind,phase,pe,'GPR mismatch')
                registers[pe]=[line for line in log.splitlines() if line.startswith(f'({x+4}, {y+1})') and re.search(r'ce_(?:gpr|dst_dsr|s0_dsr|s1_dsr|sp |pcr |psr |pipe_status|mt_ip|inp_queue_status|outp_queue_status)',line)]
            case['phases'][phase]=dict(sram=row['sram'],values={k:v if kind=='single' else [struct.unpack('<f',struct.pack('<I',x))[0] for x in v] for k,v in row['sram'].items()},
                symbols=row['symbols'],gpr_u16=row['gpr_u16'],registers=registers,passed=True,
                evidence='ELF core SRAM/GPR reads agree with csdb and expected values; independent stopped run; no D2H before dump')
            for p in [path,logpath,root/kind/f'stopped-{phase}'/'state.elf']:
                case['sources'].append(dict(path=str(p.relative_to(ROOT)),sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
        cases.append(case)
    return dict(schema='snapshot-summary/1',cases=cases,cycle_exact=False,
                note='Each phase comes from a separate simulator run stopped at a host boundary. GPR values include runtime completion state. No correspondence to the older GEMM/GEMV trace cycles is asserted.')
def main():
    ap=argparse.ArgumentParser();ap.add_argument('--root',type=Path,default=ROOT/'results/snapshots/try-20260918b')
    ap.add_argument('--out',type=Path,default=ROOT/'results/snapshots/summary.json');a=ap.parse_args()
    result=build(a.root.resolve());a.out.write_text(json.dumps(result,indent=2)+'\n')
    print(len(result['cases']),'cases: SRAM and all 16 named ce_gpr words agree with csdb at both stopped phases')
if __name__=='__main__':main()
