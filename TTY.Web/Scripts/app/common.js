// easyui loading效果
window.request = function (url, para, callBack, method) {
    $.ajax({
        url: url,
        data: para,
        type: (method ? method : 'POST'),
        dataType: 'json',
        beforeSend: function () {
            //$("<div class=\"datagrid-mask\" style=\"background-color:#ccc !important;\></div>").css({ display: "block", width: "100%", height: $(window).height() }).appendTo("body");
            //$("<div class=\"datagrid-mask-msg\" style=\"background-color:#fff !important;\"></div>").html("正在处理，请稍候。。。").appendTo("body").css({ display: "block", left: ($(document.body).outerWidth(true) - 190) / 2, top: ($(window).height() - 45) / 2 });
            if ($('.main-loading').length < 1) {
                $('<div class="main-loading bg"><div class="main-loading-mask">正在处理，请稍待。。。</div></div>').prependTo('.main');
                var _t = setInterval(function () {
                    if ($('.main-loading').length > 0) {
                        hideLoading();
                        clearInterval(_t);
                    }
                }, 5000);
            }
        },
        success: function (data) {
            if (data.code && data.code == -1) {
                loginTimeoutCallback(data);
                return;
            }
            if (typeof callBack == 'function')
                callBack(data);
        },
        complete: function () {
            //$(".datagrid-mask,.datagrid-mask-msg").remove();
            //隐藏Loding
            hideLoading();
        }
    });
}
window.alert = function (msg, icon, callBack) {
    easyloader.load('messager', function () {
        $.messager.alert('系统提示', msg,
            (typeof icon == 'undefined' ? 'info' : icon),
            function () {
                if (typeof callBack == 'function') {
                    callBack();
                }
            });
    });
}
window.confirm = function (msg, okCallback, noCallback) {
    easyloader.load('messager', function () {
        $.messager.confirm('系统提示', msg, function (r) {
            if (r && typeof okCallback == 'function') {
                okCallback();
            } else if (typeof noCallback == 'function') {
                noCallback();
            }
        });
    });
}

// 顶部居中、几秒后自动消失的优雅提示（toast）
// type: success / error / warning / info；timeout 默认 2500ms
window.showToast = function (msg, type, timeout) {
    type = type || 'info';
    timeout = timeout || 2500;
    if (!document.getElementById('app-toast-style')) {
        var st = document.createElement('style');
        st.id = 'app-toast-style';
        st.type = 'text/css';
        st.innerHTML = '.app-toast-wrap{position:fixed;top:24px;left:50%;-webkit-transform:translateX(-50%);transform:translateX(-50%);z-index:99999;display:-webkit-box;display:flex;-webkit-box-orient:vertical;-webkit-box-direction:normal;flex-direction:column;-webkit-box-align:center;align-items:center;pointer-events:none}'
            + '.app-toast{min-width:180px;max-width:520px;margin-bottom:10px;padding:11px 22px;border-radius:6px;color:#fff;font-size:14px;line-height:1.5;-webkit-box-shadow:0 6px 20px rgba(0,0,0,.18);box-shadow:0 6px 20px rgba(0,0,0,.18);opacity:0;-webkit-transform:translateY(-12px);transform:translateY(-12px);-webkit-transition:all .28s ease;transition:all .28s ease;word-break:break-all;text-align:center}'
            + '.app-toast.show{opacity:1;-webkit-transform:translateY(0);transform:translateY(0)}'
            + '.app-toast .at-ico{margin-right:8px;font-weight:bold}'
            + '.app-toast-success{background:#52c41a}'
            + '.app-toast-error{background:#ff4d4f}'
            + '.app-toast-warning{background:#faad14}'
            + '.app-toast-info{background:#1890ff}';
        document.getElementsByTagName('head')[0].appendChild(st);
    }
    var wrap = document.getElementById('app-toast-wrap');
    if (!wrap) {
        wrap = document.createElement('div');
        wrap.id = 'app-toast-wrap';
        wrap.className = 'app-toast-wrap';
        document.body.appendChild(wrap);
    }
    var icoMap = { success: '\u2714', error: '\u2716', warning: '\u26A0', info: '\u2139' };
    var safe = String(msg == null ? '' : msg)
        .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/\n/g, '<br/>');
    var el = document.createElement('div');
    el.className = 'app-toast app-toast-' + type;
    el.innerHTML = '<span class="at-ico">' + (icoMap[type] || icoMap.info) + '</span>' + safe;
    wrap.appendChild(el);
    setTimeout(function () { el.className += ' show'; }, 10);
    setTimeout(function () {
        el.className = el.className.replace(' show', '');
        setTimeout(function () { if (el.parentNode) el.parentNode.removeChild(el); }, 300);
    }, timeout);
}

//随机字符
//len : 长度
//an：返回字符类型  a英文字符  n数字字符  不参值为英文数值混合
function randomStr(len, an) {
    an = an && an.toLowerCase();
    var str = "", i = 0, min = an == "a" ? 10 : 0, max = an == "n" ? 10 : 62;
    while (i++ < len) {
        var r = Math.random() * (max - min) + min << 0;
        str += String.fromCharCode(r += r > 9 ? r < 36 ? 55 : 61 : 48);
    }
    return str;
}
//获取URL参数
function getParam(name) {
    var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
    var r = window.location.search.substr(1).match(reg);
    if (r != null)
        return unescape(r[2]);
    return "";
}
//数据集合加载失败，提示用户数据加载失败
function loadError() {
    alert('没有查询到相应数据！');
}
//系统提示
function showMsg(data) {
    if (data && typeof data.code == 'number') {
        if (data.code == -1) {
            loginTimeoutCallback(data);
        } else {
            alert((data.msg ? data.msg : data.content), (data.code < 1 ? 'error' : 'info'));
        }
    }
}
//登录超时
function loginTimeoutCallback(data) {
    if (typeof data.code != "undefined" && data.code == -1) {
        var okFn = function () {
            top.window.location.reload();
        }
        var noFn = function () { }
        confirm((data.msg ? data.msg : data.content), okFn, noFn);
    }
}
//日期、时间格式化
function TimeFormatter(date) {
    return myformatter(date, true);
}
function DateFormatter(date) {
    return myformatter(date, false);
}
//日期控件转换函数
function myformatter(date, hasTime) {
    var y = date.getFullYear();
    var m = date.getMonth() + 1;
    var d = date.getDate();
    if (hasTime == true) {
        var h = date.getHours();
        var mi = date.getMinutes();
        var s = date.getSeconds();
        return y + '-' + (m < 10 ? ('0' + m) : m) + '-' + (d < 10 ? ('0' + d) : d) + ' ' + (h < 10 ? '0' + h : h) + ':' + (mi < 10 ? '0' + mi : mi) + ':' + (s < 10 ? '0' + s : s);
    }
    return y + '-' + (m < 10 ? ('0' + m) : m) + '-' + (d < 10 ? ('0' + d) : d);
}
function TimeParser(str) {
    return myparser(str, true);
}
function DateParser(str) {
    return myparser(str, false);
}
//时间转换函数
function myparser(str, hasTime) {

    if (!str) return new Date();

    var reg = new RegExp("(\\d+)-(\\d+)-(\\d+)\\s*?");
    if (hasTime == true) {
        reg = new RegExp("(\\d+)-(\\d+)-(\\d+)\\s*?(\\d+)\:(\\d+)\\:(\\d+)");
    }
    var ss = str.match(reg);
    var y = parseInt(ss[1], 10);
    var m = parseInt(ss[2], 10);
    var d = parseInt(ss[3], 10);

    if (hasTime == true) {

        var h = parseInt(ss[4], 10);
        var mi = parseInt(ss[5], 10);
        var s = parseInt(ss[6], 10);

        if (!isNaN(y) && !isNaN(m) && !isNaN(d) && !isNaN(h) && !isNaN(mi) && !isNaN(s)) {
            return new Date(y, m - 1, d, h, mi, s);
        } else {
            return new Date();
        }
    }

    if (!isNaN(y) && !isNaN(m) && !isNaN(d)) {
        return new Date(y, m - 1, d);
    } else {
        return new Date();
    }
}
//格式化钱
function formateMoney(value, rowData, rowIndex) {
    return '￥' + value;
}
//格式化数值
function formateIntNumber(value, rowData, rowIndex) {
    if (/^\d+((\.?)\d+)?$/.test(value))
        return Math.abs(value);
    return value;
}
//获取日期时间
function GetDate(bDay, hasTime) {
    //获取时间
    var dateNow = new Date();
    var i_milliseconds = dateNow.getTime();        //获取毫秒  
    if (typeof bDay == "number") {
        i_milliseconds += 1000 * 60 * 60 * 24 * bDay;
    }
    var now = new Date();
    now.setTime(i_milliseconds);


    var year = now.getFullYear();       //年
    var month = now.getMonth() + 1;     //月
    var day = now.getDate();            //日

    var hh = now.getHours();            //时
    var mm = now.getMinutes();          //分
    var sec = now.getSeconds();         //秒

    var clock = year + "-";

    if (month < 10)
        clock += "0";

    clock += month + "-";

    if (day < 10)
        clock += "0";

    clock += day;

    if (hasTime == true) {
        clock += " ";
        if (hh < 10)
            clock += "0";
        clock += hh + ":";
        if (mm < 10)
            clock += '0';
        clock += mm;
        clock = clock + ':' + sec;//秒
    }
    return (clock);
}
//获取某月第一天
function GetStartDate() {
    var now = new Date();
    var year = now.getFullYear();       //年
    var month = now.getMonth() + 1;     //月
    var day = "01";                     //日
    return year + "-" + month + "-" + day;
}
//返回两个日期相差的周数
function WeeksBetw(date1, date2) {
    return parseInt((Math.abs(date1.getTime() - date2.getTime()) / 1000 / 60 / 60 / 24 / 7), 10);
}
//获取周数范围
function GetWeekRangeData(_year, callBack) {
    request('/Service/WeekRange', { year: _year }, function (data) {
        if (typeof callBack == "function") {
            callBack(data);
        }
    });
}
//四舍五入
function decimal(num, v) {
    num = num + v * 0.1;
    var vv = Math.pow(10, v);
    return Math.round(num * vv) / vv;
}
//检查登录
function CheckOpt(callBack) {
    request("/Login/CheckLogin", {}, function (data) {
        if (data && typeof (data.code) != "undefined" && typeof (callBack) == "function") {
            switch (data.code) {
                case 1:
                    callBack();
                    break;
                default:
                    loginTimeoutCallback(data);
                    break;
            }
        }
    });
}
//初始化插件
function pluginInit() {
    if ($.fn.datagrid && $.fn.datagrid.defaults) {
        $.fn.datagrid.defaults.fitColumns = true;
    }
    if ($.fn.treegrid && $.fn.treegrid.defaults) {
        $.fn.treegrid.defaults.fitColumns = true;
    }
    jQuery.prototype.serializeObject = function () {
        var obj = new Object();
        $.each(this.serializeArray(), function (index, param) {
            if (!(param.name in obj)) {
                obj[param.name] = param.value;
            }
        });
        return obj;
    };
    //$.extend($.fn.combobox.methods, {
    //    selectedIndex: function (jq, index) {
    //        if (!index)
    //            index = 0;
    //        var data = $(jq).combobox('getData');
    //        if (data != null && data.length > 0) {
    //            var vf = $(jq).combobox('options').valueField;
    //            $(jq).combobox('setValue', eval('data[index].' + vf));
    //        }
    //    }
    //});
}

function applyAdaptiveGridColumns(id) {
    var grid = $('#' + id);
    if (grid.length < 1 || !grid.data('datagrid'))
        return;

    grid.datagrid('options').fitColumns = true;
    grid.datagrid('fitColumns');
}

//重置表格大小
function resizeGrid(id, w, h) {

    w = (typeof (w) == 'undefined' || w == 0) ? $(window).width() : w;
    h = (typeof (h) == 'undefined' || h == 0) ? $(window).height() : h;

    $('#' + id).datagrid('resize', {
        width: w,
        height: h
    });
    applyAdaptiveGridColumns(id);

}
//隐藏Loading
function hideLoading() {
    if ($('.main-loading') && $('.main-loading').is(':visible')) {
        $('.main-loading').addClass('animated fadeOut').promise().done(function () {
            $('.main-loading').remove();
        });
    }
}
//数据加载完成
function onLoaded(data) {
    if (!$('body').data('grid-init')) {
        $('body').data('grid-init', 1);
    }
    //隐藏Loding
    hideLoading();
    //提示消息
    showMsg(data);
}
//下载文件
function download(url, para) {

    var form;
    if ($('#downloadFrm').length > 0) {
        form = $('#downloadFrm');
        form.html('');
    } else {
        form = $('<form id="downloadFrm">');
        form.attr('action', url);
        form.attr('style', 'display:none');
        form.attr('method', 'POST');
        form.attr('target', '');

        $('body').append(form);//将表单放置在web中
    }
    //将做参数用的input放大form表单中
    for (var key in para) {
        var input = $('<input>');
        input.attr('type', 'hidden');
        input.attr('name', key);
        input.attr('value', para[key]);
        form.append(input);
    }

    form.submit();//表单提交
}
// 打开弹出窗口
function openWin(para) {
    easyloader.load(['dialog', 'form', 'combobox', 'numberbox'], function () {
        if (!$(para.winId).hasClass('easyui-dialog')) {
            $(para.winId).dialog({
                title: para.title,
                iconCls: para.iconCls ? para.iconCls : 'icon-help',
                width: para.width ? para.width : 350,
                height: para.height ? para.height : 350,
                resizable: false,
                modal: true
            });
        } else {
            $(para.winId).dialog('open');
        }
        if (typeof para.callBack == 'function')
            para.callBack();
    });
}
