#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-A (LAB-M1) after the offline system upgrade: offline log, boots, marker, rollback options.
set -uo pipefail
bash ~/lab/a-m1-e4.sh state AFTER-M1-F45
echo "--- offline transaction"; sudo dnf offline log 2>&1 | tail -3; sudo journalctl --list-boots --no-pager 2>/dev/null | tail -4
sudo journalctl -b -1 --no-pager -o cat 2>/dev/null | grep -iE 'offline transaction|Running transaction|Complete!|error' | tail -5
echo "--- /home marker (sudo)"; sudo cat /home/labuser/marker.txt
echo "--- dnf history"; sudo dnf history list 2>/dev/null | head -4
echo "--- system-level rollback options on M1"; findmnt -no FSTYPE /; rpm -q snapper 2>&1 | tail -1; sudo btrfs subvolume list / 2>/dev/null | head -3
echo "--- errors this boot"; sudo journalctl -b -p err --no-pager -o cat 2>/dev/null | sort | uniq -c | sort -rn | head -6
