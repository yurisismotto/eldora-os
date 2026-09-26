#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# Host memory guard for the memory-constrained E4 phase. Exit 1 (STOP) if available memory is below the threshold.
T=${1:-2000}
A=$(awk '/MemAvailable/{print int($2/1024)}' /proc/meminfo)
echo "host MemAvailable=${A} MiB (threshold ${T} MiB)"
[ "$A" -ge "$T" ] || { echo "STOP: memory pressure"; exit 1; }
