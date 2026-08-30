# -*- coding: utf-8 -*-
"""一次性脚本：手机端 UI 文案 钻石/钻 → 金币（仅用户可见文案，类名与“下钻”导航术语不动）。"""
import io

files = [
    r'TTY.Web\Areas\Mobile\Controllers\HomeController.cs',
    r'TTY.Web\Areas\Mobile\Views\Home\Recharge.cshtml',
    r'TTY.Web\Areas\Mobile\Views\Home\Songjiang.cshtml',
    r'TTY.Web\Areas\Mobile\Views\Home\Huiyuan.cshtml',
    r'TTY.Web\Areas\Mobile\Views\Home\Agents.cshtml',
    r'TTY.Web\Areas\Mobile\Views\Home\Records.cshtml',
    r'TTY.Web\Scripts\app\phone\phone.players.js',
    r'TTY.Web\Scripts\app\phone\phone.recharge.js',
    r'TTY.Web\Scripts\app\phone\phone.songjiang.js',
    r'TTY.Web\Scripts\app\phone\phone.agents.js',
]

# 有顺序的精确替换（先长串后短串）
rules = [
    ('今日玩家总输赢（钻）', '今日玩家总输赢（金币）'),
    ('（钻）', '（金币）'),
    ('(钻)', '(金币)'),
    ('钻石', '金币'),
    ("+ '钻</span>'", "+ '金币</span>'"),
    ("+ '钻</div>'", "+ '金币</div>'"),
]

for path in files:
    with io.open(path, 'r', encoding='utf-8') as f:
        s = f.read()
    orig = s
    for old, new in rules:
        s = s.replace(old, new)
    if s != orig:
        with io.open(path, 'w', encoding='utf-8') as f:
            f.write(s)
        print('updated ' + path)
    else:
        print('no change ' + path)

# 校验：不应再有用户可见的“钻”残留（排除 下钻 / 类名 diamond-）
import re
for path in files:
    with io.open(path, 'r', encoding='utf-8') as f:
        s = f.read()
    for m in re.finditer(r'.{6}钻.{6}', s):
        frag = m.group(0)
        if '下钻' in frag or 'diamond' in frag:
            continue
        print('RESIDUE in %s: %r' % (path, frag))
