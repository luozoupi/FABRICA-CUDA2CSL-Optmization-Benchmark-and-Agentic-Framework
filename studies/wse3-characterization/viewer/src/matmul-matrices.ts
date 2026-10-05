/** Numeric teaching surface shared by instruction and mesh journeys. */
export const escapeHTML=(s:unknown)=>String(s).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]!));
export type Values=(number|null)[][];
export type MatrixOptions={active?:string[];selected?:string;done?:string[];block?:number;delta?:boolean;label?:string};
export function matrix(values:Values,color:string,options:MatrixOptions={}){
 const nr=values.length,nc=values[0].length,key=(i:number,j:number)=>`${i},${j}`;
 return `<div class="number-matrix ${options.delta?'delta-matrix':''}" role="table" aria-label="${escapeHTML(options.label??'Matrix')}" style="--n:${nc};--matrix-color:${color}"><span></span>${values[0].map((_,j)=>`<span class="index">${j}</span>`).join('')}${values.map((row,i)=>`<span class="index">${i}</span>${row.map((x,j)=>`<span role="cell" data-cell="${i},${j}" data-value="${x??''}" class="number-cell ${options.active?.includes(key(i,j))?'operand':''} ${options.selected===key(i,j)?'selected':''} ${options.done?.includes(key(i,j))?'finalized':''} ${options.block&&j>0&&j%options.block===0?'tile-left':''} ${options.block&&i>0&&i%options.block===0?'tile-top':''}">${x===null?'·':options.delta&&x>0?'+'+x:x}</span>`).join('')}`).join('')}</div>`;
}
export const palette={a:'#4c5fd7',b:'#0d8f83',c:'#c2621a',p:'#8151bd'};
export function matrixBoard(a:Values,b:Values,c:Values,d:Values,options:{names?:string[];a?:MatrixOptions;b?:MatrixOptions;c?:MatrixOptions;delta?:MatrixOptions;note?:string}={}){
 const names=options.names??['A','B','C'];
 const panel=(name:string,values:Values,color:string,cls:string,opt?:MatrixOptions)=>`<section class="matrix-panel ${cls}"><h3 style="color:${color}">${name}<small>${values.length} × ${values[0].length}</small></h3>${matrix(values,color,{label:name,...opt})}</section>`;
 return `<div class="matrix-board">${panel('Δ'+names[2]+' · this step',d,palette.c,'delta', {...options.delta,delta:true})}${panel(names[1],b,palette.b,'matrix-b',options.b)}${panel(names[0],a,palette.a,'matrix-a',options.a)}${panel(names[2],c,palette.c,'matrix-c',options.c)}</div><p class="matrix-legend"><span class="legend-swatch"></span> selected operands <span class="legend-swatch outline"></span> finalized outputs · ${escapeHTML(options.note??'Numbers follow the current teaching step.')}</p>`;
}
