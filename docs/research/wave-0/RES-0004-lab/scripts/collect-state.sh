#!/bin/sh
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# Read-only state snapshot for RES-0004 probes. Usage: sudo sh collect-state.sh <LABEL>
echo "===== STATE: $1 ($(date -u +%FT%TZ)) ====="
echo "--- os/deployment"; . /etc/os-release; echo "$PRETTY_NAME"; command -v bootc >/dev/null && bootc status --format=humanreadable 2>/dev/null | grep -E 'Booted image|Rollback image|Staged image|Digest|Version' | head -12
echo "--- rpm"; rpm -q eldora-lab-config 2>&1
echo "--- /etc/eldora-lab"; for f in /etc/eldora-lab/*.conf /etc/eldora-lab/*.rpmnew /etc/eldora-lab/*.rpmsave /etc/eldora-lab/conf.d/*; do [ -e "$f" ] && echo "$f: $(tr '\n' ' ' < "$f")"; done
echo "--- effective config"; /usr/bin/eldora-lab-effective 2>&1 | tr '\n' ' '; echo
echo "--- users/groups"; for n in eldoralab eldoralab2 labuser; do printf '%s: ' $n; getent passwd $n || echo "(absent)"; done
for g in eldoralab eldoralabextra; do printf 'group %s: ' $g; getent group $g || echo "(absent)"; done
printf 'id labuser: '; id labuser 2>&1
echo "--- /etc/passwd origin"; grep -c . /etc/passwd | sed 's/^/etc-passwd-lines=/'; [ -f /usr/lib/passwd ] && grep -c . /usr/lib/passwd | sed 's/^/usr-lib-passwd-lines=/'
echo "--- service state"; systemctl is-active eldora-lab.service 2>&1; tail -n 5 /var/lib/eldora-lab/state.log 2>&1
echo "--- machine state"; printf 'machine-id sha256: '; sha256sum /etc/machine-id | cut -c1-16; hostname; for k in /etc/ssh/ssh_host_*_key.pub; do ssh-keygen -lf "$k" | awk '{print $2, $4}'; done
echo "--- user data"; ls -l /home/labuser/marker.txt 2>&1; cat /home/labuser/marker.txt 2>/dev/null
echo "--- local customizations"; ls /etc/systemd/system/local-hello.service 2>&1; systemctl is-enabled local-hello.service 2>&1; command -v strace 2>&1 || echo "strace: absent"
echo "--- boots"; journalctl --list-boots --no-pager 2>/dev/null | tail -n 4
