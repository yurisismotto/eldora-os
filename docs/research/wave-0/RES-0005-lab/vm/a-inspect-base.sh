#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-A: ephemeral sigstore key; inspect desktop base candidate quay.io/fedora/fedora-silverblue:44.
set -uo pipefail
cd ~/lab
printf 'lab-only-passphrase' > sigpass; [ -f sigA.private ] || skopeo generate-sigstore-key --output-prefix sigA --passphrase-file sigpass >/dev/null; ls sigA.*
echo "--- desktop base candidate: quay.io/fedora/fedora-silverblue:44"
S=$(date +%s); sudo podman pull -q quay.io/fedora/fedora-silverblue:44 >/dev/null; echo "pull seconds=$(( $(date +%s)-S ))"
sudo podman image inspect quay.io/fedora/fedora-silverblue:44 --format 'digest={{.Digest}} size={{.Size}} containers.bootc={{index .Labels "containers.bootc"}} ostree.bootable={{index .Labels "ostree.bootable"}} version={{index .Labels "org.opencontainers.image.version"}}'
sudo podman run --rm quay.io/fedora/fedora-silverblue:44 sh -c 'rpm -q bootc rpm-ostree gnome-shell gdm kernel-core pipewire xdg-desktop-portal NetworkManager shim-x64 grub2-efi-x64 bootupd composefs 2>&1; printf "/usr/local -> %s\n/opt -> %s\n" "$(readlink /usr/local)" "$(readlink /opt)"; ls /usr/lib/bootupd/updates 2>&1 | head' 2>/dev/null
df -h / | tail -1
