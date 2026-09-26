#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-B: AFTER-ROLLBACK snapshot (booted v1 deployment), then roll forward to v2 again (reboot from host).
set -uo pipefail
sh /root/collect-state.sh AFTER-ROLLBACK-M3
echo "--- post-update edits after rollback"; cat /etc/eldora-lab/unmodified.conf; ls /etc/eldora-lab/conf.d/
echo "--- service with newer state present"; systemctl is-active eldora-lab.service; journalctl -b -u eldora-lab --no-pager 2>/dev/null | tail -2
echo "--- roll forward (bootc rollback again swaps to v2)"; bootc rollback 2>&1 | tail -1
