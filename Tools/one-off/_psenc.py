# -*- coding: utf-8 -*-
"""把本地 PowerShell 脚本内容转成 -EncodedCommand 用的 base64（UTF-16LE）。
用法：python _psenc.py <script_file>
"""
import sys, base64

script = open(sys.argv[1], 'r', encoding='utf-8').read()
sys.stdout.write(base64.b64encode(script.encode('utf-16-le')).decode('ascii'))
