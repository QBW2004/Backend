
$(function () {
    easyloader.load(['textbox', 'combobox', 'linkbutton', 'datagrid'], function () {
        //适应窗口大小变化
        $(window).resize(function () {
            if ($('body').data('grid-init')) {
                setGridSize();
            }
        });
        //初始化插件
        pluginInit();
        //初始化查询
        queryData();
    });
});
//查询数据
function queryData() {
    var para = $("#frm_srch").serializeObject();
    bindGridData(para);
}
//绑定表格数据
function bindGridData(para) {
    if (!$('body').data('grid-init')) {
        $('#tb_AdvertReport').datagrid({
            url: "/Game/AdvertMgr/AdvertReport",
            queryParams: $.extend({}, para),
            pagination: true,
            singleSelect: true,
            idField: 'AdID',
            height: 768,
            onBeforeLoad: setGridSize,
            onLoadSuccess: function (data) {
                onLoaded(data);
            }
        });
    } else {
        $('#tb_AdvertReport').datagrid('load', para);
    }
}
//重置表格大小
function setGridSize(param) {
    var w = $(window).width() - 10;
    var h = $(window).height() - 78;
    resizeGrid('tb_AdvertReport', 'auto', h);
}