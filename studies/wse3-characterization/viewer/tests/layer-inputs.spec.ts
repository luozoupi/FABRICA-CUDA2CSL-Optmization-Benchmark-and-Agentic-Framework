import {test,expect} from '@playwright/test';
import {readFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {layerInputs} from '../src/layer-inputs';
import {layersFor} from '../src/layer-model';
import type {Scene} from '../src/time-model';

const scenes:Scene[]=JSON.parse(readFileSync('public/time-bundle.json','utf8')).scenes;

test('on-plane arrays retain owned inputs and never disclose a future receive',()=>{
  for(const s of scenes)for(const pe of s.pes){
    for(const layer of layersFor(s,0,'uniform',8)){
      const arrays=layerInputs(s,pe,layer.cycle);
      for(const tile of pe.input_tiles||[])expect(arrays.find(a=>a.key===tile.tensor)?.values).toEqual(tile.values);
    }
    for(const e of s.input_receipts?.filter(e=>e.pe===pe.id)||[]){
      const before=layerInputs(s,pe,e.cycle-1).find(a=>a.key===e.storage)!;
      const previous=s.input_receipts!.filter(q=>q.pe===e.pe&&q.storage===e.storage&&q.index===e.index&&q.cycle<e.cycle).at(-1);
      expect(before.values[e.index]).toBe(previous?.value??null);
      const after=layerInputs(s,pe,e.cycle).find(a=>a.key===e.storage)!;
      expect(after.values[e.index]).toBe(e.value);
      expect(after.titles[e.index]).toContain(`cycle ${e.cycle}`);
    }
  }
});

test('GEMV and GEMM inputs appear inside every time plane and exported figure',async({page})=>{
  const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto('file://'+resolve('../results/gemv-walkthrough/space-time.html'));
  await expect(page.locator('#presentation')).toHaveValue('stack');
  expect(await page.locator('.stack-overview').evaluate(el=>getComputedStyle(el).gridTemplateColumns.split(' ').length)).toBe(1);
  await page.locator('#presentation').selectOption('sheets');
  for(let l=0;l<6;l++){
    const pe=page.locator(`[data-mesh-node="${l}|0,1"]`);
    await expect(pe.locator('[data-input-cell="X:0"]')).toHaveAttribute('data-value','-1');
    await expect(pe.locator('[data-input-cell="X:1"]')).toHaveAttribute('data-value','3');
    await expect(pe.locator('[data-input-cell="W:2"]')).toHaveAttribute('data-value','13');
  }
  const shown=page.locator('[data-mesh-node="3|0,1"] [data-input-cell="X:0"] .input-array-value');
  const box=await shown.boundingBox();expect(box!.height).toBeGreaterThan(12);
  await page.locator('.stage-shell').screenshot({path:'../results/gemv-walkthrough/layer-inputs-gemv.png'});
  const download=page.waitForEvent('download');await page.getByRole('button',{name:'Export SVG',exact:true}).click();
  const svg=await download,xml=readFileSync((await svg.path())!,'utf8');
  expect(xml).toContain('data-layer-array="X"');expect(xml).toContain('data-layer-array="W"');
  expect(xml.includes('X[2] = -1')).toBe(true);expect(xml.includes('var(--')).toBe(false);
  await svg.saveAs(resolve('../results/gemv-walkthrough/layers-with-inputs.svg'));
  await page.locator('#presentation').selectOption('stack');
  await expect(page.locator('#layer-stage [data-layer-array="X"]')).toHaveCount(24);
  await page.getByRole('button',{name:'Expand selected layer',exact:true}).click();
  await expect(page.locator('[data-layer-plane]')).toHaveCount(1);
  await page.locator('.stage-shell').screenshot({path:'../results/gemv-walkthrough/layer-inputs-stack.png'});
  await page.locator('[data-scene="g1"]').click();
  await page.locator('#presentation').selectOption('sheets');
  const initial=page.locator('[data-mesh-node="0|0,0"]');
  await expect(initial.locator('[data-input-cell="A:0"]')).toHaveAttribute('data-value','1');
  await expect(initial.locator('[data-input-cell="abuf:0"]')).toHaveAttribute('data-value','unknown');
  await page.locator('.layer-rail [data-layer]').last().click();
  const last=page.locator('[data-mesh-node="5|0,0"]');
  await expect(last.locator('[data-input-cell="A:0"]')).toHaveAttribute('data-value','1');
  await expect(last.locator('[data-input-cell="abuf:0"]')).toHaveAttribute('data-value','3');
  await expect(last.locator('[data-input-cell="bbuf:0"]')).toHaveAttribute('data-value','2');
  await page.locator('.stage-shell').screenshot({path:'../results/gemv-walkthrough/layer-inputs-gemm.png'});
  await last.locator('[data-input-cell="abuf:0"]').focus();await page.keyboard.press('Enter');
  await expect(page.locator('.stage-inputs h2')).toContainText('PE (0,0)');
  await page.setViewportSize({width:390,height:844});
  expect(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1)).toBeTruthy();
  expect(await page.locator('.layer-scroll').evaluate(el=>el.scrollWidth>el.clientWidth)).toBeTruthy();
  expect(errors).toEqual([]);
});
