import {DataflowGL,type Card,type Edge} from './dataflow-gl';
import {matrix,matrixBoard,palette,escapeHTML as esc,type Values} from './matmul-matrices';
type PE={id:string;x:number;y:number;samples:number[];features:number[];outputs:number[];activation:number[][]};
type Flow={source:string;destination:string;kind:string;values:number[];local?:number[];result?:number[]};
type Calc={pe:string;samples:number[];activation:number[];before:number[];products:number[];after:number[]};
type Step={phase:string;title:string;description:string;partial:Record<string,number[]>;output:Values;cycle:null;o?:number;k?:number;weight?:number;owner?:number;calculations:Calc[];flows:Flow[];reduced?:Record<string,number[]>};
export type StreamingModel={X:number[][];W:number[][];reference:number[][];pes:PE[];steps:Step[];limits:string[];sources:{title:string;url:string}[];verification:{nonzero_weights:number;modeled_products:number}};
const vec=(a:(number|null)[])=>'['+a.map(x=>x??'·').join(', ')+']';
const col=(a:number[])=>a.map(x=>[x]);

export class StreamingLesson{
 index=0;selected='0,0';timer:number|undefined;mesh?:DataflowGL;core?:DataflowGL;
 constructor(public root:HTMLElement,public model:StreamingModel){
  root.innerHTML=`<div class="intro"><div><p class="eyebrow">MEMORYX → COLUMN BROADCAST → LOCAL AXPY → ROW REDUCTION</p><h1>Where does every number live?</h1><p>Activation-stationary weight streaming, reconstructed from the official architecture explanation. Same numbers as the captured 4 × 4 GEMM; a different PE mapping.</p></div><div class="stream-badge">Documented model<br><small>Numeric reconstruction · no cycle claim</small></div></div>
  <div class="stream-scope"><b>Generation matters.</b> The 2022 slides describe WSE-2. The WSE-3 core is documented in 2024 with 48 KB SRAM, a 512 B local cache and eight 16-bit lanes. This lesson does not reveal the cache contents of our SDK captures.</div>
  <section class="workspace stream-workspace"><div class="stage"><div class="stage-top"><div><b id="stream-title"></b><span id="stream-position"></span></div><button id="stream-reset-camera">Reset cameras</button></div>
  <div id="stream-matrices"></div><p class="lesson-description">X is sample × input feature. W is output feature × input feature: <b>Y = XWᵀ</b>. Here X = captured A and W = captured Bᵀ. Dots mean outputs have not yet been finalized.</p>
  <div class="debug-controls"><button id="stream-back">← Step</button><button id="stream-next">Step →</button><button id="stream-play">▶ Replay</button><input id="stream-scrub" type="range" min="0" max="${model.steps.length-1}" value="0" aria-label="Weight streaming step"></div>
  <div class="stream-jumps"><label>Go to dependency step<select id="stream-jump">${model.steps.map((s,i)=>`<option value="${i}">${i+1} · ${esc(s.title)}</option>`).join('')}</select></label><button id="stream-next-reduction">Next reduction</button><button id="stream-final">Final output</button></div>
  <p id="stream-description" class="lesson-description" aria-live="polite"></p>
  <div class="stream-key"><span style="color:${palette.a}">■ activation SRAM</span><span style="color:${palette.b}">↓ streamed weight</span><span style="color:${palette.p}">→ partial reduction</span><span style="color:${palette.c}">■ final output SRAM</span></div>
  <div class="stream-canvas-wrap"><canvas id="stream-mesh" aria-label="WebGL weight broadcasts and partial-sum row reductions"></canvas></div>
  <p class="lesson-description">PE coordinates are logical. Columns partition input features k; rows partition samples b. Click a PE to inspect it. Arrows show this step only; ingress placement is illustrative.</p>
  <div id="stream-equations" class="stream-equations"></div>
  <details class="datapath" open><summary>Inside the selected PE · conceptual operand path</summary><canvas id="stream-core" aria-label="WebGL local SRAM, transient weight, accumulator and arithmetic paths"></canvas></details>
  <p class="lesson-description">DSRs describe addresses, strides and lengths; they do not hold the activation tensor. Arrow geometry expresses dependencies, not measured pipeline stages or physical floorplan.</p></div>
  <aside><div class="loop-panel"><p class="eyebrow">SELECT PE · INSPECT RESIDENCY</p><div class="stream-pe-select">${model.pes.map(p=>`<button data-stream-pe="${p.id}">(${p.id})</button>`).join('')}</div></div><div id="stream-inspector"></div><div id="stream-history"></div></aside></section>
  <section class="comparison"><p class="eyebrow">ONE CHIP · DIFFERENT ALGORITHMS</p><h2>Stationary depends on the workload</h2><div class="packet-table"><table><thead><tr><th>Implementation / evidence</th><th>Local resident arrays</th><th>Data crossing PE links</th><th>Accumulation / output</th></tr></thead><tbody>
  <tr><td>HC2022 weight streaming<br>Documented model shown above</td><td>Activation slices; no full local weight array</td><td>Indexed weights along columns; partial sums across rows</td><td>Local partial vectors; row reduction; final feature slices in SRAM</td></tr>
  <tr><td>Our small SUMMA-like GEMM<br>Captured WSE-3 simulator</td><td>A, B and C tiles; abuf / bbuf for remote panels</td><td>A panels along rows; B panels along columns</td><td>C stays on its owner; no inter-PE C reduction</td></tr>
  <tr><td>WaferLLM MeshGEMM<br>Source + bounded fabric profile</td><td>Double-buffered X / W tiles; C tile</td><td>X shifts horizontally, W vertically on folded rings</td><td>Output-stationary Cannon; no inter-PE C reduction</td></tr>
  <tr><td>HC2024 inference<br>Vendor architecture presentation</td><td>Weights and KV in wafer regions</td><td>Activations between layer regions</td><td>Distinct from the training weight-streaming mapping</td></tr></tbody></table></div>
  <div class="stream-capture"><h3>What the captured small GEMM establishes</h3><p>Owner A/B SRAM → fabric send → router / input queue → remote abuf/bbuf SRAM → scalar GPR operands → FMULS / FADDS → C SRAM. The teaching kernel uses f32 scalar arithmetic and stores C after each term. Panel owners use their original arrays directly. The mesh tab binds actual packet values to send, receive and consumer instructions.</p><button id="stream-open-capture">Open captured mesh GEMM / GEMV →</button><p>SRAM-backed arrays are established by source and ELF / IR audits. We do not infer a cache hit, bank selection, or simultaneous SRAM snapshot from an operand trace.</p></div></section>
  <details class="evidence" open><summary>Sources, verification and modeling boundaries</summary><p id="stream-validation">16 output cells match both independent multiplication and captured g1 readback. ${model.verification.nonzero_weights} nonzero weights produce ${model.verification.modeled_products} modeled scalar products; skipped zero terms are mathematically exact. These counts are not a throughput measurement.</p><ul>${model.limits.map(s=>`<li>${esc(s)}</li>`).join('')}</ul>${model.sources.map(s=>`<p><a href="${esc(s.url)}" target="_blank" rel="noreferrer">${esc(s.title)} ↗</a></p>`).join('')}</details>`;
  this.q('#stream-back').onclick=()=>this.go(this.index-1);this.q('#stream-next').onclick=()=>this.go(this.index+1);
  this.q<HTMLInputElement>('#stream-scrub').oninput=e=>this.go(+(e.target as HTMLInputElement).value);
  this.q<HTMLSelectElement>('#stream-jump').onchange=e=>this.go(+(e.target as HTMLSelectElement).value);
  this.q('#stream-final').onclick=()=>this.go(model.steps.length-1);
  this.q('#stream-next-reduction').onclick=()=>{const i=model.steps.findIndex((s,i)=>i>this.index&&s.phase==='reduce');if(i>=0)this.go(i);};
  this.q('#stream-play').onclick=()=>{if(this.timer){this.stop();return;}this.q('#stream-play').textContent='Ⅱ Pause';this.timer=window.setInterval(()=>{if(this.index===model.steps.length-1)this.stop();else{this.index++;this.render();}},1300);};
  this.q('#stream-reset-camera').onclick=()=>{for(const gl of [this.mesh,this.core])if(gl){gl.reset();gl.yaw=gl.tilt=0;gl.draw();}};
  this.q('#stream-open-capture').onclick=()=>document.querySelector<HTMLButtonElement>('#view-mesh')!.click();
  root.querySelectorAll<HTMLButtonElement>('[data-stream-pe]').forEach(b=>b.onclick=()=>{this.selected=b.dataset.streamPe!;this.render();});
  document.addEventListener('keydown',e=>{if(root.hidden||['INPUT','SELECT','BUTTON','TEXTAREA'].includes((e.target as HTMLElement).tagName))return;if(['ArrowLeft','ArrowRight'].includes(e.key)){e.preventDefault();this.go(this.index+(e.key==='ArrowRight'?1:-1));}});
 }
 q<T extends HTMLElement=HTMLElement>(s:string){return this.root.querySelector<T>(s)!;}
 stop(){clearInterval(this.timer);this.timer=undefined;this.q('#stream-play').textContent='▶ Replay';}
 go(i:number){this.stop();this.index=Math.max(0,Math.min(this.model.steps.length-1,i));this.render();}
 render(){
  const m=this.model,s=m.steps[this.index],pe=m.pes.find(p=>p.id===this.selected)!,calc=s.calculations.find(c=>c.pe===pe.id);
  this.q('#stream-title').textContent=s.title;this.q('#stream-position').textContent=`Dependency step ${this.index+1} / ${m.steps.length} · ${s.phase} · illustrative, untimed`;
  this.q<HTMLInputElement>('#stream-scrub').value=String(this.index);this.q<HTMLSelectElement>('#stream-jump').value=String(this.index);
  this.q<HTMLButtonElement>('#stream-back').disabled=this.index===0;this.q<HTMLButtonElement>('#stream-next').disabled=this.index===m.steps.length-1;
  this.q<HTMLButtonElement>('#stream-next-reduction').disabled=!m.steps.slice(this.index+1).some(s=>s.phase==='reduce');
  this.q('#stream-description').textContent=s.description;
  const prev=m.steps[Math.max(0,this.index-1)].output,delta=s.output.map((r,i)=>r.map((v,j)=>v===null?0:v-(prev[i][j]??0))),active=s.k!==undefined&&s.phase!=='skip';
  this.q('#stream-matrices').innerHTML=matrixBoard(m.X,m.W,s.output,delta,{names:['X · activation','W · off-wafer weight','Y · finalized'],a:{block:2,active:active?m.X.map((_,i)=>`${i},${s.k}`):[]},b:{block:2,active:s.k!==undefined?[`${s.o},${s.k}`]:[]},c:{block:2,done:s.output.flatMap((r,i)=>r.flatMap((v,j)=>v===null?[]:[`${i},${j}`]))},note:'ΔY records final SRAM placement. Local partial changes appear on the PE cards and in the inspector.'});
  this.root.querySelectorAll<HTMLElement>('[data-stream-pe]').forEach(b=>b.setAttribute('aria-pressed',String(b.dataset.streamPe===pe.id)));
  const transient=['broadcast','axpy'].includes(s.phase)&&Math.floor(s.k!/2)===pe.x;
  const own=s.output.slice(pe.y*2,pe.y*2+2).map(r=>r.slice(pe.x*2,pe.x*2+2));
  this.q('#stream-inspector').innerHTML=`<div class="loop-panel"><p class="eyebrow">PE (${pe.id}) · LOGICAL COORDINATES</p><h3>Resident input slice</h3><p>Samples b = ${vec(pe.samples)}<br>Input features k = ${vec(pe.features)}</p>${matrix(this.index?pe.activation:pe.activation.map(r=>r.map(()=>null)),palette.a,{label:'Resident activation slice'})}<p>${this.index?'Local SRAM · retained through all four output features':'Placement pending; global inputs remain visible above'}</p><h4>Transient weight operand</h4><pre>${transient?`W[${s.o},${s.k}] = ${s.weight}\nindex k=${s.k} → local column ${s.k!%2}`:'No active weight at this PE in this step'}</pre><h4>Local partial vector · output feature ${s.o??'—'}</h4><div class="stream-vector">${matrix(col(s.partial[pe.id]),palette.p,{label:'Local partial vector'})}</div><p>Algorithm state. Official model uses a software-managed accumulator cache; our WSE-3 runs do not expose its contents.</p>${s.reduced?.[pe.id]?`<h4>After row reduction</h4><pre>${vec(s.reduced[pe.id])}</pre>`:''}<h4>Final output slice in SRAM</h4><p>Output features o = ${vec(pe.outputs)}</p>${matrix(own,palette.c,{label:'Owned output slice'})}<p>${s.phase==='complete'?'PASS · exact match to captured g1 output':'Dots mark values not finalized yet.'}</p></div>`;
  this.q('#stream-equations').innerHTML=s.calculations.length?s.calculations.map(c=>`<p><b>PE (${c.pe})</b> ${vec(c.before)} + ${vec(c.activation)} × ${s.weight} = <b>${vec(c.after)}</b></p>`).join(''):s.flows.length?s.flows.map(f=>`<p><b>${f.source==='MemoryX'?'MemoryX':'PE ('+f.source+')'} → PE (${f.destination})</b> ${f.kind==='partial'?`${vec(f.local!)} + incoming ${vec(f.values)} = <b>${vec(f.result!)}</b>`:`weight ${vec(f.values)} · k=${s.k}`}</p>`).join(''):`<p>${s.phase==='skip'?'Zero coefficient: no injected weight and no AXPY.':s.phase==='complete'?'All 16 outputs agree with both reference computations.':'No tensor transfer in this dependency step.'}</p>`;
  this.q('#stream-history').innerHTML=`<div class="loop-panel"><p class="eyebrow">RECENT DEPENDENCY SLICES · PE (${pe.id})</p><p>The input slice above remains resident. These are mathematical states, not cycle snapshots.</p><div class="packet-table"><table><thead><tr><th>Step</th><th>Local partial</th><th>Weight</th></tr></thead><tbody>${m.steps.slice(Math.max(0,this.index-3),this.index+1).map((st,j)=>`<tr><td>${Math.max(0,this.index-3)+j+1}<br>${st.phase}</td><td>${vec(st.partial[pe.id])}</td><td>${['broadcast','axpy'].includes(st.phase)&&Math.floor(st.k!/2)===pe.x?st.weight:'—'}</td></tr>`).join('')}</tbody></table></div></div>`;
  if(!this.mesh){try{this.mesh=new DataflowGL(this.q('#stream-mesh'),true);this.core=new DataflowGL(this.q('#stream-core'),true);for(const gl of [this.mesh,this.core])gl.yaw=gl.tilt=0;new ResizeObserver(()=>{this.drawMesh(this.model.steps[this.index]);this.drawCore(this.model.steps[this.index],this.model.pes.find(p=>p.id===this.selected)!,this.model.steps[this.index].calculations.find(c=>c.pe===this.selected));}).observe(this.q('#stream-mesh'));this.mesh.onPick=id=>{if(id.startsWith('pe:')){this.selected=id.slice(3);this.render();}};}catch(e){this.q('#stream-description').textContent+=' '+String(e);return;}}
  this.drawMesh(s);this.drawCore(s,pe,calc);
 }
 drawMesh(s:Step){
  const cards:Card[]=[],edges:Edge[]=[];
  const pos=(id:string):[number,number,number]=>{const [x,y]=id.split(',').map(Number);return [x?4.4:-4.4,y?-3.1:3.1,0];};
  cards.push({id:'memoryx',at:[0,8.3,0],width:14,height:1.65,lines:['MEMORYX · OFF-WAFER WEIGHTS',s.o===undefined?'W rows stream one output feature at a time':`W[${s.o},:] = ${vec(this.model.W[s.o])}   ${s.k===undefined?'':`selected k=${s.k}, weight=${s.weight}`}`],color:palette.b});
  for(const pe of this.model.pes){const at=pos(pe.id),p=s.partial[pe.id];cards.push({id:'pe:'+pe.id,at,width:6.3,height:3.8,color:pe.id===this.selected?'#253044':palette.a,active:pe.id===this.selected,lines:[`PE (${pe.id}) · b=${pe.samples.join(',')} / k=${pe.features.join(',')}`],matrix:{values:this.index?pe.activation:pe.activation.map(r=>r.map(()=>null)),rows:pe.samples,cols:pe.features,focus:s.phase==='axpy'&&Math.floor(s.k!/2)===pe.x?{rows:pe.samples,cols:[s.k!]}:undefined}});cards.push({id:'pe:'+pe.id,at:[at[0],at[1]-2.5,0],width:6.3,height:.85,lines:[`local p = ${vec(p)}`],color:palette.p});}
  for(const f of s.flows){const dest=pos(f.destination);if(f.kind==='weight'){
    const x=dest[0],lane=x+(x<0?-3.65:3.65),start=f.source==='MemoryX'?[x,7.44,0] as [number,number,number]:[lane,3.1,0] as [number,number,number];
    // Weight spine stays outside PE cards; short branches enter their edges.
    edges.push({from:start,to:[x+(x<0?-3.22:3.22),dest[1],0],via:f.source==='MemoryX'?[[lane,7.44,0],[lane,dest[1],0]]:[[lane,dest[1],0]],color:palette.b,width:.06});
   }else{const src=pos(f.source),direction=dest[0]>src[0]?1:-1;edges.push({from:[src[0]+3.22*direction,src[1],0],to:[dest[0]-3.22*direction,dest[1],0],color:palette.p,width:.09});}}
  cards.push({id:'stage',at:[0,-7.1,0],width:14,height:1.4,lines:[s.phase==='reduce'?'HORIZONTAL REDUCTION · two K partitions become a final sum':s.phase==='complete'?'OUTPUT SRAM · ready for the next layer':'VERTICAL BROADCAST · one weight reused across sample rows',s.phase==='reduce'?s.flows.map(f=>`${f.destination}: ${vec(f.result!)}`).join('   '):'PE cards show stationary X and local partial p, not a replicated weight matrix'],color:s.phase==='reduce'?palette.p:palette.c});
  this.mesh!.setScene({cards,edges},Math.max(10,9.7*this.mesh!.canvas.clientWidth/this.mesh!.canvas.clientHeight));
 }
 drawCore(s:Step,pe:PE,calc?:Calc){
  const active=['broadcast','axpy'].includes(s.phase)&&Math.floor(s.k!/2)===pe.x;
  const cards:Card[]=[],edges:Edge[]=[];
  const add=(id:string,x:number,y:number,w:number,h:number,lines:string[],color:string)=>cards.push({id,at:[x,y,0],width:w,height:h,lines,color});
  add('weight',-6,4.8,5.2,1.7,['FABRIC → INPUT QUEUE',active?`indexed weight (${s.k}, ${s.weight})`:'no active weight'],palette.b);
  add('sram',0,4.8,5.2,1.7,['ACTIVATION SRAM',calc?`X[:,${s.k}] = ${vec(calc.activation)}`:`resident X = ${pe.activation.flat().join(', ')}`],palette.a);
  add('partial',6,4.8,5.2,1.7,['LOCAL PARTIAL · SW CACHE',`p = ${vec(s.partial[pe.id])}`],palette.p);
  add('scalar',-6,1.4,5.2,1.6,['TRANSIENT SCALAR',active?`w = ${s.weight} · no W array`:'weight operand path'],palette.b);
  add('dsr',0,1.4,5.2,1.6,['DSR-CONTROLLED READ','column selection / stride / length'],palette.a);
  add('alu',0,-2.2,5.6,1.9,['VECTOR FMAC / AXPY',calc?`${vec(calc.before)} + ${vec(calc.activation)} × ${s.weight}`:'p ← p + X column × weight'],palette.p);
  add('reduce',6,-2.2,5.2,1.9,['PSUM / FSUM → ROW FABRIC',s.reduced?.[pe.id]?`combined = ${vec(s.reduced[pe.id])}`:'after local K contributions'],palette.p);
  add('out',6,-5.5,5.2,1.6,['FINAL OUTPUT → SRAM',`owner features ${vec(pe.outputs)}`],palette.c);
  const edge=(from:Edge['from'],to:Edge['to'],color:string,via?:Edge['via'])=>edges.push({from,to,color,via,width:.055});
  edge([-6,3.9,0],[-6,2.25,0],palette.b);edge([0,3.9,0],[0,2.25,0],palette.a);edge([0,.5,0],[0,-1.2,0],palette.a);
  edge([-6,.5,0],[-2.9,-2.2,0],palette.b,[[-6,-2.2,0]]);
  edge([3.3,4.8,0],[1.8,-1.2,0],palette.p,[[2.9,4.8,0],[2.9,-.6,0],[1.8,-.6,0]]);
  edge([0,-3.2,0],[6,5.7,0],palette.p,[[0,-4.15,0],[9.5,-4.15,0],[9.5,6.3,0],[6,6.3,0]]);
  edge([6,3.9,0],[6,-1.2,0],palette.p);edge([6,-3.2,0],[6,-4.65,0],palette.c);
  this.core!.setScene({cards,edges},Math.max(10.5,7.1*this.core!.canvas.clientWidth/this.core!.canvas.clientHeight));
 }
}
