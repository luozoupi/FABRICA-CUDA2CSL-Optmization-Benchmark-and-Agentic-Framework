#!/bin/bash
# Statically disassemble every compiled PE ELF in the kernel corpus.
# Each ELF is copied into a scratch dir because the SDK container mounts only cwd.
OUT=${1:-$HOME/xkernel/studies/wse3-characterization/results/disasm}
SCRATCH=/tmp/disasm_work
TOOL=$HOME/xkernel/studies/wse3-characterization/tools/csdisasm.py
mkdir -p "$OUT"; rm -rf "$SCRATCH"; mkdir -p "$SCRATCH"
n=0; f=0
cd "$HOME/xkernel/kernels" || exit 1
for d in */CSL; do
  k=$(dirname "$d"); safe=$(echo "$k" | tr ' /' '__')
  for elf in "$d"/out/bin/out_*.elf; do
    [ -f "$elf" ] || continue
    tag="${safe}__$(basename "$elf" .elf)"
    cp "$elf" "$SCRATCH/$tag.elf" 2>/dev/null || continue
    ( cd "$SCRATCH" && python3 "$TOOL" "$tag.elf" --json "$OUT/$tag.json" --summary >"$OUT/$tag.txt" 2>"$OUT/$tag.err" ) \
      && { echo "ok   $tag"; n=$((n+1)); } || { echo "FAIL $tag"; f=$((f+1)); }
    rm -f "$SCRATCH/$tag.elf" "$SCRATCH/$tag.am"
  done
done
echo "disassembled $n ELFs, $f failures -> $OUT"
