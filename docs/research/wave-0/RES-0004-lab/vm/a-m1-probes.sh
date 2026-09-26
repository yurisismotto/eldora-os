#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-A as LAB-M1 (Fedora 44 package-based). PB5 (RPM trust), PB3 (/etc, users), PB2 (admin ops). Disposable VM only.
set -uo pipefail
cd ~/lab; C="sudo sh $HOME/lab/collect-state.sh"
echo "################ PB5-M1: RPM verification ################"
echo "default _pkgverify_level on F44: $(rpm --eval '%{_pkgverify_level}')"
echo "--- T1 unsigned, default level"; sudo rpm -i rpms/unsigned/eldora-lab-config-1-1.noarch.rpm && echo "RESULT: accepted"; sudo rpm -e eldora-lab-config >/dev/null 2>&1
echo "--- T2 unsigned, level=all"; sudo rpm -i --define '_pkgverify_level all' rpms/unsigned/eldora-lab-config-1-1.noarch.rpm 2>&1 | tail -2; rpm -q eldora-lab-config >/dev/null 2>&1 && { echo "RESULT: accepted"; sudo rpm -e eldora-lab-config; } || echo "RESULT: rejected"
sudo rpm --import rpms/LAB-KEY-A.asc
echo "--- T3 signed by untrusted key B, level=all (only key A imported)"; sudo rpm -i --define '_pkgverify_level all' rpms/signedB/eldora-lab-config-1-1.noarch.rpm 2>&1 | tail -2; rpm -q eldora-lab-config >/dev/null 2>&1 && { echo "RESULT: accepted"; sudo rpm -e eldora-lab-config; } || echo "RESULT: rejected"
echo "--- T4 signed by trusted key A, level=all"; sudo rpm -i --define '_pkgverify_level all' rpms/signedA/eldora-lab-config-1-1.noarch.rpm 2>&1 | tail -2; rpm -q eldora-lab-config >/dev/null 2>&1 && { echo "RESULT: accepted"; sudo rpm -e eldora-lab-config; } || echo "RESULT: rejected"
echo "--- T5 dnf with repo gpgcheck=1 (key A) installing B-signed package"
mkdir -p repo-B && cp rpms/signedB/eldora-lab-config-1-1.noarch.rpm repo-B/ && createrepo_c -q repo-B
printf '[eldora-lab-B]\nname=lab B (RESEARCH ONLY)\nbaseurl=file://%s/lab/repo-B\ngpgcheck=1\ngpgkey=file://%s/lab/rpms/LAB-KEY-A.asc\n' "$HOME" "$HOME" | sudo tee /etc/yum.repos.d/eldora-lab-B.repo >/dev/null
sudo dnf -y -q --repo=eldora-lab-B install eldora-lab-config 2>&1 | tail -3; rpm -q eldora-lab-config >/dev/null 2>&1 && { echo "RESULT: accepted"; sudo rpm -e eldora-lab-config; } || echo "RESULT: rejected"
sudo rm -f /etc/yum.repos.d/eldora-lab-B.repo

echo "################ PB3-M1: /etc + users/groups ################"
mkdir -p repo-m1 && cp rpms/signedA/eldora-lab-config-1-1.noarch.rpm repo-m1/ && createrepo_c -q repo-m1
printf '[eldora-lab]\nname=lab (RESEARCH ONLY)\nbaseurl=file://%s/lab/repo-m1\ngpgcheck=1\ngpgkey=file://%s/lab/rpms/LAB-KEY-A.asc\nmetadata_expire=0\n' "$HOME" "$HOME" | sudo tee /etc/yum.repos.d/eldora-lab.repo >/dev/null
sudo dnf -y -q --repo=eldora-lab install eldora-lab-config 2>&1 | grep -E 'sysusers|Creating' ; sudo systemctl start eldora-lab.service
$C BEFORE-M1
echo "--- local changes (admin)"
echo "value=local" | sudo tee /etc/eldora-lab/modified.conf >/dev/null
echo "color=green" | sudo tee /etc/eldora-lab/conf.d/local.conf >/dev/null
sudo useradd -m labuser && sudo usermod -aG eldoralab labuser && echo "usermod exit=$?"
echo "user data" | sudo tee /home/labuser/marker.txt >/dev/null
sudo hostnamectl set-hostname lab-m1-custom
printf '[Unit]\nDescription=RESEARCH ONLY local unit\n[Service]\nType=oneshot\nExecStart=/bin/true\nRemainAfterExit=yes\n[Install]\nWantedBy=multi-user.target\n' | sudo tee /etc/systemd/system/local-hello.service >/dev/null
sudo systemctl daemon-reload && sudo systemctl enable --now local-hello.service 2>&1 | tail -1
$C LOCAL-CHANGES-M1
echo "--- UPDATE to v2 (dnf upgrade)"
cp rpms/signedA/eldora-lab-config-2-1.noarch.rpm repo-m1/ && createrepo_c -q --update repo-m1
sudo dnf -y --repo=eldora-lab upgrade eldora-lab-config 2>&1 | grep -iE 'warning|rpmnew|sysusers|Creating|Upgrading' ; sudo systemctl restart eldora-lab.service
$C AFTER-UPDATE-M1
echo "--- ROLLBACK (dnf downgrade to v1)"
sudo dnf -y --repo=eldora-lab downgrade eldora-lab-config-1 2>&1 | grep -iE 'warning|rpmnew|rpmsave|Downgrading|Removing' ; sudo systemctl restart eldora-lab.service
$C AFTER-ROLLBACK-M1

echo "################ PB2-M1: advanced admin ops ################"
echo "--- O1 persistent CLI tool"; sudo dnf -y -q install strace >/dev/null 2>&1; command -v strace && echo "steps=1 reboot=no rebuild=no"
echo "--- O4 write /usr/local and /opt"; sudo touch /usr/local/bin/lab-local-tool /opt/lab-opt-file && echo "writes OK"
echo "--- O5 container tool env"; podman --version
echo "--- O6 revert"; sudo dnf -y -q remove strace >/dev/null 2>&1; command -v strace || echo "strace removed"; sudo rm -f /usr/local/bin/lab-local-tool /opt/lab-opt-file
echo "--- dnf history (last 5)"; sudo dnf history list 2>/dev/null | head -7
