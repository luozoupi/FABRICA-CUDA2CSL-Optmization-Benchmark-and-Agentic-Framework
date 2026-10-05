import './style.css';
import './walkthrough.css';
import './space-time.css';
import {inputPanel,inputStateAt} from './input-view';
import {layerInputs,layerGeometry,type LayerArray} from './layer-inputs';
import {badge,bits,download,esc,events,fmt,header,hex,mini,theme} from './walkthrough';
import {eventText,phaseName,type NumericEvent,type PE,type Scene} from './time-model';
import {layersFor,numericEvents,outputFor,outputLabel,project,slotFor,transferLayers,transfersFor,type BufferName,type Layer,type Point} from './layer-model';

type Bundle={schema:string;scenes:Scene[]};
declare global{interface Window{TIME_BUNDLE?:Bundle}}
let bundle:Bundle,s:Scene,layers:Layer[],target=0,selectedPE='0,1',selectedLayer=3,selectedBuffer:BufferName='result';
let presentation='stack';
let sampling='story',count=6,anchor=0,yaw=52,tilt=12,spacing=1,zoom=1,panX=0,panY=0,focus=false,showTransfers=true,highlight=true,playing:number|undefined;
const app=document.querySelector<HTMLDivElement>('#app')!;
const VW=1400,VH=640;
let W=440,H=400,DX=478,DY=432;
const sheetPitch=()=>((s.p-1)*DY+H+180);
const peById=(id:string)=>s.pes.find(p=>p.id===id)!;
const current=()=>layers[selectedLayer];
const selectedSlot=()=>Math.max(0,slotFor(s,peById(selectedPE),target));
function stop(){clearInterval(playing);playing=undefined;}
function resetCamera(){zoom=1;panX=panY=0;focus=false;}
function prepare(){const g=layerGeometry(s);W=g.width;H=g.height;DX=g.dx;DY=g.dy;layers=layersFor(s,target,sampling,count,anchor);selectedLayer=Math.max(0,Math.min(layers.length-1,selectedLayer));}
function pt(layer:number,y:number,z:number):Point{
  if(presentation==='sheets')return {x:z+((s.p-1)*DX+W+50)/2+35,y:layer*sheetPitch()+((s.p-1)*DY+H+50)/2-y+105};
  return project((layer-(layers.length-1)/2)*1100*spacing,y,z,yaw,tilt);
}
function center(pe:PE){return {y:((s.p-1)/2-pe.y)*DY,z:(pe.x-(s.p-1)/2)*DX};}
function position(layer:number,pe:PE,field:BufferName,slot:number){
  const c=center(pe),left=c.z-W/2,top=c.y+H/2;
  const outputTop=layerGeometry(s).outputTop;
  if(s.kind==='gemv')return pt(layer,top-outputTop-(['partial','peer','result'].indexOf(field))*44-26,left+100+(slot+.5)*(310/s.t));
  return pt(layer,top-outputTop-45-Math.floor(slot/s.slot_columns)*32,left+50+((slot%s.slot_columns)+.5)*(350/s.slot_columns));
}
function polygon(points:Point[]){return points.map(p=>`${p.x.toFixed(2)},${p.y.toFixed(2)}`).join(' ');}
function textAt(p:Point,text:string,cls:string,extra=''){return `<text x="${p.x}" y="${p.y}" class="${cls}" ${extra}>${esc(text)}</text>`;}
function save(){history.replaceState(null,'','#'+new URLSearchParams({scene:s.id,output:String(target),layer:String(selectedLayer),pe:selectedPE,buffer:selectedBuffer,sampling,count:String(count),anchor:String(anchor),view:presentation}));}

function drawInputs(layer:number,pe:PE,cycle:number,left:number,top:number){
  const g=layerGeometry(s),arrays=layerInputs(s,pe,cycle);
  let out=textAt(pt(layer,top-70,left+14),'INPUT ARRAYS · PE-local SRAM','input-band-label');
  for(const [n,array] of arrays.entries()){
    const band=Math.floor(n/2),x=left+16+(n%2)*210,y=top-94-band*g.bandHeight;
    if(n===2)out+=textAt(pt(layer,y+25,left+14),'SRAM RECEIVE BUFFERS · observed operands','input-band-label');
    out+=`<g data-layer-array="${array.key}" data-array-pe="${pe.id}" data-array-cycle="${cycle}">`;
    out+=textAt(pt(layer,y,x),array.label,'input-array-name');
    out+=textAt(pt(layer,y-20,x),array.note,'input-array-note');
    const cw=Math.min(44,156/array.cols.length),start=x+28;
    for(let col=0;col<array.cols.length;col++)out+=textAt(pt(layer,y-40,start+(col+.5)*cw),array.cols[col],'input-index','text-anchor="middle"');
    for(let row=0;row<array.rows.length;row++){
      out+=textAt(pt(layer,y-64-row*30,x+10),array.rows[row],'input-index','text-anchor="middle"');
      for(let col=0;col<array.cols.length;col++){
        const index=row*array.cols.length+col,p=pt(layer,y-64-row*30,start+(col+.5)*cw),v=array.values[index];
        const active=array.active.includes(index);
        out+=`<g role="button" tabindex="0" data-pick="${layer}|${pe.id}|partial|${Math.max(0,slotFor(s,pe,target))}" data-input-cell="${array.key}:${index}" data-value="${v??'unknown'}" aria-label="${esc(array.titles[index])}"><title>${esc(array.titles[index])}</title>`;
        if(active)out+=`<rect x="${p.x-18}" y="${p.y-21}" width="36" height="27" rx="3" class="input-operand-highlight"/>`;
        out+=textAt(p,v===null?'?':String(v),`input-array-value ${v===null?'unknown':''} ${active?'operand':''}`,'text-anchor="middle"')+'</g>';
      }
    }
    out+='</g>';
  }
  return out;
}

function draw(){
  const svg=document.querySelector<SVGSVGElement>('#layer-stage')!;
  const planeW=(s.p-1)*DX+W+50,planeH=(s.p-1)*DY+H+50;
  const corners=(l:number)=>[pt(l,planeH/2,-planeW/2),pt(l,planeH/2,planeW/2),pt(l,-planeH/2,planeW/2),pt(l,-planeH/2,-planeW/2)];
  const bounds=(focus?[selectedLayer]:layers.map((_,i)=>i)).flatMap(l=>[...corners(l),pt(l,planeH/2+95,-planeW/2),pt(l,-planeH/2-110,planeW/2)]);
  const minX=Math.min(...bounds.map(p=>p.x)),maxX=Math.max(...bounds.map(p=>p.x)),minY=Math.min(...bounds.map(p=>p.y)),maxY=Math.max(...bounds.map(p=>p.y));
  const scale=Math.min((VW-110)/(maxX-minX+160),(VH-120)/(maxY-minY+30))*zoom;
  const transform=presentation==='sheets'?'':`translate(${VW/2+panX} ${VH/2+panY+5}) scale(${scale}) translate(${-(minX+maxX)/2} ${-(minY+maxY)/2})`;
  svg.classList.toggle('sheets',presentation==='sheets');
  svg.setAttribute('viewBox',presentation==='sheets'?`0 0 ${planeW+70} ${sheetPitch()*layers.length+35}`:`0 0 ${VW} ${VH}`);
  document.querySelector<HTMLElement>('.layer-scroll')!.style.setProperty('--sheet-aspect',String((planeW+70)/sheetPitch()));
  let temporal='';
  for(let l=0;l<layers.length-1&&!(focus&&presentation==='stack');l++)for(const pe of s.pes){
    const c=center(pe),a=pt(l,c.y,c.z),b=pt(l+1,c.y,c.z);
    temporal+=`<path class="temporal-link ${pe.id===selectedPE?'selected':''}" d="M${a.x},${a.y} L${b.x},${b.y}"><title>Same PE (${pe.id}) at cycles ${layers[l].cycle} and ${layers[l+1].cycle}; snapshot continuity</title></path>`;
  }
  let planes='';
  for(let l=layers.length-1;l>=0;l--){
    if(focus&&presentation==='stack'&&l!==selectedLayer)continue;
    const frame=layers[l];
    planes+=`<g data-layer-plane="${l}"><polygon class="plane-sheet ${l===selectedLayer?'active':''}" points="${polygon(corners(l))}"/>`;
    planes+=textAt(pt(l,planeH/2+78,-planeW/2),`L${l+1}  ${frame.label}`,'layer-title '+(l===selectedLayer?'active':''));
    planes+=textAt(pt(l,planeH/2+43,-planeW/2),`cycle ${frame.cycle.toLocaleString('en-US')}`,'layer-cycle');
    for(const pe of s.pes){
      const c=center(pe),left=c.z-W/2,top=c.y+H/2,contributor=slotFor(s,pe,target)>=0;
      const coords=[pt(l,top,left),pt(l,top,left+W),pt(l,top-H,left+W),pt(l,top-H,left)];
      const state=frame.states[pe.id];
      planes+=`<g data-mesh-node="${l}|${pe.id}" opacity="${presentation==='stack'&&highlight&&!contributor ? .45 : 1}"><polygon class="pe-face ${contributor?'contributor':''} ${l===selectedLayer&&pe.id===selectedPE?'selected':''}" points="${polygon(coords)}"/>`;
      const pick=`${l}|${pe.id}|partial|${Math.max(0,slotFor(s,pe,target))}`;
      planes+=`<g role="button" tabindex="0" data-pick="${pick}" class="pick-target" aria-label="Layer ${l+1}, PE ${pe.id}, cycle ${frame.cycle}">${textAt(pt(l,top-25,left+14),`PE (${pe.id})`,'tile-title')}</g>`;
      planes+=textAt(pt(l,top-48,left+14),state.phase==='not yet observed'?'unobserved':state.phase,'buffer-label');
      planes+=drawInputs(l,pe,frame.cycle,left,top);
      const outputTop=layerGeometry(s).outputTop;
      planes+=textAt(pt(l,top-outputTop+5,left+14),'OBSERVED OUTPUTS','input-band-label');
      const fields:BufferName[]=s.kind==='gemv'?['partial','peer','result']:['partial'];
      for(const field of fields){
        if(s.kind==='gemv')planes+=textAt(pt(l,top-outputTop-fields.indexOf(field)*44-26,left+13),field==='partial'?'P':field==='peer'?'recv':'Y','buffer-label');
        for(let index=0;index<s.slots;index++){
          const p=position(l,pe,field,index),value=state[field][index],active=slotFor(s,pe,target)===index;
          planes+=`<g role="button" tabindex="0" data-pick="${l}|${pe.id}|${field}|${index}" aria-label="Layer ${l+1}, PE ${pe.id}, ${field} ${index}: ${value===null?'unknown':value}"><title>${outputLabel(s,outputFor(s,pe,index))} · ${field} · cycle ${frame.cycle}</title>`;
          if(active)planes+=`<rect x="${p.x-21}" y="${p.y-23}" width="42" height="29" rx="4" fill="var(--cs)"/>`;
          planes+=textAt(p,value===null?'?':String(value),`value ${active?'focus-value':''} ${value===null?'unknown':''}`,'text-anchor="middle"')+'</g>';
        }
      }
      if(s.kind==='gemm')planes+=textAt(pt(l,top-outputTop-23,left+14),'C · local row / column','buffer-label');
      const input=inputStateAt(s,pe,frame.cycle),last=input.last_multiply;
      planes+=textAt(pt(l,top-H+18,left+14),last?`Last PE ×: ${last.a} × ${last.b} = ${last.value} · ${s.kind==='gemv'?`Y[${last.j}]`:`C[${last.i},${last.j}]`}`:'No multiply observed yet','input-use-label');
      planes+='</g>';
    }
    planes+='</g>';
  }
  let links='';
  if(showTransfers)for(const link of transfersFor(s,target)){
    const mapped=transferLayers(link,layers);if(!mapped)continue;
    const [a,b]=mapped;if(focus&&presentation==='stack'&&(a!==selectedLayer||b!==selectedLayer))continue;
    const from=position(a,peById(link.source),link.sourceField,link.index),to=position(b,peById(link.destination),link.destinationField,link.index);
    const cx=(from.x+to.x)/2,cy=Math.min(from.y,to.y)-100;
    links+=`<g data-logical-link="${link.id}" data-link-layer="${b}" data-link-pe="${link.destination}" data-link-buffer="${link.destinationField}"><path class="transfer-link" d="M${from.x},${from.y} Q${cx},${cy} ${to.x},${to.y}" marker-end="url(#transfer-arrow)"><title>Logical ${link.kind} transfer: ${link.value}. Source ready by ${link.sourceReady}, destination available by ${link.destinationAvailable}. These are checkpoint bounds, not packet timing.</title></path>${textAt({x:cx,y:.25*from.y+.5*cy+.25*to.y-16},`${link.value} · ${link.kind==='partial'?'partial':'replica'}`,'transfer-label','text-anchor="middle"')}</g>`;
  }
  const a=pt(0,-planeH/2-90,0),b=pt(layers.length-1,-planeH/2-90,0);
  const axis=presentation==='sheets'||focus?'':`<path d="M${a.x},${a.y} L${b.x},${b.y}" fill="none" stroke="var(--muted)" stroke-width="2" marker-end="url(#time-arrow)"/>${textAt({x:(a.x+b.x)/2,y:(a.y+b.y)/2+34},'TIME →  successive snapshots','axis-label','text-anchor="middle"')}`;
  svg.innerHTML=`<defs><marker id="transfer-arrow" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto"><path d="M0,0 L6,3 L0,6" fill="var(--b)"/></marker><marker id="time-arrow" markerWidth="7" markerHeight="7" refX="6" refY="3" orient="auto"><path d="M0,0 L7,3 L0,6" fill="var(--muted)"/></marker></defs><g transform="${transform}">${temporal}${planes}${links}${axis}</g>`;
  document.querySelector('#camera-readout')!.textContent=presentation==='sheets'?'Scroll through time · click a PE or value':`rotation ${Math.round(yaw)}° · tilt ${Math.round(tilt)}° · zoom ${zoom.toFixed(1)}×`;
}

function microscope(){
  const frame=current(),pe=peById(selectedPE),slot=selectedSlot(),state=frame.states[pe.id];
  const ops=numericEvents(s,pe.id,slot,frame.cycle),last=[...ops].reverse().find(e=>e.kind==='accumulate'||e.kind==='reduce');
  const prev=layers[Math.max(0,selectedLayer-1)].cycle;
  const recent=s.events.filter(e=>e.pe===pe.id&&e.cycle>prev&&e.cycle<=frame.cycle);
  let flow='<p class="empty-state">No matched update for this output on this PE by the selected frame.</p>';
  const chip=(name:string,value:string,note:string,cls='')=>`<div class="micro-node ${cls}"><span>${esc(name)}</span><b>${esc(value)}</b><small>${esc(note)}</small></div>`;
  if(last){
    if(last.kind==='reduce')flow=chip('Local partial',String(last.old),'from this PE')+'<span class="micro-arrow">+</span>'+chip('Received partial',String(last.addend),'from the top PE')+'<span class="micro-arrow">→</span>'+chip('FADDS',String(last.value),`execute cycle ${last.cycle}`,'op');
    else{
      const mul=[...ops].reverse().find(e=>e.kind==='multiply'&&e.k===last.k&&e.j===last.j&&e.i===last.i&&e.cycle<=last.cycle);
      if(mul)flow=chip(s.kind==='gemv'?`X[${last.k}]`:`A[${last.i},${last.k}]`,String(mul.a),'input operand')+'<span class="micro-arrow">×</span>'+chip(s.kind==='gemv'?`W[${last.k},${last.j}]`:`B[${last.k},${last.j}]`,String(mul.b),'input operand')+'<span class="micro-arrow">→</span>'+chip('FMULS',String(mul.value),`cycle ${mul.cycle}`)+'<span class="micro-arrow">+</span>'+chip('Old partial',String(last.old),'previous accumulator')+'<span class="micro-arrow">→</span>'+chip('FADDS',String(last.value),`cycle ${last.cycle}`,'op');
    }
  }
  return `<div class="layer-inspector"><section class="card"><div class="section-heading"><div><span class="eyebrow">INSIDE THE SELECTED PE</span><h2>PE (${pe.id}) · layer ${selectedLayer+1}</h2></div>${badge(`cycle ${fmt(frame.cycle)}`)}</div><div class="node-picker">${s.pes.map(p=>`<button data-pe="${p.id}" class="${p.id===pe.id?'active':''}">PE (${p.id})</button>`).join('')}</div><p class="subtle">${phaseName(state.phase)} · selected ${outputLabel(s,target)} · selected buffer ${selectedBuffer}</p><div class="layer-buffers">${(['partial',...(s.kind==='gemv'?['peer','result']:[])] as BufferName[]).map(field=>`<div><label>${field==='partial'?'Partial accumulators':field==='peer'?'Received / source buffer':'Results / replicas'}</label>${mini(state[field],s.slot_columns)}</div>`).join('')}</div>${presentation==='stack'?`<div class="stage-inputs inline-inputs">${inputPanel(s,pe,frame.cycle,target)}</div>`:''}<h3>Last matched update for ${outputLabel(s,target)}</h3><div class="micro-flow">${flow}</div>${last?.instruction?`<p class="mono">${esc(last.instruction.assembly)} · PC ${hex(last.instruction.pc)} · UID ${last.instruction.uid}</p><p class="row-bits">${bits(last.old!)} + ${bits(last.addend!)} → ${bits(last.value!)}</p><details><summary>Raw trace row references</summary><p class="mono">${last.instruction.raw_rows.join(', ')}</p></details>`:''}<p class="note">The equation is the last matching update at or before this frame. It is not asserted to execute at the frame's cycle. Buffer values are established by arithmetic observations or recorded checkpoints; this is not a register-file or SRAM dump.</p><div class="lineage-table"><table><thead><tr><th>Layer</th><th>Cycle</th><th>Partial</th>${s.kind==='gemv'?'<th>Received</th><th>Result</th>':''}</tr></thead><tbody>${layers.map((l,i)=>`<tr class="${i===selectedLayer?'current':''}"><td><button class="event-select" data-layer="${i}">L${i+1}</button></td><td>${fmt(l.cycle)}</td><td>${fmt(l.states[pe.id].partial[slot])}</td>${s.kind==='gemv'?`<td>${fmt(l.states[pe.id].peer[slot])}</td><td>${fmt(l.states[pe.id].result[slot])}</td>`:''}</tr>`).join('')}</tbody></table></div></section>
  <section class="card"><span class="eyebrow">ACROSS THIS TIME INTERVAL</span><h2>${fmt(prev)} → ${fmt(frame.cycle)}</h2><p class="subtle">${recent.length} bound observations on PE (${pe.id})</p><div class="frame-events">${recent.map(e=>`<div class="history-row"><small>${fmt(e.cycle)} · ${e.kind}</small><strong>${esc(eventText(e))}</strong></div>`).join('')||'<p class="empty-state">No new bound observation in this interval. The diagram carries the last known value forward.</p>'}</div><details><summary>Final readback — untimed comparison</summary>${mini(pe.final_readback,s.slot_columns)}</details><div class="link-note">${s.kind==='gemv'&&s.p===2?transfersFor(s,target).map(link=>`${link.kind==='partial'?'Partial':'Replica'} <b>${link.value}</b>: PE (${link.source}) → (${link.destination}). Source ready by cycle <b>${fmt(link.sourceReady)}</b>; destination available by <b>${fmt(link.destinationAvailable)}</b>.`).join('<br><br>'):'This capture has no supported cross-PE value-transfer binding in this view. Its time links show the same PE across successive snapshots.'}<br><br>Dashed links describe the compiled algorithm and checked endpoint values. They do not describe an observed packet path or flight duration.</div></section></div>`;
}

function render(){
  prepare();save();
  app.innerHTML=`${header('SPACE × TIME / PE LAYERS')}<main><div class="intro layer-intro"><div><p class="eyebrow">ONE MESH, REPEATED THROUGH TIME</p><h1>Layers of execution.</h1><p class="subtitle">Every plane is the same PE mesh at a different cycle. Select a number to follow its history and inspect the computation inside a PE.</p></div><div class="intro-evidence">${badge(outputLabel(s,target),'green')}<span>${layers.length} layers · ${s.p*s.p} PEs in each layer</span></div></div><nav class="scene-nav" aria-label="Layered workload selection">${bundle.scenes.map(scene=>`<button data-scene="${scene.id}" class="${scene.id===s.id?'selected':''}"><span><b>${scene.n} × ${scene.n} ${scene.kind.toUpperCase()}</b><small>${scene.p*scene.p} PE${scene.p>1?'s':''}</small></span></button>`).join('')}</nav>
  <section class="card layer-tools"><label>Presentation<select id="presentation"><option value="sheets" ${presentation==='sheets'?'selected':''}>Readable time layers</option><option value="stack" ${presentation==='stack'?'selected':''}>3D stack overview</option></select></label><label>Follow output<select id="output">${Array.from({length:s.kind==='gemv'?s.n:s.n*s.n},(_,i)=>`<option value="${i}" ${i===target?'selected':''}>${outputLabel(s,i)}</option>`).join('')}</select></label><label>Choose time layers<select id="sampling"><option value="story" ${sampling==='story'?'selected':''}>Work through this output</option><option value="uniform" ${sampling==='uniform'?'selected':''}>Equal cycle intervals</option><option value="events" ${sampling==='events'?'selected':''}>Consecutive event frames</option></select></label><label>Layers<input id="count" type="number" min="3" max="8" value="${sampling==='story'?layers.length:count}" ${sampling==='story'?'disabled':''}></label><div class="layer-playback"><button id="previous" aria-label="Previous layer">←</button><button id="play" aria-label="${playing?'Pause':'Play'} layers">${playing?'Ⅱ':'▶'}</button><button id="next" aria-label="Next layer">→</button></div><div class="tool-separator"></div><label>Layer spacing<input id="spacing" type="range" min="0.7" max="1.7" step="0.05" value="${spacing}"></label><label class="inline-control"><input id="highlight" type="checkbox" ${highlight?'checked':''}> highlight contributors</label><label class="inline-control"><input id="transfers" type="checkbox" ${showTransfers?'checked':''}> logical transfers</label><button id="export-svg" class="download-svg">Export SVG</button>${sampling==='events'?`<div class="event-window-control"><span>Event window</span><input id="anchor" type="range" min="0" max="${s.cycles.length}" value="${anchor}" aria-label="Event window"><span>${anchor} / ${s.cycles.length}</span></div>`:''}</section>
  <div class="stack-and-inputs ${presentation==='stack'?'stack-overview':''}"><section class="stage-shell"><div class="layer-help">${presentation==='stack'?'Drag to rotate · shift-drag to pan · wheel to zoom':'Inputs and observed values are inside every PE tile'}<br><span id="camera-readout"></span></div><div class="layer-view-actions"><button id="zoom-out" aria-label="Zoom out">−</button><button id="zoom-in" aria-label="Zoom in">+</button><button id="focus">${focus?'Show full stack':'Expand selected layer'}</button><button id="reset">Reset view</button></div><div class="layer-scroll ${presentation==='sheets'?'readable':''}"><svg id="layer-stage" class="layer-stage" viewBox="0 0 ${VW} ${VH}" role="group" aria-label="Interactive stacked PE meshes across time" tabindex="0"></svg></div><div class="layer-legend"><span><b>X/W · A/B</b> host-loaded inputs</span><span><b>abuf/bbuf</b> received input operands</span><span><i class="legend-line"></i>same PE at a later snapshot</span><span><i class="legend-line transfer"></i>logical value transfer, checked endpoints</span><span>${s.kind==='gemv'?'<b>P</b> partial · <b>recv</b> received/source buffer · <b>Y</b> result':'<b>C</b> output-tile accumulators'}</span><span><b>?</b> not observed by that layer</span></div></section>${presentation==='sheets'?`<aside class="card stage-inputs">${inputPanel(s,peById(selectedPE),current().cycle,target)}</aside>`:''}</div>
  <nav class="layer-rail" aria-label="Time layers" style="--layers:${layers.length}">${layers.map((l,i)=>`<button data-layer="${i}" class="${i===selectedLayer?'active':''}" aria-pressed="${i===selectedLayer}"><strong>L${i+1} · ${esc(l.label)}</strong><span>${fmt(l.cycle)}</span><small>${i?'Δ '+fmt(l.cycle-layers[i-1].cycle)+' cycles':'first displayed frame'}</small></button>`).join('')}</nav><p class="stack-caption">${sampling==='uniform'?'Layers sample equal cycle intervals.':'Layers use selected recorded times; their geometric spacing is for readability and is not proportional to elapsed time.'} Each plane has its own timestamp. Other PEs may be at different phases in the same plane.</p>${microscope()}
  <section class="card layer-provenance"><div class="section-heading"><div><span class="eyebrow">EVIDENCE AND SHARING</span><h2>Numbers first, geometry second.</h2></div><button id="export-data">Export displayed layer data</button></div><p class="note">${esc(s.limitations)} Camera rotation and spacing change only the presentation. Values use the same checked state reducer as the time-slice view.</p><details><summary>Source identity and visual inspiration</summary><p class="mono">${esc(s.provenance.source_bundle)}<br>SHA-256 ${s.provenance.source_sha256}</p><p class="note">Inspired by the stacked node-link organization in Adam Harley's <a href="https://github.com/aharley/nn_vis">interactive CNN visualization</a>. Here a layer represents a later state of the same physical mesh. The frontend is implemented independently and reuses the existing checked GEMV/GEMM observations.</p></details></section><footer>WSE-3 / layers of execution <span>Spatial mesh × recorded time × numeric state</span></footer></main>`;
  bind();draw();
  if(presentation==='sheets'){
    const scroll=document.querySelector<HTMLElement>('.layer-scroll')!,svg=document.querySelector<SVGSVGElement>('#layer-stage')!;
    scroll.scrollTop=selectedLayer*sheetPitch()*svg.clientWidth/svg.viewBox.baseVal.width;
  }
}

function selectPick(value:string){
  const [layer,pe,field,index]=value.split('|');stop();selectedLayer=Number(layer);selectedPE=pe;selectedBuffer=field as BufferName;
  const nextTarget=outputFor(s,peById(pe),Number(index));
  if(nextTarget!==target){const oldCycle=current().cycle;target=nextTarget;prepare();selectedLayer=layers.reduce((best,l,i)=>Math.abs(l.cycle-oldCycle)<Math.abs(layers[best].cycle-oldCycle)?i:best,0);}
  render();
}

function exportSvg(){
  const original=document.querySelector<SVGSVGElement>('#layer-stage')!,clone=original.cloneNode(true) as SVGSVGElement;
  const originals=[original,...original.querySelectorAll('*')],clones=[clone,...clone.querySelectorAll('*')];
  const properties=['fill','fill-opacity','stroke','stroke-width','stroke-opacity','stroke-dasharray','stroke-linecap','stroke-linejoin','paint-order','font-family','font-size','font-weight','text-anchor','opacity'];
  originals.forEach((el,i)=>{
    const style=getComputedStyle(el);
    clones[i].setAttribute('style',properties.map(p=>`${p}:${style.getPropertyValue(p)}`).join(';'));
    // Computed styles now carry these values. Remove page-only variable references
    // from presentation attributes so the exported SVG has no CSS dependencies.
    for(const attr of [...clones[i].attributes])if(attr.value.includes('var('))clones[i].removeAttribute(attr.name);
  });
  const {width,height}=original.viewBox.baseVal;
  clone.setAttribute('xmlns','http://www.w3.org/2000/svg');clone.setAttribute('width','1800');clone.setAttribute('height',String(Math.round(1800*height/width)));
  const bg=document.createElementNS('http://www.w3.org/2000/svg','rect');bg.setAttribute('width',String(width));bg.setAttribute('height',String(height));bg.setAttribute('fill',getComputedStyle(document.documentElement).getPropertyValue('--paper').trim()||'#fff');clone.prepend(bg);
  const data=new XMLSerializer().serializeToString(clone),url=URL.createObjectURL(new Blob([data],{type:'image/svg+xml'}));
  const a=document.createElement('a');a.href=url;a.download=`${s.id}-pe-time-layers.svg`;a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);
}

function bind(){
  theme();
  document.querySelector<HTMLSelectElement>('#presentation')!.onchange=e=>{presentation=(e.target as HTMLSelectElement).value;resetCamera();render();};
  events('[data-scene]',el=>{stop();s=bundle.scenes.find(v=>v.id===el.dataset.scene)!;target=0;selectedPE=s.kind==='gemv'&&s.p>1?'0,1':'0,0';selectedBuffer=s.kind==='gemv'?'result':'partial';selectedLayer=3;anchor=0;resetCamera();render();});
  events('[data-layer]',el=>{stop();selectedLayer=Number(el.dataset.layer);render();});
  events('[data-input-select]',el=>selectPick(`${selectedLayer}|${el.dataset.inputSelect}|${selectedBuffer}|${Math.max(0,slotFor(s,peById(el.dataset.inputSelect!),target))}`));
  events('[data-pe]',el=>selectPick(`${selectedLayer}|${el.dataset.pe}|${selectedBuffer}|${Math.max(0,slotFor(s,peById(el.dataset.pe!),target))}`));
  document.querySelector<HTMLSelectElement>('#output')!.onchange=e=>{stop();target=Number((e.target as HTMLSelectElement).value);const candidates=s.pes.filter(pe=>slotFor(s,pe,target)>=0);if(!candidates.some(pe=>pe.id===selectedPE))selectedPE=candidates.at(-1)!.id;render();};
  document.querySelector<HTMLSelectElement>('#sampling')!.onchange=e=>{stop();sampling=(e.target as HTMLSelectElement).value;anchor=Math.max(0,s.cycles.findIndex(c=>c>=current().cycle));resetCamera();render();};
  document.querySelector<HTMLInputElement>('#count')!.onchange=e=>{count=Math.max(3,Math.min(8,Math.floor(Number((e.target as HTMLInputElement).value))||6));render();};
  document.querySelector<HTMLInputElement>('#spacing')!.oninput=e=>{spacing=Number((e.target as HTMLInputElement).value);draw();};
  document.querySelector<HTMLInputElement>('#highlight')!.onchange=e=>{highlight=(e.target as HTMLInputElement).checked;draw();};
  document.querySelector<HTMLInputElement>('#transfers')!.onchange=e=>{showTransfers=(e.target as HTMLInputElement).checked;draw();};
  const anchorInput=document.querySelector<HTMLInputElement>('#anchor');if(anchorInput)anchorInput.oninput=e=>{anchor=Number((e.target as HTMLInputElement).value);render();};
  const step=(delta:number)=>{selectedLayer=Math.max(0,Math.min(layers.length-1,selectedLayer+delta));render();};
  events('#previous',()=>{stop();step(-1);});events('#next',()=>{stop();step(1);});
  events('#play',()=>{if(playing){stop();render();return;}if(selectedLayer===layers.length-1)selectedLayer=0;playing=window.setInterval(()=>{if(selectedLayer===layers.length-1){stop();render();}else step(1);},1300);render();});
  events('#focus',()=>{if(presentation==='sheets'){presentation='stack';focus=false;}focus=!focus;zoom=1;panX=panY=0;render();});events('#reset',()=>{resetCamera();yaw=52;tilt=12;spacing=1;render();});
  events('#zoom-in',()=>{zoom=Math.min(4,zoom*1.2);draw();});events('#zoom-out',()=>{zoom=Math.max(.4,zoom/1.2);draw();});
  events('#export-svg',exportSvg);events('#export-data',()=>download(`${s.id}-pe-time-layers.json`,{schema:'pe-time-layers/1',scene:s.id,output:outputLabel(s,target),sampling,layers,inputs:layers.map(l=>({cycle:l.cycle,pes:s.pes.map(pe=>inputStateAt(s,pe,l.cycle))})),logical_transfers:transfersFor(s,target),provenance:s.provenance}));
  const svg=document.querySelector<SVGSVGElement>('#layer-stage')!;
  let pointer:{x:number;y:number;yaw:number;tilt:number;panX:number;panY:number;shift:boolean;target:Element}|null=null,moved=false;
  svg.onpointerdown=e=>{if(e.button!==0)return;pointer={x:e.clientX,y:e.clientY,yaw,tilt,panX,panY,shift:e.shiftKey,target:e.target as Element};moved=false;svg.setPointerCapture(e.pointerId);svg.classList.add('dragging');};
  svg.onpointermove=e=>{if(!pointer||presentation==='sheets')return;const dx=e.clientX-pointer.x,dy=e.clientY-pointer.y;if(Math.abs(dx)+Math.abs(dy)>4)moved=true;if(!moved)return;
    if(pointer.shift){panX=pointer.panX+dx*VW/svg.clientWidth;panY=pointer.panY+dy*VH/svg.clientHeight;}else{yaw=Math.max(35,Math.min(72,pointer.yaw+dx*.12));tilt=Math.max(-24,Math.min(26,pointer.tilt+dy*.10));}draw();};
  svg.onpointerup=e=>{const p=pointer;pointer=null;svg.classList.remove('dragging');if(svg.hasPointerCapture(e.pointerId))svg.releasePointerCapture(e.pointerId);if(!p||moved)return;
    const pick=p.target.closest('[data-pick]');if(pick){selectPick(pick.getAttribute('data-pick')!);return;}
    const link=p.target.closest('[data-logical-link]');if(link){selectedLayer=Number(link.getAttribute('data-link-layer'));selectedPE=link.getAttribute('data-link-pe')!;selectedBuffer=link.getAttribute('data-link-buffer') as BufferName;render();}};
  svg.onpointercancel=()=>{pointer=null;svg.classList.remove('dragging');};
  svg.addEventListener('wheel',e=>{if(presentation==='sheets')return;e.preventDefault();zoom=Math.max(.4,Math.min(4,zoom*Math.exp(-e.deltaY*.001)));draw();},{passive:false});
  svg.onkeydown=e=>{if(['Enter',' '].includes(e.key)){const pick=(e.target as Element).closest('[data-pick]');if(pick){e.preventDefault();selectPick(pick.getAttribute('data-pick')!);}}};
}

async function init(){try{
  bundle=window.TIME_BUNDLE||await fetch('./time-bundle.json').then(r=>{if(!r.ok)throw Error('Export time-bundle.json before building the layered view.');return r.json();});
  if(bundle.schema!=='time-slices/1'||!bundle.scenes.length)throw Error('Unsupported time-layer data');
  const h=new URLSearchParams(location.hash.slice(1));s=bundle.scenes.find(v=>v.id===h.get('scene'))||bundle.scenes.find(v=>v.id==='v1')||bundle.scenes[0];
  presentation=h.get('view')==='sheets'?'sheets':'stack';
  target=Math.max(0,Math.min((s.kind==='gemv'?s.n:s.n*s.n)-1,Math.floor(Number(h.get('output')))||0));
  sampling=['story','uniform','events'].includes(h.get('sampling')||'')?h.get('sampling')!:'story';count=Math.max(3,Math.min(8,Number(h.get('count'))||6));anchor=Math.max(0,Math.min(s.cycles.length,Number(h.get('anchor'))||0));
  const contributors=s.pes.filter(pe=>slotFor(s,pe,target)>=0);
  selectedPE=contributors.some(p=>p.id===h.get('pe'))?h.get('pe')!:contributors.at(-1)!.id;
  selectedLayer=h.has('layer')?Math.max(0,Math.floor(Number(h.get('layer')))||0):3;
  selectedBuffer=['partial','peer','result'].includes(h.get('buffer')||'')?h.get('buffer') as BufferName:'result';
  if(s.kind==='gemm')selectedBuffer='partial';
  render();window.addEventListener('keydown',e=>{if((e.target as HTMLElement).matches('input,select,textarea'))return;if(e.key==='ArrowRight'||e.key==='ArrowLeft'){e.preventDefault();stop();selectedLayer=Math.max(0,Math.min(layers.length-1,selectedLayer+(e.key==='ArrowRight'?1:-1)));render();}});
}catch(e){app.innerHTML=`<div class="bundle-error"><h1>Could not load the PE layers</h1><p>${esc(e)}</p></div>`;}}
void init();
