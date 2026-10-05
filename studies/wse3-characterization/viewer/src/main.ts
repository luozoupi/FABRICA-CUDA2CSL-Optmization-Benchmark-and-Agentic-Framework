import './style.css';

type Term = {id:string;i:number;j:number;k:number;round:number;a:number;b:number;old:number;product:number;acc:number;a_origin:number[];b_origin:number[];a_offset_bytes:number;b_offset_bytes:number;observed:null|Record<string,number|string>;instruction_ids:string[];arithmetic_ids?:string[];binding:string|null};
type Cell = {i:number;j:number;pe:string;local:number[];c_offset_bytes:number;expected:number;observed:number|null;terms:Term[]};
type PE = {id:string;x:number;y:number;fabric:number[];rows:number[];cols:number[];cycles?:number;window?:number[];placement_evidence:string};
type Exec = {cycle:number;element:number;lane:number;dest:number;src0:number;src1:number;src2:number};
type Inst = {id:string;uid:number;pe:string;pc:number|null;name:string;dispatch:number[];decode:number[];execute:Exec[];task?:number;ut?:number;raw_rows:number[]};
type Panel = {tensor:string;source:number[];destination:number[];round:number;values:number[][];packed:number[];observed:number[]|null;transfer:boolean};
type Scene = {id:string;n:number;p:number;t:number;a:number[][];b:number[][];cells:Cell[];pes:PE[];panels:Panel[];storage:string;status:string;verification:null|{passed:boolean;checks:number;contributions:number;outputs:number;mismatches:unknown[]};programs:Record<string,{assembly:Record<string,{text:string;source:string;file:string}>;csl:string;ir:string}>;dynamic:Record<string,Inst>;wavelets:{cycle:number;xy:number[];ident:string;color:number;data:number;row:number}[];trace:null|{counts:Record<string,number>;discarded:number;matched_terms:number;binding:string};control:null|{correct:boolean;pes:{id:string;cycles:number}[]};provenance:null|{run:string;mode:string;manifest_sha256:string;sif:string[];sha256:Record<string,string>}};
type Bundle = {schema:string;scenes:Scene[]};
declare global {interface Window {GEMM_BUNDLE?:Bundle;}}

const app=document.querySelector<HTMLDivElement>('#app')!;
const esc=(x:unknown)=>String(x??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]!));
const fmt=(v:unknown)=>typeof v==='number'?Number.isInteger(v)?v.toLocaleString('en-US'):v.toPrecision(5):'—';
const hex=(v:number)=>'0x'+v.toString(16).padStart(8,'0');
const float=(v:number)=>{const a=new Uint32Array([v]);return new Float32Array(a.buffer)[0];};
const bits=(v:number)=>{const a=new Float32Array([v]);return hex(new Uint32Array(a.buffer)[0]);};
let bundle:Bundle, scene:Scene, i=0,j=0,k=0,mode='math',tab='assembly',showBits=false,playing:number|undefined,prediction='',answerShown=false,selectedInst='';
const titles:Record<string,string>={g0:'One PE. Every number.',g1:'Four PEs. One result.',g2:'Bigger tiles. Same idea.'};
const subtitle:Record<string,string>={g0:'A handwritten 4 × 4 matrix multiplication, followed from input to output.',g1:'The same 4 × 4 matrices, with a 2 × 2 output tile on each PE.',g2:'An 8 × 8 multiplication across four PEs, each owning a 4 × 4 output tile.'};
const current=()=>scene.cells[i*scene.n+j];
const term=()=>current().terms[k];
const pe=()=>scene.pes.find(x=>x.id===current().pe)!;
const badge=(text:string,kind='')=>`<span class="badge ${kind}">${esc(text)}</span>`;
const number=(v:number)=>`${fmt(v)}${showBits?`<small>${bits(v)}</small>`:''}`;

function save(){
  const hash=new URLSearchParams({scene:scene.id,i:String(i),j:String(j),k:String(k),mode,tab});
  history.replaceState(null,'','#'+hash.toString());
}
function stop(){if(playing!==undefined)window.clearInterval(playing);playing=undefined;}
function move(delta:number){k=Math.max(0,Math.min(scene.n-1,k+delta));selectedInst='';answerShown=false;prediction='';render();}
function matrix(name:string,values:number[][]){
  return `<div class="matrix" style="--n:${scene.n}">${values.flatMap((row,r)=>row.map((value,c)=>{
    const active=name==='A'?r===i&&c===k:name==='B'?r===k&&c===j:r===i&&c===j;
    const related=name==='A'?r===i:name==='B'?c===j:Math.floor(r/scene.t)===pe().y&&Math.floor(c/scene.t)===pe().x;
    const owner=Math.floor(r/scene.t)*scene.p+Math.floor(c/scene.t);
    return `<button class="entry ${active?'active':''} ${related?'related':''} ${name.toLowerCase()}" style="--owner:${owner}" data-matrix="${name}" data-row="${r}" data-col="${c}" aria-label="${name}[${r},${c}] = ${value}" aria-pressed="${active}" title="${name}[${r},${c}]${name==='C'?' · owner PE ('+Math.floor(c/scene.t)+','+Math.floor(r/scene.t)+')':''}">${fmt(value)}</button>`;
  })).join('')}</div>`;
}
function miniMatrix(values:number[][]){return `<div class="mini-matrix" style="--n:${values.length}">${values.flat().map(v=>`<span>${fmt(v)}</span>`).join('')}</div>`;}

function mesh(){
  return `<div class="mesh" style="--p:${scene.p}">${scene.pes.map(p=>`<button class="pe ${p.id===pe().id?'selected':''}" data-pe="${p.id}" aria-pressed="${p.id===pe().id}"><span class="pe-dot dot-${p.y*scene.p+p.x}"></span><strong>PE (${p.x}, ${p.y})</strong><small>C[${p.rows[0]}:${p.rows[1]}, ${p.cols[0]}:${p.cols[1]}]</small><span class="pe-values">${scene.cells.filter(c=>c.pe===p.id).map(c=>fmt(c.expected)).slice(0,4).join(' · ')}${scene.t>2?' …':''}</span><small class="physical">fabric (${p.fabric.join(', ')})</small></button>`).join('')}</div>`;
}

function worksheet(){
  const c=current(),q=term();
  return `<section class="card worksheet"><div class="section-heading"><div><span class="eyebrow">01 / FOLLOW THE NUMBERS</span><h2>C[${i},${j}] is a dot product</h2></div>${badge(`${scene.n} terms · PE (${pe().id})`)}</div>
  <div class="equation"><span class="old">${number(q.old)}</span><span>+</span><span class="a-value">${number(q.a)}</span><span>×</span><span class="b-value">${number(q.b)}</span><span>=</span><span class="result-value">${number(q.acc)}</span></div>
  <div class="equation-captions"><span>previous accumulator</span><span>A[${i},${k}] × B[${k},${j}]</span><span>after k = ${k}</span></div>
  <div class="terms"><table><thead><tr><th>k</th><th>A[${i},k]</th><th>B[k,${j}]</th><th>Product</th><th>Running sum</th><th>Observed sum</th></tr></thead><tbody>${c.terms.map(t=>`<tr class="${t.k===k?'current':''} ${t.k>k?'future':''}" data-term="${t.k}" tabindex="0"><td>${t.k}</td><td class="a-text">${fmt(t.a)}</td><td class="b-text">${fmt(t.b)}</td><td>${fmt(t.product)}</td><td>${fmt(t.acc)}</td><td>${t.observed?`<span class="${t.observed.acc===t.acc?'ok':'bad'}">${fmt(t.observed.acc)} ${t.observed.acc===t.acc?'✓':'≠'}</span>`:'<span class="muted">not captured</span>'}</td></tr>`).join('')}</tbody></table></div>
  <div class="verification-line"><span>Final expected <b>${fmt(c.expected)}</b></span><span>Simulator readback <b class="${c.observed===c.expected?'ok':''}">${fmt(c.observed)}</b></span><span>${c.observed===null?'Reference calculation only':c.observed===c.expected?'Exact match ✓':'Mismatch — inspect the history'}</span></div>
  <details class="predict"><summary>Try the next sum yourself</summary><div><label>After k = ${Math.min(scene.n-1,k+1)} <input id="prediction" type="number" step="any" value="${esc(prediction)}" placeholder="Your prediction" aria-label="Predict the next accumulator"></label><button id="check-answer">Check answer</button><output>${answerShown?(Number(prediction)===c.terms[Math.min(scene.n-1,k+1)].acc&&prediction!==''?'Correct ✓':'Expected '+c.terms[Math.min(scene.n-1,k+1)].acc):''}</output></div></details>
  </section>`;
}

function dataflow(){
  const q=term(),c=current(),obs=q.observed;
  const bound=!!q.binding;
  const stages=[
    ['A operand',`A[${i},${k}]`,`${q.a}`,`${scene.p>1?'A panel':'A'} + ${q.a_offset_bytes} B`,'a'],
    ['B operand',`B[${k},${j}]`,`${q.b}`,`${scene.p>1?'B panel':'B'} + ${q.b_offset_bytes} B`,'b'],
    ['Multiply',`${q.a} × ${q.b}`,`${q.product}`,bound?`execute cycle ${obs!.multiply_cycle}`:'mathematical product','mul'],
    ['Accumulate',`${q.old} + ${q.product}`,`${q.acc}`,bound?`execute cycle ${obs!.add_cycle}`:'expected next value','sum'],
    ['Output',`C[${i},${j}]`,k===scene.n-1?`${q.acc}`:'in progress',`C tile + ${c.c_offset_bytes} B`,'out']
  ];
  const d=bound?scene.dynamic[q.arithmetic_ids![1]]:undefined;
  const asm=d?scene.programs[d.pe]?.assembly[String(d.pc)]?.text:'';
  return `<section class="card dataflow"><div class="section-heading"><div><span class="eyebrow">02 / FUNDAMENTAL DATAFLOW</span><h2>From storage to an updated value</h2></div>${badge(bound?'arithmetic matched to trace':'functional explanation',bound?'green':'')}</div>
  <div class="flow-track">${stages.map((s,ix)=>`<div class="flow-node ${s[4]}"><span class="node-number">${ix+1}</span><span class="eyebrow">${s[0]}</span><strong>${esc(s[1])}</strong><b>${esc(s[2])}</b><small>${esc(s[3])}</small></div>${ix<stages.length-1?'<span class="flow-arrow">→</span>':''}`).join('')}</div>
  <div class="acc-feedback"><span>↶</span> accumulator version k=${k-1}: <b>${fmt(q.old)}</b> → version k=${k}: <b>${fmt(q.acc)}</b></div>
  <div class="resource-detail"><div><span class="eyebrow">ACTUAL ARITHMETIC RESOURCE</span><p class="mono">${asm?esc(asm):'Register assignment not bound to this step'}</p></div><div><span class="eyebrow">OBSERVED CHECKPOINT</span><p>${obs?`Accumulator ${fmt(obs.acc)} · local timer tick ${fmt(obs.sample_tick)}`:'No simulator snapshot loaded'}</p></div></div>
  <p class="note">Arrows show functional dependencies. Offsets are bytes within a buffer; absolute addresses, load timing, forwarding, and physical writeback are not inferred. A math step is not one machine cycle. ${bound?'Multiply/add values match the trace; neighboring instructions below provide context.':'Execution details appear only after a verified capture is linked.'}</p></section>`;
}

function communication(){
  if(scene.p===1)return `<section class="card communication"><span class="eyebrow">03 / DATA PLACEMENT</span><h2>All operands are local</h2><p>The host initializes A and B on application PE (0,0). Its handwritten loop computes all 16 outputs. No application panel broadcast is needed.</p><div class="local-chain"><span>Host A, B</span> → <span>PE SRAM</span> → <span>64 product contributions</span> → <span>Host C</span></div><p class="note">The SDK memcpy runtime still uses support PEs and fabric traffic. These are separate from the single application PE.</p></section>`;
  const panels=scene.panels.filter(v=>v.destination[0]===pe().x&&v.destination[1]===pe().y&&v.round===term().round);
  const round=term().round;
  const tile=Array.from({length:scene.t},(_,r)=>Array.from({length:scene.t},(_,col)=>scene.cells[(pe().y*scene.t+r)*scene.n+pe().x*scene.t+col].terms[(round+1)*scene.t-1].acc));
  return `<section class="card communication"><div class="section-heading"><div><span class="eyebrow">03 / PANELS → LOCAL COMPUTE</span><h2>Round ${round}: k = ${round*scene.t}…${(round+1)*scene.t-1}</h2></div>${badge('output stays on its owner')}</div>
  <div class="panels">${panels.map(v=>`<div class="panel-box ${v.tensor.toLowerCase()}"><div class="panel-route"><b>${v.tensor} panel</b><span>PE (${v.source.join(',')}) ${v.transfer?'→':'='} PE (${v.destination.join(',')})</span></div>${miniMatrix(v.values)}<small>SRAM order: [${v.packed.join(', ')}]</small><small class="${v.observed?'ok':'muted'}">${v.observed?'Received/local panel readback '+(JSON.stringify(v.observed)===JSON.stringify(v.packed)?'matches ✓':'differs ≠'):'Expected panel; no readback'}</small></div>`).join('')}<div class="panel-box c"><div class="panel-route"><b>C tile after round ${round}</b></div>${miniMatrix(tile)}<small>Expected partial result on PE (${pe().id})</small></div></div>
  <div class="local-chain"><span>source SRAM</span> → <span>send / mesh</span> → <span>receive buffer</span> → <span>both panels ready</span> → <span>local multiply + add</span></div>
  <p class="note">Panel routes here describe SUMMA's logical transfers. Packet-to-element associations and queue residence are not assumed. PEs need not start or finish a round simultaneously.</p></section>`;
}

function timeline(insts:Inst[]){
  if(!insts.length)return '<div class="empty-state">No instruction mapping for this contribution. The expected arithmetic remains available.</div>';
  const lo=Math.min(...insts.flatMap(d=>d.dispatch)),hi=Math.max(...insts.flatMap(d=>d.execute.map(e=>e.cycle)),lo+1);
  const span=Math.max(1,hi-lo),width=760;
  return `<div class="timeline"><svg viewBox="0 0 1000 ${insts.length*23+36}" role="img" aria-label="Observed instruction dispatch and execute cycles"><text x="220" y="14" class="svg-muted">${lo}</text><text x="950" y="14" text-anchor="end" class="svg-muted">${hi} cycles</text>${insts.map((d,ix)=>{
    const y=ix*23+32;const pos=(c:number)=>220+(c-lo)/span*width;
    return `<g data-inst="${esc(d.id)}" class="timeline-row"><text x="4" y="${y+3}" class="svg-label">${esc(d.name)} · ${d.pc===null?'?':'0x'+d.pc.toString(16)}</text>${d.dispatch.map(c=>`<rect x="${pos(c)-2}" y="${y-5}" width="4" height="10" fill="#507bd4"/>`).join('')}${d.execute.map(e=>`<circle cx="${pos(e.cycle)}" cy="${y}" r="3" fill="#14866d"/>`).join('')}</g>`;
  }).join('')}</svg></div><p class="note">Blue ticks: dispatch (including redispatch). Green dots: observed execute records. Empty space means no displayed observation, not proven idle time.</p>`;
}

function execution(){
  const q=term(),prog=scene.programs[pe().id],insts=q.instruction_ids.map(id=>scene.dynamic[id]).filter(Boolean);
  const chosen=insts.find(d=>d.id===selectedInst)||insts.find(d=>d.id===q.arithmetic_ids?.[1])||insts[0];
  let content='';
  if(tab==='assembly')content=insts.length?`<div class="instruction-table"><table><thead><tr><th>PC</th><th>Instruction</th><th>Dispatch</th><th>Execute</th><th>Task / µthread</th></tr></thead><tbody>${insts.map(d=>`<tr data-inst="${esc(d.id)}" class="${d.id===chosen?.id?'current':''}"><td>${d.pc===null?'?':'0x'+d.pc.toString(16)}</td><td class="mono">${esc(prog?.assembly[String(d.pc)]?.text||d.name)}</td><td>${d.dispatch.join(', ')}</td><td>${[...new Set(d.execute.map(e=>e.cycle))].join(', ')||'unobserved'}</td><td>${d.task??'—'} / ${d.ut===255?'none':d.ut??'—'}</td></tr>`).join('')}</tbody></table></div>`:'<div class="empty-state">No captured instruction binding for this step.</div>';
  else if(tab==='csl'||tab==='ir')content=`<pre class="source-code">${esc(prog?.[tab]||(tab==='csl'?'Source will appear with a completed capture.':'IR is unavailable for this build.'))}</pre>`;
  else content=timeline(insts);
  let details='';
  if(chosen){
    const vals=chosen.execute.filter(e=>e.dest!==4294967295);
    details=`<details class="raw-details"><summary>Selected instruction: operand bits, source, and raw record references</summary><p class="mono">${esc(prog?.assembly[String(chosen.pc)]?.source||'Source location unavailable')}</p><table><thead><tr><th>Cycle</th><th>Element / lane</th><th>src0</th><th>src1</th><th>dest</th></tr></thead><tbody>${vals.map(e=>`<tr><td>${e.cycle}</td><td>${e.element} / ${e.lane===255?'none':e.lane}</td>${['src0','src1','dest'].map(key=>{const v=e[key as keyof Exec];return `<td>${v===4294967295?'unavailable':`${hex(v)}<small>${fmt(float(v))} as f32</small>`}</td>`;}).join('')}</tr>`).join('')}</tbody></table><p class="note">f32 interpretation is appropriate for FMULS/FADDS; other instructions may encode addresses, integers, or descriptors. Raw JSONL rows: ${chosen.raw_rows.join(', ')}. UID ${chosen.uid} is scoped to PE (${chosen.pe}) and this run.</p></details>`;
  }
  return `<section class="card execution ${mode==='execution'?'focus-section':''}"><div class="section-heading"><div><span class="eyebrow">04 / INSPECT THE EXECUTION</span><h2>What this PE actually executed</h2></div>${badge(scene.trace?`${scene.trace.matched_terms}/${scene.n**3} terms mapped`:'capture unavailable',scene.trace?.binding==='complete'?'green':'')}</div><p class="note">${esc(q.binding||'No verified semantic-to-instruction mapping. A reference calculation has no device cycles.')}</p><div class="tabs" role="tablist">${['assembly','timeline','csl','ir'].map(t=>`<button role="tab" aria-selected="${tab===t}" data-tab="${t}">${t==='ir'?'LLVM IR':t==='csl'?'CSL source':t[0].toUpperCase()+t.slice(1)}</button>`).join('')}</div>${content}${details}</section>`;
}

function evidence(){
  return `<section class="card evidence"><div class="section-heading"><div><span class="eyebrow">05 / VERIFY THE STORY</span><h2>Evidence and capture boundaries</h2></div>${badge(scene.status,scene.verification?.passed?'green':'')}</div>
  <div class="evidence-grid"><div><b>${scene.verification?fmt(scene.verification.checks):'—'}</b><span>numerical comparisons</span></div><div><b>${scene.trace?fmt(scene.trace.counts.wavelet_trace_entry||0):'—'}</b><span>raw wavelet observations, whole run</span></div><div><b>${scene.trace?fmt(scene.trace.discarded):'—'}</b><span>reported discarded events</span></div><div><b>${scene.control?.correct?'matched':'—'}</b><span>history-free control output</span></div></div>
  ${scene.verification&&!scene.verification.passed?`<pre class="bad">${esc(JSON.stringify(scene.verification.mismatches.slice(0,8),null,2))}</pre>`:''}
  <table class="timings"><thead><tr><th>Application PE</th><th>With history (cycles)</th><th>Without history (cycles)</th><th>Ratio</th></tr></thead><tbody>${scene.pes.map(p=>{const control=scene.control?.pes.find(c=>c.id===p.id);return `<tr><td>(${p.id})</td><td>${fmt(p.cycles)}</td><td>${fmt(control?.cycles)}</td><td>${p.cycles&&control?(p.cycles/control.cycles).toFixed(2)+'×':'—'}</td></tr>`;}).join('')}</tbody></table>
  <p class="note">History stores and timestamps change execution. These are separate captures, and each PE duration uses its own local timer. Local timer ticks and simulator trace cycles have different origins. This page does not present silicon timing or reconstruct internal forwarding circuitry.</p>
  ${scene.provenance?`<details><summary>Build identity and retained artifacts</summary><p class="mono">${esc(scene.provenance.run)}</p><p>Compilation: ${esc(scene.provenance.mode)}</p><p class="mono">Manifest SHA-256: ${scene.provenance.manifest_sha256}</p><p class="mono">${esc(scene.provenance.sif.join('\n'))}</p><button id="download-bundle">Download this scene's evidence JSON</button></details>`:'<p class="note">This scene contains an independent reference model only. No measurements have been fabricated.</p>'}
  ${scene.wavelets.length?`<details><summary>Raw application-color fabric observations</summary><p class="note">Application PEs, colors 0/1/4/5, whole capture. Sorted near the selected multiply in trace-cycle space; nearby observations are not claimed as this product's packets. Data is a raw word.</p><table><thead><tr><th>Cycle</th><th>Fabric PE</th><th>Color</th><th>Ident</th><th>Data</th></tr></thead><tbody>${[...scene.wavelets].sort((a,b)=>Math.abs(a.cycle-Number(term().observed?.multiply_cycle||0))-Math.abs(b.cycle-Number(term().observed?.multiply_cycle||0))).slice(0,12).sort((a,b)=>a.cycle-b.cycle).map(w=>`<tr><td>${w.cycle}</td><td>(${w.xy})</td><td>${w.color}</td><td>${w.ident}</td><td>${hex(w.data)}</td></tr>`).join('')}</tbody></table></details>`:''}
  </section>`;
}

function render(){
  const c=current(),q=term();save();
  const expected=Array.from({length:scene.n},(_,r)=>scene.cells.slice(r*scene.n,(r+1)*scene.n).map(c=>c.expected));
  app.innerHTML=`<header class="topbar"><a href="#" class="brand" id="brand"><span class="brand-mark">▦</span> WSE<span class="brand-light"> / FIELD NOTES</span></a><div>${badge('Cerebras WSE-3')}${badge('interactive microbench')}</div><button id="theme" aria-label="Toggle light or dark theme">◐ <span>Theme</span></button></header>
  <main><div class="intro"><div><p class="eyebrow">GEMM / FROM FIRST PRINCIPLES</p><h1>${titles[scene.id]}</h1><p class="subtitle">${subtitle[scene.id]}</p></div><div class="intro-evidence">${badge(scene.status,scene.verification?.passed?'green':'')}<span>${scene.verification?`${scene.n**3} product contributions · ${scene.n**2} ${scene.verification.passed?'verified':'checked'} outputs`:'Expected values · no device capture'}</span></div></div>
  <nav class="scene-nav" aria-label="Microbench selection">${bundle.scenes.map((s,ix)=>`<button data-scene="${s.id}" class="${scene.id===s.id?'selected':''}"><span class="scene-number">0${ix+1}</span><span><b>${s.n} × ${s.n} GEMM</b><small>${s.p*s.p} application PE${s.p>1?'s · '+s.t+' × '+s.t+' tiles':''}</small></span><span class="scene-status ${s.verification?.passed?'ok':''}">${s.verification?.passed?'✓':'○'}</span></button>`).join('')}</nav>
  <section class="matrices card"><div class="section-heading"><div><span class="eyebrow">THE WORKLOAD</span><h2>Pick a number. Follow its calculation.</h2></div><label class="bit-toggle"><input id="bits" type="checkbox" ${showBits?'checked':''}> show f32 bits</label></div>
  <div class="matrix-equation"><div class="matrix-block"><div class="matrix-title"><span class="matrix-letter a-text">A</span><span>row ${i} highlighted</span></div>${matrix('A',scene.a)}</div><span class="matrix-op">×</span><div class="matrix-block"><div class="matrix-title"><span class="matrix-letter b-text">B</span><span>column ${j} highlighted</span></div>${matrix('B',scene.b)}</div><span class="matrix-op">=</span><div class="matrix-block"><div class="matrix-title"><span class="matrix-letter c-text">C</span><span>expected final outputs</span></div>${matrix('C',expected)}</div></div><p class="matrix-hint">Click C to choose an output. Click A or B to choose an operand. Indices are zero-based.</p></section>
  <div class="workbench"><div class="primary-column"><div class="transport card"><div class="mode-switch"><button data-mode="math" class="${mode==='math'?'selected':''}">Work through the math</button><button data-mode="execution" class="${mode==='execution'?'selected':''}">Inspect execution</button></div><div class="step-controls"><button id="prev" aria-label="Previous product" ${k===0?'disabled':''}>←</button><button id="play" aria-label="${playing?'Pause':'Play'} products">${playing?'Ⅱ':'▶'}</button><button id="next" aria-label="Next product" ${k===scene.n-1?'disabled':''}>→</button><label>k <input id="step" type="range" min="0" max="${scene.n-1}" value="${k}" aria-label="Product index"></label><b>${k+1} / ${scene.n}</b><button id="round">Round end</button></div></div>${worksheet()}${dataflow()}${communication()}${execution()}${evidence()}</div>
  <aside><section class="card ownership"><span class="eyebrow">WHERE IT HAPPENS</span><h2>The application mesh</h2><p>Columns → x · rows ↓ y</p>${mesh()}<div class="owner-callout">C[${i},${j}] belongs to <strong>PE (${pe().id})</strong><small>Local entry (${c.local.join(', ')}) · offset ${c.c_offset_bytes} bytes</small></div><p class="note">${esc(scene.storage)}. ${esc(pe().placement_evidence)}. Support PEs are not drawn in this application-only map.</p></section>
  <section class="card guide"><span class="eyebrow">A SHORT WALKTHROUGH</span><h3>Read it like a notebook</h3><ol><li>Choose one output in C.</li><li>Step through its ${scene.n} products.</li><li>Watch the running sum change.</li><li>Follow operands through the dataflow.</li><li>${scene.p>1?'Inspect which PE sends each panel.':'Inspect the loads and arithmetic.'}</li><li>Compare the result with readback.</li></ol><button id="example">${scene.p>1?'Follow C[2,2] across PEs':'Start with C[0,0]'}</button><div class="selection-note"><span>Selected contribution</span><b>(${i}, ${j}, ${k})</b><small>Round ${q.round} · product ${fmt(q.product)}</small></div></section></aside></div>
  <footer>WSE-3 workload study / xkernel <span>Reference math · compiled programs · simulator observations</span></footer></main>`;
  bind();
}

function bind(){
  const on=(selector:string,fn:(el:HTMLElement)=>void)=>document.querySelectorAll<HTMLElement>(selector).forEach(el=>el.onclick=()=>fn(el));
  on('[data-scene]',el=>{stop();scene=bundle.scenes.find(s=>s.id===el.dataset.scene)!;i=j=k=0;selectedInst='';render();});
  on('[data-matrix]',el=>{stop();const r=Number(el.dataset.row),c=Number(el.dataset.col);if(el.dataset.matrix==='A'){i=r;k=c;}else if(el.dataset.matrix==='B'){k=r;j=c;}else{i=r;j=c;}selectedInst='';answerShown=false;render();});
  on('[data-pe]',el=>{const [x,y]=el.dataset.pe!.split(',').map(Number);i=y*scene.t;j=x*scene.t;selectedInst='';render();});
  on('[data-term]',el=>{k=Number(el.dataset.term);selectedInst='';render();});
  document.querySelectorAll<HTMLElement>('[data-term]').forEach(el=>el.onkeydown=e=>{if(e.key==='Enter'||e.key===' '){e.preventDefault();el.click();}});
  on('[data-mode]',el=>{mode=el.dataset.mode!;render();if(mode==='execution')document.querySelector('.execution')?.scrollIntoView({behavior:'smooth',block:'start'});});
  on('[data-tab]',el=>{tab=el.dataset.tab!;render();});
  on('[data-inst]',el=>{selectedInst=el.dataset.inst!;const y=scrollY;render();window.scrollTo(0,y);});
  on('#prev',()=>move(-1));on('#next',()=>move(1));
  on('#play',()=>{if(playing){stop();render();return;}if(k===scene.n-1)k=0;playing=window.setInterval(()=>{if(k===scene.n-1){stop();render();}else move(1);},1100);render();});
  on('#round',()=>{k=Math.min(scene.n-1,(term().round+1)*scene.t-1);render();});
  const slider=document.querySelector<HTMLInputElement>('#step')!;slider.oninput=()=>{k=Number(slider.value);selectedInst='';render();};
  const bit=document.querySelector<HTMLInputElement>('#bits')!;bit.onchange=()=>{showBits=bit.checked;render();};
  const pred=document.querySelector<HTMLInputElement>('#prediction')!;pred.oninput=()=>{prediction=pred.value;};
  on('#check-answer',()=>{prediction=pred.value;answerShown=true;render();document.querySelector<HTMLDetailsElement>('.predict')!.open=true;});
  on('#example',()=>{i=j=scene.p>1?2:0;k=0;selectedInst='';render();document.querySelector('.worksheet')?.scrollIntoView({behavior:'smooth',block:'center'});});
  on('#theme',()=>{const theme=document.documentElement.dataset.theme==='dark'?'light':'dark';document.documentElement.dataset.theme=theme;try{localStorage.setItem('gemm-theme',theme);}catch{}});
  on('#download-bundle',()=>{const blob=new Blob([JSON.stringify({schema:bundle.schema,scenes:[scene]},null,2)],{type:'application/json'});const url=URL.createObjectURL(blob);const a=document.createElement('a');a.href=url;a.download=scene.id+'-evidence.json';a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);});
  document.querySelector<HTMLAnchorElement>('#brand')!.onclick=e=>{e.preventDefault();window.scrollTo({top:0,behavior:'smooth'});};
}

async function init(){
  try{
    bundle=window.GEMM_BUNDLE||await fetch('./bundle.json').then(r=>{if(!r.ok)throw Error('Run study.py viz-export --out viewer/public, then build the viewer.');return r.json();});
    if(bundle.schema!=='gemm-viz/1'||!bundle.scenes.length)throw Error('Unsupported or empty GEMM bundle');
    const s=new URLSearchParams(location.hash.slice(1));scene=bundle.scenes.find(x=>x.id===s.get('scene'))||bundle.scenes[0];
    const index=(key:string)=>Math.max(0,Math.min(scene.n-1,Math.floor(Number(s.get(key)))||0));i=index('i');j=index('j');k=index('k');
    mode=s.get('mode')==='execution'?'execution':'math';tab=['assembly','timeline','csl','ir'].includes(s.get('tab')||'')?s.get('tab')!:'assembly';
    try{document.documentElement.dataset.theme=localStorage.getItem('gemm-theme')||'light';}catch{}
    render();
    window.addEventListener('keydown',e=>{if((e.target as HTMLElement).matches('input,textarea,select'))return;if(e.key==='ArrowRight'){e.preventDefault();move(1);}if(e.key==='ArrowLeft'){e.preventDefault();move(-1);}});
  }catch(e){app.innerHTML=`<div class="load-error"><h1>Could not load the walkthrough</h1><p>${esc(e)}</p><p>Open the portable gemm.html file, or serve the built viewer with its bundle.json.</p></div>`;}
}
void init();
