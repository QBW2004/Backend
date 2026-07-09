function InitValidExt() {
    easyloader.load(['validatebox'], function () {
        $.extend($.fn.validatebox.defaults.rules, {
            phone: {//手机号码校验  
                validator: function (value, param) {
                    return checkPhone(value);
                },
                message: '手机号码不正确'
            },
            myEmail: {//邮箱校验，避免使用email和默认的冲突  
                validator: function (value, param) {
                    return checkEmail(value);
                },
                message: '邮箱地址不正确'
            },
            loginName: {//登录名，数字、英文字母或者下划线  
                validator: function (value, param) {
                    return checkLoginName(value);
                },
                message: '只能是数字、英文字母或者下划线'
            },
            telePhone: {//座机，区号及分机号可有可无  
                validator: function (value, param) {
                    return checkTelePhone(value);
                },
                message: '座机号码不正确'
            },
            chinese: {//中文汉字
                validator: function (value, param) {
                    return checkChinese(value);
                },
                message: '只能是中文汉字'
            },
            number: {//正整数，包括0（00，01非数字）  
                validator: function (value, param) {
                    return isNumber(value);
                },
                message: '只能是数字'
            },
            numberText: {//数字组成的字符串，如000222，22220000，00000  
                validator: function (value, param) {
                    return isNumberText(value);
                },
                message: '只能是数字字符串'
            },
            idCardNo: {//身份证  
                validator: function (value, param) {
                    return isIdCardNo(value);
                },
                message: '身份证号码不正确'
            },
            money: {//金额  
                validator: function (value, param) {
                    return isFloat(value);
                },
                message: '金额不正确'
            },
            floatNumber: {//数字（包括正整数、0、浮点数）  
                validator: function (value, param) {
                    return isFloat(value);
                },
                message: '只能是0、正整数、浮点数'
            },
            minLength: {//最少字符数
                validator: function (value, param) {
                    return value.length >= param[0];
                },
                message: '至少 {0}个字符'
            },
            maxLength: {//最大字符数
                validator: function (value, param) {
                    return value.length <= param[0];
                },
                message: '不能超过{0}个字符'
            },
            minTo: {
                validator: function (value, param) {
                    return value.length < param[0];
                },
                message: '不能小于{0}的数值'
            },
            maxTo: {
                validator: function (value, param) {
                    return value.length > param[0];
                },
                message: '不能大于{0}的数值'
            }
        });
    });
}

/**  
 * 是否为Null  
 * @param object  
 * @returns {Boolean}  
 */
function isNull(object) {
    if (object == null || typeof object == "undefined") {
        return true;
    }
    return false;
};

/**  
 * 是否为空字符串，有空格不是空字符串  
 * @param str  
 * @returns {Boolean}  
 */
function isEmpty(str) {
    if (str == null || typeof str == "undefined" ||
        str == "") {
        return true;
    }
    return false;
};

/**  
 * 是否为空字符串，全空格也是空字符串  
 * @param str  
 * @returns {Boolean}  
 */
function isBlank(str) {
    if (str == null || typeof str == "undefined" ||
        str == "" || trim(str) == "") {
        return true;
    }
    return false;
};

/** 
 * 检查手机号码 
 * @param phoneNo 要检查的值 
 * @return {Boolean}
*/
function checkPhone(phoneNo) {
    if (isEmpty(phoneNo) || phoneNo.length != 11) {
        return false;
    }
    var z_reg = /^13[0-9]{9}|15[012356789][0-9]{8}|18[0-9]{9}|(14[57][0-9]{8})|(17[015678][0-9]{8})$/;
    return z_reg.test(phoneNo);
};

/** 
 * 检查电子邮箱 
 * @param mail 要检查的值 
 * @return {Boolean}
*/
function checkEmail(mail) {
    //var emailReg = /^([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}$/;  
    var z_reg = /^\w+((-\w+)|(\.\w+))*\@[A-Za-z0-9]+((\.|-)[A-Za-z0-9]+)*\.[A-Za-z0-9]+$/;
    return z_reg.test($.trim(mail));
};

/** 
 * 检查登录名（由数字、26个英文字母或者下划线组成的字符串） 
 * @param loginName 要检查的值
 * @return {Boolean}
*/
function checkLoginName(loginName) {
    var z_reg = /^\w+$/;
    return z_reg.test($.trim(loginName));
};

/** 
 * 检查电话号码 
 * @param telPhoneNo 要检查的值 
 * @return {Boolean}
*/
function checkTelePhone(telPhoneNo) {
    var z_reg = /^(([0\+]\d{2,3}-)?(0\d{2,3})-)?(\d{7,8})(-(\d{3,4}))?$/;
    return z_reg.test($.trim(telPhoneNo));
};

/** 
 * 检查仅中文 
 * @param chineseChr 要检查的值
 * @return {Boolean}
*/
function checkChinese(chineseChr) {
    var z_reg = /^[\u4E00-\u9FA5\uF900-\uFA2D]+$/;
    return z_reg.test($.trim(chineseChr));
};

/** 
 * 是否为数字 
 * @param num 要检查的值 
 * @return {Boolean}
*/
function isNumber(num) {
    var z_reg = /^(([0-9])|([1-9]([0-9]+)))$/;
    return z_reg.test($.trim(num));
};

/** 
 * 是否为数字组成的字符串，01也符合规则 
 * @param num 要检查的值
 * @return {Boolean}
*/
function isNumberText(num) {
    var z_reg = /^([0-9]+)$/;
    return z_reg.test($.trim(num));
};

/** 
 * 可以判断是否为数字、金额、浮点数 
 * @param num 要检查的值
 * @return {Boolean}
*/
function isFloat(num) {
    var z_reg = /^((([0-9])|([1-9][0-9]+))(\.([0-9]+))?)$/;//.是特殊字符，需要转义  
    return z_reg.test($.trim(num));
};  