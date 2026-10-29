# -*- coding: utf-8 -*-
# 一次性工具：把 PowerShell 脚本经 -EncodedCommand 发到 8.218.67.82 执行。
# 用法: python _ssh_ps.py <ps脚本文件>   或   python _ssh_ps.py -c "单行命令"
# 说明: 远端输出按 GBK 解码；stderr 中的 CLIXML 进度噪音会被滤掉。
import base64
import subprocess
import sys

HOST = 'administrator@8.218.67.82'


def run_ps(ps_text):
    enc = base64.b64encode(ps_text.encode('utf-16-le')).decode()
    r = subprocess.run(
        ['ssh', HOST, 'powershell', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-EncodedCommand', enc],
        capture_output=True, timeout=600)
    out = r.stdout.decode('gbk', 'replace')
    err = r.stderr.decode('gbk', 'replace')
    # 滤掉 CLIXML 包装行，只留有效输出与错误文本
    for line in (out + '\n' + err).splitlines():
        line = line.strip()
        if not line or line.startswith('#< CLIXML') or line.startswith('<Objs') or line.endswith('</Objs>'):
            continue
        # CLIXML 内的 <S> 文本提取
        if '<S S=' in line or '<S>' in line:
            import re
            for m in re.finditer(r'<S[^>]*>(.*?)</S>', line):
                print(m.group(1).replace('_x000D__x000A_', ''))
            continue
        print(line)
    return r.returncode


if __name__ == '__main__':
    if len(sys.argv) >= 3 and sys.argv[1] == '-c':
        script = sys.argv[2]
    elif len(sys.argv) >= 2:
        with open(sys.argv[1], 'r', encoding='utf-8') as f:
            script = f.read()
    else:
        print('usage: _ssh_ps.py <script.ps1> | -c "command"')
        sys.exit(2)
    sys.exit(run_ps(script))
