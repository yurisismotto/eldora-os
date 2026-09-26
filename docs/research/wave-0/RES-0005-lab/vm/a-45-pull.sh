#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-A E4 step 1: pull the Fedora 45 desktop base (Silverblue 45) and record its identity.
set -uo pipefail
free -m | sed -n 2p | awk '{print "VM-A mem used/avail MiB:", $3, $7}'
S=$(date +%s); sudo podman pull -q quay.io/fedora/fedora-silverblue:45 >/dev/null; echo "pull 45 exit=$? seconds=$(( $(date +%s)-S ))"
sudo podman image inspect quay.io/fedora/fedora-silverblue:45 --format 'base45 digest={{.Digest}} version={{index .Labels "org.opencontainers.image.version"}} bootc={{index .Labels "containers.bootc"}} size={{.Size}}'
sudo podman run --rm quay.io/fedora/fedora-silverblue:45 sh -c 'grep -E "^(PRETTY_NAME|RELEASE_TYPE|VERSION_ID)" /etc/os-release; rpm -q bootc rpm-ostree gnome-shell gdm kernel-core shim-x64 grub2-efi-x64 bootupd dnf5 systemd pipewire' 2>/dev/null
df -h / | tail -1
