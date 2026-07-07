#!/usr/bin/env bash
source ~/.hermes/.env
curl -sS "$OPENAI_BASE_URL/models" -H "Authorization: Bearer $OPENAI_API_KEY" \
  -o /tmp/n1n_models.json
echo "=== 总数 ==="
python3 -c "
import json
d = json.load(open('/tmp/n1n_models.json'))
data = d.get('data', [])
print(f'共 {len(data)} 个模型')
print()

# 按 model_type / tags / id 关键字分组
buckets = {'图像生成':[], '识图(vision)':[], '语音/TTS/ASR':[], '嵌入(embedding)':[], '思考(thinking)':[], '工具/对话':[], '其它':[]}
for m in data:
    mid = m.get('id','')
    mt = m.get('model_type','') or ''
    tags = m.get('tags','') or ''
    low = mid.lower()
    if any(k in low for k in ['image','dall-e','dalle','flux','sd3','sdxl','stable-diffusion','midjourney','mj_','ideogram','recraft','seedream','kolors','wanx','cogview','hunyuan-image']) or '生图' in mt or '画图' in mt or '图像' in mt:
        buckets['图像生成'].append(mid)
    elif any(k in low for k in ['tts','whisper','speech','voice','asr','audio']):
        buckets['语音/TTS/ASR'].append(mid)
    elif 'embed' in low or '嵌入' in mt:
        buckets['嵌入(embedding)'].append(mid)
    elif 'thinking' in low or '思考' in tags:
        buckets['思考(thinking)'].append(mid)
    elif '识图' in tags or 'vision' in low:
        buckets['识图(vision)'].append(mid)
    elif mt == '文本' or '对话' in tags or '工具' in tags:
        buckets['工具/对话'].append(mid)
    else:
        buckets['其它'].append(mid)

for k,v in buckets.items():
    print(f'--- {k} ({len(v)}) ---')
    for x in v[:60]:
        print(' ', x)
    if len(v) > 60:
        print(f'  ... 还有 {len(v)-60} 个')
    print()
"
