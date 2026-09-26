#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# Usage: labssh.sh <a|d> <user> <command...>   (ephemeral lab key; does not touch ~/.ssh/known_hosts)
L=/home/yuri/.claude/jobs/95dfae05/tmp/lab5
case "$1" in a) P=2231;; d) P=2232;; *) echo "vm must be a or d"; exit 2;; esac
U="$2"; shift 2
exec ssh -q -i "$L/labkey" -p "$P" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -o ConnectTimeout=10 -o BatchMode=yes "$U@127.0.0.1" "$@"
