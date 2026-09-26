#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-D: controlled trials for the finalize failure. Usage: d-trial.sh A|B|result
set -uo pipefail
case "$1" in
  A) ls /boot >/dev/null 2>&1; findmnt -no TARGET,FSTYPE,SOURCE /boot | sed 's/^/trial A, before reboot: \/boot mounted as: /' ;;
  B) rpm-ostree rebase ostree-unverified-registry:labregistry:5000/eldora-desk:44-r4 2>&1 | tail -1
     systemctl stop boot.automount boot.mount 2>/dev/null; printf 'trial B, before reboot: boot.automount=%s /boot mount=%s\n' "$(systemctl is-active boot.automount)" "$(findmnt -no FSTYPE /boot || echo none)" ;;
  result) printf 'booted revision: '; cat /usr/lib/eldora-lab/revision; journalctl -b -1 -u ostree-finalize-staged --no-pager -o cat 2>/dev/null | grep -E 'error|Finished|Failed' | tail -2 ;;
esac
