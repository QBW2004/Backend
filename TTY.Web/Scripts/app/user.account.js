
$(function () {

    //隐藏Loding
    hideLoading();

    // 加载指定的模块
    easyloader.load(['textbox', 'linkbutton', 'combotree', 'datagrid'], function () {
        //    //适应窗口大小变化
        //    //$(window).resize(function () {
        //    //    if ($('body').data('grid-init')) {
        //    //        setGridSize();
        //    //    }
        //    //});
        //    //初始化插件
        //    pluginInit();
        //    //绑定查询用角色下拉
        //    //bindQerySelRole();
        binSelUserType();
        //    //初始化查询
        //    //queryData();
    });
});


//重置表格大小
function setGridSize() {
    var w = $(window).width() - 8;
    var h = $(window).height() - 77;
    resizeGrid('tb_Users', 'auto', h);
}
var selectRoleId = 0;
//查询数据
function queryData() {
    var para = $("#frm_srch").serializeObject();
    if ($('#tree_roles').hasClass('tree')) {
        var node = $('#tree_roles').tree('getSelected');
        if (node != null) {
            para.RoleID = node.id;
            selectRoleId = node.id;
        }
    }
    bindGridData(para);
}

//绑定用户类型下拉列表
function binSelUserType() {
    $('#selUserType').combotree('clear');
    getRolesData(function (data) {
        $('#selUserType').combotree('loadData', data.children);
    });
}

//绑定表格数据
function bindGridData(para) {
    if (!$('body').data('grid-init')) {
        $('#tb_Users').datagrid({
            url: "/Mgr/GetUserList",
            queryParams: $.extend({}, para),
            pagination: true,
            fitColumns: true,
            singleSelect: true,
            striped: true,
            rownumbers: true,
            height: 768,
            pageSize: 1000,
            pageList: [1000],
            idField: 'UserID',
            onBeforeLoad: setGridSize,
            onLoadSuccess: onLoaded
        });
    } else {
        $('#tb_Users').datagrid('load', para);
    }
}
// 格式化
function formateStatus(value, rowData, rowIndex) {
    if (value == 1)
        return '<span class="red">禁用</span>';
    else
        return '<span class="green">正常</span>';
}
function formateOpt(value, rowData, rowIndex) {
    var arr = [];
    if (rowData.UserID != 1) {
        arr.push('<a href="javascript:void(0)" onclick="showAddUser(' + rowData.UserID + ')">编辑</a>');
        arr.push('<a class="Lmg10" href="javascript:void(0)" onclick="deleteUser(' + rowData.UserID + ')">删除</a>');
    }
    return arr.join('');
}

//获取角色数据
function getRolesData(fn) {
    request('/Game/GetRoleList', {}, function (data) {
        //提示消息
        showMsg(data);
        if (data.code)
            return;
        if (typeof fn == "function") {
            fn(data);
        }
    });
}
//绑定查询条件中角色下拉
function bindQerySelRole() {
    getRolesData(function (data) {
        data.text = '----全部数据----';
        $('#selRole').combotree('loadData', [data]);
    });
}
//绑定角色下拉列表
function binSelRoles() {
    $('#selUserRole').combotree('clear');
    getRolesData(function (data) {
        $('#selUserRole').combotree('loadData', data.children);
    });
}

//显示用户添加窗口
function showAddUser(userID) {
    easyloader.load(['dialog', 'form'], function () {
        $('#txtUName,#txtUAccounts,#txtUPwd,#txtRemark,#hfUserID').val('');

        if (!$('#addUserWin').hasClass('easyui-dialog')) {
            $('#addUserWin').dialog({
                title: '【添加用户】',
                iconCls: 'icon-user_add',
                width: 350,
                height: 350,
                resizable: false,
                modal: true
            });
        } else {
            $('#addUserWin').dialog('open');
        }

        var pWin = $('#addUserWin').closest('.window');
        $('#trTip1,#trTip2').toggleClass('hide');
        //传用户ID时为编辑状态
        if (typeof userID != 'undefined' && parseInt(userID, 10) > 0) {
            pWin.find('.panel-title').text('【编辑用户】');
            pWin.find('.panel-icon').removeClass('icon-user_add').addClass('icon-user_edit');

            //编辑用户信息
            var rowIndex = $('#tb_Users').datagrid('getRowIndex', userID);//id是关键字值
            var data = $('#tb_Users').datagrid('getData').rows[rowIndex];

            //角色
            var tr = $('#selUserRole').combotree('tree');
            var sel_node = tr.tree('find', parseInt(data.Roles, 10));
            if (sel_node != null) {
                $('#selUserRole').combotree('setText', sel_node.text).combotree('setValue', sel_node.id);
            }
            $('#txtUName').textbox('setValue', data.UserName);
            $('#txtUAccounts').textbox('setValue', data.Accounts);
            $('#txtUPwd').textbox('setValue', '');
            $('#txtRemark').textbox('setValue', data.Remark);
            $('#hfUserID').val(userID);
        } else {
            //角色
            var treeData = $('#selUserRole').combotree('options').data;
            if (treeData != null && treeData.length > 0) {
                var selectData = treeData[0];
                $('#selUserRole').combotree('setText', selectData.text).combotree('setValue', selectData.id);
            }

            $('#selUserRole').combotree('setValue', "1");
            $('#hfUserID').val(0);
            pWin.find('.panel-title').text('【添加用户】');
            pWin.find('.panel-icon').removeClass('icon-user_edit').addClass('icon-user_add');

            //添加用户信息
            $('#txtUPwd').textbox('setValue', randomStr(6));
        }
    });
}
//保存用户信息
function SaveUser() {
    var para = $('#form2').serializeObject();

    var url = '/Mgr/AddUser';
    if (parseInt(para.UserID, 10) > 0)
        url = '/Mgr/EditUser';

    request(url, para, function (data) {
        //提示消息
        showMsg(data);
        if (data && data.code == 1) {
            $('#addUserWin').dialog('close');
            $('#form2').form('reset');
            queryData();//重新加载表格数据
        }
    });
}

//删除用户
function deleteUser(userID) {
    confirm('确认删除用户？', function () {
        request('/Mgr/DelUser', { UserID: userID }, function (data) {
            //提示消息
            showMsg(data);
            if (data && data.code == 1) {
                queryData();//重新加载表格数据
            }
        });
    });
}