import {test,expect} from '@playwright/test';
import {readFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {layersFor,outputFor,slotFor,transferLayers,transfersFor} from '../src/layer-model';
import type {Scene} from '../src/time-model';

const bundle=JSON.parse(readFileSync(resolve('public/time-bundle.json'),'utf8'));
const scenes:Scene[]=bundle.scenes;
const v1=scenes.find(s=>s.id==='v1')!;

test('layers preserve numeric histories and transfer evidence boundaries',()=>{
  const layers=layersFor(v1,0,'story');
  expect(layers.map(l=>l.cycle)).toEqual([8525,10730,11315,11359,11831,12487]);
  expect(layers[1].states['0,0'].partial).toEqual([11,14]);
  expect(layers[1].states['0,1'].partial).toEqual([30,32]);
  expect(layers[2].states['0,1'].peer).toEqual([11,14]);
  expect(layers[2].states['0,1'].result).toEqual([null,null]);
  expect(layers[3].states['0,1'].result).toEqual([41,null]);
  expect(layers[3].states['0,0'].result).toEqual([null,null]);
  expect(layers[5].states['0,0'].result).toEqual([41,46]);
  const links=transfersFor(v1,0);
  expect(links.map(l=>l.value)).toEqual([11,41]);
  expect(links.map(l=>transferLayers(l,layers))).toEqual([[1,2],[4,5]]);
  const broken=structuredClone(v1);
  broken.events.find(e=>e.pe==='0,1'&&e.phase==='peer')!.values!.peer[0]=999;
  expect(transfersFor(broken,0).map(l=>l.kind)).toEqual(['replica']);
  const missing=structuredClone(v1);missing.events=missing.events.filter(e=>e.phase!=='reduced');
  expect(transfersFor(missing,0).map(l=>l.kind)).toEqual(['partial']);
  for(const scene of scenes){
    const frames=layersFor(scene,0,'uniform',8),last=frames.at(-1)!;
    expect(frames).toHaveLength(8);expect(frames[0].cycle).toBe(scene.start);expect(last.cycle).toBe(scene.end);
    for(const pe of scene.pes)expect(scene.kind==='gemv'?last.states[pe.id].result:last.states[pe.id].partial).toEqual(pe.final_readback);
    if(scene.kind==='gemm')expect(transfersFor(scene,0)).toEqual([]);
    for(const pe of scene.pes)for(let slot=0;slot<scene.slots;slot++)expect(slotFor(scene,pe,outputFor(scene,pe,slot))).toBe(slot);
  }
});

test('CNN-style stack supports picking, rotation, zoom, and sampling modes',async({page})=>{
  const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto('/space-time/space-time.html');
  await page.locator('#presentation').selectOption('stack');
  await expect(page.getByRole('heading',{name:'Layers of execution.'})).toBeVisible();
  await expect(page.locator('[data-layer-plane]')).toHaveCount(6);
  await expect(page.locator('[data-mesh-node]')).toHaveCount(24);
  await expect(page.locator('[data-logical-link]')).toHaveCount(2);
  await expect(page.locator('.micro-flow')).toContainText('30');await expect(page.locator('.micro-flow')).toContainText('41');
  await page.locator('#layer-stage [data-pick="2|0,1|peer|0"]').focus();await page.keyboard.press('Enter');
  await expect(page.getByRole('heading',{name:'PE (0,1) · layer 3',exact:true})).toBeVisible();
  await expect(page.locator('.layer-buffers>div').nth(2)).toContainText('?');
  await page.getByRole('button',{name:'Next layer',exact:true}).click();
  await expect(page.locator('.layer-buffers>div').nth(2)).toContainText('41');
  const before=await page.locator('.layer-buffers').innerText();
  const box=await page.locator('#layer-stage').boundingBox();
  await page.mouse.move(box!.x+box!.width/2,box!.y+box!.height/2);await page.mouse.down();await page.mouse.move(box!.x+box!.width/2+90,box!.y+box!.height/2+30,{steps:8});await page.mouse.up();
  await expect(page.locator('#camera-readout')).not.toContainText('rotation 52°');
  expect(await page.locator('.layer-buffers').innerText()).toBe(before);
  await page.getByRole('button',{name:'Expand selected layer',exact:true}).click();
  await expect(page.getByRole('button',{name:'Show full stack',exact:true})).toBeVisible();
  await page.getByRole('button',{name:'Reset view',exact:true}).click();
  await page.locator('#sampling').selectOption('uniform');await page.locator('#count').fill('8');await page.locator('#count').press('Tab');
  await expect(page.locator('[data-layer-plane]')).toHaveCount(8);
  await page.locator('#sampling').selectOption('events');await expect(page.getByRole('slider',{name:'Event window'})).toBeVisible();
  await page.locator('#sampling').selectOption('story');await page.locator('#output').selectOption('2');
  await expect(page.locator('.intro-evidence')).toContainText('Y[2]');
  await page.reload();await expect(page.locator('.intro-evidence')).toContainText('Y[2]');
  await page.locator('[data-scene="g1"]').click();await expect(page.locator('[data-logical-link]')).toHaveCount(0);
  expect(errors).toEqual([]);
});

test('portable layered page and SVG export work offline at desktop and mobile sizes',async({page})=>{
  const errors:string[]=[],network:string[]=[];
  page.on('pageerror',e=>errors.push(e.message));page.on('request',r=>{if(/^https?:/.test(r.url()))network.push(r.url());});
  await page.goto('file://'+resolve('../results/gemv-walkthrough/space-time.html'));
  await expect(page.locator('[data-layer-plane]')).toHaveCount(6);
  await page.screenshot({path:'../results/gemv-walkthrough/space-time-desktop.png',fullPage:true});
  const pending=page.waitForEvent('download');await page.getByRole('button',{name:'Export SVG',exact:true}).click();
  const svg=await pending;await svg.saveAs(resolve('../results/gemv-walkthrough/space-time-overview.svg'));
  const xml=readFileSync(await svg.path(),'utf8');expect(xml.includes('xmlns="http://www.w3.org/2000/svg"')).toBe(true);expect(xml.includes('partial')).toBe(true);expect(xml.includes('12487')).toBe(true);expect(xml.includes('var(--')).toBe(false);
  await page.getByRole('button',{name:'Expand selected layer',exact:true}).click();
  await page.screenshot({path:'../results/gemv-walkthrough/space-time-expanded.png',fullPage:true});
  await page.getByRole('button',{name:'Reset view',exact:true}).click();
  await page.setViewportSize({width:390,height:844});await page.locator('[data-scene="v2"]').click();
  expect(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1)).toBeTruthy();
  await expect(page.locator('[data-layer-plane]')).toHaveCount(6);
  await page.screenshot({path:'../results/gemv-walkthrough/space-time-mobile.png',fullPage:true});
  const download=page.waitForEvent('download');await page.getByRole('button',{name:'Export displayed layer data'}).click();expect((await download).suggestedFilename()).toBe('v2-pe-time-layers.json');
  expect(errors).toEqual([]);expect(network).toEqual([]);
});
