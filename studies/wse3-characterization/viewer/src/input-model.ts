import {type InputReceipt,type Scene,type PE} from './time-model';

export function inputStateAt(scene:Scene,pe:PE,cycle:number,target?:number){
  const last=scene.events.filter(e=>e.pe===pe.id&&e.kind==='multiply'&&e.cycle<=cycle&&
    (target===undefined||(scene.kind==='gemv'?e.j===target:(e.i??0)*scene.n+(e.j??0)===target))).at(-1)||null;
  const round=last?Math.floor(last.k!/scene.t):null;
  const panels=round===null?[]:(scene.input_panels||[]).filter(p=>p.pe===pe.id&&p.round===round);
  const receipts=(scene.input_receipts||[]).filter(e=>e.pe===pe.id&&e.cycle<=cycle);
  const received=['A','B'].flatMap(tensor=>{
    const entries=receipts.filter(e=>e.tensor===tensor);if(!entries.length)return [];
    const values:(number|null)[]=Array(scene.t*scene.t).fill(null),observations:(InputReceipt|null)[]=Array(values.length).fill(null);
    for(const e of entries){values[e.index]=e.value;observations[e.index]=e;}
    return [{tensor,storage:tensor==='A'?'abuf':'bbuf',values,observations}];
  });
  return {cycle,pe:pe.id,initial:pe.input_tiles||[],input_checkpoint:pe.input_checkpoint??null,last_multiply:last,round,panels,received};
}

