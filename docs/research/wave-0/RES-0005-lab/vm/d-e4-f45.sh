#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-D E4: evidence that the staged F45 deployment was finalized, plus boot-chain / kernel-change details.
set -uo pipefail
echo "--- finalization of the staged deployment (previous boot)"
journalctl -b -1 -u ostree-finalize-staged --no-pager -o cat 2>/dev/null | grep -E 'Finished|error|Failed|Copying /etc' | tail -4
bootc status --format=humanreadable 2>/dev/null | grep -E 'Booted image|Digest|Version|Rollback image' | head -6
grep -E '^(PRETTY_NAME|VERSION_ID|RELEASE_TYPE)' /etc/os-release; uname -r
echo "--- boot artifacts"; ls /boot/loader/entries/; grep -h '^linux\|^options' /boot/loader/entries/*.conf | cut -c1-150
echo "--- bootloader (bootupd)"; bootupctl status 2>&1 | head -8; systemctl is-failed bootloader-update.service; journalctl -b -u bootloader-update --no-pager -o cat | tail -3
echo "--- secure boot / lockdown"; mokutil --sb-state; cat /sys/kernel/security/lockdown; dmesg 2>/dev/null | grep -iE 'secureboot|lockdown' | head -3
echo "--- warnings/failures (this boot)"; systemctl --failed --no-legend; journalctl -b -p err --no-pager -o cat 2>/dev/null | sort | uniq -c | sort -rn | head -8
