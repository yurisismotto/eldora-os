#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# Usage: wait-vm.sh <a|b> <user> [timeout_seconds]   Waits for SSH (and cloud-init when present).
D=$(cd "$(dirname "$0")" && pwd)
T=${3:-300}; S=0
while [ "$S" -lt "$T" ]; do
  if bash "$D/labssh.sh" "$1" "$2" 'command -v cloud-init >/dev/null && cloud-init status --wait >/dev/null 2>&1; echo ready' 2>/dev/null | grep -q ready; then
    echo "vm-$1 ready after ~${S}s"; exit 0
  fi
  sleep 5; S=$((S+5))
done
echo "vm-$1 NOT ready after ${T}s"; exit 1
