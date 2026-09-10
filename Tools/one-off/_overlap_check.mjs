// 一次性排查脚本：检查手机端筛选区是否存在"元素穿出/压叠"。
// 判定：同一筛选容器内任意两个可见元素（input/button/标签）的矩形相交面积 > 1px² 即视为压叠。
// 同时断言：日期输入框宽度 >= 其固有宽度（不裁文本）、文档无横向溢出。
//
// 前置：本地起站（Tools/dev/start.ps1）后，用仓库自带的 Playwright Chromium 开一个调试端口：
//   "C:/Users/<用户>/AppData/Local/ms-playwright/chromium-1187/chrome-win/chrome.exe" \
//       --headless=new --no-sandbox --disable-gpu --remote-debugging-port=9333 \
//       --user-data-dir=<临时目录> about:blank
// 用法: node Tools/one-off/_overlap_check.mjs <baseUrl> <page...> [--widths 320,360,390]
// 例：  node Tools/one-off/_overlap_check.mjs http://localhost:8123 AgentFlow Records GameRecord PrizeHistory

const args = process.argv.slice(2);
const baseUrl = args.shift();
const widthIdx = args.indexOf('--widths');
const widths = (widthIdx >= 0 ? args[widthIdx + 1] : '280,320,360,375,390,414,591')
  .split(',').map(Number);
const pages = widthIdx >= 0 ? args.slice(0, widthIdx) : args;

const version = await (await fetch('http://127.0.0.1:9333/json/version')).json();
const ws = new WebSocket(version.webSocketDebuggerUrl);
let nextId = 1;
const pending = new Map();
ws.addEventListener('message', (ev) => {
  const m = JSON.parse(ev.data);
  if (m.id && pending.has(m.id)) {
    const p = pending.get(m.id); pending.delete(m.id);
    m.error ? p.reject(new Error(JSON.stringify(m.error))) : p.resolve(m.result);
  }
});
await new Promise((r) => ws.addEventListener('open', r, { once: true }));
function send(method, params = {}, sessionId) {
  const id = nextId++; const pl = { id, method, params };
  if (sessionId) pl.sessionId = sessionId;
  ws.send(JSON.stringify(pl));
  return new Promise((resolve, reject) => pending.set(id, { resolve, reject }));
}
const { targetId } = await send('Target.createTarget', { url: 'about:blank' });
const { sessionId } = await send('Target.attachToTarget', { targetId, flatten: true });
await send('Page.enable', {}, sessionId);
await send('Runtime.enable', {}, sessionId);
await send('Network.enable', {}, sessionId);
const UA = 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';
async function setWidth(w) {
  await send('Network.setUserAgentOverride', { userAgent: UA }, sessionId);
  await send('Emulation.setDeviceMetricsOverride', { width: w, height: 844, deviceScaleFactor: 2, mobile: true }, sessionId);
}
async function evaluate(expression) {
  const r = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true }, sessionId);
  if (r.exceptionDetails) throw new Error(JSON.stringify(r.exceptionDetails));
  return r.result.value;
}
async function goto(url) {
  await send('Page.navigate', { url }, sessionId);
  for (let i = 0; i < 100; i++) { await new Promise((r) => setTimeout(r, 100)); if ((await evaluate('document.readyState')) === 'complete') return; }
}

await setWidth(390);
await goto(`${baseUrl}/Login/Mobile`);
await evaluate(`(async () => {
  const tok = document.querySelector('input[name="__RequestVerificationToken"]');
  const b = new URLSearchParams();
  b.append('uname','atmadmin'); b.append('upwd','123456');
  b.append('__RequestVerificationToken', tok ? tok.value : '');
  return await (await fetch('/Login/Mobile', { method:'POST',
    headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, body:b.toString() })).text();
})()`);

const CHECK = `(() => {
  const out = { url: location.pathname, overlaps: [], tooNarrow: [], docScrollW: document.documentElement.scrollWidth, seps: [] };
  const vis = (el) => { const b = el.getBoundingClientRect(); const cs = getComputedStyle(el);
    return b.width > 0 && b.height > 0 && cs.visibility !== 'hidden' && cs.display !== 'none' && cs.opacity !== '0'; };
  const box = (el) => el.getBoundingClientRect();
  const inter = (a, b) => Math.max(0, Math.min(a.right,b.right) - Math.max(a.left,b.left)) *
                         Math.max(0, Math.min(a.bottom,b.bottom) - Math.max(a.top,b.top));

  // 参照物：本页实测的 date 固有宽度
  const refHost = document.createElement('div');
  refHost.style.cssText = 'position:absolute;left:-9999px;top:0;white-space:nowrap;';
  document.body.appendChild(refHost);

  const scope = document.querySelectorAll('.filter-container,.history-filter,.m-date-field,.m-date-range,.filter-bottom-row,.filter-actions');
  for (const root of scope) {
    const items = [...root.querySelectorAll('input,button,.filter-label,.m-date-label,.m-date-range-sep,.record-summary,.stats-item')]
      .filter(vis);
    for (const el of items) {
      const b = box(el);
      if (el.tagName === 'INPUT' && (el.type === 'date' || el.type === 'datetime-local')) {
        const cs = getComputedStyle(el);
        const ref = document.createElement('input');
        ref.type = el.type; ref.value = el.value || '2026-09-10';
        ref.style.cssText = 'height:40px;padding:0 ' + parseFloat(cs.paddingLeft) + 'px;border:1px solid #ccc;box-sizing:border-box;font-size:' + cs.fontSize + ';font-family:' + cs.fontFamily + ';';
        refHost.appendChild(ref);
        const need = ref.getBoundingClientRect().width;
        ref.remove();
        if (b.width + 0.5 < need) out.tooNarrow.push({ id: el.id, w: +b.width.toFixed(1), need: +need.toFixed(1) });
      }
      if (el.classList.contains('m-date-range-sep')) out.seps.push({ display: getComputedStyle(el).display, x: +b.x.toFixed(1), y: +b.y.toFixed(1) });
    }
    for (let i = 0; i < items.length; i++) for (let k = i + 1; k < items.length; k++) {
      if (items[i].contains(items[k]) || items[k].contains(items[i])) continue;
      const a = box(items[i]), c = box(items[k]);
      const area = inter(a, c);
      if (area > 1) out.overlaps.push({
        a: items[i].id || items[i].className, b: items[k].id || items[k].className,
        area: +area.toFixed(1),
        aBox: { x:+a.x.toFixed(1), y:+a.y.toFixed(1), w:+a.width.toFixed(1), h:+a.height.toFixed(1) },
        bBox: { x:+c.x.toFixed(1), y:+c.y.toFixed(1), w:+c.width.toFixed(1), h:+c.height.toFixed(1) },
      });
    }
  }
  refHost.remove();
  return out;
})()`;

const results = [];
for (const w of widths) {
  await setWidth(w);
  for (const pg of pages) {
    await goto(`${baseUrl}/Mobile/Home/${pg}`);
    results.push({ width: w, page: pg, ...(await evaluate(CHECK)) });
  }
}
console.log(JSON.stringify(results, null, 1));
await send('Target.closeTarget', { targetId });
ws.close();
