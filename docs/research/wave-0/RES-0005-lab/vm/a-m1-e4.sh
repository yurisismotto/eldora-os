#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-A (LAB-M1, package-based) E4: Fedora 44 -> 45 via dnf system-upgrade. Usage: a-m1-e4.sh prep|state <LABEL>|update|download|reboot
set -uo pipefail
cd ~/lab
case "$1" in
prep)
  mkdir -p repo-m1 && cp ctx/eldora-lab-config-2-1.noarch.rpm repo-m1/ && createrepo_c -q repo-m1
  sudo rpm --import ctx/LAB5-RPM-KEY-A.asc
  printf '[eldora-lab]\nname=lab (RESEARCH ONLY)\nbaseurl=file://%s/lab/repo-m1\ngpgcheck=1\ngpgkey=file://%s/lab/ctx/LAB5-RPM-KEY-A.asc\n' "$HOME" "$HOME" | sudo tee /etc/yum.repos.d/eldora-lab.repo >/dev/null
  sudo dnf -y -q --repo=eldora-lab install eldora-lab-config 2>&1 | grep -iE 'creat|error' ; sudo systemctl start eldora-lab.service
  echo "value=local" | sudo tee /etc/eldora-lab/modified.conf >/dev/null; echo "color=green" | sudo tee /etc/eldora-lab/conf.d/local.conf >/dev/null
  id labuser >/dev/null 2>&1 || sudo useradd -m labuser; echo "user data" | sudo tee /home/labuser/marker.txt >/dev/null
  echo "prep done" ;;
state)
  echo "===== M1 STATE: $2 ($(date -u +%FT%TZ)) ====="
  grep -E '^(PRETTY_NAME|VERSION_ID)' /etc/os-release; uname -r; findmnt -no FSTYPE /
  printf 'packages: '; rpm -qa | wc -l; rpm -q eldora-lab-config docker-distribution podman systemd dnf5 kernel-core | tr '\n' ' '; echo
  for f in /etc/eldora-lab/*.conf /etc/eldora-lab/conf.d/*; do [ -e "$f" ] && echo "$f: $(tr '\n' ' ' < "$f")"; done
  printf '.rpmnew/.rpmsave under /etc: '; sudo find /etc \( -name '*.rpmnew' -o -name '*.rpmsave' \) 2>/dev/null | tr '\n' ' '; echo
  getent passwd eldoralab eldoralab2 labuser | cut -d: -f1,3; getent group eldoralabextra | cut -d: -f1,3
  sudo ls -ln /var/lib/eldora-lab | tail -n +2; sudo tail -n 2 /var/lib/eldora-lab/state.log; ls -l /home/labuser/marker.txt | awk '{print $1,$NF}'
  for s in docker-distribution eldora-lab sshd; do printf '%s: %s\n' $s "$(systemctl is-active $s)"; done
  printf 'registry catalog: '; curl -s http://labregistry:5000/v2/_catalog; echo
  sudo systemctl --failed --no-legend | head -5; df -h / | tail -1 ;;
update)
  S=$(date +%s); sudo dnf -y --refresh upgrade 2>&1 | grep -E 'Total size|Nothing to do|Complete|Error|warning' | tail -4; echo "pre-upgrade update seconds=$(( $(date +%s)-S ))" ;;
download)
  S=$(date +%s); sudo dnf -y system-upgrade download --releasever=45 2>&1 | grep -viE '^\s*\[|^ +[0-9]+%|^Updating|^Repositories loaded' | grep -E 'Total size|Upgrading:|Installing:|Removing:|Downgrading:|conflict|Problem|Warning|warning|Error|error|Complete|Transaction|packages' | tail -15
  echo "download seconds=$(( $(date +%s)-S ))"; df -h / | tail -1 ;;
reboot)
  sudo dnf -y offline reboot 2>&1 | tail -2 ;;
esac
