/* ======================= cycle animation tab: one panel, tiles as pie glyphs, after qin00162/Cerebras ======================= */
{
const C = D.cyc, T = C.T, PEs = [0, 1, 2, 3];
const canvas = $('cyc'), ctx = canvas.getContext('2d');
let cycle = C.start, playing = false, last = 0, zoomPE = null;
const css = n => getComputedStyle(document.documentElement).getPropertyValue(n).trim();
/* colour: hue family by tensor (X blue, W orange, as everywhere on this page), lightness by k-block: same k, same shade */
const kOf = g => g[0] === 'X' ? +g[4] : +g[2];            /* X(i,k) -> k, W(k,j) -> k */
/* canvas needs concrete colours: resolve the page's variables and mix towards ink by k */
const hex = v => { const c = v.trim(); if (c[0] === '#') return [1, 3, 5].map(i => parseInt(c.length === 4 ? c[(i + 1) / 2] + c[(i + 1) / 2] : c.slice(i, i + 2), 16));
  const m = c.match(/\d+/g) || [0, 0, 0]; return m.slice(0, 3).map(Number); };
const mixc = (a, b, t) => `rgb(${a.map((v, i) => Math.round(v + (b[i] - v) * t)).join(',')})`;
const shade = (t, k) => mixc(hex(css(`--${t}`)), hex(css('--ink')), k * 0.2);
const tileCol = g => shade(g[0] === 'X' ? 'x' : 'w', kOf(g));
const X0 = 110, Y0 = 70, GX = 232, GY = 165, R = 42, BW = 86, BH = 62;
const pos = (px, py) => [X0 + px * GX + BW, Y0 + py * GY + BH];
const runsAt = (pe, c) => (C.ops[pe] || []).filter(r => r[0] <= c && c <= r[1]);
const resAt = (pe, c) => (C.residency[pe] || []).filter(r => r.arrived !== null && r.arrived <= c && c < (r.overwritten ?? Infinity));
const stateOf = (r, c) => r.computed.some(([a, b]) => a <= c && c <= b) ? 'computing' : r.sent.some(([a, b]) => a <= c && c < b) ? 'sending' : 'resident';
const current = (res, t) => res.filter(r => r.t === t).sort((a, b) => (stateOf(b, cycle) === 'computing') - (stateOf(a, cycle) === 'computing') || b.arrived - a.arrived)[0];
const cAt = (px, py, c) => { const M = Array.from({length: T}, () => Array(T).fill(0)); if (!C.cvals) return M;
  for (const [cy, x, y, m, n, v] of C.cvals){ if (x === px && y === py && cy <= c) M[m][n] = v; } return M; };
function arrow(x, y, X, Y, w){
  ctx.lineWidth = w; ctx.beginPath(); ctx.moveTo(x, y); ctx.lineTo(X, Y); ctx.stroke();
  const a = Math.atan2(Y - y, X - x); ctx.beginPath(); ctx.moveTo(X, Y); ctx.lineTo(X - 9 * Math.cos(a - .45), Y - 9 * Math.sin(a - .45)); ctx.lineTo(X - 9 * Math.cos(a + .45), Y - 9 * Math.sin(a + .45)); ctx.fill();
}
function sector(x, y, r0, r1, a0, a1, fill){ ctx.beginPath(); ctx.arc(x, y, r1, a0, a1); ctx.arc(x, y, r0, a1, a0, true); ctx.closePath(); ctx.fillStyle = fill; ctx.fill(); }
function draw(){
  const ink = css('--ink'), ink2 = css('--ink2'), dim = css('--dim'), pan = css('--pan'), pan2 = css('--pan2'), ln = css('--ln');
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  ctx.fillStyle = ink; ctx.font = '600 16px IBM Plex Sans, system-ui'; ctx.fillText(`MeshGEMM · P = 4 · X and W ${T * 4} × ${T * 4}, ${T} × ${T} tiles · cycle ${cycle.toLocaleString('en-US')}`, 24, 30);
  ctx.font = '12px IBM Plex Mono, monospace'; ctx.fillStyle = ink2;
  const phase = (() => { const hi = Object.values(C.host_in), ho = Object.values(C.host_out);
    if (hi.length && cycle < Math.max(...hi.map(h => h.end))) return 'host → PEs: X then W arrive (memcpy, 1 value per wavelet)';
    if (ho.length && cycle >= Math.min(...ho.map(h => h.start))) return 'PEs → host: C streams out';
    const comp = Object.values(C.compute).flat().find(([a, b]) => a <= cycle && cycle < b); if (comp) return comp[2];
    const act = C.links.filter(l => l.start <= cycle && cycle < l.end); if (act.some(l => l.kind.startsWith('s'))) return 'skew: X tiles rotate along their rows';
    if (act.length) return 'tiles move to their ring successors'; return 'between phases'; })();
  ctx.fillText(phase, 24, 50);
  /* host edge markers */
  ctx.fillStyle = dim; ctx.font = '11px IBM Plex Mono, monospace'; ctx.fillText('host in', 18, Y0 + 2 * GY - 50); ctx.fillText('host out', canvas.width - 84, Y0 + 2 * GY - 50);
  const active = C.links.filter(l => l.start <= cycle && cycle < l.end);
  /* PEs as pie glyphs: X half (left), W half (right), inner disc = C progress, ring = compute/sending state */
  for (const py of PEs) for (const px of PEs){
    const pe = `${px},${py}`, [x, y] = pos(px, py), res = resAt(pe, cycle);
    const comp = (C.compute[pe] || []).find(([a, b]) => a <= cycle && cycle < b);
    ctx.fillStyle = pan2; ctx.beginPath(); ctx.roundRect(x - BW, y - BH, 2 * BW, 2 * BH, 8); ctx.fill(); ctx.strokeStyle = zoomPE === pe ? ink : ln; ctx.lineWidth = zoomPE === pe ? 2.5 : 1; ctx.stroke();
    ctx.fillStyle = ink; ctx.font = '11px IBM Plex Mono, monospace'; ctx.fillText(`PE (${px},${py})`, x - BW + 7, y - BH + 15);
    const xr = current(res, 'x'), wr = current(res, 'w');
    const cx = x - 38, cy = y + 6;
    if (comp && comp[2].startsWith('FMACH')){ ctx.beginPath(); ctx.arc(cx, cy, R + 7, 0, 2 * Math.PI); ctx.fillStyle = '#a7e6b0'; ctx.fill(); }
    sector(cx, cy, 14, R, Math.PI / 2, 3 * Math.PI / 2, xr ? tileCol(xr.g) : ln);
    sector(cx, cy, 14, R, -Math.PI / 2, Math.PI / 2, wr ? tileCol(wr.g) : ln);
    const steps_done = (C.compute[pe] || []).filter(([a, b, l]) => l.startsWith('FMACH') && b <= cycle).length + ((comp && comp[2].startsWith('FMACH')) ? .5 : 0);
    sector(cx, cy, 0, 12, -Math.PI / 2, -Math.PI / 2 + 2 * Math.PI * Math.min(1, steps_done / 4), css('--c'));
    ctx.strokeStyle = pan; ctx.lineWidth = 1.5; ctx.beginPath(); ctx.moveTo(cx, cy - R); ctx.lineTo(cx, cy + R); ctx.stroke();

    /* counters and flags */
    ctx.font = '10px IBM Plex Mono, monospace'; ctx.fillStyle = ink2;
    const line = (r, i) => { if (!r) return; const st = stateOf(r, cycle), flag = st === 'computing' ? '⚙' : st === 'sending' ? '↗' : '·';
      ctx.fillStyle = tileCol(r.g); ctx.font = '600 11px IBM Plex Mono, monospace'; ctx.fillText(`${flag} ${r.g}`, x + 12, y - 24 + i * 16); ctx.fillStyle = ink2; ctx.font = '10px IBM Plex Mono, monospace'; ctx.fillText(`${(cycle - r.arrived).toLocaleString('en-US')} cyc here`, x + 12, y - 11 + i * 16); };
    line(xr, 0); line(wr, 2);
    const tags = [...new Set(runsAt(pe, cycle).map(r => C.tags[r[2]]))].join('/');
    ctx.fillStyle = dim; ctx.font = '9px IBM Plex Mono, monospace'; ctx.fillText(tags ? tags.slice(0, 22) : '—', x - BW + 7, y + BH - 7);
  }
  /* host streams as edge arrows */
  for (const py of PEs) for (const px of PEs){
    const pe = `${px},${py}`, hi = C.host_in[pe], ho = C.host_out[pe], [x, y] = pos(px, py);
    if (hi && hi.start <= cycle && cycle < hi.end){ ctx.strokeStyle = ctx.fillStyle = css('--io'); arrow(px === 0 ? 20 : x - GX + BW + 6, y + 44, x - BW - 4, y + 44, 2); }
    if (ho && ho.start <= cycle && cycle < ho.end){ ctx.strokeStyle = ctx.fillStyle = css('--c'); arrow(x + BW + 4, y + 44, px === 3 ? canvas.width - 22 : x + GX - BW - 6, y + 44, 2); }
  }
  /* kernel transfers: one arrow per tile and hop, X along rows, W down columns; no colour numbers (the colour of the arrow is the tile) */
  const bundles = {};
  active.forEach(l => { const k = `${l.sx},${l.sy}>${l.tx},${l.ty}`; (bundles[k] = bundles[k] || []).push(l); });
  Object.values(bundles).forEach(es => es.forEach((e, i) => {
    let [x, y] = pos(e.sx, e.sy), [X, Y] = pos(e.tx, e.ty); const off = (i - (es.length - 1) / 2) * 14, vert = e.sx === e.tx;
    if (vert){ x += off - 30; X += off - 30; const s = Math.sign(Y - y); y += s * BH; Y -= s * BH; } else { y += off - 14; Y += off - 14; const s = Math.sign(X - x); x += s * BW; X -= s * BW; }
    ctx.strokeStyle = ctx.fillStyle = tileCol(e.g); arrow(x, y, X, Y, 3);
    ctx.font = '600 9px IBM Plex Mono, monospace'; ctx.textAlign = vert ? (i % 2 ? 'left' : 'right') : 'center';
    ctx.fillText(e.g, vert ? (x + X) / 2 + (i % 2 ? 8 : -8) : (x + X) / 2, vert ? (y + Y) / 2 + 3 : (y + Y) / 2 + (i % 2 ? 13 : -7)); ctx.textAlign = 'left';
  }));
  ctx.fillStyle = dim; ctx.font = '11px IBM Plex Sans, system-ui';
  ctx.fillText('Pie: left half = the X tile on the PE, right half = the W tile, same darkness = same k-block (they match while computing); centre fills as C accumulates. Arrow = one tile on one hop, first upstream to last downstream wavelet.', 24, canvas.height - 10);
  $('cycslider').value = cycle; $('cyclabel').textContent = cycle.toLocaleString('en-US');
  $('cyclinks').textContent = active.length ? active.map(l => `${l.g} | ${l.n} wavelets | PE(${l.sx},${l.sy}) → PE(${l.tx},${l.ty}) | hop ${l.hop}/${l.hops} | [${l.start}, ${l.end})`).join('\n') : 'no transfer in flight';
  $('cycops').textContent = PEs.flatMap(py => PEs.map(px => { const pe = `${px},${py}`, rs = runsAt(pe, cycle);
    return rs.length ? `PE(${pe}): ` + rs.map(r => `${C.tags[r[2]]} | ${C.instrs[r[4]]} | ${C.fns[r[3]]}${r[5] > 1 ? ` | run of ${r[5]} (${r[0]}–${r[1]})` : ''}`).join(' ; ') : null; })).filter(Boolean).join('\n') || 'no dispatch recorded on a kernel PE this cycle';
  zoom();
}
/* zoom: the selected PE at this cycle, with the tiles' places in X and W and their values */
const gridHTML = (M, t, hl) => `<table class="grid g-${t}"><tr><th class="corner"></th>${M[0].map((_, j) => `<th>${j}</th>`).join('')}</tr>` +
  M.map((r, i) => `<tr><th>${i}</th>${r.map((v, j) => `<td class="${hl && hl(i, j) ? 'sel' : ''}">${v}</td>`).join('')}</tr>`).join('') + `</table>`;
function zoom(){
  const el = $('cyczoom'); if (!zoomPE){ el.innerHTML = `<p class="eyebrow">Zoom</p><p>Click a PE in the animation to see, at the current cycle, which X and W tile it holds, where they sit in X and W, their values, and C so far.</p>`; return; }
  const [px, py] = zoomPE.split(',').map(Number), res = resAt(zoomPE, cycle), xr = current(res, 'x'), wr = current(res, 'w');
  const stepNow = (C.compute[zoomPE] || []).find(([a, b, l]) => a <= cycle && cycle < b && l.startsWith('FMACH'));
  const stepsDone = (C.compute[zoomPE] || []).filter(([a, b, l]) => l.startsWith('FMACH') && b <= cycle).length;
  const tileOf = g => { if (!g) return null; const i = +g[2], j = +g[4]; return g[0] === 'X' ? {i, j, M: C.X, name: 'X'} : {i, j, M: C.W, name: 'W'}; };
  const tx = tileOf(xr && xr.g), tw = tileOf(wr && wr.g);
  const blk = (M, i, j) => Array.from({length: T}, (_, a) => Array.from({length: T}, (_, b) => M[i * T + a][j * T + b]));
  const Cnow = cAt(px, py, cycle), Cfin = blk(C.C, py, px);
  const flag = r => r ? ({computing: 'computing on it now', sending: 'being sent to the ring successor', resident: 'resident, waiting'})[stateOf(r, cycle)] : '';
  let h = `<p class="eyebrow">PE (${px},${py}) at cycle ${cycle.toLocaleString('en-US')} · owns C(${py},${px}) · ${stepNow ? stepNow[2] : stepsDone === 4 ? 'all 4 steps done' : stepsDone + ' of 4 steps done'}</p>`;
  h += `<div class="zoomrow">`;
  h += `<div><p class="mini">X (${T * 4} × ${T * 4}); block ${tx ? `(${tx.i},${tx.j})` : '—'} is on this PE</p>${gridHTML(C.X, 'x', tx ? (i, j) => Math.floor(i / T) === tx.i && Math.floor(j / T) === tx.j : null)}</div>`;
  h += `<div><p class="mini">W; block ${tw ? `(${tw.i},${tw.j})` : '—'} is on this PE</p>${gridHTML(C.W, 'w', tw ? (i, j) => Math.floor(i / T) === tw.i && Math.floor(j / T) === tw.j : null)}</div>`;
  h += `<div><p class="mini">C = X·W; this PE owns block (${py},${px})</p>${gridHTML(C.C, 'c', (i, j) => Math.floor(i / T) === py && Math.floor(j / T) === px)}</div></div>`;
  h += `<div class="zoomrow">`;
  if (xr) h += `<div><p class="eyebrow">${xr.g} · ${flag(xr)}</p>${gridHTML(blk(C.X, tx.i, tx.j), 'x')}<p class="mini">arrived ${xr.from_host ? 'from the host' : 'by the fabric'} at cycle ${xr.arrived.toLocaleString('en-US')} → here for <b>${(cycle - xr.arrived).toLocaleString('en-US')}</b> cycles${xr.computed.length ? '; FMACH ' + xr.computed.map(([a, b]) => `${a}–${b}`).join(', ') : ''}${xr.sent.length ? '; sent ' + xr.sent.map(([a, b]) => `${a}–${b - 1}`).join(', ') : ''}${xr.overwritten ? '; overwritten at ' + xr.overwritten : ''}</p></div>`;
  if (wr) h += `<div><p class="eyebrow">${wr.g} · ${flag(wr)}</p>${gridHTML(blk(C.W, tw.i, tw.j), 'w')}<p class="mini">arrived ${wr.from_host ? 'from the host' : 'by the fabric'} at cycle ${wr.arrived.toLocaleString('en-US')} → here for <b>${(cycle - wr.arrived).toLocaleString('en-US')}</b> cycles${wr.computed.length ? '; FMACH ' + wr.computed.map(([a, b]) => `${a}–${b}`).join(', ') : ''}${wr.sent.length ? '; sent ' + wr.sent.map(([a, b]) => `${a}–${b - 1}`).join(', ') : ''}${wr.overwritten ? '; overwritten at ' + wr.overwritten : ''}</p></div>`;
  h += `<div><p class="eyebrow">C(${py},${px}) so far${C.cvals ? ' (from the FMACH results up to this cycle)' : ''}</p>${gridHTML(Cnow, 'c')}<p class="mini">final: ${Cfin.map(r => r.join(' ')).join(' / ')}${xr && wr && tx && tw ? (tx.j === tw.i ? ` · k-blocks match (k = ${tx.j}): this pair can multiply` : ` · k-blocks differ (${tx.j} vs ${tw.i}): not yet a matching pair`) : ''}</p></div></div>`;
  const others = res.filter(r => r !== xr && r !== wr);
  if (others.length) h += `<p class="mini">Also in SRAM (other buffer): ${others.map(r => `${r.g}, arrived ${r.arrived}, ${flag(r)}`).join('; ')}</p>`;
  el.innerHTML = h;
}
canvas.addEventListener('click', e => {
  const rect = canvas.getBoundingClientRect(), sx = canvas.width / rect.width, sy = canvas.height / rect.height, mx = (e.clientX - rect.left) * sx, my = (e.clientY - rect.top) * sy;
  let hit = null; for (const py of PEs) for (const px of PEs){ const [x, y] = pos(px, py); if (Math.abs(mx - x) <= 95 && Math.abs(my - y) <= 62) hit = `${px},${py}`; }
  zoomPE = hit === zoomPE ? null : hit; draw();
});
function step(d){ cycle = Math.min(C.end, Math.max(C.start, cycle + d)); draw(); }
$('cycplay').onclick = () => { playing = !playing; $('cycplay').textContent = playing ? 'Pause' : 'Play'; };
$('cycprev').onclick = () => step(-1); $('cycnext').onclick = () => step(1);
$('cycevent').onclick = () => { cycle = C.events.find(c => c > cycle) ?? C.start; draw(); };
$('cycslider').min = C.start; $('cycslider').max = C.end; $('cycslider').oninput = () => { cycle = +$('cycslider').value; draw(); };
const jumps = [['host in', () => Math.min(...Object.values(C.host_in).map(h => h.start))], ['skew', () => Math.min(...C.links.filter(l => l.kind.startsWith('s')).map(l => l.start)) - 3],
  ...[0, 1, 2, 3].map(s => [`step ${s + 1}`, () => Math.min(...Object.values(C.compute).map(iv => (iv.find(v => v[3] === s) || [C.start])[0])) - 60]),
  ['host out', () => Math.min(...Object.values(C.host_out).map(h => h.start))]];
$('cycjump').innerHTML = jumps.map(([l], i) => `<button data-i="${i}">${l}</button>`).join('');
$('cycjump').querySelectorAll('button').forEach(b => b.onclick = () => { cycle = Math.max(C.start, Math.min(C.end, jumps[+b.dataset.i][1]())); draw(); });
function tick(t){ if (playing && t - last >= 1000 / +$('cycspeed').value){ cycle = cycle < C.end ? cycle + 1 : C.start; last = t; draw(); } requestAnimationFrame(tick); }
$('cycnote').innerHTML = `Instance: X, W ${T * 4} × ${T * 4} integers (exact in f16), one checked repeat, ${cnt(C.end - C.start + 1)} cycles from the first host word reaching the kernel to the last C word leaving. Tiles identified against the FMACH operands: X ${C.checks.x_tile_matches_block} / ${C.checks.tiles}, W ${C.checks.w_tile_matches_block} / ${C.checks.tiles}; final C = host readback on ${C.checks.c_final_matches_host} / 16 PEs. ${C.links.length} hop envelopes.`;
window.__cyc = {draw, set cycle(v){ cycle = v; }, get cycle(){ return cycle; }, set zoom(v){ zoomPE = v; }};
draw(); requestAnimationFrame(tick);
}
