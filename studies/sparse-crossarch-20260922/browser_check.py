"""Check the offline comparison UI through Chrome's debugging protocol."""
import base64,json,subprocess,tempfile,time
from pathlib import Path
import requests,websocket
ROOT=Path(__file__).resolve().parent
with tempfile.TemporaryDirectory(prefix='sparse-browser-')as profile:
    with open(ROOT/'browser.log','w')as log:
        browser=subprocess.Popen(['google-chrome','--headless','--no-sandbox','--disable-gpu','--disable-dev-shm-usage','--no-first-run','--remote-debugging-port=0','--remote-debugging-address=127.0.0.1','--remote-allow-origins=http://localhost','--user-data-dir='+profile,'about:blank'],stdout=log,stderr=log)
        try:
            for _ in range(100):
                p=Path(profile)/'DevToolsActivePort'
                if p.exists():break
                time.sleep(.1)
            port=p.read_text().splitlines()[0];http=requests.Session();http.trust_env=False;page=next(p for p in http.get(f'http://127.0.0.1:{port}/json').json()if p['type']=='page')
            ws=websocket.create_connection(page['webSocketDebuggerUrl'],origin='http://localhost',timeout=60);serial=0;errors=[]
            def call(method,params=None):
                global serial
                serial+=1;ws.send(json.dumps(dict(id=serial,method=method,params=params or {})))
                while True:
                    r=json.loads(ws.recv())
                    if r.get('method')=='Runtime.exceptionThrown':errors.append(r)
                    if r.get('id')==serial:
                        if 'error'in r:raise RuntimeError(r['error'])
                        return r.get('result',{})
            def js(code):
                r=call('Runtime.evaluate',dict(expression=code,returnByValue=True,awaitPromise=True))
                if 'exceptionDetails'in r:raise AssertionError(r['exceptionDetails'])
                return r.get('result',{}).get('value')
            call('Runtime.enable');call('Page.enable');call('Emulation.setDeviceMetricsOverride',dict(width=1440,height=1100,deviceScaleFactor=1,mobile=False));call('Page.navigate',dict(url=(ROOT/'index.html').as_uri()))
            for _ in range(100):
                if js('Boolean(window.sparseLab)'):break
                time.sleep(.1)
            report=js("""(()=>{const $=id=>document.getElementById(id);function change(id,v){$(id).value=v;$(id).dispatchEvent(new Event('change'))}let cells=0,rows=0;
              for(const m of [...$('matrix-choice').options]){change('matrix-choice',m.value);for(const n of [...$('width-choice').options]){change('width-choice',n.value);if(!$('gpu-table').textContent.includes('GE'))throw Error('Missing GPU records');cells++;
                if(m.value.startsWith('32x64'))for(let r=0;r<32;r++){change('row-choice',r);$('end').click();const s=sparseLab.state;if(!s.sums.every((x,j)=>x===s.expected[j]))throw Error('row mismatch');rows++;$('back').click();$('next').click()}
              }}
              change('matrix-choice','32x64-uniform8');change('width-choice',16);change('flow-mode','ge');$('next').click();change('pes',64);change('reuse',10);change('timing','single');change('timing','graph');
              return {workloadViews:cells,completedRows:rows,allControls:true};
            })()""")
            shot=call('Page.captureScreenshot',dict(format='png'));(ROOT/'preview.png').write_bytes(base64.b64decode(shot['data']))
            call('Emulation.setDeviceMetricsOverride',dict(width=390,height=844,deviceScaleFactor=1,mobile=True))
            report['mobile']=js('({width:innerWidth,scroll:document.documentElement.scrollWidth})');assert report['mobile']['scroll']<=390
            shot=call('Page.captureScreenshot',dict(format='png'));(ROOT/'preview-mobile.png').write_bytes(base64.b64decode(shot['data']))
            report['errors']=errors;assert not errors
            (ROOT/'browser-report.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
        finally:browser.terminate();browser.wait(timeout=10)

