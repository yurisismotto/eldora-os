#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-A E4: rebase the lab desktop image to Fedora 45 by changing ONLY the base image reference.
set -uo pipefail
cd ~/lab
S=$(date +%s); sudo podman pull -q quay.io/fedora/fedora-silverblue:45 >/dev/null; echo "pull 45 seconds=$(( $(date +%s)-S ))"
sudo podman image inspect quay.io/fedora/fedora-silverblue:45 --format 'base45 digest={{.Digest}} version={{index .Labels "org.opencontainers.image.version"}} bootc={{index .Labels "containers.bootc"}} size={{.Size}}'
sudo podman run --rm quay.io/fedora/fedora-silverblue:45 sh -c 'grep -E "^(PRETTY_NAME|RELEASE_TYPE)" /etc/os-release; rpm -q bootc rpm-ostree gnome-shell kernel-core shim-x64 grub2-efi-x64 bootupd' 2>/dev/null
REV=45 bash ./a-build-desk.sh quay.io/fedora/fedora-silverblue:45 45-v2 2 2>&1 | grep -E 'seconds|digest|eldoralab|error|Error'
