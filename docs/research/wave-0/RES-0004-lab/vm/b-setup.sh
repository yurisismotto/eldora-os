#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-B (LAB-M3, bootc) client setup. Default trust policy is left untouched here (tested in PB5).
set -uo pipefail
echo "--- versions"; grep PRETTY /etc/os-release; uname -r; rpm -q bootc rpm-ostree ostree systemd dnf5 podman selinux-policy-targeted; getenforce
echo "--- mounts"; findmnt -no FSTYPE,OPTIONS / | cut -c1-80; findmnt -no OPTIONS /usr | cut -c1-40; for p in /home /root /opt /usr/local /srv /mnt; do printf '%s -> %s\n' "$p" "$(readlink "$p" || echo '(dir)')"; done
echo "--- nss"; grep -E '^(passwd|group):' /etc/nsswitch.conf; ls -l /usr/lib/passwd /usr/lib/group 2>&1
echo "--- default container policy"; python3 -c 'import json;print(json.load(open("/etc/containers/policy.json"))["default"])'
grep -q labregistry /etc/hosts || echo "10.0.2.2 labregistry" >> /etc/hosts
mkdir -p /etc/containers/registries.conf.d /etc/containers/registries.d
printf '[[registry]]\nlocation = "labregistry:5000"\ninsecure = true\n' > /etc/containers/registries.conf.d/50-labregistry.conf
printf 'docker:\n  labregistry:5000:\n    use-sigstore-attachments: true\n' > /etc/containers/registries.d/50-labregistry.yaml
curl -s http://labregistry:5000/v2/_catalog; echo
echo "--- bootc status"; bootc status --format=humanreadable 2>&1 | head -20
systemctl is-enabled bootc-fetch-apply-updates.timer 2>&1
