"""Static distribution predictions, explicitly not measured fabric runtime."""
import heapq,json,time
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parent
def main():
    manifest=json.loads((ROOT/'inputs/manifest.json').read_text());results=[]
    for mat in manifest['matrices']:
        m,k,z=mat['M'],mat['K'],mat['nnz'];d=ROOT/'inputs'/mat['id'];rp=np.fromfile(d/'row_ptr.bin',np.int32);ix=np.fromfile(d/'col_idx.bin',np.int32);lens=np.diff(rp)
        for pe in (4,16,64,256):
            equal=[list(x)for x in np.array_split(np.arange(m),pe)]
            heap=[(0,p)for p in range(pe)];greedy=[[]for _ in range(pe)]
            for row in np.argsort(-lens,kind='stable'):
                load,p=heapq.heappop(heap);greedy[p].append(int(row));heapq.heappush(heap,(load+int(lens[row]),p))
            for name,groups in [('equal_rows',equal),('balanced_whole_rows',greedy)]:
                loads=[];refs=[];active_rows=[]
                for rows in groups:
                    loads.append(int(lens[rows].sum())if rows else 0);active_rows.append(int(np.count_nonzero(lens[rows]))if rows else 0)
                    cols=np.concatenate([ix[rp[r]:rp[r+1]]for r in rows])if rows else np.array([],np.int32)
                    refs.append(int(len(np.unique(cols))))
                results.append(dict(matrix=mat['id'],pes=pe,partition=name,nonzeros=loads,active_rows=active_rows,max_over_mean=max(loads)/(z/pe),unique_B_rows_per_pe=refs,total_B_row_copies=sum(refs),max_B_rows=max(refs),ideal_split_row_max=int(np.ceil(z/pe)),whole_row_lower_bound=max(int(lens.max()),int(np.ceil(z/pe)))))
    output=dict(scope='Static input-derived distribution predictions; B demand assumes each distinct referenced row is fetched once per PE and retained. Excludes initial ownership, routes, hops, buffering, temporal eviction, reduction, packing, and synchronization. These counts are not fabric measurements.',rows=results)
    (ROOT/'partition-analysis.json').write_text(json.dumps(output,indent=2)+'\n');print(len(results),'partition predictions')
if __name__=='__main__':main()
