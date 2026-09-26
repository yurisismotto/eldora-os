#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-B: inspect bootloader-update failure; edit /etc after update; then request rollback (reboot done from host).
set -uo pipefail
echo "--- bootloader-update.service failure"; systemctl cat bootloader-update.service 2>/dev/null | grep -E 'ExecStart|Condition' ; journalctl -b -u bootloader-update.service --no-pager 2>/dev/null | tail -6
echo "--- post-update /etc edit (to test rollback semantics)"
echo "value=edited-after-update" > /etc/eldora-lab/unmodified.conf
echo "tuned=after-update" > /etc/eldora-lab/conf.d/after-update.conf
echo "--- bootc rollback"; bootc rollback 2>&1 | tail -3
bootc status --format=humanreadable 2>&1 | grep -E 'Staged|Booted|Rollback|Version'
