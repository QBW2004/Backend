(function (window, $, M) {
    'use strict';
    var account = (window.MPagePreset && window.MPagePreset.account) || '';
    var pageSize = 100;

    function esc(v) { return M.esc(v == null ? '--' : v); }
    function render(data) {
        if (data && data.notice) M.toast(data.notice, 'info');
        var rows = (data && data.rows) || [];
        var games = (data && data.games) || [];
        var byGame = {};
        rows.forEach(function (r) {
            var key = String(r.GameId);
            if (!byGame[key]) byGame[key] = [];
            byGame[key].push(r);
        });
        var totalCount = Number(data && data.total || 0);
        $('#prizeTotalCount').text(totalCount);
        $('#historySummary').text('共 ' + totalCount + ' 条中奖记录（鱼机/拉霸高倍率以触发中奖播报为准）');
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
                    '<td>' + esc(r.TableLabel || '--') + '</td>' +
                    '<td>' + (Number(r.IsManualControl) === 1 ? '是' : '否') + '</td>' +
                    '<td>' + esc(M.fmtTime(r.RecTime, true)) + '</td>' +
                    '</tr>';
            }).join('') : '<tr><td colspan="5" class="history-empty">暂无记录</td></tr>';
            return '<div class="game-card"><div class="game-card-header"><span>' + esc(g.Name || ('游戏' + g.GameId)) + '</span><span class="game-count">' + rs.length + '</span></div>' +
                '<div class="history-table-scroll"><table class="history-table"><thead><tr><th>牌型</th><th>得分</th><th>机台号</th><th>是否送奖</th><th>开奖时间</th></tr></thead><tbody>' + body + '</tbody></table></div></div>';
        }).join(''));
    }

    function fetchPage(page, start, end) {
        return M.post('/Game/UserRecord/GetPrizeHistory', {
            ID: account,
            StartTime: start,
            EndTime: end,
            page: page,
            rows: pageSize
        });
    }

    function fetchRemaining(page, data, start, end) {
        var totalPages = Math.ceil(data.total / pageSize);
        if (page > totalPages || data.rows.length >= data.total) return $.Deferred().resolve(data).promise();
        return fetchPage(page, start, end).then(function (next) {
            var nextRows = (next && next.rows) || [];
            if (!nextRows.length) {
                data.total = data.rows.length;
                return data;
            }
            Array.prototype.push.apply(data.rows, nextRows);
            return fetchRemaining(page + 1, data, start, end);
        });
    }

    function load() {
        if (!account) { M.toast('缺少玩家账号参数', 'error'); return; }
        var start = $('#historyStart').val();
        var end = $('#historyEnd').val();
        M.loading('查询中...');
        return fetchPage(1, start, end).then(function (first) {
            var data = {
                total: Number(first && first.total || 0),
                rows: ((first && first.rows) || []).slice(),
                games: (first && first.games) || [],
                notice: first && first.notice
            };
            return fetchRemaining(2, data, start, end);
        }).always(M.hideLoading).then(render);
    }

    function init() {
        $('#historyQueryBtn').on('click', load);
        M.onRefresh(function () { M.runRefresh(load); });
        load();
    }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init); else init();
})(window, jQuery, window.MApp);
