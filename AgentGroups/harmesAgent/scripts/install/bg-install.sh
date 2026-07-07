#!/bin/bash
# Background launcher for hermes installer.
# Usage (in WSL):  bash /mnt/d/webDevFrontProject/AgentGroups/harmesAgent/scripts/install/bg-install.sh
nohup bash /tmp/hermes-install.sh --skip-setup > /tmp/hermes-install.log 2>&1 &
echo "PID=$!"
