(function(root){
    'use strict';
    function integer(value,min,max,label){
        if(!Number.isSafeInteger(value)||value<min||value>max)throw new Error(label+'须为 '+min+'～'+max+' 的整数。');
        return value;
    }
    function weighted(data,max){
        if(!data||!Array.isArray(data.values)||!Array.isArray(data.weights)||!data.values.length||data.values.length>max||data.values.length!==data.weights.length)throw new Error('权重档位不完整。');
        var sum=0,total=0,seen={};
        data.values.forEach(function(v,i){
            integer(v,1,max,'档位');integer(data.weights[i],0,2147483647,'权重');
            if(seen[v])throw new Error('档位不能重复。');seen[v]=true;sum+=data.weights[i];total+=v*data.weights[i];
        });
        integer(sum,1,2147483647,'权重合计');
        return{sum:sum,average:total/sum,probabilities:data.weights.map(function(w){return w/sum;})};
    }
    function chance(c){
        if(!c)throw new Error('概率未填写。');integer(c.denominator,1,2147483647,'概率分母');integer(c.numerator,0,c.denominator,'概率分子');
        return c.numerator/c.denominator;
    }
    var percentTotal=100000000;
    function gcd(a,b){while(b){var r=a%b;a=b;b=r;}return a;}
    function percentUnits(text){
        var raw=String(text).trim();
        if(!/^(?:\d+(?:\.\d{0,6})?|\.\d{1,6})$/.test(raw))throw new Error('概率须为 0～100%，最多六位小数。');
        var value=Number(raw);if(value<0||value>100)throw new Error('概率须在 0～100% 之间。');
        return Math.round(value*1000000);
    }
    function percentText(units){return(units/1000000).toFixed(6).replace(/\.?0+$/,'')||'0';}
    function splitWeights(win,miss){
        integer(win,0,2147483647,'中赠权重');integer(miss,0,2147483647,'落空权重');
        integer(win+miss,1,2147483647,'中赠与落空权重合计');
        var divisor=gcd(win,miss);return{numerator:win/divisor,denominator:(win+miss)/divisor};
    }
    function weightsFromPercentages(values){
        var units=values.map(percentUnits),sum=units.reduce(function(a,b){return a+b;},0);
        if(sum!==percentTotal)throw new Error('概率合计须为 100%，当前为 '+percentText(sum)+'%。');
        var divisor=units.reduce(gcd,0);return units.map(function(v){return v/divisor;});
    }
    function percentagesFromWeights(weights){
        var sum=weights.reduce(function(a,b){return a+b;},0);
        integer(sum,1,2147483647,'权重合计');weights.forEach(function(v){integer(v,0,2147483647,'权重');});
        var exact=weights.map(function(w){return w/sum*percentTotal;}),units=exact.map(Math.floor),left=percentTotal-units.reduce(function(a,b){return a+b;},0);
        var order=exact.map(function(v,i){return{i:i,remainder:v-units[i]};}).sort(function(a,b){return b.remainder-a.remainder||a.i-b.i;});
        for(var j=0;j<left;j++)units[order[j].i]++;
        return units.map(percentText);
    }
    function model(c){
        var s=c.specialRules,a=s.authentic,f=s.five,t=s.streak;
        var auth=weighted(a.multipliers,14),streak=weighted(t.awardCounts,255),p=chance(f.successChance);
        integer(c.smallFourMultiplier,1,2147483647,'小四梅倍率');integer(a.baseMultiplier,1,2147483647,'正宗基础倍率');integer(f.baseMultiplier,1,2147483647,'五枚基础倍率');
        integer(f.missMultiplier,1,255,'落空倍数');integer(f.successMultiplier,f.missMultiplier,255,'中赠倍数');
        return{auth:auth,streak:streak,fiveChance:p,
            small:c.smallFourMultiplier,authBase:a.baseMultiplier,fiveBase:f.baseMultiplier,
            authentic:a.baseMultiplier*(a.enabled?auth.average:1),
            five:f.baseMultiplier*(f.enabled?p*f.successMultiplier+(1-p)*f.missMultiplier:1)};
    }
    var api={weighted:weighted,chance:chance,model:model,percentUnits:percentUnits,percentText:percentText,splitWeights:splitWeights,weightsFromPercentages:weightsFromPercentages,percentagesFromWeights:percentagesFromWeights};root.RabbitRulesMath=api;
    if(typeof module==='object'&&module.exports)module.exports=api;
})(typeof window==='object'?window:globalThis);
