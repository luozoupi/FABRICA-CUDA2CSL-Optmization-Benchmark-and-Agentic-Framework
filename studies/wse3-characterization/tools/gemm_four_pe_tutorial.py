#!/usr/bin/env python3
"""Generate a printable, numeric four-PE lesson from retained g1 evidence."""
from pathlib import Path
import hashlib
import html
import json
import struct
from markdown_it import MarkdownIt

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT/'results/four-pe-tutorial'
BLUE, GREEN, ORANGE = '#355acb', '#087d70', '#b45b12'
INK, MUTED = '#18263b', '#516279'


def matrix_product(a,b):
    return [[sum(x*y for x,y in zip(row,col)) for col in zip(*b)] for row in a]


def tile(a,r,c):
    return [row[c*2:c*2+2] for row in a[r*2:r*2+2]]


def packed(a):
    return [a[i][j] for j in range(2) for i in range(2)]


def short(a):
    return '[['+'], ['.join(', '.join(str(int(v)) for v in row) for row in a)+']]'


class Figure:
    def __init__(self,w,h,title,subtitle):
        self.w,self.h=w,h
        self.parts=[f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" role="img" aria-label="{html.escape(title)}"><title>{html.escape(title)}</title><defs>'+''.join(f'<marker id="{n}" markerWidth="10" markerHeight="10" refX="8" refY="5" orient="auto"><path d="M0,1 L8,5 L0,9" fill="none" stroke="{c}" stroke-width="1.7"/></marker>' for n,c in [('x',BLUE),('w',GREEN),('y',ORANGE),('gray',MUTED)])+'</defs>',f'<rect width="{w}" height="{h}" fill="#f7f9fd"/>']
        self.text(36,45,title,28,INK,True)
        self.text(36,78,subtitle,17,MUTED)

    def text(self,x,y,s,size=19,color=INK,bold=False):
        self.parts.append(f'<text x="{x}" y="{y}" font-size="{size}" font-family="Arial, sans-serif" font-weight="{700 if bold else 400}" fill="{color}">{html.escape(str(s))}</text>')

    def box(self,x,y,w,h,color='#d9e1ee',fill='white'):
        self.parts.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="10" fill="{fill}" stroke="{color}" stroke-width="1.5"/>')

    def mat(self,x,y,a,label,color=BLUE,cell=44,split=False):
        self.text(x,y-15,label,20,color,True)
        for i,row in enumerate(a):
            for j,v in enumerate(row):
                xx=x+j*cell;yy=y+i*cell
                fill='#eef2fc' if color==BLUE else '#eaf5f1' if color==GREEN else '#fff1e6'
                self.parts.append(f'<rect x="{xx}" y="{yy}" width="{cell-2}" height="{cell-2}" fill="{fill}"/>')
                self.parts.append(f'<text x="{xx+cell/2-1}" y="{yy+cell/2+7}" text-anchor="middle" font-size="21" font-family="monospace" fill="{INK}">{int(v)}</text>')
        if split:
            self.parts.append(f'<path d="M{x+2*cell-1},{y} v{len(a)*cell} M{x},{y+2*cell-1} h{len(a[0])*cell}" stroke="{color}" stroke-width="3"/>')

    def arrow(self,x1,y1,x2,y2,kind):
        color={'x':BLUE,'w':GREEN,'y':ORANGE,'gray':MUTED}[kind]
        self.parts.append(f'<path d="M{x1},{y1} L{x2},{y2}" stroke="{color}" stroke-width="3" fill="none" marker-end="url(#{kind})"/>')

    def save(self,name):
        text=''.join(self.parts)+'</svg>'
        (OUT/name).write_text(text)
        return text


def build():
    OUT.mkdir(parents=True,exist_ok=True)
    source=ROOT/'viewer/public/dataflow-bundle.json'
    s=next(s for s in json.loads(source.read_text())['scenes'] if s['id']=='g1')
    X,W=[q['values'] for q in s['host']['inputs']]
    Y=matrix_product(X,W)
    assert Y==s['host']['output'] and s['verification']['passed']
    original=next(q for q in json.loads((ROOT/'viewer/public/bundle.json').read_text())['scenes'] if q['id']=='g1')
    run=ROOT/original['provenance']['run']
    manifest=json.loads((run/'manifest.json').read_text())
    for name in ('pe.csl','layout.csl','run.py'):
        assert hashlib.sha256((run/name).read_bytes()).hexdigest()==manifest['sha256'][name]
    layout=(run/'layout.csl').read_text()
    assert '.x_colors = .{ @get_color(0), @get_color(1) }' in layout
    assert '.y_colors = .{ @get_color(4), @get_color(5) }' in layout
    panels=[st for st in s['teaching']['steps'] if st['phase']=='panel']
    packets={p['id']:p for p in s['packets']}
    hops=next(q for q in json.loads((ROOT/'results/pe-hops/hops.json').read_text())['scenes'] if q['id']=='g1')
    transfers=[]
    for st in panels:
        for f in st['flows']:
            x,y=map(int,f['source'].split(','));isx=f['tensor']=='A'
            expected=packed(tile(X if isx else W,y,x))
            assert f['values']==expected
            q=[packets[i] for i in f['packet_ids']]
            assert [p['value'] for p in q]==expected
            assert all(p['color']==(0 if isx else 4) and struct.unpack('<f',struct.pack('<I',p['word']))[0]==p['value'] for p in q)
            for p in q:
                assert len(p['observations'])==2
                a,b=p['observations'];assert abs(a['xy'][0]-b['xy'][0])+abs(a['xy'][1]-b['xy'][1])==1
                assert a['ident']==b['ident']==p['id'] and a['word']==b['word']==p['word']
            message=next(m for m in hops['messages'] if m['terms'][0]['packet']['ident']==q[0]['id'])
            control=message['control'];assert control['control'] and control['color']==q[0]['color']
            transfers.append(dict(round=q[0]['round'],tensor='X' if isx else 'W',tile=f'{"X" if isx else "W"}{y}{x}',source=f['source'],destination=f['destination'],values=expected,color=q[0]['color'],packets=q,control=control))
    assert len(transfers)==8 and sum(len(t['packets']) for t in transfers)==32
    states=[[[sum(X[i][k]*W[k][j] for k in range(n)) for j in range(4)] for i in range(4)] for n in range(5)]
    for st in s['teaching']['steps']:
        if st['phase']!='compute':continue
        k=st['calculations'][0]['k']
        for pe,val in st['state'].items():
            x,y=map(int,pe.split(','));assert val['partial']==sum(tile(states[k+1],y,x),[])
    figures={}
    f=Figure(1380,880,'1 · Partition X and W; give each PE one output tile','Tile subscripts are (matrix tile row, matrix tile column). PE coordinates are (x, y).')
    f.mat(50,135,X,'X · input activations',BLUE,51,True)
    f.mat(370,135,W,'W · weights',GREEN,51,True)
    f.text(675,142,'Compute Y = XW',27,INK,True)
    f.text(675,186,'Cut every matrix into four 2 × 2 tiles.',22)
    f.text(675,223,'PE (x,y) owns Y tile row y, column x.',22)
    f.text(675,260,'Each PE starts with local Xyx and Wyx.',22)
    f.text(675,301,'The host copies the eight input tiles into local SRAM.',18,MUTED)
    f.text(50,380,'Application mesh: x increases right; y increases down. Each box below is one PE.',21,INK,True)
    for y in range(2):
        for x in range(2):
            xx=50+x*665;yy=410+y*217
            f.box(xx,yy,620,196)
            f.text(xx+18,yy+29,f'PE ({x},{y}) / fabric ({4+x},{1+y}) → owns Y{y}{x}',21,INK,True)
            f.mat(xx+20,yy+76,tile(X,y,x),f'X{y}{x}',BLUE,39)
            f.mat(xx+177,yy+76,tile(W,y,x),f'W{y}{x}',GREEN,39)
            f.mat(xx+334,yy+76,[[0,0],[0,0]],f'Y{y}{x} = 0',ORANGE,39)
            f.text(xx+435,yy+107,'Each number: f32',16,MUTED)
            f.text(xx+435,yy+137,'Each tile: 16 bytes',16,MUTED)
    figures['01-placement.svg']=f.save('01-placement.svg')

    for r in range(2):
        f=Figure(1380,1000,f'{r+2} · Round {r+1}: use k = {2*r}, {2*r+1}',
                 'X panels cross PE rows on color 0. W panels cross PE columns on color 4. Y stays on its owner.')
        for y in range(2):
            for x in range(2):
                xx=45+x*800;yy=135+y*450
                f.box(xx,yy,480,270)
                f.text(xx+18,yy+31,f'PE ({x},{y}) · update Y{y}{x}',23,INK,True)
                f.mat(xx+20,yy+91,tile(X,y,r),f'X{y}{r} · {"local" if x==r else "in abuf"}',BLUE,40)
                f.mat(xx+255,yy+91,tile(W,r,x),f'W{r}{x} · {"local" if y==r else "in bbuf"}',GREEN,40)
                f.text(xx+20,yy+202,f'Y{y}{x} += X{y}{r} × W{r}{x}',20,INK,True)
                f.text(xx+20,yy+236,'After round: '+short(tile(states[2*r+2],y,x)),20,ORANGE,True)
        for y in range(2):
            yy=260+y*450;src,dst=(525,845) if r==0 else (845,525)
            f.arrow(src,yy,dst,yy,'x')
            f.text(560,yy-37,f'X{y}{r} · color 0',20,BLUE,True)
            f.text(550,yy+39,str(packed(tile(X,y,r))),20,BLUE)
            f.text(590,yy+69,'4 wavelets · 1 hop',17,MUTED)
        for x in range(2):
            xx=285+x*800;src,dst=(405,585) if r==0 else (585,405)
            f.arrow(xx,src,xx,dst,'w')
            f.text(xx+22,465,f'W{r}{x} · color 4',20,GREEN,True)
            f.text(xx+22,500,str(packed(tile(W,r,x))),20,GREEN)
            f.text(xx+22,535,'4 wavelets · 1 hop',17,MUTED)
        f.text(45,908,'Numbers on arrows are transmitted in column-major order: top-left, bottom-left, top-right, bottom-right.',19,MUTED)
        f.text(45,942,'Copied input panels remain in SRAM at the sender. Only remote copies travel; no Y tile crosses a PE link.',19,MUTED)
        name=f'0{r+2}-round-{r+1}.svg';figures[name]=f.save(name)

    transfer=transfers[0];q=transfer['packets'][0]
    f=Figure(1380,720,'4 · Zoom into one tile transfer: X00 from PE (0,0) to PE (1,0)',
             'The tile is a message of four data wavelets. A color is a channel tag; it is not a matrix index.')
    f.mat(45,153,[[1,2],[5,6]],'X00 · source SRAM',BLUE,52)
    f.arrow(175,207,287,207,'x');f.text(183,184,'pack',18,BLUE)
    for i,p in enumerate(transfer['packets']):
        xx=310+245*i;f.box(xx,120,218,181,BLUE)
        f.text(xx+16,151,f'Wavelet {i}',21,BLUE,True)
        f.text(xx+16,186,'color = 0',20)
        f.text(xx+16,222,f'f32 = {p["value"]:g}',22,INK,True)
        f.text(xx+16,262,f'bits = 0x{p["word"]:08x}',17,MUTED)
    f.text(45,343,'Receive order in PE (1,0): abuf[0..3] = [1,5,2,6]  →  logical tile [[1,2],[5,6]].',22,INK,True)
    f.text(45,381,'The local loop chooses array offsets. These f32 data wavelets carry no explicit matrix (i,j,k) coordinate.',19,MUTED)
    labels=[('Send operand',q['send']['cycle']),('Source router',q['observations'][0]['cycle']),('Neighbor router',q['observations'][1]['cycle']),('Receive operand',q['receive']['cycle']),('First multiply',q['consumer']['cycle'])]
    for i,(label,cyc) in enumerate(labels):
        xx=45+i*264;f.box(xx,431,231,96)
        f.text(xx+14,461,label,19,INK,True);f.text(xx+14,500,f'cycle {cyc}',23,BLUE)
        if i<4:f.arrow(xx+235,479,xx+258,479,'gray')
    f.text(45,570,f'Packet identity {q["id"]} is matched at both routers. First use: {q["consumer"]["equation"]}.',20)
    f.text(45,608,'The destination reuses that 1 for both output columns: 1×3 and 1×4. It does not receive it twice.',20)
    f.text(45,650,'Timeline spacing is schematic. Operand observations are not SRAM commit times or a measured pipeline diagram.',18,MUTED)
    f.text(45,683,'A separate end/control wavelet follows the four data words; control traffic is not another matrix element.',18,MUTED)
    figures['04-wavelets.svg']=f.save('04-wavelets.svg')

    f=Figure(1380,760,'5 · Follow one PE through both rounds: PE (1,0)',
             'This PE owns Y[0:2,2:4]. Its output tile stays in its SRAM for the entire computation.')
    for r in range(2):
        yy=143+r*264
        f.mat(45,yy,tile(X,0,r),f'Round {r+1} · X0{r}',BLUE,46)
        f.text(167,yy+55,'×',31)
        f.mat(225,yy,tile(W,r,1),f'W{r}1',GREEN,46)
        f.text(347,yy+55,'=',31)
        delta=matrix_product(tile(X,0,r),tile(W,r,1))
        f.mat(405,yy,delta,'Contribution ΔY01',ORANGE,46)
        f.text(45,yy+152,f'Before round: {short(tile(states[2*r],0,1))}',22)
        f.text(615,yy+15,'Accumulate locally',24,INK,True)
        f.text(615,yy+67,short(tile(states[2*r],0,1)),24,ORANGE)
        f.text(615,yy+109,'+ '+short(delta),24,ORANGE)
        f.text(615,yy+151,'= '+short(tile(states[2*r+2],0,1)),26,ORANGE,True)
    f.text(45,684,'One scalar output: Y[0,2] = 1×3 + 2×2 + 3×1 + 4×0 = 3 → 7 → 10 → 10.',25,INK,True)
    f.text(45,726,'The explicit teaching kernel uses scalar FMULS, then FADDS, then stores the updated Y element.',19,MUTED)
    figures['05-accumulation.svg']=f.save('05-accumulation.svg')
    f=Figure(1380,540,'6 · Gather four finished output tiles',
             'Each PE computed all four k contributions for its own four outputs. No inter-PE partial-sum reduction is needed.')
    for y in range(2):
        for x in range(2):
            xx=45+x*345;yy=150+y*193
            f.mat(xx,yy,tile(Y,y,x),f'PE ({x},{y}) → Y{y}{x}',ORANGE,44)
    f.arrow(655,267,790,267,'y');f.mat(855,165,Y,'Host result Y = XW',ORANGE,60,True)
    f.text(45,513,'Host readback assembles tiles by their row/column ownership. The host transfer route and timing are not traced here.',19,MUTED)
    figures['06-output.svg']=f.save('06-output.svg')

    transfer_rows='\n'.join(f'| {t["round"]+1} | {t["tile"]} | ({t["source"]}) → ({t["destination"]}) | {t["color"]} | `{t["values"]}` |' for t in transfers)
    accum_rows='\n'.join(f'| ({x},{y}) | `X{y}0 W0{x}` | `{short(tile(states[2],y,x))}` | `X{y}1 W1{x}` | `{short(tile(Y,y,x))}` |' for y in range(2) for x in range(2))
    state_rows='\n'.join(f'| {"Initial" if n==0 else "After k="+str(n-1)} | '+ ' | '.join('`'+short(tile(state,y,x))+'`' for y in range(2) for x in range(2))+' |' for n,state in enumerate(states))
    tutorial=f'''# A 4 × 4 GEMM on four WSE-3 PEs

This tutorial explains **one actual implementation** from our retained WSE-3 simulator capture: the small SUMMA-like kernel **g1**. It uses two communication rounds. Every matrix value, remote data color and neighbor hop below comes from that capture or arithmetic checked against it.

We use **Y = XW**, where both X and W are 4 × 4. X is called `A`, W is called `B`, and Y is called `C` in the source. Here W is indexed `W[k,j]` (input feature × output feature). The earlier weight-streaming lesson stored weights in the transposed convention; this tutorial uses the captured kernel's direct multiplication convention.

**Read in this order:** place tiles → send the first panels → compute → send the second panels → compute → read back. The figures show dependency stages, not simultaneous cycle snapshots. The original interactive microscope remains at [matmul.html](../matmul-compare/matmul.html), in its **Mesh GEMM / GEMV** tab.

## 1. What is one PE responsible for?

One output number is a dot product: `Y[i,j] = Σ_k X[i,k] × W[k,j]`. We split the output into four 2 × 2 tiles. PE coordinates are **(x,y)**, while tile subscripts are **(row,column)**. Thus **PE (1,0) owns Y01**, the upper-right output tile.

```text
                    PE x=0                 PE x=1
PE y=0          X00, W00, Y00           X01, W01, Y01
PE y=1          X10, W10, Y10           X11, W11, Y11
```

The host uploads one X tile and one W tile to each PE's local SRAM. Each PE starts its Y tile at zero. Other PEs cannot directly load those SRAM arrays: an input needed elsewhere must be sent as a message. These four **application PEs** occupy fabric coordinates (4,1), (5,1), (4,2), (5,2); surrounding SDK I/O support PEs are omitted. Host ingress is outside our matched kernel-hop capture.

![Exact inputs and their initial PE placement](01-placement.svg)

Each original X or W tile is 4 f32 values = 16 bytes. Each PE also has a 16-byte Y tile, a receive buffer `abuf` for a remote X panel, and `bbuf` for a remote W panel. Original input arrays remain local when a copy is broadcast. This is explicit SRAM placement, not a cache-residency claim.

## 2. Why are there two rounds?

Divide the dot-product dimension `k=0,1,2,3` into two chunks. Round 1 handles `k=0,1`; round 2 handles `k=2,3`.

```text
Y00 = X00·W00 + X01·W10       Y01 = X00·W01 + X01·W11
Y10 = X10·W00 + X11·W10       Y11 = X10·W01 + X11·W11
```

These are **2 × 2 matrix products**, not elementwise products. For example, PE (1,0) initially owns X01 and W01. For its first product `X00·W01`, it already has W01 but needs a copy of X00 from its left neighbor. For its second product `X01·W11`, it already has X01 but needs W11 from its lower neighbor.

## 3. How do tiles become colored wavelets?

A **tile** is a group of matrix elements. A **wavelet** is a small fabric message. A **color** is a hardware virtual-channel ID used by the configured router and receive path. It does not name a tensor or identify a tile automatically. On WSE-3 a color can be bound to an input queue; the numeric color and queue ID are different concepts. [Official communication model](https://sdk.cerebras.ai/computing-with-cerebras#communication).

For this kernel, the layout gives the row collective colors **0,1** and the column collective colors **4,5**. In the matched numeric messages, **all X data uses color 0** and **all W data uses color 4**. We do not assign a different color to each tile. The four X tiles reuse color 0 on their scheduled routes; W tiles reuse color 4. Colors 1 and 5 are additional library-configured resources, not the numeric X/W payload streams counted here.

```c
// Retained layout.csl: row / column collective resources
.x_colors = .{{ @get_color(0), @get_color(1) }},
.y_colors = .{{ @get_color(4), @get_color(5) }}
```

The blue/green drawing palette is just a visual legend; **the hardware IDs are the numbers 0 and 4** printed on the arrows. A wavelet does not contain an RGB color.

The 2 × 2 tile `X00=[[1,2],[5,6]]` is packed column-major as `[1,5,2,6]`. Each of those values is carried by a separate f32 data wavelet on color 0. A data word uses all 32 bits for the float; it is **not** the earlier sparse-streaming format of a 16-bit value plus a 16-bit matrix index. The scheduled message and receive offset establish the matrix coordinates.

![Packing a tile into data wavelets and following one recorded packet](04-wavelets.svg)

The shown packet has identity `{q['id']}`. Identity plus full payload, color, endpoints and chronology match it across the capture; equal floating-point values alone would not identify a packet. Its first remote arithmetic use is `1 × 3 = 3` on PE (1,0). That same received 1 is reused for the second output column as `1 × 4`; there is no second network copy for that reuse.

The diagram's cycle labels are actual simulator observations. The two-cycle gap between these router observations is **not** a universal link-latency measurement. The gap until arithmetic includes the collective and program schedule. Send/receive operand records do not identify an exact SRAM commit cycle. The four numeric words are followed by a separate matched end/control wavelet, also on color 0.

## 4. Round 1: X goes right, W goes down

Left-column PEs own the X panels for `k=0,1`; top-row PEs own the W panels for `k=0,1`. They send copies to their row/column peers. In this 2 × 2 mesh each remote transfer is exactly **one neighbor hop**.

![Round 1 routes with exact transmitted values and local partial outputs](02-round-1.svg)

Every PE uses its local panel if it owns that round's source, otherwise the received `abuf`/`bbuf`. The collective completion callbacks make the compute task runnable only after both panels are ready. A PE does not multiply unrelated values merely because they arrived at similar times. Row and column traffic can overlap; the tutorial separates them for readability.

At PE (1,0):

```text
X00 = [[1,2], [5,6]]       W01 = [[3,4], [2,3]]

Y01 += [[1×3 + 2×2,  1×4 + 2×3],
        [5×3 + 6×2,  5×4 + 6×3]]
     = [[7,10], [27,38]]
```

## 5. Round 2: X goes left, W goes up

Now `k=2,3`. Right-column PEs own the required X panels; bottom-row PEs own the W panels. The root of each broadcast changes. **The data still uses the same color IDs:** X uses 0 and W uses 4. Direction depends on routing and the selected collective root, not on an immutable meaning such as “color 0 always means east.”

![Round 2 routes with exact transmitted values and completed outputs](03-round-2.svg)

PE (1,0) uses its original X01 and receives W11 into `bbuf`. Its earlier partial output remains in its Y SRAM tile:

```text
X01·W11 = [[3,4], [7,8]] · [[1,2], [0,1]]
        = [[3,10], [7,22]]

Y01 = [[7,10], [27,38]] + [[3,10], [7,22]]
    = [[10,20], [34,60]]
```

![Two rounds of exact local accumulation on PE 1,0](05-accumulation.svg)

## 6. The entire communication schedule

All eight messages below are matched to packet identities in the retained simulator trace. Every row contains **four data wavelets, one hop each**. Payloads are listed in transmission/receive-buffer order, not row-major display order.

| Round | Tile copied | Source PE → destination PE | Data color | Four f32 payloads |
|---|---|---|---|---|
{transfer_rows}

That is **32 numeric neighbor-hop transmissions = 128 payload bytes**, plus separately accounted control traffic. It excludes host I/O, protocol overhead and other library traffic. We matched one end/control wavelet for each of these eight messages. No Y/partial-output message is part of this kernel schedule.

## 7. Where are the partial sums?

They are the current entries of each PE's local Y/C array. In this teaching kernel the inner loop reads one X value, one W value and the old Y value; executes scalar f32 multiply and add; then stores the new Y value. This is the retained explicit implementation, not a claim about every optimized GEMM's register/cache strategy.

```text
For round s = 0,1 on PE (x,y):
    get X[y,s] across row y; get W[s,x] across column x
    wait until both panels are ready
    for local k = 0,1:
        for local j = 0,1:
            for local i = 0,1:
                Y[i,j] += X_panel[i,k] * W_panel[k,j]
```

Array offsets are `X_panel[k*2+i]`, `W_panel[j*2+k]`, and `Y[j*2+i]`. The column-major layout makes each local i sequence contiguous. A received input is reused from local storage; it is not sent again for every product. Each PE performs 16 products in total, so the four PEs perform the expected `4³=64` products. **Zeros are still sent and multiplied** in this dense f32 benchmark.

| Stage | PE (0,0): Y00 | PE (1,0): Y01 | PE (0,1): Y10 | PE (1,1): Y11 |
|---|---|---|---|---|
{state_rows}

These rows group dependency progress after each k contribution, not a simultaneous wall-clock snapshot of all four PEs.

## 8. Assemble the result

| PE | Round 1 product | Partial after round 1 | Round 2 product | Final local Y |
|---|---|---|---|---|
{accum_rows}

![Final output ownership and host assembly](06-output.svg)

Each output has accumulated **all four k terms on the same PE**, so there is no need to reduce partial Y values between PEs. The host simply reads and places the four completed tiles into their known positions. This is why this algorithm differs from the activation-stationary weight-streaming lesson, where different PEs own different k contributions to the same output and must combine them.

## 9. Connect this to the real implementation

The retained `pe.csl` selects `A` or `abuf` with `px == step`, and `B` or `bbuf` with `py == step`. It calls `mpi_x.broadcast(step, ...)` and `mpi_y.broadcast(step, ...)`; `gemm()` then updates C. `tools/gemm_four_pe_tutorial.py` builds this lesson directly from the existing g1 bundle, checks payload words and colors against the matched messages, and verifies every k-stage and the final matrix.

- Captured run: `{original['provenance']['run']}`.
- Exact panel/hop evidence: `viewer/public/dataflow-bundle.json`, scene `g1`; `results/pe-hops/hops.json`, scene `g1`.
- Source: `microbench/gemm_walkthrough/generate.py` and the retained run's `layout.csl`, `pe.csl`, `run.py`.
- [Interactive mesh and instruction viewer](../matmul-compare/matmul.html), [packet-hop viewer](../pe-hops/hops.html), [validation record](verification.json).

To reproduce the tutorial files without launching a device job: `python tools/gemm_four_pe_tutorial.py`.
'''
    (OUT/'tutorial.md').write_text(tutorial)
    rendered=MarkdownIt('commonmark').enable('table').render(tutorial)
    for name,svg in figures.items():
        import re
        rendered=re.sub(r'<img src="'+re.escape(name)+r'"[^>]*>',lambda _:f'<figure>{svg}<figcaption><a href="{name}">Open this figure as SVG</a></figcaption></figure>',rendered)
    page='''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>4 × 4 GEMM on four WSE-3 PEs — a numeric tutorial</title><style>
*{box-sizing:border-box}body{margin:0;color:#18263b;background:#f4f6fb;font:17px/1.75 system-ui,sans-serif}main{max-width:1140px;margin:auto;padding:44px 48px;background:#fff}h1{font-size:40px;line-height:1.2;letter-spacing:-1px}h2{margin-top:58px;border-top:1px solid #dce2ec;padding-top:24px;font-size:26px}p,li{max-width:980px}a{color:#355acb}strong{color:#18263b}pre{padding:22px;background:#eef2f8;overflow:auto;border-radius:9px;font-size:15px;line-height:1.7}code{font-family:ui-monospace,monospace;font-size:.88em}p code,td code{background:#eef2f8;padding:2px 4px}figure{margin:26px -20px;background:#f7f9fd;border:1px solid #dce2ec;border-radius:12px;overflow:hidden}svg{display:block;width:100%;height:auto}figcaption{font-size:12px;padding:8px 16px}table{border-collapse:collapse;width:100%;font-size:13px;line-height:1.55;display:block;overflow:auto}th,td{padding:11px;border:1px solid #dce2ec;text-align:left;vertical-align:top}th{background:#eef2f8}nav{font-size:13px;display:flex;gap:16px;flex-wrap:wrap}nav a{padding:5px 0}footer{margin-top:40px;font-size:13px;color:#516279}@media(max-width:680px){body{font-size:15px}main{padding:24px 16px}h1{font-size:29px}h2{font-size:23px}figure{margin:20px 0}pre{font-size:12px;padding:13px}}@media print{@page{size:A4 landscape;margin:14mm}body{font-size:12px;background:white}main{max-width:none;padding:0}nav,figcaption{display:none}h1{font-size:27px}h2{font-size:20px;margin-top:25px;break-after:avoid}figure{margin:15px 0;break-inside:avoid;max-width:950px}svg{max-height:160mm}pre,table{font-size:11px}tr{break-inside:avoid}a{color:inherit;text-decoration:none}}
</style></head><body><main><nav><a href="tutorial.md">Markdown source</a><a href="../matmul-compare/matmul.html">Interactive microscope</a><a href="verification.json">Evidence checks</a></nav>'''+rendered+'<footer>Generated from retained simulator evidence. Numeric verification is separate from physical timing claims.</footer></main></body></html>'
    (OUT/'tutorial.html').write_text(page)
    (OUT/'transfers.json').write_text(json.dumps(transfers,indent=2)+'\n')
    report=dict(scene='g1',date='2026-09-25',source_run=str(run.relative_to(ROOT)),source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),verified_source_files=['layout.csl','pe.csl','run.py'],outputs_verified=16,products_verified=64,k_stages_verified=4,messages_verified=8,numeric_packets_verified=32,matched_end_control_packets=8,data_colors={'X':0,'W':4},all_numeric_routes='one adjacent PE hop',passed=True,final=Y,artifacts={name:hashlib.sha256((OUT/name).read_bytes()).hexdigest() for name in ['tutorial.md','tutorial.html',*figures]})
    (OUT/'verification.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({k:v for k,v in report.items() if k!='artifacts'},indent=2))


if __name__=='__main__':
    build()
