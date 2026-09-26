#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# Usage: reboot-vm.sh <a|b> <user>   Reboots a lab VM and waits for SSH (measures downtime).
D=$(cd "$(dirname "$0")" && pwd)
S=$(date +%s)
bash "$D/labssh.sh" "$1" "$2" 'sudo systemctl reboot || systemctl reboot' >/dev/null 2>&1
sleep 15
bash "$D/wait-vm.sh" "$1" "$2" 300 >/dev/null && echo "vm-$1 back after $(( $(date +%s) - S ))s" || { echo "vm-$1 did not come back"; exit 1; }
