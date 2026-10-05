import {inputStateAt} from './input-model';
import type {PE,Scene} from './time-model';

export type LayerArray={key:string;label:string;note:string;rows:string[];cols:string[];values:(number|null)[];titles:string[];active:number[]};

/** Inputs on the plane itself: static host tiles and time-bounded receive operands.
 * Do not substitute a whole round-history panel for partially observed receives.
 */
export function layerInputs(scene:Scene,pe:PE,cycle:number):LayerArray[]{
  const state=inputStateAt(scene,pe,cycle),last=state.last_multiply;
  const initial:LayerArray[]=state.initial.map(tile=>{
    const active:number[]=[];
    const titles=tile.values.map((value,index)=>{
      const r=tile.rows[Math.floor(index/tile.cols.length)],c=tile.cols[index%tile.cols.length];
      const used=last&&(tile.tensor==='X'?c===last.k:tile.tensor==='W'?r===last.k&&c===last.j:tile.tensor==='A'?r===last.i&&c===last.k:r===last.k&&c===last.j);
      if(used)active.push(index);
      return `${tile.tensor==='X'?`X[${c}]`:`${tile.tensor}[${r},${c}]`} = ${value}; host-loaded ${tile.storage} on PE (${pe.id}); ${tile.packing}; static input context`;
    });
    return {key:tile.tensor,label:tile.tensor,note:'host-loaded',rows:tile.tensor==='X'?['X']:tile.rows.map(String),cols:tile.cols.map(String),values:tile.values,titles,active};
  });
  if(scene.kind==='gemm'&&scene.p>1)for(const tensor of ['A','B']){
    const buffer=state.received.find(b=>b.tensor===tensor),storage=tensor==='A'?'abuf':'bbuf';
    const values=buffer?.values||Array(scene.t*scene.t).fill(null),active:number[]=[];
    const titles=values.map((value,index)=>{
      const e=buffer?.observations[index];
      if(!e)return `${storage}[${Math.floor(index/scene.t)},${index%scene.t}]: no receive S6 observation by cycle ${cycle}`;
      const r=tensor==='A'?pe.y*scene.t+Math.floor(index/scene.t):e.round*scene.t+Math.floor(index/scene.t);
      const c=tensor==='A'?e.round*scene.t+index%scene.t:pe.x*scene.t+index%scene.t;
      if(last&&e.round===state.round&&(tensor==='A'?r===last.i&&c===last.k:r===last.k&&c===last.j))active.push(index);
      return `${tensor}[${r},${c}] = ${value}; ${storage} from PE (${e.source}); receive S6 cycle ${e.cycle}; raw row ${e.row}; packet ${e.ident}. Not an SRAM write timestamp.`;
    });
    initial.push({key:storage,label:storage,note:'receive S6 · local r/c',rows:Array.from({length:scene.t},(_,i)=>String(i)),cols:Array.from({length:scene.t},(_,i)=>String(i)),values,titles,active});
  }
  return initial;
}

export function layerGeometry(scene:Scene){
  const bandHeight=80+scene.t*30,hasReceive=scene.kind==='gemm'&&scene.p>1;
  const outputTop=72+bandHeight*(hasReceive?2:1)+28;
  const outputHeight=scene.kind==='gemv'?3*44:36+scene.t*32;
  const height=outputTop+outputHeight+44;
  return {width:440,height,dx:478,dy:height+32,bandHeight,outputTop};
}
