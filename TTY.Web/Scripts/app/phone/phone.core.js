/* ============================================================
   手机端后台运行时（1:1 复刻参考站点交互）
   依赖：jQuery + phone.css
   约定：
     - 所有数据接口均为 POST，返回 Msg{code,content,datas}
       或 EasyUI 形状 {total,rows}；code == 1 表示成功。
     - 登录超时返回 code == -1，统一跳转手机登录页 /Mobile/Login。
     - 页面级配置由 _MobileLayout.cshtml 注入到 window.MConfig。
     - 页面通过 M.onRefresh(fn) / M.onSearch(fn) 注册头部按钮行为。
   ============================================================ */
(function (window, $) {
    'use strict';

    var MConfig = window.MConfig = window.MConfig || {};
    MConfig.user = MConfig.user || {};
    MConfig.perms = MConfig.perms || {};

    var M = {};

    /* ---------------- 图标 ---------------- */
    M.ICONS = {
        menu: '<svg viewBox="0 0 24 24" width="24" height="24"><path d="M3 18h18v-2H3v2zm0-5h18v-2H3v2zm0-7v2h18V6H3z"/></svg>',
        back: '<svg viewBox="0 0 24 24" width="24" height="24"><path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z"/></svg>',
        refresh: '<svg viewBox="0 0 24 24" width="24" height="24"><path d="M12 4V1L8 5l4 4V6c3.31 0 6 2.69 6 6 0 1.01-.25 1.97-.7 2.8l1.46 1.46C19.54 15.03 20 13.57 20 12c0-4.42-3.58-8-8-8zm0 14c-3.31 0-6-2.69-6-6 0-1.01.25-1.97.7-2.8L5.24 7.74C4.46 8.97 4 10.43 4 12c0 4.42 3.58 8 8 8v3l4-4-4-4v3z"/></svg>',
        search: '<svg viewBox="0 0 24 24" width="24" height="24"><path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>',
        close: '<svg viewBox="0 0 24 24" width="24" height="24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z" fill="currentColor"/></svg>',
        avatar: '<svg viewBox="0 0 24 24" width="40" height="40"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 3c1.66 0 3 1.34 3 3s-1.34 3-3 3-3-1.34-3-3 1.34-3 3-3zm0 14.2c-2.5 0-4.71-1.28-6-3.22.03-1.99 4-3.08 6-3.08 1.99 0 5.97 1.09 6 3.08-1.29 1.94-3.5 3.22-6 3.22z" fill="#007aff"/></svg>',
        clock: '<svg viewBox="0 0 24 24" width="16" height="16" fill="#007aff"><path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8z"/><path d="M12.5 7H11v6l5.25 3.15.75-1.23-4.5-2.67z"/></svg>',
        check: '<svg viewBox="0 0 24 24" width="48" height="48"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z" fill="#34c759"/></svg>',
        error: '<svg viewBox="0 0 24 24" width="48" height="48"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z" fill="#ff3b30"/></svg>',
        lock: '<svg viewBox="0 0 24 24" width="20" height="20"><path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zM9 6c0-1.66 1.34-3 3-3s3 1.34 3 3v2H9V6zm9 14H6V10h12v10zm-6-3c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2z"/></svg>',
        kick: '<svg viewBox="0 0 24 24" width="20" height="20"><path d="M20 17.17L18.83 16H4V4h16v13.17zM20 2H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h14l4 4V4c0-1.1-.9-2-2-2z"/></svg>',
        logout: '<svg viewBox="0 0 24 24" width="20" height="20"><path d="M17 7l-1.41 1.41L18.17 11H8v2h10.17l-2.58 2.58L17 17l5-5zM4 5h8V3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h8v-2H4V5z"/></svg>',
        shield: '<svg viewBox="0 0 24 24" width="20" height="20"><path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4z"/></svg>'
    };

    /* ---------------- 基础工具 ---------------- */

    /** HTML 转义，所有拼接进 innerHTML 的动态文本都必须过一遍 */
    M.esc = function (v) {
        if (v === null || v === undefined) return '';
        return String(v)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    };

    /** 千分位整数 */
    M.num = function (v) {
        var n = Number(v || 0);
        if (isNaN(n)) return '0';
        var neg = n < 0;
        var s = Math.abs(Math.round(n)).toString();
        s = s.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
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
     * 真金版按兑换率折算成两位小数，否则原样千分位。
     */
    M.gold = function (v) {
        var n = Number(v || 0);
        if (isNaN(n)) return '0';
        if (MConfig.isRMB && MConfig.exchangeRate > 0) {
            var val = n / MConfig.exchangeRate;
            var fixed = Math.abs(val).toFixed(2);
            var parts = fixed.split('.');
            parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');
            return (val < 0 ? '-' : '') + parts.join('.');
        }
        return M.num(n);
    };

    M.pad2 = function (n) {
        return (n < 10 ? '0' : '') + n;
    };

    /** .NET JSON 日期 /Date(1234)/ 或 ISO 字符串 -> yyyy-MM-dd HH:mm */
    M.fmtTime = function (v, withSec) {
        if (!v) return '--';
        var d = null;
        if (typeof v === 'string') {
            var mm = /\/Date\((-?\d+)\)\//.exec(v);
            if (mm) {
                d = new Date(parseInt(mm[1], 10));
            } else if (/^\d{4}-\d{2}-\d{2}/.test(v)) {
                return withSec ? v.substring(0, 19).replace('T', ' ') : v.substring(0, 16).replace('T', ' ');
            } else {
                d = new Date(v);
            }
        } else if (typeof v === 'number') {
            d = new Date(v < 1e12 ? v * 1000 : v);
        } else if (v instanceof Date) {
            d = v;
        }
        if (!d || isNaN(d.getTime())) return '--';
        var s = d.getFullYear() + '-' + M.pad2(d.getMonth() + 1) + '-' + M.pad2(d.getDate()) +
            ' ' + M.pad2(d.getHours()) + ':' + M.pad2(d.getMinutes());
        if (withSec) s += ':' + M.pad2(d.getSeconds());
        return s;
    };

    M.debounce = function (fn, wait) {
        var timer = null;
        return function () {
            var ctx = this, args = arguments;
            if (timer) clearTimeout(timer);
            timer = setTimeout(function () { fn.apply(ctx, args); }, wait || 300);
        };
    };

    /** 代理层级 -> 中文 */
    M.privName = function (priv) {
        var p = Number(priv);
        if (p === 0) return '管理员';
        if (p === 9) return '副管理';
        if (p === 10) return '运营';
        if (p > 0) return p + '级代理';
        return '--';
    };

    /* ---------------- 请求 ---------------- */

    M.toLogin = function () {
        window.location.href = '/Login/Mobile';
    };

    /** 防伪令牌：由布局页的隐藏 @Html.AntiForgeryToken() 提供，惰性读取 */
    M.token = function () {
        if (!MConfig.token) {
            MConfig.token = $('input[name="__RequestVerificationToken"]').first().val() || '';
        }
        return MConfig.token;
    };

    /**
     * 统一 POST 请求。自动附带防伪令牌；登录超时统一跳转手机登录页。
     * @param {String} url 接口地址
     * @param {Object} data 表单数据
     * @param {Object} [opts] 可选项：{ timeoutMs: 12000 } 请求超时
     * @returns jQuery Promise，resolve 的是后端原始 JSON
     */
    M.post = function (url, data, opts) {
        var payload = $.extend({}, data || {});
        var token = M.token();
        if (token) {
            payload.__RequestVerificationToken = token;
        }
        var ajaxOptions = {
            url: url,
            type: 'POST',
            data: payload,
            dataType: 'json',
            cache: false
        };
        if (opts && opts.timeoutMs) {
            ajaxOptions.timeout = opts.timeoutMs;
        }
        return $.ajax(ajaxOptions).then(function (res) {
            if (res && Number(res.code) === -1) {
                M.toast('登录超时，请重新登录', 'error');
                setTimeout(M.toLogin, 1200);
                return $.Deferred().reject('login-timeout').promise();
            }
            return res;
        }, function (xhr, status) {
            if (status !== 'abort') {
                M.toast('网络异常，请稍后重试', 'error');
            }
            return $.Deferred().reject(status).promise();
        });
    };

    M.get = function (url, data) {
        return $.ajax({ url: url, type: 'GET', data: data || {}, dataType: 'json', cache: false });
    };

    /** 归一化后端返回的提示信息：Msg{code,content} 与 {code,msg} 两种形状 */
    M.result = function (res) {
        if (!res) return { ok: false, text: '操作失败' };
        var ok = Number(res.code) === 1;
        var text = res.content || res.msg || (ok ? '操作成功' : '操作失败');
        return { ok: ok, text: text, datas: res.datas };
    };

    /* ---------------- Loading ---------------- */

    M.loading = function (text) {
        var $el = $('#mLoading');
        if (!$el.length) return;
        $el.text(text || '处理中...');
        $el.addClass('show');
    };

    M.hideLoading = function () {
        $('#mLoading').removeClass('show');
    };

    /* ---------------- Toast ---------------- */

    M.toast = function (msg, type, duration) {
        var $box = $('#mToast');
        if (!$box.length) return;
        var icon = '';
        if (type === 'success') icon = M.ICONS.check;
        else if (type === 'error') icon = M.ICONS.error;
        var $t = $('<div class="m-toast' + (type ? ' ' + type : '') + '"></div>');
        $t.html('<span class="m-toast-icon">' + icon + '</span><span>' + M.esc(msg) + '</span>');
        $t.find('svg').attr({ width: 18, height: 18 });
        $box.append($t);
        setTimeout(function () {
            $t.addClass('fade-out');
            setTimeout(function () { $t.remove(); }, 260);
        }, duration || 2400);
    };

    /* ---------------- 弹窗（参考站 modal-overlay 结构） ---------------- */

    /**
     * 通用弹窗。
     * @param {Object} o
     *   title, subtitle, bodyHTML
     *   actions: [{label, type, value}]  竖排大按钮（.modal-action-btn）
     *   buttons: [{label, type, value}]  底部按钮（.modal-btn.confirm）
     *   onRender($modal): 弹窗渲染后回调
     *   beforeClose(value, $modal): 返回 false 可阻止关闭（用于表单校验）
     * @returns jQuery Promise，resolve 点击的 value（遮罩点击为 null）
     */
    M.modal = function (o) {
        o = o || {};
        var dfd = $.Deferred();
        var $overlay = $('<div class="modal-overlay"></div>');
        var $modal = $('<div class="modal-content"></div>');

        if (o.title || o.subtitle) {
            var head = '<div class="modal-header"><div class="modal-title">' + M.esc(o.title || '') + '</div>';
            if (o.subtitle) head += '<div class="modal-subtitle">' + M.esc(o.subtitle) + '</div>';
            head += '</div>';
            $modal.append(head);
        }
        if (o.bodyHTML != null) {
            $modal.append($('<div class="modal-body"></div>').html(o.bodyHTML));
        }

        var settled = false;
        function close(value) {
            if (settled) return;
            if (o.beforeClose && o.beforeClose(value, $modal) === false) return;
            settled = true;
            $overlay.removeClass('show');
            setTimeout(function () { $overlay.remove(); }, 100);
            dfd.resolve(value);
        }

        if (o.actions && o.actions.length) {
            var $acts = $('<div class="modal-actions"></div>');
            $.each(o.actions, function (i, a) {
                var $b = $('<button type="button" class="modal-action-btn ' + (a.type || '') + '"></button>');
                $b.text(a.label);
                $b.on('click', function () { close(a.value); });
                $acts.append($b);
            });
            $modal.append($acts);
        }

        var buttons = o.buttons || [{ label: '关闭', value: null, type: 'confirm' }];
        var $foot = $('<div class="modal-footer"></div>');
        $.each(buttons, function (i, b) {
            var $b = $('<button type="button" class="modal-btn ' + (b.type || '') + '"></button>');
            $b.text(b.label);
            $b.on('click', function () { close(b.value); });
            $foot.append($b);
        });
        $modal.append($foot);

        $overlay.append($modal);
        $overlay.on('click', function (e) {
            if (e.target === $overlay[0]) close(null);
        });
        $('body').append($overlay);
        $overlay.addClass('show');

        if (o.onRender) o.onRender($modal);

        var promise = dfd.promise();
        promise.close = close;
        promise.$modal = $modal;
        return promise;
    };

    /** 确认框 */
    M.confirm = function (message, title) {
        return M.modal({
            title: title || '提示',
            bodyHTML: '<div class="modal-message">' + M.esc(message) + '</div>',
            buttons: [
                { label: '取消', value: false },
                { label: '确定', value: true, type: 'confirm' }
            ]
        }).then(function (v) {
            return v === true;
        });
    };

    /** 结果提示弹窗（操作成功/失败，图标 + 文案 + 确定） */
    M.alert = function (message, success, title) {
        var icon = success ? M.ICONS.check : M.ICONS.error;
        return M.modal({
            title: title || (success ? '操作成功' : '操作失败'),
            bodyHTML: '<div class="modal-icon ' + (success ? 'success' : 'error') + '">' + icon + '</div>' +
                '<div class="modal-message">' + M.esc(message) + '</div>',
            buttons: [{ label: '确定', value: true, type: 'confirm' }]
        });
    };

    /**
     * 带输入框的弹窗。
     * @param {Object} o title, label, placeholder, type(text/password/number), value, confirmText, emptyMsg
     * @returns Promise，resolve 输入值；取消为 null
     */
    M.promptInput = function (o) {
        o = o || {};
        var id = 'mPrompt' + Date.now();
        var body = '<div style="width:100%;">';
        if (o.label) body += '<label style="display:block;font-size:14px;font-weight:500;margin-bottom:8px;color:#333;">' + M.esc(o.label) + '</label>';
        body += '<input type="' + (o.type || 'text') + '" class="input-field" id="' + id + '"' +
            ' placeholder="' + M.esc(o.placeholder || '') + '" value="' + M.esc(o.value || '') + '" autocomplete="off">';
        body += '</div>';

        var dlg = M.modal({
            title: o.title,
            bodyHTML: body,
            buttons: [
                { label: '取消', value: null },
                { label: o.confirmText || '确定', value: 'ok', type: 'confirm' }
            ],
            beforeClose: function (value, $modal) {
                if (value !== 'ok') return true;
                var v = $.trim($modal.find('#' + id).val());
                if (!v) {
                    M.toast(o.emptyMsg || '请输入内容', 'error');
                    return false;
                }
                return true;
            },
            onRender: function ($modal) {
                setTimeout(function () { $modal.find('#' + id).focus(); }, 120);
            }
        });

        var $input = dlg.$modal.find('#' + id);
        return dlg.then(function (v) {
            return v === 'ok' ? $.trim($input.val()) : null;
        });
    };

    /* ---------------- 抽屉 ---------------- */

    M.openDrawer = function () {
        $('#sidebar').addClass('active');
        $('#sidebarOverlay').addClass('active');
    };

    M.closeDrawer = function () {
        $('#sidebar').removeClass('active');
        $('#sidebarOverlay').removeClass('active');
    };

    /* ---------------- 头部按钮注册 ---------------- */

    var refreshHandler = null;
    var searchHandler = null;

    /** 注册头部刷新按钮行为 */
    M.onRefresh = function (fn) { refreshHandler = fn; };

    /** 注册头部搜索按钮行为 */
    M.onSearch = function (fn) { searchHandler = fn; };

    M.spinRefresh = function (on) {
        $('#refreshBtn').toggleClass('spin', !!on);
    };

    /** 包装一次“刷新”动作：按钮转圈 + 结束提示 */
    M.runRefresh = function (loader, silent) {
        M.spinRefresh(true);
        return $.when(loader()).always(function () {
            M.spinRefresh(false);
            if (!silent) M.toast('已刷新', 'success', 1200);
        });
    };

    /* ---------------- 账号历史（本地） ---------------- */

    var HISTORY_KEY = 'm_account_history';

    M.history = {
        get: function () {
            try {
                return JSON.parse(localStorage.getItem(HISTORY_KEY) || '[]');
            } catch (e) {
                return [];
            }
        },
        save: function (list) {
            try { localStorage.setItem(HISTORY_KEY, JSON.stringify(list.slice(0, 10))); } catch (e) { }
        },
        add: function (account) {
            if (!account) return;
            var list = M.history.get();
            list = $.grep(list, function (a) { return a !== account; });
            list.unshift(account);
            M.history.save(list);
        },
        remove: function (account) {
            M.history.save($.grep(M.history.get(), function (a) { return a !== account; }));
        },
        clear: function () {
            M.history.save([]);
        }
    };

    /* ---------------- 账号模糊联想 ---------------- */

    /**
     * 为手机端账号输入框绑定统一的模糊联想。
     * kind 可为 player/agent，也可传函数以便根据页面状态动态切换。
     * onSelect(row) 用于在选中后执行页面自己的查询或填充逻辑。
     */
    M.bindAccountAutocomplete = function (options) {
        options = options || {};
        var $input = $(options.input);
        if (!$input.length) return null;

        var $box = options.suggest ? $(options.suggest) : $('<div class="m-account-suggest"></div>').appendTo($input.parent());
        var timer = null;
        var sequence = 0;
        var rowMap = {};

        function hide() {
            rowMap = {};
            $box.removeClass('show').empty();
        }

        function kind() {
            return typeof options.kind === 'function' ? options.kind() : (options.kind || 'player');
        }

        function highlight(value, keyword) {
            var text = String(value == null ? '' : value);
            var key = String(keyword || '');
            var index = key ? text.toLowerCase().indexOf(key.toLowerCase()) : -1;
            if (index < 0) return M.esc(text);
            return M.esc(text.substring(0, index)) +
                '<span class="m-account-suggest-hl">' + M.esc(text.substring(index, index + key.length)) + '</span>' +
                M.esc(text.substring(index + key.length));
        }

        function render(rows, keyword, rowKind) {
            rows = rows || [];
            if (!rows.length) {
                rowMap = {};
                $box.html('<div class="m-account-suggest-empty">未找到匹配账号</div>').addClass('show');
                return;
            }
            rowMap = {};
            $box.html(rows.map(function (row) {
                var account = row.ID || '';
                rowMap[String(account)] = row;
                var secondary = rowKind === 'player' ? (row.NAME || '') : (row.AGENCY || '');
                var coins = row.COINS == null ? '' : M.gold(row.COINS) + '币';
                return '<div class="m-account-suggest-item" data-account="' + M.esc(account) + '">' +
                    '<span class="m-account-suggest-account">' + highlight(account, keyword) + '</span>' +
                    '<span class="m-account-suggest-secondary">' + M.esc(secondary) + '</span>' +
                    (coins ? '<span class="m-account-suggest-coins">' + coins + '</span>' : '') +
                    '</div>';
            }).join('')).addClass('show');
        }

        function search(keyword) {
            var rowKind = kind();
            var currentSequence = ++sequence;
            var request = rowKind === 'agent'
                ? M.post('/Game/AgencyInfo/GetAgencies', { ID: keyword, Agency: '', page: 1, rows: 8 })
                : M.post('/Game/UserInfo/GetUsers', { srch_ID: keyword, srch_NAME: '', srch_Agency: '', page: 1, rows: 8 });
            request.then(function (result) {
                if (currentSequence !== sequence) return;
                render(result && result.rows, keyword, rowKind);
            }, function () {
                if (currentSequence === sequence) hide();
            });
        }

        $input.on('input', function () {
            var keyword = $.trim($input.val());
            if (timer) { clearTimeout(timer); timer = null; }
            if (typeof options.onInput === 'function') options.onInput(keyword);
            if (!keyword) { sequence++; hide(); return; }
            timer = setTimeout(function () { search(keyword); }, options.delay == null ? 300 : options.delay);
        });
        $input.on('blur', function () { setTimeout(hide, 180); });
        $box.on('mousedown', '.m-account-suggest-item', function (event) {
            event.preventDefault();
            var account = $(this).data('account');
            if (!account) return;
            var selectedRow = rowMap[String(account)] || { ID: String(account) };
            hide();
            $input.val(String(account));
            if (typeof options.onSelect === 'function') {
                options.onSelect(selectedRow);
            }
        });

        return { hide: hide, search: search };
    };

    /* ---------------- 游戏名映射 ---------------- */

    var gamesCache = null;

    M.loadGames = function () {
        if (gamesCache) return $.Deferred().resolve(gamesCache).promise();
        return M.get('/api/Games').then(function (data) {
            gamesCache = data || [];
            return gamesCache;
        }, function () {
            gamesCache = [];
            return gamesCache;
        });
    };

    M.gameName = function (gameId) {
        var id = Number(gameId);
        if (!id || id <= 0) return '--';
        if (gamesCache) {
            for (var i = 0; i < gamesCache.length; i++) {
                if (gamesCache[i] && Number(gamesCache[i].GameId) === id) return gamesCache[i].Name;
            }
        }
        return '游戏' + id;
    };

    /* ---------------- 全局初始化 ---------------- */

    M.initShell = function () {
        $('#menuBtn').on('click', M.openDrawer);
        $('#sidebarOverlay').on('click', M.closeDrawer);
        $('#sidebarCloseBtn').on('click', M.closeDrawer);

        // 返回按钮：导航锁防连点——back() 是异步遍历，遍历提交前的连点会被
        // 内核丢弃或连跳多条历史。正常导航会触发 pagehide，此时取消兜底定时器
        //（页面可能进 bfcache，定时器不能留着）；若 1.2s 后仍停留在本页
        //（history.length 误报、无可退记录），兜底跳玩家主页。
        // pageshow：首次加载与 bfcache 恢复时解锁按钮。
        var navLocked = false;
        var backTimer = null;
        var $backBtn = $('#backBtn');
        $(window).on('pagehide', function () {
            if (backTimer) { clearTimeout(backTimer); backTimer = null; }
        });
        $(window).on('pageshow', function () {
            navLocked = false;
            $backBtn.removeClass('navigating');
        });
        $backBtn.on('click', function () {
            if (navLocked) return;
            navLocked = true;
            $backBtn.addClass('navigating');
            if (window.history.length > 1) {
                window.history.back();
                backTimer = setTimeout(function () {
                    backTimer = null;
                    window.location.href = '/Mobile/Home/Index';
                }, 1200);
            } else {
                window.location.href = '/Mobile/Home/Index';
            }
        });

        $('#refreshBtn').on('click', function () {
            if (refreshHandler) refreshHandler();
        });

        $('#searchBtn').on('click', function () {
            if (searchHandler) searchHandler();
        });

        // 修改密码
        $('#changePasswordBtn').on('click', function () {
            M.closeDrawer();
            M.showChangePwd();
        });

        // 退出登录
        $('#logoutBtn').on('click', function () {
            M.closeDrawer();
            M.confirm('确定要退出登录吗？', '退出登录').then(function (ok) {
                if (ok) window.location.href = '/Login/LoginOut';
            });
        });
    };

    /** 修改自己的登录密码 */
    M.showChangePwd = function () {
        var body =
            '<div style="width:100%;"><label style="display:block;font-size:14px;font-weight:500;margin-bottom:8px;color:#333;">原密码</label>' +
            '<input type="password" class="input-field" id="mCpOld" placeholder="请输入原密码" autocomplete="off"></div>' +
            '<div style="width:100%;"><label style="display:block;font-size:14px;font-weight:500;margin-bottom:8px;color:#333;">新密码</label>' +
            '<input type="password" class="input-field" id="mCpNew" placeholder="请输入新密码" autocomplete="off"></div>' +
            '<div style="width:100%;"><label style="display:block;font-size:14px;font-weight:500;margin-bottom:8px;color:#333;">确认新密码</label>' +
            '<input type="password" class="input-field" id="mCpRe" placeholder="请再次输入新密码" autocomplete="off"></div>';

        var dlg = M.modal({
            title: '修改密码',
            bodyHTML: body,
            buttons: [
                { label: '取消', value: null },
                { label: '确认修改', value: 'ok', type: 'confirm' }
            ],
            beforeClose: function (value, $modal) {
                if (value !== 'ok') return true;
                var o = $.trim($modal.find('#mCpOld').val());
                var n = $.trim($modal.find('#mCpNew').val());
                var r = $.trim($modal.find('#mCpRe').val());
                if (!o || !n || !r) { M.toast('请填写完整信息', 'error'); return false; }
                if (n !== r) { M.toast('两次输入的新密码不一致', 'error'); return false; }
                if (n.length < 6) { M.toast('新密码至少 6 位', 'error'); return false; }
                if (n === o) { M.toast('新密码不能与原密码相同', 'error'); return false; }
                $modal.data('pwd', { OldPwd: o, NewPwd: n, RePwd: r });
                return true;
            }
        });

        var $dlgEl = dlg.$modal;
        dlg.then(function (v) {
            if (v !== 'ok') return;
            var data = $dlgEl.data('pwd');
            if (!data) return;
            M.loading('修改中...');
            M.post('/Login/ResetPwd', data).always(M.hideLoading).then(function (res) {
                var r = M.result(res);
                if (r.ok) {
                    M.alert('密码修改成功，请重新登录', true).then(M.toLogin);
                } else {
                    M.alert(r.text, false, '修改失败');
                }
            });
        });
    };

    window.MApp = M;

})(window, jQuery);
