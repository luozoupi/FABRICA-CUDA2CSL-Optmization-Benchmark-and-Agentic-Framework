import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parent
data=json.loads((ROOT/'results.json').read_text())
text=(ROOT/'viewer-template.html').read_text().replace('__DATA__',json.dumps(data,separators=(',',':')).replace('</','<\\/'))
(ROOT/'index.html').write_text(text)
(ROOT/'viewer-manifest.json').write_text(json.dumps(dict(html_sha256=hashlib.sha256(text.encode()).hexdigest(),results_sha256=hashlib.sha256((ROOT/'results.json').read_bytes()).hexdigest()),indent=2)+'\n')
print('Packaged cross-architecture explorer')
