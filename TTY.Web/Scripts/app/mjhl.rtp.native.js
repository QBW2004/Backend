/* Same-rule sampling kernel. The generated module is built from Tools/dev/mjhl-rtp-native/engine.c. */
(function(root,factory){
    var api=factory();if(typeof module==='object'&&module.exports)module.exports=api;else root.MjhlRtpNative=api;
})(typeof self!=='undefined'?self:this,function(){
    'use strict';
    function create(engine,encoded){
        if(typeof WebAssembly!=='object')throw new Error('当前浏览器不支持快速复核。');
        var raw=typeof atob==='function'?atob(encoded):Buffer.from(encoded,'base64').toString('binary');
        var bytes=new Uint8Array(raw.length);for(var i=0;i<raw.length;i++)bytes[i]=raw.charCodeAt(i);
        var wasm=new WebAssembly.Instance(new WebAssembly.Module(bytes)).exports,busy=false;
        function sample(profile,count,seed128,opts,done){
            opts=opts||{};
            if(busy){done(new Error('计算核心正在使用。'));return;}
            try{
                if(!Number.isSafeInteger(count)||count<1||count>50000000)throw new Error('样本数无效。');
                var component=typeof opts.component==='number';
                if(component&&(!Number.isInteger(opts.component)||opts.component<0||opts.component>2))throw new Error('复核分组无效。');
                engine.xoshiro128ss(seed128);
                var compiled=engine.compile(profile),input=new Int32Array(wasm.memory.buffer,wasm.config_ptr(),123);
                for(var m=0;m<2;m++)for(var s=0;s<12;s++)for(var col=0;col<5;col++)input[(m*12+s)*5+col]=compiled.eff[m][s][col];
                input[120]=Number(profile.weightTotal);input[121]=0;
                for(s=0;s<9;s++)if(profile.enabled[s])input[121]|=1<<s;
                input[122]=Math.round(Number(profile.goldChance)*100);
                if(wasm.configure())throw new Error('快速复核参数无效。');
                wasm.reset(seed128[0],seed128[1],seed128[2],seed128[3]);
            }catch(e){done(e);return;}
            busy=true;var completed=0;
            function finish(error,result){busy=false;done(error,result);}
            function step(){
                if(opts.cancelled&&opts.cancelled()){finish(new Error('已停止计算。'));return;}
                try{
                    var amount=Math.min(50000,count-completed);
                    if(component?wasm.sample_spins(amount,opts.component):wasm.sample(amount))throw new engine.GenerationLimitError();
                    completed+=amount;if(opts.onProgress)opts.onProgress(completed,count);
                    if(completed<count){setTimeout(step,0);return;}
                    var a=new Float64Array(wasm.memory.buffer,wasm.stats_ptr(),18),stats;
                    if(component)stats={count:a[0],mean:a[6],m2:a[7],meanGrants:a[8],m2Grants:a[9],cov:a[10]};
                    else{
                        var distribution={zero:a[8],small:a[9],medium:a[10],big:a[11],mega:a[12],super:a[13]};
                        stats={count:a[0],normal:a[1]/count,free:a[2]/count,total:(a[1]+a[2])/count,hit:a[3]/count,miss:1-a[3]/count,
                            scatter:a[4]/count,cap:a[5]/count,mean:a[6],m2:a[7],half95:count>1?1.96*Math.sqrt(a[7]/(count-1)/count):0,
                            distribution:distribution,roundHit:1-distribution.zero/count,trunc:0,freeLimited:0,intervalReliable:a[7]>0,unobservedReturn:distribution.zero===count};
                    }
                    stats.nativeDraws=a[17];finish(null,stats);
                }catch(e){finish(e);}
            }
            step();
        }
        return {sample:sample};
    }
    return {create:create};
});
