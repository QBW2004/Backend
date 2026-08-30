# -*- coding: utf-8 -*-
"""一次性脚本：把手机端复刻新增的文件登记进 YYT.Web.csproj。"""
import io

path = r'TTY.Web\YYT.Web.csproj'
with io.open(path, 'r', encoding='utf-8-sig') as f:
    s = f.read()

changed = False

def add_after(anchor, addition):
    global s, changed
    if addition.strip() in s:
        print('skip (already present): ' + addition.strip())
        return
    assert anchor in s, 'anchor not found: ' + anchor
    s = s.replace(anchor, anchor + '\r\n' + addition, 1)
    changed = True
    print('added: ' + addition.strip())

# 1) Compile: AbnormalController
add_after(r'    <Compile Include="Areas\Game\Controllers\AgencyInfoController.cs" />',
          r'    <Compile Include="Areas\Game\Controllers\AbnormalController.cs" />')

# 2) Content: phone.css
add_after(r'    <Content Include="Content\css\mobile.css" />',
          r'    <Content Include="Content\css\phone.css" />')

# 3) Content: Login Mobile view
add_after(r'    <Content Include="Views\Login\Index.cshtml" />',
          r'    <Content Include="Views\Login\Mobile.cshtml" />')

# 4) Content: new Mobile area views
views = [
    r'Areas\Mobile\Views\Home\Abnormal.cshtml',
    r'Areas\Mobile\Views\Home\BanPlayer.cshtml',
    r'Areas\Mobile\Views\Home\BanAgent.cshtml',
    r'Areas\Mobile\Views\Home\Blacklist.cshtml',
    r'Areas\Mobile\Views\Home\Songjiang.cshtml',
    r'Areas\Mobile\Views\Home\Huiyuan.cshtml',
]
for v in views:
    add_after(r'    <Content Include="Areas\Mobile\Views\Home\Index.cshtml" />',
              r'    <Content Include="%s" />' % v)

# 5) Content: phone.*.js
scripts = [
    r'Scripts\app\phone\phone.core.js',
    r'Scripts\app\phone\phone.players.js',
    r'Scripts\app\phone\phone.agents.js',
    r'Scripts\app\phone\phone.addagent.js',
    r'Scripts\app\phone\phone.recharge.js',
    r'Scripts\app\phone\phone.records.js',
    r'Scripts\app\phone\phone.abnormal.js',
    r'Scripts\app\phone\phone.banplayer.js',
    r'Scripts\app\phone\phone.banagent.js',
    r'Scripts\app\phone\phone.blacklist.js',
    r'Scripts\app\phone\phone.songjiang.js',
    r'Scripts\app\phone\phone.huiyuan.js',
]
for v in scripts:
    add_after(r'    <Content Include="Scripts\app\mobile\mobile.core.js" />',
              r'    <Content Include="%s" />' % v)

if changed:
    with io.open(path, 'w', encoding='utf-8-sig') as f:
        f.write(s)
    print('csproj updated')
else:
    print('no changes')
