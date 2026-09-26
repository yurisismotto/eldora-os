#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-A (LAB-M1 + builder) setup. Runs INSIDE the disposable VM only.
set -euo pipefail
echo "--- versions (before)"; grep PRETTY /etc/os-release; uname -r; rpm -q rpm dnf5 systemd selinux-policy-targeted; getenforce
sudo dnf -y -q install podman skopeo rpm-build rpm-sign systemd-rpm-macros docker-distribution createrepo_c >/dev/null
echo "--- builder tools"; rpm -q podman skopeo rpm-build rpm-sign docker-distribution createrepo_c
# lab registry name resolves to local registry in VM-A
grep -q labregistry /etc/hosts || echo "127.0.0.1 labregistry" | sudo tee -a /etc/hosts >/dev/null
sudo mkdir -p /etc/containers/registries.conf.d
printf '[[registry]]\nlocation = "labregistry:5000"\ninsecure = true\n' | sudo tee /etc/containers/registries.conf.d/50-labregistry.conf >/dev/null
# registry listens on :5000 (docker-distribution default config)
grep -E 'addr|rootdirectory' /etc/docker-distribution/registry/config.yml
sudo systemctl enable --now docker-distribution >/dev/null 2>&1
sleep 2; curl -s http://labregistry:5000/v2/_catalog; echo
df -h / | tail -1
