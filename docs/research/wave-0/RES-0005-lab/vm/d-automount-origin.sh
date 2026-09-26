#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-D: where does boot.automount come from? (read-only)
systemctl show -p FragmentPath -p SourcePath boot.automount boot.mount 2>/dev/null
grep -vE '^\s*#|^\s*$' /etc/fstab 2>/dev/null || echo "(no active fstab entries)"
cat /proc/cmdline
lsblk -o NAME,PARTTYPENAME,FSTYPE,MOUNTPOINTS /dev/vda 2>/dev/null
systemd-analyze cat-config systemd/system.conf 2>/dev/null | grep -i gpt | head -2
