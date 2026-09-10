// 一次性排查脚本：真实点击"筛选/查询"按钮，验证改造后按钮仍能触发请求且控件可交互。
// 通过监听 Network.requestWillBeSent 抓取点击后发出的 XHR。
// 需要预设账号的页面（AgentFlow/GameRecord/PrizeHistory）会自动带上 ?id=，否则页面会弹"缺少参数"。
//
// 前置：同 _overlap_check.mjs（本地起站 + Playwright Chromium 开 --remote-debugging-port=9333）。
// 用法: node Tools/one-off/_click_check.mjs <baseUrl> <page> [width]

const [baseUrl, pageName, widthArg] = process.argv.slice(2);
const width = Number(widthArg || 390);

const version = await (await fetch('http://127.0.0.1:9333/json/version')).json();
const ws = new WebSocket(version.webSocketDebuggerUrl);
let nextId = 1;
const pending = new Map();
const requests = [];
ws.addEventListener('message', (ev) => {
  const m = JSON.parse(ev.data);
  if (m.id && pending.has(m.id)) {
    const p = pending.get(m.id); pending.delete(m.id);
    m.error ? p.reject(new Error(JSON.stringify(m.error))) : p.resolve(m.result);
  } else if (m.method === 'Network.requestWillBeSent') {
    requests.push({ url: m.params.request.url, method: m.params.request.method });
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
await send('Network.setUserAgentOverride', {
  userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
}, sessionId);
await send('Emulation.setDeviceMetricsOverride', { width, height: 844, deviceScaleFactor: 2, mobile: true }, sessionId);

async function evaluate(expression) {
  const r = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true }, sessionId);
  if (r.exceptionDetails) throw new Error(JSON.stringify(r.exceptionDetails));
  return r.result.value;
}
async function goto(url) {
  await send('Page.navigate', { url }, sessionId);
  for (let i = 0; i < 120; i++) { await new Promise((r) => setTimeout(r, 100)); if ((await evaluate('document.readyState')) === 'complete') return; }
}

await goto(`${baseUrl}/Login/Mobile`);
await evaluate(`(async () => {
  const tok = document.querySelector('input[name="__RequestVerificationToken"]');
  const b = new URLSearchParams();
  b.append('uname','atmadmin'); b.append('upwd','123456');
  b.append('__RequestVerificationToken', tok ? tok.value : '');
  return await (await fetch('/Login/Mobile', { method:'POST',
    headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}, body:b.toString() })).text();
})()`);

await goto(baseUrl + "/Mobile/Home/" + pageName + (pageName === "GameRecord" ? "?id=95000002" : pageName === "PrizeHistory" ? "?id=95000002" : pageName === "AgentFlow" ? "?id=10010" : ""));
await new Promise((r) => setTimeout(r, 2500));

// 记录点击前的页面初始请求，之后只看新增
const before = requests.length;
const clicked = await evaluate(`(() => {
  const btn = document.getElementById('filterBtn') || document.getElementById('historyQueryBtn');
  if (!btn) return 'no-button';
  // 确认按钮中心点没有被其它元素遮挡（命中测试）
  const b = btn.getBoundingClientRect();
  const hit = document.elementFromPoint(b.left + b.width / 2, b.top + b.height / 2);
  const covered = !(btn === hit || btn.contains(hit));
  // 确认日期控件可聚焦可改值
  const d = document.querySelector('input[type="date"]');
  let dateOk = false;
  if (d) { d.focus(); d.value = '2026-09-09';
    dateOk = document.activeElement === d && d.value === '2026-09-09'; }
  btn.click();
  return { hitTarget: hit ? (hit.id || hit.tagName + '.' + hit.className) : null, covered, dateOk,
    btnBox: { x: +b.x.toFixed(1), y: +b.y.toFixed(1), w: +b.width.toFixed(1), h: +b.height.toFixed(1) } };
})()`);
await new Promise((r) => setTimeout(r, 2500));
const after = requests.slice(before).filter((r) => !/\.(css|js|png|jpg|ico|woff2?)(\?|$)/i.test(r.url));

console.log(JSON.stringify({ page: pageName, width, click: clicked,
  xhr: after.map((r) => r.method + ' ' + r.url.replace(baseUrl, '')) }, null, 1));
await send('Target.closeTarget', { targetId });
ws.close();
