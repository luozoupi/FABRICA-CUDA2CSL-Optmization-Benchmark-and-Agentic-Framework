import {test,expect} from '@playwright/test';
import {pathToFileURL} from 'node:url';
import path from 'node:path';

test('backend preserves arithmetic, unknown initial state, lineage and query bounds',async({request})=>{
  const catalog=await (await request.get('/api/scenes')).json();expect(catalog).toHaveLength(6);
  const scene=await (await request.get('/api/scenes/v1')).json();expect(scene.host.output).toEqual([[41,46,51,56]]);
  const teaching=await (await request.get('/api/scenes/v1/walkthrough')).json();expect(teaching.checked_operations).toBe(16);expect(teaching.steps.at(-1).state['0,1'].result).toEqual([41,46]);
  const initial=await (await request.get(`/api/scenes/v1/frame?cycle=${scene.start-1}`)).json();expect(initial.pes['0,0'].partial).toEqual([null,null]);
  const lineage=await (await request.get('/api/scenes/v1/lineage?output=0')).json();expect(lineage.events.some((e:any)=>e.kind==='reduce'&&e.value===41)).toBeTruthy();
  expect((await request.get('/api/scenes/v1/events?limit=-1')).status()).toBe(400);
  expect((await request.get('/api/scenes/v1/lineage?output=99')).status()).toBe(400);
  expect((await request.get('/api/scenes/unknown')).status()).toBe(404);
  const first=await (await request.get('/api/scenes/v1/events?limit=3')).json();expect(first.events).toHaveLength(3);expect(first.next_offset).toBe(3);
});

test('WebGL journey includes inputs, a matched packet and host result',async({page})=>{
  const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto('/dataflow.html');await expect(page.locator('#fabric')).toHaveAttribute('data-context','webgl2');
  await expect(page.locator('#scrub')).toBeDisabled();
  await expect(page.getByRole('button',{name:'X[0,2] = -1',exact:true})).toBeVisible();
  await page.locator('[data-chapter="2"]').click();await page.screenshot({path:'../results/dataflow-inputs.png',fullPage:true});
  await page.locator('[data-chapter="4"]').click();await expect(page.locator('#scrub')).toBeEnabled();
  await expect(page.locator('#packet-detail')).toContainText('14310831030273');await expect(page.locator('#packet-detail')).toContainText('30 + 11 = 41');
  const nonbackground=await page.locator('#fabric').evaluate((node:HTMLCanvasElement)=>{const gl=node.getContext('webgl2')!;const pixels=new Uint8Array(gl.drawingBufferWidth*gl.drawingBufferHeight*4);gl.readPixels(0,0,gl.drawingBufferWidth,gl.drawingBufferHeight,gl.RGBA,gl.UNSIGNED_BYTE,pixels);let count=0;for(let i=0;i<pixels.length;i+=4)if(pixels[i]>70||pixels[i+1]>90)count++;return count;});expect(nonbackground).toBeGreaterThan(10000);
  await page.screenshot({path:'../results/dataflow-packet.png',fullPage:true});
  await page.locator('[data-chapter="6"]').click();await expect(page.locator('#stage-title')).toHaveText('Host output');
  await expect(page.locator('#host-output')).toContainText('56');expect(errors).toEqual([]);
});

test('input selection links exact owners and uses; output includes reduction',async({page})=>{
  await page.goto('/dataflow.html');await page.getByRole('button',{name:'X[0,2] = -1',exact:true}).click();
  await expect(page.locator('#input-lineage')).toContainText('(0,1), (1,1)');
  await expect(page.locator('#input-lineage')).toContainText('-1 × 9 = -9');
  await page.locator('#input-lineage button').first().click();await expect(page.locator('#cycle-number')).toHaveValue('8598');
  await page.getByRole('button',{name:'Y[0,0] = 41',exact:true}).click();await expect(page.locator('#output-equation')).toContainText('30 + 11 = 41');
});

test('time layers and GEMM remain interactive',async({page})=>{
  await page.goto('/dataflow.html#scene=v1&chapter=4&cycle=10857');await page.locator('[data-view="layers"]').click();
  await expect(page.locator('#fabric')).toHaveAttribute('data-cards','15');await page.screenshot({path:'../results/dataflow-layers.png',fullPage:true});
  const before=await page.locator('#fabric').screenshot();const box=await page.locator('#fabric').boundingBox();
  await page.mouse.move(box!.x+200,box!.y+200);await page.mouse.down();await page.mouse.move(box!.x+270,box!.y+220);await page.mouse.up();
  expect((await page.locator('#fabric').screenshot()).equals(before)).toBeFalsy();
  await page.locator('#scene').selectOption('g1');await page.locator('[data-view="journey"]').click();await page.locator('[data-chapter="2"]').click();
  await expect(page.locator('#host-inputs table')).toHaveCount(2);await expect(page.locator('#packet option')).not.toHaveCount(0);
  await page.getByRole('button',{name:'A[0,2] = 3',exact:true}).click();await expect(page.locator('#input-lineage')).toContainText('(1,0)');
  await page.screenshot({path:'../results/dataflow-gemm.png',fullPage:true});
});

test('mobile layout keeps values reachable without page overflow',async({page})=>{
  await page.setViewportSize({width:390,height:844});await page.goto('/dataflow.html#scene=v2&chapter=2');
  await expect(page.locator('#host-inputs table')).toHaveCount(2);
  expect(await page.evaluate(()=>document.documentElement.scrollWidth)).toBeLessThanOrEqual(391);
  await page.screenshot({path:'../results/dataflow-mobile.png',fullPage:true});
});

test('verified SRAM and register snapshots are available through API and WebGL',async({page,request})=>{
  const data=await (await request.get('/api/snapshots')).json();expect(data.cycle_exact).toBe(false);expect(data.cases).toHaveLength(3);
  await page.goto('/dataflow.html');await expect(page.locator('#snapshot-canvas')).toHaveAttribute('data-context','webgl2');
  await expect(page.locator('#snapshot-detail')).toContainText('[12, 42, 43981, 48350]');
  await page.locator('#snapshot-case').selectOption('1');await page.locator('[data-lab-pe="1,0"]').click();await expect(page.locator('#snapshot-detail')).toContainText('[41]');
  await page.locator('#snapshot-case').selectOption('2');await expect(page.locator('#snapshot-canvas')).toHaveAttribute('data-cards','10');
  await page.locator('#snapshot-lab').screenshot({path:'../results/dataflow-snapshots.png'});
});

test('standalone presentation works without a backend or remote assets',async({page})=>{
  const network:string[]=[];page.on('request',r=>{if(r.url().startsWith('http'))network.push(r.url());});
  await page.goto(pathToFileURL(path.resolve('../results/dataflow/dataflow.html')).href);
  await expect(page.locator('#connection')).toContainText('Offline');await expect(page.locator('#fabric')).toHaveAttribute('data-context','webgl2');
  await expect(page.locator('#snapshot-case option')).toHaveCount(3);expect(network).toEqual([]);
});

test('streaming architecture, tile placement and GEMM steps expose checked scalar evidence',async({page,request})=>{
  const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto('/dataflow.html#scene=g1&view=streaming&step=0');
  await expect(page.locator('#inspector')).toContainText('streaming=False');
  await expect(page.locator('#teaching-caption')).toContainText('three west support columns');
  await page.locator('.workspace').screenshot({path:'../results/dataflow/streaming-architecture.png'});
  await page.locator('#teaching-step').selectOption('3');
  await expect(page.locator('#inspector')).toContainText('[3, 7, 4, 8]');
  await expect(page.locator('#inspector')).toContainText('PE (1,0)');
  await page.locator('.workspace').screenshot({path:'../results/dataflow/gemm-tile-placement.png'});
  await page.locator('#teaching-step').selectOption('15');
  await expect(page.locator('#teaching-caption')).toContainText('abuf');
  await expect(page.locator('#inspector')).toContainText('(1,0) → (0,0)');
  await page.locator('.workspace').screenshot({path:'../results/dataflow/gemm-panel-round.png'});
  await page.locator('#teaching-step').selectOption('17');await page.locator('[data-pe="0,0"]').click();
  await expect(page.locator('#inspector .equation')).toContainText('1 + 3 × 2');
  await expect(page.locator('#inspector .equation')).toContainText('= 7');
  await page.locator('[data-teaching-cell="3"]').click();
  await expect(page.locator('#inspector .equation')).toContainText('16 + 7 × 0');
  await page.locator('.workspace').screenshot({path:'../results/dataflow/gemm-scalar-step.png'});
  const scene=await (await request.get('/api/scenes/g1')).json();
  const calc=scene.teaching.steps[17].calculations.find((x:any)=>x.pe==='0,0');
  const event=scene.events.find((e:any)=>e.id===calc.mul_ids[3]);
  await page.locator('#inspector [data-event]').first().click();
  await expect(page.locator('#cycle-number')).toHaveValue(String(event.cycle));
  await expect(page.locator('[data-view="journey"]')).toHaveClass('active');expect(errors).toEqual([]);
});

test('GEMV teaching sequence shows both partials, replicas and host assembly',async({page})=>{
  await page.goto('/dataflow.html#scene=v1&view=streaming&step=13');
  await expect(page.locator('#inspector')).toContainText('30 + 11 = 41');
  await expect(page.locator('#inspector')).toContainText('32 + 14 = 46');
  await page.locator('.workspace').screenshot({path:'../results/dataflow/gemv-reduction-step.png'});
  await page.locator('#teaching-step').selectOption('15');await expect(page.locator('#teaching-caption')).toContainText('replica');
  await page.locator('#teaching-step').selectOption('20');await expect(page.locator('#teaching-next')).toBeDisabled();
  await page.locator('.workspace').screenshot({path:'../results/dataflow/gemv-host-assembly.png'});
  await page.locator('#teaching-previous').click();await expect(page.locator('#teaching-step')).toHaveValue('19');
});

test('eight by eight and single PE teaching cases remain legible and navigable',async({page})=>{
  await page.goto('/dataflow.html#scene=g2&view=streaming&step=19');
  await expect(page.locator('#fabric')).toHaveAttribute('data-context','webgl2');
  await expect(page.locator('[data-teaching-cell]')).toHaveCount(16);
  await page.locator('[data-teaching-cell="15"]').click();await page.locator('.workspace').screenshot({path:'../results/dataflow/gemm-eight-step.png'});
  await page.locator('#scene').selectOption('g0');await page.locator('#teaching-step').selectOption('7');
  await expect(page.locator('[data-pe]')).toHaveCount(1);
  await page.setViewportSize({width:390,height:844});
  expect(await page.evaluate(()=>document.documentElement.scrollWidth)).toBeLessThanOrEqual(391);
  await page.locator('.workspace').screenshot({path:'../results/dataflow/streaming-mobile.png'});
});
