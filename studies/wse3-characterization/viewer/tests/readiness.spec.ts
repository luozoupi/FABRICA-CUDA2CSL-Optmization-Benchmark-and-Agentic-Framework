import {test,expect} from '@playwright/test';
import {resolve} from 'node:path';
import {readFileSync} from 'node:fs';

const root=resolve('../results/readiness');

test('readiness experiment exposes every verified word at its observed time',async({page})=>{
  test.setTimeout(180000);
  const errors:string[]=[],network:string[]=[];
  page.on('pageerror',e=>errors.push(e.message));
  page.on('request',r=>{if(/^https?:/.test(r.url()))network.push(r.url());});
  const data=JSON.parse(readFileSync(root+'/readiness.json','utf8'));
  expect(data.cases.length).toBe(19);
  expect(data.repeats).toHaveLength(4);
  expect(data.repeats.every((r:any)=>r.timing_and_values_identical)).toBeTruthy();
  await page.goto('file://'+root+'/readiness.html');
  await expect(page.getByRole('heading',{name:'When the receiver waits.'})).toBeVisible();
  await expect(page.locator('#stats')).toContainText('172');
  await expect(page.locator('#layers [data-layer]')).toHaveCount(5);
  const stage=await page.locator('.stage').boundingBox(),inputs=await page.locator('aside').boundingBox();
  expect(inputs!.x).toBeGreaterThan(stage!.x+stage!.width-1);
  let checked=0;
  for(let i=0;i<data.cases.length;i++){
    const c=data.cases[i];await page.locator('#case').selectOption(String(i));
    for(const t of c.terms){
      await page.locator('#word-select').selectOption(String(t.slot));
      await expect(page.locator('#bit-pattern')).toContainText('0x'+t.bits.toString(16));
      await page.locator('#rail [data-event="0"]').click();
      await expect(page.locator('#received .selected b')).toHaveText('?');
      await expect(page.locator('#outputs .selected b')).toHaveText('?');
      await page.locator('#rail [data-event="3"]').click();
      await expect(page.locator('#received .selected b')).not.toHaveText('?');
      await page.locator('#rail [data-event="4"]').click();
      await expect(page.locator('#outputs .selected b')).not.toHaveText('?');
      await expect(page.locator('#equation')).toContainText(' = ');
      checked++;
    }
  }
  expect(checked).toBe(172);
  const late=data.cases.findIndex((c:any)=>c.words===16&&c.receiver_nops===256);
  await page.locator('#case').selectOption(String(late));
  await page.locator('#word-select').selectOption('8');
  await page.screenshot({path:root+'/readiness-desktop.png',fullPage:true});
  await page.locator('#layers [data-layer="4"]').focus();await page.keyboard.press('Enter');
  await expect(page.locator('#equation')).toContainText(' = ');
  const download=page.waitForEvent('download');await page.locator('#export').click();
  expect((await download).suggestedFilename()).toBe('readiness-evidence.json');
  await page.setViewportSize({width:390,height:844});
  expect(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth+1)).toBeTruthy();
  await page.screenshot({path:root+'/readiness-mobile.png',fullPage:true});
  expect(errors).toEqual([]);expect(network).toEqual([]);
});
