"""Plot compact, trace-verified simulator evidence. No hardware performance claim."""
import json
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
ROOT=Path(__file__).resolve().parent
summary=json.loads((ROOT/'summary.json').read_text())
names=['scalar-n1','descriptor-n1','scalar-n4','descriptor-n4','descriptor-n16','hoisted-n16']
labels=['Scalar\nw=1','Descriptor\nw=1','Scalar\nw=4','Descriptor\nw=4','Descriptor\nw=16','Hoisted\nw=16']
rows={(r['case'],r['family']):r for r in summary['rows']}
x=np.arange(len(names));fig,axes=plt.subplots(1,2,figsize=(12,4.6),layout='constrained')
for offset,family,label,color in [(-.19,'uniform8','32 nonempty rows','#28648c'),(.19,'skew8','4 nonempty rows','#d18536')]:
 values=[rows[n,family]['cycles']/1000 for n in names]
 axes[0].bar(x+offset,values,width=.36,label=label,color=color)
axes[0].set_ylabel('Simulator cycles (thousands)');axes[0].set_title('Same 256 nonzeros; different row distributions')
axes[0].legend(frameon=False,fontsize=9);axes[0].set_ylim(0,23)
bottom=np.zeros(len(names))
components=[('arithmetic_dispatches','Arithmetic','#438970'),('configuration_stores','Descriptor setup stores','#9b6354'),('explicit_nops','Explicit NOPs','#aab5bd'),('other','Other dispatches','#52677c')]
for key,label,color in components:
 vals=np.array([rows[n,'uniform8'][key] if key!='other' else rows[n,'uniform8']['dispatches']-rows[n,'uniform8']['arithmetic_dispatches']-rows[n,'uniform8']['configuration_stores']-rows[n,'uniform8']['explicit_nops'] for n in names])/1000
 axes[1].bar(x,vals,bottom=bottom,label=label,color=color,width=.7);bottom+=vals
axes[1].set_ylabel('Recorded dispatch events (thousands)');axes[1].set_title('Instruction mix for the uniform-row input')
axes[1].legend(frameon=False,fontsize=8,ncol=2,loc='upper left');axes[1].set_ylim(0,15.7)
for ax in axes:
 ax.set_xticks(x,labels,fontsize=9);ax.spines[['top','right']].set_visible(False);ax.grid(axis='y',alpha=.18);ax.set_axisbelow(True)
fig.suptitle('One-PE FP32 sparse kernels: descriptor setup must be amortized',fontsize=13)
for ext in ['png','svg','pdf']:fig.savefig(ROOT/('sparse-trace-results.'+ext),dpi=170)

# Matplotlib SVG path lines include trailing spaces; normalize for source control.
svg=ROOT/"sparse-trace-results.svg"
svg.write_text("\n".join(line.rstrip() for line in svg.read_text().splitlines())+"\n")
