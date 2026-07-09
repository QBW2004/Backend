$(function () {
    // 加载指定的模块
    easyloader.load(['combo', 'tree', 'form', 'validatebox', 'textbox', 'layout', 'combobox', 'numberbox', 'linkbutton'], function () {
        //初始化插件
        pluginInit();
        //隐藏Loding
        hideLoading();
        //适应窗口大小变化
        $(window).resize(function () {
            resizeContainer();
        });
        var t = setInterval(function () {
            if ($('#main').hasClass('layout')) {
                resizeContainer();
                clearInterval(t);
            }
        }, 10);
    });
});

// 将 GetGameList 的平铺数据转换为 easyui-tree 所需的树形结构
function treeLoadFilter(data) {
    if (!data || data.length === 0) return [];
    var typeNames = { 0: '押注类', 1: '牌机类', 2: '鱼机类', 3: '拉霸类' };
    var typeMap = {};
    for (var i = 0; i < data.length; i++) {
        var g = data[i];
        var gt = g.gameType;
        if (!typeMap[gt]) {
            typeMap[gt] = { id: 'type_' + gt, text: typeNames[gt] || ('类型' + gt), state: 'open', children: [] };
        }
        typeMap[gt].children.push({ id: g.id, text: g.text, attributes: { GameType: gt } });
    }
    var result = [];
    for (var k in typeMap) { result.push(typeMap[k]); }
    return result;
}

function resizeContainer() {
    $('#main').layout('resize', { height: $(window).height() - 38 });
}
function setCtrlVisible() {
    $('#type_0,#type_1,#type_2,#type_3').hide();
    $('#type_' + Game_Type).show();
}
function setHiddenVal() {
    var parentBox = $('#type_' + Game_Type);
    parentBox.find('[name="GAME_TYPE"]').val(Game_Type);
    parentBox.find('[name="GAME_ID"]').val(Game_Id);
}
function resetCtrl(gameType) {
    $('#type_' + gameType).find('.easyui-numberbox').numberbox('clear');
}
function setNumCtrlPrecision(gameType) {
    if (top.isRMB != true)
        return;

    $('#type_' + gameType+' [numberboxname]').numberbox({ precision: 2 });
}

function getComboSelData(len, minVal) {
    var arr = [];
    var _minVal = (typeof minVal == "number" ? minVal : 0)
    for (var i = _minVal; i < len; i++) {
        if (i == _minVal)
            arr.push({ id: i, text: i.toString(), selected: true });
        else
            arr.push({ id: i, text: i.toString() });
    }
    return arr;
}
function getRoomSelData(len) {
    var arr = [];
    for (var i = 0; i < len; i++) {
        if (i == 0)
            arr.push({ id: i, text: '初级场', selected: true });
        else if (i == 1)
            arr.push({ id: i, text: '中级场' });
        else if (i == 2)
            arr.push({ id: i, text: '高级场' });
        else if (i == 3)
            arr.push({ id: i, text: 'VIP 场' });
    }
    return arr;
}
// 获取机台索引
function getDeskIndex() {
    var selRoom = getSelRoom();// 获取房间索引
    var selDesk = getSelDesk();// 获取机台索引

    if (!selDesk)
        selDesk = 0;

    if (!selRoom)
        selRoom = 0;

    var startIndex = 0;
    var roomDeskData = $('body').data('RoomDeskData');
    if (roomDeskData) {
        for (var i = 0; i < roomDeskData.length; i++) {
            if (roomDeskData[i].RoomIndex < selRoom) {
                startIndex += roomDeskData[i].DeskCount;
            }
        }
    }

    return (startIndex + selDesk - 1);
}
// 获取桌子数据
function getGamePara(gameId, gameType, bindSel) {
    
    var para = { GAME_ID: gameId, GAME_TYPE: gameType, DESK_ID: (gameType != 3 ? getDeskIndex() : 0) };
    // 清理控件
    resetCtrl(gameType);
    if (para.GAME_ID > -1 && para.GAME_TYPE > -1) {
        // 设置控件
        setCtrlVisible();
        // 设置隐藏表单控件
        setHiddenVal();
        // 真金版显示设置
        setNumCtrlPrecision(gameType);
        // 绑定表单控件
        request('/Game/GameRecord/GetGameRecord', para, function (msg) {
            if (msg.code == 1 && msg.datas) {
                if (gameType == 3 && msg.datas.length > 0) {

                    setLabaCtrlVal(msg.datas[0], gameType, 0);
                } else {

                    if (msg.datas.Head == 0 && msg.datas.Body) {
                        if (gameType == 0) {

                            for (var i = 0; i < msg.datas.Body.length; i++) {
                                setBetFishCtrlVal(msg.datas.Body[i], gameType, i);
                            }
                        } else if (gameType == 1) {

                            for (var i = 0; i < msg.datas.Body.length; i++) {
                                setCardCtrlVal(msg.datas.Body[i], gameType, i);
                            }
                        } else if (gameType == 2) {

                            setBetFishCtrlVal(msg.datas.Body[0], gameType, 0);
                        }
                    }
                }
            }
        });
        // 绑定机台选择控件
        if (bindSel == true) {
            getRoomDeskData(para, function (roomSelData, deskSelData) {
                $('#type_' + Game_Type).find('#selRoomSel_' + Game_Type).combobox('loadData', roomSelData);
                $('#type_' + Game_Type).find('#selDeskSel_' + Game_Type).combobox('loadData', deskSelData);
            });
        }
    }
}
// 获取房间与桌子关联数据
function getRoomDeskData(para, callBack) {
    request('/Game/GameRecord/GetGameRoomDeskPara', para, function (data) {
        $('body').data('RoomDeskData', data);

        var roomSelData = getRoomSelData(data.length);
        var deskCount = 1;
        for (var i = 0; i < data.length; i++) {
            if (data[i].RoomIndex == 0) {
                deskCount = data[0].DeskCount;
                break;
            }
        }
        var deskSelData = getComboSelData(deskCount + 1, 1);

        if (typeof callBack == 'function') {
            callBack(roomSelData, deskSelData);
        }
    });
}
// 获取房间
function getSelRoom() {
    return parseInt($('#type_' + Game_Type).find('#selRoomSel_' + Game_Type).combobox('getValue'), 10);
}
// 获取机台
function getSelDesk() {
    return parseInt($('#type_' + Game_Type).find('#selDeskSel_' + Game_Type).combobox('getValue'), 10);
}


// 游戏选择
function onTreeSel(node) {
    if (node.attributes && typeof node.attributes.GameType != 'undefined') {
        window.Game_Id = node.id;
        window.Game_Type = node.attributes.GameType;

        $('#type_' + Game_Type).data('init', false);
        getGamePara(Game_Id, Game_Type, true);
    }
}
// 房间选择
function onRoomSelChange(newValue, oldValue) {
    if (newValue.toString().length > 0 && oldValue.toString().length > 0 && parseInt(newValue) != parseInt(oldValue)) {
        // 先清空机台下拉选择控件值
        $('#type_' + Game_Type).find('#selDeskSel_' + Game_Type).combobox('clear').combobox('setText', '');
        // 绑定机台选择控件数据
        var roomDeskData = $('body').data('RoomDeskData');
        var deskCount = 1;
        for (var i = 0; i < roomDeskData.length; i++) {
            if (roomDeskData[i].RoomIndex == parseInt(newValue)) {
                deskCount = roomDeskData[i].DeskCount;
                break;
            }
        }
        var deskSelData = getComboSelData(deskCount + 1, 1);
        $('#type_' + Game_Type).find('#selDeskSel_' + Game_Type).combobox('loadData', deskSelData);
        // 绑定表单控件数据
        getGamePara(Game_Id, Game_Type, false);
    }
}
// 机台选择
function onDeskSelChange(newValue, oldValue) {
    if (newValue.toString().length > 0 && oldValue.toString().length > 0 && parseInt(newValue) != parseInt(oldValue)) {
        // 绑定表单控件数据
        getGamePara(Game_Id, Game_Type, false);
    }
}


function commonNumCtrlSet(ctrlObj, key, score) {
    if (ctrlObj && ctrlObj.length > 0) {
        if (/_Per/ig.test(key))
            ctrlObj.numberbox('setValue', score);
        else
            ctrlObj.numberbox('setValue', top.goldFormat(score));
    }
}
// 绑定押注、鱼机数据
function setBetFishCtrlVal(datas, gameType, rowIndex) {
    // 数据检验
    if (typeof datas == 'undefined' || datas.length < 1)
        return;
    // 赋值
    var ctrlId, ctrlObj;
    for (var key in datas) {
        ctrlId = '[numberboxname="' + key + '_' + rowIndex + '"]';
        ctrlObj = $('#type_' + gameType).find(ctrlId);
        commonNumCtrlSet(ctrlObj, key, datas[key]);
    }
}
// 绑定拉霸数据
function setLabaCtrlVal(datas, gameType, rowIndex) {
    // 数据检验
    if (typeof datas == 'undefined')
        return;
    // 赋值
    var ctrlId, ctrlObj;
    for (var key in datas) {
        ctrlId = '[numberboxname="' + key + '"]';
        ctrlObj = $('#type_' + gameType).find(ctrlId);
        commonNumCtrlSet(ctrlObj, key, datas[key]);
    }
}
// 绑定牌机数据
function setCardCtrlVal(datas, gameType, rowIndex) {
    // 数据检验
    if (typeof datas == 'undefined' || datas.length < 1)
        return;
    // 赋值
    var ctrlId, ctrlObj;
    for (var key in datas) {
        if (key == "CardTypeDatas") {
            for (var i = 0; i < datas[key].length; i++) {
                ctrlId = '[numberboxname="CardType_' + i + '"]';
                ctrlObj = $('#type_' + gameType).find(ctrlId);
                commonNumCtrlSet(ctrlObj, key, datas[key][i]);
            }
        } else {
            ctrlId = '[numberboxname="' + key + '_' + rowIndex + '"]';
            ctrlObj = $('#type_' + gameType).find(ctrlId);
            commonNumCtrlSet(ctrlObj, key, datas[key]);
        }
    }
}