import shutil

p = '/home/huazhonghao/.hermes/hermes-agent/tools/send_message_tool.py'
src = open(p, encoding='utf-8').read()

needle = '''    # --- Signal: native attachment support via JSON-RPC attachments param ---
    if platform == Platform.SIGNAL and media_files:
        last_result = None
        for i, chunk in enumerate(chunks):
            is_last = (i == len(chunks) - 1)
            result = await _send_signal(
                pconfig.extra,
                chat_id,
                chunk,
                media_files=media_files if is_last else [],
            )
            if isinstance(result, dict) and result.get("error"):
                return result
            last_result = result
        return last_result

    # --- Non-media platforms ---'''

add = '''    # --- Signal: native attachment support via JSON-RPC attachments param ---
    if platform == Platform.SIGNAL and media_files:
        last_result = None
        for i, chunk in enumerate(chunks):
            is_last = (i == len(chunks) - 1)
            result = await _send_signal(
                pconfig.extra,
                chat_id,
                chunk,
                media_files=media_files if is_last else [],
            )
            if isinstance(result, dict) and result.get("error"):
                return result
            last_result = result
        return last_result

    # --- Feishu: native attachment support via FeishuAdapter.send_voice/etc. ---
    if platform == Platform.FEISHU and media_files:
        last_result = None
        for i, chunk in enumerate(chunks):
            is_last = (i == len(chunks) - 1)
            result = await _send_feishu(
                pconfig,
                chat_id,
                chunk,
                media_files=media_files if is_last else [],
                thread_id=thread_id,
            )
            if isinstance(result, dict) and result.get("error"):
                return result
            last_result = result
        return last_result

    # --- Non-media platforms ---'''

assert needle in src, "needle not found"
src2 = src.replace(needle, add, 1)
shutil.copy(p, p + ".bak.feishu_media")
open(p, "w", encoding="utf-8").write(src2)
print("OK", len(src), "->", len(src2))
