#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# Host side: destroy the laboratory (stop VMs, delete $L). Nothing else on the host was changed.
L=/home/yuri/.claude/jobs/95dfae05/tmp/lab
for v in vm-a vm-b; do
  if [ -f "$L/$v.pid" ]; then P=$(cat "$L/$v.pid"); kill "$P" 2>/dev/null && echo "stopped $v (pid $P)"; fi
done
sleep 3
pgrep -af 'qemu-system-x86_64 -name vm-' || echo "no lab qemu processes remain"
rm -rf "$L" && echo "removed $L"
ls -d "$L" 2>/dev/null || echo "lab directory absent"
