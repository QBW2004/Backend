(function(root,$){
    'use strict';
    var math=null,error='';
    function current(){return $('#gcGameId').val()==='55';}
    function pct(v){return(100*v).toFixed(2)+'%';}
    function refresh(){if(typeof root.gcUpdatePayoutSum==='function')root.gcUpdatePayoutSum();}
    root.rabbitPayoutClear=function(){
        math=null;error='';$('#rabbitPayout,#rbTableStats').hide();$('#gcForm').removeClass('gc-rb-mode');
        $('#gcHp0').prop('readonly',false).removeAttr('title');
        var th=$('#gcPayoutTable th').eq(2);if(th.data('rb-original'))th.text(th.data('rb-original'));
    };
    root.rabbitPayoutLoad=function(){
        root.rabbitPayoutClear();if(!current())return;
        $('#gcForm').addClass('gc-rb-mode');$('#rabbitPayout').show();
        var th=$('#gcPayoutTable th').eq(2);if(!th.data('rb-original'))th.data('rb-original',th.text());th.text('奖励倍数（按当前规则）');
        $('#rbTableStats').insertBefore($('#gcPayoutTable').prevAll('.gc-section-title').first()).show();
        $('#rbTableStatus').text('正在读取玩法规则…');refresh();
    };
    root.rabbitPayoutUseRules=function(data,source){
        if(!current())return;math=RabbitRulesMath.model(data);error='';
        $('#rbTableScope').text(source==='table'?'当前桌台独立规则':source==='legacy'?'当前桌台沿用旧规则 · 保存后独立生效':'当前桌台默认规则 · 保存后独立生效');
        $('#rbTableStatus').text('已读取本桌玩法规则 · 修改后实时重算');refresh();
    };
    root.rabbitPayoutRtp=function(){return current()?{valid:!!math,error:error,model:math}:null;};
    root.rabbitPayoutUseDraft=function(data,message){
        if(!current())return;
        if(data){math=RabbitRulesMath.model(data);error='';}else{math=null;error=message||'规则草稿无效';}
        $('#rbTableScope').text('当前桌台规则草稿 · 保存后仅对本桌生效');$('#rbTableStatus').text(error||'正在按本桌未保存的玩法草稿试算');refresh();
    };
    root.rabbitPayoutDisplay=function(base,total,freqAuth,freqFive,invalid){
        if(!math||invalid){$('#rbTableRtp,#rbTableBase,#rbTableAuthExtra,#rbTableFiveExtra').text('—');$('#rbTableAuthAvg').text(invalid||error||'等待载入规则');return;}
        $('#rbTableRtp').text(pct(total));$('#rbTableBase').text(pct(base));
        $('#rbTableAuthExtra').text('+'+((math.authentic-math.authBase)*freqAuth*100).toFixed(2)+' 个百分点');
        $('#rbTableFiveExtra').text('+'+((math.five-math.fiveBase)*freqFive*100).toFixed(2)+' 个百分点');
        $('#rbTableAuthAvg').text('正宗平均奖励 '+math.authentic.toFixed(2)+' 倍');$('#rbTableFiveAvg').text('五梅平均奖励 '+math.five.toFixed(2)+' 倍');
    };
})(window,jQuery);
