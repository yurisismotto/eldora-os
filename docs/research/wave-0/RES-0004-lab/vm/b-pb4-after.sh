#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-B PB4: state after replacement by an image that does not contain the lab package; then request rollback.
set -uo pipefail
sh /root/collect-state.sh AFTER-REPLACEMENT-M3
echo "--- /etc files of a package absent from the new image"; ls -la /etc/eldora-lab/ 2>&1 | tail -6
echo "--- orphaned state/ownership"; ls -ln /var/lib/eldora-lab 2>&1; getent passwd 976 || echo "uid 976: no passwd entry"
echo "--- failed units"; systemctl --failed --no-legend | head -5
echo "--- request rollback to previous deployment"; bootc rollback 2>&1 | tail -1
