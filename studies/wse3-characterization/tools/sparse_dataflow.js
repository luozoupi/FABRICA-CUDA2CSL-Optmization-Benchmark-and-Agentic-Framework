/* ======================= sparse dataflow page: SpMV, SpMM, SpGEMM ======================= */
const D = %%DATA%%;
const $ = i => document.getElementById(i);
const esc = s => String(s).replace(/[&<>]/g, c => ({'&': '&amp;', '<': '&lt;', '>': '&gt;'}[c]));
const cnt = n => Number(n).toLocaleString('en-US');
const ok = p => `${cnt(p[0])} / ${cnt(p[1])}`;
const num = v => Number.isInteger(v) ? String(v) : (Math.abs(v) >= 100 ? v.toFixed(2) : v.toFixed(4));
const hex32 = v => '0x' + (v >>> 0).toString(16).padStart(8, '0');
const f32bits = v => { const b = new DataView(new ArrayBuffer(4)); b.setFloat32(0, v); return b.getUint32(0); };
const WALK = D.walk, SCH = ['spmv', 'spmm', 'spgemm', 'spgemm_acc'];
const NAME = {spmv: 'SpMV · row blocks on a strip', spmm: 'SpMM · CSR × dense on a mesh', spgemm: 'SpGEMM · masked AᵀA, merge', spgemm_acc: 'SpGEMM · masked AᵀA, accumulator'};
const SHORT = {spmv: 'SpMV', spmm: 'SpMM', spgemm: 'SpGEMM (merge)', spgemm_acc: 'SpGEMM (accumulator)'};
const COL = {x: 'var(--x)', w: 'var(--w)', c: 'var(--c)', idx: 'var(--ink2)', io: 'var(--io)', acc: 'var(--c)'};
const mc = t => COL[t] || 'currentColor';
const TOF = {row_ptr: 'idx', col_idx: 'idx', col_ptr: 'idx', row_idx: 'idx', val: 'w', x: 'x', B_tile: 'x', y: 'c', C_tile: 'c', c_val: 'c', c_row: 'c', acc_val: 'acc', acc_pat: 'acc'};
const ROWS = {spmv: ['row_ptr', 'col_idx', 'val', 'x', 'y'], spmm: ['row_ptr', 'col_idx', 'val', 'B_tile', 'C_tile'],
              spgemm: ['col_ptr', 'row_idx', 'val', 'c_val', 'c_row'], spgemm_acc: ['col_ptr', 'row_idx', 'val', 'acc_val', 'acc_pat', 'c_val', 'c_row']};
const txt = (x, y, s, o = {}) => `<text x="${x}" y="${y}" font-size="${o.fs || 9}" ${o.a ? `text-anchor="${o.a}"` : ''} fill="${o.c || 'currentColor'}"
  ${o.fo ? `fill-opacity="${o.fo}"` : ''} ${o.w ? 'font-weight="600"' : ''} font-family="IBM Plex Mono,monospace" ${o.rot ? `transform="rotate(${o.rot} ${x} ${y})"` : ''}
  ${o.halo ? 'paint-order="stroke" stroke="var(--pan2)" stroke-width="3"' : ''}>${s}</text>`;
const poly = (p, c, w, extra) => `<path d="M${p.map(q => q.map(v => v.toFixed(1)).join(',')).join(' L')}" fill="none"
  stroke="${c}" stroke-width="${w || 1.8}" stroke-linejoin="round" stroke-linecap="round" ${extra || ''}/>`;
const halo = (p, w) => poly(p, 'var(--pan2)', (w || 1.8) + 4);
const head = (x, y, c, dir, s = 6) => {
  const h = s * .6, d = {r: [[-s, -h], [-s, h]], l: [[s, -h], [s, h]], d: [[-h, -s], [h, -s]], u: [[-h, s], [h, s]]}[dir];
  return `<path d="M${x + d[0][0]},${y + d[0][1]} L${x},${y} L${x + d[1][0]},${y + d[1][1]} z" fill="${c}"/>`;
};
const hdir = (a, b) => b[0] > a[0] ? 'r' : b[0] < a[0] ? 'l' : b[1] > a[1] ? 'd' : 'u';
const R_ = (x, y, w, h, c, o = {}) => `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${o.rx ?? 2}" fill="${o.fill || c}" fill-opacity="${o.fo ?? .14}"
  stroke="${c}" stroke-opacity="${o.so ?? .9}" stroke-width="${o.sw || 1}" ${o.dash ? 'stroke-dasharray="4 3"' : ''}/>`;

/* ---------- KPIs ---------- */
{
  const v = WALK.spmv, m = WALK.spmm, g = WALK.spgemm, a = WALK.spgemm_acc;
  const arith = [v, m, g, a].reduce((s, k) => s + k.checks.arithmetic[0], 0), arithN = [v, m, g, a].reduce((s, k) => s + k.checks.arithmetic[1], 0);
  $('kpis').innerHTML = `
    <div><b style="color:var(--c)">${arith} / ${arithN}</b><span>scalar multiplies and adds in the four traces, each matched to the source's product or sum, bit for bit</span></div>
    <div><b style="color:var(--x)">${v.mcast.packets} → ${v.params.P - 1}</b><span>packets of x in SpMV, each delivered to ${v.params.P - 1} PEs: one hardware multicast per value</span></div>
    <div style="color:var(--w)"><b>0</b><span>matrix values that cross the fabric in any of the three kernels: only the dense operand or nothing moves</span></div>
    <div><b>${(g.compute_span[1] - g.compute_span[0]) > 0 ? ((g.compute_span[1] - g.compute_span[0]) / g.nnz).toFixed(0) : '—'} cyc</b><span>per mask entry in the SpGEMM merge; ${((a.compute_span[1] - a.compute_span[0]) / a.nnz).toFixed(0)} with the dense accumulator, on the same instance</span></div>`;
  $('kpinote').textContent = 'Every number on this page comes from the traced runs (results/datapath/sparse_walk.json) or the kernels\' own source; benchmark-size cycles are quoted from the study\'s records and tagged as such.';
}

/* ---------- formats: storage, partition, what travels ---------- */
let fsch = 'spmv';
function denseOf(inst){ const M = Array.from({length: inst.n}, () => Array(inst.m).fill(null)); inst.rows.forEach((r, k) => M[r][inst.cols[k]] = inst.vals[k]); return M; }
function fmtDraw(){
  const s = fsch, k = WALK[s], I = k.instance, M = denseOf(I);
  let g = '', cell = s === 'spmv' ? 18 : 30, x0 = 24, y0 = 46;
  g += txt(x0, 22, `A: ${I.n} × ${I.m}, ${I.rows.length} nonzeros (stored values only)`, {fs: 12, w: 1});
  const peOfRow = r => s === 'spmv' ? Math.floor(r / k.params.nrows_pe) : s === 'spmm' ? Math.floor(r / k.params.Mt) : 0;
  for (let r = 0; r < I.n; r++) for (let c = 0; c < I.m; c++){
    const v = M[r][c], pe = peOfRow(r);
    g += R_(x0 + c * cell, y0 + r * cell, cell - 1, cell - 1, v === null ? 'currentColor' : mc('w'), {fo: v === null ? .03 : .25, so: v === null ? .12 : .8, rx: 1});
    if (v !== null) g += txt(x0 + c * cell + cell / 2, y0 + r * cell + cell * .68, v, {a: 'middle', fs: cell > 20 ? 12 : 9, c: mc('w'), w: 1});
  }
  if (s !== 'spgemm' && s !== 'spgemm_acc'){
    const per = s === 'spmv' ? k.params.nrows_pe : k.params.Mt;
    for (let b = 0; b < I.n / per; b++){
      g += `<rect x="${x0 - 3}" y="${y0 + b * per * cell - 2}" width="${I.m * cell + 5}" height="${per * cell + 3}" rx="3" fill="none" stroke="var(--ink)" stroke-opacity=".55" stroke-dasharray="5 3"/>`;
      g += txt(x0 + I.m * cell + 8, y0 + b * per * cell + per * cell / 2 + 4, s === 'spmv' ? `→ PE ${b}` : `→ mesh row ${b}`, {fs: 10, w: 1});
    }
  } else {
    for (let c = 0; c < I.m; c++) g += `<rect x="${x0 + c * cell - 1}" y="${y0 - 3}" width="${cell + 1}" height="${I.n * cell + 5}" rx="2" fill="none" stroke="var(--ink)" stroke-opacity="${c % 2 ? .25 : .5}" stroke-dasharray="4 3"/>`;
    g += txt(x0, y0 + I.n * cell + 16, 'stored by column (CSC): col_ptr, row_idx, val · all on one PE', {fs: 10, fo: .75});
  }
  /* the arrays, as the host sends them */
  const ax = s === 'spmv' ? 420 : 330, arr = (y, name, vals, t, sub) => {
    g += txt(ax, y, name, {fs: 10, w: 1, c: mc(t)}) + txt(ax + 62, y, sub || '', {fs: 9, fo: .6});
    vals.slice(0, 40).forEach((v, i) => g += R_(ax + i * 14, y + 4, 13, 15, mc(t), {fo: .12, so: .35, rx: 1}) + txt(ax + i * 14 + 6.5, y + 15, v, {a: 'middle', fs: 7.5, c: mc(t)}));
    if (vals.length > 40) g += txt(ax + 40 * 14 + 4, y + 18, `… ${vals.length}`, {fs: 8, fo: .6});
  };
  if (s === 'spmv'){
    const P = k.params.P; let y = 46;
    g += txt(ax, 22, `Cut into ${P} row blocks; each PE gets its rows as a local CSR (row_ptr relative, col_idx global), padded to the caps`, {fs: 11, w: 1});
    for (let px = 0; px < P; px++){
      const pe = k.pes[`${px},0`];
      g += txt(ax, y, `PE ${px}`, {fs: 10, w: 1}); arr(y + 14, 'row_ptr', pe.row_ptr, 'idx', `[${k.params.nrows_pe + 1}]`); arr(y + 42, 'col_idx', pe.col_idx, 'idx', `[${k.params.max_nnz_pe}], ${pe.nnz} used`); arr(y + 70, 'val', pe.val, 'w', `[${k.params.max_nnz_pe}]`);
      y += 104;
    }
    g += txt(ax, y, `x: written to PE 0 only, ${k.params.ncols} values; the kernel multicasts it`, {fs: 10, w: 1, c: mc('x')}); arr(y + 14, 'x', k.x, 'x', '');
  } else if (s === 'spmm'){
    const P = k.params.P; let y = 46;
    g += txt(ax, 22, `Row tiles replicated along each mesh row; B split into ${P} column slices, each replicated down its mesh column`, {fs: 11, w: 1});
    for (let py = 0; py < P; py++){
      const pe = k.pes[`0,${py}`];
      g += txt(ax, y, `mesh row ${py}: PEs (0,${py}) and (1,${py}) both hold`, {fs: 10, w: 1}); arr(y + 14, 'row_ptr', pe.row_ptr, 'idx', `[${k.params.Mt + 1}]`); arr(y + 42, 'col_idx', pe.col_idx, 'idx', `[${k.params.max_nnz_pe}], ${pe.nnz} used`); arr(y + 70, 'val', pe.val, 'w', '');
      y += 104;
    }
    g += txt(ax, y + 2, 'B (8 × 4 dense)', {fs: 11, w: 1, c: mc('x')});
    k.B.forEach((row, r) => row.forEach((v, c) => g += R_(ax + 90 + c * 22, y - 8 + r * 15, 21, 14, mc('x'), {fo: .12, so: .35, rx: 1}) + txt(ax + 90 + c * 22 + 10.5, y + 3 + r * 15, v, {a: 'middle', fs: 8.5, c: mc('x')})));
    for (let px = 0; px < P; px++) g += `<rect x="${ax + 89 + px * 44}" y="${y - 10}" width="45" height="${8 * 15 + 3}" rx="2" fill="none" stroke="var(--ink)" stroke-opacity=".55" stroke-dasharray="4 3"/>` + txt(ax + 89 + px * 44 + 22, y - 14, `→ mesh column ${px}`, {a: 'middle', fs: 9});
  } else {
    g += txt(ax, 22, 'One PE holds A by column; the pattern of A is also the mask M', {fs: 11, w: 1});
    arr(50, 'col_ptr', k.col_ptr, 'idx', `[${k.params.n + 1}]`); arr(80, 'row_idx', k.row_idx, 'idx', `[${k.params.max_nnz}], ${k.nnz} used`); arr(110, 'val', k.val, 'w', '');
    g += txt(ax, 150, `Outputs at the ${k.nnz} mask positions: c_val[p] = A(:,i)·A(:,j), c_row[p] = i, or ~i when the columns share no row (zombie).`, {fs: 10, fo: .8});
    g += txt(ax, 168, `Here: ${k.entries.filter(e => !e.zombie).length} values, ${k.nzombies} zombies.`, {fs: 10, fo: .8});
    if (s === 'spgemm_acc') g += txt(ax, 192, 'Variant: A(:,j) is scattered into a dense accumulator (acc_val, acc_pat) once per column; each C(i,j) is then a gather over A(:,i).', {fs: 10, fo: .8});
  }
  $('fmtfig').innerHTML = g;
  $('fmtfig').setAttribute('viewBox', `0 0 1020 ${s === 'spmv' ? 530 : s === 'spmm' ? 340 : 300}`);
  $('fmtcap').innerHTML = {spmv: 'What travels: the dense vector x (16 values, from PE 0 to the other three by multicast). The matrix never moves; each PE reads x by index (a gather) while it walks its own rows.',
    spmm: 'Nothing travels between PEs. The host replicates A\'s row tile along each mesh row and B\'s column slice down each mesh column, so PE (px, py) has everything for its Mt × Nt tile of C. The replication is the price of a communication-free kernel.',
    spgemm: 'Nothing travels: one PE. C(i,j) is the dot product of two sorted index lists, A(:,i) and A(:,j); the work is the two-pointer merge, not the arithmetic.',
    spgemm_acc: 'Nothing travels: one PE. The accumulator turns the merge into a scatter and a gather; the arithmetic count rises (one multiply per stored row of A(:,i), zero where column j has no entry) while the branching falls.'}[s];
  $('ftabs').querySelectorAll('button').forEach(b => b.setAttribute('aria-pressed', String(b.dataset.s === fsch)));
}
$('ftabs').innerHTML = SCH.map(s => `<button data-s="${s}">${SHORT[s]}</button>`).join('');
$('ftabs').querySelectorAll('button').forEach(b => b.onclick = () => { fsch = b.dataset.s; fmtDraw(); });
fmtDraw();

/* wavelets and colours */
{
  let g = '';
  const wav = (x, y, hi, lo, c, cap) => {
    g += R_(x, y, 54, 26, c, {fo: .06}) + R_(x + 54, y, 90, 26, c, {fo: .06}) + R_(x + 144, y, 90, 26, c, {fo: .2});
    g += txt(x + 27, y + 17, 'colour', {a: 'middle', fs: 9}) + txt(x + 99, y + 17, hi, {a: 'middle', fs: 10}) + txt(x + 189, y + 17, lo, {a: 'middle', fs: 10, w: 1});
    cap.forEach((s, i) => g += txt(x, y + 42 + i * 14, s, {fs: 10, fo: .8}));
  };
  g += txt(20, 22, 'These kernels are f32 and u32, so every value is one whole 32-bit wavelet: index half = high 16 bits, data half = low 16 bits', {fs: 12, w: 1});
  wav(20, 40, `${hex32(f32bits(4.0)).slice(0, 6)}`, hex32(f32bits(4.0)).slice(6), mc('x'), ['x[0] = 4.0 = 0x40800000 as it was traced on colour 8:', 'index = 0x4080, data = 0x0000 (verified for all 16 values)']);
  wav(360, 40, '0x0000', '0x0005', mc('idx'), ['a u32 index, e.g. col_idx = 5, on memcpy colour 23:', 'one 32-bit word per wavelet, no packing']);
  g += txt(700, 50, 'verified in the traces', {fs: 11, w: 1});
  const v = WALK.spmv;
  [['SpMV host→device words that reached the kernel', `${cnt(v.io.h2d_words_found)} / ${cnt(v.io.h2d_words_expected)} (in ${cnt(v.io.h2d_packets)} packets)`],
   ['x multicast, payload = x in order', v.mcast.payload_is_x_in_order ? `${v.mcast.packets} / ${v.mcast.packets}` : 'no'],
   ['device→host words (y) found on colour 21', `${cnt(v.io.d2h_words_found)} / ${cnt(v.io.d2h_words_expected)}`],
   ['values per wavelet, everywhere on this page', '1']].forEach(([a, b], i) => g += txt(700, 74 + i * 30, a, {fs: 10, fo: .7}) + txt(700, 88 + i * 30, b, {fs: 11}));
  $('wavefig').innerHTML = g;
  const rows = [
    [8, 'SpMV: x, PE 0 → PEs 1–3', 'east along the strip; PE 1 and 2 deliver <b>and</b> forward (rx WEST → tx RAMP, EAST), PE 3 delivers', 'OQ2 → IQ2', `${v.mcast.packets} packets · ${v.mcast.routers_per_packet.join('/')} routers each · ${v.mcast.per_hop_cycles.join('/')} cycle per hop`, 'SpMV only'],
    [23, 'memcpy host → device', 'west edge in, east along each kernel row; each PE keeps its slot', 'IQ0/1 (memcpy)', `SpMV ${cnt(v.io.h2d_packets)} · SpMM ${cnt(WALK.spmm.io.h2d_packets)} · SpGEMM ${cnt(WALK.spgemm.io.h2d_packets)} packets`, 'all'],
    [21, 'memcpy device → host', 'east out', 'OQ0 (memcpy)', `SpMV ${cnt(v.io.d2h_packets)} · SpMM ${cnt(WALK.spmm.io.d2h_packets)} · SpGEMM ${cnt(WALK.spgemm.io.d2h_packets)} packets (results + timestamps + control)`, 'all'],
    [22, 'memcpy commands (launch, RPC)', '—', 'memcpy', 'present in all four traces', 'all'],
    ['0–3, 5', 'memcpy internal, support columns only', '—', 'memcpy', 'never enter a kernel PE', 'all']];
  $('coltab').innerHTML = `<tr><th>colour</th><th>carries</th><th>route</th><th>queues</th><th>measured</th><th>kernels</th></tr>` +
    rows.map(r => `<tr><td>${typeof r[0] === 'number' ? 'c' + r[0] : r[0]}</td><td>${r[1]}</td><td>${r[2]}</td><td>${r[3]}</td><td>${r[4]}</td><td>${r[5]}</td></tr>`).join('') +
    `<tr><td colspan="6" class="mini">Of the 24 colour IDs, the kernels bind one (SpMV's colour 8) or none (SpMM, SpGEMM). Compare MeshGEMM, which binds twelve. The SpMV route at PEs 1 and 2 is a hardware multicast: one incoming wavelet is copied to the ramp and to the east link in the same router.</td></tr>`;
  $('fantab').innerHTML = `<tr><th>what moves</th><th>in space</th><th>over the run</th><th>evidence</th></tr>
    <tr><td>SpMV: x</td><td><b>one-to-many</b>: 1 packet → 3 PEs (multicast), the first true fabric broadcast on these pages</td><td>16 packets once; each PE then reads x by index, ${v.nnz} gathered reads for ${v.nnz} nonzeros</td><td>${v.mcast.routers_per_packet.join('/')} routers per packet; FMULS operands = val × x[col]</td></tr>
    <tr><td>SpMV: matrix</td><td>none: each PE's rows stay on it</td><td>—</td><td>0 kernel packets other than x</td></tr>
    <tr><td>SpMM: A tile, B slice</td><td><b>one-to-many by the host</b>: a row tile is sent to every PE of its mesh row, a B slice to every PE of its column</td><td>replicated once; no fabric traffic during compute</td><td>kernel colours seen: ${WALK.spmm.kernel_colours.join(', ')} (memcpy only)</td></tr>
    <tr><td>SpGEMM</td><td>none: one PE</td><td>—</td><td>kernel colours seen: ${WALK.spgemm.kernel_colours.join(', ')}</td></tr>
    <tr><td>compute, all three</td><td><b>one-to-one</b>: every output element is owned and accumulated by exactly one PE</td><td>SpMV y[r], SpMM C[r,c], SpGEMM c_val[p]</td><td>outputs bit-exact: ${ok(v.checks.outputs)}, ${ok(WALK.spmm.checks.outputs)}, ${ok(WALK.spgemm.checks.c_values)}</td></tr>
    <tr><td>inside one nonzero</td><td>a single scalar FMULS then FADDS; no SIMD lanes are used by these scalar loops</td><td>—</td><td>lane 0 only in every F-op record</td></tr>`;
}

/* ---------- kernel view: router + ramp + SRAM per PE ---------- */
const KV = {W: 1020, CW: 225, CH: 236, G: 20, X0: 30, Y0: 40};
const RB = {x: 6, y: 6, w: 70, h: 42};
const PORT = {E_out: [76, 17], W_in: [6, 17], W_out: [6, 35], E_in: [76, 35], S_out: [16, 48], N_in: [16, 6], N_out: [30, 6], S_in: [30, 48]};
const OUT = {E: 'E_out', W: 'W_out', S: 'S_out', N: 'N_out'}, IN = {E: 'W_in', W: 'E_in', S: 'N_in', N: 'S_in'};
const RAMP_UP = 42, RAMP_DN = 56, QX = 68, QW = 18, CHIP = {x: 90, w: 124, h: 22, gap: 4, y0: 60};
let scheme = 'spmv', ph = 0, timer = null, detailSel = null, shown = null;
const grid = () => { const r = WALK[scheme].rect; return {cols: r[2], rows: r[3]}; };
const kx0 = () => grid().cols === 1 ? (KV.W - KV.CW) / 2 : KV.X0 + ((KV.W - 2 * KV.X0) - (grid().cols * (KV.CW + KV.G) - KV.G)) / 2;
const cX = px => kx0() + px * (KV.CW + KV.G), cY = py => KV.Y0 + py * (KV.CH + KV.G);
const rowY = (py, b) => cY(py) + CHIP.y0 + ROWS[scheme].indexOf(b) * (CHIP.h + CHIP.gap);
const P2 = (px, py, p) => [cX(px) + PORT[p][0], cY(py) + PORT[p][1]];
const dirOf = (a, b) => b[0] > a[0] ? 'E' : b[0] < a[0] ? 'W' : b[1] > a[1] ? 'S' : 'N';
const rFloor = py => cY(py) + RB.y + RB.h;
const kvH = () => KV.Y0 + grid().rows * (KV.CH + KV.G) + 10;
function qbox(x, y, s, c){ if (!s) return ''; return `<rect x="${x}" y="${y - 6}" width="${QW}" height="12" rx="2" fill="var(--pan)" stroke="${c}" stroke-width="1"/>` + txt(x + QW / 2, y + 3, s, {a: 'middle', fs: 7.5, c}); }
function drawTransfer(m, L){
  const c = mc(m.t), path = m.path, n = path.length - 1, [ax, ay] = path[0];
  const tapY = (py, b, out) => rowY(py, b) + CHIP.h / 2 + (out ? -4 : 4);
  const y = tapY(ay, m.from, true), ux = cX(ax) + RAMP_UP, top = rFloor(ay);
  L.taps += halo([[cX(ax) + CHIP.x, y], [ux, y]]) + poly([[cX(ax) + CHIP.x, y], [ux, y], [ux, top]], c) + `<circle cx="${cX(ax) + CHIP.x}" cy="${y}" r="2.4" fill="${c}"/>` + head(ux, top, c, 'u');
  L.q += qbox(cX(ax) + QX, y, m.q[0], c);
  L.route += poly([[ux, top], P2(ax, ay, OUT[dirOf(path[0], path[1])])], c, 1.5);
  L.marks[`${ax},${ay}`] = 'end';
  const deliver = (b, B) => {
    const [bx, by] = b, dx = cX(bx) + RAMP_DN, yy = tapY(by, m.to, false);
    L.route += poly([B, [dx, rFloor(by)]], c, 1.5);
    L.taps += poly([[dx, rFloor(by)], [dx, yy], [cX(bx) + CHIP.x, yy]], c) + head(cX(bx) + CHIP.x, yy, c, 'r');
    L.q += qbox(cX(bx) + QX, yy, m.q[1], c);
    L.marks[`${bx},${by}`] = m.mult ? 'drop' : 'end';
  };
  for (let i = 0; i < n; i++){
    const a = path[i], b = path[i + 1], d = dirOf(a, b), A = P2(a[0], a[1], OUT[d]), B = P2(b[0], b[1], IN[d]);
    L.links += poly([A, B], c, 2.4) + head(B[0], B[1], c, hdir(A, B));
    const mx = (A[0] + B[0]) / 2, my = (A[1] + B[1]) / 2;
    L.labels += txt(mx, my - 4, `c${m.colour} · hop ${i + 1}`, {a: 'middle', c, halo: 1});
    if (i + 1 < n){ L.route += poly([B, P2(b[0], b[1], OUT[dirOf(b, path[i + 2])])], c, 1.5); if (!m.mult) L.marks[`${b[0]},${b[1]}`] = L.marks[`${b[0]},${b[1]}`] || 'transit'; }
    if (m.mult || i + 1 === n) deliver(b, B);
  }
}
const ROLE = {send: '↑ out', recv: '↓ in', read: 'read', gather: 'gather', acc: '+=', write: 'write', loaded: 'host', held: '', idle: '', scatter: 'scatter', unscatter: 'clear'};
function kernelView(f){
  const {cols, rows} = grid(), L = {marks: {}, taps: '', q: '', route: '', links: '', labels: ''};
  (f.moves || []).forEach(m => drawTransfer(m, L));
  let g = '';
  for (let py = 0; py < rows; py++) for (let px = 0; px < cols; px++){
    const x = cX(px), y = cY(py);
    g += `<rect x="${x}" y="${y}" width="${KV.CW}" height="${KV.CH}" rx="7" fill="var(--pan2)" stroke="currentColor" stroke-opacity=".32"/>`;
    if (px < cols - 1) g += `<line x1="${x + 76}" y1="${y + 26}" x2="${cX(px + 1) + 6}" y2="${y + 26}" stroke="currentColor" stroke-opacity=".12" stroke-width="22"/>`;
    if (py < rows - 1) g += `<line x1="${x + 23}" y1="${y + 48}" x2="${x + 23}" y2="${cY(py + 1) + 6}" stroke="currentColor" stroke-opacity=".12" stroke-width="18"/>`;
    g += `<rect x="${x + 36}" y="${y + 48}" width="32" height="${KV.CH - 54}" fill="currentColor" fill-opacity=".05"/>`;
    g += `<rect x="${x + 84}" y="${y + CHIP.y0 - 14}" width="${KV.CW - 88}" height="${KV.CH - CHIP.y0 + 10}" rx="4" fill="var(--pan)" stroke="currentColor" stroke-opacity=".2"/>`;
    g += txt(x + KV.CW - 8, y + CHIP.y0 - 4, `PE (${px},${py}) · SRAM`, {a: 'end', fs: 9, fo: .55});
    const bufs = f.bufs(px, py);
    ROWS[scheme].forEach(b => {
      const e = bufs[b]; if (!e) return;
      const t = TOF[b], col = mc(t), ry = rowY(py, b), role = e.role || '', dim = role === 'idle';
      const isSel = detailSel && detailSel.kind === 'buf' && detailSel.name === b && detailSel.px === px && detailSel.py === py;
      g += `<g class="chip" data-buf="${b}:${px}:${py}" tabindex="0" role="button" aria-label="Open ${b} at PE (${px},${py})">`;
      if (isSel) g += `<rect x="${x + CHIP.x - 3}" y="${ry - 3}" width="${CHIP.w + 6}" height="${CHIP.h + 6}" rx="5" fill="none" stroke="var(--ink)" stroke-width="2.4"/>`;
      g += `<rect x="${x + CHIP.x}" y="${ry}" width="${CHIP.w}" height="${CHIP.h}" rx="3" fill="${col}" fill-opacity="${dim ? .04 : ['read', 'gather', 'acc', 'write', 'scatter'].includes(role) ? .3 : .14}"
        stroke="${col}" stroke-opacity="${dim ? .35 : 1}" stroke-width="${['recv', 'acc', 'write', 'gather'].includes(role) ? 2 : 1}" ${role === 'send' ? 'stroke-dasharray="4 2"' : ''}/>`;
      g += txt(x + CHIP.x + 5, ry + 15, b, {fs: 9.5, c: col, fo: dim ? .5 : .8});
      g += txt(x + CHIP.x + 62, ry + 15, e.label, {fs: 10, c: col, w: !dim, fo: dim ? .55 : 1});
      if (ROLE[role]) g += txt(x + CHIP.x + CHIP.w - 5, ry + 15, ROLE[role], {a: 'end', fs: 8, c: col, fo: .9});
      g += `</g>`;
    });
  }
  let rt = '';
  for (let py = 0; py < rows; py++) for (let px = 0; px < cols; px++){
    const st = L.marks[`${px},${py}`], x = cX(px) + RB.x, y = cY(py) + RB.y;
    rt += `<rect x="${x}" y="${y}" width="${RB.w}" height="${RB.h}" rx="4" fill="var(--pan)" stroke="${st ? 'var(--ink)' : 'currentColor'}" stroke-opacity="${st ? .8 : .4}" stroke-width="${st === 'end' ? 1.8 : 1.2}"/>`;
    if (!st) rt += txt(x + RB.w / 2, y + 25, 'router', {a: 'middle', fs: 9, fo: .45});
    if (st === 'drop') rt += txt(x + RB.w / 2, y + RB.h - 4, 'deliver + fwd', {a: 'middle', fs: 7.5, fo: .8});
  }
  return g + rt + L.taps + L.route + L.links + L.q + L.labels;
}

/* ---------- wafer view, parametrised by fabric and kernel rectangle ---------- */
function waferView(f){
  const k = WALK[scheme], [FW, FH] = k.fabric, [rx0, ry0, rw, rh] = k.rect;
  const c = Math.min(66, Math.floor((1020 - 160) / FW) - 14), gp = 14, X0 = 80, Y0 = 50;
  const wX = x => X0 + x * (c + gp), wY = y => Y0 + y * (c + gp), WR = (x, y) => [wX(x) + 13, wY(y) + 13];
  const region = (x, y) => (x >= rx0 && x < rx0 + rw && y >= ry0 && y < ry0 + rh) ? 'K' : (x === 0 || x === FW - 1 || y === 0 || y === FH - 1) ? 'H' : x < rx0 ? 'W' : 'E';
  let g = '';
  [['halo', 0, 0], ['memcpy support', 1, rx0 - 1], ['kernel', rx0, rx0 + rw - 1], ['support', rx0 + rw, FW - 2], ['halo', FW - 1, FW - 1]].forEach(([t, a, b]) =>
    g += txt((wX(a) + wX(b) + c) / 2, 18, t, {a: 'middle', fs: 11, fo: .6}) + `<line x1="${wX(a) + 2}" y1="26" x2="${wX(b) + c - 2}" y2="26" stroke="currentColor" stroke-opacity=".25"/>`);
  for (let y = 0; y < FH; y++) for (let x = 0; x < FW; x++){
    const [rx, ry] = WR(x, y);
    if (x < FW - 1) g += `<line x1="${rx}" y1="${ry}" x2="${WR(x + 1, y)[0]}" y2="${ry}" stroke="currentColor" stroke-opacity=".12" stroke-width="3"/>`;
    if (y < FH - 1) g += `<line x1="${rx}" y1="${ry}" x2="${rx}" y2="${WR(x, y + 1)[1]}" stroke="currentColor" stroke-opacity=".12" stroke-width="3"/>`;
  }
  for (let y = 0; y < FH; y++) for (let x = 0; x < FW; x++){
    const r = region(x, y), X = wX(x), Y = wY(y);
    g += `<rect x="${X}" y="${Y}" width="${c}" height="${c}" rx="5" fill="${r === 'K' ? 'var(--pan)' : r === 'H' ? 'var(--bg)' : 'var(--pan2)'}" fill-opacity="${r === 'H' ? .6 : 1}"
      stroke="currentColor" stroke-opacity="${r === 'K' ? .5 : .25}" ${r === 'H' ? 'stroke-dasharray="3 3"' : ''}/>`;
    g += `<rect x="${X + 5}" y="${Y + 5}" width="16" height="16" rx="3" fill="var(--pan)" stroke="currentColor" stroke-opacity=".45"/>`;
    g += txt(X + c - 4, Y + c - 5, `${x},${y}`, {a: 'end', fs: 8.5, fo: .45});
    if (r === 'K'){
      const held = f.held(x - rx0, y - ry0), names = ROWS[scheme].filter(b => !b.startsWith('acc'));
      names.forEach((b, i) => g += `<rect x="${X + 27}" y="${Y + 8 + i * 9}" width="${c - 33}" height="7" rx="1.5" fill="${mc(TOF[b])}" fill-opacity="${held[b] ? .8 : .08}" stroke="${mc(TOF[b])}" stroke-opacity="${held[b] ? 1 : .3}"/>`);
    }
  }
  const PW = [X0 - 14, WR(0, ry0)[1]], PE_ = [wX(FW - 1) + c + 14, WR(FW - 1, ry0 + rh - 1)[1]];
  g += `<g font-family="IBM Plex Mono,monospace" font-size="11"><rect x="4" y="${PW[1] - 20}" width="${PW[0] - 4}" height="44" rx="4" fill="var(--pan)" stroke="var(--io)" stroke-width="1.5"/>
    <text x="${(PW[0] + 4) / 2}" y="${PW[1] - 3}" text-anchor="middle" fill="currentColor">west</text><text x="${(PW[0] + 4) / 2}" y="${PW[1] + 12}" text-anchor="middle" fill="currentColor">I/O</text>
    <rect x="${PE_[0]}" y="${PE_[1] - 20}" width="${1020 - 4 - PE_[0]}" height="44" rx="4" fill="var(--pan)" stroke="var(--io)" stroke-width="1.5"/>
    <text x="${(PE_[0] + 1016) / 2}" y="${PE_[1] - 3}" text-anchor="middle" fill="currentColor">east</text><text x="${(PE_[0] + 1016) / 2}" y="${PE_[1] + 12}" text-anchor="middle" fill="currentColor">I/O</text></g>`;
  const pt = q => q === 'W' ? PW : q === 'E' ? PE_ : WR(q[0], q[1]);
  (f.paths || []).forEach(p => {
    const col = mc(p.t), pts = p.pts.map(pt);
    if (p.ghost){ g += poly(pts, col, 1.4, 'stroke-opacity=".35" stroke-dasharray="5 4"'); return; }
    g += poly(pts, col, 2.4);
    const Lp = pts[pts.length - 1], Q = pts[pts.length - 2]; g += head(Lp[0], Lp[1], col, hdir(Q, Lp));
    (p.drops || []).forEach(([x, y]) => { const [rx, ry] = WR(x, y); g += `<circle cx="${rx}" cy="${ry}" r="4" fill="${col}"/>` + poly([[rx, ry], [rx, wY(y) + 32], [wX(x) + 25, wY(y) + 32]], col, 1.6) + head(wX(x) + 27, wY(y) + 32, col, 'r'); });
    (p.from || []).forEach(([x, y]) => { const [rx, ry] = WR(x, y); g += poly([[wX(x) + 27, wY(y) + 40], [rx + 4, wY(y) + 40], [rx + 4, ry + 8]], col, 1.6) + head(rx + 4, ry + 8, col, 'u'); });
    if (p.label){ const [a, b] = p.labelAt ? [pts[p.labelAt[0]], pts[p.labelAt[1]]] : [pts[0], pts[1]];
      g += txt((a[0] + b[0]) / 2 + (p.dx || 0), (a[1] + b[1]) / 2 + (p.dy || -12), p.label, {a: 'middle', fs: 11, c: col, w: 1, halo: 1}); }
  });
  for (let y = 0; y < FH; y++) for (let x = 0; x < FW; x++) if (region(x, y) === 'K')
    g += `<rect class="chip" data-pe="${x - rx0}:${y - ry0}" x="${wX(x)}" y="${wY(y)}" width="${c}" height="${c}" fill="transparent" tabindex="0" role="button" aria-label="Open PE (${x - rx0},${y - ry0})"/>`;
  return {svg: g, h: Y0 + FH * (c + gp) + 10};
}
function inPaths(leg, key){
  const k = WALK[key], [rx0, ry0, rw, rh] = k.rect, y0 = ry0, sx = rx0 - 2;
  const P1 = [{t: 'io', pts: ['W', [0, y0], [1, y0], [sx, y0]], label: leg === 1 ? `${cnt(k.io.h2d_packets)} packets reach the kernel` : '', labelAt: [1, 2], dy: -12}];
  if (rh > 1) P1.push({t: 'io', pts: Array.from({length: rh}, (_, i) => [sx, y0 + i])});
  const rows_ = [];
  for (let i = 0; i < rh; i++) rows_.push({t: 'io', pts: [[sx, y0 + i], [sx + 1, y0 + i], ...Array.from({length: rw}, (_, j) => [rx0 + j, y0 + i])], drops: Array.from({length: rw}, (_, j) => [rx0 + j, y0 + i]),
    label: i === 0 && leg === 2 ? 'each PE keeps its own slots, one word per wavelet' : '', labelAt: [1, 2], dy: -12});
  return [...P1.map(p => ({...p, ghost: leg === 2})), ...rows_.map(p => ({...p, ghost: leg === 1}))];
}
function outPaths(key){
  const k = WALK[key], [rx0, ry0, rw, rh] = k.rect, ex = rx0 + rw, ylast = ry0 + rh - 1, FW = k.fabric[0];
  const rows_ = []; for (let i = 0; i < rh; i++) rows_.push({t: 'c', pts: [...Array.from({length: rw}, (_, j) => [rx0 + j, ry0 + i]), [ex, ry0 + i]], from: Array.from({length: rw}, (_, j) => [rx0 + j, ry0 + i]),
    label: i === 0 ? `${cnt(k.io.d2h_packets)} packets: results, timestamps, control` : '', labelAt: [0, 1], dy: -12});
  const down = Array.from({length: rh}, (_, i) => [ex, ry0 + i]);
  return [...rows_, {t: 'c', pts: [...down, ...Array.from({length: FW - 1 - ex}, (_, j) => [ex + 1 + j, ylast]), 'E']}];
}

/* ---------- host view ---------- */
const HV = {W: 1020, H: 430, bx: 12, bw: 148, gap: 22, by: 74, bh: 136};
const EVT = {src: ['source', 'var(--x)'], doc: ['documented', 'var(--w)'], sim: ['trace', 'var(--c)'], none: ['not used here', 'var(--dim)']};
function hostStages(){
  const k = WALK[scheme], I = k.instance, nnz = I.rows.length;
  const cpu = {spmv: ['partition_row_block: 4 blocks', 'csr_pad to the caps', 'u32 / f32 → 32-bit words'], spmm: ['row tiles × mesh rows', 'B slices × mesh columns', 'replicated per PE'],
               spgemm: ['csc_pad: A by column', 'pattern = mask', 'reference: masked A\'A'], spgemm_acc: ['csc_pad: A by column', 'pattern = mask', 'reference: masked A\'A']}[scheme];
  return [dict('storage', 'Storage', 'none', ['no file is read', 'matrices are generated', 'in memory']),
          dict('ram', 'Host RAM', 'src', [`A: ${I.n} × ${I.m}, ${nnz} nnz`, scheme === 'spmv' ? 'x: 16 ints' : scheme === 'spmm' ? 'B: 8 × 4 ints' : 'values 1–3', 'numpy, fixed seed']),
          dict('cpu', 'Host CPU', 'src', cpu), dict('runtime', 'SDK runtime', 'src', ['SdkRuntime (simulator)', 'memcpy_h2d, 32-bit', 'launch / memcpy_d2h']),
          dict('transport', 'Network', 'doc', ['device: 100 GbE', 'to the CS-3 (1.2 Tb/s)', 'sim: in-process']),
          dict('edge', 'Wafer edge', 'sim', ['I/O channel, west', 'colour 23', '--channels 1'])];
  function dict(id, title, ev, lines){ return {id, title, ev, lines}; }
}
function hostView(f){
  const S = hostStages(), act = new Set(f.active || []); let g = '';
  [['outside the program', 0, 0], ['host program (Python, numpy, SDK runtime)', 1, 3], ['system and wafer', 4, 5]].forEach(([t, a, b]) => {
    const x0 = HV.bx + a * (HV.bw + HV.gap), x1 = HV.bx + b * (HV.bw + HV.gap) + HV.bw;
    g += txt((x0 + x1) / 2, 30, t, {a: 'middle', fs: 11, fo: .6}) + `<line x1="${x0 + 2}" y1="38" x2="${x1 - 2}" y2="38" stroke="currentColor" stroke-opacity=".25"/>`; });
  S.forEach((s, i) => {
    const x = HV.bx + i * (HV.bw + HV.gap), on = act.has(s.id), [evl, evc] = EVT[s.ev];
    g += `<rect x="${x}" y="${HV.by}" width="${HV.bw}" height="${HV.bh}" rx="6" fill="${on ? 'color-mix(in srgb,var(--io) 10%,var(--pan))' : 'var(--pan)'}" stroke="${on ? 'var(--io)' : 'currentColor'}" stroke-opacity="${on ? 1 : .35}" stroke-width="${on ? 2 : 1}" ${s.ev === 'none' ? 'stroke-dasharray="5 4"' : ''}/>`;
    g += txt(x + 10, HV.by + 22, s.title, {fs: 13, w: 1, fo: on ? 1 : .7});
    s.lines.forEach((l, j) => g += txt(x + 10, HV.by + 44 + j * 15, l, {fs: 10, fo: on ? .9 : .55}));
    g += `<rect x="${x + 10}" y="${HV.by + HV.bh - 24}" width="${evl.length * 6 + 12}" height="15" rx="2" fill="none" stroke="${evc}" stroke-opacity=".8"/>` + txt(x + 16, HV.by + HV.bh - 13, evl.toUpperCase(), {fs: 8, c: evc});
    if (i < S.length - 1){ const ax = x + HV.bw + 3, bx = x + HV.bw + HV.gap - 3, y = HV.by + HV.bh / 2, cc = act.has(s.id) && act.has(S[i + 1].id) ? 'var(--io)' : 'currentColor';
      g += poly([[ax, y], [bx, y]], cc, 2, `stroke-opacity="${cc === 'currentColor' ? .35 : 1}"`) + head(f.reverse ? ax + 6 : bx, y, cc, f.reverse ? 'l' : 'r'); }
  });
  let x = HV.bx; g += txt(HV.bx, 262, 'the data at this stage', {fs: 10, fo: .6});
  (f.formats || []).forEach((q, i, A) => { const w = Math.max(150, Math.max(q[0].length * 7.2, q[1].length * 6) + 24);
    g += `<rect x="${x}" y="274" width="${w}" height="54" rx="4" fill="var(--pan)" stroke="var(--io)" stroke-opacity=".6"/>` + txt(x + 10, 296, q[0], {fs: 12, w: 1}) + txt(x + 10, 314, q[1], {fs: 9.5, fo: .7});
    if (i < A.length - 1) g += poly([[x + w + 4, 301], [x + w + 22, 301]], 'var(--io)', 1.8) + head(x + w + 22, 301, 'var(--io)', 'r'); x += w + 28; });
  (f.notes || []).forEach((n, i) => g += txt(HV.bx, 360 + i * 17, n, {fs: 10.5, fo: .78}));
  return g;
}

/* ---------- phases ---------- */
const phases = {};
function lab(name, k, px, py){
  const W_ = WALK[k];
  if (k === 'spmv'){ const pe = W_.pes[`${px},0`]; return {row_ptr: `[${W_.params.nrows_pe + 1}]`, col_idx: `[${W_.params.max_nnz_pe}]`, val: `[${W_.params.max_nnz_pe}]`, x: `[${W_.params.ncols}]`, y: `[${W_.params.nrows_pe}]`}[name]; }
  if (k === 'spmm'){ const pe = W_.pes[`${px},${py}`]; return {row_ptr: `[${W_.params.Mt + 1}]`, col_idx: `[${W_.params.max_nnz_pe}]`, val: `[${W_.params.max_nnz_pe}]`, B_tile: `[${W_.params.K}×${W_.params.Nt}]`, C_tile: `[${W_.params.Mt}×${W_.params.Nt}]`}[name]; }
  return {col_ptr: `[${W_.params.n + 1}]`, row_idx: `[${W_.params.max_nnz}]`, val: `[${W_.params.max_nnz}]`, c_val: `[${W_.nnz}]`, c_row: `[${W_.nnz}]`, acc_val: `[${W_.params.n}]`, acc_pat: `[${W_.params.n}]`}[name];
}
const B = (k, roles) => (px, py) => Object.fromEntries(ROWS[k].map(b => [b, {label: lab(b, k, px, py), role: typeof roles[b] === 'function' ? roles[b](px, py) : (roles[b] || 'held')}]));
const H = (id, title, active, text, checks, code, hl, extra = {}) => ({id, view: 'host', ev: extra.ev || 'src', group: extra.group || 'host', title, active, text, checks, code, hl, ...extra});
{
  const v = WALK.spmv, P = v.params.P, io = v.io, mcst = v.mcast;
  const pe1 = v.pes['1,0'], pe0 = v.pes['0,0'];
  const perNnz = pe => ((pe.last_fadds - pe.first_fmuls) / Math.max(1, pe.nnz - 1)).toFixed(1);
  phases.spmv = [
    H('h1', 'Where A and x come from', ['ram', 'cpu'], `The instance is generated in host RAM: a ${v.instance.n}×${v.instance.m} matrix with 2 or 3 integer nonzeros per row and an integer x, so every product and sum is exact in f32. The host cuts the rows into ${P} consecutive blocks with <code>partition_row_block</code>, pads each block to the compiled caps with <code>csr_pad</code> (row_ptr past the real rows repeats nnz; col_idx and val are zero-filled), and views every u32 and f32 as one 32-bit word.`,
      [['nonzeros per PE', v.pes ? Object.values(v.pes).map(p => p.nnz).join(', ') : ''], ['words per PE (row_ptr + col_idx + val)', `${v.params.nrows_pe + 1} + ${v.params.max_nnz_pe} + ${v.params.max_nnz_pe}`], ['x words', v.params.ncols]],
      ['walk_instance', 'spmv_partition', 'spmv_pad'], ['partition_row_block', 'csr_pad', 'np\\.full'], {formats: [['A: 16 × 16, 39 nnz', 'row, col, val triples'], ['4 local CSRs, padded', 'row_ptr[5], col_idx[12], val[12] each'], ['+ x[16]', 'to PE 0 only']]}),
    H('h3', 'Runtime and transport to the wafer edge', ['runtime', 'transport', 'edge'], `Four memcpy_h2d calls: three write a (1 × ${P}) strip region, one word per PE slot, and one writes x to PE 0 alone. In the simulator (this trace) SdkRuntime runs the program on simfabric; on a CS-3 the same calls go over 100 GbE to the system. On the wafer they enter through the west I/O channel and are carried on colour 23 to the kernel row.`,
      [['host→device packets that reach the kernel row', cnt(io.h2d_packets)], ['of which data words the host sent, found', ok([io.h2d_words_found, io.h2d_words_expected])]],
      ['spmv_host_h2d'], ['memcpy_h2d', 'h2d_strip'], {ev: 'doc', formats: [['memcpy_h2d(row_ptr, 0,0, 4,1, 5)', 'u32, row-major, copy mode'], ['… col_idx, val (12 each)', 'per PE slot'], ['memcpy_h2d(x, 0,0, 1,1, 16)', 'PE 0 only']],
       notes: ['Documented: memcpy zero-extends 16-bit types; these arrays are already 32-bit, so a word is a wavelet.']}),
    {id: 'in1', view: 'wafer', ev: 'meas', group: 'host → wafer', title: 'West I/O port → memcpy support → the kernel row',
      text: `Every word enters at the west halo, crosses the memcpy support columns and turns east along row ${v.rect[1]}. The stream passes all ${P} kernel PEs; each keeps the words of its own slot. ${cnt(io.h2d_packets)} packets were seen in the kernel region, ${cnt(io.h2d_words_found)} of them the exact ${cnt(io.h2d_words_expected)} data words the host sent (the rest are memcpy control).`,
      checks: [['data words found in the kernel region', ok([io.h2d_words_found, io.h2d_words_expected])], ['values per wavelet', io.values_per_packet]], code: ['spmv_host_h2d'], hl: ['memcpy_h2d'],
      held: () => ({}), paths: inPaths(1, 'spmv')},
    {id: 'in2', view: 'wafer', ev: 'meas', group: 'host → wafer', title: 'Arrays land in SRAM; x on PE 0 only',
      text: `After the four copies, every PE holds its padded CSR slice, and only PE 0 holds x. The kernel has not started; nothing has crossed between PEs.`,
      checks: [['x delivered to', 'PE 0 (16 words)'], ['CSR slices delivered to', `${P} PEs`]], code: ['spmv_host_h2d'], hl: ['PE 0 only'],
      held: (px) => ({row_ptr: 1, col_idx: 1, val: 1, x: px === 0 ? 1 : 0, y: 0}), paths: inPaths(2, 'spmv')},
    {id: 'mc', view: 'kernel', ev: 'meas', group: 'compute', title: 'x is multicast east: one send, three receivers',
      text: `<code>main</code> on PE 0 starts an asynchronous <code>@fmovs(fab_x_out, x_dsd)</code>: ${v.params.ncols} wavelets leave through OQ2 on colour ${mcst.path.length ? 8 : 8}. The layout's routes make it a hardware multicast: PE 1 and PE 2 are configured rx WEST → tx RAMP <b>and</b> EAST, so each wavelet is copied down their ramps into IQ2 and forwarded; PE 3 (rx WEST → tx RAMP) only delivers. PEs 1–3 armed <code>@fmovs(x_dsd, fab_x_in, .activate = COMPUTE)</code> at cycle ${cnt(pe1.x_move.c)}, before the first packet (${cnt(mcst.first_send)}), so the receive waits in the queue; the last packet reaches PE 3 at cycle ${cnt(mcst.last_arrival)}: ${mcst.per_hop_cycles.join('/')} cycle per hop, ${v.params.ncols} packets back to back. PE 0 does not wait: it activates COMPUTE at once and multiplies while its own send is still draining.`,
      checks: [['packets on colour 8', cnt(mcst.packets)], ['routers seen per packet (send + 3 deliveries)', mcst.routers_per_packet.join('/')], ['payload = x, in order', mcst.payload_is_x_in_order ? '16 / 16' : 'no'], ['cycles per hop', mcst.per_hop_cycles.join('/')]],
      code: ['spmv_main', 'spmv_fab_dsds', 'spmv_layout_routes', 'spmv_queues'], hl: ['fmovs', 'RAMP, EAST', 'fab_x', 'C_X'],
      bufs: B('spmv', {row_ptr: 'held', col_idx: 'held', val: 'held', x: px => px === 0 ? 'send' : 'recv', y: 'idle'}),
      moves: [{t: 'x', a: [0, 0], b: [P - 1, 0], path: Array.from({length: P}, (_, i) => [i, 0]), mult: true, colour: 8, q: ['OQ2', 'IQ2'], from: 'x', to: 'x'}]},
    {id: 'cmp', view: 'kernel', ev: 'meas', group: 'compute', title: 'Each PE walks its rows: gather x by column, multiply, add',
      text: `<code>spmv_rows</code> is the textbook loop: for each local row, for each stored j, <code>sum += val[j] * x[col_idx[j]]</code>. In the trace that is one FMULS and one FADDS per nonzero, lane 0 only, and about ${v.inner_iteration.length} dispatched instructions around them: two index loads, a shift and add to form the address of x[col], the gathered load of x, the load of val, the compare and jump. ${perNnz(pe1)} cycles per nonzero on PE 1 (${pe1.nnz} nonzeros, cycles ${cnt(pe1.first_fmuls)}–${cnt(pe1.last_fadds)}); PE 0 starts first, at ${cnt(pe0.first_fmuls)}, because it never waited for x.`,
      checks: [['FMULS/FADDS operands and results = val[j] · x[col[j]], running sum, bit for bit', ok(v.checks.arithmetic)], ['final sums = y read back by the host', ok(v.checks.outputs)], ['device-internal window (TSC), max over PEs', `${cnt(v.cycles_send)} cycles`]],
      code: ['spmv_rows'], hl: ['col_idx_array\\[j\\]', 'x_array\\[c\\]', 'sum \\+='],
      bufs: B('spmv', {row_ptr: 'read', col_idx: 'read', val: 'read', x: 'gather', y: 'acc'}), moves: []},
    {id: 'out', view: 'wafer', ev: 'meas', group: 'wafer → host', title: 'y streams out through the east edge',
      text: `memcpy_d2h reads y from every PE (${v.params.nrows_pe} words each), then the six 16-bit timestamp words. ${cnt(io.d2h_packets)} packets were seen leaving the kernel region on colour 21; the ${cnt(io.d2h_words_expected)} y words are all among them.`,
      checks: [['y words found on colour 21', ok([io.d2h_words_found, io.d2h_words_expected])]], code: ['spmv_host_h2d'], hl: ['memcpy_d2h'],
      held: () => ({y: 1}), paths: outPaths('spmv')},
    H('h4', 'Back on the host: verify', ['cpu', 'ram'], `The host reassembles the ${P} slices, drops the padding rows and compares with numpy's float64 A·x. Exact: ${v.exact ? 'yes' : 'no'}.`,
      [['y == A·x (all 16 rows)', v.exact ? '16 / 16' : 'no']], ['spmv_host_h2d'], ['assert_allclose'], {group: 'host', reverse: true, formats: [['y: 4 slices × 4 words', 'from memcpy_d2h'], ['y[16] = ' + v.y_dev.flat().map(num).join(', '), 'integers, exact']]}),
  ];
}
{
  const m = WALK.spmm, P = m.params.P, io = m.io, pe = m.pes['0,0'];
  phases.spmm = [
    H('h1', 'Where A and B come from, and how they are cut', ['ram', 'cpu'], `A is ${m.instance.n}×${m.instance.m} with 2–3 integer nonzeros per row, B is ${m.params.K}×${P * m.params.Nt} with small integers (some zero). The host cuts A into ${P} row tiles (one per mesh row) and B into ${P} column slices of ${m.params.Nt} columns (one per mesh column). Then it <b>replicates</b>: PE (px, py) receives row tile py and B slice px, so no PE ever needs another PE's data.`,
      [['nonzeros per row tile', m.pes ? [m.pes['0,0'].nnz, m.pes['0,1'].nnz].join(', ') : ''], ['B words per PE', m.params.K * m.params.Nt], ['copies of each row tile / B slice', `${P} / ${P}`]],
      ['walk_instance', 'spmm_host_tiles'], ['row_ptr\\[py, px\\]', 'B_tiles\\[py, px\\]'], {formats: [['A: 8 × 8, 19 nnz', 'CSR'], ['2 row tiles × 2 copies', 'row_ptr[5], col_idx[12], val[12]'], ['B: 8 × 4 → 2 slices × 2 copies', '8 × 2 each, row-major']]}),
    H('h3', 'Runtime and transport to the wafer edge', ['runtime', 'transport', 'edge'], `Four memcpy_h2d calls over the ${P} × ${P} region, one word per PE slot. The B slice is the largest: ${m.params.K * m.params.Nt} words per PE.`,
      [['host→device packets that reach the kernel', cnt(io.h2d_packets)], ['data words found', ok([io.h2d_words_found, io.h2d_words_expected])]],
      ['spmm_host_h2d'], ['memcpy_h2d', 'h2d_mesh'], {ev: 'doc', formats: [['memcpy_h2d(row_ptr, 0,0, 2,2, 5)', 'u32, row-major'], ['… col_idx, val (12), B_tile (16)', 'per PE'], ['180 words', '188 packets seen']]}),
    {id: 'in1', view: 'wafer', ev: 'meas', group: 'host → wafer', title: 'West I/O port → support → both kernel rows',
      text: `The stream enters at the west halo, comes down the support column to each kernel row and runs east through it; each PE keeps its slot. ${cnt(io.h2d_words_found)} of the ${cnt(io.h2d_words_expected)} data words the host sent were found in the kernel region.`,
      checks: [['data words found', ok([io.h2d_words_found, io.h2d_words_expected])], ['packets in the kernel region', cnt(io.h2d_packets)]], code: ['spmm_host_h2d'], hl: ['memcpy_h2d'], held: () => ({}), paths: inPaths(1, 'spmm')},
    {id: 'in2', view: 'wafer', ev: 'meas', group: 'host → wafer', title: 'Every PE holds a whole row tile and a whole B slice',
      text: `Replication done: PEs (0,py) and (1,py) hold the same CSR tile; PEs (px,0) and (px,1) hold the same B slice. The kernel starts with nothing to exchange.`,
      checks: [['kernel colours in the trace', m.kernel_colours.join(', ') + ' (memcpy only)']], code: ['spmm_host_tiles'], hl: ['B_tiles'], held: () => ({row_ptr: 1, col_idx: 1, val: 1, B_tile: 1}), paths: inPaths(2, 'spmm')},
    {id: 'cmp', view: 'kernel', ev: 'meas', group: 'compute', title: 'Each PE forms its Mt × Nt tile of C: one AXPY per nonzero',
      text: `<code>spmm_tile</code>: for each local row r, clear C[r,:], then for each stored a_rk scale the dense row B[k,:] into C[r,:]. That is an outer-product (AXPY) form inside the PE, one FMULS and one FADDS per (nonzero, output column). The compiled loop runs the output columns from Nt−1 down to 0 (observed). No fabric traffic: the mesh rows finish at different times because their row tiles have different nonzero counts (${m.pes['0,0'].nnz} vs ${m.pes['0,1'].nnz}), and the device-internal window is ${cnt(m.cycles_send)} cycles.`,
      checks: [['FMULS/FADDS operands and results = a_rk · B[k,c], running C[r,c]', ok(m.checks.arithmetic)], ['final C elements = host readback', ok(m.checks.outputs)], ['per-PE windows (TSC)', Object.values(m.pes).map(p => p.window_tsc[1] - p.window_tsc[0]).join(', ') + ' cycles']],
      code: ['spmm_tile', 'spmm_main'], hl: ['C_tile\\[c_base \\+ cc\\] \\+=', 'B_tile\\[b_base'],
      bufs: B('spmm', {row_ptr: 'read', col_idx: 'read', val: 'read', B_tile: 'gather', C_tile: 'acc'}), moves: []},
    {id: 'out', view: 'wafer', ev: 'meas', group: 'wafer → host', title: 'C tiles stream out east',
      text: `memcpy_d2h reads C_tile (${m.params.Mt * m.params.Nt} words) from every PE, then the timestamps. ${cnt(io.d2h_packets)} packets left the kernel region; all ${cnt(io.d2h_words_expected)} C words are among them.`,
      checks: [['C words found on colour 21', ok([io.d2h_words_found, io.d2h_words_expected])]], code: ['spmm_host_h2d'], hl: ['memcpy_d2h'], held: () => ({C_tile: 1}), paths: outPaths('spmm')},
    H('h4', 'Back on the host: verify', ['cpu', 'ram'], `The host assembles the four tiles into the 8 × 4 C and compares with numpy's float64 A·B. Exact: ${m.exact ? 'yes' : 'no'}.`,
      [['C == A·B (32 elements)', m.exact ? '32 / 32' : 'no']], ['spmm_host_h2d'], ['assert_allclose'], {group: 'host', reverse: true, formats: [['4 tiles × 8 words', 'from memcpy_d2h'], ['C: 8 × 4, integers', 'exact']]}),
  ];
}
function spgemmPhases(k){
  const g = WALK[k], io = g.io, acc = k === 'spgemm_acc', ref = WALK.spgemm;
  const span = g.compute_span[1] - g.compute_span[0];
  return [
    H('h1', 'Where A comes from: stored by column, pattern = mask', ['ram', 'cpu'], `A is ${g.instance.n}×${g.instance.m} with 2–3 nonzeros per row, values 1–3. The host transposes it into CSC (<code>csc_pad</code>): col_ptr, sorted row_idx, val. The stored pattern is also the mask: the kernel computes C(i,j) = A(:,i)·A(:,j) exactly at the ${g.nnz} stored positions, and nowhere else. The reference is numpy's masked AᵀA; entries whose two columns share no row are zombies.`,
      [['mask entries', g.nnz], ['of which zombies (no shared row)', g.nzombies], ['row intersections (products) in total', g.matches_total]],
      ['walk_instance', 'spgemm_host_csc', 'spgemm_csc_pad'], ['csc_pad', 'masked_gram'], {formats: [['A: 8 × 8, 22 nnz', 'row, col, val'], ['CSC: col_ptr[9], row_idx[24], val[24]', 'padded to max_nnz'], ['mask = pattern of A', '22 positions']]}),
    H('h3', 'Runtime and transport to the wafer edge', ['runtime', 'transport', 'edge'], `Three memcpy_h2d calls to the single PE (col_ptr, row_idx, val), then <code>runner.call("compute")</code>, then three reads back (c_val, c_row, nzombies) and the timer words.`,
      [['host→device packets that reach the PE', cnt(io.h2d_packets)], ['data words found', ok([io.h2d_words_found, io.h2d_words_expected])]], ['spgemm_host_csc'], ['memcpy_h2d'], {ev: 'doc'}),
    {id: 'in1', view: 'wafer', ev: 'meas', group: 'host → wafer', title: 'West I/O port → support → the one kernel PE',
      text: `${cnt(io.h2d_words_found)} of ${cnt(io.h2d_words_expected)} data words found in ${cnt(io.h2d_packets)} packets at the kernel PE.`,
      checks: [['data words found', ok([io.h2d_words_found, io.h2d_words_expected])]], code: ['spgemm_host_csc'], hl: ['memcpy_h2d'], held: () => ({col_ptr: 1, row_idx: 1, val: 1}), paths: inPaths(1, k)},
    acc ? {id: 'cmp', view: 'kernel', ev: 'meas', group: 'compute', title: 'Scatter a column, gather every mask entry against it, un-scatter',
      text: `For each column j: scatter A(:,j) into a dense accumulator (<code>acc_val[k] = val</code>, <code>acc_pat[k] = 1</code>); then for every stored (i, j) walk A(:,i) once and accumulate <code>val[q] · acc_val[row_idx[q]]</code>, which is 0 where column j has no entry, counting hits from acc_pat; then clear only the touched entries. The trace shows one FMULS/FADDS per stored row of A(:,i), ${g.matches_total} in all (${ref.matches_total} of them non-zero products), no merge compares. ${cnt(span)} cycles for the ${g.nnz} entries, against ${cnt(ref.compute_span[1] - ref.compute_span[0])} for the merge on the same instance.`,
      checks: [['FMULS/FADDS = val[q] · acc_val[k], running sum, bit for bit', ok(g.checks.arithmetic)], ['c_val = host readback', ok(g.checks.c_values)], ['c_row codes (i or ~i)', ok(g.checks.row_codes)], ['zombies', ok(g.checks.zombies)], ['mask entries with a found store boundary', ok(g.checks.entry_boundaries_found)]],
      code: ['spgemm_accum'], hl: ['acc_val\\[k\\] = val', 'cij \\+=', 'hits \\+='], bufs: B('spgemm_acc', {col_ptr: 'read', row_idx: 'read', val: 'read', acc_val: 'scatter', acc_pat: 'scatter', c_val: 'write', c_row: 'write'}), moves: []}
    : {id: 'cmp', view: 'kernel', ev: 'meas', group: 'compute', title: 'Merge two sorted columns for every mask entry',
      text: `For each column j and each stored row i of it: two pointers walk A(:,i) and A(:,j); equal row indices give one FMULS/FADDS, unequal ones advance the smaller. The work is the merge: in the trace, the compute window has ${cnt(g.mix.by_class.float)} floating-point dispatches out of ${cnt(g.mix.total)}; the rest are compares (${cnt(g.mix.by_class.branch)} compare/branch), address arithmetic and, notably, stores and loads of the merge pointers to the stack. ${cnt(span)} cycles for ${g.nnz} entries; a zombie costs as much as a hit.`,
      checks: [['FMULS/FADDS = val[pa] · val[pb], running sum, bit for bit', ok(g.checks.arithmetic)], ['c_val = host readback', ok(g.checks.c_values)], ['c_row codes (i or ~i)', ok(g.checks.row_codes)], ['zombies', ok(g.checks.zombies)], ['mask entries with a found store boundary', ok(g.checks.entry_boundaries_found)]],
      code: ['spgemm_merge', 'spgemm_compute'], hl: ['ia == ib', 'cij \\+=', 'pa \\+= 1', 'pb \\+= 1', '~i'], bufs: B('spgemm', {col_ptr: 'read', row_idx: 'read', val: 'read', c_val: 'write', c_row: 'write'}), moves: []},
    {id: 'out', view: 'wafer', ev: 'meas', group: 'wafer → host', title: 'c_val, c_row and the zombie count stream out',
      text: `${cnt(io.d2h_packets)} packets left the PE on colour 21; all ${cnt(io.d2h_words_expected)} result words (c_val and c_row) are among them.`,
      checks: [['result words found on colour 21', ok([io.d2h_words_found, io.d2h_words_expected])]], code: ['spgemm_host_csc'], hl: ['memcpy_d2h'], held: () => ({c_val: 1, c_row: 1}), paths: outPaths(k)},
    H('h4', 'Back on the host: verify values, codes and zombies', ['cpu', 'ram'], `numpy recomputes A(:,i)·A(:,j) at every mask position and the structural existence; the kernel's c_val, c_row and nzombies must all match. Exact: ${g.exact ? 'yes' : 'no'}.`,
      [['c_val, c_row, nzombies', g.exact ? 'all match' : 'mismatch']], ['spgemm_host_csc'], ['assert_allclose', 'assert_array_equal'], {group: 'host', reverse: true}),
  ];
}
phases.spgemm = spgemmPhases('spgemm'); phases.spgemm_acc = spgemmPhases('spgemm_acc');

/* ---------- detail panel ---------- */
const arrTable = (name, vals, t, o = {}) => `<div class="gridwrap"><table class="grid g-${t === 'idx' ? 'i' : t}"><tr><th class="corner">${o.idx || 'i'}</th>${vals.map((_, i) => `<th>${i}</th>`).join('')}</tr>
  <tr><th>${name}</th>${vals.map((v, i) => `<td class="${o.hl && o.hl.has(i) ? 'hl' : ''}" title="${hex32(typeof v === 'number' && !Number.isInteger(v) || t !== 'idx' ? f32bits(v) : v)}">${num(v)}</td>`).join('')}</tr></table></div>`;
const chainTable = (heads, rows) => `<div class="gridwrap"><table class="chain"><thead><tr>${heads.map(h => `<th>${h}</th>`).join('')}</tr></thead><tbody>${rows.map(r => `<tr>${r.map(c => `<td>${c}</td>`).join('')}</tr>`).join('')}</tbody></table></div>`;
const tick = b => b ? '✓' : '✗';
function detailBuf(){
  const {name, px, py} = detailSel, k = WALK[scheme], f = phases[scheme][ph];
  const hdr = `<p class="eyebrow">${SHORT[scheme]} · PE (${px},${py}) · ${esc(f.title)}</p>`;
  if (scheme === 'spmv'){
    const pe = k.pes[`${px},0`];
    if (name === 'row_ptr') return hdr + `<h3>row_ptr: where each local row's nonzeros start</h3>` + arrTable('row_ptr', pe.row_ptr, 'idx', {idx: 'r'}) + `<p class="mini">Row r owns j ∈ [row_ptr[r], row_ptr[r+1]). Rows past the real ones repeat nnz (${pe.nnz}), so they are empty.</p>`;
    if (name === 'col_idx') return hdr + `<h3>col_idx: global column of each stored value</h3>` + arrTable('col_idx', pe.col_idx, 'idx', {idx: 'j'}) + `<p class="mini">${pe.nnz} used, the rest zero padding. These are the indices of the gathered x reads.</p>`;
    if (name === 'val') return hdr + `<h3>val: the stored values</h3>` + arrTable('val', pe.val, 'w', {idx: 'j'});
    if (name === 'x'){
      let h = hdr + `<h3>x (${k.params.ncols} values)${px ? ', received by multicast' : ', loaded by the host'}</h3>` + arrTable('x', k.x, 'x', {hl: new Set(pe.col_idx.slice(0, pe.nnz))});
      h += px ? `<p class="ok">Receive armed at cycle ${cnt(pe.x_move.c)} (${pe.x_move.n}, micro-thread ${pe.x_move.ut}); last packet arrived at this PE at ${cnt(pe.x_last_arrival)}; first FMULS at ${cnt(pe.first_fmuls)}. Payload of all 16 packets = x, in order.</p>`
                : `<p class="ok">Sent by @fmovs on colour 8 from cycle ${cnt(k.mcast.first_send)}; this PE started multiplying at ${cnt(pe.first_fmuls)} without waiting.</p>`;
      return h + `<p class="mini">Highlighted: the ${pe.nnz} entries this PE gathers (its col_idx).</p>`;
    }
    let h = hdr + `<h3>y: this PE's ${k.params.nrows_pe} rows, term by term, as traced</h3>`;
    pe.rows.forEach(row => { h += `<p class="eyebrow" style="margin-top:10px">y[${row.grow}] (local row ${row.r}): ${row.terms.map(t => `${num(t.val)}·x[${t.col}]`).join(' + ') || 'no nonzeros'} = <b>${num(row.y)}</b> · host read ${num(row.y_dev)} ${tick(row.y === row.y_dev)}</p>`;
      if (row.terms.length) h += chainTable(['j', 'col', 'val', 'x[col]', 'product', 'sum', 'FMULS @', 'FADDS @', ''], row.terms.map(t => [t.j, t.col, num(t.val), num(t.x), num(t.product), `<b>${num(t.acc)}</b>`, cnt(t.cyc_mul), cnt(t.cyc_add), tick(t.ok)])); });
    return h + `<p class="ok">${ok(k.checks.arithmetic)} multiply/add pairs across the strip match the trace bit for bit.</p>`;
  }
  if (scheme === 'spmm'){
    const pe = k.pes[`${px},${py}`];
    if (name === 'row_ptr') return hdr + `<h3>row_ptr of row tile ${py}</h3>` + arrTable('row_ptr', pe.row_ptr, 'idx', {idx: 'r'});
    if (name === 'col_idx') return hdr + `<h3>col_idx (k) of row tile ${py}</h3>` + arrTable('col_idx', pe.col_idx, 'idx', {idx: 'j'});
    if (name === 'val') return hdr + `<h3>val of row tile ${py}</h3>` + arrTable('val', pe.val, 'w', {idx: 'j'});
    if (name === 'B_tile'){ const rows = []; for (let r = 0; r < k.params.K; r++) rows.push(pe.B_tile.slice(r * k.params.Nt, (r + 1) * k.params.Nt));
      return hdr + `<h3>B slice ${px}: columns ${px * k.params.Nt}–${px * k.params.Nt + k.params.Nt - 1} of B, all ${k.params.K} rows</h3>` + chainTable(['k', ...Array.from({length: k.params.Nt}, (_, c) => `B[k][${px * k.params.Nt + c}]`)], rows.map((r, i) => [i, ...r.map(num)])) + `<p class="mini">Row k of this slice is what nonzero a_rk scales into C[r,:].</p>`; }
    let h = hdr + `<h3>C tile (${k.params.Mt} × ${k.params.Nt}): every element, term by term</h3>`;
    pe.rows.forEach(row => row.cells.forEach(cell => { h += `<p class="eyebrow" style="margin-top:8px">C[${row.grow}][${cell.gcol}] = ${cell.terms.map(t => `${num(t.val)}·B[${t.k}][${cell.gcol}]`).join(' + ') || '0'} = <b>${num(cell.C)}</b> · host ${num(cell.C_dev)} ${tick(cell.C === cell.C_dev)}</p>`;
      if (cell.terms.length) h += chainTable(['j', 'k', 'a_rk', 'B[k][c]', 'product', 'sum', 'FMULS @', 'FADDS @', ''], cell.terms.map(t => [t.j, t.k, num(t.val), num(t.b), num(t.product), `<b>${num(t.acc)}</b>`, cnt(t.cyc_mul), cnt(t.cyc_add), tick(t.ok)])); }));
    return h;
  }
  const g = k;
  if (name === 'col_ptr') return hdr + `<h3>col_ptr: where each column's rows start</h3>` + arrTable('col_ptr', g.col_ptr, 'idx', {idx: 'j'});
  if (name === 'row_idx') return hdr + `<h3>row_idx: sorted row of each stored value (CSC)</h3>` + arrTable('row_idx', g.row_idx.slice(0, g.nnz), 'idx', {idx: 'p'});
  if (name === 'val') return hdr + `<h3>val, in column order</h3>` + arrTable('val', g.val.slice(0, g.nnz), 'w', {idx: 'p'});
  if (name.startsWith('acc')) return hdr + `<h3>${name}: the dense accumulator (${g.params.n} entries)</h3><p>For column j, <code>acc_val[k] = A(k,j)</code> and <code>acc_pat[k] = 1</code> for every stored k of column j; all other entries are 0. After the column's mask entries are done, only those k are cleared, so the cost stays proportional to nnz(A(:,j)).</p>`;
  let h = hdr + `<h3>${name === 'c_val' ? 'c_val: C(i,j) at every mask position' : 'c_row: row code, i or ~i (zombie)'}</h3>`;
  g.entries.forEach(e => {
    h += `<p class="eyebrow" style="margin-top:8px">p = ${e.p}: C(${e.i},${e.j}) = A(:,${e.i})·A(:,${e.j}) = <b>${num(e.c)}</b>${e.zombie ? ' · <b>zombie</b> (no shared row), c_row = ~' + e.i + ' = ' + hex32(e.c_row_dev) : ' · c_row = ' + e.i} · host ${num(e.c_dev)} ${tick(e.c === e.c_dev)}${e.cycles ? ` · ${cnt(e.instructions)} instructions, ${cnt(e.cycles)} cycles` : ''}</p>`;
    h += `<p class="mini">A(:,${e.i}) = {${e.colA.map(([r, v]) => `${r}:${num(v)}`).join(', ')}} · A(:,${e.j}) = {${e.colB.map(([r, v]) => `${r}:${num(v)}`).join(', ')}}</p>`;
    h += chainTable(scheme === 'spgemm' ? ['step', 'ia', 'ib', 'action', 'product', 'sum', 'FMULS @', ''] : ['q', 'k', 'val[q]', 'acc_val[k]', 'product', 'sum', 'FMULS @', ''],
      e.steps.map((s, si) => scheme === 'spgemm' ? [si, s.ia, s.ib, s.action, s.match ? num(s.product) : '', s.match ? `<b>${num(s.acc)}</b>` : num(s.acc), s.match && s.cyc_mul ? cnt(s.cyc_mul) : '', s.match ? tick(s.ok) : '']
                                                   : [s.pa, s.ia, num(s.a), num(s.b), num(s.product), `<b>${num(s.acc)}</b>`, s.cyc_mul ? cnt(s.cyc_mul) : '', tick(s.ok)]));
  });
  return h;
}
function showDetail(){
  const el = $('detail'); if (!detailSel){ el.innerHTML = `<p class="eyebrow">Numbers from the traced run</p><p>Tap any array in a PE's SRAM, or a kernel PE in the wafer view, to see its exact values from the run the host checked. Outputs open term by term, each with the cycle at which the trace shows the multiply and the add.</p>`; return; }
  const k = WALK[scheme];
  if (detailSel.kind === 'pe'){ const {px, py} = detailSel; const f = phases[scheme][ph]; detailSel = {kind: 'buf', px, py, name: f.id === 'out' ? ROWS[scheme].filter(b => TOF[b] === 'c')[0] : ROWS[scheme][0]}; }
  el.innerHTML = detailBuf();
}

/* ---------- code, lifecycle, drawing, controls ---------- */
function codeBlock(key, hl){
  const s = D.snip[key]; if (!s) return '';
  const re = hl && hl.length ? new RegExp(hl.join('|')) : null;
  const lines = s.code.split('\n').map((l, i) => `<span class="ln${re && re.test(l) ? ' hl' : ''}"><i>${s.start + i}</i>${esc(l) || ' '}</span>`).join('');
  return `<details class="code" open><summary>${esc(s.file)}:${s.start}–${s.end}</summary><pre>${lines}</pre></details>`;
}
function drawLife(){
  const L = phases[scheme], groups = [];
  L.forEach((f, i) => { const g = groups[groups.length - 1]; if (g && g.name === f.group) g.items.push(i); else groups.push({name: f.group, items: [i]}); });
  $('lifebar').innerHTML = groups.map(g => `<div class="lg"><span class="lgn">${esc(g.name)}</span><div class="lgp">${g.items.map(i => `<button data-i="${i}" aria-pressed="${i === ph}" title="${esc(L[i].title)}">${i + 1}</button>`).join('')}</div></div>`).join('<span class="lga">→</span>');
  $('lifebar').querySelectorAll('button').forEach(b => b.onclick = () => { stop(); ph = +b.dataset.i; drawMesh(); });
}
function drawMesh(){
  const L = phases[scheme], f = L[ph], svg = $('mesh');
  if (f.view === 'host') detailSel = null;
  if (f.view === 'kernel' && detailSel && detailSel.kind === 'pe') showDetail();
  if (f.view === 'wafer' && detailSel && detailSel.kind === 'buf') detailSel = {kind: 'pe', px: detailSel.px, py: detailSel.py};
  if (f.view === 'wafer'){ const r = waferView(f); svg.setAttribute('viewBox', `0 0 1020 ${r.h}`); svg.innerHTML = r.svg; }
  else if (f.view === 'host'){ svg.setAttribute('viewBox', `0 0 ${HV.W} ${HV.H}`); svg.innerHTML = hostView(f); }
  else { svg.setAttribute('viewBox', `0 0 ${KV.W} ${kvH()}`); svg.innerHTML = kernelView(f); }
  svg.setAttribute('aria-label', f.title + '. ' + f.text.replace(/<[^>]+>/g, ''));
  svg.querySelectorAll('.chip').forEach(c => {
    const open = () => { if (c.dataset.pe){ const [px, py] = c.dataset.pe.split(':').map(Number); detailSel = {kind: 'pe', px, py}; }
      else { const [name, px, py] = c.dataset.buf.split(':'); detailSel = {kind: 'buf', name, px: +px, py: +py}; }
      drawMesh(); if (innerWidth < 960) $('detail').scrollIntoView({behavior: 'smooth', block: 'start'}); };
    c.addEventListener('click', open); c.addEventListener('keydown', e => { if (e.key === 'Enter' || e.key === ' '){ e.preventDefault(); open(); } });
  });
  $('phase').textContent = `phase ${ph + 1} / ${L.length}`;
  const {cols, rows} = grid();
  $('viewtag').textContent = f.view === 'wafer' ? `whole fabric · ${WALK[scheme].fabric.join(' × ')}` : f.view === 'host' ? 'host side' : `kernel · ${cols} × ${rows} · each PE = router + ramp + SRAM`;
  $('capev').innerHTML = `<span class="ev ${f.ev}">${f.ev === 'doc' ? 'documented' : f.ev === 'src' ? 'source' : 'measured'}</span> &nbsp;${esc(f.group)}`;
  $('captitle').textContent = f.title; $('captext').innerHTML = f.text;
  $('checks').innerHTML = f.checks.map(([a, b]) => `<li><span>${esc(a)}</span><b>${esc(String(b))}</b></li>`).join('');
  $('capform').innerHTML = FORM[scheme];
  $('code').innerHTML = f.code && f.code.length ? `<p class="eyebrow" style="margin-top:14px">The code that runs this phase, verbatim</p>` + f.code.map(k => codeBlock(k, f.hl)).join('') : '';
  $('mkey').innerHTML = f.view === 'wafer' ? `<span><i class="sq"></i>router, inside each PE</span><span><i class="dot"></i>delivered down the ramp into this PE</span><span>bars: arrays held (${ROWS[scheme].filter(b => !b.startsWith('acc')).join(', ')})</span>`
    : f.view === 'host' ? `<span>boxes: where the data is, left to right in time</span><span><b>source</b> = host code · <b>documented</b> = Cerebras docs · <b>trace</b> = simulator · dashed = not used by this code</span>`
    : `<span><i class="sq"></i>router: a line inside is a route, rx port → tx port</span><span><i class="dot"></i>deliver + forward: the router copies the wavelet to its ramp and onward (multicast)</span><span><b>c8 · hop 1</b> = colour 8, one arrow per link</span><span><b>OQ2 / IQ2</b> = hardware output / input queue (WSE-3: 8 / 4 words)</span><span>dashed array = being sent · bold = written or read now</span>`;
  $('mtabs').querySelectorAll('button').forEach(b => b.setAttribute('aria-pressed', String(b.dataset.k === scheme)));
  drawLife(); showDetail();
}
const FORM = {
  spmv: 'Inside each PE: <b>inner products</b>, one per row, each a gather over x. Across PEs: <b>independent row blocks</b>; the only exchange is the multicast of x. Weight-stationary, output-owning.',
  spmm: 'Inside each PE: <b>outer products</b> (one AXPY per nonzero into a row of C). Across PEs: <b>none</b>; the host replicates A row tiles and B slices so every PE owns its C tile outright.',
  spgemm: 'Inside the PE: an <b>inner product of two sparse columns</b> per mask entry, by merging sorted index lists. No parallelism across PEs in this reference.',
  spgemm_acc: 'Inside the PE: the same inner products, computed as a <b>gather against a dense accumulator</b> (Gustavson\'s form). No parallelism across PEs in this reference.',
};
$('mtabs').innerHTML = SCH.map(k => `<button data-k="${k}">${NAME[k]}</button>`).join('');
$('mtabs').querySelectorAll('button').forEach(b => b.onclick = () => { scheme = b.dataset.k; ph = 0; detailSel = null; stop(); drawMesh(); });
function stop(){ if (timer) clearInterval(timer); timer = null; $('play').textContent = 'Play'; }
$('fwd').onclick = () => { ph = Math.min(phases[scheme].length - 1, ph + 1); drawMesh(); };
$('back').onclick = () => { ph = Math.max(0, ph - 1); drawMesh(); };
$('play').onclick = () => { if (timer) return stop(); $('play').textContent = 'Pause'; timer = setInterval(() => { ph = (ph + 1) % phases[scheme].length; drawMesh(); }, 3200); };
addEventListener('keydown', e => { if (/INPUT|TEXTAREA/.test(e.target.tagName)) return; if (e.key === 'ArrowRight'){ e.preventDefault(); $('fwd').click(); } if (e.key === 'ArrowLeft'){ e.preventDefault(); $('back').click(); } });

/* ---------- check it by hand ---------- */
let hsch = 'spmv';
function dense(inst){ const M = Array.from({length: inst.n}, () => Array(inst.m).fill(0)); inst.rows.forEach((r, k) => M[r][inst.cols[k]] = inst.vals[k]); return M; }
const mat = (M, t, o = {}) => `<div class="gridwrap"><table class="grid g-${t}"><tr><th class="corner">${o.corner || ''}</th>${M[0].map((_, j) => `<th>${j}</th>`).join('')}</tr>` +
  M.map((r, i) => `<tr><th>${i}</th>${r.map((v, j) => `<td class="${v === 0 && !o.showZero ? '' : 'hl'}" ${o.pe ? `style="box-shadow: inset 0 0 0 1px ${o.pe(i, j) % 2 ? 'var(--ln)' : 'transparent'}"` : ''}>${v === 0 && !o.showZero ? '·' : num(v)}</td>`).join('')}</tr>`).join('') + `</table></div>`;
function handDraw(){
  const k = WALK[hsch], I = k.instance, A = dense(I); let h = '';
  if (hsch === 'spmv'){
    h += `<div class="stage"><div class="card"><p class="eyebrow">A (16 × 16), rows 4py–4py+3 on PE py</p>${mat(A, 'w')}</div><div class="card"><p class="eyebrow">x</p>${arrTable('x', k.x, 'x')}<p class="eyebrow" style="margin-top:12px">y = A·x, row by row</p>` +
      chainTable(['row', 'PE', 'terms', 'y', 'device'], Object.values(k.pes).flatMap(pe => pe.rows.map(r => [r.grow, pe === k.pes['0,0'] ? 0 : Object.keys(k.pes).find(q => k.pes[q] === pe).split(',')[0], r.terms.map(t => `${num(t.val)}·${num(t.x)}`).join(' + '), `<b>${num(r.y)}</b>`, `${num(r.y_dev)} ${tick(r.y === r.y_dev)}`]))) + `</div></div>`;
  } else if (hsch === 'spmm'){
    h += `<div class="stage"><div class="card"><p class="eyebrow">A (8 × 8): rows 0–3 → mesh row 0, rows 4–7 → mesh row 1</p>${mat(A, 'w')}<p class="eyebrow" style="margin-top:12px">B (8 × 4): columns 0–1 → mesh column 0, 2–3 → mesh column 1</p>${mat(k.B, 'x', {showZero: true})}</div>
      <div class="card"><p class="eyebrow">C = A·B, each element as the PE that owns it computed it</p>` +
      chainTable(['C[r][c]', 'PE', 'terms', 'C', 'device'], Object.entries(k.pes).flatMap(([key, pe]) => pe.rows.flatMap(r => r.cells.map(c => [`[${r.grow}][${c.gcol}]`, `(${key})`, c.terms.map(t => `${num(t.val)}·${num(t.b)}`).join(' + ') || '0', `<b>${num(c.C)}</b>`, `${num(c.C_dev)} ${tick(c.C === c.C_dev)}`])))) + `</div></div>`;
  } else {
    h += `<div class="stage"><div class="card"><p class="eyebrow">A (8 × 8); the mask is its pattern</p>${mat(A, 'w')}<p class="mini">C(i,j) = A(:,i)·A(:,j) = Σ_k A(k,i)·A(k,j): multiply the two columns where both have an entry.</p></div>
      <div class="card"><p class="eyebrow">the ${k.nnz} mask entries (p in CSC order)</p>` +
      chainTable(['p', '(i, j)', 'A(:,i)', 'A(:,j)', 'shared rows → products', 'C(i,j)', 'c_row', 'device'], k.entries.map(e => [e.p, `(${e.i}, ${e.j})`, `{${e.colA.map(([r, v]) => `${r}:${num(v)}`).join(', ')}}`, `{${e.colB.map(([r, v]) => `${r}:${num(v)}`).join(', ')}}`,
        e.steps.filter(s => s.match).map(s => `${num(s.a)}·${num(s.b)}`).join(' + ') || '— (zombie)', `<b>${num(e.c)}</b>`, e.zombie ? `~${e.i}` : e.i, `${num(e.c_dev)} ${tick(e.c === e.c_dev)}`])) + `</div></div>`;
  }
  $('handbody').innerHTML = h;
  $('htabs').querySelectorAll('button').forEach(b => b.setAttribute('aria-pressed', String(b.dataset.s === hsch)));
}
$('htabs').innerHTML = ['spmv', 'spmm', 'spgemm'].map(s => `<button data-s="${s}">${SHORT[s]}</button>`).join('');
$('htabs').querySelectorAll('button').forEach(b => b.onclick = () => { hsch = b.dataset.s; handDraw(); });
handDraw();

/* ---------- cost ---------- */
{
  const v = WALK.spmv, m = WALK.spmm, g = WALK.spgemm, a = WALK.spgemm_acc, R = D.refs;
  const pe1 = v.pes['1,0'], pm = m.pes['0,0'];
  const per = (mix, n) => (mix.total / n).toFixed(1);
  const cls = mix => ['address', 'load', 'store', 'move', 'branch', 'float'].map(c => `${c} ${mix.by_class[c] || 0}`).join(' · ');
  $('costtab').innerHTML = `<tr><th>kernel (traced instance)</th><th>unit of work</th><th>dispatched instructions per unit</th><th>by class, whole compute window</th><th>cycles, device window</th><th>benchmark size (study record, simulator)</th></tr>
    <tr><td>SpMV, PE 1</td><td>nonzero (${pe1.nnz})</td><td>${per(pe1.mix, pe1.nnz)}</td><td>${cls(pe1.mix)}</td><td>${cnt(v.cycles_send)} (max over PEs)</td><td>${R.spmv ? `${cnt(R.spmv.cycles)} cycles, ${R.spmv.desc}` : '—'}</td></tr>
    <tr><td>SpMM, PE (0,0)</td><td>nonzero × output column (${pm.nnz * m.params.Nt})</td><td>${per(pm.mix, pm.nnz * m.params.Nt)}</td><td>${cls(pm.mix)}</td><td>${cnt(m.cycles_send)}</td><td>${R.spmm ? `${cnt(R.spmm.cycles)} cycles, ${R.spmm.desc}` : '—'}</td></tr>
    <tr><td>SpGEMM, merge</td><td>mask entry (${g.nnz})</td><td>${per(g.mix, g.nnz)}</td><td>${cls(g.mix)}</td><td>${cnt(g.cycles_send)}</td><td>${R.spgemm ? `${cnt(R.spgemm.cycles)} cycles, ${R.spgemm.desc}` : '—'}</td></tr>
    <tr><td>SpGEMM, accumulator</td><td>mask entry (${a.nnz})</td><td>${per(a.mix, a.nnz)}</td><td>${cls(a.mix)}</td><td>${cnt(a.cycles_send)}</td><td>${R.spgemm_acc ? R.spgemm_acc.desc : '—'}</td></tr>
    <tr><td colspan="6" class="mini">Float = FMULS + FADDS. "address" is index arithmetic and shifts (SLL/SLR/ADD16), "move" includes the memory-destination moves the compiler uses for loads and stores of f32 (FMOV32/IMOV32). The merge's stores are register spills of its pointers; the accumulator variant has fewer branches and more address arithmetic.</td></tr>`;
  const it = (name, list) => `<tr><th colspan="3" style="text-align:left">${name}</th></tr>` + list.map((x, i) => `<tr><td>${i + 1}</td><td>${x.n}</td><td><code>${esc(x.asm || '')}</code></td></tr>`).join('');
  $('itertab').innerHTML = `<tr><th>#</th><th>dispatched</th><th>disassembly (from the ELF, joined by pc)</th></tr>` + it(`SpMV: one nonzero on PE 1, from the previous FADDS to this nonzero's FMULS (${v.inner_iteration.length} instructions)`, v.inner_iteration) + it(`SpMM: one (nonzero, column) on PE (0,0) (${m.inner_iteration.length} instructions)`, m.inner_iteration);
}

/* ---------- Cerebras' hypersparse SpMV ---------- */
$('hyperbody').innerHTML = D.hyper;

/* ---------- evidence ---------- */
$('evtab').innerHTML = `<tr><th>claim</th><th>evidence</th><th>how it was checked</th></tr>` + D.evidence.map(r => `<tr><td>${r[0]}</td><td><span class="ev ${r[1]}">${r[1] === 'meas' ? 'simulator' : r[1] === 'doc' ? 'documented' : 'source'}</span></td><td>${r[2]}</td></tr>`).join('');
$('foot').textContent = D.foot;
drawMesh();
