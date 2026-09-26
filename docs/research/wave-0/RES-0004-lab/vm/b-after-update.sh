#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-B: AFTER-UPDATE snapshot (v2), image-vs-local identity comparison, /usr/lib-only group test.
set -uo pipefail
sh /root/collect-state.sh AFTER-UPDATE-M3
echo "--- image default vs local /etc for identity files"
for f in passwd group; do printf '%s: image(/usr/etc) has eldoralab2/eldoralabextra? ' $f; grep -cE '^(eldoralab2|eldoralabextra):' /usr/etc/$f; grep -E '^eldoralab:' /usr/etc/$f /etc/$f; done
echo "--- systemd-sysusers at boot"; journalctl -b -u systemd-sysusers --no-pager 2>/dev/null | grep -iE 'creat|eldoralab' | head -5
echo "--- /var/lib/eldora-lab ownership"; ls -ln /var/lib/eldora-lab
echo "--- group defined only in /usr/lib/group"
G=$(comm -23 <(cut -d: -f1 /usr/lib/group | sort) <(cut -d: -f1 /etc/group | sort) | head -1); echo "group=$G"
usermod -aG "$G" labuser; echo "usermod -aG $G exit=$?"; id labuser | tr ',' '\n' | grep -c "($G)" | sed "s/^/labuser in $G (count): /"; grep -H "^$G:" /etc/group /usr/lib/group
echo "--- journal: failed units"; systemctl --failed --no-legend | head -5
