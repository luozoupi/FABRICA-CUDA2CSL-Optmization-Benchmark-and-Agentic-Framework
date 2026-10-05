/** Small WebGL2 renderer: real depth-tested meshes, textured numeric cards and picking.
 * No network assets. Canvas2D only prepares text textures; scene rendering is WebGL2.
 */
export type V3=[number,number,number];
export type Matrix={values:(number|null)[][];rows?:number[];cols?:number[];block?:number;focus?:{rows:number[];cols:number[]};cell?:[number,number];pick?:boolean};
export type Card={id:string;at:V3;width:number;height:number;lines:string[];color:string;active?:boolean;matrix?:Matrix;fill?:string};
export type Edge={from:V3;to:V3;color:string;width?:number;via?:V3[];dashed?:boolean;arrow?:boolean};
type Scene={cards:Card[];edges:Edge[]};
const rgb=(s:string)=>[1,3,5].map(i=>parseInt(s.slice(i,i+2),16)/255);
export class DataflowGL {
  gl:WebGL2RenderingContext;program:WebGLProgram;buffer:WebGLBuffer;vao:WebGLVertexArrayObject;
  yaw=-.11;tilt=.19;zoom=1;pan:V3=[0,0,0];extent=12;scene:Scene={cards:[],edges:[]};
  cache=new Map<string,WebGLTexture>();onPick:(id:string)=>void=()=>{};onChange:()=>void=()=>{};
  private matrix=new Float32Array(16);private dragging=false;private moved=0;private previous=[0,0];
  constructor(public canvas:HTMLCanvasElement,public light=false){
    const gl=canvas.getContext('webgl2',{antialias:true,alpha:false,preserveDrawingBuffer:true});
    if(!gl)throw Error('WebGL2 is unavailable. Enable browser hardware acceleration or use the numeric inspector.');
    this.gl=gl;
    const compile=(type:number,src:string)=>{const s=gl.createShader(type)!;gl.shaderSource(s,src);gl.compileShader(s);if(!gl.getShaderParameter(s,gl.COMPILE_STATUS))throw Error(gl.getShaderInfoLog(s)||'Shader failure');return s;};
    const vs=compile(gl.VERTEX_SHADER,`#version 300 es
      layout(location=0) in vec3 position; layout(location=1) in vec2 uv;
      uniform mat4 camera; out vec2 texUV;
      void main(){gl_Position=camera*vec4(position,1.);texUV=uv;}`);
    const fs=compile(gl.FRAGMENT_SHADER,`#version 300 es
      precision highp float; uniform vec4 tint; uniform bool textured;
      uniform sampler2D image; in vec2 texUV; out vec4 color;
      void main(){color=textured?texture(image,texUV)*tint:tint;if(color.a<.03)discard;}`);
    this.program=gl.createProgram()!;gl.attachShader(this.program,vs);gl.attachShader(this.program,fs);gl.linkProgram(this.program);
    if(!gl.getProgramParameter(this.program,gl.LINK_STATUS))throw Error(gl.getProgramInfoLog(this.program)||'Link failure');
    gl.deleteShader(vs);gl.deleteShader(fs);
    this.vao=gl.createVertexArray()!;gl.bindVertexArray(this.vao);this.buffer=gl.createBuffer()!;gl.bindBuffer(gl.ARRAY_BUFFER,this.buffer);
    gl.enableVertexAttribArray(0);gl.vertexAttribPointer(0,3,gl.FLOAT,false,20,0);
    gl.enableVertexAttribArray(1);gl.vertexAttribPointer(1,2,gl.FLOAT,false,20,12);
    gl.enable(gl.DEPTH_TEST);gl.depthFunc(gl.LEQUAL);gl.enable(gl.BLEND);gl.blendFunc(gl.SRC_ALPHA,gl.ONE_MINUS_SRC_ALPHA);
    canvas.addEventListener('pointerdown',e=>{this.dragging=true;this.moved=0;this.previous=[e.clientX,e.clientY];canvas.setPointerCapture(e.pointerId);});
    canvas.addEventListener('pointermove',e=>{if(!this.dragging)return;const dx=e.clientX-this.previous[0],dy=e.clientY-this.previous[1];this.moved+=Math.abs(dx)+Math.abs(dy);this.previous=[e.clientX,e.clientY];
      if(e.shiftKey){this.pan[0]+=dx*this.extent/400;this.pan[1]-=dy*this.extent/400;}
      else{this.yaw=Math.max(-.8,Math.min(.8,this.yaw+dx*.003));this.tilt=Math.max(-.65,Math.min(.65,this.tilt+dy*.003));}this.draw();});
    canvas.addEventListener('pointerup',e=>{this.dragging=false;if(this.moved<5){const r=canvas.getBoundingClientRect(),x=(e.clientX-r.left)/r.width*2-1,y=1-(e.clientY-r.top)/r.height*2;
      const hit=[...this.scene.cards].reverse().find(c=>{const p=this.project(c.at),a=this.project([c.at[0]+c.width/2,c.at[1],c.at[2]]),b=this.project([c.at[0],c.at[1]+c.height/2,c.at[2]]);return Math.abs(x-p[0])<Math.abs(a[0]-p[0])&&Math.abs(y-p[1])<Math.abs(b[1]-p[1]);});
      if(hit){let id=hit.id;if(hit.matrix?.pick){const p=this.project(hit.at),m=this.matrix,dx=(x-p[0])/m[0],dy=(y-p[1]-m[1]*dx)/m[5];
        const h=1024*hit.height/hit.width,u=(dx/hit.width+.5)*1024,v=(.5-dy/hit.height)*h;
        const col=Math.floor((u-85)/((1024-115)/hit.matrix.values[0].length)),row=Math.floor((v-135)/((h-180)/hit.matrix.values.length));
        if(row>=0&&row<hit.matrix.values.length&&col>=0&&col<hit.matrix.values[0].length)id+=`:cell:${row}:${col}`;}
        this.onPick(id);}}});
    canvas.addEventListener('wheel',e=>{e.preventDefault();this.zoom=Math.max(.55,Math.min(3.5,this.zoom*Math.exp(-e.deltaY*.001)));this.draw();},{passive:false});
    new ResizeObserver(()=>this.draw()).observe(canvas);
    canvas.addEventListener('webglcontextlost',e=>{e.preventDefault();canvas.setAttribute('data-context','lost');this.onChange();});
    canvas.dataset.context='webgl2';
  }
  reset(){this.yaw=-.11;this.tilt=.19;this.zoom=1;this.pan=[0,0,0];this.draw();}
  setScene(s:Scene,extent=12){this.scene=s;this.extent=extent;this.draw();}
  project(p:V3){const m=this.matrix;return [m[0]*p[0]+m[4]*p[1]+m[8]*p[2]+m[12],m[1]*p[0]+m[5]*p[1]+m[9]*p[2]+m[13]];}
  private geometry(vertices:number[],color:string,texture?:WebGLTexture){const gl=this.gl;
    gl.bufferData(gl.ARRAY_BUFFER,new Float32Array(vertices),gl.STREAM_DRAW);
    gl.uniform4f(gl.getUniformLocation(this.program,'tint'),...rgb(color) as [number,number,number],1);
    gl.uniform1i(gl.getUniformLocation(this.program,'textured'),texture?1:0);
    if(texture)gl.bindTexture(gl.TEXTURE_2D,texture);gl.drawArrays(gl.TRIANGLES,0,vertices.length/5);
  }
  private quad(a:V3,b:V3,c:V3,d:V3,color:string,texture?:WebGLTexture){this.geometry([...a,0,1,...b,1,1,...c,1,0,...a,0,1,...c,1,0,...d,0,0],color,texture);}
  private box(at:V3,w:number,h:number,color:string){const [x,y,z]=at,depth=.18;
    this.quad([x-w/2,y-h/2,z],[x+w/2,y-h/2,z],[x+w/2,y+h/2,z],[x-w/2,y+h/2,z],color);
    this.quad([x-w/2,y-h/2,z+depth],[x+w/2,y-h/2,z+depth],[x+w/2,y-h/2,z],[x-w/2,y-h/2,z],'#07131f');
    this.quad([x+w/2,y-h/2,z+depth],[x+w/2,y+h/2,z+depth],[x+w/2,y+h/2,z],[x+w/2,y-h/2,z],'#223e52');
  }
  private texture(card:Card){const key=JSON.stringify([card.lines,card.color,card.active,card.width,card.height,card.matrix,card.fill]);if(this.cache.has(key))return this.cache.get(key)!;
    const c=document.createElement('canvas');c.width=1024;c.height=Math.round(1024*card.height/card.width);const ctx=c.getContext('2d')!;
    ctx.fillStyle=card.fill??(this.light?'#ffffff':card.active?'#172f40':'#102233');ctx.fillRect(0,0,c.width,c.height);
    ctx.strokeStyle=card.color;ctx.lineWidth=card.active?12:5;ctx.strokeRect(3,3,c.width-6,c.height-6);
    const padY=card.matrix?35:Math.min(35,c.height*.13),small=card.width<1;
    const lh=card.matrix?100:Math.min(small?900:240,(c.height-2*padY)/Math.max(1,card.lines.length));
    card.lines.forEach((line,i)=>{ctx.font=`${i===0?'600':'400'} ${card.matrix?90:Math.min(small?650:140,lh*.74)}px ui-monospace, monospace`;
      ctx.fillStyle=i===0?card.color:this.light?'#303b50':line.startsWith('→')?'#fec77a':line.startsWith('·')?'#9bb2c4':'#e6f0f8';
      ctx.fillText(line,35,padY+lh*(i+.75),c.width-70);});
    if(card.matrix){const m=card.matrix,nr=m.values.length,nc=m.values[0].length,cw=(c.width-115)/nc,ch=(c.height-180)/nr;
      ctx.textAlign='center';ctx.textBaseline='middle';
      for(let r=0;r<nr;r++)for(let col=0;col<nc;col++){const x=85+col*cw,y=135+r*ch;
        const focus=m.focus?.rows.includes(m.rows?.[r]??r)&&m.focus.cols.includes(m.cols?.[col]??col),selected=m.cell?.[0]===r&&m.cell[1]===col;
        ctx.fillStyle=this.light?(selected?'#fbe5cd':focus?'#dceeea':'#eef1f7'):selected?'#57472f':focus?'#244b55':'#122b3b';ctx.fillRect(x+2,y+2,cw-4,ch-4);
        ctx.strokeStyle=selected?(this.light?'#bd631e':'#ffffff'):focus?card.color:this.light?'#dbe1ec':'#294658';ctx.lineWidth=selected?5:2;ctx.strokeRect(x+2,y+2,cw-4,ch-4);
        ctx.font=`500 ${Math.min(240,cw*.48,ch*.58)}px ui-monospace, monospace`;ctx.fillStyle=this.light?'#233146':m.values[r][col]==null?'#536f81':'#e7f3f5';
        ctx.fillText(m.values[r][col]==null?'·':String(m.values[r][col]),x+cw/2,y+ch/2,cw-10);
      }
      ctx.font='32px ui-monospace, monospace';ctx.fillStyle='#87a4b7';
      for(let r=0;r<nr;r++)ctx.fillText(String(m.rows?.[r]??r),48,135+(r+.5)*ch);
      for(let col=0;col<nc;col++)ctx.fillText(String(m.cols?.[col]??col),85+(col+.5)*cw,117);
      if(m.block){ctx.strokeStyle=card.color;ctx.lineWidth=5;
        for(let r=0;r<nr;r+=m.block)for(let col=0;col<nc;col+=m.block)ctx.strokeRect(85+col*cw+1,135+r*ch+1,Math.min(m.block,nc-col)*cw-2,Math.min(m.block,nr-r)*ch-2);}
    }
    const gl=this.gl,t=gl.createTexture()!;gl.bindTexture(gl.TEXTURE_2D,t);gl.texImage2D(gl.TEXTURE_2D,0,gl.RGBA,gl.RGBA,gl.UNSIGNED_BYTE,c);
    gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_MIN_FILTER,gl.LINEAR);gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_MAG_FILTER,gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_WRAP_S,gl.CLAMP_TO_EDGE);gl.texParameteri(gl.TEXTURE_2D,gl.TEXTURE_WRAP_T,gl.CLAMP_TO_EDGE);
    this.cache.set(key,t);if(this.cache.size>160){const old=this.cache.keys().next().value!;gl.deleteTexture(this.cache.get(old)!);this.cache.delete(old);}return t;
  }
  draw(){const gl=this.gl;if(gl.isContextLost())return;const r=this.canvas.getBoundingClientRect();if(!r.width||!r.height)return;
    const dpr=Math.min(devicePixelRatio,2);this.canvas.width=Math.round(r.width*dpr);this.canvas.height=Math.round(r.height*dpr);gl.viewport(0,0,this.canvas.width,this.canvas.height);
    if(this.light)gl.clearColor(.968,.974,.987,1);else gl.clearColor(.025,.05,.08,1);gl.clear(gl.COLOR_BUFFER_BIT|gl.DEPTH_BUFFER_BIT);gl.useProgram(this.program);gl.bindVertexArray(this.vao);gl.bindBuffer(gl.ARRAY_BUFFER,this.buffer);
    const cy=Math.cos(this.yaw),sy=Math.sin(this.yaw),ct=Math.cos(this.tilt),st=Math.sin(this.tilt),sx=this.zoom/this.extent,sz=.012;
    const syScale=sx*r.width/r.height;this.matrix=new Float32Array([cy*sx,sy*st*syScale,-sy*ct*sz,0, 0,ct*syScale,st*sz,0, sy*sx,-cy*st*syScale,cy*ct*sz,0,this.pan[0]*sx,this.pan[1]*syScale,0,1]);
    gl.uniformMatrix4fv(gl.getUniformLocation(this.program,'camera'),false,this.matrix);
    for(const edge of this.scene.edges)this.edge(edge);
    for(const c of this.scene.cards){this.box([c.at[0],c.at[1],c.at[2]+.01],c.width,c.height,c.color);const [x,y,z]=c.at;
      // Smaller z is nearer under the orthographic depth convention.
      this.quad([x-c.width/2,y-c.height/2,z-.02],[x+c.width/2,y-c.height/2,z-.02],[x+c.width/2,y+c.height/2,z-.02],[x-c.width/2,y+c.height/2,z-.02],'#ffffff',this.texture(c));}
    this.canvas.dataset.cards=String(this.scene.cards.length);this.canvas.dataset.edges=String(this.scene.edges.length);this.onChange();
  }
  /** Round polyline corners, keep a dark casing between crossing lanes, and put
   * one arrowhead at the destination port. Dashed routes denote inferred I/O. */
  private edge(edge:Edge){const raw=[edge.from,...(edge.via??[]),edge.to],points:V3[]=[raw[0]];
    const lerp=(a:V3,b:V3,t:number):V3=>a.map((v,i)=>v+(b[i]-v)*t) as V3;
    for(let i=1;i<raw.length-1;i++){const a=raw[i-1],b=raw[i],c=raw[i+1],la=Math.hypot(b[0]-a[0],b[1]-a[1]),lb=Math.hypot(c[0]-b[0],c[1]-b[1]);
      const radius=Math.min(.28,la*.35,lb*.35),start=lerp(b,a,radius/(la||1)),end=lerp(b,c,radius/(lb||1));points.push(start);
      for(let j=1;j<=8;j++){const t=j/8;points.push(lerp(lerp(start,b,t),lerp(b,end,t),t));}}
    points.push(edge.to);const w=edge.width??.03;
    const ribbon=(a:V3,b:V3,width:number,color:string,z:number)=>{const dx=b[0]-a[0],dy=b[1]-a[1],len=Math.hypot(dx,dy)||1,nx=-dy/len*width,ny=dx/len*width;
      this.quad([a[0]+nx,a[1]+ny,a[2]+z],[b[0]+nx,b[1]+ny,b[2]+z],[b[0]-nx,b[1]-ny,b[2]+z],[a[0]-nx,a[1]-ny,a[2]+z],color);};
    for(let i=1;i<points.length;i++)ribbon(points[i-1],points[i],w+.023,this.light?'#f7f9fc':'#06101b',.007);
    let distance=0;
    for(let i=1;i<points.length;i++){const a=points[i-1],b=points[i],len=Math.hypot(b[0]-a[0],b[1]-a[1]);
      if(!edge.dashed)ribbon(a,b,w,edge.color,0);
      else for(let d=0;d<len;){const phase=(distance+d)%.36,run=Math.min(len-d,.36-phase+.000001);if(phase<.23){const end=Math.min(d+run,d+.23-phase);if(end>d)ribbon(lerp(a,b,d/len),lerp(a,b,end/len),w,edge.color,0);}d+=run;}
      distance+=len;}
    if(edge.arrow!==false){const a=points[points.length-2],b=edge.to,dx=b[0]-a[0],dy=b[1]-a[1],len=Math.hypot(dx,dy)||1,tx=dx/len,ty=dy/len,head=Math.max(.17,w*4.8);
      this.geometry([...b,0,0,b[0]-tx*head-ty*head*.52,b[1]-ty*head+tx*head*.52,b[2],0,0,b[0]-tx*head+ty*head*.52,b[1]-ty*head-tx*head*.52,b[2],0,0],edge.color);}
  }
}
