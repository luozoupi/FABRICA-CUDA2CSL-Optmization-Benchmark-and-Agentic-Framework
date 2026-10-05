#!/usr/bin/env python3
"""Local read-only data service and WebGL application. No device/compile endpoints.

GET /api/scenes; /api/scenes/<id>; /events?start=&end=&offset=&limit=;
/frame?cycle=; /lineage?output=. Event times are simulator cycles only.
"""
import argparse
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
import json
from pathlib import Path
from urllib.parse import parse_qs, unquote, urlsplit

ROOT=Path(__file__).resolve().parents[1]

def frame_at(scene,cycle):
    state={p['id']:dict(partial=[None]*scene['slots'],peer=[None]*scene['slots'],
                      result=[None]*scene['slots'],latest=None) for p in scene['pes']}
    for e in scene['events']:
        if e['cycle']>cycle:break
        p=state[e['pe']];p['latest']=e
        if e['kind']=='checkpoint':
            for k,v in e.get('values',{}).items():p[k]=v
        elif e['kind']=='accumulate':p['partial'][e['index']]=e['value']
        elif e['kind']=='reduce':p['result'][e['index']]=e['value']
    return dict(cycle=cycle,pes=state,evidence='latest observed values; not continuous SRAM/register snapshots')

def lineage(scene,output):
    n=scene['n'];i,j=divmod(output,n) if scene['kind']=='gemm' else (0,output)
    selected=[]
    for e in scene['events']:
        if e['kind']=='checkpoint':continue
        if scene['kind']=='gemm':match=e.get('i')==i and e.get('j')==j
        elif e['kind']=='reduce':
            pe=next(p for p in scene['pes'] if p['id']==e['pe'])
            match=e.get('index')==j%scene['t'] and pe['x']==j//scene['t']
        else:match=e.get('j')==j
        if match:selected.append(e)
    return dict(output=output,events=selected,evidence='matched instruction operands and results')

class Handler(SimpleHTTPRequestHandler):
    def __init__(self,*a,data,**kw):self.data=data;super().__init__(*a,**kw)
    def json_response(self,value,status=200):
        body=json.dumps(value,separators=(',',':'),allow_nan=False).encode()
        self.send_response(status);self.send_header('Content-Type','application/json')
        self.send_header('Content-Length',str(len(body)));self.send_header('Cache-Control','no-cache')
        self.send_header('X-Content-Type-Options','nosniff');self.end_headers();self.wfile.write(body)
    def do_GET(self):
        url=urlsplit(self.path)
        if not url.path.startswith('/api/'):
            if url.path=='/':self.path='/dataflow.html' if (Path(self.directory)/'dataflow.html').exists() else '/matmul.html'
            # The static root is only the built viewer, not the study or $HOME.
            rel=unquote(urlsplit(self.path).path).lstrip('/')
            dest=(Path(self.directory)/rel).resolve()
            if not dest.is_relative_to(Path(self.directory).resolve()) or dest.is_dir():
                self.send_error(404);return
            return super().do_GET()
        parts=url.path.strip('/').split('/');q=parse_qs(url.query)
        try:
            if parts==['api','health']:
                return self.json_response(dict(status='ok',schema=self.data['schema']))
            if parts==['api','snapshots']:
                return self.json_response(self.data.get('snapshots'))
            if parts==['api','matmul']:
                if self.data.get('matmul') is None:return self.json_response({'error':'Matmul comparison unavailable'},404)
                return self.json_response(self.data['matmul'])
            if parts==['api','scenes']:
                return self.json_response([dict(id=s['id'],title=s['title'],kind=s['kind'],n=s['n'],p=s['p'],start=s['start'],end=s['end']) for s in self.data['scenes']])
            if len(parts)<3 or parts[:2]!=['api','scenes']:return self.json_response({'error':'Not found'},404)
            scene=next((s for s in self.data['scenes'] if s['id']==parts[2]),None)
            if scene is None:return self.json_response({'error':'Unknown scene'},404)
            if len(parts)==3:return self.json_response(scene)
            if parts[3:] == ['walkthrough']:
                return self.json_response(scene['teaching'])
            def integer(key,default):
                v=int(q.get(key,[str(default)])[0])
                if abs(v)>2**53:raise ValueError('Integer outside supported range')
                return v
            if parts[3:] == ['frame']:
                return self.json_response(frame_at(scene,integer('cycle',scene['start'])))
            if parts[3:] == ['lineage']:
                output=integer('output',0);maximum=scene['n']**(2 if scene['kind']=='gemm' else 1)
                if not 0<=output<maximum:raise ValueError('Output index outside tensor')
                return self.json_response(lineage(scene,output))
            if parts[3:] == ['events']:
                start=integer('start',scene['start']);end=integer('end',scene['end'])
                offset=integer('offset',0);limit=integer('limit',200)
                if offset<0 or not 1<=limit<=2000 or start>end:raise ValueError('Invalid event window or pagination')
                rows=[e for e in scene['events'] if start<=e['cycle']<=end]
                return self.json_response(dict(total=len(rows),events=rows[offset:offset+limit],next_offset=offset+limit if offset+limit<len(rows) else None))
            return self.json_response({'error':'Not found'},404)
        except (ValueError,TypeError) as e:return self.json_response({'error':str(e)},400)

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--port',type=int,default=8765);ap.add_argument('--host',default='127.0.0.1')
    ap.add_argument('--bundle',type=Path,default=ROOT/'viewer/public/dataflow-bundle.json')
    ap.add_argument('--static',type=Path,default=ROOT/'viewer/dist/dataflow')
    a=ap.parse_args();data=json.loads(a.bundle.read_text())
    comparison=ROOT/'viewer/public/matmul-bundle.json'
    if comparison.is_file():data['matmul']=json.loads(comparison.read_text())
    if data['schema']!='wse-dataflow/1':raise SystemExit('Unsupported bundle schema')
    if not any((a.static/p).is_file() for p in ('dataflow.html','matmul.html')):raise SystemExit('Build viewer first: npm run build:dataflow or npm run build:matmul')
    server=ThreadingHTTPServer((a.host,a.port),partial(Handler,data=data,directory=str(a.static.resolve())))
    entry='dataflow.html' if (a.static/'dataflow.html').exists() else 'matmul.html'
    print(f'WSE viewer: http://{a.host}:{server.server_port}/{entry}',flush=True)
    try:server.serve_forever()
    except KeyboardInterrupt:pass
    finally:server.server_close()

if __name__=='__main__':main()
