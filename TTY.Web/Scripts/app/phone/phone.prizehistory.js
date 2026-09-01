(function (window, $, M) {
    'use strict';
    var account = (window.MPagePreset && window.MPagePreset.account) || '';
    var pageIndex = 1;
    var pageSize = 100;
    var totalCount = 0;

    function esc(v) { return M.esc(v == null ? '--' : v); }
    function render(data) {
        var rows = (data && data.rows) || [];
        var games = (data && data.games) || [];
        var byGame = {};
        rows.forEach(function (r) {
            var key = String(r.GameId);
            if (!byGame[key]) byGame[key] = [];
            byGame[key].push(r);
        });
        totalCount = Number(data && data.total || 0);
        var totalPages = Math.max(1, Math.ceil(totalCount / pageSize));
        $('#historySummary').text('共 ' + totalCount + ' 条中奖记录（鱼机/拉霸高倍率以触发中奖播报为准）');
        $('#historyPageInfo').text('第 ' + pageIndex + ' 页 / 共 ' + totalPages + ' 页');
        $('#historyPrevBtn').prop('disabled', pageIndex <= 1);
        $('#historyNextBtn').prop('disabled', pageIndex >= totalPages);
        if (!games.length) {
            $('#prizeHistoryList').html('<div class="history-empty">暂无已启用的非押注游戏</div>');
            return;
        }
        $('#prizeHistoryList').html(games.map(function (g) {
            var rs = byGame[String(g.GameId)] || [];
            var body = rs.length ? rs.map(function (r) {
                var score = Number(r.Score || 0);
                return '<tr>' +
                    '<td>' + esc(r.CardType || '--') + '</td>' +
                    '<td class="' + (score >= 0 ? 'positive' : 'negative') + '">' + (score > 0 ? '+' : '') + M.gold(score) + '</td>' +
                    '<td>' + esc(r.RoomId || '--') + '</td>' +
                    '<td>' + (Number(r.IsManualControl) === 1 ? '是' : '否') + '</td>' +
                    '<td>' + esc(M.fmtTime(r.RecTime, true)) + '</td>' +
                    '</tr>';
            }).join('') : '<tr><td colspan="5" class="history-empty">暂无记录</td></tr>';
            return '<div class="game-card"><div class="game-card-header"><span>' + esc(g.Name || ('游戏' + g.GameId)) + '</span><span class="game-count">' + rs.length + '</span></div>' +
                '<table class="history-table"><thead><tr><th>牌型</th><th>得分</th><th>场次</th><th>是否送奖</th><th>开奖时间</th></tr></thead><tbody>' + body + '</tbody></table></div>';
        }).join(''));
    }

    function load(page) {
        if (!account) { M.toast('缺少玩家账号参数', 'error'); return; }
        pageIndex = Math.max(1, Number(page || 1));
        M.loading('查询中...');
        return M.post('/Game/UserRecord/GetPrizeHistory', {
            ID: account,
            StartTime: $('#historyStart').val(),
            EndTime: $('#historyEnd').val(),
            page: pageIndex,
            rows: pageSize
        }).always(M.hideLoading).then(render);
    }

    function init() {
        $('#historyQueryBtn').on('click', function () { load(1); });
        $('#historyPrevBtn').on('click', function () { if (pageIndex > 1) load(pageIndex - 1); });
        $('#historyNextBtn').on('click', function () {
            if (pageIndex < Math.ceil(totalCount / pageSize)) load(pageIndex + 1);
        });
        M.onRefresh(function () { M.runRefresh(function () { return load(pageIndex); }); });
        load(1);
    }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init); else init();
})(window, jQuery, window.MApp);
