import asyncio, edge_tts
voices = asyncio.run(edge_tts.list_voices())
for v in voices:
    if v["Locale"].startswith("zh-CN"):
        print(v["ShortName"], "|", v.get("Gender"), "|", v.get("VoicePersonalities", v.get("VoiceTag", "")))
