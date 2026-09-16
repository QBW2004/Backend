# -*- coding: utf-8 -*-
"""临时查看脚本：按行号范围打印（自动尝试 utf-8 / gbk 解码）。用法：python _showlines.py <file> <start> <end>"""
import sys, io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

path = sys.argv[1]
start = int(sys.argv[2])
end = int(sys.argv[3])
data = open(path, 'rb').read()

for enc in ('utf-8', 'gbk'):
    try:
        text = data.decode(enc)
        break
    except UnicodeDecodeError:
        text = data.decode('gbk', 'replace')
        break

lines = text.split('\n')
for i in range(start, min(end, len(lines)) + 1):
    sys.stdout.write('%d: %s\n' % (i, lines[i - 1].rstrip()))
