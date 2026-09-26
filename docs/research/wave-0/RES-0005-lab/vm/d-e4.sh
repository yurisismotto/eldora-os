#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-D E4 (M3 Fedora 44 -> 45). Usage: d-e4.sh state <LABEL> | stage
set -uo pipefail
U=$(id -u labuser); E="XDG_RUNTIME_DIR=/run/user/$U DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$U/bus"
case "$1" in
state)
  for i in $(seq 1 30); do loginctl list-sessions --no-legend 2>/dev/null | grep -q labuser && break; sleep 3; done; sleep 8
  systemctl start eldora-lab.service 2>/dev/null
  sh /root/collect-desk.sh "$2" | grep -vE '^(  Installed|Component)'
  echo "--- E4 extra"; printf 'gnome-shell: '; rpm -q gnome-shell; printf 'systemd: '; rpm -q systemd; cat /usr/lib/eldora-lab/revision
  printf 'karg systemd.gpt_auto=0: '; grep -q 'systemd.gpt_auto=0' /proc/cmdline && echo present || echo ABSENT; printf 'boot.automount units: '; systemctl list-units --type=automount --no-legend | grep -c boot.automount
  bootupctl status 2>&1 | grep -E 'Update' | head -2
  printf '(a) /usr/local tool: '; /usr/local/bin/labtool 2>&1; printf '(a) service: '; systemctl is-active labtool.service
  printf 'local /etc items: '; for f in /etc/gdm/custom.conf /etc/containers/policy.json /etc/systemd/system/labtool.service /etc/containers/registries.d/50-labregistry.yaml; do [ -e $f ] && printf '%s ' "$(basename $f)"; done; echo
  printf 'toolbox run: '; sudo -iu labuser env $E toolbox run sh -c 'grep VERSION_ID /etc/os-release' 2>&1 | tail -1
  printf 'user dconf color-scheme: '; sudo -u labuser env $E gsettings get org.gnome.desktop.interface color-scheme 2>&1
  df -h /sysroot | tail -1 | awk '{print "sysroot used:", $3, "avail:", $4}'
  systemctl --failed --no-legend | head -5 ;;
stage)
  S=$(date +%s); bootc switch labregistry:5000/eldora-desk:45-v2 2>&1 | grep -vE '^\s*$' | tail -6; echo "stage seconds=$(( $(date +%s)-S ))"
  bootc status --format=humanreadable 2>/dev/null | grep -E 'Staged image|Version' | head -2 ;;
esac
