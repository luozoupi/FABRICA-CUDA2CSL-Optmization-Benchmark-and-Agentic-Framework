"""Check every published explorer selection in a real headless browser."""
import datetime,json,re,subprocess,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parent
script=r'''
<script>
try {
 const assert=(ok,msg)=>{if(!ok)throw Error(msg);};let checks=0;
 for (const expected of data.rows) {
  $('case').value=expected.case;resetInput();$('input').value=expected.pattern+'|'+expected.policy;$('mode').value=expected.mode;render();
  assert($('root').textContent===fmt(expected.root_cycles),'Root value mismatch');
  assert($('grid').children.length===expected.P,'PE count mismatch');
  assert($('bars').children.length===expected.P,'Bar count mismatch');
  for(let i=0;i<3;i++){$('repetition').value=String(i);renderPhases();assert($('phase-values').textContent.includes('Total: '+fmt(expected.root_samples[i])+' cycles'),'Root phase total mismatch');assert(expected.root_phases[i].reduce((a,b)=>a+b,0)===expected.root_samples[i],'Root intervals do not sum to total');}
  for(let p=0;p<expected.P;p++) {
   $('grid').children[p].click();
   assert($('detail').textContent.includes(fmt(expected.local_cycles[p])+' cycles'),'PE local value mismatch');
   assert($('grid').children[p].getAttribute('aria-pressed')==='true','Selected PE missing');
  }
  for(let i=0;i<5;i++){$('steps').children[i].click();assert($('steptext').textContent.includes(descriptions[i]),'Protocol description mismatch');}
  assert(document.documentElement.scrollWidth<=window.innerWidth+1,'Horizontal page overflow');
  checks++;
 }
 document.body.setAttribute('data-verification',String(checks));
 document.body.setAttribute('data-viewport-width',String(window.innerWidth));
} catch(error) {document.body.setAttribute('data-verification-error',error.message);}
</script>
'''
results=[]
for width in (420,1440):
 with tempfile.TemporaryDirectory(prefix='spgemm-explorer-check-')as tmp:
  tmp=Path(tmp);page=tmp/'check.html';page.write_text((ROOT/'explorer.html').read_text()+script)
  run=subprocess.run(['google-chrome','--headless','--no-sandbox','--disable-gpu','--disable-background-networking','--disable-dev-shm-usage','--user-data-dir='+str(tmp/'profile'),f'--window-size={width},1100','--virtual-time-budget=2000','--dump-dom',page.as_uri()],capture_output=True,text=True,timeout=60)
  assert run.returncode==0,run.stderr[-1000:]
  errors=re.findall(r'data-verification-error="([^"]*)"',run.stdout);assert not errors,errors
  counts=re.findall(r'data-verification="([0-9]+)"',run.stdout);assert len(counts)==1
  expected=sum(r['initial']for r in json.loads((ROOT/'summary.json').read_text())['rows']);assert int(counts[0])==expected
  actual=re.findall(r'data-viewport-width="([0-9]+)"',run.stdout);assert len(actual)==1
  results.append(dict(requested_width=width,actual_viewport_width=int(actual[0]),record_selections_checked=expected,status='pass'))
(ROOT/'explorer-checks.json').write_text(json.dumps(dict(created_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),checks=results),indent=2)+'\n')
print(results)
