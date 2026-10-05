"""Audit sparse replay traces inside timer windows; count events, not inferred stalls."""
import argparse
from collections import Counter
import hashlib
import json
import math
from pathlib import Path
import re
import statistics
import struct
import sys


def require(condition, message):
    if not condition: raise ValueError(message)


def sha(path):
    h=hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda:f.read(1024*1024),b''): h.update(block)
    return h.hexdigest()


def f32(word): return struct.unpack('<f',struct.pack('<I',word))[0]
def round32(value): return struct.unpack('<f',struct.pack('<f',value))[0]


def elf_text(path):
    b=path.read_bytes(); require(b[:6]==b'\x7fELF\x02\x01','Unsupported ELF')
    h=struct.unpack_from('<HHIQQQIHHHHHH',b,16)
    ss=[struct.unpack_from('<IIQQQQIIQQ',b,h[5]+i*h[10]) for i in range(h[11])]
    s=ss[h[12]]; names=b[s[4]:s[4]+s[5]]
    for s in ss:
        if names[s[0]:].split(b'\0')[0]==b'.text': return s[3],b[s[4]:s[4]+s[5]]
    raise ValueError('No .text section')


def stats(values):
    return dict(min=min(values),median=statistics.median(values),max=max(values)) if values else None


