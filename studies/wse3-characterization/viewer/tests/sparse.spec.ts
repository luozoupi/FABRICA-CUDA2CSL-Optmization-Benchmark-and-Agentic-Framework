import {test,expect} from '@playwright/test';
import {resolve} from 'node:path';

test('sparse walkthrough separates recorded cycles from reconstructed index steps',async({page})=>{
  const errors:string[]=[],network:string[]=[];
  page.on('pageerror',e=>errors.push(e.message));
  page.on('request',r=>{if(/^https?:/.test(r.url()))network.push(r.url());});
  await page.goto('file://'+resolve('../results/sparse-walkthrough/sparse.html'));
  await expect(page.getByRole('heading',{name:'Follow the nonzeros.'})).toBeVisible();
  expect(await page.locator('#scene option').count()).toBe(6);
  for(let s=0;s<4;s++){
    await page.locator('#scene').selectOption(String(s));
    for(let r=0;r<16;r++){
      await page.locator('#row').selectOption(String(r));
      await page.locator('[data-snapshot]').last().click();
      await expect(page.locator('#badge')).toContainText('Recorded simulator');
      expect(await page.locator('.proof').count()).toBe(2);
      await expect(page.locator('#current')).toContainText('selected output finished');
    }
  }
  await page.locator('#scene').selectOption('0');
  await page.getByRole('button',{name:'Next step',exact:true}).click();
  await expect(page.locator('#equation')).toHaveText('0 + 0.25 × 0.5 = 0.125');
  await expect(page.locator('#proof')).toContainText('13657');
  await page.screenshot({path:'../results/sparse-walkthrough/spmv-desktop.png',fullPage:true});
  await page.locator('#scene').selectOption('4');
  for(const r of [0,127,128,233])for(const c of [0,7,8,15]){
    await page.locator('#row').selectOption(String(r));await page.locator('#col').selectOption(String(c));
    await page.locator('[data-snapshot]').last().click();
    await expect(page.locator('#output')).toContainText(`PE (${Math.floor(c/8)},${Math.floor(r/128)})`);
    await expect(page.locator('#badge')).toContainText('Source reconstruction');
    await expect(page.locator('#verification')).toContainText('not available per element');
    expect(await page.locator('.proof').count()).toBe(0);
  }
  await page.screenshot({path:'../results/sparse-walkthrough/spmm-desktop.png',fullPage:true});
  await page.locator('#scene').selectOption('5');
  const target=await page.locator('#sparse-data').evaluate(el=>{
    const s=JSON.parse(el.textContent!).scenes[5];
    const o=s.outputs.find((o:any)=>o.steps.some((t:any)=>!t.match)&&o.steps.some((t:any)=>t.match));
    return {r:o.r,c:o.c};
  });
  await page.locator('#row').selectOption(String(target.r));await page.locator('#col').selectOption(String(target.c));
  await page.locator('[data-snapshot]').last().click();
  await expect(page.locator('#step-table')).toContainText('advance');
  await expect(page.locator('#current')).toContainText('structural match exists');
  await expect(page.locator('#storage-title')).toHaveText('Two CSC lists, one intersection.');
  await page.screenshot({path:'../results/sparse-walkthrough/spgemm-desktop.png',fullPage:true});
  await page.setViewportSize({width:390,height:844});
  expect(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1)).toBeTruthy();
  await page.screenshot({path:'../results/sparse-walkthrough/sparse-mobile.png',fullPage:true});
  const download=page.waitForEvent('download');await page.locator('#export').click();
  expect((await download).suggestedFilename()).toBe('sparse-evidence.json');
  expect(errors).toEqual([]);expect(network).toEqual([]);
});
