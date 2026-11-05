'use strict';
// Independently enumerate all 900 proposal paths, rather than reusing the C factorization.
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path'),Module=require('node:module');
const E=require('../TTY.Web/Scripts/app/mjhl.engine.js'),D=4294967296;
(async()=>{
    const {instance}=await WebAssembly.instantiate(fs.readFileSync(path.join(__dirname,'../.build/mjhl-rtp-native/engine-audit.wasm'))),w=instance.exports;
    const rng=E.mulberry32(234789),profiles=[E.defaults()];
    const rare=E.defaults();for(const mode of ['n','f'])for(let s=0;s<9;s++)rare.weights[mode][s]=[1,1,1,1,1];profiles.push(rare);
    const disabled=E.defaults();disabled.enabled[1]=false;disabled.weights.f[9].fill(0);profiles.push(disabled);
    let boards=0;
    for(const p of profiles){
        const c=E.compile(p),input=new Int32Array(w.memory.buffer,w.config_ptr(),123);
        for(let m=0;m<2;m++)for(let s=0;s<12;s++)for(let col=0;col<5;col++)input[(m*12+s)*5+col]=c.eff[m][s][col];
        input[120]=p.weightTotal;input[121]=p.enabled.slice(0,9).reduce((mask,on,i)=>mask|(on?1<<i:0),0);input[122]=Math.round(p.goldChance*100);assert.equal(w.configure(),0);
        const probs=Array.from({length:3},(_,col)=>{let used=0;return Array.from({length:12},(_,s)=>{const before=Math.ceil(used*D/p.weightTotal);used+=c.eff[1][s][col];return (Math.ceil(used*D/p.weightTotal)-before)/D;});});
        for(let col=0;col<3;col++)for(let s=0;s<12;s++)assert.equal(w.audit_probability(col,s),probs[col][s]);
        const mass=Array.from({length:9},(_,s)=>100*probs[0][s]*(probs[1][s]+probs[1][9])*(probs[2][s]+probs[2][9]));
        const total=mass.reduce((a,b)=>a+b,0);let cumulative=0,previous=0;
        const qs=mass.map(v=>{cumulative+=v;const cut=total?Math.min(D,Math.ceil(cumulative/total*D)):0;const q=(cut-previous)/D;previous=cut;return q;});
        const qc=probs.map(row=>row.slice(0,9).map(v=>(v+row[9])?Math.ceil(v/(v+row[9])*D)/D:0));
        for(let s=0;s<9;s++){assert(Math.abs(qs[s]-w.audit_symbol_q(s))<1e-14);for(let col=0;col<3;col++)assert.equal(qc[col][s],w.audit_conditional_q(col,s));}
        const qp=[4,5,5].map(n=>Array.from({length:n},(_,i)=>(Math.ceil((i+1)*D/n)-Math.ceil(i*D/n))/D));
        const grid=new Int32Array(w.memory.buffer,w.audit_grid_ptr(),60);
        for(let run=0;run<80;run++){
            grid.fill(-2);for(let col=0;col<3;col++)for(let j=0;j<E.LOGICAL[col];j++){
                const choices=col===0?[-2,1,3,5,9]:col===1?[-2,1,3,5,9,20,101,103]:[-2,101,103,105,109,20];grid[col*12+E.BUF_TOP[col]+j]=choices[Math.floor(rng()*choices.length)];
            }
            const ratio=(s,col,j)=>{let cell=grid[col*12+E.BUF_TOP[col]+j];if(cell>=100)cell-=100;
                return cell===s+1&&probs[col][s]>0?qc[col][s]/probs[col][s]:cell===20&&probs[col][9]>0?(1-qc[col][s])/probs[col][9]:0;};
            let enumerated=0;
            for(let s=0;s<9;s++)for(let a=0;a<4;a++)for(let b=0;b<5;b++)for(let d=0;d<5;d++)enumerated+=qs[s]*qp[0][a]*qp[1][b]*qp[2][d]*ratio(s,0,a)*ratio(s,1,b)*ratio(s,2,d);
            const actual=w.audit_density();assert(Math.abs(actual-enumerated)<=1e-11*Math.max(1,Math.abs(enumerated)));boards++;
        }
    }
    // A real paid path that is created by blank substitution must remain in the residual.
    const p=E.defaults(),c=E.compile(p),grid=E.COL_LEN.map(n=>Array(n).fill(-2));grid[1][6]=20;grid[2][6]=20;
    const source=fs.readFileSync(path.join(__dirname,'../TTY.Web/Scripts/app/mjhl.engine.js'),'utf8'),m=new Module('mjhl-audit',module);
    m._compile(source.replace('blankWeights: blankWeights,','_substitute:substitute,blankWeights: blankWeights,'),'mjhl-audit');
    m.exports._substitute(c,()=>0,true,grid);assert(E.spinGrid(c,()=>0,200,true,20000000,grid,false).totalWin>0);
    console.log(JSON.stringify({pass:'exact integer probabilities, independently enumerated Q/P, blank-substitution residual',boards,paths:boards*900}));
})().catch(e=>{console.error(e);process.exitCode=1;});
