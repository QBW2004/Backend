
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
        $('#tb_Advert').datagrid({
            url: "/Game/AdvertMgr/Index",
            queryParams: $.extend({}, para),
            pagination: true,
            singleSelect: true,
            idField: 'AdID',
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
            }
        });
    } else {
        $('#tb_Advert').datagrid('load', para);
    }
}
//格式化
function formateAdType(value, rowData, rowIndex) {
    return value == 1 ? '分享类' : '<span class="red">独占类</span>';
}
function formateIsUsr(value, rowData, rowIndex) {
    return value == 0 ? '<span class="red">广告商</span>' : '一般用户';
}
function formateIsEnable(value, rowData, rowIndex) {
    var arr = [];
    if (rowData.IsUsr == 0) {
        if (value == 0)
            arr.push('<span class="red">禁用</span>');
        else
            arr.push('<span class="green">启用</span>');

        arr.push('<a class="Lmg10" href="javascript:void(0);" onclick="showWin(' + rowData.AdID + ');">编辑</a> ');
    }
    return arr.join('');
}
//重置表格大小
function setGridSize(param) {
    var w = $(window).width() - 10;
    var h = $(window).height() - 78;
    resizeGrid('tb_Advert', 'auto', h);
}
//打开窗口
function showWin(id) {
    easyloader.load(['dialog', 'form'], function () {

        if (!$('#addWin').hasClass('easyui-dialog')) {
            $('#addWin').dialog({
                title: '【编辑信息】',
                iconCls: 'icon-user_edit',
                width: 350,
                height: 350,
                resizable: false,
                modal: true
            });
        } else {
            $('#addWin').dialog('open');
        }

        //取值
        var rowIndex = $('#tb_Advert').datagrid('getRowIndex', id);//id是关键字值
        var data = $('#tb_Advert').datagrid('getData').rows[rowIndex];
        $('#txtNickName').textbox('setValue', data.NickName);

        $('#cbxIsEnable').checkbox(data.IsEnable == 0 ? 'uncheck' : 'check');
        $('#cbxIsEnable').checkbox('setValue', data.IsEnable);

        $('#hfAdID').val(id);
        $('#hfOpenID').val(data.OpenID);
    });
}
//设置状态
function setAdvertEnable(adid, flag) {
    confirm('确认' + (flag === 1 ? '启用' : '禁用') + '广告商？', function () {
        request('/Game/AdvertMgr/SetEnable', { AdID: adid, IsEnable: flag }, function (data) {
            showMsg(data);
            if (data.code == 1) {
                queryData();
            }
        });
    });
}

//保存
function saveAdvert() {
    var para = $('#form2').serializeObject();
    if (para.AdID == 0) {
        alert('获取标识失败！', 'warning');
        return;
    }
    if ($.trim(para.NickName) == "") {
        alert('昵称不能为空！', 'warning');
        return;
    }
    para.IsEnable = ($('#cbxIsEnable').checkbox('options').checked == true ? 1 : 0);

    confirm('确认修改广告商？', function () {
        request('/Game/AdvertMgr/Edit', para, function (data) {
            showMsg(data);
            if (data.code == 1) {
                queryData();
                $('#addWin').dialog('close');
            }
        });
    });
}