#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-B (LAB-M3): BEFORE snapshot, same local changes as LAB-M1, and PB2 host-operation attempts.
set -uo pipefail
C="sh /root/collect-state.sh"
systemctl start eldora-lab.service; $C BEFORE-M3
echo "--- local changes (admin)"
echo "value=local" > /etc/eldora-lab/modified.conf
echo "color=green" > /etc/eldora-lab/conf.d/local.conf
useradd -m labuser; echo "useradd exit=$?"
usermod -aG eldoralab labuser; echo "usermod -aG eldoralab exit=$?"
echo "user data" > /home/labuser/marker.txt
hostnamectl set-hostname lab-m3-custom
printf '[Unit]\nDescription=RESEARCH ONLY local unit\n[Service]\nType=oneshot\nExecStart=/bin/true\nRemainAfterExit=yes\n[Install]\nWantedBy=multi-user.target\n' > /etc/systemd/system/local-hello.service
systemctl daemon-reload && systemctl enable --now local-hello.service 2>&1 | tail -1
echo "--- where did eldoralab group come from?"; grep -H '^eldoralab' /etc/group /usr/lib/group 2>&1
echo "################ PB2-M3 host operation attempts ################"
echo "--- O1a dnf install strace (default)"; dnf -y -q install strace 2>&1 | tail -3; command -v strace || echo "RESULT: strace not installed"
echo "--- O1b dnf install --transient strace"; dnf -y -q install --transient strace 2>&1 | tail -3; command -v strace && echo "RESULT: strace available (transient)"
findmnt -no FSTYPE,OPTIONS /usr | cut -c1-60
echo "--- O4 write /usr/local, /opt, /usr/bin"
for p in /usr/local/bin/lab-local-tool /opt/lab-opt-file /usr/bin/lab-usr-file; do touch "$p" 2>&1 | tail -1; [ -e "$p" ] && echo "$p: written"; done
echo "--- O5 container tool env"; podman --version; command -v toolbox || echo "toolbox: not in image"
$C LOCAL-CHANGES-M3
echo "--- /etc drift view (ostree admin config-diff, lab-relevant lines)"; ostree admin config-diff 2>/dev/null | grep -E 'eldora|passwd|group|shadow|hostname|local-hello' | head -12
