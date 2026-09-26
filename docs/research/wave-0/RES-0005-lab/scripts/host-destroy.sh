#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# Host side: destroy the RES-0005 laboratory directory (VMs must already be stopped). Evidence is kept elsewhere.
L=/home/yuri/.claude/jobs/95dfae05/tmp/lab5
for v in a d; do [ -f "$L/vm-$v.pid" ] && kill -0 "$(cat "$L/vm-$v.pid")" 2>/dev/null && { echo "vm-$v still running; refusing"; exit 1; }; done
rm -rf "$L" && echo "removed $L"
ls -d "$L" 2>/dev/null || echo "lab5 directory absent"
