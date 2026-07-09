Current Version: 1.6.6
====================================================================================================================================
This software is allowed to use under freeware license or you need to buy commercial license for better support or other purpose.
Please contact us at info@jeasyui.com


====================================================================================================================================
# 加载 EasyUI 模块
easyloader.base = '../'; // 设置 easyui 的基本目录
easyloader.load('messager', function(){ // 加载指定的模块
    $.messager.alert('Title', 'load ok');
});

# 通过相对 url 加载脚本
// 脚本相对于 easyui 目录的路径
using('./myscript.js', function(){
    // ...
});

# 通过绝对 url 加载脚本
using('http://code.jquery.com/jquery-1.4.4.min.js', function(){
    // ...
});

# 名称			# 类型			# 描述												# 默认值
modules			object			预定义的模块。	
locales			object			预定义的语言环境。	
base			string			easyui 的基本目录，必须以 '/' 结尾。				基本目录将被自动相对于 easyload.js 进行设置
theme			string			定义在 'themes' 目录下的主题名称。					default
css				boolean			定义当加载模块的时候是否加载 css 文件。				true
locale			string			语言环境名称。										null
timeout			number			以毫秒为单位的超时值，如果超时发生就触发。			2000
====================================================================================================================================