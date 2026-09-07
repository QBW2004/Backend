/* ============================================================
   用户管理(iOS 风格版)
   依赖 common.js 的 request / showToast;不使用 easyui。
   接口:GetRoleList / GetUserList / AddUser / EditUser / DelUser
   ============================================================ */
$(function () {
    var roleList = [];      // 平铺角色 [{id,text}]
    var users = [];         // 当前用户列表(GetUserList rows)
    var editingUserId = 0;  // 0=新增, >0=编辑
    var deleteUserId = 0;

    // HTML 转义,防注入
    function esc(s) {
        return String(s == null ? '' : s)
            .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
    }
    // 统一提示(成功/失败)
    function notify(data) {
        var ok = data && data.code == 1;
        showToast(ok ? ((data && data.content) || '操作成功') : ((data && (data.msg || data.content)) || '操作失败'), ok ? 'success' : 'error');
        return ok;
    }

    // ---------- 加载角色(树 -> 平铺) ----------
    function loadRoles(fn) {
        request('/Mgr/GetRoleList', {}, function (data) {
            roleList = [];
            if (data && data.children) {
                data.children.forEach(function (group) {
                    // 分组本身也是可选角色(如"系统管理员")
                    if (group && group.id != null && group.text) {
                        roleList.push({ id: group.id, text: group.text });
                    }
                    (group.children || []).forEach(function (leaf) {
                        if (leaf && leaf.id != null && leaf.text) {
                            roleList.push({ id: leaf.id, text: leaf.text });
                        }
                    });
                });
            }
            if (typeof fn === 'function') fn();
        });
    }

    // ---------- 渲染两个角色下拉 ----------
    function renderRoleSelects() {
        var opts = roleList.map(function (r) {
            return '<option value="' + r.id + '">' + esc(r.text) + '</option>';
        }).join('');
        $('#selRole').html('<option value="0">全部角色</option>' + opts);
        $('#fRoleID').html(opts);
    }

    // ---------- 加载用户 ----------
    function loadUsers() {
        var para = {
            RoleID: parseInt($('#selRole').val() || '0', 10),
            usrNameOrAccounts: $.trim($('#txtUsrNameOrAccounts').val() || '')
        };
        request('/Mgr/GetUserList', para, function (data) {
            if (data && data.code == -1) return; // 超时已由 request 处理
            users = (data && data.rows) ? data.rows : [];
            renderStats();
            renderTable();
        });
    }

    // ---------- 统计卡 ----------
    function renderStats() {
        var total = users.length;
        var normal = users.filter(function (u) { return u.IsDel == 0; }).length;
        var disabled = total - normal;
        var admin = users.filter(function (u) { return String(u.Roles).split(',').indexOf('1') >= 0; }).length;
        var other = total - admin;
        var defs = [
            { label: '用户总数', value: total, cls: '' },
            { label: '正常用户', value: normal, cls: '' },
            { label: '禁用用户', value: disabled, cls: disabled > 0 ? 'negative' : '' },
            { label: '角色数', value: roleList.length, cls: '' },
            { label: '管理员', value: admin, cls: '' },
            { label: '其他角色', value: other, cls: '' }
        ];
        $('#statsGrid').html(defs.map(function (s) {
            return '<div class="stat-box"><div class="stat-label">' + s.label + '</div>' +
                '<div class="stat-value ' + s.cls + '">' + s.value + '</div></div>';
        }).join(''));
    }

    // ---------- 数据表格 ----------
    function renderTable() {
        if (!users.length) {
            $('#tbUsersBody').html('<tr><td colspan="7" class="no-data">暂无数据</td></tr>');
            return;
        }
        $('#tbUsersBody').html(users.map(function (u, i) {
            var status = u.IsDel == 1
                ? '<span class="tag bad">禁用</span>'
                : '<span class="tag ok">正常</span>';
            var opt = '';
            if (u.UserID != 1) { // 系统管理员账号不允许编辑/删除(沿用原逻辑)
                opt = '<button type="button" class="row-btn edit" data-id="' + u.UserID + '" onclick="openEdit(this)">编辑</button> ' +
                      '<button type="button" class="row-btn del" data-id="' + u.UserID + '" onclick="askDelete(this)">删除</button>';
            }
            return '<tr>'
                + '<td>' + (u.RowIndex || (i + 1)) + '</td>'
                + '<td>' + esc(u.RoleName || '') + '</td>'
                + '<td class="amount">' + esc(u.Accounts || '') + '</td>'
                + '<td>' + esc(u.UserName || '') + '</td>'
                + '<td>' + status + '</td>'
                + '<td>' + esc(u.Remark || '') + '</td>'
                + '<td>' + opt + '</td>'
                + '</tr>';
        }).join(''));
    }

    // ---------- 新增 / 编辑弹窗 ----------
    window.openAdd = function () {
        editingUserId = 0;
        $('#userModalTitle').text('新增用户');
        $('#pwdTip').hide();
        $('#fUName').val('');
        $('#fUAccounts').val('');
        $('#fUPwd').val('');
        $('#fRemark').val('');
        if (roleList.length) $('#fRoleID').val(roleList[0].id);
        $('#userModal').addClass('show');
        $('#fUName').focus();
    };

    window.openEdit = function (btn) {
        var id = parseInt($(btn).attr('data-id'), 10);
        var u = users.filter(function (x) { return x.UserID == id; })[0];
        if (!u) return;
        editingUserId = id;
        $('#userModalTitle').text('编辑用户');
        $('#pwdTip').show();
        $('#fUName').val(u.UserName || '');
        $('#fUAccounts').val(u.Accounts || '');
        $('#fUPwd').val('');
        $('#fRemark').val(u.Remark || '');
        if (u.Roles) {
            var firstRole = String(u.Roles).split(',')[0];
            $('#fRoleID').val(firstRole);
        }
        $('#userModal').addClass('show');
        $('#fUName').focus();
    };

    window.closeUserModal = function () { $('#userModal').removeClass('show'); };

    // ---------- 保存 ----------
    function saveUser() {
        var para = {
            RoleID: parseInt($('#fRoleID').val() || '0', 10),
            UName: $.trim($('#fUName').val()),
            UAccounts: $.trim($('#fUAccounts').val()),
            UPwd: $('#fUPwd').val(),
            Remark: $.trim($('#fRemark').val()),
            UserID: editingUserId
        };
        if (!para.RoleID) { showToast('请选择角色', 'warning'); return; }
        if (!para.UName) { showToast('请填写用户名', 'warning'); return; }
        if (!para.UAccounts) { showToast('请填写账号', 'warning'); return; }
        var url = editingUserId > 0 ? '/Mgr/EditUser' : '/Mgr/AddUser';
        request(url, para, function (data) {
            if (notify(data)) {
                closeUserModal();
                loadUsers();
            }
        });
    }

    // ---------- 删除 ----------
    window.askDelete = function (btn) {
        deleteUserId = parseInt($(btn).attr('data-id'), 10);
        $('#delModal').addClass('show');
    };
    function closeDelModal() { $('#delModal').removeClass('show'); }
    function doDelete() {
        closeDelModal();
        request('/Mgr/DelUser', { UserID: deleteUserId }, function (data) {
            if (notify(data)) {
                loadUsers();
            }
        });
    }

    // ---------- 事件绑定 ----------
    $('#btnSearch').click(loadUsers);
    $('#selRole').change(loadUsers);
    $('#txtUsrNameOrAccounts').keydown(function (e) { if (e.keyCode === 13) loadUsers(); });
    $('#btnAdd').click(openAdd);
    $('#btnModalSave').click(saveUser);
    $('#btnModalCancel').click(closeUserModal);
    $('#btnDelOk').click(doDelete);
    $('#btnDelCancel').click(closeDelModal);
    // 点击遮罩空白处关闭
    $('.modal-overlay').click(function (e) {
        if (e.target === this) $(this).removeClass('show');
    });

    // ---------- 初始化 ----------
    loadRoles(function () {
        renderRoleSelects();
        loadUsers();
    });
});
