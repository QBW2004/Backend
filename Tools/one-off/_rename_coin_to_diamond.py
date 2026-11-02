# -*- coding: utf-8 -*-
"""一次性脚本：后台全端文案 金币/币 → 钻（2026-11-02，货币口径统一为「钻」）。

范围：TTY.Web、YYT.BLL、YYT.Entity、YYT.Remote、UnitTestProj 源码
      （.cshtml/.cs/.js/.config，跳过 bin/、obj/）。
规则：金币→钻、游戏币→钻、其余散用「币」→「钻」；
      保护非货币词 货币（游戏货币/加密货币）、造币（批量赋值造币）不动；
      逐文件保留 UTF-8 BOM 有无与 CRLF 换行。
注意：Docs/、SQL 库 dump、.build/、TestResults/ 基线不动；App_Data/Data.db 为停用遗留库不动。
"""
import io
import os
import re

ROOTS = ['TTY.Web', 'YYT.BLL', 'YYT.Entity', 'YYT.Remote', 'UnitTestProj']
EXTS = ('.cshtml', '.cs', '.js', '.config')
SKIP_DIRS = {'bin', 'obj'}

SENT_HUOBI = '\ue000'  # 货币 哨兵
SENT_ZAOBI = '\ue001'  # 造币 哨兵

rules = [
    ('金币', '钻'),
    ('游戏币', '钻'),
    ('货币', SENT_HUOBI),
    ('造币', SENT_ZAOBI),
    ('币', '钻'),
    (SENT_HUOBI, '货币'),
    (SENT_ZAOBI, '造币'),
]

changed = []
for root in ROOTS:
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d.lower() not in SKIP_DIRS]
        for name in filenames:
            if not name.lower().endswith(EXTS):
                continue
            path = os.path.join(dirpath, name)
            with io.open(path, 'rb') as f:
                raw = f.read()
            bom = raw.startswith(b'\xef\xbb\xbf')
            try:
                s = raw.decode('utf-8-sig')
            except UnicodeDecodeError:
                print('SKIP non-utf8 ' + path)
                continue
            orig = s
            for old, new in rules:
                s = s.replace(old, new)
            if s == orig:
                continue
            out = s.encode('utf-8')
            if bom:
                out = b'\xef\xbb\xbf' + out
            with io.open(path, 'wb') as f:
                f.write(out)
            changed.append(path)

print('changed %d files' % len(changed))
for p in changed:
    print('  ' + p)

# 校验：残留的「币」只允许出现在 货币/造币 中
print('--- residue check ---')
bad = 0
for root in ROOTS:
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d.lower() not in SKIP_DIRS]
        for name in filenames:
            if not name.lower().endswith(EXTS):
                continue
            path = os.path.join(dirpath, name)
            with io.open(path, 'rb') as f:
                try:
                    s = f.read().decode('utf-8-sig')
                except UnicodeDecodeError:
                    continue
            for m in re.finditer(r'.{0,8}币.{0,8}', s):
                frag = m.group(0)
                if '货币' in frag or '造币' in frag:
                    continue
                bad += 1
                print('RESIDUE %s: %r' % (path, frag))
print('residue %d (expect 0)' % bad)
