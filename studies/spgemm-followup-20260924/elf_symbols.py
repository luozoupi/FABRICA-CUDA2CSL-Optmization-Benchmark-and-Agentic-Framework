"""Read ELF64 symbol sizes without invoking or modifying the compiler."""
import json,struct
from pathlib import Path
ROOT=Path(__file__).resolve().parent

def symbols(path):
 b=path.read_bytes();assert b[:6]==b'\x7fELF\x02\x01';h=struct.unpack_from('<HHIQQQIHHHHHH',b,16)
 sections=[struct.unpack_from('<IIQQQQIIQQ',b,h[5]+i*h[10]) for i in range(h[11])];result=[]
 for s in sections:
  if s[1]!=2:continue
  strings=sections[s[6]];names=b[strings[4]:strings[4]+strings[5]];assert s[9]==24
  for offset in range(s[4],s[4]+s[5],s[9]):
   name,info,other,section,value,size=struct.unpack_from('<IBBHQQ',b,offset)
   text=names[name:].split(b'\0',1)[0].decode('utf-8','replace')
   result.append(dict(name=text,type=info&15,section=section,value=value,size=size))
 return result

if __name__=='__main__':
 results={}
 for d in sorted((ROOT/'general').iterdir()):
  syms=symbols(d/'out/bin/out_0_0.elf');selected=[s for s in syms if s['name'].split('.')[-1] in ('acc','seen')]
  if not selected:selected=[s for s in syms if 'acc' in s['name'] or 'seen' in s['name']]
  results[d.name]=selected;print(d.name,json.dumps(selected))
 (ROOT/'accumulator-symbols.json').write_text(json.dumps(results,indent=2)+'\n')
