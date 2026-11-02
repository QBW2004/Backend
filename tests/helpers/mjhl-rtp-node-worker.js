'use strict';
// 本地测试适配器：实际运行 worker_threads，子线程直接 require 同一业务引擎，避免 vm 上下文扭曲性能。
// 只适配本项目 sample worker 的 importScripts，不访问网络、数据库或正式环境。
const path = require('node:path');
const { Worker: ThreadWorker } = require('node:worker_threads');
const enginePath = path.resolve(__dirname, '../../TTY.Web/Scripts/app/mjhl.engine.js');
const poolPath = path.resolve(__dirname, '../../TTY.Web/Scripts/app/mjhl.rtp.pool.js');
const sampleWorkerPath = path.resolve(__dirname, '../../TTY.Web/Scripts/app/mjhl.rtp.sample.worker.js');
class BrowserWorker {
    constructor(url) {
        const workerFile = path.resolve(String(url).split('?')[0]);
        this.onmessage = null;
        this.onerror = null;
        this.thread = new ThreadWorker(`
            const {parentPort,workerData}=require('node:worker_threads');
            const path=require('node:path');
            global.self=global;
            global.postMessage=value=>parentPort.postMessage(value);
            global.importScripts=function(){
                for(const url of arguments){
                    const file=path.resolve(path.dirname(workerData.file),String(url).split('?')[0]);
                    if(path.basename(file)!=='mjhl.engine.js') throw new Error('测试适配器只允许加载同目录麻将引擎');
                    global.MjhlEngine=require(file);
                }
            };
            require(workerData.file);
            parentPort.on('message',data=>{if(typeof global.onmessage==='function')global.onmessage({data});});
        `, { eval: true, workerData: { file: workerFile } });
        this.thread.on('message', data => { if (this.onmessage) this.onmessage({ data }); });
        this.thread.on('error', error => { if (this.onerror) this.onerror({ message: error.message, error, preventDefault() {} }); });
    }
    postMessage(value) { this.thread.postMessage(value); }
    terminate() { return this.thread.terminate(); }
}
function createPool(options) {
    return require(poolPath).create(Object.assign({ engine: require(enginePath), maxWorkers: 4,
        hardwareConcurrency: 4, workerUrl: sampleWorkerPath, workerFactory: url => new BrowserWorker(url) }, options || {}));
}
module.exports = { BrowserWorker, createPool, enginePath, poolPath, sampleWorkerPath };
