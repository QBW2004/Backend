(function(root,$){
    'use strict';
    function current(){return $('#gcGameId').val()==='25';}
    function pct(v){return(v*100).toFixed(2)+'%';}
    function features(){
        if(!$('#amFeatureTable').parent().is('#gcGfBox')){
            $('#amFeatureTable').appendTo('#gcGfBox');
            [['gcGf','amGfInput'],['gcDp','amDpInput'],['gcAr','amArInput'],['gcGfOn','amGfOn'],['gcDpOn','amDpOn'],['gcArOn','amArOn']].forEach(function(p){$('#'+p[0]).appendTo('#'+p[1]);});
            $('#amGfAwards,.am-rules').appendTo('#gcGfBox');
        }
        var awards=($('#amGfAwardRows').empty());
        root.GC_GOLD_FINGER_MAGS.forEach(function(v){awards.append($('<div>').append($('<strong>').text(v+' 倍')).append($('<small>').text('20.00%')));});
        $('#amGfAverage').text(root.GC_GOLD_FINGER_AVG_MAG);
    }
    root.attMhbClear=function(){
        $('#attMhbConfig,#amRtpStats,#amRtpNote').hide();$('#gcForm').removeClass('gc-att-mode');
        $('#gcHp0').prop('readonly',false).removeAttr('title');
        var header=$('#gcPayoutTable th').eq(2);if(header.data('am-original'))header.text(header.data('am-original'));
        $('#gcJpBox > .gc-section-title,#gcGfBox > .gc-section-title').each(function(){var title=$(this);if(title.data('am-original'))title.text(title.data('am-original'));});
    };
    root.attMhbLoad=function(){
        if(!current())return;$('#gcForm').addClass('gc-att-mode');$('#attMhbConfig').show();features();
        var title=$('#gcPayoutTable').prevAll('.gc-section-title').first();$('#amRtpStats').insertBefore(title).show();$('#amRtpNote').insertAfter('#amRtpStats').show();
        var header=$('#gcPayoutTable th').eq(2);if(!header.data('am-original'))header.data('am-original',header.text());header.text('小档 / 中档 / 大档（60% / 25% / 15%）');
        root.GC_PAYOUT_ROWS.forEach(function(r){
            var s=root.GC_MAG_TAB.dscj,span=$('#gcHm'+r.ht).empty(),avg=s.small[r.ht]*0.6+s.middle[r.ht]*0.25+s.big[r.ht]*0.15;
            var odds=$('<span class="am-odds">');[s.small[r.ht],s.middle[r.ht],s.big[r.ht]].forEach(function(v){odds.append($('<span>').text(v));});
            span.append(odds).append($('<small class="am-weighted">').text('加权 '+avg.toFixed(2)+' 倍'));
        });
        $('#gcJpBox > .gc-section-title,#gcGfBox > .gc-section-title').each(function(){var title=$(this);if(!title.data('am-original'))title.data('am-original',title.text());});
        $('#gcGfBox > .gc-section-title').text('额外玩法 · 触发机会');
        $('#gcJpBox > .gc-section-title').first().text('彩金奖池 · 六池设置');root.gcUpdatePayoutSum();
    };
    root.attMhbDisplayRtp=function(base,goldFinger,winSum){
        if(!current())return;
        var bad=!isFinite(base)||winSum>10000||winSum<0;
        $('#amBaseRtp').text(bad?'—':pct(base));$('#amGfRtp').text(bad?'—':'+'+(goldFinger*100).toFixed(2)+' 个百分点');$('#amTotalRtp').text(bad?'—':pct(base+goldFinger));
        $('#gcHp0').val(Math.max(0,10000-winSum)).prop('readonly',true).attr('title','杂牌自动取未中奖余量');
        [['gcGf','amGfChance'],['gcDp','amDpChance'],['gcAr','amArChance']].forEach(function(p){var v=Number($('#'+p[0]).val());$('#'+p[1]).text(Number.isInteger(v)&&v>=0&&v<=10000?pct(v/10000):'—');});
        $('#amGfFrequency').text('杂牌余量 '+Math.max(0,10000-winSum)+' / 10000 · 平均奖励 '+root.GC_GOLD_FINGER_AVG_MAG+' 倍');
    };
})(window,jQuery);
