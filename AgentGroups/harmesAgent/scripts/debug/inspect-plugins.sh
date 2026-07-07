#!/usr/bin/env bash
~/.local/bin/hermes plugins ls 2>&1 | sed 's/\x1b\[[0-9;]*m//g' > /tmp/plugins.txt
grep -i image_gen /tmp/plugins.txt
echo '--- all bundled plugin names ---'
grep -E '^\s*│\s*[a-z][a-z0-9_-]+\s*│' /tmp/plugins.txt | head -30
echo '--- raw lines ---'
cat /tmp/plugins.txt | head -200
