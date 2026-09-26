#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-D: /boot mount details (read-only), previous-boot finalize context, then restage r5 to test reproducibility.
set -uo pipefail
findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS /boot /boot/efi /sysroot / 2>&1 | cut -c1-140
systemctl list-units --type=automount --no-legend 2>/dev/null | head -3
echo "--- previous boot finalize context"; journalctl -b -1 --no-pager -o short-monotonic 2>/dev/null | grep -iE 'ostree|boot.mount|boot-efi|remount' | tail -8
echo "--- restage r5 via rpm-ostree rebase (keeps layering)"; rpm-ostree rebase ostree-unverified-registry:labregistry:5000/eldora-desk:44-r5 2>&1 | tail -2
rpm-ostree status 2>&1 | grep -E '●|Version|LayeredPackages' | head -4
