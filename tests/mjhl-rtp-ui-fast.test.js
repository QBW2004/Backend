'use strict';
// 直接提取本地Razor中的实际函数，以受控DOM/Worker验证异步时序；不连接数据库或游戏服。
const fs = require('fs'), path = require('path'), vm = require('vm'), assert = require('assert');
const root = path.resolve(__dirname, '..');
const viewPath = path.join(root, 'TTY.Web/Areas/Game/Views/GameConfig/ConfigEditor.cshtml');
const source = fs.readFileSync(viewPath, 'utf8');
const script = source.slice(source.indexOf('    var GC_MJHL_RTP_SEQ'), source.indexOf('\n    function gcApplyType()'));
const engine = require(path.join(root, 'TTY.Web/Scripts/app/mjhl.engine.js'));
const clone = value => structuredClone(value);
const checks = [];
function check(name, fn) { fn(); checks.push(name); }
function harness() {
    const nodes = {}, bindings = {}, workers = [], timers = new Map(), calls = [], toasts = [];
    let clock = 0;
    function $(selector) {
        if (typeof selector === 'object') return selector;
        if (!nodes[selector]) nodes[selector] = {value:'', props:{}, textValue:'', dataValues:{}};
        const node = nodes[selector];
        const api = {
            val(v) { if (arguments.length) { node.value = v; return api; } return node.value; },
            prop(k,v) { if (arguments.length > 1) { node.props[k] = v; return api; } return node.props[k]; },
            text(v) { if (arguments.length) { node.textValue = v; return api; } return node.textValue; },
            data(k,v) { if (arguments.length > 1) { node.dataValues[k] = v; return api; } return node.dataValues[k]; },
            each() { return api; }, attr() { return api; }, toggleClass() { return api; }, toggle(v) { node.visible = !!v; return api; },
            on(events, arg, handler) { events.split(' ').forEach(event => bindings[selector + ':' + event] = handler || arg); return api; }
        };
        return api;
    }
    $.extend = function (deep, target, ...values) { values.forEach(value => Object.assign(target, clone(value))); return target; };
    $.each = (items, fn) => items.forEach((value, index) => fn(index,value)); $.trim = v => String(v == null ? '' : v).trim();
    $.ajax = options => {
        let done, fail, always;
        calls.push({url:options.url,data:options.data,callback(data){done(data);if(always)always();},fail(){fail();if(always)always();}});
        const result={done(fn){done=fn;return result;},fail(fn){fail=fn;return result;},always(fn){always=fn;return result;}};
        return result;
    };
    function Worker(url) { this.url = url; this.stopped = false; this.postMessage = job => { this.job = clone(job); }; this.terminate = () => { this.stopped = true; }; workers.push(this); }
    const ctx = { $, console, Math, Number, String, JSON, isFinite, Worker,
        window:{ Worker, MjhlEngine:engine, setTimeout(fn) { const id = ++clock; timers.set(id,fn); return id; }, clearTimeout(id) { timers.delete(id); } },
        line:'realAgent', GC_MJHL_AGENT:null, GC_MJHL_AGENT_SAVED:null, GC_MJHL_AGENT_CAN_EDIT:true,
        gcCurLine:() => ctx.line, gcIsMjhl:() => true, gcMjhlWeightSummary:() => [], gcMjhlRenderWeights:() => {},
        gcSetParaVisible:() => {}, gcMsg:() => {}, gcLineToken:() => 'test-token',
        showToast:(text,type) => toasts.push({text,type}), request:(url,data,callback) => calls.push({url,data,callback}),
        GC_URL:{mjhlAgentGet:'read',mjhlAgentSave:'save'}
    };
    vm.createContext(ctx); vm.runInContext(script, ctx, {filename:viewPath});
    // 实际事件绑定也取自页面，防止函数正确但页面漏接事件。
    source.split(/\r?\n/).filter(line => /\$\('#gcMjhlAgentPanel \.gc-weight-body'\)\.on|\$\('#mjhlScatterEnabled,#mjhlFreeRetrigger'\)\.on|\$\('#mjhlGoldChance'\)\.on|\$\('#mjhlTargetRtp'\)\.on/.test(line)).forEach(line => vm.runInContext(line,ctx));
    const defaults = engine.defaults();
    const config = {gameId:54,targetRtp:80,goldChance:8,scatterEnabled:true,freeRetrigger:true,weights:clone(defaults.weights),bets:{min:0.4,max:60,chips:[0.4,0.8,1.2,2,4,6,8,20,60],entry:6,scorePerCoin:1}};
    function prepare(cfg=config) {
        ctx.GC_MJHL_AGENT = clone(cfg); ctx.GC_MJHL_AGENT_SAVED = clone(cfg); ctx.GC_MJHL_AGENT_CAN_EDIT = true;
        $('#mjhlTargetRtp').val(cfg.targetRtp); $('#mjhlGoldChance').val(cfg.goldChance);
        $('#mjhlScatterEnabled').prop('checked',cfg.scatterEnabled); $('#mjhlFreeRetrigger').prop('checked',cfg.freeRetrigger);
        return cfg;
    }
    function stats() { return {total:0.801,half95:0.009,count:1000000,distribution:{zero:800000,small:190000,medium:9000,big:800,mega:150,super:50},precisionReached:true,intervalReliable:true,unobservedReturn:false,exact:false,normalOnly:true,mathFingerprint:ctx.gcMjhlRtpFingerprint(ctx.gcMjhlRtpMathKey(ctx.gcMjhlEngineProfile()))}; }
    function meta(data=stats()) { return {lineAgent:ctx.line,configured:true,revision:'3',configHash:'a'.repeat(64),canEdit:true,simulationSummary:'正常权重试算；'+JSON.stringify(data)}; }
    function flush() { const pending = Array.from(timers.values()); timers.clear(); pending.forEach(fn => fn()); }
    function result(worker=workers[workers.length-1], values={}) { worker.onmessage({data:{result:{stats:Object.assign(stats(),values),precisionReached:true,exact:false}}}); }
    prepare(); return {ctx,$,nodes,bindings,workers,timers,calls,toasts,config,prepare,stats,meta,flush,result};
}
check('开关文字覆盖打开和关闭', () => {
    const h=harness(); h.ctx.gcMjhlSwitchText(); assert.equal(h.$('#mjhlScatterState').text(),'打开至尊'); assert.equal(h.$('#mjhlFreeRetriggerState').text(),'打开触发');
    h.$('#mjhlScatterEnabled').prop('checked',false); h.$('#mjhlFreeRetrigger').prop('checked',false); h.ctx.gcMjhlSwitchText();
    assert.equal(h.$('#mjhlScatterState').text(),'关闭至尊'); assert.equal(h.$('#mjhlFreeRetriggerState').text(),'关闭触发');
});
check('数学缓存排除目标、筹码和兑换，保留实际权重和金牌', () => {
    const h=harness(), c=h.ctx, key=c.gcMjhlRtpMathKey(c.gcMjhlEngineProfile());
    h.$('#mjhlTargetRtp').val(91); c.GC_MJHL_AGENT.bets.entry=8; c.GC_MJHL_AGENT.bets.scorePerCoin=100;
    assert.equal(c.gcMjhlRtpMathKey(c.gcMjhlEngineProfile()),key);
    c.GC_MJHL_AGENT.weights.n[0][0]++; assert.notEqual(c.gcMjhlRtpMathKey(c.gcMjhlEngineProfile()),key);
    c.GC_MJHL_AGENT.weights.n[0][0]--; h.$('#mjhlGoldChance').val(9); assert.notEqual(c.gcMjhlRtpMathKey(c.gcMjhlEngineProfile()),key);
});
check('已关闭的至尊原始权重不影响数学指纹，开启后影响', () => {
    const h=harness(), c=h.ctx; h.$('#mjhlScatterEnabled').prop('checked',false); const key=c.gcMjhlRtpMathKey(c.gcMjhlEngineProfile());
    c.GC_MJHL_AGENT.weights.n[10][0]++; assert.equal(c.gcMjhlRtpMathKey(c.gcMjhlEngineProfile()),key);
    h.$('#mjhlScatterEnabled').prop('checked',true); assert.notEqual(c.gcMjhlRtpMathKey(c.gcMjhlEngineProfile()),key);
});
check('完整110格单项变动指纹区分且摘要小于1800字符', () => {
    const h=harness(), c=h.ctx, seen=new Set(), initial=clone(c.GC_MJHL_AGENT.weights);
    for (const mode of ['n','f']) for(let r=0;r<11;r++) for(let col=0;col<5;col++) {
        c.GC_MJHL_AGENT.weights=clone(initial); c.GC_MJHL_AGENT.weights[mode][r][col]++;
        const fingerprint=c.gcMjhlRtpFingerprint(c.gcMjhlRtpMathKey(c.gcMjhlEngineProfile())); assert(!seen.has(fingerprint)); seen.add(fingerprint);
    }
    assert.equal(seen.size,110); assert(JSON.stringify(h.stats()).length<1800);
});
check('相同代理已保存达标历史加载与恢复不启动Worker', () => {
    const h=harness(), meta=h.meta(); h.ctx.gcMjhlFill(h.config,meta); assert.equal(h.workers.length,0); assert(h.ctx.GC_MJHL_RTP_RESULT.historical);
    h.ctx.gcMjhlFill(h.ctx.GC_MJHL_AGENT_SAVED,h.ctx.GC_MJHL_META); assert.equal(h.workers.length,0); assert.equal(h.$('#mjhlScatterState').text(),'打开至尊');
});
check('继承默认配置复用来源版本的达标RTP，目标版本仍用于写入校验', () => {
    const h=harness(),meta=h.meta();meta.configured=false;meta.inherited=true;meta.sourceLine='*';meta.sourceRevision='7';meta.revision='0';
    h.ctx.gcMjhlFill(h.config,meta);assert.equal(h.workers.length,0);assert(h.ctx.GC_MJHL_RTP_RESULT.historical);assert.equal(h.$('#mjhlAgentStatus').data('revision'),'0');
    assert(h.$('#mjhlAgentStatus').text().includes('默认版本 7'));
});
for (const [name, mutate] of [
    ['跨代理',m=>{m.lineAgent='anotherAgent';}],['无完整配置哈希',m=>{m.configHash='bad';}],['未保存',m=>{m.configured=false;}],
    ['旧规则指纹',m=>{const s=JSON.parse(m.simulationSummary.split('；')[1]);s.mathFingerprint='v9:abc';m.simulationSummary=JSON.stringify(s);}],
    ['无指纹',m=>{const s=JSON.parse(m.simulationSummary.split('；')[1]);delete s.mathFingerprint;m.simulationSummary=JSON.stringify(s);}],
    ['精度未达标',m=>{const s=JSON.parse(m.simulationSummary.split('；')[1]);s.precisionReached=false;m.simulationSummary=JSON.stringify(s);}],
    ['误差超过1',m=>{const s=JSON.parse(m.simulationSummary.split('；')[1]);s.half95=0.010001;m.simulationSummary=JSON.stringify(s);}],
    ['未观测到返奖',m=>{const s=JSON.parse(m.simulationSummary.split('；')[1]);s.unobservedReturn=true;m.simulationSummary=JSON.stringify(s);}],
    ['非普通开奖结果',m=>{const s=JSON.parse(m.simulationSummary.split('；')[1]);s.normalOnly=false;m.simulationSummary=JSON.stringify(s);}]
]) check(name+'历史不能冒用，改走verify',()=>{const h=harness(),meta=h.meta();mutate(meta);h.ctx.gcMjhlFill(h.config,meta);assert.equal(h.workers.length,1);assert.equal(h.workers[0].job.type,'verify');assert.equal(h.ctx.GC_MJHL_RTP_RESULT,null);});
check('输入目标不按字符计算，Enter后change失焦只执行一次',()=>{
    const h=harness(); h.ctx.gcMjhlFill(h.config,h.meta()); assert(!h.bindings['#mjhlTargetRtp:input']);
    h.$('#mjhlTargetRtp').val(85); let prevented=false; h.bindings['#mjhlTargetRtp:keydown']({key:'Enter',preventDefault(){prevented=true;}});
    h.bindings['#mjhlTargetRtp:change'](); assert(prevented); assert.equal(h.workers.length,1); assert.equal(h.workers[0].job.type,'calibrate');
    assert.equal(h.nodes['#gcMjhlAgentPanel input,#mjhlAgentReset'].props.disabled,true);
});
check('目标同值失焦不再调权重，格式变化也不重复',()=>{
    const h=harness();h.ctx.gcMjhlFill(h.config,h.meta());h.$('#mjhlTargetRtp').val('80.00');h.bindings['#mjhlTargetRtp:change']();assert.equal(h.workers.length,0);
});
check('空目标不能被当作0%调成无奖或保存',()=>{
    const h=harness();h.ctx.gcMjhlFill(h.config,h.meta());h.$('#mjhlTargetRtp').val('');h.ctx.gcMjhlCalibrate();h.ctx.gcMjhlSave();assert.equal(h.workers.length,0);assert.equal(h.calls.length,0);assert.equal(h.toasts.length,2);
});
check('手动input/change去重、停顿复核、继续编辑取消旧任务',()=>{
    const h=harness(),c=h.ctx; c.gcMjhlFill(h.config,h.meta()); c.GC_MJHL_AGENT.weights.n[0][0]++;
    h.bindings['#gcMjhlAgentPanel .gc-weight-body:input']();h.bindings['#gcMjhlAgentPanel .gc-weight-body:change']();assert.equal(h.timers.size,1);h.flush();
    assert.equal(h.workers.length,1);assert.equal(h.workers[0].job.type,'verify');assert.equal(h.nodes['#gcMjhlAgentPanel input,#mjhlAgentReset'].props.disabled,false);assert.equal(h.$('#mjhlAgentSave').prop('disabled'),true);
    h.bindings['#gcMjhlAgentPanel .gc-weight-body:change']();assert.equal(h.workers.length,1);assert(!h.workers[0].stopped);
    const old=h.workers[0];c.GC_MJHL_AGENT.weights.f[1][1]++;h.bindings['#gcMjhlAgentPanel .gc-weight-body:input']();assert(old.stopped);assert.equal(h.timers.size,1);h.flush();assert.equal(h.workers.length,2);
    h.result(old);assert.equal(c.GC_MJHL_RTP_RESULT,null);assert.equal(c.GC_MJHL_RTP_WORKER,h.workers[1]);
    h.result();assert(c.GC_MJHL_RTP_RESULT);assert.equal(h.$('#mjhlAgentSave').prop('disabled'),false);
    h.bindings['#gcMjhlAgentPanel .gc-weight-body:change']();h.flush();assert.equal(h.workers.length,2);
});
check('重开同数学快照读缓存，明确复核按钮仍重新算',()=>{
    const h=harness(),c=h.ctx;c.gcMjhlFill(h.config,h.meta());c.gcMjhlActualRtp();assert.equal(h.workers.length,0);c.gcMjhlVerify();assert.equal(h.workers.length,1);assert.equal(h.workers[0].job.type,'verify');
});
check('切换代理后旧Worker结果不能覆盖新代理',()=>{
    const h=harness(),c=h.ctx;c.gcMjhlRunRtp('verify');const old=h.workers[0];c.line='otherAgent';c.gcMjhlFill(h.config,h.meta());h.result(old);assert.equal(c.GC_MJHL_RTP_RESULT.historical,true);assert.equal(c.GC_MJHL_LOADED_LINE,'otherAgent');
});
check('精确0只在数学可证明无奖时复用',()=>{
    const h=harness(),c=h.ctx,s={total:0,half95:0,count:0,exact:true,normalOnly:true,precisionReached:true};assert.equal(c.gcMjhlRtpReusable(s,c.gcMjhlEngineProfile()),false);
    const p=c.gcMjhlEngineProfile(); for(const mode of ['n','f']) { p.weights[mode]=Array.from({length:11},()=>[0,0,0,0,0]); for(let col=0;col<5;col++)p.weights[mode][col%2][col]=10000; } assert.equal(c.gcMjhlRtpReusable(s,p),true);
});
check('只改筹码可沿用真实RTP保存，改变权重不能保存旧结果',()=>{
    const h=harness(),c=h.ctx;c.gcMjhlFill(h.config,h.meta());h.$('#mjhlBetEntry').val(8);c.gcMjhlSave();assert.equal(h.calls.length,1);assert.equal(h.calls[0].url,'save');
    const saved=JSON.parse(h.calls[0].data.simulated);assert.equal(saved.mathFingerprint,c.gcMjhlRtpFingerprint(c.gcMjhlRtpMathKey(c.gcMjhlEngineProfile())));assert.equal(h.calls[0].data.lineAgent,'realAgent');
    c.gcMjhlSave();assert.equal(h.calls.length,1);assert(c.GC_MJHL_WRITING);
    h.calls[0].callback({code:0});c.GC_MJHL_AGENT.weights.n[0][0]++;c.gcMjhlSave();assert.equal(h.calls.length,1);assert(h.toasts.some(t=>t.type==='warning'));
});
check('快速估算持续显示、无保存资格且不污染缓存，最终复核替换估算',()=>{
    const h=harness(),c=h.ctx; c.gcMjhlFill(h.config,{}); const worker=h.workers[0], weights=JSON.stringify(c.GC_MJHL_AGENT.weights);
    const preview=Object.assign(h.stats(),{count:2000,half95:0.15,precisionReached:false});
    worker.onmessage({data:{preview}}); const shown=h.$('#mjhlActualRtp').text();
    assert(shown.includes('估算 RTP')); assert(shown.includes('2,000')); assert(shown.includes('待精确复核'));
    assert.equal(c.GC_MJHL_RTP_RESULT,null); assert.equal(Object.keys(c.GC_MJHL_RTP_CACHE).length,0); assert.equal(h.$('#mjhlAgentSave').prop('disabled'),true);
    worker.onmessage({data:{progress:{phase:'verify',completed:10000,total:50000000}}});
    assert.equal(h.$('#mjhlActualRtp').text(),shown); assert(h.$('#mjhlRtpProgress').text().includes('精确复核'));
    assert.equal(JSON.stringify(c.GC_MJHL_AGENT.weights),weights); h.result(worker);
    assert(!h.$('#mjhlActualRtp').text().includes('估算')); assert.equal(h.$('#mjhlRtpProgress').text(),''); assert(c.GC_MJHL_RTP_RESULT.precisionReached);
});
check('调权重区分调整前与候选估算，两者均不应用权重或解锁保存',()=>{
    const h=harness(),c=h.ctx;c.gcMjhlFill(h.config,h.meta());c.gcMjhlRunRtp('calibrate');const worker=h.workers[0],weights=JSON.stringify(c.GC_MJHL_AGENT.weights);
    worker.onmessage({data:{preview:h.stats(),beforeCalibration:true}});assert(h.$('#mjhlActualRtp').text().includes('调整前权重'));
    worker.onmessage({data:{progress:{phase:'search',estimate:h.stats()}}});assert(h.$('#mjhlActualRtp').text().includes('候选权重'));
    c.gcMjhlSave();assert.equal(h.calls.length,0);assert.equal(c.GC_MJHL_RTP_RESULT,null);assert.equal(JSON.stringify(c.GC_MJHL_AGENT.weights),weights);
    assert.equal(h.$('#mjhlAgentSave').prop('disabled'),true);
});
check('取消与切换代理后忽略迟到估算，重新载入不能复用估算',()=>{
    const h=harness(),c=h.ctx;c.gcMjhlFill(h.config,{});const worker=h.workers[0];worker.onmessage({data:{preview:h.stats()}});
    c.gcMjhlVerify();const stopped=h.$('#mjhlActualRtp').text();worker.onmessage({data:{preview:h.stats()}});assert.equal(h.$('#mjhlActualRtp').text(),stopped);assert.equal(h.$('#mjhlRtpProgress').text(),'');
    c.line='nextAgent';c.gcMjhlFill(h.config,{});assert.equal(h.workers.length,2);const loading=h.$('#mjhlActualRtp').text();worker.onmessage({data:{preview:h.stats()}});assert.equal(h.$('#mjhlActualRtp').text(),loading);assert.equal(c.GC_MJHL_RTP_RESULT,null);
});
check('估算失败不结束正式任务，未中奖估算不冒充精确0%',()=>{
    const h=harness(),c=h.ctx;c.gcMjhlRunRtp('verify');const worker=h.workers[0];worker.onmessage({data:{previewError:'long chain'}});
    assert(c.GC_MJHL_CALIBRATING);assert(!worker.stopped);assert.equal(c.GC_MJHL_RTP_RESULT,null);
    worker.onmessage({data:{preview:Object.assign(h.stats(),{total:0,half95:0,unobservedReturn:true})}});
    assert(h.$('#mjhlActualRtp').text().includes('未能确定误差'));assert(!h.$('#mjhlActualRtp').text().includes('精确值'));
    worker.onmessage({data:{error:'复核失败'}});assert.equal(h.$('#mjhlRtpProgress').text(),'');assert.equal(c.GC_MJHL_RTP_RESULT,null);
});
assert(source.includes('误差不超过±1个百分点'));
const report={completedAt:new Date().toISOString(),checksPassed:checks.length,checks};
if (process.env.MJHL_UI_TEST_REPORT) fs.writeFileSync(process.env.MJHL_UI_TEST_REPORT,JSON.stringify(report,null,2));
console.log(JSON.stringify(report));
