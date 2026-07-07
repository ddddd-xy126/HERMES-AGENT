#!/usr/bin/env bash
# 把爱马仕的人格设定 + 人生记忆库植入 Hermes
#
# 设计：persona.md + life-rag.md 拼接 -> ~/.hermes/SOUL.md
#   - SOUL.md 是 hard-injected 的"活动人格"，每条消息加载，**不走** memory 压缩。
#   - 之前把 life-rag.md 塞 ~/.hermes/memories/MEMORY.md，但 Hermes 的 memory_char_limit=2200
#     会无情压缩到 ~1KB，导致人生记忆几乎全丢。教训：人生记忆是人格延伸，必须走 SOUL.md。
# 幂等：每次重写 SOUL.md（带 .bak.<时间戳> 备份）；不动 MEMORY.md（保留 Hermes 运维条目）。
set -e

PERSONA_SRC="/mnt/d/project/hermes-agent/AgentGroups/harmesAgent/persona/persona.md"
LIFERAG_SRC="/mnt/d/project/hermes-agent/AgentGroups/harmesAgent/persona/life-rag.md"
SOUL="$HOME/.hermes/SOUL.md"

[ -f "$PERSONA_SRC" ] || { echo "missing: $PERSONA_SRC"; exit 1; }
[ -f "$LIFERAG_SRC" ] || { echo "missing: $LIFERAG_SRC"; exit 1; }

ts="$(date +%Y%m%d-%H%M%S)"
[ -f "$SOUL" ] && cp "$SOUL" "$SOUL.bak.$ts"

{
  cat "$PERSONA_SRC"
  printf '\n\n---\n\n# 附：人生记忆库（life-rag）\n\n'
  printf '> 林听的真实经历切片。**单次回复最多调用 2 个片段**，绝不倾倒。\n\n'
  # 跳过 life-rag.md 原本的 H1 + 引言，从 §1 开始
  sed -n '/^## §1/,$p' "$LIFERAG_SRC"
} > "$SOUL"

echo "[install-persona] SOUL.md updated  ($(wc -c < "$SOUL") bytes, $(wc -l < "$SOUL") lines)"

# 重启 gateway 让 SOUL.md 缓存彻底刷新
if [ -x /mnt/d/project/hermes-agent/AgentGroups/harmesAgent/_restart-gateway.sh ]; then
  bash /mnt/d/project/hermes-agent/AgentGroups/harmesAgent/_restart-gateway.sh || true
fi

echo
echo "=== done. ==="
ls -la "$SOUL"
