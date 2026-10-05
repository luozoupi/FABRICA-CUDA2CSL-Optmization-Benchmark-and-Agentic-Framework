import {test,expect} from '@playwright/test';
import {resolve} from 'node:path';
import {readFileSync} from 'node:fs';
import {stateAt} from '../src/time-model';

const timeBundle=JSON.parse(readFileSync(resolve('public/time-bundle.json'),'utf8'));

test('MeshGEMV links local sums, ownership, and the separate reduction',async({page})=>{
  const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto('/gemv/gemv.html');
  await expect(page.getByRole('heading',{name:'Local sums become a shared result.'})).toBeVisible();
  await expect(page.locator('.worksheet .result-value')).toHaveText('1');
  await page.getByRole('button',{name:'Next contribution',exact:true}).click();
  await expect(page.locator('.worksheet .result-value')).toHaveText('11');
  await page.getByRole('button',{name:'Next contribution',exact:true}).click();
  await expect(page.locator('.worksheet .result-value')).toHaveText('-9');
  await expect(page.locator('.owner-callout')).toContainText('PE (0,1)');
  await expect(page.locator('.reduction-equation')).toContainText('30 + 11 = 41');
  await page.getByRole('button',{name:'Final reduction',exact:true}).click();
  await expect(page.locator('.execution')).toContainText('fadds');
  await page.getByRole('tab',{name:'Timeline',exact:true}).click();
  await expect(page.getByRole('img',{name:'Observed MeshGEMV instruction timeline'})).toBeVisible();
  await page.getByRole('tab',{name:'LLVM IR',exact:true}).click();
  await expect(page.locator('.source-code')).toContainText('@combine');
  await page.reload();await expect(page.locator('.worksheet .result-value')).toHaveText('-9');
  await page.locator('[data-scene="v2"]').click();
  await expect(page.locator('.execution')).toContainText('64/64 products mapped');
  await expect(page.getByRole('button',{name:'Y[0] = 158',exact:true})).toBeVisible();
  expect(errors).toEqual([]);
});

test('time slices retain unknowns until events and reproduce every final state',async({page})=>{
  const v=timeBundle.scenes.find((s:any)=>s.id==='v1');
  expect(Object.values(stateAt(v,v.start)).every(s=>s.partial.every(x=>x===null))).toBeTruthy();
  for(const scene of timeBundle.scenes){
    const final=stateAt(scene,scene.end);
    for(const pe of scene.pes)expect(scene.kind==='gemv'?final[pe.id].result:final[pe.id].partial).toEqual(pe.final_readback);
  }
  const firstReduce=v.events.find((e:any)=>e.kind==='reduce');
  expect(stateAt(v,firstReduce.cycle-1)[firstReduce.pe].result[firstReduce.index]).toBeNull();
  expect(stateAt(v,firstReduce.cycle)[firstReduce.pe].result[firstReduce.index]).toBe(firstReduce.value);
  await page.goto('/time-slices/time-slices.html');
  await expect(page.getByRole('heading',{name:'Watch the values change.'})).toBeVisible();
  await page.getByRole('button',{name:'Last frame',exact:true}).click();
  await expect(page.locator('article[data-pe="0,0"]')).toContainText('41');
  await page.getByRole('button',{name:'First frame',exact:true}).click();
  await expect(page.locator('article[data-pe="0,0"]')).toContainText('not yet observed');
  await page.locator('#advance').selectOption('fixed');await page.getByRole('spinbutton',{name:'Slice width',exact:true}).fill('50');await page.getByRole('spinbutton',{name:'Slice width',exact:true}).press('Tab');
  await page.getByRole('button',{name:'Next frame',exact:true}).click();
  await expect(page.locator('.time-count')).toHaveText((v.start+50).toLocaleString('en-US'));
  const download=page.waitForEvent('download');await page.getByRole('button',{name:'Export current frame JSON'}).click();expect((await download).suggestedFilename()).toContain('cycle-');
  await page.reload();await expect(page.locator('.time-count')).toHaveText((v.start+50).toLocaleString('en-US'));
  await page.locator('[data-scene="g1"]').click();await page.getByRole('button',{name:'Last frame',exact:true}).click();
  await expect(page.locator('article[data-pe="0,0"]')).toContainText('11');
});

test('both new standalone pages work offline on desktop and mobile',async({page})=>{
  const errors:string[]=[],network:string[]=[];page.on('pageerror',e=>errors.push(e.message));page.on('request',r=>{if(/^https?:/.test(r.url()))network.push(r.url());});
  for(const name of ['gemv','time-slices']){
    await page.setViewportSize({width:1440,height:1100});
    await page.goto('file://'+resolve('../results/gemv-walkthrough/'+name+'.html'));
    await expect(page.locator('h1')).not.toContainText('Could not');
    if(name==='time-slices'){
      const v=timeBundle.scenes.find((s:any)=>s.id==='v1'),e=v.events.find((e:any)=>e.kind==='reduce');
      await page.getByRole('spinbutton',{name:'Go to cycle',exact:true}).fill(String(e.cycle));await page.getByRole('button',{name:'Go',exact:true}).click();
    }
    await page.screenshot({path:'../results/gemv-walkthrough/'+name+'-desktop.png',fullPage:true});
    await page.setViewportSize({width:390,height:844});await page.locator('[data-scene="v2"]').click();
    expect(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1)).toBeTruthy();
    await page.screenshot({path:'../results/gemv-walkthrough/'+name+'-mobile.png',fullPage:true});
  }
  expect(errors).toEqual([]);expect(network).toEqual([]);
});
