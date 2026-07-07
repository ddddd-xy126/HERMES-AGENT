import re
p = '/home/huazhonghao/.hermes/config.yaml'
s = open(p, encoding='utf-8').read()
s = re.sub(
    r'voice: zh-CN-XiaomoNeural\n    speed: 0\.95',
    'voice: zh-CN-XiaoxiaoNeural\n    speed: 0.88',
    s, count=1)
open(p, 'w', encoding='utf-8').write(s)
print("OK")
