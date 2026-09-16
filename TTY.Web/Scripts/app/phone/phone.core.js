/* ============================================================
   手机端后台运行时（1:1 复刻参考站点交互）
   依赖：jQuery + phone.css
   约定：
     - 所有数据接口均为 POST，返回 Msg{code,content,datas}
       或 EasyUI 形状 {total,rows}；code == 1 表示成功。
     - 登录超时返回 code == -1，统一跳转手机登录页 /Login/Mobile。
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

    /** 手机端整数：不使用千分位分隔符 */
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
        if (p === 1) return '特级代理';
        if (p > 1) return (p - 1) + '级代理';
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

    /*
     * 弹窗期间的背景滚动锁。
     * 部分老安卓内核（微信 X5 / 老 WebKit）给 position:fixed 元素做触摸命中测试时按
     * "文档坐标"算，命中区不随页面滚动更新：页面滚到中下部再打开弹窗，点确定/取消
     * 毫无反应（弹窗视觉位置一直是对的），必须把页面滚回顶部才点得中。
     * 所以打开弹窗时把 body 固定住（用负 top 保持视觉位置），并把文档滚动量归零，
     * 让命中区与视觉位置一致；关闭时还原滚动位置。
     * 弹窗会叠加（确认框点确定后接着弹结果框），用计数配对加减，最后一个关闭才解锁。
     */
    var scrollLockCount = 0;
    var scrollLockY = 0;

    function lockPageScroll() {
        if (scrollLockCount++ > 0) return;
        var y = window.pageYOffset ||
            (document.documentElement ? document.documentElement.scrollTop : 0) ||
            (document.body ? document.body.scrollTop : 0) || 0;
        scrollLockY = y;
        var s = document.body.style;
        s.position = 'fixed';
        s.top = -y + 'px';
        s.left = '0';
        s.right = '0';
        s.width = '100%';
        s.overflow = 'hidden';
        // 滚动量归零：老内核按文档坐标命中，滚动量非 0 时弹窗按钮点不中
        if (y) window.scrollTo(0, 0);
    }

    function unlockPageScroll() {
        if (scrollLockCount === 0 || --scrollLockCount > 0) return;
        var y = scrollLockY;
        scrollLockY = 0;
        var s = document.body.style;
        s.position = '';
        s.top = '';
        s.left = '';
        s.right = '';
        s.width = '';
        s.overflow = '';
        if (y) window.scrollTo(0, y);
    }

    /**
     * 通用弹窗。
     * @param {Object} o
     *   title, subtitle, bodyHTML
     *   actions: [{label, type, value}]  竖排大按钮（.modal-action-btn）
     *   actionsInline: true 时动作按钮并排一行、宽度均分（只有两个动作时用）
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
            unlockPageScroll();
            setTimeout(function () { $overlay.remove(); }, 100);
            dfd.resolve(value);
        }

        if (o.actions && o.actions.length) {
            var $acts = $('<div class="modal-actions' + (o.actionsInline ? ' inline' : '') + '"></div>');
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
        // 先锁住背景滚动再挂弹窗：页面滚到中下部时打开的弹窗，按钮才点得中（见上）
        lockPageScroll();
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

    /* ---------------- 控牌牌型表（控制页与玩家列表共用，移植电脑端 UserInfo/Index.cshtml） ---------------- */

    // 牌机 13 种牌型（与服务端 te_CardsType 枚举 0..12 一致）
    var TC_CARD_TYPES = [
        { ht: 0, name: '杂牌' }, { ht: 1, name: '对子' }, { ht: 2, name: '两对' },
        { ht: 3, name: '三条' }, { ht: 4, name: '杂顺' }, { ht: 5, name: '同花' },
        { ht: 6, name: '葫芦' }, { ht: 7, name: '小四梅' }, { ht: 8, name: '大四梅' },
        { ht: 9, name: '同花顺' }, { ht: 10, name: '五梅' }, { ht: 11, name: '同花大顺' },
        { ht: 12, name: '五鬼' }
    ];
    // 各牌机游戏倍率（与台机设定 GC_MAG_TAB 一致；ATT3 取 middle 档）
    var TC_MAG_TAB = {
        phenix: [0, 1, 2, 3, 5, 7, 10, 40, 80, 120, 250, 500, 1000],
        king3:  [0, 1, 2, 3, 5, 7, 10, 60, 60, 120, 250, 500, 1000],
        dazhi:  [0, 1, 2, 3, 5, 7, 15, 65, 65, 150, 350, 250, 350],
        nba:    [0, 1, 2, 3, 5, 7, 10, 50, 50, 100, 400, 200, 1000],
        att3:   [0, 1, 2, 3, 5, 7, 10, 50, 50, 120, 400, 200, 1000]
    };

    function tcMagKey(action) {
        if (action == 5) return 'dazhi';
        if (action == 7) return 'att3';
        if (action == 12) return 'king3';
        if (action == 13) return 'nba';
        return 'phenix';
    }

    // 牌机型(5-14)牌型下拉：杂牌(0)/五鬼(12)不提供，大四梅(8)仅火凤凰(14)保留；99=关闭控制。
    // 与电脑端 UserInfo/Index.cshtml 的 valSelDataPAIJI 同一口径（大字板五鬼已下线，与服务端 AlgProb 封死一致）
    function cardTypeDataForPaiji(action) {
        var mags = TC_MAG_TAB[tcMagKey(action)];
        var arr = [];
        for (var i = 0; i < TC_CARD_TYPES.length; i++) {
            var t = TC_CARD_TYPES[i];
            if (t.ht == 0 || t.ht == 12) continue;
            if (t.ht == 8 && action != 14) continue;
            arr.push({ id: t.ht, text: t.name + '(' + mags[t.ht] + '倍)' });
        }
        arr.push({ id: 99, text: '关闭控制' });
        return arr;
    }

    // 水浒传控牌=按结果类 code 强制（与电脑端 valSelDataShz / 服务端 ShzRtp::ComboToClass 一致）：
    // 400-407三连 410-417四连 420-427五连 430-432纯万能线 440-448全屏 450/451全屏混合；10=关闭。
    // 全屏类倍率=全屏奖+线奖（9 线）叠加后的总赔率；超过 2000 倍的一律不下发（440 14000 / 441 11500 /
    // 442 4600 / 443 2300），历史控牌值回退见 SHZ_LEGACY。
    function cardTypeDataForShz() {
        return [
            { id: 407, text: '三连·斧(2倍)' }, { id: 406, text: '三连·枪(3倍)' },
            { id: 405, text: '三连·刀(5倍)' }, { id: 417, text: '四连·斧(5倍)' },
            { id: 404, text: '三连·鲁智深(7倍)' }, { id: 403, text: '三连·林冲(10倍)' },
            { id: 416, text: '四连·枪(10倍)' }, { id: 402, text: '三连·宋江(15倍)' },
            { id: 415, text: '四连·刀(15倍)' }, { id: 451, text: '全屏·纯武器混合(15倍)' },
            { id: 401, text: '三连·替天行道(20倍)' }, { id: 414, text: '四连·鲁智深(20倍)' },
            { id: 427, text: '五连·斧(20倍)' }, { id: 413, text: '四连·林冲(30倍)' },
            { id: 412, text: '四连·宋江(40倍)' }, { id: 426, text: '五连·枪(40倍)' },
            { id: 400, text: '三连·忠义堂(50倍)' }, { id: 430, text: '纯万能线·3连(50倍)' },
            { id: 450, text: '全屏·纯人物混合(50倍)' }, { id: 425, text: '五连·刀(60倍)' },
            { id: 411, text: '四连·替天行道(80倍)' }, { id: 424, text: '五连·鲁智深(100倍)' },
            { id: 423, text: '五连·林冲(160倍)' }, { id: 410, text: '四连·忠义堂(200倍)' },
            { id: 422, text: '五连·宋江(200倍)' }, { id: 431, text: '纯万能线·4连(200倍)' },
            { id: 448, text: '全屏·斧(230倍)' }, { id: 421, text: '五连·替天行道(400倍)' },
            { id: 447, text: '全屏·枪(460倍)' }, { id: 446, text: '全屏·刀(690倍)' },
            { id: 420, text: '五连·忠义堂(1000倍)' }, { id: 432, text: '纯万能线·5连(1000倍)' },
            { id: 445, text: '全屏·鲁智深(1150倍)' }, { id: 444, text: '全屏·林冲(1840倍)' },
            { id: 10, text: '关闭控制' }
        ];
    }

    // 明星97控牌=按结果类 code 强制（与电脑端 valSelDataMx97 / 服务端 Mx97Rtp::ComboToClass 一致）：
    // 300-308纯色三连 310 ANY BAR 311/312樱桃2/1连 322-329 Scatter 330全水果 340-347全屏 350全屏BAR；10=关闭。
    // 全屏类倍率同样是全屏奖+线奖（8 线）叠加后的总赔率，最高 660 倍，未触及 2000 倍上限。
    function cardTypeDataForMx97() {
        return [
            { id: 300, text: '纯色三连·樱桃(10倍)' }, { id: 301, text: '纯色三连·橘子(10倍)' },
            { id: 302, text: '纯色三连·蓝莓(14倍)' }, { id: 303, text: '纯色三连·铃铛(18倍)' },
            { id: 304, text: '纯色三连·西瓜(20倍)' }, { id: 305, text: '纯色三连·黄BAR(30倍)' },
            { id: 306, text: '纯色三连·红BAR(50倍)' }, { id: 307, text: '纯色三连·蓝BAR(70倍)' },
            { id: 308, text: '纯色三连·七(80倍+)' }, { id: 310, text: 'ANY BAR(10倍)' },
            { id: 311, text: '樱桃2连(5倍)' }, { id: 312, text: '樱桃1连(2倍)' },
            { id: 322, text: 'Scatter 全盘2个七(2倍)' }, { id: 323, text: 'Scatter 全盘3个七(5倍)' },
            { id: 324, text: 'Scatter 全盘4个七(20倍)' }, { id: 325, text: 'Scatter 全盘5个七(40倍)' },
            { id: 326, text: 'Scatter 全盘6个七(60倍)' }, { id: 327, text: 'Scatter 全盘7个七(80倍)' },
            { id: 328, text: 'Scatter 全盘8个七(100倍)' }, { id: 329, text: 'Scatter 全盘9个七(200倍)' },
            { id: 330, text: '全水果(15倍)' }, { id: 340, text: '全屏·樱桃(160倍)' },
            { id: 341, text: '全屏·橘子(120倍)' }, { id: 342, text: '全屏·蓝莓(152倍)' },
            { id: 343, text: '全屏·铃铛(184倍)' }, { id: 344, text: '全屏·西瓜(220倍)' },
            { id: 345, text: '全屏·黄BAR(300倍)' }, { id: 346, text: '全屏·红BAR(490倍)' },
            { id: 347, text: '全屏·蓝BAR(660倍)' }, { id: 350, text: '全屏 ANY BAR(40倍)' },
            { id: 10, text: '关闭控制' }
        ];
    }

    // 水果拉霸控牌=强制大转盘指向面板位（与机台设定的 24 面板位一致）；id=30+面板位，10=关闭；
    // 按倍率小到大排（送灯位无倍率=免费局排最后，同倍率按面板位），文本不带"面板X"前缀，与电脑端一致。
    // 面板位 9/21 两个送灯位要分开写清免费局次数（9→1~3 次、21→3~6 次，与机台设定面板表同名）
    function cardTypeDataForFruit() {
        var panels = [
            '橘子·大(10倍)', '铃铛·大(20倍)', 'BAR·小(50倍)', 'BAR·大(120倍)', '苹果(5倍)', '苹果·小(3倍)',
            '柠檬·大(15倍)', '西瓜·大(20倍)', '西瓜·小(3倍)', '送灯位·免费局 1~3 次', '苹果(5倍)', '橘子·小(3倍)',
            '橘子·大(10倍)', '铃铛·大(20倍)', '双7·小(3倍)', '双7·大(40倍)', '苹果(5倍)', '柠檬·小(3倍)',
            '柠檬·大(15倍)', '星星·小(3倍)', '星星·大(30倍)', '送灯位·免费局 3~6 次', '苹果(5倍)', '铃铛·小(3倍)'
        ];
        var arr = [];
        for (var i = 0; i < panels.length; i++) {
            var m = /\((\d+)倍\)/.exec(panels[i]);
            arr.push({ id: 30 + i, text: panels[i], mag: m ? parseInt(m[1], 10) : 9999 });
        }
        arr.sort(function (a, b) {
            if (a.mag != b.mag) return a.mag - b.mag;
            return (a.id - 30) - (b.id - 30);
        });
        arr.push({ id: 10, text: '关闭控制' });
        return arr;
    }

    M.CARD_ACTIONS = [
        { id: 5, text: '大字版控制' }, { id: 7, text: 'ATT3控制' }, { id: 12, text: '金皇冠' },
        { id: 13, text: 'NBA' }, { id: 14, text: '火凤凰' }, { id: 15, text: '水浒传' },
        { id: 16, text: '明星97' }, { id: 17, text: '水果拉霸' }
    ];

    /** 控牌游戏(GameId/cardAction) -> 名称，如 5 -> “大字版控制” */
    M.cardActionName = function (action) {
        for (var i = 0; i < M.CARD_ACTIONS.length; i++)
            if (M.CARD_ACTIONS[i].id == action) return M.CARD_ACTIONS[i].text;
        return '游戏' + action;
    };

    /** 指定游戏的牌型下拉数据（含倍率文案） */
    M.cardTypeData = function (action) {
        action = parseInt(action, 10);
        if (action == 15) return cardTypeDataForShz();
        if (action == 16) return cardTypeDataForMx97();
        if (action == 17) return cardTypeDataForFruit();
        return cardTypeDataForPaiji(action);
    };

    // 历史控牌值名称回退（下拉已不再提供，但已下发的旧控牌记录仍要能回显，与电脑端 labaTypeName 同口径）：
    // 水浒传 0-7 = 中间行五连符号；明星97 0-8 = 单线三连符号
    var SHZ_LEGACY = [
        '五连·忠义堂(1000倍)', '五连·替天行道(400倍)', '五连·宋江(200倍)', '五连·林冲(160倍)',
        '五连·鲁智深(100倍)', '五连·刀(60倍)', '五连·枪(40倍)', '五连·斧(20倍)'
    ];
    var MX97_LEGACY = [
        '三连·樱桃(10倍)', '三连·橘子(10倍)', '三连·蓝莓(14倍)', '三连·铃铛(18倍)', '三连·西瓜(20倍)',
        '三连·黄BAR(30倍)', '三连·红BAR(50倍)', '三连·蓝BAR(70倍)', '三连·七(80倍+)'
    ];

    /** 牌型值 -> 名称，如 大字版控制(5) + 9 -> “同花顺(150倍)” */
    M.cardTypeName = function (action, value) {
        action = parseInt(action, 10);
        value = parseInt(value, 10);
        var rows = M.cardTypeData(action);
        for (var i = 0; i < rows.length; i++)
            if (rows[i].id == value) return rows[i].text;
        // 牌机：已隐藏牌型（杂牌0 / 大四梅8 / 五鬼12）不在下拉里，但历史控牌值按该游戏倍率表回显
        if (action >= 5 && action <= 14) {
            var mags = TC_MAG_TAB[tcMagKey(action)];
            for (var j = 0; j < TC_CARD_TYPES.length; j++)
                if (TC_CARD_TYPES[j].ht == value) return TC_CARD_TYPES[j].name + '(' + mags[value] + '倍)';
        }
        if (action == 15 && value >= 0 && value <= 7) return SHZ_LEGACY[value];
        if (action == 16 && value >= 0 && value <= 8) return MX97_LEGACY[value];
        return '牌型' + value;
    };

    /**
     * 控牌参数主体（不含"（1次/5把）"后缀，供各页套自己的外层格式）：
     * “大字版控制 同花顺(150倍)”。
     * GameId<5 属历史/异常数据，没有游戏类型可映射，退回只显示牌型值。
     */
    M.cardControlParams = function (gameId, cardValue) {
        if (parseInt(gameId, 10) >= 5) {
            return M.cardActionName(gameId) + ' ' + M.cardTypeName(gameId, cardValue);
        }
        return '控牌值 ' + M.num(cardValue);
    };

    /**
     * 控牌完整参数文案（控制页状态行与玩家列表卡片共用）：
     * “大字版控制 同花顺(150倍)（1次/5把）”。
     */
    M.cardControlText = function (gameId, cardValue) {
        return M.cardControlParams(gameId, cardValue) + '（1次/5把）';
    };

    /* ---------------- 默认向上展开的下拉（控制页「控制牌型」等页面底部的字段） ---------------- */

    var upselSeq = 0;

    /** select 当前选中项的显示文本（没选中时取第一项） */
    function upselText($sel) {
        var v = $sel.val();
        var text = '';
        $sel.find('option').each(function () {
            if (this.value == v) text = $.trim($(this).text());
        });
        if (!text) text = $.trim($sel.find('option').first().text() || '');
        return text;
    }

    /**
     * 把原生 select 换成“默认向上展开”的下拉：点字段时在它上方弹出列表，上方放不下才向下。
     * 场景：控制页「控制牌型」在页面底部，原生 select 的弹出列表只能向下，列表会被屏幕底部裁掉，
     * 后面的牌型点不到（老安卓内核/桌面模拟器都一样）。
     * 原生 select 仍留在 DOM 里作为取值与 change 事件的唯一来源（.val() / .trigger('change') 照旧），
     * 只是视觉上隐藏，由按钮 + 页面内浮层代替；选项重建后调 M.upwardSelectRefresh 同步文案。
     */
    M.upwardSelect = function ($sel) {
        if (!$sel || !$sel.length || $sel.data('upselReady')) return;
        $sel.data('upselReady', true);

        var uid = 'upsel' + (++upselSeq);
        var $wrap = $('<div class="upsel"></div>');
        $sel.addClass('upsel-native').after($wrap);
        $sel.appendTo($wrap);
        var $btn = $('<button type="button" class="input-field upsel-trigger" aria-haspopup="listbox"></button>').appendTo($wrap);

        function closePanel() {
            $wrap.removeClass('open').children('.upsel-panel').remove();
            $(document).off('click.' + uid);
        }

        function refresh() {
            $btn.text(upselText($sel));
        }

        function openPanel() {
            closePanel();
            var html = '';
            $sel.find('option').each(function () {
                html += '<div class="upsel-item' + (this.value == $sel.val() ? ' active' : '') +
                    '" data-v="' + M.esc(this.value) + '">' + M.esc($(this).text()) + '</div>';
            });
            var $panel = $('<div class="upsel-panel" role="listbox"></div>').html(html).appendTo($wrap);

            // 默认向上；上方空间不足且下方更宽敞才向下。高度按可用空间收缩，超长列表（水果拉霸 24 项）内部滚动。
            var rect = $btn[0].getBoundingClientRect();
            var roomAbove = rect.top - 8;
            var roomBelow = window.innerHeight - rect.bottom - 8;
            var up = !(roomAbove < 160 && roomBelow > roomAbove);
            var room = Math.min(up ? roomAbove : roomBelow, window.innerHeight - 16);
            $panel.addClass(up ? 'up' : 'down')
                .css('max-height', Math.max(132, Math.min(room, window.innerHeight * 0.6)) + 'px');

            $wrap.addClass('open');
            var $active = $panel.children('.upsel-item.active');
            if ($active.length) $panel.scrollTop(Math.max(0, $active.position().top - $panel.height() / 2 + $active.outerHeight() / 2));

            $(document).on('click.' + uid, function (e) {
                if (!$(e.target).closest($wrap).length) closePanel();
            });
        }

        $btn.on('click', function (e) {
            e.preventDefault();
            e.stopPropagation();
            if ($wrap.hasClass('open')) closePanel();
            else openPanel();
        });
        $wrap.on('click', '.upsel-item', function (e) {
            e.stopPropagation();
            var v = $(this).attr('data-v');
            closePanel();
            if ($sel.val() != v) $sel.val(v).trigger('change');
            refresh();
        });
        // 其他地方（脚本 setValue、表单重置）改了值也要跟上按钮文案
        $sel.on('change', refresh);

        $wrap.data('upselRefresh', refresh);
        refresh();
    };

    /** 选项被重建（fillSelect）后同步按钮文案；浮层开着就直接收起 */
    M.upwardSelectRefresh = function ($sel) {
        var $wrap = $sel && $sel.closest ? $sel.closest('.upsel') : null;
        if (!$wrap || !$wrap.length) return;
        if ($wrap.hasClass('open')) {
            $wrap.removeClass('open').children('.upsel-panel').remove();
        }
        var fn = $wrap.data('upselRefresh');
        if (typeof fn === 'function') fn();
    };

    /* ---------------- 代理详细信息弹窗 ---------------- */

    /**
     * 代理详细信息弹窗（我的代理页、代理流水页共用）。
     * 弹窗内可继续前往该代理的流水页 / 充值页；创建下级开关受后端权限校验。
     */
    M.showAgentDetail = function (id) {
        if (!id) return;
        M.loading('查询代理信息...');
        return M.post('/Game/AgencyInfo/GetAgencyDetail', { ID: id }).always(M.hideLoading).then(function (res) {
            var r = M.result(res);
            if (!r.ok || !r.datas) {
                M.alert(r.text, false, '查询失败');
                return;
            }
            var a = r.datas;
            var canViewPwd = a.PWD != null && a.PWD !== '';
            var body = '<div class="agent-detail-modal">' +
                '<div><span>代理账号</span><b>' + M.esc(a.ID) + '</b></div>' +
                (canViewPwd ? '<div><span>账号密码</span><b>' + M.esc(a.PWD) + '</b></div>' : '') +
                '<div><span>注册时间</span><b>' + M.esc(M.fmtTime(a.CreateTime, true)) + '</b></div>' +
                '<div><span>代理级别</span><b>' + M.esc(M.privName(a.PRIV)) + '</b></div>' +
                '<div><span>最后登录</span><b>' + M.esc(M.fmtTime(a.LastLoginTime, true)) + '</b></div>' +
                '<div><span>邀请码</span><b>' + M.esc(a.InviteCode || '--') + '</b></div>' +
                '<div><span>上级代理</span><b>' + M.esc(a.AGENCY || '--') + '</b></div>' +
                '<div><span>剩余币</span><b class="blue-text">' + M.gold(a.COINS) + '</b></div>' +
                '<div><span>剩余分</span><b>' + M.num(a.RemainingScore || 0) + '</b></div>' +
                '<div class="agent-create-child-row"><span>创建下级</span><label class="m-switch"><input type="checkbox" id="agentCreateChild" ' + (Number(a.IsCreateAgent) === 1 ? 'checked' : '') + '><span></span></label><span class="agent-save-state" id="agentSaveState"></span></div>' +
                '</div>';
            var dlg = M.modal({
                title: '代理详细信息',
                bodyHTML: body,
                actionsInline: true,
                actions: [
                    { label: '流水', value: 'flow', type: 'secondary' },
                    { label: '充值', value: 'recharge', type: 'primary' }
                ],
                buttons: [{ label: '关闭', value: null, type: 'confirm' }],
                onRender: function ($modal) {
                    var $toggle = $modal.find('#agentCreateChild');
                    var savedValue = Number(a.IsCreateAgent) === 1;
                    $toggle.on('change', function () {
                        var nextValue = $toggle.is(':checked');
                        $toggle.prop('disabled', true);
                        $modal.find('#agentSaveState').text('保存中...');
                        M.post('/Game/Admin/SetIsCreateAgent', { ID: a.ID, IsCreateAgent: nextValue ? 1 : 0 })
                            .then(function (saveRes) {
                                var save = M.result(saveRes);
                                if (save.ok) {
                                    savedValue = nextValue;
                                    $modal.find('#agentSaveState').text('已保存');
                                    M.toast('保存成功', 'success');
                                } else {
                                    $toggle.prop('checked', savedValue);
                                    $modal.find('#agentSaveState').text(save.text);
                                    M.toast(save.text, 'error');
                                }
                            }, function () {
                                $toggle.prop('checked', savedValue);
                                $modal.find('#agentSaveState').text('保存失败');
                            })
                            .always(function () { $toggle.prop('disabled', false); });
                    });
                }
            });
            dlg.then(function (value) {
                if (value === 'flow')
                    window.location.href = '/Mobile/Home/AgentFlow?id=' + encodeURIComponent(a.ID);
                else if (value === 'recharge')
                    window.location.href = '/Mobile/Home/Recharge?id=' + encodeURIComponent(a.ID) + '&role=agent';
            });
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

    /** 包装一次“刷新”动作：按钮转圈；silent=false 时显示结束提示 */
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

    /* ---------------- 玩家列表刷新标记 ---------------- */

    // 玩家列表页（Index，即在线玩家页）的子页面里，操作会改变列表展示数据的那些。
    // 进入这些页面即给列表页留一个"需要刷新"标记；列表页恢复时消费并重拉数据。
    // 注意不能在离开页面的时机（pagehide）打标记：实测（Chromium）返回导航里恢复页面的
    // pageshow 先于离开页面的 pagehide，标记会晚一步写入、列表页看不到它。
    var PLAYERS_STALE_KEY = 'm_players_stale';
    var PLAYERS_STALE_PAGES = { agents: true, huiyuan: true, recharge: true };

    /** 当前页面是否属于"返回列表页时需要刷新"的那几个 */
    function isPlayersStalePage() {
        return !!PLAYERS_STALE_PAGES[MConfig.page];
    }

    /**
     * 标记玩家列表数据已过期。返回列表页大多是 bfcache 恢复（页面不重新加载、
     * JS 状态原样保留），页面内变量传不过去，只能借用跨导航的存储。
     */
    M.markPlayersStale = function () {
        try { localStorage.setItem(PLAYERS_STALE_KEY, '1'); } catch (e) { }
    };

    /** 取走过期标记；返回 true 表示列表页需要重新拉数据 */
    M.consumePlayersStale = function () {
        try {
            if (localStorage.getItem(PLAYERS_STALE_KEY) !== '1') return false;
            localStorage.removeItem(PLAYERS_STALE_KEY);
            return true;
        } catch (e) {
            return false;
        }
    };

    /* ---------------- 全局初始化 ---------------- */

    M.initShell = function () {
        $('#menuBtn').on('click', M.openDrawer);
        $('#sidebarOverlay').on('click', M.closeDrawer);
        $('#sidebarCloseBtn').on('click', M.closeDrawer);

        // 进入"我的代理 / 我的会员 / 充值管理"即标记玩家列表数据过期——这几个页面
        // 会改余额与输赢，返回列表页时要重拉（见 phone.players.js 的 pageshow）。
        // 标记放在进入时机而不是离开时机：恢复页面的 pageshow 早于离开页面的 pagehide。
        if (isPlayersStalePage()) M.markPlayersStale();

        // 返回按钮：导航锁防连点——back() 是异步遍历，遍历提交前的连点会被
        // 内核丢弃或连跳多条历史。正常导航会触发 pagehide，此时取消兜底定时器
        //（页面可能进 bfcache，定时器不能留着）；若 1.2s 后仍停留在本页
        //（history.length 误报、无可退记录），兜底跳玩家主页。
        // pageshow：首次加载与 bfcache 恢复时解锁按钮，并把抽屉收起来。
        // 抽屉只有玩家列表页有，而 bfcache 恢复会原样保留打开时的 DOM 状态：
        // 从抽屉点进"我的代理/我的会员/充值管理"再返回，菜单会一直盖在列表上。
        var navLocked = false;
        var backTimer = null;
        var $backBtn = $('#backBtn');
        $(window).on('pagehide', function () {
            if (backTimer) { clearTimeout(backTimer); backTimer = null; }
        });
        $(window).on('pageshow', function () {
            navLocked = false;
            $backBtn.removeClass('navigating');
            M.closeDrawer();
        });
        $backBtn.on('click', function () {
            if (navLocked) return;
            navLocked = true;
            $backBtn.addClass('navigating');
            // 补一次标记：本页若是 bfcache 恢复的，进入时那次标记已被列表页消费掉
            if (isPlayersStalePage()) M.markPlayersStale();
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
                if (ok) window.location.href = '/Login/LoginOut?view=mobile';
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
