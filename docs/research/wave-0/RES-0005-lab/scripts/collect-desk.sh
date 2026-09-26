#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# Read-only state snapshot for RES-0005 (desktop, boot/Secure Boot, IDs, user/machine state). Run as root in VM-D.
echo "===== STATE: $1 ($(date -u +%FT%TZ)) ====="
echo "--- deployment"; bootc status --format=humanreadable 2>/dev/null | grep -E 'Booted image|Rollback image|Staged image|Version' | head -6
. /etc/os-release; echo "$PRETTY_NAME / kernel $(uname -r)"
echo "--- boot/secure boot"; mokutil --sb-state 2>&1 | head -1; printf 'lockdown: '; cat /sys/kernel/security/lockdown 2>/dev/null
printf 'bootloader-update.service: '; systemctl is-failed bootloader-update.service 2>/dev/null
bootupctl status 2>&1 | grep -E 'Component|Installed|Update' | head -6
echo "--- desktop"; printf 'default target: '; systemctl get-default
for u in graphical.target gdm.service NetworkManager.service; do printf '%s: %s\n' $u "$(systemctl is-active $u)"; done
S=$(loginctl list-sessions --no-legend 2>/dev/null | awk '$3=="labuser"{print $1; exit}')
if [ -n "$S" ]; then loginctl show-session "$S" -p Type -p State -p Active -p Class -p Desktop | tr '\n' ' '; echo
  for s in pipewire wireplumber xdg-desktop-portal; do printf 'user %s: %s\n' $s "$(systemctl --user -M labuser@ is-active $s 2>/dev/null)"; done
  printf 'gnome-shell running: '; pgrep -u labuser -c gnome-shell
  U=$(id -u labuser); printf 'audio server: '; sudo -u labuser XDG_RUNTIME_DIR=/run/user/$U pactl info 2>/dev/null | grep -E 'Server Name' | cut -d: -f2
  printf 'user setting color-scheme: '; sudo -u labuser DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$U/bus gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null
else echo "no labuser session"; fi
echo "--- IDs (E5)"; for n in eldoralab eldoralab2; do getent passwd $n || echo "$n: absent"; done; for g in eldoralab eldoralabextra; do getent group $g || echo "group $g: absent"; done
ls -ln /var/lib/eldora-lab 2>&1 | tail -n +2; printf 'image /usr/etc/passwd: '; grep -E '^eldoralab' /usr/etc/passwd 2>/dev/null | cut -d: -f1,3 | tr '\n' ' '; echo
echo "--- lab service"; systemctl is-active eldora-lab.service; tail -n 3 /var/lib/eldora-lab/state.log 2>/dev/null
echo "--- user/machine state"; ls -l /home/labuser/marker.txt 2>&1 | awk '{print $1,$3,$NF}'; printf 'machine-id: '; sha256sum /etc/machine-id | cut -c1-16; hostname
echo "--- trust"; python3 -c 'import json;d=json.load(open("/etc/containers/policy.json"));print("policy default:",d["default"])'
