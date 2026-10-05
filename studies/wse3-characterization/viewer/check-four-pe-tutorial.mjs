import {chromium} from 'playwright';
import {pathToFileURL} from 'node:url';
import path from 'node:path';
import fs from 'node:fs/promises';
import assert from 'node:assert/strict';

const root=path.resolve('../results/four-pe-tutorial');
const browser=await chromium.launch({headless:true,args:['--no-sandbox']});
const page=await browser.newPage({viewport:{width:1440,height:1050},deviceScaleFactor:1});
const errors=[],network=[];
page.on('pageerror',e=>errors.push(e.message));
page.on('request',r=>{if(r.url().startsWith('http'))network.push(r.url());});
try{
 await page.goto(pathToFileURL(path.join(root,'tutorial.html')).href);
 assert.equal(await page.locator('figure svg').count(),6);
 assert.equal(await page.locator('h2').count(),9);
 assert.equal(await page.locator('img').count(),0,'All diagrams must be embedded for offline reading');
 assert.equal(await page.locator('table').count(),3);
 const transfers=JSON.parse(await fs.readFile(path.join(root,'transfers.json'),'utf8'));
 assert.equal(transfers.length,8);
 const body=await page.locator('body').textContent();
 for(const t of transfers)assert.ok(body.includes(`[${t.values.join(', ')}]`));
 assert.ok(body.includes('all X data uses color 0'));
 assert.ok(body.includes('all W data uses color 4'));
 await page.screenshot({path:path.join(root,'tutorial-desktop.png')});
 await page.pdf({path:path.join(root,'tutorial.pdf'),preferCSSPageSize:true,printBackground:true});
 await page.setViewportSize({width:390,height:844});
 assert.ok(await page.evaluate(()=>document.documentElement.scrollWidth<=391));
 await page.screenshot({path:path.join(root,'tutorial-mobile.png')});
 await page.setViewportSize({width:1380,height:1100});
 const files=(await fs.readdir(root)).filter(n=>n.endsWith('.svg')).sort();
 const overflow=[];
 for(const name of files){
  await page.goto(pathToFileURL(path.join(root,name)).href);
  const dimensions=await page.evaluate(()=>{const v=document.querySelector('svg').viewBox.baseVal;return {width:v.width,height:v.height};});
  await page.setViewportSize(dimensions);
  const bad=await page.evaluate(()=>{const svg=document.querySelector('svg'),v=svg.viewBox.baseVal;return [...svg.querySelectorAll('text')].flatMap(t=>{const b=t.getBBox();return b.x<0||b.y<0||b.x+b.width>v.width||b.y+b.height>v.height?[t.textContent]:[];});});
  overflow.push(...bad.map(text=>({figure:name,text})));
  const overlapping=await page.evaluate(()=>{const ts=[...document.querySelectorAll('svg text')];const out=[];for(let i=0;i<ts.length;i++)for(let j=i+1;j<ts.length;j++){const a=ts[i].getBBox(),b=ts[j].getBBox();if(Math.min(a.x+a.width,b.x+b.width)-Math.max(a.x,b.x)>1&&Math.min(a.y+a.height,b.y+b.height)-Math.max(a.y,b.y)>1)out.push([ts[i].textContent,ts[j].textContent]);}return out;});
  assert.deepEqual(overlapping,[],name+' labels must not overlap');
  await page.locator('svg').screenshot({path:path.join(root,name.replace('.svg','.png'))});
 }
 assert.deepEqual(overflow,[],'Figure text must stay within the drawing');
 assert.deepEqual(errors,[]);assert.deepEqual(network,[]);
 const result={passed:true,offline:true,svg_figures:6,sections:9,tables:3,mobile_overflow:false,figure_text_overflow:overflow,browser_errors:errors};
 await fs.writeFile(path.join(root,'browser-check.json'),JSON.stringify(result,null,2)+'\n');
 console.log(JSON.stringify(result));
}finally{await browser.close();}
