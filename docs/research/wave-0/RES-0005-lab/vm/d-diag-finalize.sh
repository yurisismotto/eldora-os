#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-D: diagnose why the staged deployment was not applied (read-only).
bootc status --format=humanreadable 2>/dev/null | grep -E 'Staged|Booted|Rollback' | head -4
echo "--- previous boot: ostree-finalize-staged"; journalctl -b -1 -u ostree-finalize-staged.service --no-pager -o short 2>/dev/null | tail -12
echo "--- previous boot: sysext at shutdown"; journalctl -b -1 --no-pager -o cat 2>/dev/null | grep -iE 'sysext|extension' | tail -5
echo "--- this boot: ostree-boot-complete"; systemctl status ostree-boot-complete.service --no-pager 2>&1 | grep -E 'Active|Main PID|code=' | head -3; journalctl -b -u ostree-boot-complete --no-pager -o cat | tail -3
ls /boot/ostree-finalize-staged.failed 2>&1
