var MConfig = { isRMB: false, exchangeRate: 0 };
var M = {};
M.num = function (v) {
        var n = Number(v || 0);
        if (isNaN(n)) return '0';
        var neg = n < 0;
        var s = Math.abs(Math.round(n)).toString();
        return (neg ? '-' : '') + s;
    };

    /** 带符号显示（盈亏） */
    M.signed = function (v) {
        var n = Number(v || 0);
        return (n > 0 ? '+' : '') + M.num(n);
    };

    M.signClass = function (v) {
        var n = Number(v || 0);
        return n > 0 ? 'positive' : (n < 0 ? 'negative' : '');
    };

    /**
     * 金额显示，与后端 IsRMB/ExchangeRate 口径一致：
     * 真金版按兑换率折算成两位小数，否则原样显示；两种模式均不加逗号。
     */
    M.gold = function (v) {
        var n = Number(v || 0);
        if (isNaN(n)) return '0';
        if (MConfig.isRMB && MConfig.exchangeRate > 0) {
            var val = n / MConfig.exchangeRate;
            var fixed = Math.abs(val).toFixed(2);
            return (val < 0 ? '-' : '') + fixed;
        }
        return M.num(n);
    };

    /**
     * 0.1 分炮鱼机（内部单位 = 0.1 分，需 ÷10 后显示 1 位小数）。
     * 与电脑端 Areas/Game/Views/UserInfo/OnlineUsers.cshtml 的 isDecimalBetFish
     * 与 GameConfigController.IsDecimalBetFish 同口径，改一处必须同步另一处。
     */
    M.DECIMAL_BET_FISH_IDS = [3, 6, 13, 19, 21, 22, 32, 33, 42, 49, 51];

    M.isDecimalBetFish = function (gameId) {
        return M.DECIMAL_BET_FISH_IDS.indexOf(Number(gameId)) >= 0;
    };

    /**
     * 押注（当前压分）显示：0.1 分炮鱼机 ÷10 保留 1 位小数（0.1 分不能显示成 1），
     * 其余游戏按 M.gold 口径（真金版折算两位小数）。
     */
    M.betGold = function (v, gameId) {
        if (v === null || v === undefined) return '--';
        var n = Number(v);
        if (isNaN(n)) return '0';
        if (!M.isDecimalBetFish(gameId)) return M.gold(n);
        n = n / 10;
        if (MConfig.isRMB && MConfig.exchangeRate > 0) {
            var val = n / MConfig.exchangeRate;
            return (val < 0 ? '-' : '') + Math.abs(val).toFixed(2);
        }
        return (n < 0 ? '-' : '') + Math.abs(n).toFixed(1);
    };

    
function check(label, actual, expected){ console.log((String(actual)===String(expected) ? 'PASS' : 'FAIL') + ' ' + label + ' => ' + actual + ' (expect ' + expected + ')'); }
check('fish32 CurBet=1', M.betGold(1, 32), '0.1');
check('fish32 CurBet=5', M.betGold(5, 32), '0.5');
check('fish32 CurBet=123', M.betGold(123, 32), '12.3');
check('game10 CurBet=1', M.betGold(1, 10), '1');
check('game15 CurBet=30', M.betGold(30, 15), '30');
check('null', M.betGold(null, 32), '--');
check('zero', M.betGold(0, 32), '0.0');
console.log('isDecimalBetFish 32/33/40/51 = ' + [32,33,40,51].map(M.isDecimalBetFish).join(','));
MConfig.isRMB = true; MConfig.exchangeRate = 100;
check('RMB fish32 CurBet=500', M.betGold(500, 32), '0.50');
check('RMB gold 1000', M.gold(1000), '10.00');
