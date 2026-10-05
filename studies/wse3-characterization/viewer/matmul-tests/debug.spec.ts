import {test,expect} from '@playwright/test';
import {pathToFileURL} from 'node:url';
import path from 'node:path';
test('weight streaming separates residency, exact AXPY, row reduction and output',async({page,request})=>{
 const b=await (await request.get('/api/matmul')).json(),m=b.hardware_dataflow;
 const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
 await page.goto('/matmul.html#view=stream');await expect(page.locator('#stream-mesh')).toHaveAttribute('data-context','webgl2');await expect(page.locator('#stream-core')).toHaveAttribute('data-context','webgl2');
 expect((await page.locator('#stream-matrices .matrix-a [role=cell]').allTextContents()).map(Number)).toEqual(m.X.flat());
 expect((await page.locator('#stream-matrices .matrix-b [role=cell]').allTextContents()).map(Number)).toEqual(m.W.flat());
 await expect(page.locator('#stream-inspector')).toContainText('Placement pending');
 const broadcast=m.steps.findIndex((s:any)=>s.phase==='broadcast');await page.locator('#stream-jump').selectOption(String(broadcast));
 await expect(page.locator('#stream-equations')).toContainText('MemoryX → PE (0,0)');
 await page.locator('#stream-mesh').screenshot({path:'../results/matmul-compare/weight-streaming-broadcast.png'});
 await page.locator('#stream-next').click();await expect(page.locator('#stream-equations')).toContainText('[0, 0] + [1, 5] × 1 = [1, 5]');
 await page.locator('#stream-next-reduction').click();await expect(page.locator('#stream-equations')).toContainText('[1, 5] + incoming [10, 22] = [11, 27]');
 await page.screenshot({path:'../results/matmul-compare/weight-streaming-reduction.png',fullPage:true});
 await page.locator('#stream-next').click();await expect(page.locator('#stream-matrices .matrix-c [role=cell]').first()).toHaveText('11');
 await page.locator('[data-stream-pe="1,0"]').click();await expect(page.locator('#stream-inspector')).toContainText('Input features k = [2, 3]');
 const skip=m.steps.findIndex((s:any)=>s.phase==='skip');await page.locator('#stream-jump').selectOption(String(skip));await expect(page.locator('#stream-equations')).toContainText('no injected weight');
 await page.locator('#stream-final').click();await expect(page.locator('#stream-inspector')).toContainText('PASS');
 expect((await page.locator('#stream-matrices .matrix-c [role=cell]').allTextContents()).map(Number)).toEqual(m.reference.flat());
 expect(errors).toEqual([]);
});
test('weight streaming standalone remains offline and usable on mobile',async({page})=>{
 const network:string[]=[];page.on('request',r=>{if(r.url().startsWith('http'))network.push(r.url());});
 await page.goto(pathToFileURL(path.resolve('../results/matmul-compare/matmul.html')).href+'#view=stream');
 await expect(page.locator('#stream-mesh')).toHaveAttribute('data-context','webgl2');await page.locator('#stream-next').click();
 await page.setViewportSize({width:390,height:844});expect(await page.evaluate(()=>document.documentElement.scrollWidth)).toBeLessThanOrEqual(391);
 await page.screenshot({path:'../results/matmul-compare/weight-streaming-mobile.png',fullPage:true});
 await page.locator('#stream-open-capture').click();await expect(page.locator('#mesh-view')).toBeVisible();expect(network).toEqual([]);
});
test('API ranks only correct repeated kernels and exposes all three matrix sizes',async({request})=>{
 const b=await (await request.get('/api/matmul')).json();expect(b.cases.map((c:any)=>c.n)).toEqual([4,8,32]);
 for(const c of b.cases){expect(c.variants.filter((v:any)=>v.passed)).toHaveLength(11);expect(c.variants.filter((v:any)=>v.passed).sort((a:any,b:any)=>a.median-b.median)[0].name).toBe('ikj_map');}
 expect(b.cases[2].variants.find((v:any)=>v.name==='ikj_packed_blk').median).toBe(17550);
});
test('WebGL instruction and element stepping shows matched data',async({page,request})=>{
 const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
 const b=await (await request.get('/api/matmul')).json();const v=b.cases[0].variants.find((v:any)=>v.name==='ikj_map');
 await page.goto('/matmul.html');await expect(page.locator('#matmul-canvas')).toHaveAttribute('data-context','webgl2');
 await expect(page.locator('#status')).toContainText(`dispatch c${v.steps[0].trace.cycle}`);
 await page.locator('#next').click();await page.locator('[data-element="2"]').click();const u=v.steps[1].updates[2];
 await expect(page.locator('#equation')).toHaveText(`${u.old} + ${u.a} × ${u.b} = ${u.value}`);
 await page.locator('#local-view .workspace').screenshot({path:'../results/matmul-compare/row-debug.png'});expect(errors).toEqual([]);
});
test('corrected reduction and overwrite diagnostic stay distinct',async({page})=>{
 await page.goto('/matmul.html#n=4&variant=ijk_reduce&step=1&element=3');
 await expect(page.locator('#explanation')).toContainText('zero-stride');await expect(page.locator('#inspector')).toContainText('FADDH');
 await page.locator('#local-view .workspace').screenshot({path:'../results/matmul-compare/reduction-debug.png'});
 await page.locator('#variant').selectOption('ijk_bad');await page.locator('#next').click();await page.locator('[data-element="3"]').click();
 await expect(page.locator('#equation')).toContainText('0 +');await expect(page.locator('#inspector')).toContainText('FAIL');
 await expect(page.locator('[data-result="32:ijk_bad"]')).toContainText('not ranked');
 await page.locator('#local-view .workspace').screenshot({path:'../results/matmul-compare/overwrite-diagnostic.png'});
});
test('cell breakpoint, scalar source mode and eight by eight selection',async({page})=>{
 await page.goto('/matmul.html');await page.locator('#break-i').fill('1');await page.locator('#break-j').fill('2');await page.locator('#run-to').click();
 await expect(page.locator('#inspector h2').first()).toHaveText('i=1 · j=2 · k=0');await expect(page.locator('#step-scrub')).toHaveValue('4');
 await page.locator('#break-i').fill('99');await page.locator('#run-to').click();await expect(page.locator('#break-status')).toContainText('outside');
 await page.locator('#size').selectOption('8');await page.locator('#variant').selectOption('ikj_packed_blk');await expect(page.locator('#explanation')).toContainText('packed');
 await page.locator('#local-view .workspace').screenshot({path:'../results/matmul-compare/packed-tile-debug.png'});
 await page.locator('#variant').selectOption('ijk_scalar');await expect(page.locator('#status')).toContainText('Source-order');
});
test('standalone is offline and mobile has no page overflow',async({page})=>{
 const network:string[]=[];page.on('request',r=>{if(r.url().startsWith('http'))network.push(r.url());});
 await page.goto(pathToFileURL(path.resolve('../results/matmul-compare/matmul.html')).href);await expect(page.locator('#matmul-canvas')).toHaveAttribute('data-context','webgl2');
 await page.setViewportSize({width:390,height:844});expect(await page.evaluate(()=>document.documentElement.scrollWidth)).toBeLessThanOrEqual(391);expect(network).toEqual([]);
 await page.screenshot({path:'../results/matmul-compare/mobile-debug.png',fullPage:true});
 await page.locator('#view-mesh').click();await page.locator('#mesh-capture').selectOption('v1');
 await expect(page.locator('#mesh-canvas')).toHaveAttribute('data-context','webgl2');expect(network).toEqual([]);
});

test('reference-style matrices preserve inputs, grouped deltas and initial state',async({page,request})=>{
 const b=await (await request.get('/api/matmul')).json(),c=b.cases[0],v=c.variants.find((v:any)=>v.name==='ikj_map');
 await page.goto('/matmul.html');
 await expect(page.locator('.method-rail [role=tab]')).toHaveCount(7);
 expect((await page.locator('#lesson-matrices .matrix-a [role=cell]').allTextContents()).map(Number)).toEqual(c.inputs.A.flat());
 await page.locator('[data-family="rowvec"]').click();await page.locator('#gran-coarse').click();
 const expected=v.steps[3].after.flat();
 expect((await page.locator('#lesson-matrices .matrix-c [role=cell]').allTextContents()).map(Number)).toEqual(expected);
 expect((await page.locator('#lesson-matrices .delta [role=cell]').allTextContents()).map(Number)).toEqual(expected);
 await expect(page.locator('#progress-final')).toHaveText('4 / 16 finalized');
 await page.locator('[data-phase="launch"]').click();
 expect((await page.locator('#lesson-matrices .matrix-c [role=cell]').allTextContents()).map(Number)).toEqual(Array(16).fill(0));
 await page.locator('[data-phase="readback"]').click();await expect(page.locator('#group-caption')).toContainText('PASS');
 expect((await page.locator('#lesson-matrices .matrix-c [role=cell]').allTextContents()).map(Number)).toEqual(v.output.flat());
 await page.locator('[data-phase="compute"]').click();await page.screenshot({path:'../results/matmul-compare/reference-style.png',fullPage:false});
});

test('mesh GEMM follows packed A payload, fine arithmetic and exact host output',async({page,request})=>{
 const b=await (await request.get('/api/matmul')).json(),s=b.mesh_scenes.find((s:any)=>s.id==='g1');
 const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));await page.goto('/matmul.html');await page.locator('#view-mesh').click();
 await expect(page.locator('#mesh-canvas')).toHaveAttribute('data-context','webgl2');
 await page.locator('[data-mesh-step="11"]').click();await expect(page.locator('#mesh-transfer')).toContainText('PE (0,0) → PE (1,0)');
 await page.locator('#mesh-fine').click();await expect(page.locator('#mesh-transfer tbody tr')).toHaveCount(1);
 await expect(page.locator('#mesh-matrices .matrix-a .operand')).toHaveCount(4);
 await expect(page.locator('#mesh-matrices .matrix-a .selected')).toHaveText('1');
 const first=s.packets.find((p:any)=>p.id===s.teaching.steps[11].flows[0].packet_ids[0]);
 await expect(page.locator('#mesh-transfer')).toContainText(`receive c${first.receive.cycle}`);
 await page.locator('[data-pe="1,0"]').click();await expect(page.locator('#mesh-inspector')).toContainText('abuf');
 await page.screenshot({path:'../results/matmul-compare/mesh-panel.png',fullPage:true});
 await page.locator('[data-mesh-step="13"]').click();await expect(page.locator('#mesh-inspector')).toContainText('Observed instruction');
 await expect(page.locator('#mesh-equation')).toContainText('×');
 await page.locator('#mesh-next').click();await expect(page.locator('#mesh-equation')).toContainText('+');
 await page.locator('#mesh-coarse').click();await page.locator(`[data-mesh-step="${s.teaching.steps.length-1}"]`).click();
 expect((await page.locator('#mesh-host-output [role=cell]').allTextContents()).map(Number)).toEqual(s.host.output.flat());
 await expect(page.locator('#mesh-inspector')).toContainText('PASS');expect(errors).toEqual([]);
});

test('MeshGEMV exposes partial reduction and retains numeric inputs on mobile',async({page,request})=>{
 const b=await (await request.get('/api/matmul')).json(),s=b.mesh_scenes.find((s:any)=>s.id==='v1');
 await page.goto('/matmul.html');await page.locator('#view-mesh').click();await page.locator('#mesh-capture').selectOption('v1');
 await page.locator('[data-mesh-step="13"]').click();await expect(page.locator('#mesh-equation')).toContainText('30, 32 + 11, 14 → 41, 46');
 await expect(page.locator('#mesh-transfer')).toContainText('30 + 11 = 41');
 await page.locator('[data-mesh-step="15"]').click();await expect(page.locator('#mesh-transfer')).toContainText('PE (0,1) → PE (0,0)');
 await page.locator(`[data-mesh-step="${s.teaching.steps.length-1}"]`).click();
 expect((await page.locator('#mesh-host-output [role=cell]').allTextContents()).map(Number)).toEqual([41,46,51,56]);
 expect((await page.locator('#mesh-matrices .matrix-a [role=cell]').allTextContents()).map(Number)).toEqual(s.host.inputs[0].values.flat());
 await page.setViewportSize({width:390,height:844});expect(await page.evaluate(()=>document.documentElement.scrollWidth)).toBeLessThanOrEqual(391);
 await page.screenshot({path:'../results/matmul-compare/mesh-mobile.png',fullPage:true});
});
