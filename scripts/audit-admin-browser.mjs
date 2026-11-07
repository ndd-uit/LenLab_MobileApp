// Read-only local UI audit. Starts a hidden Edge profile; no production service.
import {createServer} from 'node:http';
import {readFile, mkdir, writeFile, stat} from 'node:fs/promises';
import {resolve, extname, sep} from 'node:path';
import {spawn} from 'node:child_process';
const root = resolve(import.meta.dirname, '..');
const build = resolve(root, 'apps/admin/build/web');
const output = resolve(root, '.design/ui-audit', process.argv[2] ?? 'after');
await mkdir(output, {recursive:true});
const profile = resolve(output, 'edge-profile');
await mkdir(profile, {recursive:true});
const mime = {'.html':'text/html','.js':'text/javascript','.json':'application/json','.wasm':'application/wasm','.svg':'image/svg+xml','.png':'image/png','.ttf':'font/ttf'};
const server = createServer(async (req,res) => {
  try {
    const file = resolve(build, '.' + decodeURIComponent(new URL(req.url,'http://localhost').pathname));
    if (!(file === build || file.startsWith(build+sep))) {res.writeHead(403).end();return;}
    const target = (await stat(file)).isDirectory() ? resolve(file,'index.html') : file;
    res.writeHead(200, {'Content-Type':mime[extname(target)] ?? 'application/octet-stream','Cache-Control':'no-store'});
    res.end(await readFile(target));
  } catch {res.writeHead(404).end();}
});
await new Promise(r=>server.listen(0,'127.0.0.1',r));
const url = `http://127.0.0.1:${server.address().port}`;
const edge=spawn('C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe',[
  '--headless=new','--no-first-run','--no-default-browser-check','--remote-debugging-port=0',
  '--remote-allow-origins=*',`--user-data-dir=${profile}`,'about:blank',
],{windowsHide:true,stdio:'ignore'});
let ws;
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
let sequence=0;
const pending=new Map();
const errors=[];
const authSource=await readFile(resolve(root,'apps/admin/lib/features/auth/data/admin_auth_source.dart'),'utf8');
const demoEmail=authSource.match(/demoEmail\s*=\s*'([^']+)'/)[1];
const demoPassword=authSource.match(/demoPassword\s*=\s*'([^']+)'/)[1];
async function call(method,params={}) {
  const id=++sequence;
  return new Promise((resolve,reject)=>{
    const timer=setTimeout(()=>{pending.delete(id);reject(new Error(`CDP timeout ${method}`));},15000);
    pending.set(id,{resolve:r=>{clearTimeout(timer);resolve(r);},reject:e=>{clearTimeout(timer);reject(e);}});
    ws.send(JSON.stringify({id,method,params}));
  });
}
const deepQuery=`function all(sel,root=document){let result=[...root.querySelectorAll(sel)];for(const el of root.querySelectorAll('*'))if(el.shadowRoot)result.push(...all(sel,el.shadowRoot));return result;}`;
async function evaluate(expression) {const r=await call('Runtime.evaluate',{expression,returnByValue:true,awaitPromise:true});if(r.exceptionDetails)throw new Error(r.exceptionDetails.text);return r.result.value;}
async function screenshot(name) {const r=await call('Page.captureScreenshot',{format:'png',captureBeyondViewport:false});await writeFile(resolve(output,name+'.png'),Buffer.from(r.data,'base64'));}
async function button(label,index=0) {
  const tree=await call('Accessibility.getFullAXTree');
  const buttons=tree.nodes.filter(n=>!n.ignored && n.role?.value==='button');
  const exact=buttons.filter(n=>n.name?.value===label);
  const found=(exact.length ? exact : buttons.filter(n=>n.name?.value?.includes(label)))[index];
  if(!found?.backendDOMNodeId)throw new Error(`Button missing: ${label}; buttons: ${tree.nodes.filter(n=>n.role?.value==='button').map(n=>n.name?.value).join(' | ')}`);
  await call('DOM.scrollIntoViewIfNeeded',{backendNodeId:found.backendDOMNodeId});
  const model=await call('DOM.getBoxModel',{backendNodeId:found.backendDOMNodeId});
  const b=model.model.content;const x=(b[0]+b[2])/2,y=(b[1]+b[5])/2;
  await call('Input.dispatchMouseEvent',{type:'mousePressed',x,y,button:'left',clickCount:1});
  await call('Input.dispatchMouseEvent',{type:'mouseReleased',x,y,button:'left',clickCount:1});
  await sleep(650);
}
try {
  let port,tabs;
  for(let i=0;i<100;i++){try{port=Number((await readFile(resolve(profile,'DevToolsActivePort'),'utf8')).split('\n')[0]);if(port){tabs=await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();if(tabs.some(t=>t.type==='page'))break;}}catch{}await sleep(200);}
  if(!tabs?.some(t=>t.type==='page'))throw new Error('Edge DevTools did not start');
  ws=new WebSocket(tabs.find(t=>t.type==='page').webSocketDebuggerUrl);
  await new Promise((r,j)=>{ws.onopen=r;ws.onerror=j;});
  ws.onmessage=e=>{const msg=JSON.parse(e.data);if(msg.id){const p=pending.get(msg.id);pending.delete(msg.id);if(msg.error)p?.reject(new Error(JSON.stringify(msg.error)));else p?.resolve(msg.result);}else if(msg.method==='Runtime.exceptionThrown')errors.push(msg.params.exceptionDetails.text);else if(msg.method==='Runtime.consoleAPICalled'&&msg.params.type==='error')errors.push(msg.params.args.map(a=>a.value??a.description??'').join(' ').slice(0,1000));};
  await call('Page.enable');await call('Runtime.enable');
  await call('Emulation.setDeviceMetricsOverride',{width:1280,height:1024,deviceScaleFactor:1,mobile:false});
  await call('Page.navigate',{url});
  for(let i=0;i<100;i++){if(await evaluate(`(()=>{${deepQuery}const p=all('flt-semantics-placeholder')[0];if(p)p.click();return all('input').length>=2;})()`))break;await sleep(300);}
  await sleep(1000);
  await screenshot('login');
  const inputs=await evaluate(`(()=>{${deepQuery}return all('input').map(e=>({type:e.type,placeholder:e.placeholder,aria:e.getAttribute('aria-label')}));})()`);
  console.log(JSON.stringify({phase:'login-inputs',inputs}));
  const fields=await call('Accessibility.getFullAXTree');
  const textFields=fields.nodes.filter(n=>!n.ignored && n.role?.value==='textbox');
  for(let i=0;i<2;i++){
    const field=textFields[i];if(!field)throw new Error('Login textbox missing');
    const model=await call('DOM.getBoxModel',{backendNodeId:field.backendDOMNodeId});
    const b=model.model.content; const x=(b[0]+b[2])/2,y=(b[1]+b[5])/2;
    await call('Input.dispatchMouseEvent',{type:'mousePressed',x,y,button:'left',clickCount:1});
    await call('Input.dispatchMouseEvent',{type:'mouseReleased',x,y,button:'left',clickCount:1});
    await sleep(100);
    await call('Input.insertText',{text:i===0?demoEmail:demoPassword});
  }
  await button('Đăng nhập ngay');await sleep(1000);
  if(!(await call('Accessibility.getFullAXTree')).nodes.some(n=>n.name?.value==='Sản phẩm')){await screenshot('login-failure');throw new Error('Mock login did not reach admin');}
  await screenshot('dashboard');
  const screens=[['Sản phẩm','products'],['Đánh giá','reviews'],['Đơn hàng','orders'],['Chi tiết','order-detail',1],['Khách hàng','customers'],['Xem chi tiết Nguyễn Văn Huy','customer-detail'],['Hội thoại','conversations'],['Kịch bản Chatbot','chatbot'],['Mã giảm giá','percentage-coupon'],['Số tiền cố định','fixed-coupon'],['Theo %',null],['Cấu hình chung','settings']];
  const completed=['login','dashboard'];
  for(const [label,name,index] of screens){await button(label,index);if(name){await screenshot(name);completed.push(name);}}
  await writeFile(resolve(output,'result.json'),JSON.stringify({viewport:[1280,1024],completed,errors},null,2));
  console.log(JSON.stringify({output,completed,errors}));
} finally {
  if(ws?.readyState===WebSocket.OPEN){try{await call('Browser.close');}catch{}ws.close();}
  edge.kill();server.close();
}
