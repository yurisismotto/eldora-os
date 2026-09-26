#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# Host side: stop VM-D and VM-A, give VM-D's disk back to VM-A as the install target, reset VM-D NVRAM copy, restart VM-A.
set -uo pipefail
L=/home/yuri/.claude/jobs/95dfae05/tmp/lab5; D=$(cd "$(dirname "$0")" && pwd); cd "$L"
[ -f vm-d.pid ] && kill "$(cat vm-d.pid)" 2>/dev/null; sleep 2
bash "$D/labssh.sh" a lab 'sudo systemctl poweroff' >/dev/null 2>&1
for i in $(seq 1 60); do [ -f vm-a.pid ] && kill -0 "$(cat vm-a.pid)" 2>/dev/null || break; sleep 2; done
rm -f target-disk.qcow2 vm-d-vars.fd && mv vm-d.qcow2 target-disk.qcow2 && echo "disk returned to VM-A as target"
bash "$D/host-vm-a.sh"
