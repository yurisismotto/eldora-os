#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-D: state after `rpm-ostree reset` (layering removed); do local kargs survive; bootc usable again?
cat /usr/lib/eldora-lab/revision; command -v strace || echo "strace: absent (layering removed)"
grep -o 'systemd.gpt_auto=0' /proc/cmdline || echo "karg systemd.gpt_auto=0: NOT present after reset"
systemctl list-units --type=automount --no-legend | grep -c boot.automount | sed 's/^/boot.automount units: /'
bootc upgrade --check 2>&1 | tail -1
bootc status --format=humanreadable 2>/dev/null | grep -E 'Booted image' | head -1
