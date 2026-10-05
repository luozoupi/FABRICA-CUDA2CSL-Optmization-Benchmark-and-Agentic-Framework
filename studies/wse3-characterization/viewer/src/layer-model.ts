import {stateAt,type NumericEvent,type PE,type Scene,type State} from './time-model';

export type Layer={cycle:number;label:string;states:Record<string,State>};
export type BufferName='partial'|'peer'|'result';
export type Transfer={id:string;kind:'partial'|'replica';source:string;destination:string;sourceField:BufferName;destinationField:BufferName;index:number;value:number;sourceReady:number;destinationAvailable:number;sourceEvent:string;destinationEvent:string};

export function outputLabel(scene:Scene,target:number){return scene.kind==='gemv'?`Y[${target}]`:`C[${Math.floor(target/scene.n)},${target%scene.n}]`;}
export function slotFor(scene:Scene,pe:PE,target:number){
  if(scene.kind==='gemv')return pe.x===Math.floor(target/scene.t)?target%scene.t:-1;
  const i=Math.floor(target/scene.n),j=target%scene.n;
  return pe.y===Math.floor(i/scene.t)&&pe.x===Math.floor(j/scene.t)?(i%scene.t)*scene.t+j%scene.t:-1;
}
export function outputFor(scene:Scene,pe:PE,slot:number){
  return scene.kind==='gemv'?pe.x*scene.t+slot:(pe.y*scene.t+Math.floor(slot/scene.t))*scene.n+pe.x*scene.t+slot%scene.t;
}
export function numericEvents(scene:Scene,pe:string,slot:number,cycle=Infinity){
  return scene.events.filter(e=>e.pe===pe&&e.index===slot&&e.cycle<=cycle&&e.kind!=='checkpoint');
}

export function layersFor(scene:Scene,target:number,mode:string,count=6,anchor=0):Layer[]{
  let points:{cycle:number;label:string}[]=[];
  const clampCount=Math.max(3,Math.min(8,Math.floor(count)));
  const phase=(pe:string,name:string)=>scene.events.find(e=>e.pe===pe&&e.phase===name);
  if(mode==='story'&&scene.kind==='gemv'&&scene.p===2){
    const x=Math.floor(target/scene.t),slot=target%scene.t,top=`${x},0`,root=`${x},1`;
    const input=[phase(top,'inputs'),phase(root,'inputs')],local=[phase(top,'local'),phase(root,'local')];
    const peer=phase(root,'peer'),reduction=scene.events.find(e=>e.pe===root&&e.kind==='reduce'&&e.index===slot),ready=phase(root,'reduced');
    if(input.every(Boolean)&&local.every(Boolean)&&peer&&reduction&&ready){
      points=[{cycle:Math.max(...input.map(e=>e!.cycle)),label:'Input checkpoints'},
        {cycle:Math.max(...local.map(e=>e!.cycle)),label:'Local partials'},
        {cycle:peer.cycle,label:'Partial received'},
        {cycle:reduction.cycle,label:`Combine ${outputLabel(scene,target)}`},
        {cycle:ready.cycle,label:'Root result ready'},
        {cycle:scene.end,label:'Replicas available'}];
    }
  }
  if(mode==='story'&&!points.length){
    const pe=scene.pes.find(p=>slotFor(scene,p,target)>=0)!;
    const adds=numericEvents(scene,pe.id,slotFor(scene,pe,target)).filter(e=>e.kind==='accumulate');
    points=[{cycle:scene.start,label:'Before observations'}];
    const n=Math.min(4,adds.length);
    for(let i=0;i<n;i++){const e=adds[Math.round(i*(adds.length-1)/Math.max(n-1,1))];points.push({cycle:e.cycle,label:`After k = ${e.k}`});}
    points.push({cycle:scene.end,label:'Last observed results'});
  }
  if(mode==='uniform')points=Array.from({length:clampCount},(_,i)=>({cycle:Math.round(scene.start+i*(scene.end-scene.start)/(clampCount-1)),label:`Time sample ${i+1}`}));
  if(mode==='events'){
    const all=[scene.start,...scene.cycles],start=Math.min(Math.max(0,anchor-Math.floor(clampCount/2)),Math.max(0,all.length-clampCount));
    points=all.slice(start,start+clampCount).map((cycle,i)=>({cycle,label:`Event frame ${start+i}`}));
  }
  const unique=points.filter((point,i)=>points.findIndex(p=>p.cycle===point.cycle)===i).sort((a,b)=>a.cycle-b.cycle);
  return unique.map(p=>({...p,states:stateAt(scene,p.cycle)}));
}

/** Logical transfer provenance: checked buffers + compiled two-peer algorithm.
 * Times bound availability at named checkpoints; neither is a packet timestamp.
 * Require both endpoints and exact values, rather than linking equal numbers.
 */
export function transfersFor(scene:Scene,target:number):Transfer[]{
  if(scene.kind!=='gemv'||scene.p!==2||!scene.has_checkpoints)return [];
  const x=Math.floor(target/scene.t),slot=target%scene.t,top=`${x},0`,root=`${x},1`;
  const phase=(pe:string,name:string)=>scene.events.find(e=>e.pe===pe&&e.phase===name);
  const result:Transfer[]=[];
  function bind(kind:'partial'|'replica',src:NumericEvent|undefined,dst:NumericEvent|undefined,sourceField:BufferName,destinationField:BufferName){
    const a=src?.values?.[sourceField]?.[slot],b=dst?.values?.[destinationField]?.[slot];
    if(src&&dst&&src.cycle<=dst.cycle&&a!==undefined&&b!==undefined&&Object.is(a,b))result.push({id:`${kind}:${target}`,kind,source:src.pe,destination:dst.pe,sourceField,destinationField,index:slot,value:a,sourceReady:src.cycle,destinationAvailable:dst.cycle,sourceEvent:src.id,destinationEvent:dst.id});
  }
  bind('partial',phase(top,'local'),phase(root,'peer'),'partial','peer');
  bind('replica',phase(root,'reduced'),phase(top,'final'),'result','result');
  return result;
}

export function transferLayers(transfer:Transfer,layers:Layer[]):[number,number]|null{
  const source=layers.findIndex(l=>l.cycle>=transfer.sourceReady&&Object.is(l.states[transfer.source][transfer.sourceField][transfer.index],transfer.value));
  const destination=layers.findIndex(l=>l.cycle>=transfer.destinationAvailable&&Object.is(l.states[transfer.destination][transfer.destinationField][transfer.index],transfer.value));
  return source>=0&&destination>=source?[source,destination]:null;
}

export type Point={x:number;y:number};
export function project(x:number,y:number,z:number,yaw:number,tilt:number):Point{
  const a=yaw*Math.PI/180,b=tilt*Math.PI/180;
  const rx=x*Math.cos(a)+z*Math.sin(a),rz=-x*Math.sin(a)+z*Math.cos(a);
  return {x:rx,y:-(y*Math.cos(b)-rz*Math.sin(b))};
}
