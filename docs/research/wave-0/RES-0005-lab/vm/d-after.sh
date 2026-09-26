#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-D: wait for the desktop session, then snapshot. Usage: d-after.sh <LABEL>
set -uo pipefail
for i in $(seq 1 30); do loginctl list-sessions --no-legend 2>/dev/null | grep -q labuser && break; sleep 3; done; sleep 10
systemctl start eldora-lab.service 2>/dev/null
sh /root/collect-desk.sh "$1"
echo "--- E5 conflict detail"; getent passwd 851 | cut -d: -f1,3; getent group eldoralabextra | cut -d: -f1,3; journalctl -b -u systemd-sysusers --no-pager 2>/dev/null | grep -iE 'eldora|851|852|creat|conflict|already' | tail -5
ls -ln /var/lib/localdev-data/file 2>&1 | awk '{print $3,$4,$NF}'
echo "--- failed units"; systemctl --failed --no-legend | head -5
