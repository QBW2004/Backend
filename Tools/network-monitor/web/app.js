'use strict';
const $ = (id) => document.getElementById(id);
const state = { seconds: 900, end: null, data: null, timer: null, request: null, generation: 0, disconnected: false };
const format = (value, digits = 1) => value == null ? '—' : Number(value).toLocaleString('en-US', { maximumFractionDigits: digits });
const timeLabel = (ts, full = false) => new Date(ts).toLocaleString('zh-CN', { timeZone: 'Asia/Taipei', hour12: false, ...(full ? {month:'2-digit',day:'2-digit'} : {}), hour:'2-digit', minute:'2-digit', second:'2-digit' });
function element(tag, text, className) { const node = document.createElement(tag); if (text != null) node.textContent = text; if (className) node.className = className; return node; }

function initializeRoutes(data) {
  if ($('route-cards').children.length) return;
  data.routes.forEach(route => {
    const card = element('article', null, 'route-card'); card.dataset.route = route.id; card.id = `card-${route.id}`;
    card.innerHTML = '<div class="route-title"><h3></h3><span class="route-state"></span></div><p class="route-sub"></p><div class="route-current"><div class="rtt"><strong></strong><small>ms</small><label></label></div><div class="loss"><strong></strong><label></label></div></div><div class="mini-stats"><span>平均<b></b></span><span>P95<b></b></span><span>抖动<b></b></span></div><div class="sample-count"></div>';
    card.querySelector('h3').textContent = route.name;
    card.querySelector('.route-sub').textContent = route.method === 'ICMP' ? (route.id === 'source_relay' ? '反向测量 · 源站计时' : 'ICMP Ping · 真实往返') : route.id === 'via_relay' ? 'HTTPS · 经中转完整请求' : 'HTTP · 源站直接对照';
    card.querySelector('.loss label').textContent = route.method === 'ICMP' ? 'ICMP 未回包率' : '请求失败率';
    card.title = route.description + '\n' + route.target;
    $('route-cards').append(card);
    const track = element('div', null, 'loss-track');
    const label = element('div', route.name, 'loss-track-label'); label.append(element('small', route.method === 'ICMP' ? 'ICMP 未回包' : 'HTTP 请求失败'));
    const wrap = element('div', null, 'loss-track-canvas'); const canvas = element('canvas'); canvas.id = `heat-${route.id}`; canvas.setAttribute('aria-label', `${route.name}失败时间分布`); wrap.append(canvas);
    const percent = element('div', '—', 'loss-track-percent'); percent.id = `loss-${route.id}`;
    track.append(label, wrap, percent); $('loss-tracks').append(track);
    canvas.addEventListener('pointermove', event => heatTooltip(event, route.id));
    canvas.addEventListener('pointerleave', hideTooltip);
  });
}

function routeState(route) {
  if (state.disconnected) return ['数据断开', 'unknown'];
  if (state.end !== null) return [route.stats.latest ? '历史窗口' : '无样本', 'unknown'];
  if (route.health.stale) return ['采集未更新', 'unknown'];
  if (route.health.state === 'failed') return ['探测未成功', 'failed'];
  if (route.health.state !== 'ok') return ['采集异常', 'unknown'];
  return ['正常', 'ok'];
}

function render() {
  const data = state.data; if (!data) return;
  initializeRoutes(data);
  $('local-name').textContent = data.hostname;
  $('host-label').textContent = `采集电脑 · ${data.hostname}`;
  $('relay-ip').textContent = data.relay; $('source-ip').textContent = data.source;
  $('interval').firstChild.textContent = data.routes[0].interval;
  $('retention').firstChild.textContent = data.retentionDays;
  data.routes.forEach(route => {
    const card = $(`card-${route.id}`), stats = route.stats, latest = stats.latest;
    const [label, cls] = routeState(route);
    const status = card.querySelector('.route-state'); status.textContent = label; status.className = `route-state ${cls}`;
    card.classList.toggle('dimmed', cls === 'unknown');
    const validLatest = latest?.status === 'ok' && (state.end !== null || (!route.health.stale && route.health.state === 'ok')) && !state.disconnected;
    card.querySelector('.rtt strong').textContent = validLatest ? format(latest.rtt) : '—';
    card.querySelector('.rtt label').textContent = state.end === null ? '本次测量' : '窗口末次测量';
    card.querySelector('.loss strong').textContent = stats.loss == null ? '—' : format(stats.loss) + '%';
    card.querySelectorAll('.mini-stats b').forEach((node, index) => node.textContent = format([stats.avg, stats.p95, stats.jitter][index]));
    card.querySelector('.sample-count').textContent = `${stats.sent} 次有效探测 · ${stats.failed} 次失败 · ${stats.unknown} 次采集缺失`;
    $(`loss-${route.id}`).textContent = stats.loss == null ? '—' : `${format(stats.loss)}%`;
    if (route.method === 'ICMP') $(`${route.id === 'local_relay' ? 'local' : 'source'}-link`).textContent = validLatest ? `${format(latest.rtt)} ms` : label;
  });
  $('window-start').textContent = timeLabel(data.start);
  $('window-end').textContent = timeLabel(data.end);
  $('resolution').textContent = `${data.bucketMs / 1000} 秒 / 格 · 悬停查看`;
  $('view-time').textContent = state.end === null ? '实时窗口' : '已暂停 · ' + timeLabel(state.end);
  $('updated').textContent = `数据更新 ${timeLabel(data.now, true)} · 图表按 ${data.bucketMs / 1000} 秒聚合，CSV 保留原始采样`;
  $('timeout-note').textContent = `北京时间 UTC+8 · Ping 超时 ${data.pingTimeoutMs / 1000}s · HTTP 超时 ${data.httpTimeoutSeconds}s · 本机记录`;
  const connection = $('connection');
  const missing = data.routes.filter(route => route.health.stale || route.health.state === 'unknown').length;
  connection.textContent = state.disconnected ? '数据连接中断' : state.end !== null ? '暂停查看 · 仍在采集' : missing ? `${missing} 条采集待恢复` : '实时采集中';
  connection.className = 'status' + (state.disconnected ? ' error' : state.end !== null || missing ? ' pending' : '');
  renderEvents(data); drawCharts();
}

function renderEvents(data) {
  const root = $('events'); root.replaceChildren();
  $('event-count').textContent = data.events.length ? '最近 ' + data.events.length + ' 条' : '暂无异常';
  if (!data.events.length) {
    const empty = element('div', null, 'event empty'); empty.append(element('strong', '✓'), element('span', '所选窗口内暂无失败或采集错误')); root.append(empty); return;
  }
  for (const event of data.events) {
    const row = element('div', null, 'event'); const route = data.routes.find(r => r.id === event.route);
    row.append(element('time', timeLabel(event.ts)), element('b', route?.name || event.route), element('span', (event.status === 'unknown' ? '采集缺失 · ' : '探测失败 · ') + event.detail)); root.append(row);
  }
}

function canvasContext(id) {
  const canvas = $(id), bounds = canvas.getBoundingClientRect(), ratio = window.devicePixelRatio || 1;
  canvas.width = Math.max(1, Math.round(bounds.width * ratio)); canvas.height = Math.max(1, Math.round(bounds.height * ratio));
  const ctx = canvas.getContext('2d'); ctx.scale(ratio, ratio); return { ctx, width: bounds.width, height: bounds.height };
}

function chart(id, routes) {
  const { ctx, width, height } = canvasContext(id); const pad = { l: 38, r: 12, t: 12, b: 27 };
  const w = width - pad.l - pad.r, h = height - pad.t - pad.b;
  const numbers = routes.flatMap(r => r.points.filter(p => p.max != null).map(p => p.max));
  const maximum = Math.max(10, ...numbers) * 1.12;
  const limit = Math.ceil(maximum / (maximum > 100 ? 50 : 10)) * (maximum > 100 ? 50 : 10);
  const x = t => pad.l + (t - state.data.start) / (state.data.end - state.data.start) * w;
  const y = value => pad.t + h - value / limit * h;
  ctx.font = '10px Segoe UI, sans-serif'; ctx.lineWidth = 1;
  for (let i = 0; i <= 4; i++) {
    const value = limit * i / 4, py = y(value); ctx.strokeStyle = '#edf1f6'; ctx.beginPath(); ctx.moveTo(pad.l, py); ctx.lineTo(width - pad.r, py); ctx.stroke(); ctx.fillStyle = '#9dabbc'; ctx.textAlign = 'right'; ctx.fillText(format(value, 0), pad.l - 8, py + 3);
  }
  for (let i = 0; i <= 3; i++) {
    ctx.textAlign = i === 0 ? 'left' : i === 3 ? 'right' : 'center'; ctx.fillText(timeLabel(state.data.start + (state.data.end - state.data.start) * i / 3), pad.l + w * i / 3, height - 5);
  }
  routes.forEach(route => ['max', 'avg'].forEach(key => {
    ctx.strokeStyle = route.color; ctx.globalAlpha = key === 'max' ? .18 : 1; ctx.lineWidth = key === 'max' ? 1 : 1.8; ctx.lineJoin = 'round'; ctx.beginPath(); let drawing = false;
    route.points.forEach(p => { const value = p[key]; if (value == null) { drawing = false; return; } if (drawing) ctx.lineTo(x(p.ts), y(value)); else ctx.moveTo(x(p.ts), y(value)); drawing = true; }); ctx.stroke();
    if (key === 'avg') route.points.forEach(p => { if (p.avg == null) return; ctx.beginPath(); ctx.arc(x(p.ts), y(p.avg), 1.8, 0, Math.PI * 2); ctx.fillStyle = route.color; ctx.fill(); });
    ctx.globalAlpha = 1;
  }));
  if (!numbers.length) { ctx.fillStyle = '#a4b1c0'; ctx.textAlign = 'center'; ctx.fillText('尚无成功样本，等待真实测量', width / 2, height / 2); }
}

function drawCharts() {
  if (!state.data) return;
  chart('ping-chart', state.data.routes.filter(r => r.method === 'ICMP'));
  chart('http-chart', state.data.routes.filter(r => r.method === 'HTTP'));
  state.data.routes.forEach(route => {
    const { ctx, width, height } = canvasContext(`heat-${route.id}`), size = width / route.points.length;
    route.points.forEach((p, index) => {
      ctx.fillStyle = !p.sent ? '#edf1f6' : p.failed ? `rgba(222, 113, 91, ${.35 + .65 * p.loss / 100})` : '#7ac5b2';
      if (p.unknown) ctx.fillStyle = '#cbd4e0';
      ctx.fillRect(index * size, 3, Math.max(.6, size - .6), height - 6);
    });
  });
}

function showTooltip(event, text) {
  const tip = $('tooltip'); tip.textContent = text; tip.hidden = false;
  tip.style.left = Math.max(8, Math.min(event.clientX + 14, innerWidth - tip.offsetWidth - 10)) + 'px';
  tip.style.top = Math.max(8, Math.min(event.clientY + 14, innerHeight - tip.offsetHeight - 10)) + 'px';
}
function hideTooltip() { $('tooltip').hidden = true; }
function chartTooltip(event, method) {
  if (!state.data) return;
  const bounds = event.currentTarget.getBoundingClientRect(), fraction = Math.max(0, Math.min(1, (event.clientX - bounds.left - 38) / (bounds.width - 50)));
  const timestamp = state.data.start + fraction * (state.data.end - state.data.start);
  const routes = state.data.routes.filter(r => r.method === method);
  const lines = [timeLabel(timestamp, true)];
  routes.forEach(r => { const point = r.points[Math.min(r.points.length - 1, Math.floor((timestamp - state.data.start) / state.data.bucketMs))]; lines.push(`${r.name}：${point.avg == null ? '无成功样本' : format(point.avg) + ' ms · 峰值 ' + format(point.max)}${point.failed ? ' · 失败 ' + point.failed : ''}`); });
  showTooltip(event, lines.join('\n'));
}
function heatTooltip(event, id) {
  if (!state.data) return;
  const route = state.data.routes.find(r => r.id === id), bounds = event.currentTarget.getBoundingClientRect();
  const point = route.points[Math.max(0, Math.min(route.points.length - 1, Math.floor((event.clientX - bounds.left) / bounds.width * route.points.length)))];
  showTooltip(event, `${timeLabel(point.ts, true)}\n${route.name}\n${point.sent} 次探测 · ${point.failed} 次失败 · ${point.unknown} 次采集缺失\n${point.loss == null ? '无有效探测' : (route.method === 'ICMP' ? 'ICMP 未回包率 ' : 'HTTP 请求失败率 ') + format(point.loss) + '%'}`);
}

async function refresh() {
  clearTimeout(state.timer); state.request?.abort();
  const request = new AbortController(), generation = ++state.generation; state.request = request;
  const timeout = setTimeout(() => request.abort('timeout'), 12000);
  try {
    const query = new URLSearchParams({ seconds: state.seconds }); if (state.end !== null) query.set('end', state.end);
    const response = await fetch('/api/snapshot?' + query, { signal: request.signal }); if (!response.ok) throw new Error('HTTP ' + response.status);
    const data = await response.json(); if (generation !== state.generation) return;
    state.data = data; state.disconnected = false; $('network-error').hidden = true; render();
  } catch (error) {
    if (generation !== state.generation || document.hidden || (request.signal.aborted && request.signal.reason !== 'timeout')) return;
    state.disconnected = true; $('network-error').textContent = '本机采集器暂时无法连接。保留上次结果，当前数据不代表实时状态；连接恢复后会自动更新。'; $('network-error').hidden = false;
    $('connection').textContent = '数据连接中断'; $('connection').className = 'status error'; render();
  } finally {
    clearTimeout(timeout);
    if (generation === state.generation && state.end === null && !document.hidden) state.timer = setTimeout(refresh, state.seconds > 3600 ? 10000 : 2000);
  }
}

document.querySelectorAll('[data-seconds]').forEach(button => button.addEventListener('click', () => {
  state.seconds = Number(button.dataset.seconds);
  document.querySelectorAll('[data-seconds]').forEach(b => { const selected = b === button; b.classList.toggle('selected', selected); b.setAttribute('aria-pressed', String(selected)); }); refresh();
}));
$('pause').addEventListener('click', () => {
  state.end = state.end === null ? state.data?.end || Date.now() : null;
  $('pause').textContent = state.end === null ? 'Ⅱ 暂停查看' : '▷ 返回实时'; hideTooltip(); render(); refresh();
});
$('export').addEventListener('click', () => { const query = new URLSearchParams({ seconds: state.seconds, end: state.end || state.data?.end || Date.now() }); const link = element('a'); link.href = '/api/export?' + query; link.download = ''; document.body.append(link); link.click(); link.remove(); });
$('ping-chart').addEventListener('pointermove', e => chartTooltip(e, 'ICMP'));
$('http-chart').addEventListener('pointermove', e => chartTooltip(e, 'HTTP'));
[$('ping-chart'), $('http-chart')].forEach(canvas => canvas.addEventListener('pointerleave', hideTooltip));
let resizeTimer;
window.addEventListener('resize', () => { clearTimeout(resizeTimer); resizeTimer = setTimeout(drawCharts, 100); });
document.addEventListener('visibilitychange', () => { if (document.hidden) { clearTimeout(state.timer); state.generation++; state.request?.abort(); } else refresh(); });
window.addEventListener('pagehide', () => { clearTimeout(state.timer); state.generation++; state.request?.abort(); });
setInterval(() => { $('clock').textContent = timeLabel(Date.now(), true); }, 1000);
refresh();
