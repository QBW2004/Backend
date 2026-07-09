
$(function () {
    // 加载指定的模块
    easyloader.load(['textbox', 'linkbutton', 'datagrid'], function () {
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

//重置表格大小
function setGridSize(param) {
    var w = $(window).width() - 8;
    var h = $(window).height() - 78;
    resizeGrid('tb_Roles', 'auto', h);
}

var selectRoleId = 0;
//查询数据
function queryData() {
    var para = $("#frm_srch").serializeObject();
    bindGridData(para);
}
//绑定表格数据
function bindGridData(para) {
    if (!$('body').data('grid-init')) {
        $('#tb_Roles').datagrid({
            url: "/Mgr/GetRoleGridList",
            queryParams: $.extend({}, para),
            pagination: true,
            fitColumns: true,
            singleSelect: true,
            height: 768,
            pageSize: 1000,
            pageList: [1000],
            idField: 'RoleID',
            onBeforeLoad: setGridSize,
            onLoadSuccess: onLoaded
        });
    } else {
        $('#tb_Roles').datagrid('load', para);
    }
}
//格式化
function formateOpt(value, rowData, rowIndex) {
    var arr = [];
    if (rowData.RoleID != 1) {
        arr.push('<a class="Lmg10" href="javascript:void(0)" onclick="deleteRole(' + rowData.RoleID + ')">删除</a>');
    }
    return arr.join('');
}
//删除角色
function deleteRole(roleId) {
    confirm('确认删除选择的角色？', function () {
        request('/Mgr/DelRole', { RoleID: roleId }, function (data) {
            //提示消息
            showMsg(data);
            if (data && data.code == 1) {
                queryData();//重新加载数据
            }
        });
    });
}
//显示角色添加窗口
function showAddRole() {
    easyloader.load(['dialog', 'form'], function () {
        if (!$('#addRoleWin').hasClass('easyui-dialog')) {
            $('#addRoleWin').dialog({
                title: '【添加角色】',
                iconCls: 'icon-user_add',
                width: 350,
                height: 260,
                resizable: false,
                modal: true
            });
        } else {
            $('#form1').form('reset');
            $('#addRoleWin').dialog('open');
        }
    });
}
//添加角色
function addRole() {
    var para = $('#form1').serializeObject();
    request('/Mgr/AddRole', para, function (data) {
        //提示消息
        showMsg(data);
        if (data && data.code == 1) {
            $('#addRoleWin').dialog('close');
            $('#form1').form('reset');
            queryData();//重新绑定表格数据
        }
    });
}
