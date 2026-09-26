#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# Usage: run-in-vm.sh <a|b> <user> <script> [args...]
#   Pipes a lab script into the VM over SSH and runs it with bash (as <user>; scripts use sudo inside the VM only).
#   Output is also appended to $L/logs/<vm>.log for evidence.
L=/home/yuri/.claude/jobs/95dfae05/tmp/lab
D=$(cd "$(dirname "$0")" && pwd)
VM="$1"; U="$2"; SCRIPT="$3"; shift 3
{ echo "### $(date -u +%FT%TZ) vm-$VM $U $(basename "$SCRIPT") $*"; } >> "$L/logs/vm-$VM.log"
bash "$D/labssh.sh" "$VM" "$U" "bash -s -- $*" < "$SCRIPT" 2>&1 | tee -a "$L/logs/vm-$VM.log"
exit "${PIPESTATUS[0]}"
