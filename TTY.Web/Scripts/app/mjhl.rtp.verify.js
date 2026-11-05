/* Natural RTP via independent ordinary spins, free-spin residuals and importance samples.
 * See Docs/麻将胡了RTP正式复核加速-20261105.md for the estimator and confidence calculation. */
(function(root,factory){var api=factory();if(typeof module==='object'&&module.exports)module.exports=api;else root.MjhlRtpVerify=api;
})(typeof self!=='undefined'?self:this,function(){
    'use strict';
    var METHOD='renewal-importance-v1';
    function merge(a,b){
        if(!a)return {count:b.count,mean:b.mean,m2:b.m2,meanGrants:b.meanGrants,m2Grants:b.m2Grants,cov:b.cov};
        var n=a.count+b.count,dx=b.mean-a.mean,dy=b.meanGrants-a.meanGrants,w=a.count*b.count/n;
        return {count:n,mean:a.mean+dx*b.count/n,meanGrants:a.meanGrants+dy*b.count/n,
            m2:a.m2+b.m2+dx*dx*w,m2Grants:a.m2Grants+b.m2Grants+dy*dy*w,cov:a.cov+b.cov+dx*dy*w};
    }
    function estimate(parts,z){
        var n=parts[0],f=parts[1],q=parts[2];
        if(!n||!f||!q||n.count<2||f.count<2||q.count<2)throw new Error('复核样本不完整。');
        var gap=1-f.meanGrants,grantError=z*Math.sqrt(f.m2Grants/(f.count-1)/f.count);
        if(gap<=grantError)return {reliable:false,reason:'免费再触发过高，无法确认免费链能够结束。'};
        var freeMean=f.mean+q.mean,u=freeMean/gap,v=n.meanGrants/gap,w=n.meanGrants*freeMean/(gap*gap);
        var vn=(n.m2+u*u*n.m2Grants+2*u*n.cov)/((n.count-1)*n.count);
        var vf=(v*v*f.m2+w*w*f.m2Grants+2*v*w*f.cov)/((f.count-1)*f.count);
        var vq=v*v*q.m2/((q.count-1)*q.count),variance=Math.max(0,vn+vf+vq),total=n.mean+n.meanGrants*u;
        if(!isFinite(total)||!isFinite(variance)||total<0)throw new Error('复核统计无效。');
        return {reliable:variance>0,total:total,normal:n.mean,free:n.meanGrants*u,half95:z*Math.sqrt(variance),varianceOfMean:variance};
    }
    function verify(engine,profile,opts,done){
        opts=opts||{};var errors=engine.validate(profile);
        if(errors.length){done(new Error(errors.join('\n')));return;}
        if(engine.proveZeroReturn(profile)){engine.verifyRtp(profile,opts,done);return;}
        if(typeof opts.sampleRunner!=='function'){done(new Error('未加载快速复核计算池。'));return;}
        var max=Math.min(50000000,Math.max(100,Math.floor(Number(opts.validationCount)||50000000)));
        if(max<750000){engine.verifyRtp(profile,opts,done);return;}
        // Five predeclared looks, with the same familywise Z correction as the full-round verifier.
        var limit=Math.floor(max/750000)*250000,checkpoints=[3000000,6000000,9000000,12000000,limit].filter(function(n,i,a){return n<=limit&&a.indexOf(n)===i;});
        checkpoints.sort(function(a,b){return a-b;});
        var looks=Math.max(checkpoints.length,Math.min(10,Math.floor(Number(opts.confidenceCheckCount)||checkpoints.length))),z=engine.verificationZ(looks);
        var seeds=[],used={},parts=[null,null,null],batches=[],index=0,draws=0,finished=false;
        // Streams for all three groups are fixed before observing any results and never overlap by seed.
        try { for(var i=0;i<3;i++){
            var words=i===0&&opts.validationSeed128?opts.validationSeed128.slice():engine.freshSeed128(),tries=0;
            while(used[words.join(',')]&&tries++<10)words=engine.freshSeed128();
            if(used[words.join(',')]){done(new Error('无法生成独立复核随机流。'));return;}
            engine.xoshiro128ss(words);used[words.join(',')]=true;seeds.push(words);
        } } catch(seedError){done(seedError);return;}
        function finish(error,result){if(!finished){finished=true;done(error,result);}}
        function cancelled(){return !!(opts.cancelled&&opts.cancelled());}
        function stop(){if(!cancelled())return false;var e=new Error('已取消计算，参数未修改。');e.code='MJHL_RTP_CANCELLED';finish(e);return true;}
        function group(kind){
            if(finished||stop())return;
            var previous=parts[kind]?parts[kind].count:0,count=checkpoints[index]-previous;
            opts.sampleRunner(profile,count,0,{component:kind,mergeStats:merge,sampleOffset:previous,
                validationSeed128:seeds[kind],validationCount:limit,cancelled:cancelled,
                onProgress:function(n){if(opts.onValidationProgress)opts.onValidationProgress(parts.reduce(function(sum,p){return sum+(p?p.count:0);},0)+n,max);}
            },function(error,part){
                if(finished||stop())return;if(error){finish(error);return;}
                if(!part||part.count!==count||!part.parallelBatches){finish(new Error('复核分片不完整。'));return;}
                parts[kind]=merge(parts[kind],part);draws+=part.parallelDraws;
                batches.push({component:kind,parts:part.parallelBatches});
                if(kind<2){group(kind+1);return;}
                var value;
                try{value=estimate(parts,z);}catch(e){finish(e);return;}
                var stats={total:value.total,normal:value.normal,free:value.free,half95:value.half95,
                    count:parts[0].count+parts[1].count+parts[2].count,method:METHOD,components:parts.map(function(p){return merge(null,p);}),
                    varianceOfMean:value.varianceOfMean,intervalZ:z,intervalReliable:!!value.reliable,unobservedReturn:!(value.total>0),trunc:0,freeLimited:0};
                var tolerance=(Number(opts.tolerancePercent)||1)/100,hasTarget=typeof opts.targetPercent==='number',target=Number(opts.targetPercent)/100;
                var reached=value.reliable&&value.half95<=tolerance;
                var targetReached=!hasTarget||(value.reliable&&Math.abs(value.total-target)+value.half95<=tolerance);
                var targetMiss=hasTarget&&value.reliable&&(value.total+value.half95<target-tolerance||value.total-value.half95>target+tolerance);
                var correction=!!opts.allowTargetCorrection&&hasTarget&&reached&&!targetReached&&value.half95<=tolerance*.8&&Math.abs(value.total-target)>tolerance*.25;
                if(opts.onCheckpoint&&value.reliable)opts.onCheckpoint(stats,reached&&targetReached);
                if(stop())return;
                index++;
                if((reached&&targetReached)||targetMiss||correction||index>=checkpoints.length){
                    if(!value.reliable){finish(new Error(value.reason||'复核尚未得到可靠误差，参数未修改。'));return;}
                    finish(null,{stats:stats,exact:false,precisionReached:reached,targetReached:hasTarget?targetReached:null,tolerancePercent:tolerance*100,
                        validationSeed128:seeds[0],validationSeeds:seeds,validationRng:METHOD,validationDraws:draws,validationBatches:batches,
                        plannedCheckpoints:checkpoints.map(function(n){return n*3;}),confidenceCheckCount:looks,targetMiss:targetMiss,needsCorrection:correction,stoppedEarly:(targetMiss||correction)&&index<checkpoints.length});
                }else setTimeout(function(){group(0);},0);
            });
        }
        group(0);
    }
    return {METHOD:METHOD,merge:merge,estimate:estimate,verify:verify};
});
