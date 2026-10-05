/** Documented SDK layout + numerically checked teaching steps. All scene geometry
 * and arrows are drawn by WebGL; DOM controls expose the same numbers accessibly. */
import type {Card,Edge,V3,Matrix} from './dataflow-gl';
import type {FlowScene} from './dataflow';
import type {InputTile} from './time-model';
export type Flow={source:string;destination:string;tensor:string;values:number[];packet_ids:string[]};
export type Calculation={pe:string;k:number;before:number[];a:number[];b:number[];products:number[];after:number[];mul_ids:string[];add_ids:string[]};
export type TeachingTile=InputTile&{id:string;pe:string;fabric:number[]};
export type TeachingStep={id:string;phase:string;title:string;description:string;chapter:number;resident:string[];gathered:string[];state:Record<string,{partial:number[]|null;result:number[]|null}>;tile?:string;pe?:string;tensor?:string;round?:number;offset?:number;flows?:Flow[];calculations?:Calculation[];reduction?:{before:number[];incoming:number[];after:number[];event_ids:string[]}};
export type Teaching={schema:string;tiles:TeachingTile[];output_tiles:{pe:string;tensor:string;rows:number[];cols:number[];values:number[]}[];steps:TeachingStep[];time_basis:string;checked_operations:number};
export const streamColors={A:'#78d5e7',X:'#78d5e7',B:'#f3bc72',W:'#f3bc72',partial:'#baabff',replica:'#90e0b1',output:'#90e0b1',support:'#f39b61',kernel:'#76aef7',halo:'#57697a'};
export function tensorColor(name:string){return streamColors[name as keyof typeof streamColors]??streamColors.output;}
export const rows=(values:(number|null)[],width:number)=>Array.from({length:Math.ceil(values.length/width)},(_,i)=>values.slice(i*width,(i+1)*width));
const range=(a:number,b:number)=>Array.from({length:b-a},(_,i)=>i+a);
export function stepPanel(s:FlowScene,pe:string,tensor:string,round:number):InputTile|undefined{
  return s.input_panels?.find(a=>a.pe===pe&&a.tensor===tensor&&a.round===round)??s.pes.find(p=>p.id===pe)?.input_tiles?.find(a=>a.tensor===tensor);
}
export function streamingScene(s:FlowScene,step:TeachingStep,selectedPE:string,cell:number){
  const cards:Card[]=[],edges:Edge[]=[];
  const add=(id:string,x:number,y:number,w:number,h:number,lines:string[],color:string,active=false,z=0,matrix?:Matrix)=>{cards.push({id,at:[x,y,z],width:w,height:h,lines,color,active,matrix,fill:id.startsWith('support')?'#694128':id==='halo'?'#394755':undefined});};
  const edge=(from:V3,to:V3,color:string,via:V3[]=[],dashed=false)=>edges.push({from,to,color,via,dashed,width:.04});
  const chosen=s.teaching.tiles.find(t=>t.id===step.tile);
  if(step.phase==='overview'){
    const yy=(y:number)=>((s.p-1)/2-y)*3.25;
    const xx=(x:number)=>(x-(s.p-1)/2)*3.1;
    const xs=[-6.2,-5.3,-4.4,-3.5,...range(0,s.p).map(xx),3.5,4.4,5.3];
    for(const x of xs)for(const y of [-3.35,3.35])add('halo',x,y,.58,.58,[],streamColors.halo);
    for(let y=0;y<s.p;y++){
      for(const [i,x] of [-5.3,-4.4,-3.5].entries())add('support-west',x,yy(y),.66,.66,[`W${i+1}`],streamColors.support);
      for(const [i,x] of [3.5,4.4].entries())add('support-east',x,yy(y),.66,.66,[`E${i+1}`],streamColors.support);
      for(const x of [-6.2,5.3])add('halo',x,yy(y),.58,.58,[],streamColors.halo);
      const ports=[...[-5.3,-4.4,-3.5].map(x=>({x,w:.66})),...range(0,s.p).map(x=>({x:xx(x),w:2.75})),... [3.5,4.4].map(x=>({x,w:.66}))];
      for(let i=1;i<ports.length;i++)edge([ports[i-1].x+ports[i-1].w/2+.025,yy(y),-.25],[ports[i].x-ports[i].w/2-.025,yy(y),-.25],i<3+s.p?streamColors.A:streamColors.output,[],true);
    }
    // A schematic distribution trunk and collection trunk use their own lanes.
    if(s.p>1){edge([-5.3,yy(0)-.4,-.25],[-5.3,yy(s.p-1)+.4,-.25],streamColors.A,[],true);
      edge([4.4,yy(0)-.4,-.25],[4.4,yy(s.p-1)+.4,-.25],streamColors.output,[],true);}
    for(const pe of s.pes){const x=xx(pe.x),y=yy(pe.y);
      add('pe:'+pe.id,x,y,2.75,2.45,[`PE (${pe.id}) · fabric ${pe.fabric}`, 'Local SRAM + compute',...pe.input_tiles!.map(t=>`${t.tensor}  ${t.rows.length} × ${t.cols.length} tile`),`→ ${s.kind==='gemm'?'C tile':'partial → Y slice'}`],streamColors.kernel,pe.id===selectedPE);
    }
    s.host.inputs.forEach((t,i)=>add('global:'+t.name,-9.7,1.7-i*3.45,3.7,3.1,[`${t.name} · host numbers`],tensorColor(t.name),false,0,{values:t.values,block:s.t}));
    add('out',9.4,0,3.9,4.4,['HOST OUTPUT · expected'],streamColors.output,false,0,{values:s.host.output,block:s.t});
    add('host-label',-9.7,4.2,4,.65,['HOST MEMORY / SdkRuntime'],streamColors.A);
    add('west-label',-4.2,4.2,3.7,.65,['WEST · 3 support columns'],streamColors.support);
    add('core-label',0,4.2,3.9,.65,[`${s.p} × ${s.p} USER KERNEL`],streamColors.kernel);
    add('east-label',4,4.2,3.5,.65,['EAST · 2 support columns'],streamColors.support);
    add('io-west',-7,0,.85,1.1,['I/O','in'],streamColors.A);add('io-east',6.5,0,.85,1.1,['I/O','out'],streamColors.output);
    edge([-7.8,0,-.35],[-7.47,0,-.35],streamColors.A,[],true);
    edge([-6.55,0,-.35],[-5.67,yy(0),-.35],streamColors.A,[[-6.5,0,-.35],[-6.5,yy(0),-.35]],true);
    edge([4.78,yy(s.p-1),-.35],[6.03,0,-.35],streamColors.output,[[5.85,yy(s.p-1),-.35],[5.85,0,-.35]],true);
    edge([6.94,0,-.35],[7.4,0,-.35],streamColors.output,[],true);
    add('mode',0,-4.5,12,.95,['COPY MODE · H2D to SRAM → launch → D2H'],streamColors.halo);
    return {cards,edges,extent:12.3};
  }
  // Global inputs stay visible throughout every tile and arithmetic step.
  const focusPE=s.pes.find(p=>p.id===selectedPE)!;
  const compute=step.calculations?.find(c=>c.pe===selectedPE);
  const phase=step.phase,round=step.round??(['results','gather','complete'].includes(phase)?s.p-1:0);
  const activeTile=chosen??(phase==='panel'?stepPanel(s,selectedPE,step.tensor!,round):undefined);
  s.host.inputs.forEach((t,index)=>{
    const cellFocus=compute?(t.name==='A'?[focusPE.y*s.t+Math.floor(cell/s.t),compute.k]:t.name==='B'||t.name==='W'?[compute.k,focusPE.x*s.t+cell%s.t]:[0,compute.k]) as [number,number]:undefined;
    const ownership=['partition','launch'].includes(phase)?focusPE.input_tiles?.find(a=>a.tensor===t.name):undefined;
    const focus=activeTile?.tensor===t.name?{rows:activeTile.rows,cols:activeTile.cols}:ownership?{rows:ownership.rows,cols:ownership.cols}:undefined;
    add('global:'+t.name,-9.8,2.7-index*5.25,4.45,4.85,[`${t.name} · GLOBAL INPUT`],tensorColor(t.name),!!focus,0,{values:t.values,block:s.t,focus,cell:cellFocus,pick:true});
  });
  const positions=new Map<string,V3>();
  const unitY=s.p===1?0:2.9;
  const pos=(x:number,y:number):V3=>[(x-(s.p-1)/2)*4.65,((s.p-1)/2-y)*(unitY*2),0];
  const isComputed=!['partition','place','launch'].includes(phase);
  for(const pe of s.pes){const [x,y]=pos(pe.x,pe.y);positions.set(pe.id,[x,y,0]);
    add('pe:'+pe.id,x,y,3.95,5.15,[],streamColors.kernel,pe.id===selectedPE,.3);
    add('pe:'+pe.id,x,y+2.23,3.6,.45,[`PE (${pe.id}) · fabric ${pe.fabric}`],streamColors.kernel,pe.id===selectedPE,-.05);
    const own=pe.input_tiles!;
    for(let z=0;z<own.length;z++){
      let tile=own[z];const r=phase==='panel'&&step.tensor==='A'&&z===1&&round>0?round-1:round;
      if(s.kind==='gemm'&&isComputed)tile=stepPanel(s,pe.id,tile.tensor,r)!;
      const resident=step.resident.includes(`${own[z].tensor}@${pe.id}`);
      // During A distribution the B operand for the new round is not ready yet.
      const waiting=s.kind==='gemm'&&phase==='panel'&&step.tensor==='A'&&z===1&&round===0&&tile.source!==pe.id;
      const values=resident&&!waiting?tile.values:tile.values.map(()=>null);
      const label=`${tile.tensor}${s.kind==='gemm'&&isComputed?' r'+(r+1):''} · ${!resident?'await H2D':waiting?'await panel':tile.source===pe.id?'local':'← '+tile.source}`;
      add('pe:'+pe.id,x+(z?1:-1)*.95,y+.8,1.78,2.05,[label],tensorColor(tile.tensor),chosen?.pe===pe.id&&chosen.tensor===tile.tensor,-.05,{values:rows(values,tile.cols.length),rows:tile.rows,cols:tile.cols});
    }
    const values=step.state[pe.id].result??step.state[pe.id].partial;
    const cc=s.kind==='gemm'?s.t:s.t;
    const results=values??Array(s.slots).fill(null);
    const resultRows=s.kind==='gemm'?range(pe.y*s.t,(pe.y+1)*s.t):[0];
    const label=step.state[pe.id].result?(s.kind==='gemm'?'C':'Y')+' · verified':s.kind==='gemm'?'C · teaching partial':'Partial · teaching state';
    add('pe:'+pe.id,x,y-1.38,3.6,2.05,[label],streamColors.output,pe.id===selectedPE,-.05,{values:rows(results,cc),rows:resultRows,cols:range(pe.x*s.t,(pe.x+1)*s.t),cell:pe.id===selectedPE?[s.kind==='gemm'?Math.floor(cell/s.t):0,cell%s.t]:undefined});
  }
  // Only one operand class is animated per teaching step. All arrows terminate
  // outside cards; row lanes and column lanes never compete in the same frame.
  if(phase==='place'&&chosen){const a=positions.get(chosen.pe)!,y=chosen.tensor===s.host.inputs[0].name?2.7:-2.55;
    const lane=a[1]+2.82;
    edge([-7.48,y,-.35],[a[0],a[1]+2.63,-.35],tensorColor(chosen.tensor),[[-6.15,y,-.35],[-6.15,lane,-.35],[a[0],lane,-.35]],true);
    add('delivery',-5.82,6.25,3.5,.6,['H2D → local SRAM'],tensorColor(chosen.tensor));
  }
  for(const flow of step.flows??[]){const a=positions.get(flow.source)!,b=positions.get(flow.destination)!,color=tensorColor(flow.tensor);
    if(a[1]===b[1]){const direction=Math.sign(b[0]-a[0]),y=a[1]+.65;edge([a[0]+direction*2.03,y,-.3],[b[0]-direction*2.03,y,-.3],color);}
    else{const direction=Math.sign(b[1]-a[1]);edge([a[0],a[1]+direction*2.63,-.3],[b[0],b[1]-direction*2.63,-.3],color);}
  }
  const output=s.host.output.map((r,i)=>r.map((v,j)=>step.gathered.some(id=>s.teaching.output_tiles.some(t=>t.pe===id&&t.rows.includes(i)&&t.cols.includes(j)))?v:null));
  add('global-output',9.25,2.65,4.6,4.9,[`${s.host.output_name} · HOST ASSEMBLY`],streamColors.output,phase==='gather'||phase==='complete',0,{values:output,block:s.t});
  if(phase==='gather'&&step.pe){const a=positions.get(step.pe)!,lane=a[1]-2.82;edge([a[0],a[1]-2.63,-.35],[6.87,2.65,-.35],streamColors.output,[[a[0],lane,-.35],[5.65,lane,-.35],[5.65,2.65,-.35]],true);}
  let lines:string[];
  if(compute){const q=cell;lines=[`PE (${selectedPE}) · k = ${compute.k}`,`left = ${compute.a[q]}`,`right = ${compute.b[q]}`,`${compute.a[q]} × ${compute.b[q]} = ${compute.products[q]}`,`old sum = ${compute.before[q]}`,`→ new sum = ${compute.after[q]}`];}
  else if(chosen){lines=[`${chosen.tensor} → PE (${chosen.pe})`,`Rows ${chosen.rows.join(', ')}`,`Cols ${chosen.cols.join(', ')}`,`SRAM: ${chosen.storage}`,`${chosen.packing} packing`,...rows(chosen.packed,Math.min(4,chosen.packed.length)).map(r=>r.join('  '))];}
  else if(step.reduction){lines=[`COMBINE · PE (${step.pe})`,...step.reduction.after.map((v,i)=>`${step.reduction!.before[i]} + ${step.reduction!.incoming[i]} = ${v}`)];}
  else if(phase==='panel'){const tile=stepPanel(s,selectedPE,step.tensor!,round)!;lines=[`${step.tensor} · round ${round+1}`,`Owner PE (${tile.source})`,`Use on PE (${selectedPE})`,tile.source===selectedPE?'Read local SRAM':`Receive into ${tile.storage}`,`k = ${round*s.t}…${(round+1)*s.t-1}`];}
  else lines=[`PE (${selectedPE}) selected`,`${s.t} × ${s.t} matrix tiles`,s.kind==='gemm'?'C[y,x] += A[y,r] × B[r,x]':'P[x,y] = X[y] × W[y,x]',s.kind==='gemm'?'A crosses rows':'X copied to each row PE',s.kind==='gemm'?'B crosses columns':'Partials combine vertically','Click a PE to inspect'];
  add('detail',9.25,-2.35,4.6,4.25,lines,compute?streamColors.B:chosen?tensorColor(chosen.tensor):streamColors.partial,true);
  return {cards,edges,extent:12.6};
}
