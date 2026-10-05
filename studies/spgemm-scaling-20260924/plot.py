"""Standalone figures from audited complete cases; simulator cycles only."""
import json
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.ticker import ScalarFormatter
ROOT=Path(__file__).resolve().parent;s=json.loads((ROOT/'summary.json').read_text());rows=[r for r in s['rows']if r['initial']]
def pick(**kw):return sorted([r for r in rows if all(r[k]==v for k,v in kw.items())],key=lambda r:r['P'])
plt.rcParams.update({'font.size':9,'axes.spines.top':False,'axes.spines.right':False})
fig,axs=plt.subplots(2,3,figsize=(13.8,7.8),layout='constrained');colors={16:'#3b73b9',64:'#dd8034',256:'#359374'}
def timeout(r):
 return r.get('case_status','pass')!='pass' or r.get('baseline_case_status','pass') not in (None,'pass') or r.get('reference_case_status','pass')!='pass'
def mark(ax,records,field):
 points=[r for r in records if timeout(r)]
 if points:ax.scatter([r['P']for r in points],[r[field]for r in points],marker='D',s=70,facecolors='none',edgecolors='black',zorder=5)
for n in (16,64,256):
 r=pick(group='strong',variant='full',N=n,pattern='uniform',policy='row_blocks',mode='broadcast')
 if r:
  axs[0,0].plot([x['P']for x in r],[x['root_cycles']for x in r],'o-',color=colors[n],label=f'{n} × {n}')
  mark(axs[0,0],r,'root_cycles')
  good=[x for x in r if x['strong_speedup']is not None]
  axs[0,1].plot([x['P']for x in good],[x['strong_speedup']for x in good],'o-',color=colors[n],label=f'{n} × {n}')
  mark(axs[0,1],good,'strong_speedup')
axs[0,0].set(title='Full-row SpGEMM: fixed-matrix scaling',ylabel='Root interval (simulator cycles)');axs[0,0].set_yscale('log');axs[0,0].legend()
axs[0,1].plot([1,64],[1,64],':',color='0.55',label='Linear reference');axs[0,1].set(title='Speedup includes communication',ylabel='Speedup over matching one-PE run');axs[0,1].set_yscale('log',base=2);axs[0,1].legend()
for mode,style,label in [('broadcast','o-','B broadcast + compute + completion'),('resident','s--','Start token + compute + completion')]:
 r=pick(group='weak',variant='full',pattern='uniform',policy='row_blocks',mode=mode)
 if r:axs[0,2].plot([x['P']for x in r],[x['root_cycles']for x in r],style,label=label)
 mark(axs[0,2],r,'root_cycles')
r=pick(group='weak',variant='full',pattern='uniform',policy='row_blocks',mode='broadcast')
if r:axs[0,2].plot([x['P']for x in r],[x['local_max']for x in r],'^:',label='Slowest local compute')
mark(axs[0,2],r,'local_max')
axs[0,2].set(title='Weak scaling: four output rows per PE',ylabel='Simulator cycles');axs[0,2].legend(fontsize=7)
for n in (16,64,256):
 r=sorted([x for x in s['comparisons']if x['kind']=='partition'and x['N']==n and x['mode']=='broadcast'and x['case'].endswith('-full')],key=lambda x:x['P'])
 if r:axs[1,0].plot([x['P']for x in r],[x['speedup_balanced']for x in r],'o-',color=colors[n],label=f'{n} × {n}')
 mark(axs[1,0],r,'speedup_balanced')
 r=sorted([x for x in s['comparisons']if x['kind']=='accumulator'and x['N']==n and x['mode']=='broadcast'and x['pattern']=='uniform'and x['policy']=='row_blocks'],key=lambda x:x['P'])
 if r:axs[1,1].plot([x['P']for x in r],[x['ratio_tiled_over_full']for x in r],'o-',color=colors[n],label=f'{n} × {n}')
 mark(axs[1,1],r,'ratio_tiled_over_full')
axs[1,0].axhline(1,color='0.6',ls=':');axs[1,0].set(title='Balancing clustered long rows',ylabel='Equal-row / balanced root time');axs[1,0].legend()
axs[1,1].axhline(1,color='0.6',ls=':');axs[1,1].set(title='Cost of bounded accumulator storage',ylabel='Bounded / full-row root time');axs[1,1].legend()
for degree,group,style in ((3,'strong','o-'),(8,'density','s--')):
 r=pick(group=group,variant='full',N=64,pattern='uniform',policy='row_blocks',mode='broadcast')
 if r:axs[1,2].plot([x['P']for x in r],[x['root_cycles']for x in r],style,label=f'{degree} entries per input row')
 mark(axs[1,2],r,'root_cycles')
axs[1,2].set(title='Density control: 64 × 64 matrices',ylabel='Root interval (simulator cycles)');axs[1,2].set_yscale('log');axs[1,2].legend()
for ax in axs.flat:
 ax.set_xscale('log',base=4);ax.set_xticks([1,4,16,64]);ax.xaxis.set_major_formatter(ScalarFormatter());ax.set_xlabel('Application PEs');ax.grid(True,alpha=.18)
note=f"{s['case_statuses'].get('pass',0)}/{s['registered_cases']} configurations passed"
if s['timeout_cases_with_verified_timings']:note+=' · Hollow diamonds: validated records from timed-out suites (or their baselines)'
if not s['all_registered_complete']:note+=' · Sweep still running'
fig.suptitle('SpGEMM on the WSE-3 SDK simulator: local work, memory and communication\n'+note,fontsize=12)
for ext in ('png','pdf','svg'):fig.savefig(ROOT/f'scaling.{ext}',dpi=180)
p=ROOT/'scaling.svg';p.write_text('\n'.join(line.rstrip()for line in p.read_text().splitlines())+'\n')
print('Saved scaling figures')
