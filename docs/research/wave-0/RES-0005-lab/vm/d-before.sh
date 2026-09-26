#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-D: set a user desktop preference (user state), start the lab service, snapshot BEFORE.
set -uo pipefail
sleep 20
U=$(id -u labuser)
sudo -u labuser DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$U/bus gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>&1
systemctl start eldora-lab.service
echo "--- ESP and boot entries"; efibootmgr 2>/dev/null | head -6 || echo "efibootmgr: n/a"; findmnt -no TARGET,OPTIONS /boot/efi 2>&1 | head -1; ls /boot/loader/entries/ 2>&1
sh /root/collect-desk.sh BEFORE-44v1
