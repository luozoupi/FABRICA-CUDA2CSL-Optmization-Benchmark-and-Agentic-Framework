export const esc=(x:unknown)=>String(x??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]!));
export const fmt=(x:unknown)=>typeof x==='number'?x.toLocaleString('en-US'):'—';
export const hex=(x:number)=>'0x'+x.toString(16).padStart(8,'0');
export const bits=(x:number)=>hex(new Uint32Array(new Float32Array([x]).buffer)[0]);
export const badge=(s:string,kind='')=>`<span class="badge ${kind}">${esc(s)}</span>`;
export function header(label:string){return `<header class="topbar"><span class="brand"><span class="brand-mark">▦</span> WSE <span class="brand-light">/ ${label}</span></span><div>${badge('Cerebras WSE-3')}${badge('simulator evidence')}</div><button id="theme" aria-label="Toggle light or dark theme">◐ Theme</button></header>`;}
export function theme(){
  try{document.documentElement.dataset.theme=localStorage.getItem('gemm-theme')||'light';}catch{}
  document.querySelector<HTMLButtonElement>('#theme')!.onclick=()=>{const t=document.documentElement.dataset.theme==='dark'?'light':'dark';document.documentElement.dataset.theme=t;try{localStorage.setItem('gemm-theme',t);}catch{}};
}
export function events(selector:string,callback:(el:HTMLElement)=>void){document.querySelectorAll<HTMLElement>(selector).forEach(el=>{el.onclick=()=>callback(el);});}
export function download(name:string,data:unknown){const url=URL.createObjectURL(new Blob([JSON.stringify(data,null,2)],{type:'application/json'}));const a=document.createElement('a');a.href=url;a.download=name;a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);}
export function mini(values:(number|null)[],columns:number,labels?:string[]){return `<div class="mini-matrix" style="--n:${columns}">${values.map((v,i)=>`<span title="${esc(labels?.[i]||'')}">${v===null?'?':fmt(v)}</span>`).join('')}</div>`;}
export type Exec={cycle:number;lane:number;element:number;dest:number;src0:number;src1:number;src2:number};
export type Instruction={id:string;uid:number;pe:string;pc:number;name:string;dispatch:number[];decode:number[];execute:Exec[];task:number;ut:number;raw_rows:number[]};
export type Program={assembly:Record<string,string>;functions:Record<string,number[]>;csl:string;ir:string};
export function instructions(ids:string[],dynamic:Record<string,Instruction>,program:Program|undefined){
  return ids.length?`<div class="instruction-table"><table><thead><tr><th>PC</th><th>Instruction</th><th>Dispatch</th><th>Execute</th><th>Operands → result (f32 bits)</th></tr></thead><tbody>${ids.map(id=>{const d=dynamic[id],v=[...d.execute].reverse().find(e=>e.lane===0);return `<tr><td>${hex(d.pc)}</td><td class="mono">${esc(program?.assembly[d.pc]||d.name)}</td><td>${d.dispatch.join(', ')}</td><td>${[...new Set(d.execute.map(e=>e.cycle))].join(', ')}</td><td>${v&&['FMULS','FADDS'].includes(d.name)?`${hex(v.src0)}, ${hex(v.src1)} → ${hex(v.dest)}`:'—'}</td></tr>`;}).join('')}</tbody></table></div>`:'<p class="empty-state">No verified instruction binding for this selection.</p>';
}
