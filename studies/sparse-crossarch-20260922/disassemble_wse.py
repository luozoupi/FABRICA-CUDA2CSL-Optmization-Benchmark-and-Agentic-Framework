"""Disassemble exact compiled ELF files without modifying them."""
import fcntl,json,os,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'tools'))
from csdisasm import parse_am
script="""import glob,pathlib,subprocess
tool=glob.glob('/cb/toolchains/llvm/cerebras/*/bin/elf2am')[0]
for d in pathlib.Path('wse').iterdir():
 for elf in (d/'out/bin').glob('*.elf'):
  target=d/(elf.stem+'.am')
  if not target.exists():subprocess.run([tool,'-o='+str(target),str(elf)],check=True)
"""
with open('/tmp/xkernel_singularity.lock','a')as lock:
    fcntl.flock(lock,fcntl.LOCK_EX)
    sdk=Path(os.environ.get('CEREBRAS_SDK_DIR',str(ROOT.parent/'cs_sdk'))).expanduser()
    p=subprocess.run([str(sdk/'cs_python'),'-c',script],cwd=ROOT,capture_output=True,text=True,timeout=300)
    (ROOT/'disassembly.log').write_text(p.stdout+p.stderr);p.check_returncode()
for d in (ROOT/'wse').iterdir():
    rows={p.name:parse_am(p)for p in d.glob('*.am')}
    if rows:(d/'disassembly.json').write_text(json.dumps(rows,indent=2)+'\n')
print('Disassembled all currently compiled WSE ELF files')
