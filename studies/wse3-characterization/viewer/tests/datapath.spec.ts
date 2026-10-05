import {test,expect} from '@playwright/test';
import {resolve} from 'node:path';

test('datapath comparison preserves values, switches every workload, and works offline',async({page})=>{
  const errors:string[]=[],network:string[]=[];
  page.on('pageerror',e=>errors.push(e.message));
  page.on('request',r=>{if(/^https?:/.test(r.url()))network.push(r.url());});
  await page.goto('file://'+resolve('../results/anatomy/datapath_review.html'));
  await expect(page.getByRole('heading',{name:'Inside the processing element.'})).toBeVisible();
  await expect(page.locator('#values')).toContainText('-3087');
  const options=await page.locator('#scene option').evaluateAll(nodes=>nodes.map(n=>({value:(n as HTMLOptionElement).value,text:n.textContent||''})));
  expect(options.length).toBeGreaterThan(30);
  for(const option of options){
    await page.locator('#scene').selectOption(option.value);
    await expect(page.locator('#title')).toHaveText(option.text);
    expect(await page.locator('#instructions tbody tr').count()).toBeGreaterThan(1);
  }
  const gemm=options.find(o=>o.text==='G0 4×4 GEMM / history')!;
  await page.locator('#scene').selectOption(gemm.value);
  await expect(page.locator('#instruction')).toContainText('fadds');
  await expect(page.locator('#timing')).toContainText('4022');
  await page.getByRole('button',{name:'Previous instruction',exact:true}).click();
  await expect(page.locator('#instruction')).toContainText('ld16rp');
  await expect(page.locator('#timing')).toContainText('4021');
  await page.screenshot({path:'../results/anatomy/datapath-review-desktop.png',fullPage:true});
  const mem=options.find(o=>o.text==='mem: 0 intervening nop(s)')!;
  await page.locator('#scene').selectOption(mem.value);
  await expect(page.locator('#timing')).toContainText('S3 → value: 5 cycles');
  await page.setViewportSize({width:390,height:844});
  expect(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1)).toBeTruthy();
  await page.screenshot({path:'../results/anatomy/datapath-review-mobile.png',fullPage:true});
  const download=page.waitForEvent('download');await page.getByRole('button',{name:'Export reviewed data'}).click();
  expect((await download).suggestedFilename()).toBe('datapath_review.json');
  expect(errors).toEqual([]);expect(network).toEqual([]);
});
