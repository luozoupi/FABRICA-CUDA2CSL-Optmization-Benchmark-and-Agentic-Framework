"""Generate standalone plots from the audited summary, without refitting results."""
import json
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
ROOT=Path(__file__).resolve().parent;s=json.loads((ROOT/'summary.json').read_text())
plt.rcParams.update({'font.size':10,'svg.hashsalt':'spgemm-followup-20260924'})
fig,axes=plt.subplots(1,2,figsize=(12,4.6),layout='constrained')
rows=s['final_comparison']['rows'];names=[r['pattern'].replace('_',' ') for r in rows];speed=[r['speedup'] for r in rows]
axes[0].barh(names,speed,color=['#238b45' if x>1 else '#b2182b' for x in speed]);axes[0].axvline(1,color='black',linewidth=1,linestyle='--');axes[0].invert_yaxis();axes[0].set_xlabel('Baseline cycles / selected-kernel cycles');axes[0].set_title('Masked product: frozen choice on final tests')
for i,x in enumerate(speed):axes[0].text(x+.01,i,f'{x:.2f}×',va='center',fontsize=9)
axes[0].set_xlim(0,max(speed)*1.19)
r=[r for r in s['groups']['general']['rows'] if r['session']==0];patterns=list(dict.fromkeys(x['pattern'] for x in r));pos=np.arange(len(patterns));width=.37
for offset,name,label,color in [(-width/2,'full_row','16 accumulator slots','#2166ac'),(width/2,'tile4','4 accumulator slots','#ef8a62')]:
 vals=[next(x['cycles'] for x in r if x['pattern']==p and x['case']==name) for p in patterns]
 axes[1].bar(pos+offset,vals,width,label=label,color=color)
axes[1].set_xticks(pos,patterns,rotation=35,ha='right');axes[1].set_yscale('log');axes[1].set_ylabel('Simulator cycles, logarithmic scale');axes[1].set_title('Full SpGEMM: accumulator capacity tradeoff');axes[1].legend(fontsize=9)
fig.suptitle('SDK 2.10.1 · one application PE · 16×16 inputs · no hardware latency claim',fontsize=11)
for suffix in ('png','pdf','svg'):fig.savefig(ROOT/('spgemm-followup.'+suffix),dpi=180)
p=ROOT/'spgemm-followup.svg';p.write_text('\n'.join(line.rstrip() for line in p.read_text().splitlines())+'\n')
