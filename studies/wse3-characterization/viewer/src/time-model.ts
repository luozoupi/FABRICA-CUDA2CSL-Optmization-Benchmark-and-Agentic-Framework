export type NumericEvent={id:string;kind:'multiply'|'accumulate'|'reduce'|'checkpoint';cycle:number;pe:string;index?:number;label?:string;i?:number;j?:number;k?:number;a?:number;b?:number;old?:number;addend?:number;value?:number;phase?:string;values?:Record<string,number[]>;local_tick?:number;instruction?:{uid:number;pc:number;assembly:string;raw_rows:number[]}};
export type InputTile={tensor:string;rows:number[];cols:number[];values:number[];packed:number[];storage:string;source:string;packing:'row-major'|'column-major';evidence:string};
export type InputPanel=InputTile&{pe:string;round:number;remote:boolean};
export type InputReceipt={pe:string;tensor:string;storage:string;round:number;source:string;index:number;slot:number;value:number;cycle:number;row:number;ident:string};
export type PE={id:string;x:number;y:number;fabric:number[];input_labels:string[];inputs:number[][];input_columns:number[];input_tiles?:InputTile[];input_checkpoint?:number;partial_labels:string[];final_expected:number[];final_readback:number[]};
export type Scene={id:string;kind:'gemv'|'gemm';title:string;n:number;p:number;t:number;slots:number;slot_columns:number;pes:PE[];events:NumericEvent[];cycles:number[];start:number;end:number;wavelets:{cycle:number;pe:string;ident:string;color:number;data:number;row:number}[];has_checkpoints:boolean;limitations:string;verification:{passed:boolean;checks:number};input_panels?:InputPanel[];input_receipts?:InputReceipt[];provenance:{source_bundle:string;source_sha256:string;input_hops?:{path:string;sha256:string}}};
export type State={partial:(number|null)[];peer:(number|null)[];result:(number|null)[];phase:string;product:number|null;latest:NumericEvent|null};
export function stateAt(scene:Scene,cycle:number):Record<string,State>{
  const states:Record<string,State>={};
  for(const pe of scene.pes)states[pe.id]={partial:Array(scene.slots).fill(null),peer:Array(scene.slots).fill(null),result:Array(scene.slots).fill(null),phase:'not yet observed',product:null,latest:null};
  for(const e of scene.events){
    if(e.cycle>cycle)break;
    const s=states[e.pe];s.latest=e;
    if(e.kind==='multiply'){s.product=e.value!;s.phase='local compute';}
    else if(e.kind==='accumulate'){s.partial[e.index!]=e.value!;s.phase='local compute';}
    else if(e.kind==='reduce'){s.result[e.index!]=e.value!;s.phase='reduction';}
    else if(e.kind==='checkpoint'){s.phase=e.phase!;for(const key of ['partial','peer','result'] as const){if(e.values?.[key])s[key]=[...e.values[key]];}}
  }
  return states;
}
export function eventText(e:NumericEvent){
  if(e.kind==='multiply')return `${e.a} × ${e.b} = ${e.value}`;
  if(e.kind==='accumulate'||e.kind==='reduce')return `${e.old} + ${e.addend} = ${e.value}`;
  return `${phaseName(e.phase||'')}: ${Object.entries(e.values||{}).map(([k,v])=>`${k} = [${v.join(', ')}]`).join(' · ')}`;
}
export function phaseName(name:string){return ({inputs:'inputs ready',local:'local partials ready',peer:'partial exchange complete',reduced:'reduction complete',final:'final result available'} as Record<string,string>)[name]||name;}
