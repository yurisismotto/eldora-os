#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-D E2: check persistence/behaviour of the mechanisms after a transition. Usage: d-e2-check.sh <LABEL>
set -uo pipefail
for i in $(seq 1 30); do loginctl list-sessions --no-legend 2>/dev/null | grep -q labuser && break; sleep 3; done; sleep 5
echo "===== E2 CHECK: $1 ====="
bootc status --format=humanreadable 2>/dev/null | grep -E 'Booted image|Version' | head -2; cat /usr/lib/eldora-lab/revision 2>/dev/null
printf '(a) /usr/local tool: '; /usr/local/bin/labtool 2>&1; printf '(a) service: '; systemctl is-active labtool.service
printf '(b) sysext: '; systemd-sysext status 2>&1 | awk '$1=="/usr"{print $2}'; command -v labext-tool >/dev/null && labext-tool || echo "labext-tool absent"
printf '(d) htop (local image): '; command -v htop || echo absent
printf 'bootc upgrade --check: '; bootc upgrade --check 2>&1 | tail -1
printf 'desktop: '; systemctl is-active graphical.target gdm | tr '\n' ' '; loginctl list-sessions --no-legend | awk '$3=="labuser"' | wc -l | sed 's/$/ labuser session(s)/'
printf 'secure boot: '; mokutil --sb-state 2>&1 | head -1
systemctl --failed --no-legend | head -3
