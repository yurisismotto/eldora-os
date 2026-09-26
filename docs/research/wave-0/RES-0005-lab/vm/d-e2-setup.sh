#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-D E2 part 1: set up candidate persistent extension mechanisms.
set -uo pipefail
echo "=== (a) /usr/local (-> $(readlink -f /usr/local)) tool + system service in /etc"
printf '#!/bin/sh\necho "labtool ok on $(cat /usr/lib/eldora-lab/revision 2>/dev/null || echo rev=?)"\n' > /usr/local/bin/labtool && chmod +x /usr/local/bin/labtool
ls -Z /usr/local/bin/labtool | awk '{print "selinux label:",$1}'
printf '[Unit]\nDescription=RESEARCH ONLY advanced-user service using /usr/local tool\n[Service]\nType=oneshot\nRemainAfterExit=yes\nExecStart=/usr/local/bin/labtool\n[Install]\nWantedBy=multi-user.target\n' > /etc/systemd/system/labtool.service
systemctl daemon-reload; systemctl enable --now labtool.service 2>&1 | tail -1; systemctl is-active labtool.service; journalctl -u labtool -b --no-pager -o cat | tail -1
echo "=== (b) systemd-sysext extension"
mkdir -p /var/lib/extensions/labext/usr/bin /var/lib/extensions/labext/usr/lib/extension-release.d
printf '#!/bin/sh\necho labext-tool ok\n' > /var/lib/extensions/labext/usr/bin/labext-tool; chmod +x /var/lib/extensions/labext/usr/bin/labext-tool
echo "ID=_any" > /var/lib/extensions/labext/usr/lib/extension-release.d/extension-release.labext
systemd-sysext merge 2>&1 | tail -3; echo "merge exit=$?"; systemd-sysext status 2>&1 | head -5; command -v labext-tool && labext-tool
systemctl enable systemd-sysext.service 2>&1 | tail -1
echo "=== (e) toolbox as desktop user under enforced system trust policy"
U=$(id -u labuser); S=$(date +%s)
sudo -u labuser XDG_RUNTIME_DIR=/run/user/$U DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$U/bus toolbox create -y 2>&1 | tail -3; echo "toolbox create exit=$? seconds=$(( $(date +%s)-S ))"
echo "=== (d) local derived image FROM the upstream channel (documented bootc local-build workflow)"
mkdir -p /etc/eldora-lab-local && printf 'FROM labregistry:5000/eldora-desk:channel\nRUN dnf -y -q install htop && dnf clean all\nRUN bootc container lint\n' > /etc/eldora-lab-local/Containerfile
S=$(date +%s); podman build -q --pull=always -t localhost/eldora-local:latest -f /etc/eldora-lab-local/Containerfile /etc/eldora-lab-local 2>&1 | tail -2; echo "local build seconds=$(( $(date +%s)-S ))"
S=$(date +%s); bootc switch --transport containers-storage localhost/eldora-local:latest 2>&1 | tail -3; echo "switch seconds=$(( $(date +%s)-S ))"
df -h /sysroot | tail -1
