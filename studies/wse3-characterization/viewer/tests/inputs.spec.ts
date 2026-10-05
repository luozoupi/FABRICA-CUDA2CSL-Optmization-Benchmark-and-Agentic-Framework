import {test,expect} from '@playwright/test';
import {readFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {inputStateAt} from '../src/input-model';
import type {Scene} from '../src/time-model';
const scenes:Scene[]=JSON.parse(readFileSync(resolve('public/time-bundle.json'),'utf8')).scenes;

test('input selection never backfills future multiplies or receive operands',()=>{
  for(const s of scenes){
    for(const pe of s.pes){
      const first=s.events.find(e=>e.pe===pe.id&&e.kind==='multiply')!;
      expect(inputStateAt(s,pe,first.cycle-1).last_multiply).toBeNull();
      expect(inputStateAt(s,pe,first.cycle-1).panels).toEqual([]);
      expect(inputStateAt(s,pe,first.cycle).last_multiply?.value).toBe(first.value);
      for(const cycle of [...new Set((s.input_receipts||[]).filter(e=>e.pe===pe.id).map(e=>e.cycle))]){
        for(const at of [cycle-1,cycle]){
          const view=inputStateAt(s,pe,at);
          for(const b of view.received)for(let i=0;i<b.values.length;i++){
            const e=(s.input_receipts||[]).filter(e=>e.pe===pe.id&&e.tensor===b.tensor&&e.index===i&&e.cycle<=at).at(-1);
            expect(b.values[i]).toBe(e?.value??null);
            if(b.observations[i])expect(b.observations[i]!.cycle).toBeLessThanOrEqual(at);
          }
        }
      }
    }
  }
  const g=scenes.find(s=>s.id==='g1')!,pe=g.pes.find(p=>p.id==='0,0')!;
  const end=inputStateAt(g,pe,g.end,0);
  expect(end.initial[0].values).toEqual([1,2,5,6]);
  expect(end.panels.find(p=>p.tensor==='A')?.values).toEqual([3,4,7,8]);
});

test('input inspector below the full-width stack follows PE/time selection',async({page})=>{
  const errors:string[]=[],network:string[]=[];
  page.on('pageerror',e=>errors.push(e.message));page.on('request',r=>{if(/^https?:/.test(r.url()))network.push(r.url());});
  await page.goto('file://'+resolve('../results/gemv-walkthrough/space-time.html'));
  const panel=page.locator('.stage-inputs');
  await expect(panel.getByRole('heading',{name:'Inputs on PE (0,1)'})).toBeVisible();
  await expect(panel.locator('[data-input-coordinate="X[2]"]')).toHaveText('-1');
  await expect(panel.locator('[data-input-coordinate="W[3,0]"]')).toHaveText('13');
  await expect(panel.locator('.input-use')).toContainText('3 × 13 = 39');
  const stage=await page.locator('.stage-shell').boundingBox(),side=await panel.boundingBox();
  expect(side!.y).toBeGreaterThan(stage!.y+stage!.height-1);
  await page.screenshot({path:'../results/gemv-walkthrough/space-time-inputs.png',fullPage:true});
  await panel.locator('[data-input-select="1,0"]').click();
  await expect(panel.locator('[data-input-coordinate="W[0,2]"]')).toHaveText('3');
  await page.locator('[data-scene="g1"]').click();
  await page.locator('.layer-rail [data-layer]').last().click();
  await expect(panel.locator('.initial-inputs [data-input-coordinate="A[0,0]"]')).toHaveText('1');
  await expect(panel.locator('.round-inputs [data-storage="abuf"]')).toContainText('from PE (1,0)');
  await expect(panel.locator('.round-inputs [data-input-coordinate="A[0,2]"]')).toHaveText('3');
  await panel.locator('.received-inputs summary').click();
  await expect(panel.locator('.received-inputs')).toContainText('abuf');
  const pending=page.waitForEvent('download');await page.getByRole('button',{name:'Export displayed layer data'}).click();
  const file=await pending,downloaded=JSON.parse(readFileSync((await file.path())!,'utf8'));
  expect(downloaded.inputs).toHaveLength(downloaded.layers.length);
  expect(downloaded.inputs.at(-1).pes.find((p:any)=>p.pe==='0,0').initial[0].values).toEqual([1,2,5,6]);
  await page.screenshot({path:'../results/gemv-walkthrough/gemm-layer-inputs.png',fullPage:true});
  await page.setViewportSize({width:390,height:844});
  expect(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1)).toBeTruthy();
  await page.screenshot({path:'../results/gemv-walkthrough/input-panel-mobile.png',fullPage:true});
  await page.goto('file://'+resolve('../results/gemv-walkthrough/time-slices.html'));
  await expect(page.locator('.input-context')).toBeVisible();
  await page.locator('[data-input-select="0,1"]').click();
  await expect(page.locator('[data-input-coordinate="X[2]"]')).toHaveText('-1');
  expect(errors).toEqual([]);expect(network).toEqual([]);
});
