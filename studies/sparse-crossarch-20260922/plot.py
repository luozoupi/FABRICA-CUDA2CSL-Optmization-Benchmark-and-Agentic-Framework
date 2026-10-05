"""Export measured implementation trends; units and evidence types stay separate."""
import hashlib,json
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
ROOT=Path(__file__).resolve().parent
x=json.loads((ROOT/'results.json').read_text())
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,'svg.fonttype':'none','pdf.fonttype':42})
fig,ax=plt.subplots(1,3,figsize=(13.3,3.7),layout='constrained')
widths=[1,4,16,32,64,128]
for method,label in [('ge_plain','GE plain'),('ge_cache','GE row caching'),('ge_merge2','GE two outputs/thread'),('best','Best tested cuSPARSE')]:
    yy=[]
    for n in widths:
        rows=[r for r in x['gpu']if r['case']==f'65536x65536-uniform8-n{n}'and r['batch']=='gpu'and r['status']=='pass'and (r['method'].startswith('cusparse')if method=='best'else r['method']==method)]
        yy.append(min(r['graph']['median']for r in rows))
    ax[0].plot(widths,yy,'o-',label=label,markersize=4)
ax[0].set(xscale='log',yscale='log',xlabel='Dense output columns',ylabel='GPU graph time / operation (µs)',title='Measured CUDA: 65,536-square, degree 8');ax[0].set_xticks(widths,labels=widths);ax[0].legend(fontsize=8)
for method,label in [('scalar','CSL scalar'),('descriptor','CSL row descriptor'),('hoisted','CSL descriptor hoisted')]:
    rows=sorted([r for r in x['wse']if '32x64-uniform8-'in r['case']and r['variant']==method],key=lambda r:r['N'])
    ax[1].plot([r['N']for r in rows],[r['cycles']['median']for r in rows],'^--'if method=='hoisted'else'o-',label=label,markersize=5)
ax[1].set(xscale='log',xlabel='Dense output columns',ylabel='One-PE simulator cycles',title='Verified CSL: 32 × 64, degree 8');ax[1].set_xticks([1,4,16,64],labels=[1,4,16,64]);ax[1].legend(fontsize=8);ax[1].text(.02,.96,'Missing points: full run timed out',transform=ax[1].transAxes,va='top',fontsize=8)
patterns=['banded8','block8','skew8'];positions=np.arange(3)
for offset,kind,label in [(-.18,'equal_rows','Equal rows'),(.18,'balanced_whole_rows','Balance nonzeros')]:
    counts=[next(v['total_B_row_copies']for v in x['partition']['rows']if v['matrix']==f'65536x65536-{p}'and v['pes']==16 and v['partition']==kind)for p in patterns]
    ax[2].bar(positions+offset,np.array(counts)/1000,.36,label=label)
ax[2].set_xticks(positions,labels=['Banded','Block','Skewed']);ax[2].set(ylabel='Distinct B-row copies (thousands)',title='Static prediction: 16 PE groups');ax[2].legend(fontsize=8)
for a in ax:a.grid(axis='y',alpha=.2)
for ext in ('svg','pdf','png'):fig.savefig(ROOT/('comparison-figure.'+ext),dpi=180)
(ROOT/'figure-provenance.json').write_text(json.dumps(dict(source_sha256=hashlib.sha256((ROOT/'results.json').read_bytes()).hexdigest(),script_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),scope='Panel 1 measured GPU, panel 2 verified local simulator cycles, panel 3 static input-derived partition prediction; no cross-architecture speedup'),indent=2)+'\n')
print('Exported SVG, PDF and PNG')
