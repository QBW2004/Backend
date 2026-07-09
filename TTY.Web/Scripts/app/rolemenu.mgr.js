
$(function () {
    // 加载指定的模块
    easyloader.load(['textbox', 'linkbutton', 'combotree', 'tree', 'datagrid'], function () {
        //适应窗口大小变化
        $(window).resize(function () {
            if ($('body').data('grid-init')) {
                setGridSize();
            }
        });
        //初始化插件
        pluginInit();
        //加载角色
        bindTree();
        //初始化查询
        queryData();
    });
});

//重置表格大小
function setGridSize(param) {
    var w = $(window).width() - 198;
    var h = $(window).height() - 65;
    resizeGrid('tb_Menus', 'auto', h);
}

var selectRoleId = 0;
//查询数据
function queryData() {
    var para = $("#frm_srch").serializeObject();
    if ($('#tree_roles').hasClass('tree')) {
        var node = $('#tree_roles').tree('getSelected');
        if (node != null) {
            selectRoleId = node.id;
        }
    }
    bindGridData(para);
}
//绑定表格数据
function bindGridData(para) {
    if (!$('body').data('grid-init')) {
        $('#tb_Menus').datagrid({
            url: "/Mgr/GetAllMenus",
            queryParams: $.extend({}, para),
            pagination: true,
            fitColumns: true,
            singleSelect: true,
            height: 768,
            pageSize: 1000,
            pageList: [1000],
            onBeforeLoad: setGridSize,
            onLoadSuccess: onLoaded
        });
    } else {
        $('#tb_Menus').datagrid('load', para);
    }
}
//格式化
function formateStatus(value, rowData, rowIndex) {
    if (value == 1)
        return '<span class="red">禁用</span>';
    else
        return '<span class="green">正常</span>';
}
function formateLink(value, rowData, rowIndex) {
    if (rowData.IsMenu == 1)
        return value;
    return '';
}
function formateMenuType(value, rowData, rowIndex) {
    if (value == 1)
        return '菜单';
    else
        return '<b>根节点</b>';
}
function formateRoleOpt(value, rowData, rowIndex) {
    var arr = [];
    if (rowData.Nullity != 1) {
        if (new RegExp('(^' + selectRoleId + ',)|(^' + selectRoleId + '$)|(,' + selectRoleId + ',)|(,' + selectRoleId + '$)', 'gi').test(rowData.Roles)) {
            arr.push('<div onclick="setReoleMenu(' + rowData.ModuleID + ',0)" class="icon Lmg18 hand icon-check_yes">&nbsp;</div>');
        } else {
            arr.push('<div onclick="setReoleMenu(' + rowData.ModuleID + ',1)" class="icon Lmg18 hand icon-check_no">&nbsp;</div>');
        }
        return arr.join('');
    }

    return arr.join('');
}

//设置用户角色
function setReoleMenu(moduleID, checked) {
    if (selectRoleId == 0) {
        alert('请在左侧角色列表中选择对应角色！', 'warning');
        return;
    }
    if (selectRoleId == 1) {
        alert('不能设置系统管理员角色菜单！', 'warning');
        return;
    }
    request('/Mgr/SetRoleMenu', { ModuleID: moduleID, RoleID: selectRoleId, IsSet: checked }, function (data) {
        //提示消息
        showMsg(data);
        if (data.code == 1) {
            queryData();
        }
    });
}

//获取角色数据
function getRolesData(fn) {
    request('/Mgr/GetRoleList', {}, function (data) {
        //提示消息
        showMsg(data);
        if (data.code)
            return;
        if (typeof fn == "function") {
            fn(data);
        }
    });
}
//绑定角色列表
function bindTree() {
    getRolesData(function (treeData) {
        $('#tree_roles').tree('loadData', [treeData]);
        bindTreeNodeEvent();
    });
}
//格式化角色树显示
function formateTreeNode(node) {
    var arr = [];
    arr.push('<span class="left">');
    arr.push(node.text);
    arr.push('</span>');
    //if (node.id > 1) {
    //    arr.push('<input type="button" class="hide icon-erase hand right" title="删除角色" ');
    //    arr.push('onclick="deleteRole(' + node.id + ')" ');
    //    arr.push('style="border:none;width:18px;height:18px;margin-right: 5px;position: absolute;right:5px;" />');
    //}
    return arr.join('');
}
//角色树节点鼠标事件
function bindTreeNodeEvent() {
    $('.tree-node').unbind();
    $('.tree-node').bind('mouseenter', function () {
        $(this).find('.icon-erase').show();
    }).bind('mouseleave', function () {
        $(this).find('.icon-erase').hide();
    });
}
//角色树节点右键点击事件
function righClickTreeEvent(e, node) {
    e.preventDefault();
    // 选择一个节点
    $('#tree_roles').tree('select', node.target);
    // 显示右键菜单
    /*$('#mm').menu('show', {
        left: e.pageX,
        top: e.pageY
    });*/
}
//角色选择事件
function roleSelected(node) {
    queryData();
}

//删除角色
function deleteRole(roleId) {
    confirm('确认删除选择的角色？', function () {
        request('/Mgr/DelRole', { RoleID: roleId }, function (data) {
            //提示消息
            showMsg(data);
            if (data && data.code == 1) {
                refreshRole();
            }
        });
    });
}
//刷新角色树
function refreshRole() {
    bindTree();
}

//显示角色添加窗口
function showAddRole() {

    $('#form1').get(0).reset();
    easyloader.load(['dialog'], function () {
        if (!$('#addRoleWin').hasClass('easyui-dialog')) {
            $('#addRoleWin').dialog({
                title: '【添加角色】',
                iconCls: 'icon-user_add',
                width: 350,
                height: 200,
                resizable: false,
                modal: true
            });
        } else {
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
            refreshRole();
        }
    });
}
