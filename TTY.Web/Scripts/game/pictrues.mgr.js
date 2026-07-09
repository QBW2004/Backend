
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
        //bindQuestionCategory();
        //初始化查询
        queryData();
        //控件附加属性
        //$('input[maxlength]').each(function (i, ele) {
        //    $(ele).next().find('.textbox-text').attr('maxlength', $(ele).attr('maxlength'));
        //});
        //var _comboSel = $('#selSQuestionCategory,#selEQuestionCategory').next().find('.textbox-text');
        //_comboSel.prop("readonly", true).mousedown(function () {
        //    $(this).prev().find('.combo-arrow').trigger('click');
        //});
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
        $('#tb_Pictures').datagrid({
            url: "/Game/PicturesMgr/Index",
            queryParams: $.extend({}, para),
            pagination: true,
            singleSelect: true,
            idField: 'PID',
            height: 768,
            onBeforeLoad: function () { },
            onLoadError: function () {
                //隐藏Loding
                hideLoading();
                setGridSize();
                console.log('加载出错！')
            },
            onLoadSuccess: function (data) {
                onLoaded(data);
                setGridSize();
                try { $("a.fancybox_lnk").fancybox(); } catch (e) { console.log(e); }
            }
        });
    } else {
        $('#tb_Pictures').datagrid('load', para);
    }
}
//格式化
function formateImg(value, rowData, rowIndex) {
    return '<a class="fancybox_lnk" href="' + value + '">' + value + '</a>';
}
function formateDec(value, rowData, rowIndex) {
    return value == 0 ? '<span class="red">广告图</span>' : '<span class="green">分享图</span>';
}
function formateOpt(value, rowData, rowIndex) {
    var arr = [];
    //arr.push('<a class="Lmg10" href="javascript:void(0)" onclick="editFunc(' + rowData.PID + ')">编辑</a>');
    arr.push('<a href="javascript:void(0)" onclick="deleteFunc(' + rowData.PID + ')">删除</a>');
    return arr.join('');
}
//重置表格大小
function setGridSize(param) {
    var w = $(window).width() - 10;
    var h = $(window).height() - 78;
    resizeGrid('tb_Pictures', 'auto', h);
}
//删除题目
function deleteFunc(id) {
    confirm('确认删除该图片？', function () {
        request('/Game/PicturesMgr/Delete/' + id, {}, function (data) {
            showMsg(data);
            if (data.code == 1) {
                queryData();
            }
        });
    });
}
//编辑
function editFunc(id) {
    showAddWin(id);
}
//显示添加窗口
function showAddWin(id) {
    easyloader.load(['dialog', 'form'], function () {
        if (!$('#addWin').hasClass('easyui-dialog')) {
            $('#addWin').dialog({
                title: '【添加图片信息】',
                iconCls: 'icon-page_add',
                width: 450,
                height: 360,
                resizable: false,
                modal: true
            });
        } else {
            $('#addWin').dialog('open');
        }

        var pWin = $('#addWin').closest('.window');
        $('#hfPID').remove();
        if (typeof id != 'undefined') {
            pWin.find('.panel-title').text('【编辑图片信息】');
            pWin.find('.panel-icon').removeClass('icon-page_add').addClass('icon-page_edit');
            // 取值
            var rowIndex = $('#tb_Pictures').datagrid('getRowIndex', id);//id是关键字值
            var data = $('#tb_Pictures').datagrid('getData').rows[rowIndex];
            // 控件赋值
            $('#selEPicType').combobox('setValue', data.PicType);
            $('#txtOpenID').textbox('setValue', data.OpenID);
            $('#txtPicText').textbox('setValue', data.PicText);

            $('<input type="hidden" id="hfPID" name="PID" value="' + id + '"/>').prependTo('#form1');
        } else {
            pWin.find('.panel-title').text('【添加图片信息】');
            pWin.find('.panel-icon').removeClass('icon-page_edit').addClass('icon-page_add');
            $('#form1').form('reset');
        }
    });
}