#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-D: mitigation test. step1: add karg systemd.gpt_auto=0 (touch /boot first so this staging finalizes).
#       step2: with the karg active, repeat trial B (stage a change with /boot untouched) and check result after reboot.
set -uo pipefail
case "$1" in
  step1) ls /boot >/dev/null; rpm-ostree kargs --append=systemd.gpt_auto=0 2>&1 | tail -1 ;;
  step2) grep -o 'systemd.gpt_auto=0' /proc/cmdline; systemctl list-units --type=automount --no-legend | grep -c boot.automount | sed 's/^/boot.automount units: /'
         rpm-ostree rebase ostree-unverified-registry:labregistry:5000/eldora-desk:44-r4 2>&1 | tail -1
         findmnt -no FSTYPE /boot || echo "/boot not mounted before reboot (trial B condition)" ;;
esac
