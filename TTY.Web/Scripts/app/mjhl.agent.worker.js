importScripts('mjhl.engine.js', 'mjhl.agent.simulation.js');
self.onmessage = function (event) {
    MjhlAgentSimulation.run(event.data, function (progress) { self.postMessage({ progress: progress }); })
        .then(function (result) { self.postMessage({ result: result }); })
        .catch(function (error) { self.postMessage({ error: error.message, code: error.code || 'MJHL_COMPUTATION_FAILED' }); });
};
