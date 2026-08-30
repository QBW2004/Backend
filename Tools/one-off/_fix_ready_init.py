# -*- coding: utf-8 -*-
"""一次性脚本：把 phone.*.js 里的 jQuery ready 初始化改为直接执行
（IAB WebView 中 jQuery 2.1.4 ready 后注册的回调不执行，脚本又在 body 末尾加载，
直接执行最稳妥）。"""
import io
import re

files = [
    r'TTY.Web\Scripts\app\phone\phone.players.js',
    r'TTY.Web\Scripts\app\phone\phone.agents.js',
    r'TTY.Web\Scripts\app\phone\phone.addagent.js',
    r'TTY.Web\Scripts\app\phone\phone.recharge.js',
    r'TTY.Web\Scripts\app\phone\phone.records.js',
    r'TTY.Web\Scripts\app\phone\phone.abnormal.js',
    r'TTY.Web\Scripts\app\phone\phone.banplayer.js',
    r'TTY.Web\Scripts\app\phone\phone.banagent.js',
    r'TTY.Web\Scripts\app\phone\phone.blacklist.js',
    r'TTY.Web\Scripts\app\phone\phone.songjiang.js',
    r'TTY.Web\Scripts\app\phone\phone.huiyuan.js',
]

HEAD = '    jQuery(function () {'
TAIL = '    });\n\n})(window, jQuery, window.MApp);'
NEW_TAIL = (
    '    }\n\n'
    '    // 脚本在 body 末尾加载，DOM 已就绪；不依赖 jQuery ready\n'
    '    //（部分 WebView 中 ready 之后注册的回调不会被执行）\n'
    "    if (document.readyState === 'loading') {\n"
    "        document.addEventListener('DOMContentLoaded', initPage);\n"
    '    } else {\n'
    '        initPage();\n'
    '    }\n\n'
    '})(window, jQuery, window.MApp);'
)

for path in files:
    with io.open(path, 'r', encoding='utf-8') as f:
        s = f.read()
    if HEAD not in s:
        print('HEAD NOT FOUND in ' + path)
        continue
    if TAIL not in s:
        print('TAIL NOT FOUND in ' + path)
        continue
    s = s.replace(HEAD, '    function initPage() {', 1)
    s = s.replace(TAIL, NEW_TAIL, 1)
    with io.open(path, 'w', encoding='utf-8') as f:
        f.write(s)
    print('updated ' + path)
