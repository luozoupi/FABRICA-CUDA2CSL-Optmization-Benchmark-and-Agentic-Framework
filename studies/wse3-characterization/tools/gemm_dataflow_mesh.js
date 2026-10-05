/* ======================= across the mesh, host to host ======================= */
/* Data (all from verified runs): D.gv MeshGEMM tiles, D.gl its lifecycle checks,
   D.vv MeshGEMV values, D.vl its lifecycle checks, D.snip verbatim source snippets. */
const T = 16;
const mc = k => k === 'io' ? 'var(--io)' : `var(--${k})`;
const f16 = h => { const s = (h >> 15) & 1, e = (h >> 10) & 31, m = h & 1023;
  const v = e === 0 ? m * 2 ** -24 : e === 31 ? (m ? NaN : Infinity) : (1 + m / 1024) * 2 ** (e - 15);
  return s ? -v : v; };
function toF16(x){                              /* round to nearest, ties to even */
  if (Number.isNaN(x)) return 0x7E00;
  let s = 0; if (x < 0 || Object.is(x, -0)) { s = 0x8000; x = -x; }
  if (x === 0) return s;
  let e = Math.floor(Math.log2(x));
  if (2 ** e > x) e--; if (2 ** (e + 1) <= x) e++;
  if (e < -14) e = -14;
  const q = 2 ** (e - 10); let r = Math.floor(x / q); const f = x / q - r;
  if (f > 0.5 || (f === 0.5 && (r & 1))) r++;
  if (r >= 2048) { r /= 2; e++; }
  if (e > 15) return s | 0x7C00;
  return r < 1024 ? (s | r) : (s | ((e + 15) << 10) | (r - 1024));
}
const fv = h => { const v = f16(h); return Math.abs(v) >= 100 ? v.toFixed(2) : v.toFixed(4); };
const hex = h => '0x' + h.toString(16).padStart(4, '0');
/* shade by k-block: k = 0 is the pure colour, each later block is darker; a moving tile keeps its shade */
const sh = (t, k) => k === undefined || k === null ? mc(t) : `color-mix(in srgb, var(--${t}) ${100 - k * 18}%, var(--ink))`;
const cnt = n => Number(n).toLocaleString('en-US');
const ok = p => `${cnt(p[0])} / ${cnt(p[1])}`;

/* ---------- kernel view: each PE = router (ports) + ramp (hardware queues) + core (SRAM buffers) ----------
   A packet leaves a buffer through an output queue (OQ), goes up the ramp into its own router, is switched
   out of one port, crosses exactly one link per hop into the neighbour's matching port, and at the last
   router is switched down the ramp through an input queue (IQ) into a buffer. Inside a router each line is
   one route, rx port -> tx port, exactly as @set_color_config states it. Row links run along the top band
   of the PEs (eastbound above westbound); column links run down the left band (southbound left of
   northbound). The ramp is one physical link; its lanes only separate the colours for legibility. */
const KV = {W: 1020, H: 930, CW: 225, CH: 206, G: 20, X0: 30, Y0: 40};
const cX = px => KV.X0 + px * (KV.CW + KV.G), cY = py => KV.Y0 + py * (KV.CH + KV.G);
const RB = {x: 6, y: 6, w: 70, h: 42};
const PORT = {E_out: [76, 17], W_in: [6, 17], W_out: [6, 35], E_in: [76, 35], S_out: [16, 48], N_in: [16, 6], N_out: [30, 6], S_in: [30, 48]};
const OUT = {E: 'E_out', W: 'W_out', S: 'S_out', N: 'N_out'}, IN = {E: 'W_in', W: 'E_in', S: 'N_in', N: 'S_in'};
const RAMP_UP = {x: 42, w: 48, c: 42}, RAMP_DN = {x: 56, w: 62, c: 56};      /* lanes of the one ramp, by tensor */
const QX = 68, QW = 18, CHIP = {x: 90, w: 124, h: 24, gap: 5, y0: 60};
const ROWS = {gemm: ['X_0', 'X_1', 'W_0', 'W_1', 'res'], gemv: ['W', 'x', 'y'], hc: ['act', 'acc']};
const TOF = {X_0: 'x', X_1: 'x', W_0: 'w', W_1: 'w', res: 'c', W: 'w', x: 'x', y: 'c', act: 'x', acc: 'c'};
const rowIdx = (b) => ROWS[scheme].indexOf(b);
const rowY = (py, b) => cY(py) + CHIP.y0 + rowIdx(b) * (CHIP.h + CHIP.gap);
const P2 = (px, py, p) => [cX(px) + PORT[p][0], cY(py) + PORT[p][1]];
const dirOf = (a, b) => b[0] > a[0] ? 'E' : b[0] < a[0] ? 'W' : b[1] > a[1] ? 'S' : 'N';
const kOf = lab => { const m = /^([XW])\((\d),(\d)\)/.exec(lab || ''); return !m ? undefined : m[1] === 'X' ? +m[3] : +m[2]; };
const poly = (p, c, w, extra) => `<path d="M${p.map(q => q.map(v => v.toFixed(1)).join(',')).join(' L')}" fill="none"
  stroke="${c}" stroke-width="${w || 1.8}" stroke-linejoin="round" stroke-linecap="round" ${extra || ''}/>`;
const halo = (p, w) => poly(p, 'var(--pan2)', (w || 1.8) + 4);        /* a gap where a line crosses another */
const head = (x, y, c, dir, s = 6) => {
  const h = s * .6, d = {r: [[-s, -h], [-s, h]], l: [[s, -h], [s, h]], d: [[-h, -s], [h, -s]], u: [[-h, s], [h, s]]}[dir];
  return `<path d="M${x + d[0][0]},${y + d[0][1]} L${x},${y} L${x + d[1][0]},${y + d[1][1]} z" fill="${c}"/>`;
};
const hdir = (a, b) => b[0] > a[0] ? 'r' : b[0] < a[0] ? 'l' : b[1] > a[1] ? 'd' : 'u';
const txt = (x, y, s, o = {}) => `<text x="${x}" y="${y}" font-size="${o.fs || 9}" ${o.a ? `text-anchor="${o.a}"` : ''} fill="${o.c || 'currentColor'}"
  ${o.fo ? `fill-opacity="${o.fo}"` : ''} ${o.w ? 'font-weight="600"' : ''} font-family="IBM Plex Mono,monospace" ${o.rot ? `transform="rotate(${o.rot} ${x} ${y})"` : ''}
  ${o.halo ? 'paint-order="stroke" stroke="var(--pan2)" stroke-width="3"' : ''}>${s}</text>`;

/* one transfer, port by port; `marks` collects router states, `layers` keeps draw order */
function drawTransfer(m, L){
  const c = sh(m.t, m.k), path = m.path, n = path.length - 1;
  const [ax, ay] = path[0];
  const tapY = (px, py, b, out) => rowY(py, b) + CHIP.h / 2 + (out ? -4 : 4);
  /* leave the source buffer: tap with its output queue, then up the ramp */
  if (!m.top){
    const y = tapY(ax, ay, m.from, true), ux = cX(ax) + RAMP_UP[m.t], top = cY(ay) + RB.y + RB.h;
    L.taps += halo([[cX(ax) + CHIP.x, y], [ux, y]]) + poly([[cX(ax) + CHIP.x, y], [ux, y], [ux, top]], c);
    L.taps += `<circle cx="${cX(ax) + CHIP.x}" cy="${y}" r="2.4" fill="${c}"/>` + head(ux, top, c, 'u');
    L.q += qbox(cX(ax) + QX, y, m.q[0], c);
    L.route += poly([[ux, top], P2(ax, ay, OUT[dirOf(path[0], path[1])])], c, 1.5);
    L.marks[`${ax},${ay}`] = L.marks[`${ax},${ay}`] || 'end';
  } else {                                      /* enters the mesh from off-wafer, through the top edge */
    const [nx, ny] = P2(ax, ay, 'N_in');
    L.links += poly([[nx, ny - 30], [nx, ny]], c, 2.4) + head(nx, ny, c, 'd');
  }
  /* every hop: one link, from the out-port to the neighbour's in-port */
  for (let i = 0; i < n; i++){
    const a = path[i], b = path[i + 1], d = dirOf(a, b);
    const A = P2(a[0], a[1], OUT[d]), B = P2(b[0], b[1], IN[d]);
    L.links += poly([A, B], c, 2.4) + head(B[0], B[1], c, hdir(A, B));
    const mx = (A[0] + B[0]) / 2, my = (A[1] + B[1]) / 2;
    const lab = m.colour === '?' ? `hop ${i + 1}/${n}` : `c${m.colour} · ${i + 1}/${n}`;
    L.labels += d === 'E' ? txt(mx, my - 4, lab, {a: 'middle', c, halo: 1}) : d === 'W' ? txt(mx, my - 4, lab, {a: 'middle', c, halo: 1})
      : txt(mx - 5, my, lab, {a: 'middle', c, rot: -90, halo: 1});
    if (i + 1 < n || m.mult){                   /* through the next router: straight on */
      if (i + 1 < n){
        L.route += poly([B, P2(b[0], b[1], OUT[dirOf(b, path[i + 2])])], c, 1.5);
        if (!m.mult) L.marks[`${b[0]},${b[1]}`] = L.marks[`${b[0]},${b[1]}`] || 'transit';
      }
    }
    if (m.mult || i + 1 === n) deliver(b, B);    /* multicast: every router it reaches also delivers */
  }
  if (m.top && m.mult) deliver(path[0], P2(ax, ay, 'N_in'));
  function deliver(b, B){
    const [bx, by] = b, dx = cX(bx) + RAMP_DN[m.t], top = cY(by) + RB.y + RB.h, y = tapY(bx, by, m.to, false);
    L.route += poly([B, [dx, top]], c, 1.5);
    L.taps += poly([[dx, top], [dx, y], [cX(bx) + CHIP.x, y]], c) + head(cX(bx) + CHIP.x, y, c, 'r');
    L.q += qbox(cX(bx) + QX, y, m.q[1], c);
    L.marks[`${bx},${by}`] = m.mult ? 'drop' : 'end';
  }
}
function qbox(x, y, s, c){
  if (!s) return '';
  const w = QW;
  return `<rect x="${x}" y="${y - 6}" width="${w}" height="12" rx="2" fill="var(--pan)" stroke="${c}" stroke-width="1"/>` +
    txt(x + w / 2, y + 3, s, {a: 'middle', fs: 7.5, c});
}
const ROLE = {send: '↑ out', recv: '↓ in', fma: 'FMA', next: 'next', acc: '+=', write: '= 0', add: '+= in',
  loaded: 'host', held: '', idle: '', stationary: '', fmac: '+='};
function kernelView(f){
  const L = {marks: {}, taps: '', q: '', route: '', links: '', labels: ''};
  const sel = detailSel && detailSel.kind === 'buf' ? detailSel : null;
  const touches = m => sel && ((m.a[0] === sel.px && m.a[1] === sel.py && m.from === sel.name) ||
    (m.path.some(p => p[0] === sel.px && p[1] === sel.py) && m.to === sel.name) || (sel.name === 'res' && m.b[0] === sel.px && m.b[1] === sel.py));
  const hit = sel && f.moves.some(touches);
  const faint = {taps: '', q: '', route: '', links: '', labels: '', marks: {}};
  const shownMoves = f.moves.filter(m => tf === 'both' || m.t === tf || m.t === 'c');
  shownMoves.forEach(m => drawTransfer(m, hit && !touches(m) ? faint : L));
  let g = '';
  for (let py = 0; py < P; py++) for (let px = 0; px < P; px++){
    const x = cX(px), y = cY(py);
    g += `<rect x="${x}" y="${y}" width="${KV.CW}" height="${KV.CH}" rx="7" fill="var(--pan2)" stroke="currentColor" stroke-opacity=".32"/>`;
    /* idle fabric: the links this router has to its east and south neighbours */
    if (px < P - 1) g += `<line x1="${x + 76}" y1="${y + 26}" x2="${cX(px + 1) + 6}" y2="${y + 26}" stroke="currentColor" stroke-opacity=".12" stroke-width="22"/>`;
    if (py < P - 1) g += `<line x1="${x + 23}" y1="${y + 48}" x2="${x + 23}" y2="${cY(py + 1) + 6}" stroke="currentColor" stroke-opacity=".12" stroke-width="18"/>`;
    g += `<rect x="${x + 36}" y="${y + 48}" width="32" height="${KV.CH - 54}" fill="currentColor" fill-opacity=".05"/>`;
    g += `<rect x="${x + 84}" y="${y + CHIP.y0 - 14}" width="${KV.CW - 88}" height="${KV.CH - CHIP.y0 + 10}" rx="4" fill="var(--pan)" stroke="currentColor" stroke-opacity=".2"/>`;
    g += txt(x + KV.CW - 8, y + CHIP.y0 - 4, `PE (${px},${py}) · SRAM`, {a: 'end', fs: 9, fo: .55});
    const bufs = f.bufs(px, py);
    ROWS[scheme].forEach(b => {
      const e = bufs[b]; if (!e) return;
      const t = TOF[b], k = kOf(e.label), col = sh(t, k), ry = rowY(py, b), role = e.role || '';
      const dim = role === 'idle' || e.label === 'zeros';
      const isSel = sel && sel.name === b && sel.px === px && sel.py === py;
      g += `<g class="chip" data-buf="${b}:${px}:${py}" tabindex="0" role="button" aria-label="Open ${b} at PE (${px},${py}): ${e.label}">`;
      if (isSel) g += `<rect x="${x + CHIP.x - 3}" y="${ry - 3}" width="${CHIP.w + 6}" height="${CHIP.h + 6}" rx="5" fill="none" stroke="var(--ink)" stroke-width="2.4"/>`;
      g += `<rect x="${x + CHIP.x}" y="${ry}" width="${CHIP.w}" height="${CHIP.h}" rx="3" fill="${col}" fill-opacity="${dim ? .04 : role === 'fma' || role === 'acc' || role === 'add' ? .34 : .16}"
        stroke="${col}" stroke-opacity="${dim ? .35 : 1}" stroke-width="${role === 'recv' || role === 'fma' || role === 'add' ? 2 : 1}" ${role === 'send' ? 'stroke-dasharray="4 2"' : ''}/>`;
      g += txt(x + CHIP.x + 5, ry + 15.5, b.replace('_', '<tspan font-size="7" dy="2">') + (b.includes('_') ? '</tspan>' : ''), {fs: 9.5, c: col, fo: dim ? .5 : .75});
      g += txt(x + CHIP.x + 34, ry + 16, e.label, {fs: 11, c: col, w: !dim, fo: dim ? .55 : 1});
      if (ROLE[role]) g += txt(x + CHIP.x + CHIP.w - 5, ry + 15.5, ROLE[role], {a: 'end', fs: 8, c: col, fo: .9});
      g += `</g>`;
    });
  }
  /* routers: box, then the routes switched through it in this phase */
  let rt = '';
  for (let py = 0; py < P; py++) for (let px = 0; px < P; px++){
    const st = L.marks[`${px},${py}`], x = cX(px) + RB.x, y = cY(py) + RB.y;
    rt += `<rect class="rtr" data-rtr="${px}:${py}" x="${x}" y="${y}" width="${RB.w}" height="${RB.h}" rx="4" fill="var(--pan)"
      stroke="${st ? 'var(--ink)' : 'currentColor'}" stroke-opacity="${st ? .8 : .4}" stroke-width="${st === 'end' ? 1.8 : 1.2}" ${st === 'transit' ? 'stroke-dasharray="4 2.5"' : ''}/>`;
    if (!st) rt += txt(x + RB.w / 2, y + 25, 'router', {a: 'middle', fs: 9, fo: .45});
    if (st === 'transit') rt += txt(x + RB.w - 3, y + RB.h - 3, 'transit', {a: 'end', fs: 7.5, fo: .7});
  }
  if (f.moves.some(m => m.top)) g += txt(KV.X0, 12, 'weights arrive from MemoryX, off-wafer, into the north port of each top-row router', {fs: 11, c: 'var(--w)'});
  const fl = hit ? `<g opacity=".14">${faint.links + faint.route + faint.taps + faint.q}</g>` : '';
  return g + rt + fl + L.taps + L.route + L.links + L.q + L.labels;
}

/* ---------- wafer view: the whole 11 x 6 fabric, memcpy support columns, both I/O ports ----------
   Same convention: each PE's router is in its top-left corner; paths join router centres. */
const WV = {W: 1020, H: 600, c: 66, g: 14, X0: 76, Y0: 50};
const wX = x => WV.X0 + x * (WV.c + WV.g), wY = y => WV.Y0 + y * (WV.c + WV.g);
const WR = (x, y) => [wX(x) + 13, wY(y) + 13];
const region = (x, y) => (x >= 4 && x <= 7 && y >= 1 && y <= 4) ? 'K' : (x === 0 || x === 10 || y === 0 || y === 5) ? 'H' : x < 4 ? 'W' : 'E';
const PORT_W = [WV.X0 - 14, WR(0, 1)[1]], PORT_E = [wX(10) + WV.c + 14, WR(10, 4)[1]];
function waferView(f){
  let g = '';
  const rl = [['halo', 0, 0], ['memcpy support, 3 west', 1, 3], ['kernel 4 × 4', 4, 7], ['support, 2 east', 8, 9], ['halo', 10, 10]];
  rl.forEach(([t, a, b]) => g += `<text x="${(wX(a) + wX(b) + WV.c) / 2}" y="18" text-anchor="middle" font-size="11.5" fill="currentColor" fill-opacity=".6" font-family="IBM Plex Mono,monospace">${t}</text>`
    + `<line x1="${wX(a) + 2}" y1="26" x2="${wX(b) + WV.c - 2}" y2="26" stroke="currentColor" stroke-opacity=".25"/>`);
  for (let y = 0; y < 6; y++) for (let x = 0; x < 11; x++){        /* idle fabric links */
    const [rx, ry] = WR(x, y);
    if (x < 10) g += `<line x1="${rx}" y1="${ry}" x2="${WR(x + 1, y)[0]}" y2="${ry}" stroke="currentColor" stroke-opacity=".12" stroke-width="3"/>`;
    if (y < 5) g += `<line x1="${rx}" y1="${ry}" x2="${rx}" y2="${WR(x, y + 1)[1]}" stroke="currentColor" stroke-opacity=".12" stroke-width="3"/>`;
  }
  for (let y = 0; y < 6; y++) for (let x = 0; x < 11; x++){
    const r = region(x, y), X = wX(x), Y = wY(y);
    g += `<rect x="${X}" y="${Y}" width="${WV.c}" height="${WV.c}" rx="5" fill="${r === 'K' ? 'var(--pan)' : r === 'H' ? 'var(--bg)' : 'var(--pan2)'}"
      fill-opacity="${r === 'H' ? .6 : 1}" stroke="currentColor" stroke-opacity="${r === 'K' ? .5 : .25}" ${r === 'H' ? 'stroke-dasharray="3 3"' : ''}/>`;
    g += `<rect x="${X + 5}" y="${Y + 5}" width="16" height="16" rx="3" fill="var(--pan)" stroke="currentColor" stroke-opacity=".45"/>`;
    g += `<text x="${X + WV.c - 4}" y="${Y + WV.c - 5}" font-size="8.5" text-anchor="end" fill="currentColor" fill-opacity=".45" font-family="IBM Plex Mono,monospace">${x},${y}</text>`;
    if (r === 'K'){
      const px = x - 4, py = y - 1, held = f.held(px, py);
      ['x', 'w', 'c'].forEach((t, i) => g += `<rect x="${X + 27}" y="${Y + 9 + i * 13}" width="${WV.c - 33}" height="9" rx="2"
        fill="${mc(t)}" fill-opacity="${held[t] ? .8 : .08}" stroke="${mc(t)}" stroke-opacity="${held[t] ? 1 : .3}"/>`);
    }
  }
  g += `<g font-family="IBM Plex Mono,monospace" font-size="11">
    <rect x="4" y="${PORT_W[1] - 20}" width="${PORT_W[0] - 4}" height="44" rx="4" fill="var(--pan)" stroke="var(--io)" stroke-width="1.5"/>
    <text x="${(PORT_W[0] + 4) / 2}" y="${PORT_W[1] - 3}" text-anchor="middle" fill="currentColor">west</text><text x="${(PORT_W[0] + 4) / 2}" y="${PORT_W[1] + 12}" text-anchor="middle" fill="currentColor">I/O</text>
    <text x="${(PORT_W[0] + 4) / 2}" y="${PORT_W[1] - 28}" text-anchor="middle" fill="currentColor" fill-opacity=".6">host</text>
    <rect x="${PORT_E[0]}" y="${PORT_E[1] - 20}" width="${WV.W - 4 - PORT_E[0]}" height="44" rx="4" fill="var(--pan)" stroke="var(--io)" stroke-width="1.5"/>
    <text x="${(PORT_E[0] + WV.W - 4) / 2}" y="${PORT_E[1] - 3}" text-anchor="middle" fill="currentColor">east</text><text x="${(PORT_E[0] + WV.W - 4) / 2}" y="${PORT_E[1] + 12}" text-anchor="middle" fill="currentColor">I/O</text>
    <text x="${(PORT_E[0] + WV.W - 4) / 2}" y="${PORT_E[1] + 40}" text-anchor="middle" fill="currentColor" fill-opacity=".6">host</text></g>`;
  const pt = q => q === 'W' ? PORT_W : q === 'E' ? PORT_E : WR(q[0], q[1]);
  (f.paths || []).slice().sort((a, b) => b.ghost - a.ghost).forEach(p => {
    const c = mc(p.t), pts = p.pts.map(pt);
    if (p.ghost){ g += poly(pts, c, 1.4, 'stroke-opacity=".35" stroke-dasharray="5 4"'); return; }
    g += poly(pts, c, p.w || 2.6);
    const L = pts[pts.length - 1], Q = pts[pts.length - 2];
    g += head(L[0], L[1], c, L[0] > Q[0] ? 'r' : L[0] < Q[0] ? 'l' : L[1] > Q[1] ? 'd' : 'u');
    (p.drops || []).forEach(([x, y]) => {                 /* router -> ramp -> this PE's core */
      const [rx, ry] = WR(x, y);
      g += `<circle cx="${rx}" cy="${ry}" r="4" fill="${c}"/>` + poly([[rx, ry], [rx, wY(y) + 32], [wX(x) + 25, wY(y) + 32]], c, 1.6) + head(wX(x) + 27, wY(y) + 32, c, 'r');
    });
    (p.from || []).forEach(([x, y]) => {                  /* this PE's core -> ramp -> router */
      const [rx, ry] = WR(x, y);
      g += poly([[wX(x) + 27, wY(y) + 40], [rx + 4, wY(y) + 40], [rx + 4, ry + 8]], c, 1.6) + head(rx + 4, ry + 8, c, 'u');
    });
    if (p.label){
      const [a, b] = p.labelAt ? [pts[p.labelAt[0]], pts[p.labelAt[1]]] : [pts[0], pts[1]];
      const lx = (a[0] + b[0]) / 2 + (p.dx || 0), ly = (a[1] + b[1]) / 2 + (p.dy || -9);
      g += `<text x="${lx}" y="${ly}" text-anchor="middle" font-size="11.5" fill="${c}" font-weight="600" font-family="IBM Plex Mono,monospace"
        paint-order="stroke" stroke="var(--pan)" stroke-width="4">${p.label}</text>`;
    }
  });
  for (let y = 0; y < 6; y++) for (let x = 0; x < 11; x++) if (region(x, y) === 'K')
    g += `<rect class="chip" data-pe="${x - 4}:${y - 1}" x="${wX(x)}" y="${wY(y)}" width="${WV.c}" height="${WV.c}" fill="transparent" tabindex="0" role="button" aria-label="Open PE (${x - 4},${y - 1})"/>`;
  return g;
}

/* ---------- host view: what happens before the host's I/O, and after it ---------- */
const HV = {W: 1020, H: 470, bx: 12, bw: 148, gap: 22, by: 74, bh: 136};
const EVT = {src: ['source', 'var(--x)'], doc: ['documented', 'var(--w)'], sim: ['trace', 'var(--c)'], none: ['not used here', 'var(--dim)'], inf: ['inferred', 'var(--dim)']};
function hostView(f){
  const S = HOST.stages, act = new Set(f.active || []);
  let g = '';
  const groups = [['outside the program', 0, 0], ['host program (Python, numpy, SDK runtime)', 1, 3], ['system and wafer', 4, 5]];
  groups.forEach(([t, a, b]) => { const x0 = HV.bx + a * (HV.bw + HV.gap), x1 = HV.bx + b * (HV.bw + HV.gap) + HV.bw;
    g += txt((x0 + x1) / 2, 30, t, {a: 'middle', fs: 11, fo: .6}) + `<line x1="${x0 + 2}" y1="38" x2="${x1 - 2}" y2="38" stroke="currentColor" stroke-opacity=".25"/>`; });
  S.forEach((s, i) => {
    const x = HV.bx + i * (HV.bw + HV.gap), on = act.has(s.id), [evl, evc] = EVT[s.ev];
    const stroke = on ? 'var(--io)' : 'currentColor';
    g += `<rect x="${x}" y="${HV.by}" width="${HV.bw}" height="${HV.bh}" rx="6" fill="${on ? 'color-mix(in srgb,var(--io) 10%,var(--pan))' : 'var(--pan)'}"
      stroke="${stroke}" stroke-opacity="${on ? 1 : .35}" stroke-width="${on ? 2 : 1}" ${s.ev === 'none' ? 'stroke-dasharray="5 4"' : ''}/>`;
    g += txt(x + 10, HV.by + 22, s.title, {fs: 13, w: 1, c: on ? 'var(--ink)' : 'currentColor', fo: on ? 1 : .7});
    s.lines.forEach((l, j) => g += txt(x + 10, HV.by + 44 + j * 15, l, {fs: 10, fo: on ? .9 : .55}));
    g += `<rect x="${x + 10}" y="${HV.by + HV.bh - 24}" width="${evl.length * 6 + 12}" height="15" rx="2" fill="none" stroke="${evc}" stroke-opacity=".8"/>` +
      txt(x + 16, HV.by + HV.bh - 13, evl.toUpperCase(), {fs: 8, c: evc});
    if (i < S.length - 1){
      const ax = x + HV.bw + 3, bx = x + HV.bw + HV.gap - 3, y = HV.by + HV.bh / 2, c = act.has(s.id) && act.has(S[i + 1].id) ? 'var(--io)' : 'currentColor';
      g += poly([[ax, y], [bx, y]], c, 2, `stroke-opacity="${c === 'currentColor' ? .35 : 1}"`) + head(bx, y, c, f.reverse ? 'l' : 'r');
      if (f.reverse) g += head(ax + 6, y, c, 'l');
    }
  });
  /* the data, as it looks at this stage */
  const F = f.formats || HOST.formats[f.id] || [];
  g += txt(HV.bx, 262, 'the data at this stage', {fs: 10, fo: .6});
  let x = HV.bx;
  F.forEach((q, i) => {
    const w = Math.max(150, Math.max(q.label.length * 7.2, (q.sub || '').length * 6) + 24);
    g += `<rect x="${x}" y="274" width="${w}" height="54" rx="4" fill="var(--pan)" stroke="var(--io)" stroke-opacity=".6"/>` +
      txt(x + 10, 296, q.label, {fs: 12, w: 1}) + txt(x + 10, 314, q.sub || '', {fs: 9.5, fo: .7});
    if (i < F.length - 1) g += poly([[x + w + 4, 301], [x + w + 22, 301]], 'var(--io)', 1.8) + head(x + w + 22, 301, 'var(--io)', 'r');
    x += w + 28;
  });
  (HOST.notes[f.id] || []).forEach((n, i) => g += txt(HV.bx, 360 + i * 17, n, {fs: 10.5, fo: .78}));
  return g;
}

/* ---------- phases ---------- */
const GL = D.gl.phases, VL = D.vl.phases, GX = D.gx;
const recv = D.send.map((_, p) => D.send.indexOf(p));
const kx = (px, py, s) => D.steps[s][`${px},${py}`].x[1];
const cyc = c => c ? `cycles ${cnt(c[0])}–${cnt(c[1])}` : '';
const phases = {gemm: [], gemv: [], hc: []};
const inputPaths = (keepLabel, leg) => [
  {t: 'io', pts: ['W', [0, 1], [1, 1]], label: keepLabel[0], labelAt: [1, 2], dy: -22},
  {t: 'io', pts: [[1, 1], [2, 1], [2, 2], [2, 3], [2, 4]], label: keepLabel[1], labelAt: [2, 3], dx: -52, dy: 4},
  ...[1, 2, 3, 4].map(y => ({t: 'io', pts: [[2, y], [3, y], [4, y], [5, y], [6, y], [7, y]], drops: [[4, y], [5, y], [6, y], [7, y]],
    label: y === 1 ? keepLabel[2] : '', labelAt: [3, 4], dy: -22}))].map((p, i) => ({...p, ghost: !!leg && (leg === 1) !== (i < 2)}));
const outputPaths = (lbl, t, leg) => [
  ...[1, 2, 3, 4].map(y => ({t, pts: [[4, y], [5, y], [6, y], [7, y], [8, y]], from: [[4, y], [5, y], [6, y], [7, y]], w: 2.2,
    label: y === 1 ? lbl[0] : '', labelAt: [2, 3], dy: -22})),
  {t, pts: [[8, 1], [8, 2], [8, 3], [8, 4], [9, 4], [10, 4], 'E'], label: lbl[1], labelAt: [4, 5], dy: 26, dx: 30}].map((p, i) => ({...p,
    ghost: !!leg && (leg === 1) !== (i < 4)}));
const constBufs = fn => (px, py) => fn(px, py);

/* host-side stages, before the host's I/O and after it (drawn by hostView) */
const HOST = D.host;
function hostPhase(id, title, active, text, checks, code, hl, extra = {}){
  return {id, view: 'host', ev: extra.ev || 'src', group: extra.group || 'host', title, active, text, checks, code, hl, ...extra};
}

/* MeshGEMM */
{
  const gi = GL.input, go = GL.output, gc = GL.compute, rv = GX.recv, lkx = GX.links;
  phases.gemm.push(hostPhase('h1', 'Where X and W come from', ['storage', 'ram'],
    `There is no storage stage in this benchmark. <code>make_inputs</code> generates X and W in host RAM with <code>np.random.rand(...).astype(np.float16)</code> (seed 2025): two ${HOST.M}×${HOST.K} f16 matrices, ${cnt(HOST.bytes_f16)} bytes each. No WaferLLM program reads a checkpoint, including the full decode layer, which also fills its weights with <code>np.random.rand</code>. In a production flow, data would be read from storage into host RAM first; that stage is drawn dashed.`,
    [['source of X and W', 'np.random, seed 2025'], ['storage reads in any WaferLLM launcher', '0']], ['gemm_inputs'], ['np\\.random', 'astype']));
  phases.gemm.push(hostPhase('h2', 'Host-side preparation', ['cpu'],
    `Before any byte moves, the host CPU reshapes both matrices for the mesh. W's row blocks are permuted by <code>ind</code>, so each PE's W tile already matches the k-block its X tile will have after the skew: W is pre-skewed on the host, X on the wafer. <code>tile_X</code> and <code>tile_W</code> reorder each matrix into 16 per-PE tiles of ${HOST.tile} values (X column-major inside its tile). Last, every f16 is widened into its own 32-bit word, low half = value: this is why each packet on the fabric later carries one value.`,
    [['words per matrix after packing', cnt(HOST.words_per_matrix)], ['values per 32-bit word', '1']], ['gemm_host_wofs', 'gemm_host_tile', 'gemm_host_load'], ['ind\\[', 'transpose', 'input_array_to_u32']));
  phases.gemm.push(hostPhase('h3', 'Runtime and transport to the wafer edge', ['runtime', 'transport', 'edge'],
    HOST.transport_text, HOST.transport_checks, ['gemm_host_load'], ['memcpy_h2d', 'SdkRuntime'], {ev: 'doc'}));
  phases.gemm.push({id: 'in1', view: 'wafer', ev: 'meas', group: 'host → wafer', title: 'West I/O port → memcpy support',
    text: `The host's two memcpy_h2d calls stream X then W through the one I/O channel this kernel was compiled with (<code>--channels 1</code>). Every word enters at the west halo PE (0,1), crosses to (1,1), and runs down support column x = 2, one value per 32-bit packet. ${cyc(gi.cycles)}.`,
    checks: [[`packets entering at halo (0,1)`, cnt(gi.entry_packets_at_west_halo_0_1) + ' (8,192 values + control)'], [`packets down support column x = 2`, cnt(gi.support_column_packets)]],
    code: ['gemm_host_load'], hl: ['memcpy_h2d'],
    held: () => ({x: 0, w: 0, c: 0}), paths: inputPaths([`${cnt(gi.entry_packets_at_west_halo_0_1)} packets`, `${cnt(gi.support_column_packets)}`, ''], 1)});
  phases.gemm.push({id: 'in2', view: 'wafer', ev: 'meas', group: 'host → wafer', title: 'Row streams fill X_0 and W_0',
    text: `At each row, support PE (2,y) turns the stream east into the kernel. The row stream passes every kernel PE in the row, and each keeps every fourth value: PE px keeps packets px, px+4, px+8, … That is ${cnt(gi.row_stream_values_per_row)} values per row: four X tiles, then four W tiles. They land in the symbols the host named, <code>X</code> and <code>W</code>, which point at <b>X_0</b> (0x1140) and <b>W_0</b> (0x1540).`,
    checks: [['X tile each PE keeps = the tile it later computes with', ok(gi.x_tiles_match)], ['W tile each PE keeps = the tile it later computes with', ok(gi.w_tiles_match)]],
    code: ['gemm_host_tile'], hl: ['transpose'],
    held: () => ({x: 1, w: 1, c: 0}), paths: inputPaths(['', '', `${cnt(gi.row_stream_values_per_row)} values per row, every 4th kept`], 2)});
  const SK = D.gk.phases;
  const skewText = [
    `The skew starts the compute, in every repeat. Each row rotates its X tiles around its ring (rows 1 and 3 forward on OQ3/IQ3, rows 0 and 2 backward on OQ4/IQ4) so every PE ends up holding the k-block its pre-skewed W tile expects. Transfer 1: every PE sends the tile the host loaded into X_0, and receives its neighbour's into X_1. Each transfer is 128 packets; the kernel's @mov16 packs two f16 into each 32-bit packet.`,
    `Transfer 2: row 0 sends its own tile again; rows 1–3 send the tile they just received, so they gain a second rotation. Which buffer ends up used is decided by pointer swaps, so the rows keep 0, 1, 1 and 2 rotations. The trace confirms it: after the skew, each PE's step-1 FMACH buffer holds exactly its step-1 tile on all 16 PEs.`];
  SK.forEach((p, i) => {
    const bufs = (px, py) => p.bufs[`${px},${py}`];
    const base = {view: 'kernel', ev: 'meas', group: 'compute', bufs, moves: p.moves, gk: p};
    if (p.id.startsWith('skew')) phases.gemm.push({...base, id: p.id, title: p.title,
      text: skewText[+p.id.slice(-1) - 1] + ` ${cyc(p.cycles)}.`,
      checks: p.id === 'skew1' ? [['transfer 1 carries the PE\'s own loaded tile', ok(GL.skew.first_transfer_own_tile)], ['sent from X_0 (host-loaded) on every PE', '16 / 16'], ['packets per transfer', '128']]
        : [['transfer 2 carries exactly the predicted tile', ok(GL.skew.second_transfer_predicted_tile)], ['step-1 FMACH buffer holds the step-1 tile', '16 / 16'], ['skew runs before the C clear and the first FMACH, every repeat', `${GX.rep.skew_first} / ${GX.rep.repeats}`]],
      code: ['gemm_skew', 'gemm_shift'], hl: ['x_shift_step', 'swap_ptr', 'left_matrix_shift', '@mov16']});
    else if (p.id === 'clear') phases.gemm.push({...base, id: 'clear', title: 'C cleared, then compute starts',
      text: `Right after the skew, one FMOV16 over 256 elements writes zeros into res_tile (0x1940): <code>@fmovh(res_dsd, 0.0)</code>. ${cyc(p.cycles)}. The first FMACH follows about 380 cycles later, after step 1's tiles have been passed on.`,
      checks: [['order on every PE, every repeat: skew → clear → first FMACH', `${GX.rep.skew_first} / ${GX.rep.repeats}`]],
      code: ['gemm_skew'], hl: ['@fmovh', 'ptr_W_send', 'mm_compute']});
    else if (p.id.startsWith('step')) phases.gemm.push({...base, id: p.id, title: p.title,
      text: `mm_compute swaps the pointers, then <code>two_hop_comm</code> starts four asynchronous @mov16s on micro-threads: X out of the buffer this step will multiply (OQ2) and the next X into the other buffer (IQ2), W likewise (OQ5 / IQ5). X goes to the row-ring successor, W to the column-ring successor. A 2-hop transfer goes straight through the middle router on its own colour (1 or 4 for 1 hop, 2/3 or 5/6 for 2 hops) and never reaches that PE's core. Each transfer is 128 packets and takes ${rv.transfer_cycles_min}–${rv.transfer_cycles_max} cycles. ${cyc(p.cycles)}.`,
      checks: [['transfers finished before this step\'s first FMACH', `${rv.transfer_done_before_fmach} / ${rv.windows}`], ['gap from last packet to first FMACH', `${rv.gap_min}–${rv.gap_max} cycles`],
               ['paths: straight runs between neighbouring routers', `${lkx.straight} / ${lkx.groups}`], ['each directed link carries one transfer', '72 / 72'],
               ['FMACH reads one buffer, the receive writes the other', `${GX.rep.read_ne_recv} / ${GX.rep.steps}`]],
      code: ['gemm_step', 'gemm_comm', 'gemm_routes'], hl: ['swap_ptr', 'two_hop_comm', '@mov16', 'tran_color', 'RAMP']});
    else phases.gemm.push({...base, id: p.id, title: p.title, step: p.step,
      text: `Now the core multiplies, with the fabric quiet on this PE: 256 FMACHs (16 per k), each reading a column of the X buffer as src1 and one W value as the broadcast scalar src2, accumulating into res_tile. The next tiles are already in the other buffers. No micro-thread moves run in this window, so communication and compute are serialised within the step. ${cyc(p.cycles)}.`,
      checks: [['FMA results recomputed bit for bit (whole run)', ok(gc.fma_bit_exact)], ['all 16 k of a step read one buffer', `${GX.rep.single_buf} / ${GX.rep.steps}`],
               ['the buffer just filled is the one multiplied next', `${GX.rep.alternates} / ${GX.rep.pairs}`], ['micro-thread moves during the FMACHs', '0']],
      code: ['gemm_step', 'gemm_fma'], hl: ['@fmach', '@map', 'for \\(@range']});
  });
  phases.gemm.push({id: 'out1', view: 'wafer', ev: 'meas', group: 'wafer → host', title: 'C streams east out of the kernel',
    text: `The host's memcpy_d2h reads res. Each kernel PE streams its 16×16 C tile east along its row into support column x = 8, in memory order, one value per packet and one control packet after each. ${cyc(go.cycles)} — with one I/O channel this is the longest phase of the run.`,
    checks: [['C tile each PE sends = its final C, bit for bit', ok(go.c_tiles_match)], ['packets per PE', `${go.data_packets_per_pe} values + ${go.control_packets_per_pe} control`]],
    code: ['gemm_host_read'], hl: ['memcpy_d2h'],
    held: () => ({x: 0, w: 0, c: 1}), paths: outputPaths(['256 values + 256 control per PE', ''], 'c', 1)});
  phases.gemm.push({id: 'out2', view: 'wafer', ev: 'meas', group: 'wafer → host', title: 'Down the east support column and out',
    text: `Support column x = 8 carries every row's output down to row 4, then east through (9,4) to the east halo (10,4) and the east I/O channel. The control packets are gone by the edge: exactly the ${cnt(go.exit_packets_at_east_halo_10_4)} values of C leave, and nothing else.`,
    checks: [['packets leaving through (10,4)', cnt(go.exit_packets_at_east_halo_10_4)], ['every one is a C value, and every C value leaves', go.exit_values_all_from_c && go.exit_covers_every_c_value ? 'yes' : 'no'],
             ['C vs X·W rebuilt from traced tiles, max relative error', gc.c_vs_xw_max_rel_err.toExponential(1)]],
    code: ['gemm_host_read'], hl: ['untile_res'],
    held: () => ({x: 0, w: 0, c: 1}), paths: outputPaths(['', `${cnt(go.exit_packets_at_east_halo_10_4)} values of C`], 'c', 2)});
  phases.gemm.push(hostPhase('h4', 'Back on the host: unpack, untile, check', ['cpu', 'ram'],
    `memcpy_d2h returns ${cnt(HOST.words_per_matrix)} 32-bit words. The host views their low halves as f16, <code>untile_res</code> puts the 16 tiles back into a ${HOST.M}×${HOST.N} matrix, and the launcher compares it with <code>np.matmul</code> in f32. That check covers repeat 1, the only repeat the host reads back. The later repeats only produce timing words.`,
    [['C vs X·W (from the traced tiles), max relative error', gc.c_vs_xw_max_rel_err.toExponential(1)], ['repeats multiplying matched k-blocks on all 16 PEs', `repeat 1 only (then ${GX.rep.aligned_later})`]],
    ['gemm_host_read'], ['untile_res', 'memcpy_view'], {group: 'host'}));
}
/* MeshGEMV: no receive buffers; the reduce adds straight from the input queue */
{
  const vi = VL.input, vo = VL.output, ck = D.vl.checks, red = D.red;
  const col = (px, from, to, extra) => ({t: 'c', a: [px, from], b: [px, to], path: Array.from({length: Math.abs(to - from) + 1}, (_, i) => [px, from + Math.sign(to - from) * i]), ...extra});
  phases.gemv.push(hostPhase('h1', 'Where W and x come from', ['storage', 'ram', 'cpu'],
    `As in MeshGEMM, W and x are generated in host RAM by np.random, seed 2025. There is no storage read. The host replicates x across each row with np.tile, so the fabric never has to broadcast x.`,
    [['source', 'np.random, seed 2025']], ['gemv_host_load'], ['np\\.tile', 'np\\.random']));
  phases.gemv.push(hostPhase('h3', 'Runtime and transport to the wafer edge', ['runtime', 'transport', 'edge'], HOST.transport_text, HOST.transport_checks, ['gemv_host_h2d'], ['memcpy_h2d'], {ev: 'doc'}));
  phases.gemv.push({id: 'in1', view: 'wafer', ev: 'meas', group: 'host → wafer', title: 'West I/O port → memcpy support',
    text: `The same path as MeshGEMM: in at the west halo PE (0,1), down support column x = 2, one value per packet. ${cyc(vi.cycles)}.`,
    checks: [['packets entering at halo (0,1)', cnt(vi.entry_packets_at_west_halo_0_1)]],
    code: ['gemv_host_h2d'], hl: ['memcpy_h2d'], held: () => ({x: 0, w: 0, c: 0}),
    paths: inputPaths([`${cnt(vi.entry_packets_at_west_halo_0_1)} packets`, '', ''], 1)});
  phases.gemv.push({id: 'in2', view: 'wafer', ev: 'meas', group: 'host → wafer', title: 'Row streams fill x and W',
    text: `Each row stream carries ${cnt(vi.row_stream_values_per_row)} values: the row's four x slices, then its four W tiles; PE px keeps every fourth.`,
    checks: [['x slice each PE keeps = the x it computes with', ok(vi.x_slices_match)], ['W tile each PE keeps = the W it computes with', ok(vi.w_tiles_match)]],
    code: ['gemv_host_load'], hl: ['np\\.tile', 'reshape'], held: () => ({x: 1, w: 1, c: 0}),
    paths: inputPaths(['', '', `${cnt(vi.row_stream_values_per_row)} values per row, every 4th kept`], 2)});
  const B = (y, yRole, dimWx) => (px, py) => ({W: {label: `W(${py},${px})`, role: dimWx ? 'idle' : 'fma'}, x: {label: `x(${py})`, role: dimWx ? 'idle' : 'fma'}, y: y(px, py) && {label: y(px, py), role: yRole(px, py)}});
  phases.gemv.push({id: 'local', view: 'kernel', ev: 'meas', group: 'compute', title: 'Local multiply: nothing moves',
    text: 'Each PE multiplies its stationary W block by its x slice: 16 FMACHs, y += W[k,:] · x[k], each fed its scalar by @map. The fabric is idle.',
    checks: [['FMACH and FADDH results recomputed bit for bit', ok(ck.arithmetic)]], code: ['gemv_step', 'gemv_fma'], hl: ['@fmach', '@map'],
    bufs: B((px, py) => 'partial', () => 'acc'), moves: []});
  phases.gemv.push({id: 'reduce1', view: 'kernel', ev: 'meas', group: 'compute', title: 'Reduce, stage 1: pairs, added straight from the queue',
    text: `Rows 0 and 2 stream their partial y out of SRAM into OQ3 (<code>@fmovh(mv_down_send, y)</code>). Rows 1 and 3 add it <b>straight from the input queue</b>: <code>@faddh(y, mv_down_recv, y)</code> takes the incoming value as src0 from IQ3 and their own partial as src1, and writes y back to SRAM. MeshGEMV has no receive buffer: the hardware queue is the only buffer on the way. Colour ${red.c1}, one hop, cycles ${cnt(red.t1[0])}–${cnt(red.t1[1])}.`,
    checks: [['adds whose operands are exactly the neighbour\'s and its own (all stages)', ok(ck.reduce)]], code: ['gemv_reduce'], hl: ['faddh', 'fmovh', 'mv_down'],
    bufs: B((px, py) => py % 2 ? 'rows ' + (py - 1) + '+' + py : 'partial', (px, py) => py % 2 ? 'add' : 'send', true),
    moves: [0, 1, 2, 3].flatMap(px => [col(px, 0, 1, {from: 'y', to: 'y', q: ['OQ3', 'IQ3'], colour: red.c1, op: 'FADDH'}), col(px, 2, 3, {from: 'y', to: 'y', q: ['OQ3', 'IQ3'], colour: red.c1, op: 'FADDH'})])});
  phases.gemv.push({id: 'reduce2', view: 'kernel', ev: 'meas', group: 'compute', title: 'Reduce, stage 2: across the pairs',
    text: `Row 1 streams its stage-1 sum into OQ5. The packets pass straight through row 2's router on colour ${red.c2}, without touching its core, and row 3 adds them from IQ5 into its own sum. Row 3 now holds the complete y for its column. Cycles ${cnt(red.t2[0])}–${cnt(red.t2[1])}.`,
    checks: [['adds whose operands are exactly the neighbour\'s and its own (all stages)', ok(ck.reduce)]], code: ['gemv_reduce'], hl: ['down_reduce', 'faddh'],
    bufs: B((px, py) => py === 3 ? 'rows 0-3' : py === 1 ? 'rows 0+1' : 'partial', (px, py) => py === 3 ? 'add' : py === 1 ? 'send' : 'idle', true),
    moves: [0, 1, 2, 3].map(px => col(px, 1, 3, {from: 'y', to: 'y', q: ['OQ5', 'IQ5'], colour: red.c2, op: 'FADDH'}))});
  phases.gemv.push({id: 'bcast', view: 'kernel', ev: 'meas', group: 'compute', title: 'Broadcast: one multicast packet per element',
    text: `Row 3 streams the result into OQ6 once. Each router on the way up delivers it down its own ramp into IQ6 and forwards it north: route rx SOUTH → tx RAMP, NORTH. Each receiving PE overwrites its y with <code>@fmovh(y, up_bd_recv)</code>. Colour ${red.cb}; all ${cnt(red.bpk)} broadcast packets are observed at exactly ${red.bpp} PEs.`,
    checks: [['non-final rows end holding row 3\'s final y exactly', ok(ck.broadcast)], ['y vs x·W from traced tiles, max relative error', ck.global_max_rel_err.toExponential(1)]],
    code: ['gemv_bcast', 'gemv_reduce'], hl: ['C_U_B', 'RAMP, NORTH', 'up_bd'],
    bufs: B((px, py) => 'final', (px, py) => py === 3 ? 'send' : 'recv', true),
    moves: [0, 1, 2, 3].map(px => col(px, 3, 0, {from: 'y', to: 'y', q: ['OQ6', 'IQ6'], colour: red.cb, mult: true}))});
  phases.gemv.push({id: 'out', view: 'wafer', ev: 'meas', group: 'wafer → host', title: 'y streams out through the east edge',
    text: `The host reads y from every PE: east along each row into support column x = 8, down to row 4, out through the east halo (10,4). ${cyc(vo.cycles)}. The same port then carries the two timing reads.`,
    checks: [['y each PE sends = its column\'s final y, bit for bit', ok(vo.y_match)], ['packets through (10,4)', `${cnt(vo.exit_packets_at_east_halo_10_4)} = 256 y values + 80 timing words`]],
    code: ['gemv_host_read'], hl: ['memcpy_d2h'], held: () => ({x: 0, w: 0, c: 1}),
    paths: outputPaths(['y, east along each row', `${cnt(vo.exit_packets_at_east_halo_10_4)} packets out`], 'c')});
}
/* Hot Chips 2022: documented, drawn schematically with the same conventions */
{
  const H = (acc, role) => (px, py) => ({act: {label: `act (${px},${py})`, role: 'stationary'}, acc: {label: acc(px, py), role: role(px, py)}});
  const down = px => ({t: 'w', a: [px, 0], b: [px, 3], path: [[px, 0], [px, 1], [px, 2], [px, 3]], top: true, mult: true, from: null, to: 'acc', q: ['', 'IQ'], colour: '?', op: 'FMAC'});
  phases.hc = [
   {id: 'act', view: 'kernel', ev: 'doc', group: 'layer start', title: 'Activations are spread across the wafer',
    text: 'Each PE holds a chunk of the activation tensor in its own SRAM and keeps it for the whole layer. The weight matrix is not on the wafer at all; it sits in off-wafer MemoryX.',
    checks: [], code: [], hl: [], bufs: H(() => 'acc = 0', () => 'idle'), moves: []},
   {id: 'wb', view: 'kernel', ev: 'doc', group: 'per weight row', title: 'Weights stream in and are multicast down the columns',
    text: 'Weights stream in from MemoryX one row at a time. Each arrives at the top router of a column, and every router on the way delivers it down its ramp and forwards it south. Each packet is 16 bits of weight plus a 16-bit index; zero weights are never sent. Colours and queue numbers are not documented, so they are left blank.',
    checks: [], code: [], hl: [], bufs: H(() => 'acc', () => 'fmac'), moves: [0, 1, 2, 3].map(down)},
   {id: 'fmac', view: 'kernel', ev: 'doc', group: 'per weight row', title: 'Each arriving weight triggers the FMACs',
    text: 'The weight goes from the input queue straight into the FMAC\'s scalar port and multiplies the local column of activations into the accumulators. It is used once and never written to memory.',
    checks: [], code: [], hl: [], bufs: H(() => 'acc += w·act', () => 'acc'), moves: []},
   {id: 'psum', view: 'kernel', ev: 'doc', group: 'per weight row', title: 'Partial sums are reduced along each row',
    text: 'A PSUM command starts the reduction of partial sums along each row of cores. Cerebras describes it as a ring; the drawing shows one pass. An FSUM command then steers the final sum to the column that owns it; which column that is here is illustrative.',
    checks: [], code: [], hl: [], bufs: H((px) => px === 3 ? 'final sum' : 'psum', (px) => px === 0 ? 'send' : 'add'),
    moves: [0, 1, 2, 3].flatMap(py => [0, 1, 2].map(px => ({t: 'c', a: [px, py], b: [px + 1, py], path: [[px, py], [px + 1, py]], from: 'acc', to: 'acc', q: ['', ''], colour: '?', op: 'add'})))},
  ];
}

/* ---------- detail panel: exact numbers from the verified run ---------- */
const g3 = h => { const v = f16(h), s = Math.abs(v) < 10 ? v.toFixed(3) : v.toFixed(2); return s.replace(/^(-?)0\./, '$1.'); };
let pick = [5, 9];                                   /* the C element under hand-check; X/W grids highlight its row / column */
/* a 16 x 16 tile as numbers; o.row / o.col highlight a row or column, o.cell one element, o.click makes cells selectable */
function grid(M, t, rowLab, colLab, o = {}){
  const head = `<tr><th class="corner">${rowLab}\\${colLab}</th>${M[0].map((_, j) => `<th class="${o.col === j ? 'on' : ''}">${j}</th>`).join('')}</tr>`;
  const body = M.map((r, i) => `<tr><th class="${o.row === i ? 'on' : ''}">${i}</th>${r.map((h, j) => {
    const cls = [o.cell && o.cell[0] === i && o.cell[1] === j ? 'sel' : '', o.row === i || o.col === j ? 'hl' : ''].join(' ').trim();
    return `<td class="${cls}" ${o.click ? `data-ij="${i}:${j}"` : ''} title="[${i},${j}] = ${f16(h)} · ${hex(h)}">${g3(h)}</td>`; }).join('')}</tr>`).join('');
  return `<div class="gridwrap"><table class="grid g-${t}${o.click ? ' clk' : ''}">${head}${body}</table></div>
    <p class="mini">exact f16 values from the trace, shown to 3 decimals · hover a value for its full value and bits${o.click ? ' · <b>click any element</b> to hand-check it' : ''}</p>`;
}
function vec(v, t, o = {}){
  return `<div class="gridwrap"><table class="grid g-${t}"><tr><th class="corner">i</th>${v.map((_, i) => `<th>${i}</th>`).join('')}</tr>
    <tr><th>${o.lab || ''}</th>${v.map((h, i) => `<td class="${o.hi === i ? 'hl' : ''}" title="${f16(h)} · ${hex(h)}">${g3(h)}</td>`).join('')}</tr></table></div>`;
}
let detailSel = null;
function detailGemm(t, px, py, s){
  const tile = D.gv[`${px},${py},${s}`], k = kx(px, py, s), [m, n] = pick;
  const hdr = `<p class="eyebrow">MeshGEMM · PE (${px},${py}) · step ${s + 1} · checked run (repeat 1 of 7)</p>`;
  if (t === 'x') return hdr + `<h3>X(${py},${k}) — the tile this PE multiplies in step ${s + 1}</h3>` +
    `<p class="mini">Row ${m} is highlighted: it is what C[${m},${n}] reads. Column k of this tile is the vector one FMACH streams.</p>` +
    grid(tile.X, 'x', 'm', 'k', {row: m}) +
    `<p class="ok">${s === 0 ? 'Arrived by the skew' : `Arrived from PE (${recv[px]},${py}), its ring predecessor, bit-identical`}. All 64 X transfers of the run carry exactly the tile computed on.</p>`;
  if (t === 'w') return hdr + `<h3>W(${k},${px}) — each element is one FMACH's broadcast scalar</h3>` +
    `<p class="mini">Column ${n} is highlighted: it is what C[${m},${n}] reads.</p>` +
    grid(tile.W, 'w', 'k', 'n', {col: n}) +
    `<p class="ok">${s === 0 ? 'Loaded by the host, already aligned to this column' : `Arrived from PE (${px},${recv[py]}), bit-identical`}. All 64 W transfers verified.</p>`;
  let run = tile.C0[m][n], rows = '';
  for (let kk = 0; kk < T; kk++){
    const x = tile.X[m][kk], w = tile.W[kk][n], nxt = toF16(f16(run) + f16(x) * f16(w));
    rows += `<tr><td>${kk}</td><td class="cx">${g3(x)}</td><td class="cw">${g3(w)}</td><td>${(f16(x) * f16(w)).toFixed(4)}</td><td class="cc">${fv(nxt)}</td><td class="mini">${hex(nxt)}</td></tr>`;
    run = nxt;
  }
  const match = run === tile.C1[m][n];
  return hdr + `<h3>C(${py},${px}) after step ${s + 1} — output-stationary</h3>` + grid(tile.C1, 'c', 'm', 'n', {cell: pick, click: true}) +
    `<p class="eyebrow" style="margin-top:14px">Hand-check C[${m},${n}], recomputed here in your browser</p>
     <p class="mini">Start: ${fv(tile.C0[m][n])}${s === 0 ? ' (C is cleared at the start of each run)' : ` (the value after step ${s})`}. Each row is one FMACH:
       acc ← round<sub>f16</sub>(acc + X[${m},k]·W[k,${n}]), a single rounding. X[${m},·] is row ${m} of this step's X tile, and W[·,${n}] is column ${n} of its W tile.</p>
     <div class="gridwrap"><table class="chain"><thead><tr><th>k</th><th>X[${m},k]</th><th>W[k,${n}]</th><th>product</th><th>acc</th><th>bits</th></tr></thead><tbody>${rows}</tbody></table></div>
     <p class="${match ? 'ok' : 'bad'}">${match ? '✓ equals' : '✗ differs from'} the traced value ${fv(tile.C1[m][n])} (${hex(tile.C1[m][n])}) bit for bit. Across the run, ${ok(D.gl.phases.compute.fma_bit_exact)} FMA results reproduce this way.</p>`;
}
function detailGemv(t, px, py, ph){
  const e = D.vv.pes[`${px},${py}`];
  const hdr = `<p class="eyebrow">MeshGEMV · PE (${px},${py}) · first run</p>`;
  if (t === 'w') return hdr + `<h3>W(${py},${px}) — stationary; row k is the vector FMACH k streams</h3>` + grid(e.W, 'w', 'k', 'n');
  if (t === 'x') return hdr + `<h3>x(${py}) — 16 scalars, one per FMACH, fed by @map</h3>` + vec(e.x, 'x', {lab: 'x'});
  let h = hdr;
  if (ph === 'local'){
    let run = Array(T).fill(0), okc = 0;                          /* recompute the 16 FMACHs: y += W[k,:]·x[k] */
    for (let k = 0; k < T; k++) run = run.map((a, j) => toF16(f16(a) + f16(e.W[k][j]) * f16(e.x[k])));
    run.forEach((v, j) => okc += v === e.partial[j]);
    h += `<h3>partial y — the result of this PE's 16 FMACHs</h3>` + vec(e.partial, 'c', {lab: 'y'}) +
      `<p class="${okc === T ? 'ok' : 'bad'}">Recomputed here from the W and x above, y[j] = Σ<sub>k</sub> W[k,j]·x[k], rounded to f16 once per term: ${okc} / ${T} elements equal the trace bit for bit.</p>`;
  } else if (ph === 'bcast' || ph === 'out') h += `<h3>final y for column ${px}</h3>` + vec(D.vv.final[px], 'c', {lab: 'y'});
  else {
    h += `<h3>partial y</h3>` + vec(e.partial, 'c', {lab: 'y'});
    if (e.adds.length) e.adds.forEach((a, i) => {
      let okc = 0; const rows = a.sum.map((s, j) => { const r = toF16(f16(a.received[j]) + f16(a.own[j])); okc += r === s;
        return `<tr><td>${j}</td><td>${fv(a.received[j])}</td><td>${fv(a.own[j])}</td><td class="cc">${fv(s)}</td><td>${r === s ? '✓' : '✗'}</td></tr>`; }).join('');
      h += `<p class="eyebrow" style="margin-top:12px">add ${i + 1} · cycle ${cnt(a.cycle)} · FADDH: received (src0) + own (src1)</p>
        <div class="gridwrap"><table class="chain"><thead><tr><th>j</th><th>received</th><th>own</th><th>sum (traced)</th><th>recomputed</th></tr></thead><tbody>${rows}</tbody></table></div>
        <p class="${okc === T ? 'ok' : 'bad'}">${okc} / ${T} sums reproduce bit for bit.</p>`;
    });
    else h += `<p class="mini">This row only sends in the reduce, so it adds nothing.</p>`;
  }
  return h;
}
const tileOf = lab => { const m = /^([XW])\((\d),(\d)\)$/.exec(lab || ''); if (!m) return null;
  return m[1] === 'X' ? {t: 'x', M: D.xt[`${m[2]},${m[3]}`], rl: 'm', cl: 'k'} : {t: 'w', M: D.wt[`${m[2]},${m[3]}`], rl: 'k', cl: 'n'}; };
const ROLE_TEXT = {send: 'being sent: a micro-thread @mov16 reads it into the output queue', recv: 'being written: a micro-thread @mov16 fills it from the input queue',
  fma: 'being read by the FMACHs of this step', next: 'holds the tile for the next step', acc: 'accumulator: FMACH reads it as src0 and writes it as dest',
  write: 'written by FMOV16 (cleared)', loaded: 'filled by the host\'s memcpy_h2d', held: 'holds data; nothing touches it in this phase', idle: 'not touched in this phase',
  add: 'FADDH writes it: incoming value (src0, straight from the input queue) + own value (src1)', stationary: 'stays for the whole layer', fmac: 'accumulates FMAC results'};
function detailBuf(){
  const {name, px, py} = detailSel, f = phases[scheme][ph], e = f.bufs(px, py)[name];
  const addr = scheme === 'gemm' ? ` · byte address ${D.gk.buffers[name]}` : '';
  let h = `<p class="eyebrow">${scheme === 'gemm' ? 'MeshGEMM' : 'MeshGEMV'} · PE (${px},${py}) · ${esc(f.title)}</p>
    <h3>${name.replace('_', '<sub>') + (name.includes('_') ? '</sub>' : '')} holds ${esc(e.label)}</h3>
    <p class="mini">${ROLE_TEXT[e.role] || ''}${addr}${e.was && e.was !== e.label ? ` · was ${esc(e.was)} before this transfer` : ''}</p>`;
  if (scheme === 'gemv'){
    if (name === 'W') return h + grid(D.vv.pes[`${px},${py}`].W, 'w', 'k', 'n');
    if (name === 'x') return h + vec(D.vv.pes[`${px},${py}`].x, 'x', {lab: 'x'});
    return h + detailGemv('c', px, py, f.id);
  }
  if (name === 'res'){
    if (f.step !== undefined) return h + detailGemm('c', px, py, f.step);
    const s = f.id.startsWith('step') ? +f.id.slice(4) - 2 : -1;
    return h + (s >= 0 ? `<p class="mini">C after step ${s + 1}, unchanged while the tiles move:</p>` + grid(D.gv[`${px},${py},${s}`].C1, 'c', 'm', 'n')
      : `<p>All zeros${f.id === 'clear' ? ', written by one FMOV16 over 256 elements' : ''}.</p>`);
  }
  if (f.step !== undefined && e.role === 'fma') return h + detailGemm(TOF[name], px, py, f.step);
  const T_ = tileOf(e.label);
  if (!T_) return h + `<p>No tile yet: the buffer was declared <code>@zeros([Mt*Kt]f16)</code> and has not received data.</p>`;
  return h + grid(T_.M, T_.t, T_.rl, T_.cl) + `<p class="ok">Tile ${esc(e.label)} is one of the verified repeat-1 tiles (bit for bit); this buffer's role in this phase comes from the pointer and DSD-base stores in the trace.</p>`;
}
function showDetail(){
  const el = $('detail'); if (!detailSel){ el.innerHTML = `<p class="eyebrow">Numbers from the verified run</p>
    <p>Tap any buffer in a PE's SRAM (X<sub>0</sub>, X<sub>1</sub>, W<sub>0</sub>, W<sub>1</sub>, res) or a kernel PE in the wafer view to see its exact values from the run the host checked. In res, click any element to recompute it here, term by term.</p>
    <p class="mini">A selected tile is followed as it moves: when it is sent, stepping forward takes you to the buffer it lands in.</p>`; return; }
  const {kind, px, py} = detailSel, f = phases[scheme][ph];
  if (scheme === 'hc'){ el.innerHTML = `<p class="eyebrow">Hot Chips 2022 · documented</p><h3>No traced run</h3><p>This dataflow is Cerebras's description of the appliance's weight-streaming mode on WSE-2. The SDK kernels traced in this study can't reach it, so there are no measured numbers to show.</p>`; return; }
  if (kind === 'buf') el.innerHTML = detailBuf();
  else if (scheme === 'gemm'){
    const first = f.id.startsWith('in');
    el.innerHTML = first ? `<p class="eyebrow">MeshGEMM · PE (${px},${py}) · as loaded by the host</p><h3>X(${py},${px}) arrives in X<sub>0</sub></h3>` + grid(D.xt[`${py},${px}`], 'x', 'm', 'k') +
        `<h3 style="margin-top:12px">W(${D.ind[py][px]},${px}) arrives in W<sub>0</sub></h3>` + grid(D.gv[`${px},${py},0`].W, 'w', 'k', 'n') +
        `<p class="ok">Both equal, bit for bit, this PE's share of its row stream: X ${ok(D.gl.phases.input.x_tiles_match)}, W ${ok(D.gl.phases.input.w_tiles_match)} PEs.</p>`
      : `<p class="eyebrow">MeshGEMM · PE (${px},${py}) · leaving for the host</p><h3>C(${py},${px}) as it streams out of res</h3>` + grid(D.gv[`${px},${py},${P - 1}`].C1, 'c', 'm', 'n') +
        `<p class="ok">Sent in memory order, and equal to the final C bit for bit on ${ok(D.gl.phases.output.c_tiles_match)} PEs.</p>`;
  } else {
    const e = D.vv.pes[`${px},${py}`];
    el.innerHTML = f.id.startsWith('in') ? `<p class="eyebrow">MeshGEMV · PE (${px},${py}) · as loaded</p><h3>x(${py})</h3>` + vec(e.x, 'x', {lab: 'x'}) + `<h3 style="margin-top:12px">W(${py},${px})</h3>` + grid(e.W, 'w', 'k', 'n')
      : `<p class="eyebrow">MeshGEMV · PE (${px},${py}) · leaving for the host</p><h3>final y(${px})</h3>` + vec(D.vv.final[px], 'c', {lab: 'y'});
  }
  el.querySelectorAll('td[data-ij]').forEach(r => r.addEventListener('click', () => { pick = r.dataset.ij.split(':').map(Number); showDetail(); }));
}

/* ---------- code panel: verbatim source ---------- */
function codeBlock(key, hl){
  const s = D.snip[key]; if (!s) return '';
  const re = hl.length ? new RegExp(hl.join('|')) : null;
  const lines = s.code.split('\n').map((l, i) => `<span class="ln${re && re.test(l) ? ' hl' : ''}"><i>${s.start + i}</i>${esc(l) || ' '}</span>`).join('');
  return `<details class="code" open><summary>${esc(s.file)}:${s.start}–${s.end}</summary><pre>${lines}</pre></details>`;
}

/* ---------- lifecycle bar, drawing, controls ---------- */
let scheme = 'gemm', ph = 0, timer = null, shown = null, tf = 'both';
function drawLife(){
  const L = phases[scheme], groups = [];
  L.forEach((f, i) => { const g = groups[groups.length - 1]; if (g && g.name === f.group) g.items.push(i); else groups.push({name: f.group, items: [i]}); });
  $('life').innerHTML = groups.map(g => `<div class="lg"><span class="lgn">${esc(g.name)}</span><div class="lgp">${g.items.map(i =>
    `<button data-i="${i}" aria-pressed="${i === ph}" title="${esc(L[i].title)}">${i + 1}</button>`).join('')}</div></div>`).join('<span class="lga">→</span>');
  $('life').querySelectorAll('button').forEach(b => b.onclick = () => { stop(); ph = +b.dataset.i; drawMesh(); });
}
/* keep a selection across phases. Stepping forward from a phase in which the selected buffer was being
   sent moves the selection to the buffer the tile landed in, so the panel follows the data. */
function follow(prev, f){
  if (!detailSel) return;
  if (f.view === 'host'){ detailSel = null; return; }
  const home = scheme === 'gemv' ? 'y' : 'res';
  if (f.view === 'wafer'){ if (detailSel.kind === 'buf') detailSel = {kind: 'pe', px: detailSel.px, py: detailSel.py}; return; }
  if (detailSel.kind === 'pe'){ detailSel = {kind: 'buf', name: home, px: detailSel.px, py: detailSel.py}; return; }
  if (prev && prev.view === 'kernel' && phases[scheme].indexOf(f) === phases[scheme].indexOf(prev) + 1){
    const m = prev.moves.find(q => q.a[0] === detailSel.px && q.a[1] === detailSel.py && q.from === detailSel.name && !q.mult);
    if (m){ detailSel.px = m.b[0]; detailSel.py = m.b[1]; detailSel.name = m.to; }
  }
  if (!f.bufs(detailSel.px, detailSel.py)[detailSel.name]) detailSel = null;
}
function drawMesh(){
  const isCyc = scheme === 'cyc';
  $('cycfig').hidden = !isCyc; $('life').hidden = isCyc; $('meshfig').hidden = isCyc; document.querySelector('#meshfig + .below').hidden = isCyc;
  $('mtabs').querySelectorAll('button').forEach(b => b.setAttribute('aria-pressed', String(b.dataset.k === scheme)));
  if (isCyc){ if (window.__cyc) window.__cyc.draw(); return; }
  const L = phases[scheme], f = L[ph], svg = $('mesh');
  follow(shown && shown.scheme === scheme ? L[shown.ph] : null, f);
  shown = {scheme, ph};
  const [w, h, draw] = f.view === 'wafer' ? [WV.W, WV.H, waferView] : f.view === 'host' ? [HV.W, HV.H, hostView] : [KV.W, KV.H, kernelView];
  svg.setAttribute('viewBox', `0 0 ${w} ${h}`); svg.innerHTML = draw(f);
  svg.setAttribute('aria-label', f.title + '. ' + f.text.replace(/<[^>]+>/g, ''));
  svg.querySelectorAll('.chip').forEach(c => {
    const open = () => {
      if (c.dataset.pe){ const [px, py] = c.dataset.pe.split(':').map(Number); detailSel = {kind: 'pe', px, py}; }
      else { const [name, px, py] = c.dataset.buf.split(':'); detailSel = {kind: 'buf', name, px: +px, py: +py}; }
      drawMesh(); if (innerWidth < 960) $('detail').scrollIntoView({behavior: smooth, block: 'start'});
    };
    c.addEventListener('click', open); c.addEventListener('keydown', e => { if (e.key === 'Enter' || e.key === ' '){ e.preventDefault(); open(); } });
  });
  $('phase').textContent = `phase ${ph + 1} / ${L.length}`;
  const both = f.view === 'kernel' && f.moves.some(m => m.t === 'x') && f.moves.some(m => m.t === 'w');
  $('tfilter').innerHTML = both ? ['both', 'x', 'w'].map(k => `<button data-tf="${k}" aria-pressed="${tf === k}">${k === 'both' ? 'X + W' : k.toUpperCase() + ' only'}</button>`).join('') : '';
  $('tfilter').querySelectorAll('button').forEach(b => b.onclick = () => { tf = b.dataset.tf; drawMesh(); });
  $('viewtag').textContent = f.view === 'wafer' ? 'whole fabric · 11 × 6' : f.view === 'host' ? 'host side · before and after the wafer'
    : 'kernel · 4 × 4 · each PE = router + ramp + SRAM';
  $('capev').innerHTML = `<span class="ev ${f.ev}">${f.ev === 'doc' ? 'documented' : f.ev === 'src' ? 'source' : 'measured'}</span> &nbsp;${esc(f.group)}`;
  $('captitle').textContent = f.title;
  $('captext').innerHTML = f.text;
  $('checks').innerHTML = f.checks.map(([a, b]) => `<li><span>${esc(a)}</span><b>${esc(String(b))}</b></li>`).join('');
  $('capform').innerHTML = FORM[scheme] + ' &nbsp;<a href="#forms">compare &uarr;</a>';
  $('code').innerHTML = f.code.length ? `<p class="eyebrow" style="margin-top:14px">The code that runs this phase, verbatim</p>` + f.code.map(k => codeBlock(k, f.hl)).join('') : '';
  $('mkey').innerHTML = f.view === 'wafer'
    ? `<span><i class="sq"></i>router, inside each PE</span><span><i class="dot"></i>delivered down the ramp into this PE</span><span>bars in a kernel PE: <b style="color:var(--x)">X</b> <b style="color:var(--w)">W</b> <b style="color:var(--c)">C</b> held</span>`
    : f.view === 'host' ? `<span>boxes: where the data is, left to right in time</span><span>tag: <b>source</b> = host code · <b>documented</b> = Cerebras docs · <b>trace</b> = simulator · dashed = not used by this code</span>`
    : `<span><i class="sq"></i>router: each line inside is one route, rx port → tx port</span><span><i class="sq" style="border-style:dashed"></i>transit: switched straight on, never reaches the core</span>`
      + `<span><b>c2 · 1/2</b> = colour 2, hop 1 of 2, one arrow per link</span><span><b>OQ2 / IQ2</b> = hardware output / input queue (WSE-3: 8 / 4 words)</span>`
      + `<span>dashed buffer = being sent · bold = being written or read by the FMACHs</span>`
      + (scheme === 'gemm' ? `<span class="kshade">shade = k-block; an arrow has the shade of the tile it carries: ${['x', 'w'].map(t => [0, 1, 2, 3].map(k =>
        `<i style="background:${sh(t, k)}" title="${t.toUpperCase()} k = ${k}"></i>`).join('')).join(' &nbsp;')} &nbsp;k = 0 … 3</span>` : '');
  $('mtabs').querySelectorAll('button').forEach(b => b.setAttribute('aria-pressed', String(b.dataset.k === scheme)));
  drawLife(); showDetail();
}
const FORM = {
  gemm: 'Inside each PE: <b>outer product</b>, 16 FMACHs per k sharing one X column. Across PEs: <b>inner product in time</b>, one k-block term per step.',
  gemv: 'Inside each PE: <b>outer product</b> (AXPY form of GEMV). Across PEs: <b>inner product in space</b>, K split down the column and reduced.',
  hc: 'Inside each PE: <b>outer product</b>, one AXPY per weight. Across PEs: <b>inner product in space</b>, K split along the row and ring-reduced.',
};
const MT = {gemm: 'MeshGEMM · output-stationary', gemv: 'MeshGEMV · weight-stationary', hc: 'Hot Chips 2022 · activation-stationary', cyc: 'Cycle animation · after qin00162'};
$('mtabs').innerHTML = Object.entries(MT).map(([k, v]) => `<button data-k="${k}">${v}</button>`).join('');
$('mtabs').querySelectorAll('button').forEach(b => b.onclick = () => { scheme = b.dataset.k; ph = 0; detailSel = null; shown = null; stop(); drawMesh(); });
function stop(){ if (timer) clearInterval(timer); timer = null; $('play').textContent = 'Play'; }
$('fwd').onclick = () => { if (scheme === 'cyc') return; ph = Math.min(phases[scheme].length - 1, ph + 1); drawMesh(); };
$('back').onclick = () => { if (scheme === 'cyc') return; ph = Math.max(0, ph - 1); drawMesh(); };
$('play').onclick = () => { if (scheme === 'cyc') return; if (timer) return stop(); $('play').textContent = 'Pause';
  timer = setInterval(() => { ph = (ph + 1) % phases[scheme].length; drawMesh(); }, 3200); };
addEventListener('keydown', e => {
  if (/INPUT|TEXTAREA/.test(e.target.tagName)) return;
  if (scheme === 'cyc'){ if (e.key === 'ArrowRight'){ e.preventDefault(); $('cycnext').click(); } if (e.key === 'ArrowLeft'){ e.preventDefault(); $('cycprev').click(); } return; }
  if (e.key === 'ArrowRight'){ e.preventDefault(); $('fwd').click(); }
  if (e.key === 'ArrowLeft'){ e.preventDefault(); $('back').click(); }
});
function flash(el){ el.classList.remove('flash'); void el.offsetWidth; el.classList.add('flash'); }
const smooth = matchMedia('(prefers-reduced-motion: reduce)').matches ? 'auto' : 'smooth';
document.querySelectorAll('a.go').forEach(a => a.addEventListener('click', e => {
  e.preventDefault();
  if (a.dataset.pe){ pe = a.dataset.pe; drawPE(); $('pefig').scrollIntoView({behavior: smooth, block: 'center'}); flash($('pefig')); }
  if (a.dataset.go){
    const [sc, id] = a.dataset.go.split(':');
    stop(); scheme = sc; detailSel = null; shown = null; ph = Math.max(0, phases[sc].findIndex(q => q.id === id)); drawMesh();
    $('meshfig').scrollIntoView({behavior: smooth, block: 'start'}); flash($('meshfig'));
  }
}));
drawPE(); drawMesh();
