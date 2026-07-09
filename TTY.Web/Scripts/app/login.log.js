
$(function () {
    easyloader.load(['datetimebox', 'textbox', 'linkbutton', 'datagrid'], function () {
        //适应窗口大小变化
        $(window).resize(function () {
            if ($('body').data('grid-init')) {
                setGridSize();
            }
        });
        $('#sTime').datebox().datebox('calendar').calendar({
            validator: validDateSel
        });
        $('#eTime').datebox().datebox('calendar').calendar({
            validator: validDateSel
        });
        //重置时间控件
        resetDateCtrl();
        //初始化插件
        pluginInit();
        //初始化查询
        queryData();
    });
});
//重置时间控件
function resetDateCtrl() {
    $('#sTime').datetimebox('setValue', GetDate(-7));
    $('#eTime').datetimebox('setValue', GetDate(0) + ' 23:59:59');
}
//验证日期选择
function validDateSel(date) {
    var now = new Date();
    var y = now.getFullYear();
    var m = now.getMonth();
    var d = now.getDate() + 1;
    var dt = new Date(y, m, d);
    return date < dt;
}
//查询数据
function queryData() {
    var para = $("#frm_srch").serializeObject();
    bindGridData(para);
}
//绑定表格数据
function bindGridData(para) {
    if (!$('body').data('grid-init')) {
        $('#tb_LoginLogList').datagrid({
            url: "/Login/LoginLog",
            queryParams: $.extend({}, para),
            pagination: true,
            singleSelect: true,
            height: 500,
            onBeforeLoad: setGridSize,
            onLoadSuccess: onLoaded
        });
    } else {
        $('#tb_LoginLogList').datagrid('load', para);
    }
}
//重置表格大小
function setGridSize(param) {
    var w = $(window).width() - 10;
    var h = $(window).height() - $('#frm_srch').outerHeight() - 37;
    resizeGrid('tb_LoginLogList', 'auto', h);
}