/* ============================================================
   后台手机端运行时
   依赖：jQuery
   约定：
     - 所有数据接口均为 POST + [AjaxOnly]，返回 Msg{code,content,datas}
       或 EasyUI 形状 {total,rows,footer}；code == 1 表示成功。
     - 登录超时返回 code == -1，统一跳转登录页。
     - 页面级配置由 _MobileLayout.cshtml 注入到 window.MConfig。
   ============================================================ */
(function (window, $) {
    'use strict';

    var MConfig = window.MConfig = window.MConfig || {};
    MConfig.user = MConfig.user || {};
    MConfig.perms = MConfig.perms || {};

    var M = {};

    /* ---------------- 图标库 ---------------- */
    M.ICONS = {
        menu: '<svg viewBox="0 0 24 24"><path d="M3 18h18v-2H3v2zm0-5h18v-2H3v2zm0-7v2h18V6H3z"/></svg>',
        back: '<svg viewBox="0 0 24 24"><path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z"/></svg>',
        refresh: '<svg viewBox="0 0 24 24"><path d="M12 4V1L8 5l4 4V6c3.31 0 6 2.69 6 6 0 1.01-.25 1.97-.7 2.8l1.46 1.46C19.54 15.03 20 13.57 20 12c0-4.42-3.58-8-8-8zm0 14c-3.31 0-6-2.69-6-6 0-1.01.25-1.97.7-2.8L5.24 7.74C4.46 8.97 4 10.43 4 12c0 4.42 3.58 8 8 8v3l4-4-4-4v3z"/></svg>',
        search: '<svg viewBox="0 0 24 24"><path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>',
        add: '<svg viewBox="0 0 24 24"><path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg>',
        people: '<svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>',
        person: '<svg viewBox="0 0 24 24"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>',
        card: '<svg viewBox="0 0 24 24"><path d="M20 4H4c-1.11 0-1.99.89-1.99 2L2 18c0 1.11.89 2 2 2h16c1.11 0 2-.89 2-2V6c0-1.11-.89-2-2-2zm0 14H4v-6h16v6zm0-10H4V6h16v2z"/></svg>',
        list: '<svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H5V5h14v14zm-7-2h2v-4h4v-2h-4V7h-2v4H8v2h4z"/></svg>',
        lock: '<svg viewBox="0 0 24 24"><path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zM9 6c0-1.66 1.34-3 3-3s3 1.34 3 3v2H9V6zm9 14H6V10h12v10zm-6-3c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2z"/></svg>',
        shield: '<svg viewBox="0 0 24 24"><path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4z"/></svg>',
        monitor: '<svg viewBox="0 0 24 24"><path d="M20 18c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2H4c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2H0v2h24v-2h-4zM4 6h16v10H4V6z"/></svg>',
        kick: '<svg viewBox="0 0 24 24"><path d="M20 17.17L18.83 16H4V4h16v13.17zM20 2H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h14l4 4V4c0-1.1-.9-2-2-2z"/></svg>',
        logout: '<svg viewBox="0 0 24 24"><path d="M17 7l-1.41 1.41L18.17 11H8v2h10.17l-2.58 2.58L17 17l5-5zM4 5h8V3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h8v-2H4V5z"/></svg>',
        close: '<svg viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>',
        check: '<svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>',
        error: '<svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/></svg>',
        info: '<svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></svg>',
        clock: '<svg viewBox="0 0 24 24"><path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10 10-4.5 10-10S17.5 2 12 2zm0 18c-4.4 0-8-3.6-8-8s3.6-8 8-8 8 3.6 8 8-3.6 8-8 8zm.5-13H11v6l5.2 3.2.8-1.3-4.5-2.7V7z"/></svg>',
        swipe: '<svg viewBox="0 0 24 24"><path d="M8 5l-4 4 4 4V10h8v-2H8V5zm8 14l4-4-4-4v3H8v2h8v3z"/></svg>',
        shield_lock: '<svg viewBox="0 0 24 24"><path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm0 10.99h7c-.53 4.12-3.28 7.79-7 8.94V12H5V6.3l7-3.11v8.8z"/></svg>'
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

    /** 盈亏的颜色 class */
    M.signClass = function (v) {
        var n = Number(v || 0);
        return n > 0 ? 'positive' : (n < 0 ? 'negative' : '');
    };

    /**
     * 金币显示格式化，与桌面端 top.goldFormat 同口径：
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

    /** 提交给后端的金额：真金版界面输入的是元，后端会自行乘兑换率，这里原样回传 */
    M.goldInput = function (v) {
        return v;
    };

    M.pad2 = function (n) {
        return (n < 10 ? '0' : '') + n;
    };

    /** Date -> yyyy-MM-dd */
    M.fmtDate = function (d) {
        d = d || new Date();
        return d.getFullYear() + '-' + M.pad2(d.getMonth() + 1) + '-' + M.pad2(d.getDate());
    };

    /** .NET JSON 日期 /Date(1234)/ 或 ISO 字符串 -> yyyy-MM-dd HH:mm */
    M.fmtTime = function (v, withSec) {
        if (!v) return '--';
        var d = null;
        if (typeof v === 'string') {
            var mm = /\/Date\((-?\d+)/.exec(v);
            if (mm) {
                d = new Date(parseInt(mm[1], 10));
            } else if (/^\d{4}-\d{2}-\d{2}/.test(v)) {
                // 后端已格式化好的字符串，直接裁剪
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
        window.location.href = '/Login/Index';
    };

    /**
     * 统一 POST 请求。
     * 自动附带防伪令牌；登录超时统一跳转登录页并中断后续流程。
     * @returns jQuery Promise，resolve 的是后端原始 JSON
     */
    /** 防伪令牌：由布局页的隐藏 @Html.AntiForgeryToken() 提供，惰性读取 */
    M.token = function () {
        if (!MConfig.token) {
            MConfig.token = $('input[name="__RequestVerificationToken"]').first().val() || '';
        }
        return MConfig.token;
    };

    M.post = function (url, data) {
        var payload = $.extend({}, data || {});
        var token = M.token();
        if (token) {
            payload.__RequestVerificationToken = token;
        }
        return $.ajax({
            url: url,
            type: 'POST',
            data: payload,
            dataType: 'json',
            cache: false
        }).then(function (res) {
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
        $el.find('.m-loading-text').text(text || '处理中...');
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
        else if (type === 'warning') icon = M.ICONS.info;
        var $t = $('<div class="m-toast' + (type ? ' ' + type : '') + '"></div>');
        $t.html(icon + '<span>' + M.esc(msg) + '</span>');
        $box.append($t);
        setTimeout(function () {
            $t.addClass('fade-out');
            setTimeout(function () { $t.remove(); }, 260);
        }, duration || 2400);
    };

    /* ---------------- 弹窗 ---------------- */

    /**
     * 通用弹窗。
     * @param {Object} o
     *   title, subtitle, bodyHTML
     *   actions: [{label, type, value}]  竖排大按钮（玩家操作面板样式）
     *   buttons: [{label, type, value}]  底部横排按钮
     *   wide: 是否加宽
     *   onRender($modal): 弹窗渲染后回调，用于绑定内部控件
     *   beforeClose(value, $modal): 返回 false 可阻止关闭（用于表单校验）
     * @returns jQuery Promise，resolve 点击的 value（关闭/遮罩点击为 null）
     */
    M.modal = function (o) {
        o = o || {};
        var dfd = $.Deferred();
        var $overlay = $('<div class="m-modal-overlay"></div>');
        var $modal = $('<div class="m-modal' + (o.wide ? ' wide' : '') + '"></div>');

        if (o.title || o.subtitle) {
            var head = '<div class="m-modal-header"><div class="m-modal-title">' + M.esc(o.title || '') + '</div>';
            if (o.subtitle) head += '<div class="m-modal-subtitle">' + M.esc(o.subtitle) + '</div>';
            head += '</div>';
            $modal.append(head);
        }
        if (o.bodyHTML != null) {
            $modal.append($('<div class="m-modal-body"></div>').html(o.bodyHTML));
        }

        var settled = false;
        function close(value) {
            if (settled) return;
            if (o.beforeClose && o.beforeClose(value, $modal) === false) return;
            settled = true;
            $overlay.removeClass('show');
            setTimeout(function () { $overlay.remove(); }, 260);
            dfd.resolve(value);
        }

        if (o.actions && o.actions.length) {
            var $acts = $('<div class="m-modal-actions"></div>');
            $.each(o.actions, function (i, a) {
                var $b = $('<button type="button" class="m-modal-action ' + (a.type || '') + '"></button>');
                $b.text(a.label);
                $b.on('click', function () { close(a.value); });
                $acts.append($b);
            });
            $modal.append($acts);
        }

        var buttons = o.buttons || [{ label: '关闭', value: null }];
        var $foot = $('<div class="m-modal-footer"></div>');
        $.each(buttons, function (i, b) {
            var $b = $('<button type="button" class="m-modal-btn ' + (b.type || '') + '"></button>');
            $b.text(b.label);
            $b.on('click', function () { close(b.value); });
            $foot.append($b);
        });
        $modal.append($foot);

        $overlay.append($modal);
        $overlay.on('click', function (e) {
            if (e.target === $overlay[0]) close(null);
        });
        $('#mModalHost').append($overlay);
        // 触发过渡
        setTimeout(function () { $overlay.addClass('show'); }, 10);

        if (o.onRender) o.onRender($modal);

        // 暴露关闭方法，便于 onRender 内部主动关闭
        dfd.close = close;
        var promise = dfd.promise();
        promise.close = close;
        promise.$modal = $modal;
        return promise;
    };

    /** 确认框 */
    M.confirm = function (message, title) {
        return M.modal({
            title: title || '提示',
            bodyHTML: '<div class="m-modal-message">' + M.esc(message) + '</div>',
            buttons: [
                { label: '取消', value: false },
                { label: '确定', value: true, type: 'primary' }
            ]
        }).then(function (v) {
            return v === true;
        });
    };

    /** 危险操作确认框（确定按钮红色） */
    M.confirmDanger = function (message, title) {
        return M.modal({
            title: title || '请确认',
            bodyHTML: '<div class="m-modal-message">' + M.esc(message) + '</div>',
            buttons: [
                { label: '取消', value: false },
                { label: '确定', value: true, type: 'danger' }
            ]
        }).then(function (v) {
            return v === true;
        });
    };

    /** 结果提示弹窗 */
    M.alert = function (message, success, title) {
        var icon = success ? M.ICONS.check : M.ICONS.error;
        var cls = success ? 'success' : 'error';
        return M.modal({
            title: title || (success ? '操作成功' : '操作失败'),
            bodyHTML: '<div style="text-align:center;">' +
                '<div class="m-modal-icon ' + cls + '">' + icon + '</div>' +
                '<div class="m-modal-message">' + M.esc(message) + '</div></div>',
            buttons: [{ label: '确定', value: true, type: 'primary' }]
        });
    };

    /**
     * 带输入框的弹窗。
     * @param {Object} o title, subtitle, label, placeholder, type(text/password/number), value, confirmText
     * @returns Promise，resolve 输入值；取消为 null
     */
    M.promptInput = function (o) {
        o = o || {};
        var id = 'mPrompt' + Date.now();
        var body = '<div class="m-form-group">';
        if (o.label) body += '<label class="m-label">' + M.esc(o.label) + '</label>';
        body += '<input type="' + (o.type || 'text') + '" class="m-input" id="' + id + '"' +
            (o.inputmode ? ' inputmode="' + o.inputmode + '"' : '') +
            ' placeholder="' + M.esc(o.placeholder || '') + '" value="' + M.esc(o.value || '') + '" autocomplete="off">';
        body += '</div>';
        if (o.tip) body += '<div class="m-hint muted">' + M.esc(o.tip) + '</div>';

        var dlg = M.modal({
            title: o.title,
            subtitle: o.subtitle,
            bodyHTML: body,
            buttons: [
                { label: '取消', value: null },
                { label: o.confirmText || '确定', value: 'ok', type: 'primary' }
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
        $('#mSidebar').addClass('active');
        $('#mSidebarOverlay').addClass('active');
    };

    M.closeDrawer = function () {
        $('#mSidebar').removeClass('active');
        $('#mSidebarOverlay').removeClass('active');
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
            try {
                localStorage.setItem(HISTORY_KEY, JSON.stringify(list.slice(0, 10)));
            } catch (e) { /* 隐私模式下忽略 */ }
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

    /* ---------------- 顶栏刷新按钮动画 ---------------- */

    M.spinRefresh = function (on) {
        var $btn = $('#mRefreshBtn');
        if (on) $btn.addClass('spin');
        else $btn.removeClass('spin');
    };

    /**
     * 包装一次“刷新”动作：按钮转圈 + 结束提示
     * @param {Function} loader 返回 promise 的加载函数
     */
    M.runRefresh = function (loader, silent) {
        M.spinRefresh(true);
        return $.when(loader()).always(function () {
            M.spinRefresh(false);
            if (!silent) M.toast('已刷新', 'success', 1200);
        });
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
        $('#mMenuBtn').on('click', M.openDrawer);
        $('#mSidebarOverlay').on('click', M.closeDrawer);
        $('#mSidebarClose').on('click', M.closeDrawer);

        $('#mBackBtn').on('click', function () {
            if (window.history.length > 1) window.history.back();
            else window.location.href = '/Mobile/Home/Index';
        });

        // 修改密码
        $('#mChangePwdBtn').on('click', function () {
            M.closeDrawer();
            M.showChangePwd();
        });

        // 一键踢人
        $('#mKickAllBtn').on('click', function () {
            M.closeDrawer();
            M.kickAll();
        });

        // 切换电脑版
        $('#mDesktopBtn').on('click', function () {
            window.location.href = '/Mgr/Index?view=pc';
        });

        // 退出登录
        $('#mLogoutBtn').on('click', function () {
            M.closeDrawer();
            M.confirmDanger('确定要退出登录吗？', '退出登录').then(function (ok) {
                if (ok) window.location.href = '/Login/LoginOut';
            });
        });
    };

    /** 修改自己的登录密码 */
    M.showChangePwd = function () {
        var body =
            '<div class="m-form-group"><label class="m-label">原密码</label>' +
            '<input type="password" class="m-input" id="mCpOld" placeholder="请输入原密码" autocomplete="off"></div>' +
            '<div class="m-form-group"><label class="m-label">新密码</label>' +
            '<input type="password" class="m-input" id="mCpNew" placeholder="请输入新密码" autocomplete="off"></div>' +
            '<div class="m-form-group"><label class="m-label">确认新密码</label>' +
            '<input type="password" class="m-input" id="mCpRe" placeholder="请再次输入新密码" autocomplete="off"></div>';

        var dlg = M.modal({
            title: '修改密码',
            bodyHTML: body,
            buttons: [
                { label: '取消', value: null },
                { label: '确认修改', value: 'ok', type: 'primary' }
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

    /** 一键踢人 */
    M.kickAll = function () {
        M.confirmDanger('确定要踢出当前在线玩家吗？此操作会立即断开玩家连接。', '一键踢人').then(function (ok) {
            if (!ok) return;
            M.loading('正在踢人...');
            M.post('/Game/UserInfo/KickAllPlayer', {}).always(M.hideLoading).then(function (res) {
                var r = M.result(res);
                M.alert(r.text, r.ok, r.ok ? '踢人完成' : '踢人失败');
            });
        });
    };

    window.MApp = M;

})(window, jQuery);
