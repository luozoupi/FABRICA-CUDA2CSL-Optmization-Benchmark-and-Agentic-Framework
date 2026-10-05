import {DataflowGL,type Card,type Edge,type V3} from './dataflow-gl';
import {matrix,matrixBoard,palette,escapeHTML as esc,type Values} from './matmul-matrices';
type Tile={id?:string;pe:string;tensor:string;rows:number[];cols:number[];values:number[];packed?:number[];packing?:string;storage?:string;source?:string;round?:number};
type State=Record<string,{partial:number[]|null;result:number[]|null}>;
type Flow={source:string;destination:string;tensor:string;values:number[];packet_ids:string[]};
type Event={id:string;kind:string;pe:string;index:number;cycle:number;i?:number;j?:number;k?:number;a?:number;b?:number;old?:number;addend?:number;value:number;instruction?:{uid:number;pc:number;assembly:string;raw_rows:number[]}};
type Packet={id:string;source:string;destination:string;kind:string;slot:number;value:number;word:number;color:number;observations:{pe:string;cycle:number;row:number;link:string;xy:number[]}[];send?:{cycle:number;row:number};receive?:{cycle:number;row:number};consumer?:{cycle:number;equation:string;assembly:string;pc:number}};
type TeachingStep={id:string;phase:string;title:string;description:string;resident:string[];gathered:string[];state:State;pe?:string;tile?:string;tensor?:string;round?:number;flows?:Flow[];calculations?:{pe:string;k:number;before:number[];a:number[];b:number[];after:number[];products:number[];mul_ids:string[];add_ids:string[]}[];reduction?:{before:number[];incoming:number[];after:number[];event_ids:string[]}};
export type MeshScene={id:string;kind:string;n:number;p:number;t:number;slots:number;slot_columns:number;title:string;pes:{id:string;x:number;y:number;fabric:number[];partial_labels:string[];final_readback:number[]}[];host:{inputs:{name:string;values:number[][]}[];output:number[][];output_name:string;note:string};teaching:{steps:TeachingStep[];tiles:Tile[];output_tiles:Tile[]};input_panels:Tile[];events:Event[];packets:Packet[];storage:{pe:string;arrays:{name:string;elf_address_hex:string;bytes:number;storage:string}[]}[];verification:{passed:boolean};limits:string[]};
const chunks=(a:(number|null)[],n:number):Values=>Array.from({length:Math.ceil(a.length/n)},(_,i)=>a.slice(i*n,(i+1)*n));
const clone=(s:State):State=>structuredClone(s);
export class MeshLesson{
 scene:MeshScene;index=0;sub=0;fine=false;pe='0,0';gl:DataflowGL;timer:number|undefined;
 constructor(public root:HTMLElement,public scenes:MeshScene[]){
  this.scene=scenes[0];
  root.innerHTML=`<div class="mesh-heading"><div><p class="eyebrow">THE SAME NUMBERS · ACROSS FOUR PROCESSING ELEMENTS</p><h2 id="mesh-heading"></h2></div><label>Capture<select id="mesh-capture">${scenes.map(s=>`<option value="${s.id}">${s.kind==='gemm'?'GEMM':'MeshGEMV'} · ${s.n} × ${s.n} · ${s.p} × ${s.p} PEs</option>`).join('')}</select></label></div><nav id="mesh-chapters" class="phase-rail" aria-label="Mesh workflow"></nav><div class="lesson-columns"><section class="paper"><div class="lesson-heading"><b id="mesh-title"></b><span id="mesh-count"></span></div><div id="mesh-matrices"></div><div class="lesson-transport"><button id="mesh-reset">↺ Start</button><button id="mesh-back">←</button><button id="mesh-play">▶ Play</button><button id="mesh-next">→</button><input id="mesh-scrub" type="range" min="0" aria-label="Mesh workflow step"></div><div class="granularity"><span>Granularity</span><button id="mesh-coarse" aria-pressed="true">Coarse · workflow</button><button id="mesh-fine" aria-pressed="false">Fine · event / word</button></div><p id="mesh-description" class="lesson-description"></p><div id="mesh-fine-picker" class="scalar-picker"></div><p id="mesh-equation" class="lesson-equation"></p></section><aside class="paper"><div id="mesh-pe-picker" class="pe-picker"></div><div id="mesh-inspector"></div></aside></div><section class="paper mesh-physical"><div class="lesson-heading"><b>Where the data goes · WebGL PE map</b><button id="mesh-camera">Reset camera</button></div><canvas id="mesh-canvas" aria-label="WebGL mesh input placement and packet routes"></canvas><p class="matrix-legend">Blue: A/X · teal: B/W · purple: partials · orange: results. Solid arrows follow matched application packets; dashed host routes are schematic. Click a PE to inspect its local arrays.</p></section><section id="mesh-transfer" class="paper transfer-ledger"></section><details class="evidence"><summary>What the capture establishes</summary><div id="mesh-limits"></div></details>`;
  this.gl=new DataflowGL(root.querySelector('#mesh-canvas')!,true);this.gl.yaw=0;this.gl.tilt=0;
  this.gl.onPick=id=>{if(id.startsWith('pe:')){this.pe=id.slice(3);this.render();}};
  this.on('#mesh-capture','change',e=>this.select((e.target as HTMLSelectElement).value));
  this.on('#mesh-next','click',()=>{this.stop();this.move(1);});this.on('#mesh-back','click',()=>{this.stop();this.move(-1);});
  this.on('#mesh-reset','click',()=>{this.stop();this.index=0;this.sub=0;this.render();});
  this.on('#mesh-scrub','input',e=>{this.stop();this.index=+(e.target as HTMLInputElement).value;this.sub=0;this.render();});
  for(const [id,fine] of [['#mesh-coarse',false],['#mesh-fine',true]] as const)this.on(id,'click',()=>{this.stop();this.fine=fine;this.sub=0;this.render();});
  this.on('#mesh-play','click',()=>{if(this.timer){this.stop();return;}this.text('#mesh-play','Ⅱ Pause');this.timer=window.setInterval(()=>{if(this.index===this.scene.teaching.steps.length-1&&this.sub===this.items().length-1){this.stop();return;}this.move(1);},1000);});
  this.on('#mesh-camera','click',()=>{this.gl.reset();this.gl.yaw=0;this.gl.tilt=0;this.gl.draw();});
  this.on('#mesh-chapters','click',e=>{const b=(e.target as HTMLElement).closest<HTMLButtonElement>('[data-mesh-step]');if(b){this.stop();this.index=+b.dataset.meshStep!;this.sub=0;this.render();}});
  this.on('#mesh-pe-picker','click',e=>{const b=(e.target as HTMLElement).closest<HTMLButtonElement>('[data-pe]');if(b){this.pe=b.dataset.pe!;this.render();}});
  this.on('#mesh-fine-picker','click',e=>{const b=(e.target as HTMLElement).closest<HTMLButtonElement>('[data-sub]');if(b){this.stop();this.sub=+b.dataset.sub!;this.render();}});
  this.render();
 }
 on(id:string,event:string,fn:(e:globalThis.Event)=>void){this.root.querySelector(id)!.addEventListener(event,fn);}
 text(id:string,text:string){this.root.querySelector(id)!.textContent=text;}
 html(id:string,text:string){this.root.querySelector(id)!.innerHTML=text;}
 stop(){clearInterval(this.timer);this.timer=undefined;this.text('#mesh-play','▶ Play');}
 select(id:string){this.stop();this.scene=this.scenes.find(s=>s.id===id)!;this.index=0;this.sub=0;this.pe='0,0';(this.root.querySelector('#mesh-capture') as HTMLSelectElement).value=id;this.render();}
 items():Array<Event|Packet|null>{
  const st=this.scene.teaching.steps[this.index];
  const ids=st.calculations?.flatMap(c=>[...c.mul_ids,...c.add_ids])??st.reduction?.event_ids??[];
  if(ids.length)return this.scene.events.filter(e=>ids.includes(e.id)).sort((a,b)=>a.cycle-b.cycle||a.id.localeCompare(b.id));
  const packets=st.flows?.flatMap(f=>f.packet_ids)??[];
  return packets.length?packets.map(id=>this.scene.packets.find(p=>p.id===id)!):[null];
 }
 move(d:number){const count=this.fine?this.items().length:1;
  if(this.fine&&this.sub+d>=0&&this.sub+d<count)this.sub+=d;
  else{this.index=Math.max(0,Math.min(this.scene.teaching.steps.length-1,this.index+d));this.sub=d<0&&this.fine?this.items().length-1:0;}this.render();}
 currentState():State{
  const st=this.scene.teaching.steps[this.index],items=this.items();
  if(!this.fine||!items[0]||!('cycle' in items[0]))return st.state;
  const state=clone(this.scene.teaching.steps[Math.max(0,this.index-1)].state);
  for(const e of items.slice(0,this.sub+1) as Event[]){if(e.kind==='accumulate')state[e.pe].partial![e.index]=e.value;else if(e.kind==='reduce'){state[e.pe].result??=Array(this.scene.slots).fill(null);state[e.pe].result![e.index]=e.value;}}
  return state;
 }
 render(){
  const s=this.scene,st=s.teaching.steps[this.index],items=this.items(),item=items[this.sub],state=this.currentState(),before=s.teaching.steps[Math.max(0,this.index-1)].state;
  if(this.fine&&item&&'cycle' in item)this.pe=item.pe;
  if(st.pe&&['place','gather'].includes(st.phase))this.pe=st.pe;
  const pe=s.pes.find(p=>p.id===this.pe)!,gemm=s.kind==='gemm';
  const packet=this.fine&&item&&'observations' in item?item:null;
  const activeTile=s.teaching.tiles.find(t=>t.id===st.tile)??(st.phase==='panel'?s.input_panels.find(t=>t.pe===(packet?.destination??this.pe)&&t.round===st.round&&t.tensor===st.tensor):undefined);
  const calc=st.calculations?.find(c=>c.pe===this.pe);
  const selectedEvent=this.fine&&item&&'cycle' in item?item:null;
  const packetCell=packet&&activeTile?`${activeTile.rows[activeTile.packing==='column-major'?packet.slot%activeTile.rows.length:Math.floor(packet.slot/activeTile.cols.length)]},${activeTile.cols[activeTile.packing==='column-major'?Math.floor(packet.slot/activeTile.rows.length):packet.slot%activeTile.cols.length]}`:undefined;
  const coordinate=(t:Tile)=>t.rows.flatMap(i=>t.cols.map(j=>`${i},${j}`));
  const focusA=activeTile&&['A','X'].includes(activeTile.tensor)?coordinate(activeTile):calc?(gemm?Array.from({length:s.t},(_,i)=>`${pe.y*s.t+i},${calc.k}`):[`0,${calc.k}`]):[];
  const focusB=activeTile&&['B','W'].includes(activeTile.tensor)?coordinate(activeTile):calc?Array.from({length:s.t},(_,j)=>`${calc.k},${pe.x*s.t+j}`):[];
  let output:Values,delta:Values,done:string[]=[];
  if(gemm){output=Array.from({length:s.n},()=>Array(s.n).fill(null));delta=Array.from({length:s.n},()=>Array(s.n).fill(0));
   for(const p of s.pes){const q=state[p.id],values=q.result??q.partial,old=before[p.id].result??before[p.id].partial;
    for(let i=0;i<s.t;i++)for(let j=0;j<s.t;j++){const a=p.y*s.t+i,b=p.x*s.t+j,k=i*s.t+j;output[a][b]=values?.[k]??null;delta[a][b]=values&&old?values[k]-old[k]:0;if(q.result?.[k]!=null)done.push(`${a},${b}`);}}
  }else{const q=state[this.pe],values=q.result??q.partial,old=before[this.pe].result??before[this.pe].partial;output=[values??Array(s.t).fill(null)];delta=[values?.map((v,j)=>old?v-old[j]:0)??Array(s.t).fill(0)];if(q.result)done=q.result.flatMap((x,j)=>x===null?[]:[`0,${j}`]);}
  if(selectedEvent){delta=delta.map(row=>row.map(()=>0));if(selectedEvent.kind!=='multiply'){const row=gemm?pe.y*s.t+Math.floor(selectedEvent.index/s.t):0,col=gemm?pe.x*s.t+selectedEvent.index%s.t:selectedEvent.index;delta[row][col]=selectedEvent.value-(selectedEvent.old??0);}}
  this.text('#mesh-heading',gemm?'GEMM · tiled panels on a 2 × 2 PE mesh':'MeshGEMV · local products, exchanged partials');
  this.text('#mesh-title',st.title);this.text('#mesh-count',`${this.index+1} / ${s.teaching.steps.length}${this.fine?` · ${this.sub+1}/${items.length} events`:''}`);
  const slider=this.root.querySelector<HTMLInputElement>('#mesh-scrub')!;slider.max=String(s.teaching.steps.length-1);slider.value=String(this.index);
  (this.root.querySelector('#mesh-back') as HTMLButtonElement).disabled=this.index===0&&this.sub===0;
  (this.root.querySelector('#mesh-next') as HTMLButtonElement).disabled=this.index===s.teaching.steps.length-1&&(!this.fine||this.sub===items.length-1);
  this.root.querySelector('#mesh-coarse')!.setAttribute('aria-pressed',String(!this.fine));this.root.querySelector('#mesh-fine')!.setAttribute('aria-pressed',String(this.fine));
  this.html('#mesh-chapters',s.teaching.steps.map((t,i)=>`<button data-mesh-step="${i}" aria-current="${i===this.index?'step':'false'}"><small>${i+1}</small>${esc(t.phase==='panel'?`${t.tensor} · round ${t.round!+1}`:t.phase==='compute'?`Compute k=${t.calculations?.[0].k}`:t.phase==='place'?`${t.tensor} → ${t.pe}`:t.phase)}</button>`).join(''));
  this.html('#mesh-matrices',matrixBoard(s.host.inputs[0].values,s.host.inputs[1].values,output,delta,{names:[s.host.inputs[0].name,s.host.inputs[1].name,gemm?'C':`${state[this.pe].result?'Y':'P'} · PE (${this.pe})`],a:{active:focusA,block:s.t,selected:st.tensor==='A'?packetCell:undefined},b:{active:focusB,block:s.t,selected:st.tensor==='B'?packetCell:undefined},c:{block:gemm?s.t:undefined,done},note:gemm?'Reconstructed PE-owned C tiles.':'P is one PE’s local contribution; Y appears after reduction. Global Y is shown in the inspector.'}));
  this.text('#mesh-description',st.description.replace('mint dashed','orange dashed').replace('Use Observed journey or Time layers to inspect the instrumented simulator timeline.','Use Fine mode on a compute or transfer step to inspect recorded events.')+(this.fine?' Fine mode replays this group’s observed arithmetic or payload words. Teaching groups are not a simultaneous wafer snapshot.':''));
  this.html('#mesh-pe-picker',s.pes.map(p=>`<button data-pe="${p.id}" aria-pressed="${p.id===this.pe}">PE (${p.id})</button>`).join(''));
  this.html('#mesh-fine-picker',this.fine?items.map((e,i)=>`<button data-sub="${i}" aria-pressed="${i===this.sub}">${e?'cycle' in e?`${e.pe} · ${e.kind} c${e.cycle}`:`word ${i}: ${e.value}`:'No timed event'}</button>`).join(''):'');
  this.text('#mesh-equation',selectedEvent?selectedEvent.kind==='multiply'?`${selectedEvent.a} × ${selectedEvent.b} = ${selectedEvent.value}`:`${selectedEvent.old} + ${selectedEvent.addend} = ${selectedEvent.value}`:calc?`PE (${this.pe}): ${calc.before[0]} + ${calc.a[0]} × ${calc.b[0]} = ${calc.after[0]} · first cell`:st.reduction?`${st.reduction.before.join(', ')} + ${st.reduction.incoming.join(', ')} → ${st.reduction.after.join(', ')}`:'');
  const resident=s.teaching.tiles.filter(t=>t.pe===this.pe&&st.resident.includes(t.id!));
  const panels=st.round!==undefined?s.input_panels.filter(t=>t.pe===this.pe&&t.round===st.round&&['panel','compute'].includes(st.phase)&&(st.phase!=='panel'||t.tensor===st.tensor)):[];
  const arrays=s.storage.find(x=>x.pe===this.pe)?.arrays??[];
  const local=(t:Tile)=>`<div class="resident-array"><b>${esc(t.tensor)} → ${esc(t.storage)}${t.source&&t.source!==this.pe?` · from PE (${t.source})`:''}</b><small>rows [${t.rows}] · cols [${t.cols}]</small>${matrix(chunks(t.values,t.cols.length),['A','X'].includes(t.tensor)?palette.a:palette.b)}<small>${esc(t.packing)} order in SRAM: [${t.packed??t.values}]</small></div>`;
  const gathered=s.host.output.map(row=>row.map(()=>null)) as Values;
  for(const t of s.teaching.output_tiles.filter(t=>st.gathered.includes(t.pe)))for(let i=0;i<t.rows.length;i++)for(let j=0;j<t.cols.length;j++)gathered[t.rows[i]][t.cols[j]]=t.values[i*t.cols.length+j];
  this.html('#mesh-inspector',`<h3>PE (${this.pe}) <small>fabric (${pe.fabric})</small></h3><p>${gemm?`Owns C rows ${pe.y*s.t}…${(pe.y+1)*s.t-1}, columns ${pe.x*s.t}…${(pe.x+1)*s.t-1}.`:`Computes k=${pe.y*s.t}…${(pe.y+1)*s.t-1}, output columns ${pe.x*s.t}…${(pe.x+1)*s.t-1}.`}</p><h4>Input arrays in local SRAM</h4>${resident.length?resident.map(local).join(''):'<p>Input placement has not occurred in this teaching sequence.</p>'}${panels.length?'<h4>Panels used in this round</h4><p>Checked complete panel history; selecting one packet does not imply all words were present at its cycle.</p>'+panels.map(local).join(''):''}<details><summary>ELF-backed storage</summary>${arrays.map(a=>`<p><code>${esc(a.name)} @ ${a.elf_address_hex}</code> · ${a.bytes} bytes<br>${esc(a.storage)}</p>`).join('')}</details>${selectedEvent?.instruction?`<div class="instruction-evidence"><h4>Observed instruction</h4><code>${esc(selectedEvent.instruction.assembly)}</code><p>c${selectedEvent.cycle} · PC 0x${selectedEvent.instruction.pc.toString(16)} · UID ${selectedEvent.instruction.uid}<br>raw rows ${selectedEvent.instruction.raw_rows.join(', ')}</p></div>`:''}<h4>Host ${s.host.output_name} · assembled readback</h4><div id="mesh-host-output">${matrix(gathered,palette.c,{label:'Host output'})}</div><p>${st.phase==='complete'?'PASS · exact match with retained readback.':'Blank cells have not been gathered in this teaching sequence.'}</p>`);
  this.html('#mesh-limits',`<p>These instrumented f32 mesh runs are distinct from the optimized f16 single-PE comparison. Their times are not comparable kernel rankings.</p><ul>${s.limits.map(x=>`<li>${esc(x)}</li>`).join('')}</ul>`);
  this.draw(state);this.ledger();
 }
 draw(state:State){
  const s=this.scene,st=s.teaching.steps[this.index],cards:Card[]=[],edges:Edge[]=[];
  const position=(id:string):V3=>{const p=s.pes.find(p=>p.id===id)!;return [-2+p.x*8,3.2-p.y*6.4,0];};
  cards.push({id:'host',at:[-12,0,0],width:4,height:3.2,lines:['HOST ARRAYS',`${s.n} × ${s.n} · f32`,'SDK copy mode'],color:palette.a});
  cards.push({id:'west',at:[-8.4,0,0],width:1.9,height:10,lines:['I/O','+','west','support'],color:'#8792a5'});
  cards.push({id:'east',at:[11.6,0,0],width:1.7,height:10,lines:['east','support','→','host'],color:'#8792a5'});
  for(const p of s.pes){const q=state[p.id],values=q.result??q.partial;cards.push({id:'pe:'+p.id,at:position(p.id),width:5.1,height:4.4,lines:[`PE (${p.id}) · ${q.result?'final':'partial'}`],color:p.id===this.pe?palette.c:palette.b,matrix:{values:chunks(values??Array(s.slots).fill(null),s.slot_columns)},active:p.id===this.pe});}
  let flows=st.flows??[];const item=this.items()[this.sub];if(this.fine&&item&&'observations' in item)flows=flows.filter(f=>f.packet_ids.includes(item.id));
  for(const f of flows){const a=position(f.source),b=position(f.destination),horizontal=a[1]===b[1],sign=horizontal?Math.sign(b[0]-a[0]):Math.sign(b[1]-a[1]);const from:V3=horizontal?[a[0]+sign*2.63,a[1],-.2]:[a[0],a[1]+sign*2.25,-.2],to:V3=horizontal?[b[0]-sign*2.63,b[1],-.2]:[b[0],b[1]-sign*2.25,-.2];
   const color=f.tensor==='A'?palette.a:f.tensor==='B'?palette.b:f.tensor==='partial'?palette.p:palette.c;
   edges.push({from,to,color,width:.055});
   const values=this.fine&&item&&'observations' in item?[item.value]:f.values;
   cards.push({id:'payload:'+f.source+':'+f.destination,at:horizontal?[(a[0]+b[0])/2,a[1]+1,0]:[a[0]+1.8,(a[1]+b[1])/2,0],width:horizontal?2.7:3,height:1.15,lines:[f.tensor+' payload','['+values.join(', ')+']'],color});}
  if(st.phase==='place'&&st.pe){const b=position(st.pe);edges.push({from:[-10,0,-.3],to:[b[0]-2.65,b[1],-.3],via:[[-6.8,0,-.3],[-6.8,b[1],-.3]],color:st.tensor==='A'||st.tensor==='X'?palette.a:palette.b,dashed:true,width:.04});}
  if(st.phase==='gather'&&st.pe){const a=position(st.pe);edges.push({from:[a[0]+2.65,a[1],-.3],to:[10.65,0,-.3],via:[[9.6,a[1],-.3],[9.6,0,-.3]],color:palette.c,dashed:true,width:.04});}
  this.gl.setScene({cards,edges},15);
 }
 ledger(){const st=this.scene.teaching.steps[this.index],item=this.items()[this.sub];
  let packets=(st.flows??[]).flatMap(f=>f.packet_ids.map(id=>this.scene.packets.find(p=>p.id===id)!));if(this.fine&&item&&'observations' in item)packets=[item];
  this.html('#mesh-transfer',`<h3>${packets.length?'PE → PE · exact payload and observed path':'This workflow step'}</h3>${packets.length?`<p>Numbers below are the transmitted words in packed order. Send, fabric observations, receive and consumer are separate recorded events; their differences are not an isolated link-latency measurement.</p><div class="packet-table"><table><thead><tr><th>Payload</th><th>Route</th><th>Observed events</th><th>Consumer</th></tr></thead><tbody>${packets.map(p=>`<tr><td><b>${p.value}</b><br><code>0x${p.word.toString(16)}</code><small>${esc(p.kind)} · color ${p.color}<br>ID ${p.id}</small></td><td>PE (${p.source}) → PE (${p.destination})</td><td>${p.send?`send c${p.send.cycle} · row ${p.send.row}<br>`:''}${p.observations.map(o=>`(${o.pe}) ${esc(o.link)} c${o.cycle} · row ${o.row}`).join('<br>')}${p.receive?`<br>receive c${p.receive.cycle} · row ${p.receive.row}`:''}</td><td>${p.consumer?`${esc(p.consumer.equation)}<br>c${p.consumer.cycle}<br><code>${esc(p.consumer.assembly)}</code>`:'No arithmetic consumer bound'}</td></tr>`).join('')}</tbody></table></div>`:`<p>${esc(st.phase==='place'||st.phase==='gather'?this.scene.host.note:'No inter-PE packet is associated with this step. Select an A/B panel transfer, partial reduction or result replication to inspect the payload and its recorded path.')}</p>`}`);
 }
}
