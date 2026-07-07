#!/usr/bin/env python3
"""扩展 Hermes config.yaml 的 command_allowlist，加入 harmesAgent 工作区脚本。"""
import re, sys
p = '/home/huazhonghao/.hermes/config.yaml'
s = open(p, encoding='utf-8').read()
new = '''command_allowlist:
- browser-harness *
- browser-harness
- bash /mnt/d/project/hermes-agent/AgentGroups/harmesAgent/scripts/runtime/ensure-chrome.sh
- bash /mnt/d/project/hermes-agent/AgentGroups/harmesAgent/*.sh
- bash /mnt/d/project/hermes-agent/AgentGroups/harmesAgent/scripts/**/*.sh
'''
s2 = re.sub(r'command_allowlist:\n(- [^\n]+\n)+', new, s, count=1)
if s2 == s:
    print("WARN: command_allowlist block not found")
else:
    open(p, 'w', encoding='utf-8').write(s2)
    print("✓ updated")
