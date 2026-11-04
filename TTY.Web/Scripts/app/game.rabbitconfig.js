(function($){
    'use strict';
    var cfg=null,loading=false,saving=false,dirty=false,loadFailed=false,active=null,sequence=0,drafts={},dropNew=false,source='default',authMode='weight',fiveMode='weight',authPercentEdited=false,fivePercentEdited=false;
    function current(){return $('#gcGameId').val()==='55';}
    function key(){return current()?String($('#gcId').val()):null;}
    function busy(){return loading||saving;}
    var numbers={rbSmallFour:'smallFourMultiplier',rbReveal:'specialRules.authentic.revealTimeoutSeconds',rbAuthBase:'specialRules.authentic.baseMultiplier',
        rbFiveBase:'specialRules.five.baseMultiplier',rbFiveSuccess:'specialRules.five.successMultiplier',rbFiveMiss:'specialRules.five.missMultiplier',
        rbBurn:'specialRules.streak.burnRounds',rbContribution:'specialRules.streak.poolContributionBasisPoints',rbInitPool:'specialRules.streak.initialPool',
        rbPassTarget:'passTarget',rbPassBonus:'passBonus',rbExplodeTarget:'explodeTarget',rbExplodeBonus:'explodeBonus'};
    var flags={rbAuthOn:'specialRules.authentic.enabled',rbFiveOn:'specialRules.five.enabled',rbStreakOn:'specialRules.streak.enabled',
        rbGuaranteeLast:'specialRules.streak.guaranteeLastRound',rbBlockHigher:'specialRules.streak.blockHigherPrizes',rbPassOn:'specialRules.settlement.passEnabled',rbExplodeOn:'specialRules.settlement.explodeEnabled'};
    var chances={rbFiveChance:'specialRules.five.successChance',rbFiveForce:'specialRules.five.forcedSuccessChance',rbStart:'specialRules.streak.startChance',
        rbContinue:'specialRules.streak.continueChance',rbExpired:'specialRules.streak.expiredChance',rbSecondJoker:'specialRules.streak.secondJokerChance',rbJokerFirst:'specialRules.streak.jokerFirstChance'};
    function copy(v){return JSON.parse(JSON.stringify(v));}
    function at(obj,path,value){var parts=path.split('.'),last=parts.pop();parts.forEach(function(k){obj=obj[k];});if(arguments.length===3)obj[last]=value;return obj[last];}
    function fill(dst,src,overwrite){Object.keys(src).forEach(function(k){if(src[k]&&typeof src[k]==='object'&&!Array.isArray(src[k])){if(!dst[k]||typeof dst[k]!=='object')dst[k]={};fill(dst[k],src[k],overwrite);}else if(overwrite||dst[k]===undefined)dst[k]=copy(src[k]);});}
    function status(t,bad){$('#rabbitConfigStatus').text(t).css('color',bad?'#bc4444':'#6e8195');}
    function controls(){
        $('#rabbitConfig :input').prop('disabled',busy()||!cfg||active!==key());
        if(current()){$('#gcSave').prop('disabled',busy()||!cfg||active!==key());$('#gcReset').prop('disabled',busy());}
        else if(!busy()&&!window.GC_LABA_SAVING&&!window.GC_BATCH_SAVING)$('#gcSave,#gcReset').prop('disabled',false);
    }
    function token(){return $('input[name="__RequestVerificationToken"]').first().val()||'';}
    function weightedTable(id){
        var values=[],weights=[],percentages=[];$(id+' tbody tr').each(function(){values.push(Number($(this).find('.rb-wv').val()));weights.push(Number($(this).find('.rb-ww').val()));if(id==='#rbAuthTable')percentages.push($(this).find('.rb-ap').val());});
        if(id==='#rbAuthTable'&&authMode==='probability'&&authPercentEdited)weights=RabbitRulesMath.weightsFromPercentages(percentages);
        return{values:values,weights:weights};
    }
    function fiveChance(){
        if(fiveMode==='weight')return RabbitRulesMath.splitWeights(Number($('#rbFiveWinWeight').val()),Number($('#rbFiveMissWeight').val()));
        if(fivePercentEdited){var w=RabbitRulesMath.weightsFromPercentages([$('#rbFiveWinPct').val(),$('#rbFiveMissPct').val()]);return RabbitRulesMath.splitWeights(w[0],w[1]);}
        return{numerator:Number($('#rbFiveChanceN').val()),denominator:Number($('#rbFiveChanceD').val())};
    }
    function applyModes(){
        $('#rbAuthTable .rb-ww').prop('readOnly',authMode==='probability');$('#rbAuthTable .rb-ap').prop('readOnly',authMode==='weight');
        $('#rbFiveWinWeight,#rbFiveMissWeight').prop('readOnly',fiveMode==='probability');$('#rbFiveWinPct,#rbFiveMissPct').prop('readOnly',fiveMode==='weight');
    }
    function validateInputs(){
        $('#rabbitConfig input[type=number]').each(function(){
            if(this.readOnly)return;
            if($(this).hasClass('rb-percent')){RabbitRulesMath.percentUnits(this.value);return;}
            var v=this.value.trim(),n=Number(v),min=Number(this.min),max=Number(this.max);
            if(v===''||!Number.isSafeInteger(n)||n<min||n>max)throw new Error(($(this).closest('.rb-field').find('label').text()||this.getAttribute('aria-label')||'数值')+'须为有效范围内的整数。');
        });
    }
    function collect(){
        if(!cfg||active!==key())throw new Error('请先载入当前桌台玩法规则。');validateInputs();var result=copy(cfg);
        var natural=fiveChance();$('#rbFiveChanceN').val(natural.numerator);$('#rbFiveChanceD').val(natural.denominator);
        $.each(numbers,function(id,path){at(result,path,Number($('#'+id).val()));});
        $.each(flags,function(id,path){at(result,path,$('#'+id).is(':checked'));});
        $.each(chances,function(id,path){var c={numerator:Number($('#'+id+'N').val()),denominator:Number($('#'+id+'D').val())};RabbitRulesMath.chance(c);at(result,path,c);});
        result.specialRules.authentic.multipliers=weightedTable('#rbAuthTable');result.specialRules.streak.awardCounts=weightedTable('#rbStreakTable');
        result.specialRules.five.revealTimeoutSeconds=result.specialRules.authentic.revealTimeoutSeconds;
        result.schemaVersion=3;result.race.enabled=false;RabbitRulesMath.model(result);
        return result;
    }
    function addRow(id,value,weight){
        var maximum=id==='#rbAuthTable'?14:255;
        var tr=$('<tr><td><input type="number" class="rb-wv" min="1" max="'+maximum+'" step="1" aria-label="档位" /></td><td><input type="number" class="rb-ww" min="0" max="2147483647" step="1" aria-label="相对权重" /></td><td class="rb-prob rb-result">—</td><td class="rb-payout rb-result">—</td><td><button type="button" class="rb-delete">移除</button></td></tr>');
        if(id==='#rbAuthTable')tr.children().eq(2).removeClass('rb-prob').empty().append('<input type="number" class="rb-ap rb-percent" min="0" max="100" step="0.000001" value="0" aria-label="档位概率百分比" readonly />');
        tr.find('.rb-wv').val(value);tr.find('.rb-ww').val(weight);tr.toggleClass('rb-zero',weight===0);$(id+' tbody').append(tr);
        applyModes();
    }
    function renderWeighted(id,data){$(id+' tbody').empty();data.values.forEach(function(v,i){if(id!=='#rbAuthTable'||data.weights[i]>0)addRow(id,v,data.weights[i]);});}
    function render(){
        authMode='weight';fiveMode='weight';authPercentEdited=false;fivePercentEdited=false;$('#rbAuthMode,#rbFiveMode').val('weight');
        $.each(numbers,function(id,path){$('#'+id).val(at(cfg,path));});$.each(flags,function(id,path){$('#'+id).prop('checked',at(cfg,path));});
        $.each(chances,function(id,path){var c=at(cfg,path);$('#'+id+'N').val(c.numerator);$('#'+id+'D').val(c.denominator);});
        var fc=cfg.specialRules.five.successChance;$('#rbFiveWinWeight').val(fc.numerator);$('#rbFiveMissWeight').val(fc.denominator-fc.numerator);
        renderWeighted('#rbAuthTable',cfg.specialRules.authentic.multipliers);renderWeighted('#rbStreakTable',cfg.specialRules.streak.awardCounts);
        applyModes();refresh();
    }
    function pct(v){return(100*v).toFixed(2)+'%';}
    function showWeighted(id,data,stats,base){
        $(id+' tbody tr').each(function(i){var tr=$(this);tr.find('.rb-prob').text(pct(stats.probabilities[i]));tr.find('.rb-payout').text((base*data.values[i]).toFixed(0)+' 倍');});
        if(id==='#rbAuthTable'){
            var rounded=RabbitRulesMath.percentagesFromWeights(data.weights);
            $(id+' tbody tr').each(function(i){if(authMode==='weight')$(this).find('.rb-ap').val(rounded[i]);if(authMode==='probability'&&authPercentEdited)$(this).find('.rb-ww').val(data.weights[i]);});
        }
        $(id+' .rb-sum').text(stats.sum);$(id+' .rb-avg').text((base*stats.average).toFixed(2)+' 倍');
    }
    function refresh(publish){
        if(publish)dirty=true;
        try{var units=0;$('#rbAuthTable .rb-ap').each(function(){units+=RabbitRulesMath.percentUnits(this.value);});$('#rbAuthProbSum').text(authMode==='probability'?RabbitRulesMath.percentText(units)+'%':'100.00%');}catch(e){$('#rbAuthProbSum').text('—');}
        try{
            var c=collect(),m=RabbitRulesMath.model(c),s=c.specialRules;
            $.each(chances,function(id,path){$('#'+id+'D').closest('.rb-field').find('[data-rb-pct]').text(pct(RabbitRulesMath.chance(at(c,path))));});
            showWeighted('#rbAuthTable',s.authentic.multipliers,m.auth,s.authentic.baseMultiplier);showWeighted('#rbStreakTable',s.streak.awardCounts,m.streak,m.small);
            $('#rbAuthSum').text('权重合计 '+m.auth.sum);$('#rbStreakSum').text('权重合计 '+m.streak.sum+' · 次数期望 '+m.streak.average.toFixed(2));
            var fc=s.five.successChance;
            if(fiveMode==='weight'){var fp=RabbitRulesMath.percentagesFromWeights([fc.numerator,fc.denominator-fc.numerator]);$('#rbFiveWinPct').val(fp[0]);$('#rbFiveMissPct').val(fp[1]);}
            else{$('#rbFiveWinWeight').val(fc.numerator);$('#rbFiveMissWeight').val(fc.denominator-fc.numerator);}
            $('#rbFiveWeightSum').text(Number($('#rbFiveWinWeight').val())+Number($('#rbFiveMissWeight').val()));$('#rbFiveProbSum').text('100.00%');$('#rbFiveAveragePay').text(m.five.toFixed(2)+' 倍');
            $('#rbFiveWinPay').text(s.five.baseMultiplier*s.five.successMultiplier+' 倍');$('#rbFiveMissPay').text(s.five.baseMultiplier*s.five.missMultiplier+' 倍');
            if(publish&&window.rabbitPayoutUseDraft)window.rabbitPayoutUseDraft(c);
            return true;
        }catch(e){$('#rabbitConfig .rb-prob,#rabbitConfig .rb-payout,#rabbitConfig .rb-sum,#rabbitConfig .rb-avg,#rbFiveWinPay,#rbFiveMissPay,#rbFiveAveragePay,#rbFiveWeightSum,#rbFiveProbSum').text('—');status(e.message,true);if(window.rabbitPayoutUseDraft)window.rabbitPayoutUseDraft(null,e.message);return false;}
    }
    function remember(){
        if(active===null||!cfg)return;if(active==='-1'&&dropNew){delete drafts[active];return;}
        var fields={};$('#rabbitConfig input[id]').each(function(){fields[this.id]={value:this.value,checked:this.checked};});
        function rows(id){return $(id+' tbody tr').map(function(){return{value:$(this).find('.rb-wv').val(),weight:$(this).find('.rb-ww').val(),percent:$(this).find('.rb-ap').val()};}).get();}
        drafts[active]={cfg:copy(cfg),fields:fields,auth:rows('#rbAuthTable'),streak:rows('#rbStreakTable'),dirty:dirty,source:source,authMode:authMode,fiveMode:fiveMode,authEdited:authPercentEdited,fiveEdited:fivePercentEdited};
    }
    function publish(){
        if(dirty)return refresh(true);
        if(!refresh())return false;
        if(window.rabbitPayoutUseRules)window.rabbitPayoutUseRules(collect(),source);
        return true;
    }
    function restore(draft){
        cfg=copy(draft.cfg);dirty=!!draft.dirty;source=draft.source||'table';render();
        if(draft.fields){
            authMode=draft.authMode;fiveMode=draft.fiveMode;authPercentEdited=draft.authEdited;fivePercentEdited=draft.fiveEdited;
            $('#rbAuthTable tbody,#rbStreakTable tbody').empty();
            draft.auth.forEach(function(r){addRow('#rbAuthTable',r.value,r.weight);$('#rbAuthTable .rb-ap').last().val(r.percent);});
            draft.streak.forEach(function(r){addRow('#rbStreakTable',r.value,r.weight);});
            $.each(draft.fields,function(id,v){$('#'+id).val(v.value).prop('checked',v.checked);});
            $('#rbAuthMode').val(authMode);$('#rbFiveMode').val(fiveMode);applyModes();
        }
        var valid=publish();controls();if(valid&&!dirty)status('已载入本桌独立规则 · 修改后需保存');
    }
    function failLoad(message){
        cfg=null;loadFailed=true;status(message,true);
        if(window.rabbitPayoutUseDraft)window.rabbitPayoutUseDraft(null,message);
    }
    function load(){
        var target=key();if(target===null)return;var request=++sequence;active=target;cfg=null;dropNew=false;loadFailed=false;loading=true;controls();status('载入本桌玩法规则…');
        if(window.rabbitPayoutUseDraft)window.rabbitPayoutUseDraft(null,'正在读取玩法规则…');
        $.ajax({url:RABBIT_CONFIG_URLS.get,type:'POST',data:{tableIndex:Number(target)<0?-1:Number(target)%1000,__RequestVerificationToken:token()},dataType:'json',timeout:15000}).done(function(data){
            if(request!==sequence||target!==key()||active!==target)return;
            if(data&&data.code===1){
                try{
                    if(!$.isPlainObject(data.config))throw new Error('规则返回格式异常。');
                    cfg=data.config;dirty=false;source=data.source||'table';fill(cfg,copy(RABBIT_RULE_DEFAULTS));RabbitRulesMath.model(cfg);render();
                    if(!publish())throw new Error($('#rabbitConfigStatus').text()||'规则校验失败。');
                    status(data.saved?'已载入本桌独立规则 · 修改后需保存':source==='legacy'?'本桌沿用旧规则 · 保存后独立生效':'本桌使用默认规则 · 保存后独立生效');
                    if(load.addRequested){load.addRequested=false;append('#rbAuthTable');document.querySelector('#rbAuthentic').scrollIntoView({block:'start'});}
                }
                catch(e){failLoad('规则无法读取，请点击顶部刷新：'+e.message);}
            }
            else{failLoad(((data&&data.content)||'载入失败')+'，请点击顶部刷新后重试。');}
        }).fail(function(xhr,reason){if(request!==sequence||target!==key()||active!==target)return;failLoad((reason==='timeout'?'规则读取超时':'后台连接失败')+'，请点击顶部刷新后重试。');}).always(function(){if(request!==sequence||active!==target)return;loading=false;controls();});
    }
    function append(id){
        var used={},maximum=id==='#rbAuthTable'?14:255;$(id+' .rb-wv').each(function(){used[Number(this.value)]=true;});
        for(var v=1;v<=maximum;v++)if(!used[v]){addRow(id,v,0);refresh(true);$(id+' tbody tr').last().find(id==='#rbAuthTable'&&authMode==='probability'?'.rb-ap':'.rb-ww').trigger('focus');status('已新增档位 · 填写权重或概率后保存，仅对本桌生效');return;}
        status('已达到 '+maximum+' 个不同档位的上限。',true);
    }
    $(function(){
        $('#rbAuthAdd').on('click',function(){append('#rbAuthTable');});$('#rbStreakAdd').on('click',function(){append('#rbStreakTable');});
        $('#rbAuthMode').on('change',function(){
            try{var data=weightedTable('#rbAuthTable');RabbitRulesMath.weighted(data,14);var rounded=RabbitRulesMath.percentagesFromWeights(data.weights);$('#rbAuthTable tbody tr').each(function(i){$(this).find('.rb-ww').val(data.weights[i]);$(this).find('.rb-ap').val(rounded[i]);});authMode=this.value;authPercentEdited=false;applyModes();refresh();}
            catch(e){this.value=authMode;status(e.message,true);}
        });
        $('#rbFiveMode').on('change',function(){
            try{var fc=fiveChance();RabbitRulesMath.chance(fc);$('#rbFiveChanceN').val(fc.numerator);$('#rbFiveChanceD').val(fc.denominator);var rounded=RabbitRulesMath.percentagesFromWeights([fc.numerator,fc.denominator-fc.numerator]);$('#rbFiveWinPct').val(rounded[0]);$('#rbFiveMissPct').val(rounded[1]);$('#rbFiveWinWeight').val(fc.numerator);$('#rbFiveMissWeight').val(fc.denominator-fc.numerator);fiveMode=this.value;fivePercentEdited=false;applyModes();refresh();}
            catch(e){this.value=fiveMode;status(e.message,true);}
        });
        $('#rabbitConfig').on('input change','input',function(){
            if($(this).hasClass('rb-ap'))authPercentEdited=true;
            if(this.id==='rbFiveWinPct'||this.id==='rbFiveMissPct'){
                fivePercentEdited=true;
                try{var complement=100000000-RabbitRulesMath.percentUnits(this.value);$('#'+(this.id==='rbFiveWinPct'?'rbFiveMissPct':'rbFiveWinPct')).val(RabbitRulesMath.percentText(complement));}catch(e){}
            }
            if(cfg&&refresh(true))status('已修改 · 尚未保存');
        });
        $('#rabbitConfig').on('click','.rb-delete',function(){var tr=$(this).closest('tr'),table=tr.closest('table');if(table.find('tbody tr').length<=1){status('至少保留一个有效档位。',true);return;}if(table.is('#rbAuthTable')&&authMode==='probability')authPercentEdited=true;tr.remove();refresh(true);});
        window.rabbitConfigClear=function(){remember();++sequence;loading=false;active=null;cfg=null;loadFailed=false;$('#rabbitConfig').hide().find(':input').prop('disabled',true);if(!current())controls();};
        window.rabbitConfigLoad=function(){
            if(!current()){window.rabbitConfigClear();return;}$('#rabbitConfig').show();var target=key();
            if(active===target){controls();if(cfg)publish();else if(!loading&&!loadFailed)load();return;}
            remember();++sequence;loading=false;active=target;cfg=null;loadFailed=false;dropNew=false;
            if(drafts[target])restore(drafts[target]);else load();
        };
        window.rabbitConfigIsReady=function(){return !!cfg&&!loading&&active===key();};
        window.rabbitConfigReload=function(){if(current()&&!saving){delete drafts[key()];cfg=null;load();}};
        window.rabbitConfigCollect=function(){
            if(!current())return{};if(busy())throw new Error('本桌规则正在读取或保存，请稍后重试。');
            return{RabbitConfigJson:JSON.stringify(collect())};
        };
        window.rabbitConfigSetSaving=function(v){saving=v;controls();status(v?'正在保存本桌参数与玩法规则…':'保存未完成时可点击底部按钮重试。');};
        window.rabbitConfigSaved=function(json,id){
            var savedKey=String(id),data=JSON.parse(json);
            if(savedKey==='-1')delete drafts[savedKey];else drafts[savedKey]={cfg:data,dirty:false,source:'table'};
            if(active===savedKey&&key()===savedKey){cfg=data;dirty=false;source='table';dropNew=savedKey==='-1';publish();status('本桌参数与玩法规则已保存。');}
        };
        window.rabbitConfigReset=function(){
            if(!current()||busy())return;cfg=cfg?copy(cfg):copy(RABBIT_RULE_DEFAULTS);active=key();loadFailed=false;var defaults=copy(RABBIT_RULE_DEFAULTS);delete defaults.keepMax;delete defaults.keepMinHands;fill(cfg,defaults,true);render();controls();refresh(true);status('本桌已恢复默认 · 点击底部保存后生效。');
        };
        load.addRequested=new URLSearchParams(window.location.search).get('rabbitTier')==='auth';window.rabbitConfigLoad();
    });
})(jQuery);
