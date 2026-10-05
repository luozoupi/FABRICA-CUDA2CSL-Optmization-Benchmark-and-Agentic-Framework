import {test,expect} from '@playwright/test';
import {resolve} from 'node:path';

test('linked math, PE ownership, trace inspection, and navigation',async({page})=>{
  const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto('/');
  await expect(page.getByRole('heading',{name:'One PE. Every number.'})).toBeVisible();
  await expect(page.locator('.worksheet .result-value')).toHaveText('1');
  await page.getByRole('button',{name:'Next product',exact:true}).click();
  await page.getByRole('button',{name:'Next product',exact:true}).click();
  await expect(page.locator('.worksheet .result-value')).toHaveText('7');
  await expect(page.locator('.execution')).toContainText('64/64 terms mapped');
  await page.locator('[data-scene="g1"]').click();
  await page.getByRole('button',{name:'C[2,2] = 58',exact:true}).click();
  await expect(page.locator('.owner-callout')).toContainText('PE (1,1)');
  await expect(page.locator('.worksheet .result-value')).toHaveText('27');
  await page.getByRole('button',{name:'Next product',exact:true}).click();
  await expect(page.locator('.worksheet .result-value')).toHaveText('47');
  await page.getByRole('tab',{name:'Timeline',exact:true}).click();
  await expect(page.getByRole('img',{name:'Observed instruction dispatch and execute cycles'})).toBeVisible();
  await page.getByRole('tab',{name:'LLVM IR',exact:true}).click();
  await expect(page.locator('.execution pre')).toContainText('@gemm');
  await page.reload();
  await expect(page.locator('.owner-callout')).toContainText('PE (1,1)');
  await expect(page.locator('.worksheet .result-value')).toHaveText('47');
  await page.locator('[data-scene="g2"]').click();
  await expect(page.locator('.execution')).toContainText('512/512 terms mapped');
  await expect(page.locator('[data-matrix="C"]')).toHaveCount(64);
  expect(errors).toEqual([]);
});

test('portable HTML opens offline and fits desktop and mobile',async({page})=>{
  const errors:string[]=[];const network:string[]=[];
  page.on('pageerror',e=>errors.push(e.message));
  page.on('request',r=>{if(/^https?:/.test(r.url()))network.push(r.url());});
  await page.goto('file://'+resolve('../results/gemm-walkthrough/gemm.html'));
  await expect(page.getByRole('heading',{name:'One PE. Every number.'})).toBeVisible();
  await page.screenshot({path:'../results/gemm-walkthrough/viewer-desktop.png',fullPage:true});
  await page.setViewportSize({width:390,height:844});
  await page.locator('[data-scene="g2"]').click();
  await expect(page.getByRole('heading',{name:'Bigger tiles. Same idea.'})).toBeVisible();
  const overflow=await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth+1);
  expect(overflow).toBe(false);
  await page.screenshot({path:'../results/gemm-walkthrough/viewer-mobile.png',fullPage:true});
  expect(network).toEqual([]);expect(errors).toEqual([]);
});
