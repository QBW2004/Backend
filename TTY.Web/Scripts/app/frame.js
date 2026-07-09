var borswer = window.navigator.userAgent.toLowerCase();
var isIE = borswer.indexOf("ie") >= 0;
var playSound = function () {
    if (isIE == true) {
        //IE内核浏览器，不支持 audio，则使用 embed 播放
        var embed;
        if (document.getElementById('embedPlay') == null) {
            embed = document.createElement('embed');
            embed.setAttribute('id', 'embedPlay');
            embed.setAttribute('name', 'embedPlay');
            embed.setAttribute('src', '/Upload/info.mp3');
            embed.setAttribute('autostart', true);
            embed.setAttribute('hidden', true);
            embed.setAttribute('loop', true);
            embed.setAttribute('enablejavascript', true);
            embed.setAttribute('volume', 100);
            document.body.appendChild(embed);
        } else {
            embed = document.getElementById('embedPlay');
        }
        setTimeout(function () {
            try {
                embed.play();
            } catch (e) { }
        }, 0)
    } else {
        //非IE内核浏览器，支持 audio
        var audio;
        if (document.getElementById("audioPlay") == null) {
            audio = document.createElement('audio');
            audio.setAttribute('id', 'audioPlay');
            audio.setAttribute('name', 'audioPlay');
            audio.setAttribute('src', '/Upload/info.mp3');
            audio.setAttribute('hidden', true);
            audio.setAttribute('autoplay', 'autoplay');
            audio.setAttribute('loop', 'loop');
            document.body.appendChild(audio);
            setTimeout(function () {
                try {
                    audio.play();
                } catch (e) { }
            }, 0)
        } else {
            audio = document.getElementById("audioPlay");
            audio.load();
        }
    }
}
function stopSound() {
    if (isIE == true) {
        try {
            if (document.getElementById('embedPlay') != null)
                document.getElementById('embedPlay').stop();//停止
        } catch (e) { }
    } else {
        try {
            if (document.getElementById("audioPlay") != null)
                document.getElementById("audioPlay").pause();//暂停
        } catch (e) { }
    }
}
//判断浏览器是否支持html5本地存储
function localStorageSupport() {
    return (('localStorage' in window) && window['localStorage'] !== null)
}
(function () {
    // 获取菜单数据
    function getMenus(callBack) {
        $.post("/Mgr/GetMenu", {}, function (json) {
            callBack(json && json.rows ? json.rows : []);
        }, "json");
    }
    // 侧边栏高度
    function fix_height() {
        var heightWithoutNavbar = $("body > #wrapper").height() - 61;
        $(".sidebard-panel").css("min-height", heightWithoutNavbar + "px");
    }
    // 菜单子项折叠
    function folderMenu(open) {
        body.toggleClass('mini-navbar');
        if (localStorageSupport) {
            localStorage.setItem("collapse_menu", body.hasClass('mini-navbar') ? 'on' : 'off');
        }
    }
    //计算元素集合的总宽度
    function calSumWidth(elements) {
        var width = 0;
        $(elements).each(function () {
            width += $(this).outerWidth(true);
        });
        return width;
    }
    //滚动到指定选项卡
    function scrollToTab(element) {
        var marginLeftVal = calSumWidth($(element).prevAll()), marginRightVal = calSumWidth($(element).nextAll());
        // 可视区域非tab宽度
        var tabOuterWidth = calSumWidth($(".content-tabs").children().not(".menu-tab-box"));
        //可视区域tab宽度
        var visibleWidth = $(".content-tabs").outerWidth(true) - tabOuterWidth;
        //实际滚动宽度
        var scrollVal = 0;
        if ($(".page-tabs-content").outerWidth() < visibleWidth) {
            scrollVal = 0;
        } else if (marginRightVal <= (visibleWidth - $(element).outerWidth(true) - $(element).next().outerWidth(true))) {
            if ((visibleWidth - $(element).next().outerWidth(true)) > marginRightVal) {
                scrollVal = marginLeftVal;
                var tabElement = element;
                while ((scrollVal - $(tabElement).outerWidth()) > ($(".page-tabs-content").outerWidth() - visibleWidth)) {
                    scrollVal -= $(tabElement).prev().outerWidth();
                    tabElement = $(tabElement).prev();
                }
            }
        } else if (marginLeftVal > (visibleWidth - $(element).outerWidth(true) - $(element).prev().outerWidth(true))) {
            scrollVal = marginLeftVal - $(element).prev().outerWidth(true);
        }
        $('.page-tabs-content').animate({
            marginLeft: 0 - scrollVal + 'px'
        }, "fast");
    }
    // 关闭其他选项卡
    function closeOtherTabs() {
        $('.page-tabs-content').children("[data-id]").not(":first").not(".active").each(function () {
            $('.J_iframe[data-id="' + $(this).data('id') + '"]').remove();
            $(this).remove();
        });
        $('.page-tabs-content').css("margin-left", "0");
        setTimeout(function () {
            try { $('.J_iframe').get(1).contentWindow.location.reload(true); } catch (e) { }
        },100)
    }
    //查看左侧隐藏的选项卡
    function scrollTabLeft() {
        var marginLeftVal = Math.abs(parseInt($('.page-tabs-content').css('margin-left')));
        // 可视区域非tab宽度
        var tabOuterWidth = calSumWidth($(".content-tabs").children().not(".menu-tab-box"));
        //可视区域tab宽度
        var visibleWidth = $(".content-tabs").outerWidth(true) - tabOuterWidth;
        //实际滚动宽度
        var scrollVal = 0;
        if ($(".page-tabs-content").width() < visibleWidth) {
            return false;
        } else {
            var tabElement = $(".menu-tab:first");
            var offsetVal = 0;
            while ((offsetVal + $(tabElement).outerWidth(true)) <= marginLeftVal) {//找到离当前tab最近的元素
                offsetVal += $(tabElement).outerWidth(true);
                tabElement = $(tabElement).next();
            }
            offsetVal = 0;
            if (calSumWidth($(tabElement).prevAll()) > visibleWidth) {
                while ((offsetVal + $(tabElement).outerWidth(true)) < (visibleWidth) && tabElement.length > 0) {
                    offsetVal += $(tabElement).outerWidth(true);
                    tabElement = $(tabElement).prev();
                }
                scrollVal = calSumWidth($(tabElement).prevAll());
            }
        }
        $('.page-tabs-content').animate({
            marginLeft: 0 - scrollVal + 'px'
        }, "fast");
    }
    //查看右侧隐藏的选项卡
    function scrollTabRight() {
        var marginLeftVal = Math.abs(parseInt($('.page-tabs-content').css('margin-left')));
        // 可视区域非tab宽度
        var tabOuterWidth = calSumWidth($(".content-tabs").children().not(".menu-tab-box"));
        //可视区域tab宽度
        var visibleWidth = $(".content-tabs").outerWidth(true) - tabOuterWidth;
        //实际滚动宽度
        var scrollVal = 0;
        if ($(".page-tabs-content").width() < visibleWidth) {
            return false;
        } else {
            var tabElement = $(".menu-tab:first");
            var offsetVal = 0;
            while ((offsetVal + $(tabElement).outerWidth(true)) <= marginLeftVal) {//找到离当前tab最近的元素
                offsetVal += $(tabElement).outerWidth(true);
                tabElement = $(tabElement).next();
            }
            offsetVal = 0;
            while ((offsetVal + $(tabElement).outerWidth(true)) < (visibleWidth) && tabElement.length > 0) {
                offsetVal += $(tabElement).outerWidth(true);
                tabElement = $(tabElement).next();
            }
            scrollVal = calSumWidth($(tabElement).prevAll());
            if (scrollVal > 0) {
                $('.page-tabs-content').animate({
                    marginLeft: 0 - scrollVal + 'px'
                }, "fast");
            }
        }
    }
    // 激活选项卡
    function menuItem() {
        // 获取标识数据
        var dataUrl = $(this).attr('href'),
            dataIndex = $(this).data('index'),
            menuName = $.trim($(this).text()),
            flag = true;
        if (dataUrl == undefined || $.trim(dataUrl).length == 0) return false;

        // 选项卡菜单已存在
        $('.menu-tab').each(function () {
            if ($(this).data('id') == dataUrl) {
                if (!$(this).hasClass('active')) {
                    $(this).addClass('active').siblings('.menu-tab').removeClass('active');
                    scrollToTab(this);
                    // 显示tab对应的内容区
                    $('.J_mainContent .J_iframe').each(function () {
                        var target = $('.J_iframe[data-id="' + $(this).data('id') + '"]');
                        var url = target.attr('src');

                        if ($(this).data('id') == dataUrl) {
                            $(this).show().siblings('.J_iframe').hide();
                            return false;
                        }
                    });
                }
                try { $('.J_iframe[data-id="' + $(this).data('id') + '"][src="' + dataUrl + '"]').get(0).contentWindow.location.reload(true); } catch (e) { }
                flag = false;
                return false;
            }
        });

        // 选项卡菜单不存在
        if (flag) {
            var str = '<a href="javascript:void(0);" class="active menu-tab" data-id="' + dataUrl + '">' + menuName + ' <i class="fa fa-times-circle"></i></a>';
            $('.menu-tab').removeClass('active');

            // 添加选项卡对应的iframe
            var str1 = '<iframe class="J_iframe" name="iframe' + dataIndex + '" width="100%" height="100%" src="' + dataUrl + '" frameborder="0" data-id="' + dataUrl + '" seamless></iframe>';
            $('.J_mainContent').find('iframe.J_iframe').hide().parents('.J_mainContent').append(str1);

            ////显示loading提示
            //var loading = layer.load();
            //$('.J_mainContent iframe:visible').load(function () {
            //    //iframe加载完成后隐藏loading提示
            //    layer.close(loading);
            //});
            // 添加选项卡
            $('.menu-tab-box .page-tabs-content').append(str);
            scrollToTab($('.menu-tab.active'));
        }
        return false;
    }
    // 关闭选项卡菜单
    function closeTab() {
        var closeTabId = $(this).parents('.menu-tab').data('id');
        var currentWidth = $(this).parents('.menu-tab').width();

        // 当前元素处于活动状态
        if ($(this).parents('.menu-tab').hasClass('active')) {

            // 当前元素后面有同辈元素，使后面的一个元素处于活动状态
            if ($(this).parents('.menu-tab').next('.menu-tab').length > 0) {

                var activeId = $(this).parents('.menu-tab').next('.menu-tab:eq(0)').data('id');
                $(this).parents('.menu-tab').next('.menu-tab:eq(0)').addClass('active');

                $('.J_mainContent .J_iframe').each(function () {
                    if ($(this).data('id') == activeId) {
                        $(this).show().siblings('.J_iframe').hide();
                        return false;
                    }
                });

                var marginLeftVal = parseInt($('.page-tabs-content').css('margin-left'));
                if (marginLeftVal < 0) {
                    $('.page-tabs-content').animate({
                        marginLeft: (marginLeftVal + currentWidth) + 'px'
                    }, "fast");
                }

                //  移除当前选项卡
                $(this).parents('.menu-tab').remove();

                // 移除tab对应的内容区
                $('.J_mainContent .J_iframe').each(function () {
                    if ($(this).data('id') == closeTabId) {
                        $(this).remove();
                        return false;
                    }
                });
            }

            // 当前元素后面没有同辈元素，使当前元素的上一个元素处于活动状态
            if ($(this).parents('.menu-tab').prev('.menu-tab').length > 0) {
                var activeId = $(this).parents('.menu-tab').prev('.menu-tab:last').data('id');
                $(this).parents('.menu-tab').prev('.menu-tab:last').addClass('active');
                $('.J_mainContent .J_iframe').each(function () {
                    if ($(this).data('id') == activeId) {
                        try { $('.J_iframe[data-id="' + $(this).data('id') + '"]').get(0).contentWindow.location.reload(true); } catch (e) { }
                        $(this).show().siblings('.J_iframe').hide();
                        return false;
                    }
                });

                //  移除当前选项卡
                $(this).parents('.menu-tab').remove();

                // 移除tab对应的内容区
                $('.J_mainContent .J_iframe').each(function () {
                    if ($(this).data('id') == closeTabId) {
                        $(this).remove();
                        return false;
                    }
                });
            }
        }
        // 当前元素不处于活动状态
        else {
            //  移除当前选项卡
            $(this).parents('.menu-tab').remove();

            // 移除相应tab对应的内容区
            $('.J_mainContent .J_iframe').each(function () {
                if ($(this).data('id') == closeTabId) {
                    $(this).remove();
                    return false;
                }
            });
            scrollToTab($('.menu-tab.active'));
        }
        return false;
    }
    // 滚动到已激活的选项卡
    function showActiveTab() {
        scrollToTab($('.menu-tab.active'));
    }
    // 点击选项卡菜单
    function activeTab() {
        try { $('.J_iframe[data-id="' + $(this).data('id') + '"]').get(0).contentWindow.location.reload(true); } catch (e) { }

        if (!$(this).hasClass('active')) {
            var currentId = $(this).data('id');
            // 显示tab对应的内容区
            $('.J_mainContent .J_iframe').each(function () {
                if ($(this).data('id') == currentId) {
                    $(this).show().siblings('.J_iframe').hide();
                    return false;
                }
            });
            $(this).addClass('active').siblings('.menu-tab').removeClass('active');
            scrollToTab(this);
        }
    }
    // 刷新iframe
    function refreshTab() {
        //var target = $('.J_iframe[data-id="' + $(this).data('id') + '"]');
        //var url = target.attr('src');
        ////显示loading提示
        //var loading = layer.load();
        //target.attr('src', url).load(function () {
        //    //关闭loading提示
        //    layer.close(loading);
        //});
    }

    $(function () {
        var body = $('body');

        /*
        // 获取菜单
        getMenus(function (data) {
            // 初始化菜单
            var html = '';
            for (var i = 0; i < data.length; i++) {
                html += '<li ' + (i == 0 ? 'class="active"' : '') + '>';
                html += '    <a href="#">';
                html += '        <i class="fa fa-home"></i>';
                html += '        <span class="nav-label">' + data[i].title + '</span>';
                html += '        <span class="fa arrow"></span>';
                html += '    </a>';
                html += '    <ul class="nav nav-second-level" style="overflow-y: auto;">';
                for (var j = 0; j < data[i].children.length; j++) {
                    html += '        <li><a class="menu-item" href="' + data[i].children[j].link + '">' + data[i].children[j].title + '</a></li>';
                }
                html += '    </ul>';
                html += '</li>';
            }

            // MetsiMenu
            $('#side-menu').html(html).metisMenu();

            //通过遍历给菜单项加上data-index属性
            $(".menu-item").each(function (index) {
                if (!$(this).attr('data-index')) {
                    $(this).attr('data-index', index);
                }
            });
            // 菜单点击
            $(".menu-item").click(menuItem);
        });*/

        // MetsiMenu
        $('#side-menu').metisMenu();

        //通过遍历给菜单项加上data-index属性
        $(".menu-item").each(function (index) {
            if (!$(this).attr('data-index')) {
                $(this).attr('data-index', index);
            }
        });
        // 菜单点击
        $(".menu-item").click(menuItem);

        /////////////////////////////////////////////////////////
        // 侧边栏高度
        fix_height();
        $(window).bind("load resize click scroll", function () {
            if (!body.hasClass('body-small')) {
                fix_height();
            }
        });
        //侧边栏滚动
        $(window).scroll(function () {
            if ($(window).scrollTop() > 0 && !$('body').hasClass('fixed-nav')) {
                $('#right-sidebar').addClass('sidebar-top');
            } else {
                $('#right-sidebar').removeClass('sidebar-top');
            }
        });
        // Safari浏览器兼容性处理
        if (/(iPhone|iPad|iPod|iOS)/i.test(navigator.userAgent)) {
            //$('#content-main').css('overflow-y', 'auto');
        }
        $(window).bind("load resize", function () {
            if ($(this).width() < 769) {
                $('body').addClass('mini-navbar');
                $('.navbar-static-side').fadeIn();
            }
        });
        /////////////////////////////////////////////////////////
        // 折叠菜单
        $('.nav-header').click(function () {
            if (body.hasClass('mini-navbar')) {
                folderMenu(false);
                $('#collapsemenu').prop('checked', false);
            }
        });
        // 主题设置
        $('#skin-list>div').click(function () {
            body.removeClass("skin-1").removeClass("skin-2").removeClass("skin-3");
            // 默认主题
            // 蓝色主题 skin-1
            // 黄色主题 skin-3
            var skin = $(this).attr('data-skin');
            if (skin.length > 0) {
                body.addClass(skin);
            }
            localStorage.setItem("skin", skin);
            $('#btn-set-skin').dropdown('toggle');
        });
        // 缓存主题
        if (localStorageSupport) {
            var skin = localStorage.getItem("skin");
            if (skin && skin.length > 0) {
                body.removeClass('skin-1').removeClass('skin-3').addClass(skin);
            }
        }
        /////////////////////////////////////////////////////////

        // 关闭选项卡菜单
        $('.menu-tab-box').delegate('a.menu-tab i', 'click', closeTab);
        // 点击选项卡菜单
        $('.menu-tab-box').delegate('a.menu-tab', 'click', activeTab);
        
        // 定位当前选项卡
        $('.J_tabShowActive').on('click', showActiveTab);
        // 关闭其他选项卡
        $('.J_tabCloseOther').on('click', closeOtherTabs);
        // 关闭全部选项卡
        $('.J_tabCloseAll').on('click', function () {
            $('.page-tabs-content').children("[data-id]").not(":first").each(function () {
                $('.J_iframe[data-id="' + $(this).data('id') + '"]').remove();
                $(this).remove();
            });
            $('.page-tabs-content').children("[data-id]:first").each(function () {
                $('.J_iframe[data-id="' + $(this).data('id') + '"]').show();
                $(this).addClass("active");
            });
            $('.page-tabs-content').css("margin-left", "0");
        });
        
        // 左移按扭
        $('.J_tabLeft').on('click', scrollTabLeft);
        // 右移按扭
        $('.J_tabRight').on('click', scrollTabRight);
        
        // 右键菜单
        $('.page-tabs-content').delegate('a.menu-tab', "contextmenu", function (e) {
            //当点击鼠标右键，显示菜单
            if (e.which == 3) {
                // 显示自定义菜单
                $("#menu").css({
                    //定义菜单显示位置为事件发生的X坐标和Y坐标
                    top: e.pageY - 5,
                    left: e.pageX - 5
                }).show();
            }
            e.stopPropagation();
            return false;
        }).delegate('a.menu-tab', 'mousedown', function (e) {
            // 鼠标中键点击
            if (e.which == 2) {
                if ($(this).find('i')) {
                    $(this).find('i').trigger('click');
                }
            }
        });
        
        // 关闭Tab的鼠标右键菜单
        $('#menu').on('mouseleave', function () {
            $('#menu').slideUp(100);
        });
        $('.nav-header ul').on('mouseleave', function () {
            $('#lnkUsrSet').dropdown('toggle');
        });
    })
})();