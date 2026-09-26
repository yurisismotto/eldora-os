#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-D: test hypothesis "active sysext breaks staged-deployment finalization": unmerge + disable sysext, restage.
set -uo pipefail
systemd-sysext unmerge 2>&1 | tail -1; systemctl disable systemd-sysext.service 2>&1 | tail -1
mv /var/lib/extensions/labext /var/lib/labext.disabled
systemd-sysext status 2>&1 | awk '$1=="/usr"{print "sysext /usr:", $2}'
bootc switch --transport containers-storage localhost/eldora-local:latest 2>&1 | tail -2
bootc status --format=humanreadable 2>/dev/null | grep -E 'Staged image' | head -1
