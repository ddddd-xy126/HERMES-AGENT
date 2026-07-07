#!/usr/bin/env bash
# Wrapper used by code-inspector-plugin inside WSL.
# Receives:  code-wsl -g /mnt/d/.../File.vue:LINE:COL
CODE='/mnt/c/Users/huazhonghao/AppData/Local/Programs/Microsoft VS Code/bin/code'
if [ "$1" = '-g' ] && [ -n "$2" ]; then
  raw="$2"
  path="${raw%%:*}"
  tail="${raw#*:}"
  win=$(wslpath -w "$path")
  exec "$CODE" -g "${win}:${tail}"
fi
exec "$CODE" "$@"
