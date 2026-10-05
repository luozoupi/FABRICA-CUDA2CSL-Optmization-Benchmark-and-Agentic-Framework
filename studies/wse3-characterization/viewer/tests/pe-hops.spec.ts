import {test,expect} from '@playwright/test';
import {resolve} from 'node:path';

test('every PE message and numeric word has an offline observable timeline',async({page})=>{
  const errors:string[]=[],network:string[]=[];
  page.on('pageerror',e=>errors.push(e.message));
  page.on('request',r=>{if(/^https?:/.test(r.url()))network.push(r.url());});
  await page.goto('file://'+resolve('../results/pe-hops/hops.html'));
  await expect(page.getByRole('heading',{name:'Follow the number across the mesh.'})).toBeVisible();
  await expect(page.locator('#stats')).toContainText('184');
  await expect(page.locator('#word')).toContainText('0x41300000');
  await expect(page.locator('#clock')).toHaveText('10857');
  await expect(page.locator('#mesh')).toContainText('at router; buffer unknown');
  await page.getByRole('button',{name:'Send S6',exact:false}).click();
  await expect(page.locator('#mesh')).toContainText('not yet observed here');
  await expect(page.locator('#equation')).toHaveText('Arithmetic use not yet observed');
  await page.getByRole('button',{name:'Arithmetic use',exact:false}).click();
  await expect(page.locator('#equation')).toHaveText('30 + 11 = 41');
  await page.screenshot({path:'../results/pe-hops/hops-desktop.png',fullPage:true});
  let words=0,messages=0;
  for(let s=0;s<4;s++){
    await page.locator('#scene').selectOption(String(s));
    const count=await page.locator('#message option').count();
    for(let m=0;m<count;m++){
      await page.locator('#message').selectOption(String(m));messages++;
      const n=await page.locator('[data-slot]').count();
      for(let w=0;w<n;w++){
        await page.locator(`[data-slot="${w}"]`).click();words++;
        await expect(page.locator('#route-note')).toContainText('ident');
        expect(await page.locator('#message-table tbody tr').count()).toBe(n);
      }
    }
  }
  expect(messages).toBe(24);expect(words).toBe(184);
  await page.setViewportSize({width:390,height:844});
  expect(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1)).toBeTruthy();
  await page.screenshot({path:'../results/pe-hops/hops-mobile.png',fullPage:true});
  const download=page.waitForEvent('download');await page.locator('#export').click();
  expect((await download).suggestedFilename()).toBe('pe-hop-evidence.json');
  expect(errors).toEqual([]);expect(network).toEqual([]);
});
