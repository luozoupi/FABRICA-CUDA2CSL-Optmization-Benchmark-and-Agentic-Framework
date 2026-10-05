/* ======================= from matrices to PEs, wavelets and colours ======================= */
{
const CO = D.col, TOY = CO.toy, IND = D.ind, SEND = D.send, X_IDS = [1, 2, 3];
const T_ = (x, y, s, o = {}) => `<text x="${x}" y="${y}" font-size="${o.fs || 11}" ${o.a ? `text-anchor="${o.a}"` : ''} fill="${o.c || 'currentColor'}"
  ${o.fo ? `fill-opacity="${o.fo}"` : ''} ${o.w ? 'font-weight="600"' : ''} font-family="IBM Plex Mono,monospace">${s}</text>`;
const R_ = (x, y, w, h, c, o = {}) => `<rect x="${x}" y="${y}" width="${w}" height="${h}" rx="${o.rx ?? 2}" fill="${o.fill || c}" fill-opacity="${o.fo ?? .14}"
  stroke="${c}" stroke-opacity="${o.so ?? .9}" stroke-width="${o.sw || 1}" ${o.dash ? 'stroke-dasharray="4 3"' : ''}/>`;
const kc = (t, k) => sh(t, k);

/* 1 · tiles and placement */
(function(){
  let g = '';
  const mat = (x0, y0, name, t, lab, sub) => {
    g += T_(x0, y0 - 10, `${name} (64 × 64 f16)`, {fs: 12, w: 1});
    for (let i = 0; i < 4; i++) for (let j = 0; j < 4; j++){
      const k = t === 'x' ? j : i;
      g += R_(x0 + j * 44, y0 + i * 44, 42, 42, kc(t, k), {fo: .22}) + T_(x0 + j * 44 + 21, y0 + i * 44 + 26, lab(i, j), {a: 'middle', fs: 10, c: kc(t, k)});
    }
    g += T_(x0, y0 + 196, sub, {fs: 10, fo: .7});
  };
  mat(20, 40, 'X', 'x', (i, k) => `${i},${k}`, 'block (i,k): 16×16 values');
  mat(220, 40, 'W', 'w', (k, j) => `${k},${j}`, 'block (k,j), rows permuted');
  g += `<path d="M420,130 L470,130" stroke="currentColor" stroke-width="2"/><path d="M470,130 l-8,-5 v10 z" fill="currentColor"/>` + T_(445, 118, 'host', {a: 'middle', fs: 10, fo: .7});
  g += T_(490, 30, 'PE (px, py) at load time: its X block, its W block; it owns C(py, px)', {fs: 12, w: 1});
  for (let py = 0; py < 4; py++) for (let px = 0; px < 4; px++){
    const x = 490 + px * 128, y = 44 + py * 68;
    g += R_(x, y, 122, 62, 'currentColor', {fo: .03, so: .35, rx: 5});
    g += T_(x + 6, y + 13, `PE (${px},${py})`, {fs: 9, fo: .55});
    g += T_(x + 8, y + 29, `X(${py},${px})`, {fs: 11, c: kc('x', px), w: 1}) + T_(x + 64, y + 29, `W(${IND[py][px]},${px})`, {fs: 11, c: kc('w', IND[py][px]), w: 1});
    g += T_(x + 8, y + 49, `C(${py},${px})`, {fs: 11, c: 'var(--c)'});
  }
  $('mapfig').innerHTML = g;
  $('mapcap').innerHTML = `Rule (host code): PE (px, py) receives X block (py, px) and W block (ind[py][px], px), and owns C block (py, px) for the whole run. Row py of the mesh holds row-block py of X; column px holds column-block px of W. Shade = k-block, the index that has to match for a product: X(py, k) · W(k, px). At load time the blocks don't match yet. The host pre-permutes W's blocks (ind); the on-wafer skew then rotates X so that they do.`;
})();

/* 2 · a tile becomes wavelets */
(function(){
  let g = '';
  g += T_(20, 22, 'one 16×16 tile = 256 f16 values = 512 bytes', {fs: 12, w: 1});
  for (let i = 0; i < 8; i++) for (let j = 0; j < 8; j++) g += R_(20 + j * 13, 34 + i * 13, 12, 12, 'var(--x)', {fo: .12 + .6 * ((i * 8 + j) % 7) / 7, so: .3, rx: 1});
  g += T_(20, 150, '(8×8 of the 16×16 shown)', {fs: 9, fo: .6});
  const wav = (x, y, hi, lo, c, cap) => {
    g += R_(x, y, 54, 26, c, {fo: .06}) + R_(x + 54, y, 70, 26, c, {fo: .06}) + R_(x + 124, y, 70, 26, c, {fo: .2});
    g += T_(x + 27, y + 17, 'colour', {a: 'middle', fs: 9}) + T_(x + 89, y + 17, hi, {a: 'middle', fs: 10}) + T_(x + 159, y + 17, lo, {a: 'middle', fs: 10, w: 1});
    cap.forEach((c, i) => g += T_(x, y + 42 + i * 14, c, {fs: 10, fo: .8}));
  };
  g += T_(180, 50, 'host → PE (memcpy, 16-bit mode): 256 wavelets on colour 23', {fs: 11, w: 1, c: 'var(--io)'});
  wav(180, 62, '0x0000', 'value', 'var(--io)', ['5-bit tag · high 16 bits zero · low 16 bits one f16;', 'the SDK requires this zero-extension: 256 wavelets per tile']);
  g += T_(180, 150, 'PE → PE (kernel @mov16): 128 wavelets, transfer\'s colour', {fs: 11, w: 1, c: 'var(--x)'});
  wav(180, 162, 'value 2i+1', 'value 2i', 'var(--x)', ['index half = the next element, data half = this one:', 'two f16 per wavelet, in memory order']);
  g += T_(700, 50, 'verified in the trace', {fs: 11, w: 1});
  [['memcpy X, W per PE', '256 + 256 wavelets, 1 value each'], ['skew and step transfers', '128 wavelets each, 2 values'], ['payload order', 'data = element 2i, index = 2i+1'],
   ['C back to host (colour 21)', '256 values + 256 control']].forEach(([a, b], i) => g += T_(700, 74 + i * 30, a, {fs: 10, fo: .7}) + T_(700, 88 + i * 30, b, {fs: 11}));
  $('wavefig').innerHTML = g;
})();

/* 3 · the three-colour rule along a row, and the colour table */
(function(){
  const plan = CO.plan, py = 1;
  let g = T_(20, 22, `X colours along row ${py}, from comm_layout.csl get_params(px, py): each PE's send, receive and transit colour`, {fs: 12, w: 1});
  for (let px = 0; px < 4; px++){
    const x = 60 + px * 240, p = plan[`${px},${py}`].x;
    g += R_(x, 40, 150, 92, 'currentColor', {fo: .03, so: .4, rx: 6}) + T_(x + 8, 56, `PE (${px},${py})`, {fs: 10, fo: .6});
    [['send', p.send], ['receive', p.recv], ['transit', px === 0 || px === 3 ? null : p.tran]].forEach(([k, c], i) =>
      g += T_(x + 12, 78 + i * 18, `${k.padEnd(8, ' ')} ${c === null ? '—' : 'c' + c}`, {fs: 11, c: c === null ? 'currentColor' : kc('x', X_IDS.indexOf(c)), fo: c === null ? .4 : 1}));
  }
  const arc = (a, b, c, lvl, lab) => {
    const x1 = 135 + a * 240, x2 = 135 + b * 240, y = 150 + lvl * 26, col = kc('x', X_IDS.indexOf(c));
    g += `<path d="M${x1},132 L${x1},${y} L${x2},${y} L${x2},132" fill="none" stroke="${col}" stroke-width="2"/>` +
      `<path d="M${x2},132 l-4,8 h8 z" fill="${col}"/>` + T_((x1 + x2) / 2, y - 4, lab, {a: 'middle', fs: 10, c: col});
  };
  arc(0, 2, 2, 2, 'c2 · 0 → 2, forwarded by (1) on its transit colour'); arc(2, 3, 1, 0, 'c1 · 2 → 3'); arc(3, 1, 3, 3, 'c3 · 3 → 1, forwarded by (2)'); arc(1, 0, 1, 1, 'c1 · 1 → 0');
  $('rulefig').innerHTML = g;
  $('rulecap').innerHTML = `Why several colours: a router routes by colour alone, so one colour can have only one route through a given router. PE (1,${py}) must forward 0→2 traffic (rx WEST → tx EAST), send its own tile west (rx RAMP → tx WEST) and receive from 3 (rx EAST → tx RAMP). That takes three different colours, and the interleave by px % 3 guarantees no router ever needs two routes on one colour. The ported rule predicts the colour of every traced transfer: <b>${CO.plan_check[0]} / ${CO.plan_check[1]}</b> paths.`;
  const cen = CO.census, rows = [
    [1, 'X step, 1 hop', 'E and W', 'OQ2 → IQ2', 'kernel'], [2, 'X step, 2 hops', 'E', 'OQ2 → IQ2', 'kernel'], [3, 'X step, 2 hops', 'W', 'OQ2 → IQ2', 'kernel'],
    [4, 'W step, 1 hop', 'S and N', 'OQ5 → IQ5', 'kernel'], [5, 'W step, 2 hops', 'S', 'OQ5 → IQ5', 'kernel'], [6, 'W step, 2 hops', 'N', 'OQ5 → IQ5', 'kernel'],
    [7, 'X skew backward, 1 hop', 'E and W', 'OQ4 → IQ4', 'kernel'], [8, 'X skew backward, 2 hops', 'W', 'OQ4 → IQ4', 'kernel'], [9, 'X skew backward, 2 hops', 'E', 'OQ4 → IQ4', 'kernel'],
    [12, 'X skew forward, 1 hop', 'E and W', 'OQ3 → IQ3', 'kernel'], [13, 'X skew forward, 2 hops', 'E', 'OQ3 → IQ3', 'kernel'], [16, 'X skew forward, 2 hops', 'W', 'OQ3 → IQ3', 'kernel'],
    [23, 'memcpy host → device', 'west edge in, east along rows', 'IQ0/1 (memcpy)', 'memcpy'], [21, 'memcpy device → host', 'east, out at (10,4)', 'OQ0 (memcpy)', 'memcpy'],
    [22, 'memcpy commands', '—', 'memcpy', 'memcpy']];
  const rp = c => { const r = cen[c] && cen[c].routers_per_packet; return r ? Object.entries(r).map(([k, v]) => `${k}: ${cnt(v)}`).join(' · ') : '—'; };
  $('coltab').innerHTML = `<tr><th>colour</th><th>carries</th><th>direction</th><th>queues</th><th>packets, 7 repeats</th><th>routers seen per packet</th><th>cores it lands in</th></tr>` +
    rows.map(([c, what, dir, q, who]) => `<tr><td style="color:${c < 4 ? kc('x', c - 1) : c < 7 ? kc('w', c - 4) : 'inherit'}">c${c}</td><td>${what}</td><td>${dir}</td><td>${q}</td>
      <td>${cen[c] ? cnt(cen[c].packets) : '—'}${cen[c] && !cen[c].kernel_only && who === 'kernel' ? '*' : ''}</td><td>${rp(c)}</td><td>${who === 'kernel' ? '1 (the receiver)' : c === 23 ? '1 (the PE whose slot it is)' : c === 21 ? 'the host' : 'memcpy code on the PEs'}</td></tr>`).join('') +
    `<tr><td colspan="7" class="mini">* Colours 0–3 and 5 are also used by memcpy inside the support columns (x = 1–3 and 8–9), which the kernel never touches. The count includes that traffic. A colour is only a router setting, so the same ID can carry unrelated traffic in regions that don't meet. Routers seen per packet: 2 = one hop (sender and receiver), 3 = two hops through one transit router, which forwards and does not deliver.</td></tr>`;
})();

/* 4 · fan-out */
$('fantab').innerHTML = `<tr><th>what moves</th><th>in space (one packet)</th><th>in time (one tile over the run)</th><th>evidence</th></tr>
  <tr><td>X, W step transfers</td><td><b>one-to-one</b>: sender → the one ring successor; a 2-hop packet passes a transit router that never delivers it</td><td><b>one-to-many</b> by relay: each X block visits all 4 PEs of its row, each W block all 4 PEs of its column, once each</td><td>2 or 3 routers per packet; transit route rx → tx, no RAMP; schedule verified 16/16 blocks</td></tr>
  <tr><td>X skew</td><td><b>one-to-one</b></td><td>2 transfers per PE; rows keep 0, 1, 1 and 2 rotations</td><td>trace, 7/7 repeats</td></tr>
  <tr><td>host → PEs (memcpy)</td><td>one stream per row passes all 4 kernel PEs; each value lands in <b>one</b> PE (PE px keeps packets px, px+4, …)</td><td>once</td><td>16/16 X and 16/16 W tiles as kept</td></tr>
  <tr><td>compute, per step</td><td><b>one-to-one</b>: a PE multiplies only its own X and W tiles into its own C</td><td>C(py,px) never moves until the host reads it (output-stationary)</td><td>262,144 FMA results bit-exact</td></tr>
  <tr><td>inside one FMACH</td><td><b>one-to-many</b>: one W value (src2) is broadcast to all 16 lanes of an X column</td><td>—</td><td>FMACH operands, trace</td></tr>
  <tr><td>MeshGEMV result broadcast</td><td><b>one-to-many</b>: one packet, 4 routers, delivered to 3 cores (multicast)</td><td>—</td><td>colour 9: 4 routers per packet</td></tr>
  <tr><td>Hot Chips weights</td><td><b>one-to-many</b>: multicast down a column</td><td>used once, not stored</td><td>documented</td></tr>`;

/* 5 · the toy */
let toyF = 1, toyPE = [1, 2];
function toyDraw(){
  const F = TOY.frames[toyF], X = TOY.X, W = TOY.W;
  let g = '';
  for (let py = 0; py < 4; py++) for (let px = 0; px < 4; px++){
    const e = F.pes[`${px},${py}`], x = 10 + px * 172, y = 10 + py * 136, sel = toyPE[0] === px && toyPE[1] === py;
    const k = e.x[1];
    g += `<g class="toype" data-pe="${px}:${py}" tabindex="0" role="button" aria-label="PE ${px},${py}">` + R_(x, y, 164, 128, sel ? 'var(--ink)' : 'currentColor', {fo: .03, so: sel ? 1 : .35, sw: sel ? 2.4 : 1, rx: 6});
    g += T_(x + 8, y + 16, `PE (${px},${py})`, {fs: 10, fo: .6});
    g += T_(x + 10, y + 40, `X[${e.x[0]}][${k}] = ${X[e.x[0]][k]}`, {fs: 13, c: kc('x', k), w: 1});
    g += T_(x + 10, y + 62, `W[${e.w[0]}][${e.w[1]}] = ${W[e.w[0]][e.w[1]]}`, {fs: 13, c: kc('w', e.w[0]), w: 1});
    if (toyF > 0) g += T_(x + 10, y + 84, `+ ${X[e.x[0]][k]}·${W[e.w[0]][e.w[1]]} = ${e.term}`, {fs: 12, fo: .75});
    g += T_(x + 10, y + 108, `C[${py}][${px}] = ${e.c}`, {fs: 13, c: 'var(--c)', w: 1});
    if (toyF > 0 && toyF < 4) g += T_(x + 156, y + 120, `X→${SEND[px]},${py}  W→${px},${SEND[py]}`, {fs: 8.5, a: 'end', fo: .55});
    g += `</g>`;
  }
  $('toyfig').innerHTML = g;
  $('toyfig').querySelectorAll('.toype').forEach(el => el.onclick = () => { toyPE = el.dataset.pe.split(':').map(Number); toyDraw(); });
  $('toytabs').querySelectorAll('button').forEach((b, i) => b.setAttribute('aria-pressed', String(i === toyF)));
  const [px, py] = toyPE, terms = [1, 2, 3, 4].map(s => TOY.frames[s].pes[`${px},${py}`]);
  const m = (M, t, hl) => `<table class="grid g-${t}"><tr><th class="corner"></th>${[0, 1, 2, 3].map(j => `<th>${j}</th>`).join('')}</tr>` +
    M.map((r, i) => `<tr><th>${i}</th>${r.map((v, j) => `<td class="${hl(i, j) ? 'hl' : ''}">${v}</td>`).join('')}</tr>`).join('') + `</table>`;
  const cur = TOY.frames[toyF].pes[`${px},${py}`];
  $('toyside').innerHTML = `<p class="eyebrow">${toyF === 0 ? 'as loaded' : 'step ' + toyF + ' of 4'} · PE (${px},${py}) owns C[${py}][${px}]</p>
    <div style="display:flex;gap:14px;flex-wrap:wrap">
      <div><p class="mini">X</p>${m(TOY.X, 'x', (i, j) => i === cur.x[0] && j === cur.x[1])}</div>
      <div><p class="mini">W</p>${m(TOY.W, 'w', (i, j) => i === cur.w[0] && j === cur.w[1])}</div>
      <div><p class="mini">C = X·W</p>${m(TOY.C, 'c', (i, j) => i === py && j === px)}</div></div>
    <p class="eyebrow" style="margin-top:12px">Hand check: the four terms PE (${px},${py}) adds</p>
    <table class="chain"><tr><th>step</th><th>k</th><th>X[${py}][k]</th><th>W[k][${px}]</th><th>term</th><th>C so far</th></tr>
    ${terms.map((e, s) => `<tr><td>${s + 1}</td><td>${e.x[1]}</td><td class="cx">${TOY.X[py][e.x[1]]}</td><td class="cw">${TOY.W[e.x[1]][px]}</td><td>${e.term}</td><td class="cc">${e.c}</td></tr>`).join('')}</table>
    <p class="ok">k runs over ${terms.map(e => e.x[1]).join(', ')}: each of 0–3 exactly once, so C[${py}][${px}] = Σ<sub>k</sub> X[${py}][k]·W[k][${px}] = ${TOY.C[py][px]}.</p>
    <p class="mini">The order of k differs from PE to PE; that is the whole point of the skew. Addition is exact here (integers), so order doesn't matter. In f16 it does, and the full-size run reproduces the traced rounding bit for bit.</p>`;
}
$('toytabs').innerHTML = ['as loaded', 'step 1', 'step 2', 'step 3', 'step 4'].map((l, i) => `<button>${l}</button>`).join('');
$('toytabs').querySelectorAll('button').forEach((b, i) => b.onclick = () => { toyF = i; toyDraw(); });
toyDraw();
}
