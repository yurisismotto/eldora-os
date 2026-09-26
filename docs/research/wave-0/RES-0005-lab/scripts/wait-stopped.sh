#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# Wait until a lab VM's QEMU process has exited. Usage: wait-stopped.sh <a|d> [timeout_s]
L=/home/yuri/.claude/jobs/95dfae05/tmp/lab5; P="$L/vm-$1.pid"; T=${2:-180}; S=0
until [ ! -f "$P" ] || ! kill -0 "$(cat "$P" 2>/dev/null)" 2>/dev/null; do sleep 3; S=$((S+3)); [ "$S" -ge "$T" ] && { echo "vm-$1 still running after ${T}s"; exit 1; }; done
echo "vm-$1 stopped (waited ~${S}s)"
