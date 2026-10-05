#!/usr/bin/env python3
"""Package the Vite build and evidence into one portable, offline HTML file."""
from pathlib import Path
import argparse
import re

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out',type=Path,default=Path('../results/gemm-walkthrough/gemm.html'))
    ap.add_argument('--page',default='index.html')
    ap.add_argument('--dist',default='dist')
    ap.add_argument('--bundle',default='bundle.json')
    ap.add_argument('--global-name',default='GEMM_BUNDLE')
    a=ap.parse_args();root=Path(__file__).resolve().parent;dist=root/a.dist
    if not re.fullmatch(r'[A-Za-z_][A-Za-z_0-9]*',a.global_name):ap.error('Invalid JavaScript global name')
    page=(dist/a.page).read_text()
    def script(m):
        src=(dist/m[1].removeprefix('./')).read_text().replace('</script','<\\/script')
        return '<script type="module">'+src+'</script>'
    def css(m):return '<style>'+(dist/m[1].removeprefix('./')).read_text()+'</style>'
    page=re.sub(r'<script type="module" crossorigin src="([^"]+)"></script>',script,page)
    page=re.sub(r'<link rel="stylesheet" crossorigin href="([^"]+)">',css,page)
    data=(dist/a.bundle).read_text().replace('<','\\u003c')
    page=page.replace('<head>','<head><script>window.'+a.global_name+'='+data+';</script>',1)
    a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(page)
    print(a.out.resolve(),a.out.stat().st_size,'bytes')

if __name__=='__main__':main()
