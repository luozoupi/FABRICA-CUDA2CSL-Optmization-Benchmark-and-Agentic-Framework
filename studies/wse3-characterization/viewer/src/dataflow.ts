import './dataflow.css';
import {DataflowGL,type Card,type V3,type Edge} from './dataflow-gl';
import {stateAt,eventText,type Scene,type NumericEvent,type PE} from './time-model';
import {layerInputs} from './layer-inputs';
import {streamingScene,rows,type Teaching,tensorColor} from './streaming-view';
type Packet={id:string;source:string;destination:string;kind:string;label:string;slot:number;value:number;word:number;color:number;observations:{cycle:number;row:number;pe:string;xy:number[];link:string}[];send?:{cycle:number;row:number};receive?:{cycle:number;row:number};consumer?:{cycle:number;row:number;equation:string};send_instruction?:string;receive_instruction?:string};
export type FlowScene=Scene&{teaching:Teaching;host:{inputs:{name:string;rows:number;cols:number;values:number[][]}[];output:number[][];output_name:string;note:string};storage:{pe:string;arrays:{name:string;elf_address:number;elf_address_hex:string;bytes:number;storage:string}[]}[];packets:Packet[];limits:string[];sources:{path:string;sha256:string}[]};
type SnapPhase={values:Record<string,number[]>;sram:Record<string,number[]>;gpr_u16:Record<string,number[]>;symbols:Record<string,{byte_address:number}>;registers:Record<string,string[]>;passed:boolean;evidence:string};
type Snapshots={note:string;cases:{id:string;title:string;phases:Record<string,SnapPhase>;sources:{path:string;sha256:string}[]}[]};
type Bundle={schema:string;scenes:FlowScene[];snapshots?:Snapshots};
declare global{interface Window{DATAFLOW_BUNDLE?:Bundle}}
const app=document.querySelector<HTMLDivElement>('#app')!;
const esc=(s:unknown)=>String(s).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]!));
const fmt=(n:number|null|undefined)=>n==null?'?':Number.isInteger(n)?String(n):n.toPrecision(5);
const list=(a:(number|null)[])=>'['+a.map(fmt).join(', ')+']';
const palette={input:'#78d5e7',compute:'#fec77a',packet:'#baabff',output:'#90e0b1',muted:'#668198'};
const chapters=['Host inputs','Load into WSE','Inputs in SRAM','Local arithmetic','PE → PE','Results on PEs','Host output'];
let s:FlowScene,catalog:{id:string;title:string}[]=[],offline:Bundle|undefined,api=false,gl:DataflowGL;
let chapter=0,cycle=0,peID='0,0',output=0,packetIndex=0,view='streaming',playing:number|undefined;
let teachingIndex=0,teachingCell=0,teachingPlaying:number|undefined;
let inputFocus:{name:string;row:number;col:number}|null=null,requestVersion=0;
let snapshots:Snapshots|undefined,lab:DataflowGL|undefined,labIndex=0,labPE='0,0';
const pe=()=>s.pes.find(p=>p.id===peID)!;
const selectedPacket=()=>s.packets[packetIndex];
const matrixLines=(name:string,values:number[][])=>[name,...values.map(r=>r.map(fmt).join('  '))];
function save(){history.replaceState(null,'','#'+new URLSearchParams({scene:s.id,chapter:String(chapter),cycle:String(cycle),pe:peID,output:String(output),packet:String(packetIndex),view,step:String(teachingIndex),cell:String(teachingCell)}));}
function stopTeaching(){clearInterval(teachingPlaying);teachingPlaying=undefined;const b=document.querySelector('#teaching-play');if(b)b.textContent='▶ Auto step';}
function setTeaching(index:number){stop();view='streaming';teachingIndex=Math.max(0,Math.min(s.teaching.steps.length-1,index));const step=s.teaching.steps[teachingIndex];chapter=step.chapter;if(step.pe)peID=step.pe;render();}
function stop(){clearInterval(playing);playing=undefined;const b=document.querySelector('#play');if(b)b.textContent='▶ Play observations';}
function sampleCycle(){
  if(chapter===3){const e=s.events.find(e=>e.pe===peID&&e.kind==='accumulate');return e?.cycle??s.start;}
  if(chapter===4)return selectedPacket()?.observations[0]?.cycle??s.start;
  return chapter>=5?s.end:s.start;
}
function table(values:number[][],name:string,clickable='input'){
  return `<table class="numbers" aria-label="${name} values"><thead><tr><th>${name}</th>${values[0].map((_,j)=>`<th>${j}</th>`).join('')}</tr></thead><tbody>${values.map((r,i)=>`<tr><th>${i}</th>${r.map((v,j)=>`<td><button data-${clickable}="${name}|${i}|${j}" class="${inputFocus?.name===name&&inputFocus.row===i&&inputFocus.col===j?'chosen':''}" aria-label="${name}[${i},${j}] = ${v}">${fmt(v)}</button></td>`).join('')}</tr>`).join('')}</tbody></table>`;
}
function outputOwner(){return s.kind==='gemm'?`${Math.floor((output%s.n)/s.t)},${Math.floor(Math.floor(output/s.n)/s.t)}`:`${Math.floor(output/s.t)},${s.p-1}`;}
function matchesOutput(e:NumericEvent){return s.kind==='gemm'?e.i===Math.floor(output/s.n)&&e.j===output%s.n:e.kind==='reduce'?e.index===output%s.t&&s.pes.find(p=>p.id===e.pe)?.x===Math.floor(output/s.t):e.j===output;}
function inputOwners(){if(!inputFocus)return [];
  return s.pes.filter(p=>p.input_tiles?.some(t=>t.tensor===inputFocus!.name&&t.rows.includes(inputFocus!.row)&&t.cols.includes(inputFocus!.col))).map(p=>p.id);
}
function inputUses(){if(!inputFocus)return [];
  const {name,row,col}=inputFocus;
  return s.events.filter(e=>e.kind==='multiply'&&(name==='A'?e.i===row&&e.k===col:name==='B'?e.k===row&&e.j===col:name==='W'?e.k===row&&e.j===col:e.k===col));
}
function scaffold(){
  app.innerHTML=`<header class="top"><a class="brand" href="dataflow.html"><span class="logo">W</span> WSE-3 <span>/ DATAFLOW LAB</span></a><span id="connection"></span><a href="https://cerebras-sdk-docs-140.netlify.app/tensor-streaming" target="_blank" rel="noreferrer">Architecture reference ↗</a></header>
  <main><div class="intro"><div><p class="eyebrow">FROM HOST MEMORY TO THE MESH AND BACK</p><h1>Follow the numbers.</h1><p>Inspect every input tile, arithmetic observation and matched PE transfer.</p></div><label>Captured workload<select id="scene">${catalog.map(c=>`<option value="${c.id}">${c.title}</option>`).join('')}</select></label></div>
  <nav class="chapters" aria-label="Dataflow chapters">${chapters.map((name,i)=>`<button data-chapter="${i}"><small>0${i+1}</small>${name}</button>`).join('')}</nav>
  <section class="workspace"><div class="stage"><div class="stage-top"><div><b id="stage-title"></b><span id="stage-note"></span></div><div class="segmented"><button data-view="streaming">Streaming & tiles</button><button data-view="journey">Observed journey</button><button data-view="layers">Time layers</button></div></div>
  <div id="teaching-controls"><button id="teaching-previous" aria-label="Previous teaching step">←</button><label>Walkthrough<select id="teaching-step" aria-label="Teaching step"></select></label><button id="teaching-next" aria-label="Next teaching step">→</button><button id="teaching-play">▶ Auto step</button><span id="teaching-progress"></span></div>
  <canvas id="fabric" tabindex="0" aria-label="Interactive WebGL WSE mesh. Select PE buttons below for keyboard access."></canvas><div id="gl-error" hidden></div>
  <div class="stage-bottom"><span id="legend"><i class="dot input"></i>Inputs / SRAM <i class="dot compute"></i>Arithmetic <i class="dot packet"></i>PE packets <i class="dot output"></i>Results</span><button id="reset">Reset camera</button></div><div class="hint">Drag to rotate · wheel to zoom · Shift + drag to pan · click a PE to inspect</div>
  <div id="teaching-caption" aria-live="polite"></div>
  <div class="timeline"><button id="play">▶ Play observations</button><label id="cycle-label">Simulator cycle <input id="cycle-number" type="number"></label><input id="scrub" type="range" aria-label="Simulator cycle"><button id="previous" aria-label="Previous observation">←</button><button id="next" aria-label="Next observation">→</button></div><p class="timing-note" id="timing-note"></p>
  </div><aside><div class="aside-head"><p class="eyebrow">PE MICROSCOPE</p><div id="pe-picker"></div></div><div id="inspector"></div></aside></section>
  <section class="ledger"><div><p class="eyebrow">01 / HOST INPUTS</p><h2>Every value has a destination</h2><p>Click an input number to highlight its initial owners and arithmetic uses.</p><div id="host-inputs" class="tensor-tables"></div><div id="input-lineage"></div></div><div><p class="eyebrow">02 / PE TRANSFERS</p><h2>A number crossing the mesh</h2><select id="packet" aria-label="Select PE packet"></select><div id="packet-detail"></div></div><div><p class="eyebrow">03 / VERIFIED OUTPUT</p><h2 id="output-title"></h2><p>Click an output to inspect its observed calculation.</p><div id="host-output"></div><div id="output-equation"></div></div></section>
  <section class="snapshot-lab" id="snapshot-lab" hidden><div class="intro"><div><p class="eyebrow">04 / NEW SNAPSHOT EXPERIMENTS</p><h2>SRAM and registers, before and after</h2><p>Independent stopped runs · one PE, a two-PE relay, and a four-PE GEMM.</p></div><label>Snapshot experiment<select id="snapshot-case"></select></label></div><div class="snapshot-grid"><div><canvas id="snapshot-canvas" aria-label="WebGL comparison of independently stopped SRAM snapshots"></canvas><p id="snapshot-note"></p></div><div><div id="snapshot-pe"></div><div id="snapshot-detail"></div></div></div></section>
  <details class="evidence"><summary>Evidence, capture boundaries and source files</summary><div id="evidence"></div></details><footer>WebGL2 scene · local read-only evidence service · numeric values from retained simulator runs</footer></main>`;
  try{gl=new DataflowGL(document.querySelector('#fabric')!);gl.onPick=id=>{if(id.startsWith('pe:')){peID=id.split(':')[1];render();}else if(id.startsWith('global:')&&id.includes(':cell:')){const [,name,,r,c]=id.split(':');inputFocus={name,row:+r,col:+c};peID=inputOwners()[0]??peID;const tile=s.teaching.tiles.find(t=>t.pe===peID&&t.tensor===name&&t.rows.includes(+r)&&t.cols.includes(+c));if(tile)setTeaching(s.teaching.steps.findIndex(st=>st.tile===tile.id));}else if(id==='host')setChapter(0);else if(id==='output')setChapter(6);};}
  catch(e){document.querySelector('#gl-error')!.textContent=String(e);(document.querySelector('#gl-error') as HTMLElement).hidden=false;}
  document.querySelector<HTMLSelectElement>('#scene')!.onchange=e=>loadScene((e.target as HTMLSelectElement).value);
  document.querySelectorAll<HTMLButtonElement>('[data-chapter]').forEach(b=>b.onclick=()=>setChapter(Number(b.dataset.chapter)));
  document.querySelectorAll<HTMLButtonElement>('[data-view]').forEach(b=>b.onclick=()=>{stop();stopTeaching();view=b.dataset.view!;if(view==='streaming'){setTeaching(teachingIndex);return;}if(view==='layers'&&chapter<3){chapter=3;cycle=sampleCycle();}render();});
  document.querySelector<HTMLSelectElement>('#teaching-step')!.onchange=e=>{stopTeaching();setTeaching(+(e.target as HTMLSelectElement).value);};
  document.querySelector('#teaching-previous')!.addEventListener('click',()=>{stopTeaching();setTeaching(teachingIndex-1);});
  document.querySelector('#teaching-next')!.addEventListener('click',()=>{stopTeaching();setTeaching(teachingIndex+1);});
  document.querySelector('#teaching-play')!.addEventListener('click',()=>{if(teachingPlaying){stopTeaching();return;}if(teachingIndex===s.teaching.steps.length-1)setTeaching(0);document.querySelector('#teaching-play')!.textContent='Ⅱ Pause';teachingPlaying=window.setInterval(()=>{if(teachingIndex===s.teaching.steps.length-1){stopTeaching();return;}setTeaching(teachingIndex+1);},2200);});
  document.querySelector('#reset')!.addEventListener('click',()=>gl?.reset());
  document.querySelector<HTMLInputElement>('#scrub')!.oninput=e=>setCycle(Number((e.target as HTMLInputElement).value));
  document.querySelector<HTMLInputElement>('#cycle-number')!.onchange=e=>setCycle(Number((e.target as HTMLInputElement).value));
  document.querySelector('#previous')!.addEventListener('click',()=>setCycle([...s.cycles].reverse().find(c=>c<cycle)??s.start));
  document.querySelector('#next')!.addEventListener('click',()=>setCycle(s.cycles.find(c=>c>cycle)??s.end));
  document.querySelector('#play')!.addEventListener('click',()=>{if(playing){stop();return;}if(chapter<3||chapter>5){chapter=3;cycle=s.start;}
    document.querySelector('#play')!.textContent='Ⅱ Pause';playing=window.setInterval(()=>{const next=s.cycles.find(c=>c>cycle);if(next===undefined){stop();return;}cycle=next;render();},400);render();});
  document.querySelector<HTMLSelectElement>('#packet')!.onchange=e=>{packetIndex=Number((e.target as HTMLSelectElement).value);setChapter(4);};
  app.addEventListener('click',e=>{const b=(e.target as HTMLElement).closest<HTMLButtonElement>('button');if(!b)return;
    if(b.dataset.teachingCell){teachingCell=+b.dataset.teachingCell;render();}
    if(b.dataset.teachingTile){stopTeaching();setTeaching(s.teaching.steps.findIndex(st=>st.tile===b.dataset.teachingTile));}
    if(b.dataset.teachingPacket){packetIndex=+b.dataset.teachingPacket;view='journey';setChapter(4);}
    if(b.dataset.pe){peID=b.dataset.pe;render();}
    if(b.dataset.input){const [name,r,c]=b.dataset.input.split('|');inputFocus={name,row:+r,col:+c};peID=inputOwners()[0]??peID;render();}
    if(b.dataset.output){const [,r,c]=b.dataset.output.split('|');output=s.kind==='gemm'?+r*s.n+(+c):+c;peID=outputOwner();inputFocus=null;render();}
    if(b.dataset.event){if(b.dataset.eventPe)peID=b.dataset.eventPe;if(b.closest('#packet-detail')){chapter=4;const p=selectedPacket(),c=+b.dataset.event;peID=p.observations.find(o=>o.cycle===c)?.pe??(p.receive?.cycle===c||p.consumer?.cycle===c?p.destination:p.source);}setCycle(+b.dataset.event);}
  });
}
function setChapter(c:number){stop();stopTeaching();if(view==='streaming')view='journey';chapter=c;cycle=sampleCycle();render();}
function setCycle(c:number){if(!Number.isFinite(c))return;stopTeaching();if(view==='streaming')view='journey';cycle=Math.max(s.start,Math.min(s.end,Math.round(c)));if(chapter<3||chapter>5)chapter=3;render();}
function rowsForPE(p:PE){return (p.input_tiles??[]).flatMap(t=>matrixLines(`${t.tensor} · SRAM`,Array.from({length:t.rows.length},(_,i)=>t.values.slice(i*t.cols.length,(i+1)*t.cols.length))));}
function draw(){if(!gl)return;if(view==='streaming'){const scene=streamingScene(s,s.teaching.steps[teachingIndex],peID,teachingCell);gl.setScene(scene,scene.extent);return;}const cards:Card[]=[],edges:Edge[]=[];
  const loaded=chapter>=2;const states=stateAt(s,cycle),owners=inputOwners();
  const positions=new Map<string,V3>();
  const add=(id:string,at:V3,width:number,height:number,lines:string[],color:string,active=false)=>cards.push({id,at,width,height,lines,color,active});
  const mesh=(cx:number,z:number,c:number,tag:string)=>{
    const state=stateAt(s,c);
    s.pes.forEach(p=>{const at:V3=[cx+(p.x-(s.p-1)/2)*3.05,((s.p-1)/2-p.y)*3.7,z];positions.set(`${tag}${p.id}`,at);
      const multiply=[...s.events].reverse().find(e=>e.pe===p.id&&e.kind==='multiply'&&e.cycle<=c);
      const lines=[`PE (${p.id}) · fabric ${p.fabric.join(',')}`,loaded||view==='layers'?rowsForPE(p):['SRAM inputs not loaded'],
        chapter>=3||view==='layers'?`→ ${s.kind==='gemv'?'partial':'C observed'} ${list(state[p.id].partial)}`:'→ awaiting kernel launch',
        s.kind==='gemv'&&(chapter>=3||view==='layers')?`→ result ${list(state[p.id].result)}`:'',
        (chapter>=3||view==='layers')&&multiply?`use ${fmt(multiply.a)} × ${fmt(multiply.b)} = ${fmt(multiply.value)}`:'· inputs → ALU → result'].flat().filter(Boolean);
      add(`pe:${p.id}`,at,2.7,3.18,lines,p.id===peID?palette.compute:palette.input,owners.includes(p.id)||p.id===peID);
      for(const [dx,dy] of [[1,0],[0,1]]){const other=s.pes.find(q=>q.x===p.x+dx&&q.y===p.y+dy);if(other)edges.push({from:[at[0],at[1],z+.3],to:[cx+(other.x-(s.p-1)/2)*3.05,((s.p-1)/2-other.y)*3.7,z+.3],color:'#345168'});}
    });
  };
  if(view==='layers'){
    const before=[...s.cycles].reverse().find(c=>c<cycle)??s.start,after=s.cycles.find(c=>c>cycle)??s.end;
    [before,cycle,after].forEach((c,i)=>{const x=(i-1)*7.3,z=(i-1)*1.4;mesh(x,z,c,`${i}:`);add(`time:${i}`,[x,4.5,z],5.6,.7,[`${i===1?'SELECTED':'TIME SLICE'} · cycle ${c}`],i===1?palette.compute:palette.muted);
      if(i<2)s.pes.forEach(p=>{const a=positions.get(`${i}:${p.id}`)!;edges.push({from:[...a] as V3,to:[a[0]+7.3,a[1],a[2]+1.4],color:'#263d50',width:.014});});});
    gl.setScene({cards,edges},11.5);return;
  }
  const inputLines=s.host.inputs.flatMap(t=>matrixLines(t.name,t.values));
  add('host',[-8.3,0,0],3.5,6.8,['HOST MEMORY',...inputLines,'· exact uploaded numbers'],palette.input,chapter===0);
  add('ingress',[-5.05,0,.7],1.95,4.4,['I/O ENTRY','Host runtime','↓','West support','3 columns','↓','Kernel SRAM','· copy mode'],palette.input,chapter===1);
  mesh(-.4,0,cycle,'');
  add('egress',[4.2,0,.7],1.95,4.4,['I/O EXIT','Kernel result','↓','East support','2 columns','↓','Host runtime','· copy mode'],palette.output,chapter===6);
  add('output',[7.6,0,0],3.5,6.8,['HOST OUTPUT',...(chapter===6?matrixLines(s.host.output_name,s.host.output):['Readback follows','kernel completion','','Expected result:',...s.host.output.map(r=>r.map(fmt).join('  '))]),chapter===6?'→ exact readback verified':'· expected ≠ received yet'],palette.output,chapter===6);
  edges.push({from:[-6.55,0,0],to:[-6.05,0,.7],color:chapter>=1?palette.input:palette.muted});
  const focus=positions.get(peID)!;
  if(chapter===1)edges.push({from:[-4,0,-.3],via:[[-3.75,0,-.3],[-3.75,focus[1]+1.9,-.3],[focus[0],focus[1]+1.9,-.3]],to:[focus[0],focus[1]+1.65,-.3],color:palette.input,dashed:true,width:.04});
  if(chapter===6)edges.push({from:[focus[0],focus[1]-1.65,-.3],via:[[focus[0],focus[1]-1.9,-.3],[2.9,focus[1]-1.9,-.3],[2.9,0,-.3]],to:[3.18,0,-.3],color:palette.output,dashed:true,width:.04});
  edges.push({from:[5.2,0,.7],to:[5.8,0,0],color:chapter===6?palette.output:palette.muted});
  if(chapter===1){const tensor=s.host.inputs.find(t=>t.name===inputFocus?.name)??s.host.inputs[0],row=inputFocus?.row??0,col=inputFocus?.col??0;
    add('upload',[-3.2,3.4,-.7],2,.85,[`${tensor.name}[${row},${col}] = ${tensor.values[row][col]}`,'host payload · logical route'],palette.input,true);}
  const packet=selectedPacket();
  if(chapter===4&&packet){const a=positions.get(packet.source)!,b=positions.get(packet.destination)!;
    const obs=packet.observations,lo=obs[0].cycle,hi=obs[obs.length-1].cycle;
    const f=Math.max(0,Math.min(1,(cycle-lo)/Math.max(1,hi-lo)));
    let points:V3[];
    if(a[1]===b[1])points=[[a[0],a[1]+1.65,-.35],[a[0],a[1]+1.95,-.35],[b[0],b[1]+1.95,-.35],[b[0],b[1]+1.65,-.35]];
    else points=[[a[0]+1.4,a[1],-.35],[a[0]+1.62,a[1],-.35],[b[0]+1.62,b[1],-.35],[b[0]+1.4,b[1],-.35]];
    edges.push({from:points[0],to:points.at(-1)!,via:points.slice(1,-1),color:palette.packet,width:.055});
    const lengths=points.slice(1).map((b,i)=>Math.hypot(b[0]-points[i][0],b[1]-points[i][1]));let remaining=f*lengths.reduce((a,b)=>a+b,0),position=points[0];
    for(let i=0;i<lengths.length;i++){const ratio=Math.min(1,remaining/lengths[i]);position=points[i].map((v,j)=>v+(points[i+1][j]-v)*ratio) as V3;if(remaining<=lengths[i])break;remaining-=lengths[i];}
    add('packet',[position[0],position[1],-.7],1.1,.75,[fmt(packet.value),`color ${packet.color}`],palette.packet,true);
  }
  add('caption',[-.3,4.25,0],5.6,.6,[chapter>=3&&chapter<=5?`cycle ${cycle} · observations`:'Host transfer order · no cycle assigned'],palette.muted);
  gl.setScene({cards,edges},10.5);
}
function render(){save();
  const teaching=view==='streaming',step=s.teaching.steps[teachingIndex];
  document.querySelector('.stage')!.classList.toggle('streaming-stage',teaching);
  for(const id of ['teaching-controls','teaching-caption'])(document.querySelector('#'+id) as HTMLElement).hidden=!teaching;
  (document.querySelector('.timeline') as HTMLElement).hidden=teaching;(document.querySelector('#timing-note') as HTMLElement).hidden=teaching;
  document.querySelector<HTMLSelectElement>('#scene')!.value=s.id;
  document.querySelector('#connection')!.textContent=api?'● Evidence API connected':'● Offline evidence bundle';
  document.querySelectorAll<HTMLButtonElement>('[data-chapter]').forEach(b=>{b.classList.toggle('active',Number(b.dataset.chapter)===chapter);b.setAttribute('aria-current',Number(b.dataset.chapter)===chapter?'step':'false');});
  document.querySelectorAll<HTMLButtonElement>('[data-view]').forEach(b=>b.classList.toggle('active',b.dataset.view===view));
  document.querySelector('#stage-title')!.textContent=teaching?step.title:chapters[chapter];
  document.querySelector('#stage-note')!.textContent=teaching?'Documented SDK layout + checked tile arithmetic · teaching order, not simultaneous cycle snapshots':chapter<3||chapter===6?'Transfer geometry is schematic; values and PE destinations come from the capture.':'Numeric state is the latest observation at this cycle; packet motion interpolates recorded endpoints.';
  const clocked=!teaching&&chapter>=3&&chapter<=5;
  for(const id of ['scrub','cycle-number']){const el=document.querySelector<HTMLInputElement>('#'+id)!;el.min=String(s.start);el.max=String(s.end);el.value=String(cycle);el.disabled=!clocked;}
  document.querySelector('#timing-note')!.textContent=clocked?'Cycle numbers are from this instrumented simulator run. Arithmetic observations are not SRAM write-commit timestamps.':'This chapter has no measured transfer cycle. The simulator cycle control becomes available during computation.';
  document.querySelector('#pe-picker')!.innerHTML=s.pes.map(p=>`<button data-pe="${p.id}" class="${p.id===peID?'active':''}">(${p.id})</button>`).join('');
  const p=pe(),state=stateAt(s,cycle)[peID],observed=[...s.events].reverse().find(e=>e.pe===peID&&e.cycle<=cycle&&e.kind!=='checkpoint');
  const arrs=s.storage.find(x=>x.pe===peID)?.arrays??[];
  document.querySelector('#inspector')!.innerHTML=`<h2>PE (${peID})</h2><p>Logical coordinates · fabric (${p.fabric.join(', ')})</p><div class="badge">${chapter<2?'Upload destination':'PE-local SRAM backing'}</div>${p.input_tiles?.map(t=>`<div class="local-array"><b>${t.tensor} <small>${esc(arrs.find(a=>a.name===t.storage)?.elf_address_hex??'address unknown')}</small></b><div class="local-grid" style="--cols:${t.cols.length}">${t.values.map((v,i)=>`<span title="${esc(t.tensor)}[${t.rows[Math.floor(i/t.cols.length)]},${t.cols[i%t.cols.length]}]">${v}</span>`).join('')}</div><small>global rows ${t.rows.join(', ')} · columns ${t.cols.join(', ')} · ${t.packing}</small></div>`).join('')}
    ${clocked&&s.kind==='gemm'&&s.p>1?layerInputs(s,p,cycle).filter(a=>a.key==='abuf'||a.key==='bbuf').map(a=>`<div class="local-array"><b>${a.label} <small>receive S6 values</small></b><div class="local-grid" style="--cols:${a.cols.length}">${a.values.map((v,i)=>`<span title="${esc(a.titles[i])}">${fmt(v)}</span>`).join('')}</div></div>`).join(''):''}
    <div class="micropath">SRAM → operand selection → arithmetic → result</div>
    ${clocked&&observed?`<p class="eyebrow">LAST ARITHMETIC OBSERVATION</p><div class="equation">${esc(eventText(observed))}</div><p>cycle ${observed.cycle} · ${observed.kind}</p><code>${esc(observed.instruction?.assembly??'See capture evidence')}</code>`:'<p>Kernel arithmetic appears after the input-loading chapters.</p>'}
    ${clocked?`<p><b>Partial / C observed</b><br>${list(state.partial)}</p>${s.kind==='gemv'?`<p><b>Received partial</b> ${list(state.peer)}<br><b>Result observed</b> ${list(state.result)}</p>`:''}`:''}
    <details><summary>What is known about storage?</summary><p>ELF symbols allocate these input arrays in local SRAM. Their displayed values come from host initialization and checked uses/readbacks. No cache contents or continuous GPR/DSR state is claimed.</p></details>`;
  document.querySelector('#host-inputs')!.innerHTML=s.host.inputs.map(t=>table(t.values,t.name)).join('');
  const uses=inputUses();
  document.querySelector('#input-lineage')!.innerHTML=inputFocus?`<div class="selection-note"><b>${inputFocus.name}[${inputFocus.row},${inputFocus.col}]</b> initially belongs to PE ${inputOwners().map(id=>'('+id+')').join(', ')}. ${uses.length} matched multiply uses.</div><div class="event-list">${uses.map(e=>`<button data-event="${e.cycle}" data-event-pe="${e.pe}"><span>c${e.cycle} · PE ${e.pe}</span>${esc(eventText(e))}</button>`).join('')}</div>`:'<p class="muted">Select a number above to follow its uses.</p>';
  const select=document.querySelector<HTMLSelectElement>('#packet')!;select.disabled=!s.packets.length;
  select.innerHTML=s.packets.length?s.packets.map((q,i)=>`<option value="${i}">${q.source} → ${q.destination} · ${q.kind} · ${fmt(q.value)} · slot ${q.slot}</option>`).join(''):'<option>No inter-PE traffic in this single-PE case</option>';select.value=String(packetIndex);
  const packet=selectedPacket();
  document.querySelector('#packet-detail')!.innerHTML=packet?`<p class="packet-value">${fmt(packet.value)} <code>0x${packet.word.toString(16).padStart(8,'0')}</code></p><p>Packet identity <code>${packet.id}</code> · color ${packet.color}</p><ol class="packet-stops">${packet.send?`<li><button data-event="${packet.send.cycle}">Send operand · cycle ${packet.send.cycle}</button></li>`:''}${packet.observations.map(o=>`<li><button data-event="${o.cycle}">PE ${o.pe} router ${o.link} · cycle ${o.cycle}</button><small>raw row ${o.row}</small></li>`).join('')}${packet.receive?`<li><button data-event="${packet.receive.cycle}">Receive operand · cycle ${packet.receive.cycle}</button></li>`:''}${packet.consumer?`<li><button data-event="${packet.consumer.cycle}">${esc(packet.consumer.equation)} · cycle ${packet.consumer.cycle}</button></li>`:''}</ol><p class="muted">Same identity and full 32-bit payload at both endpoints. Queue residence between observations is unknown.</p>`:'<p>This workload runs on one PE. Inputs and outputs still cross the SDK I/O infrastructure.</p>';
  document.querySelector('#output-title')!.textContent=s.kind==='gemv'?'Y = X × W':'C = A × B';
  document.querySelector('#host-output')!.innerHTML=table(s.host.output,s.host.output_name,'output');
  const operations=s.events.filter(e=>matchesOutput(e)&&e.kind!=='checkpoint');
  document.querySelector('#output-equation')!.innerHTML=`<div class="selection-note">${s.host.output_name}[${s.kind==='gemm'?`${Math.floor(output/s.n)},`:''}${output%s.n}] · ${operations.length} arithmetic observations</div><div class="event-list">${operations.map(e=>`<button data-event="${e.cycle}" data-event-pe="${e.pe}" class="${e.cycle===cycle?'chosen':''}"><span>c${e.cycle} · PE ${e.pe}</span>${esc(eventText(e))}</button>`).join('')}</div>`;
  document.querySelector('#evidence')!.innerHTML=`<ul>${s.limits.map(l=>`<li>${esc(l)}</li>`).join('')}</ul><p>Sources retain ${s.verification.checks} numerical checks. The original captures include instrumentation; their timings are not uninstrumented hardware performance.</p><div class="sources">${s.sources.map(p=>`<p><code>${esc(p.path)}</code><br><small>SHA-256 ${p.sha256}</small></p>`).join('')}</div><p>Presentation references: <a href="https://github.com/aharley/nn_vis">Adam Harley’s CNN visualization</a> and <a href="https://github.com/bbycroft/llm-viz">Brendan Bycroft’s LLM visualization</a>. This renderer and data service are implemented independently.</p>`;
  renderTeaching(teaching);
  draw();void checkFrame();
}
function renderTeaching(active:boolean){
  const step=s.teaching.steps[teachingIndex];
  document.querySelector('#legend')!.innerHTML=active?`<i class="dot input"></i>A / X <i class="dot compute"></i>B / W <i class="dot packet"></i>Partial <i class="dot output"></i>Output <span class="line-sample"></span>Matched PE transfer <span class="line-sample dashed"></span>Schematic I/O`:'<i class="dot input"></i>Inputs / SRAM <i class="dot compute"></i>Arithmetic <i class="dot packet"></i>PE packets <i class="dot output"></i>Results';
  if(!active)return;
  const select=document.querySelector<HTMLSelectElement>('#teaching-step')!;
  select.innerHTML=s.teaching.steps.map((st,i)=>`<option value="${i}">${String(i+1).padStart(2,'0')} · ${esc(st.title)}</option>`).join('');select.value=String(teachingIndex);
  document.querySelector<HTMLButtonElement>('#teaching-previous')!.disabled=teachingIndex===0;
  document.querySelector<HTMLButtonElement>('#teaching-next')!.disabled=teachingIndex===s.teaching.steps.length-1;
  document.querySelector('#teaching-progress')!.textContent=`${teachingIndex+1} / ${s.teaching.steps.length}`;
  document.querySelector('#teaching-caption')!.innerHTML=`<span class="badge">${step.phase==='overview'?'Documented architecture':'Checked teaching step'}</span><p>${esc(step.description)}</p>`;
  const tile=s.teaching.tiles.find(t=>t.id===step.tile),calc=step.calculations?.find(c=>c.pe===peID);
  const mappings=s.teaching.tiles.filter(t=>t.pe===peID);
  let html=`<h2>PE (${peID})</h2><p>Fabric (${pe().fabric.join(', ')}) · click any PE in the mesh.</p><p class="eyebrow">INITIAL TILE OWNERSHIP</p><div class="tile-mappings">${mappings.map(t=>`<button data-teaching-tile="${t.id}" style="--tile-color:${tensorColor(t.tensor)}"><b>${t.tensor}</b> rows [${t.rows[0]}:${t.rows.at(-1)!+1}) · cols [${t.cols[0]}:${t.cols.at(-1)!+1})<small>${list(t.values)}</small></button>`).join('')}</div>`;
  if(tile){const address=s.storage.find(p=>p.pe===tile.pe)?.arrays.find(a=>a.name===tile.storage)?.elf_address_hex;
    html+=`<h2>${tile.tensor} → PE (${tile.pe})</h2><p>SRAM symbol <code>${tile.storage}</code> at <code>${address??'unknown address'}</code></p><p><b>Tile values (row view)</b><br>${rows(tile.values,tile.cols.length).map(list).join('<br>')}</p><p><b>Local ${tile.packing} order</b><br>${list(tile.packed)}</p><p>Local packing differs from the SDK’s ordering of PE payloads.</p>`;}
  if(calc){const p=pe(),slots=calc.after.length;
    html+=`<h2>One scalar at a time</h2><div class="scalar-picker">${Array.from({length:slots},(_,q)=>`<button data-teaching-cell="${q}" class="${q===teachingCell?'active':''}">${s.kind==='gemm'?`${p.y*s.t+Math.floor(q/s.t)},`:''}${p.x*s.t+q%s.t}</button>`).join('')}</div>`;
    const q=teachingCell,mul=s.events.find(e=>e.id===calc.mul_ids[q])!,add=s.events.find(e=>e.id===calc.add_ids[q])!;
    html+=`<div class="equation">${calc.before[q]} + ${calc.a[q]} × ${calc.b[q]}<br>= ${calc.after[q]}</div><p>Global k = ${calc.k}. Inputs stay visible on the left; selected operands are outlined in white.</p><div class="event-list"><button data-event="${mul.cycle}" data-event-pe="${peID}">Observe multiply · c${mul.cycle}<span>${esc(mul.instruction?.assembly)}</span></button><button data-event="${add.cycle}" data-event-pe="${peID}">Observe sum · c${add.cycle}<span>${esc(add.instruction?.assembly)}</span></button></div><p>The cell grid names global output indices. All ${slots} cells on this PE are updated in this teaching step.</p>`;
  }
  if(step.reduction){html+=`<h2>Partial + partial</h2>${step.reduction.after.map((v,q)=>`<p class="equation">${step.reduction!.before[q]} + ${step.reduction!.incoming[q]} = ${v}</p>`).join('')}`;}
  const values=step.state[peID].result??step.state[peID].partial;
  if(values)html+=`<h2>${step.state[peID].result?'Final values':'Teaching partial'} · PE (${peID})</h2><div class="local-grid" style="--cols:${s.t}">${values.map(v=>`<span>${fmt(v)}</span>`).join('')}</div>`;
  if(step.flows?.length){html+=`<h2>Captured PE transfers</h2><div class="flow-evidence">${step.flows.map(f=>`<p><b>${f.tensor} · (${f.source}) → (${f.destination})</b><br>${list(f.values)}<br>${f.packet_ids.length} matched 32-bit payloads</p><button data-teaching-packet="${s.packets.findIndex(q=>q.id===f.packet_ids[0])}">Inspect first packet →</button>`).join('')}</div>`;}
  if(step.phase==='overview')html+=`<h2>Read the layout</h2><p>Orange: SDK support PEs.<br>Blue: user kernel PEs.<br>Gray: halo.<br>Dashed arrows: schematic I/O route.</p><p>Support columns are compressed; kernel PEs are enlarged. This shows the compile rectangle, not a wafer floorplan.</p><p><code>streaming=False</code><br>H2D copies → launch → D2H copies</p><p>Streaming mode in the SDK instead delivers wavelets to a task or fabric input descriptor. These retained kernels use copy mode.</p>`;
  document.querySelector('#inspector')!.innerHTML=html;
}
async function checkFrame(){if(!api)return;const version=++requestVersion;if(view==='streaming')return;
  if(chapter<3||chapter>5)return;
  try{const r=await fetch(`/api/scenes/${s.id}/frame?cycle=${cycle}`);if(!r.ok)throw Error('Frame service unavailable');const f=await r.json();if(version===requestVersion)document.querySelector('#connection')!.textContent=`● Evidence API · frame ${f.cycle}`;}
  catch{if(version===requestVersion)document.querySelector('#connection')!.textContent='Frame request failed · showing loaded capture';}
}
async function loadScene(id:string,initial=false){stop();stopTeaching();const r=api?await fetch(`/api/scenes/${id}`):null;
  if(r&&!r.ok)throw Error('Scene unavailable');s=r?await r.json():offline!.scenes.find(x=>x.id===id)!;
  if(!s)throw Error('Unknown workload');chapter=0;cycle=s.start;peID='0,0';packetIndex=0;output=0;inputFocus=null;teachingIndex=0;teachingCell=0;
  if(initial){const q=new URLSearchParams(location.hash.slice(1));const c=Number(q.get('chapter'));if(c>=0&&c<=6)chapter=c;
    const t=Number(q.get('cycle'));if(t>=s.start&&t<=s.end)cycle=t;else cycle=sampleCycle();
    if(s.pes.some(p=>p.id===q.get('pe')))peID=q.get('pe')!;
    const o=Number(q.get('output'));if(o>=0&&o<(s.kind==='gemm'?s.n*s.n:s.n))output=o;
    const pi=Number(q.get('packet'));if(pi>=0&&pi<s.packets.length)packetIndex=pi;
    if(['layers','journey','streaming'].includes(q.get('view')??''))view=q.get('view')!;else if(q.has('chapter'))view='journey';
    const ti=Number(q.get('step'));if(Number.isInteger(ti)&&ti>=0&&ti<s.teaching.steps.length)teachingIndex=ti;
    const cell=Number(q.get('cell'));if(Number.isInteger(cell)&&cell>=0&&cell<s.slots)teachingCell=cell;
  }
  if(view==='streaming'){chapter=s.teaching.steps[teachingIndex].chapter;if(initial&&!new URLSearchParams(location.hash.slice(1)).has('pe'))peID=s.teaching.steps[teachingIndex].pe??peID;}
  render();
}
async function boot(){
  offline=window.DATAFLOW_BUNDLE;
  if(!offline){try{const r=await fetch('/api/scenes');if(r.ok){catalog=await r.json();api=Array.isArray(catalog)&&catalog.length>0;}}catch{/* static/offline fallback */}
    if(!api){const r=await fetch('./dataflow-bundle.json');if(!r.ok)throw Error('Start tools/dataflow_server.py or open the standalone HTML');offline=await r.json();}}
  if(offline)catalog=offline.scenes.map(x=>({id:x.id,title:x.title}));
  scaffold();const id=new URLSearchParams(location.hash.slice(1)).get('scene')??'v1';await loadScene(catalog.some(s=>s.id===id)?id:catalog[0].id,true);
  snapshots=offline?.snapshots;
  if(api){try{const r=await fetch('/api/snapshots');if(r.ok)snapshots=await r.json();}catch{/* independent lab unavailable */}}
  if(snapshots){const select=document.querySelector<HTMLSelectElement>('#snapshot-case')!;select.innerHTML=snapshots.cases.map((c,i)=>`<option value="${i}">${esc(c.title)}</option>`).join('');select.onchange=()=>{labIndex=+select.value;labPE='0,0';renderLab();};
    document.querySelector<HTMLElement>('#snapshot-lab')!.hidden=false;
    try{lab=new DataflowGL(document.querySelector('#snapshot-canvas')!);lab.onPick=id=>{if(id.startsWith('lab:')){labPE=id.slice(4);renderLab();}};}catch{/* numeric snapshots remain accessible */}
    document.querySelector('#snapshot-pe')!.addEventListener('click',e=>{const b=(e.target as HTMLElement).closest<HTMLButtonElement>('button');if(b?.dataset.labPe){labPE=b.dataset.labPe;renderLab();}});renderLab();}
}
function renderLab(){if(!snapshots)return;const c=snapshots.cases[labIndex],before=c.phases.loaded,after=c.phases.computed;
  const pes=Object.keys(before.gpr_u16);const width=Math.max(...pes.map(k=>+k.split(',')[0]))+1,height=Math.max(...pes.map(k=>+k.split(',')[1]))+1;
  document.querySelector('#snapshot-note')!.textContent=snapshots.note;
  document.querySelector('#snapshot-pe')!.innerHTML=pes.map(k=>`<button data-lab-pe="${k}" class="${k===labPE?'active':''}">PE (${k})</button>`).join('');
  const keys=Object.keys(before.values).filter(k=>k.endsWith('@'+labPE));
  document.querySelector('#snapshot-detail')!.innerHTML=`<h2>PE (${labPE}) · exact dump values</h2><p class="badge">ELF core + csdb agree</p><table class="snapshot-values"><thead><tr><th>SRAM symbol</th><th>Loaded</th><th>Computed</th></tr></thead><tbody>${keys.map(k=>`<tr><th>${esc(k.split('@')[0])}<small>0x${before.symbols[k].byte_address.toString(16)}</small></th><td>${list(before.values[k])}</td><td class="${JSON.stringify(before.values[k])!==JSON.stringify(after.values[k])?'changed':''}">${list(after.values[k])}</td></tr>`).join('')}</tbody></table><p>${c.id==='gemm'?'Tiles are packed column-major in SRAM. ':''}No host readback precedes these dumps.</p><details><summary>All 16 named GPR words · raw hexadecimal</summary><table class="snapshot-values"><thead><tr><th>ce_gpr</th><th>Loaded</th><th>Computed</th></tr></thead><tbody>${before.gpr_u16[labPE].map((v,i)=>`<tr><th>${i}</th><td>${v.toString(16).padStart(4,'0')}</td><td class="${v!==after.gpr_u16[labPE][i]?'changed':''}">${after.gpr_u16[labPE][i].toString(16).padStart(4,'0')}</td></tr>`).join('')}</tbody></table><p>Runtime completion code also uses these registers; these are boundary values, not arithmetic operands.</p></details><details><summary>Descriptor and control register observations</summary><pre>${esc(after.registers[labPE].join('\n'))}</pre></details><details><summary>Snapshot source hashes</summary>${c.sources.map(x=>`<p><code>${esc(x.path)}</code><br><small>${x.sha256}</small></p>`).join('')}</details>`;
  const cards:Card[]=[],edges:{from:V3;to:V3;color:string}[]=[];
  [before,after].forEach((phase,i)=>{const center=(i-.5)*(width*3.2+1.7);
    cards.push({id:'label',at:[center,height*1.7+.65,0],width:width*3.2,height:.7,lines:[i?'AFTER COMPUTATION · stopped':'AFTER INPUT LOADING · stopped'],color:i?palette.output:palette.input});
    for(const key of pes){const [x,y]=key.split(',').map(Number),at:V3=[center+(x-(width-1)/2)*3.2,((height-1)/2-y)*3.5,i*.8];
      const rows=Object.keys(phase.values).filter(k=>k.endsWith('@'+key)).flatMap(k=>[`${k.split('@')[0]} · 0x${phase.symbols[k].byte_address.toString(16)}`,list(phase.values[k])]);
      cards.push({id:'lab:'+key,at,width:2.95,height:3.1,lines:[`PE (${key}) · SRAM`,...rows,'→ independently verified'],color:i?palette.output:palette.input,active:key===labPE});
      if(i===0)edges.push({from:[at[0]+1.5,at[1],.3],to:[at[0]+width*3.2+.2,at[1],1.1],color:'#36566c'});
    }
  });lab?.setScene({cards,edges},width===1?6.2:10.5);
}
boot().catch(e=>{app.innerHTML=`<main><h1>Could not load the capture</h1><p>${esc(e)}</p><p>Start the local dataflow server, or open the bundled offline presentation.</p></main>`;console.error(e);});
