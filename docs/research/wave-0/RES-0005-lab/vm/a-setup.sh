#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-A: builder + lab registry setup; build lab RPMs (fixed IDs); ephemeral keys; inspect desktop base image.
set -euo pipefail
echo "--- versions"; grep PRETTY /etc/os-release; uname -r
sudo dnf -y -q install podman skopeo rpm-build rpm-sign systemd-rpm-macros docker-distribution createrepo_c >/dev/null 2>&1
rpm -q rpm dnf5 systemd podman skopeo docker-distribution
grep -q labregistry /etc/hosts || echo "127.0.0.1 labregistry" | sudo tee -a /etc/hosts >/dev/null
sudo mkdir -p /etc/containers/registries.conf.d /etc/containers/registries.d
printf '[[registry]]\nlocation = "labregistry:5000"\ninsecure = true\n' | sudo tee /etc/containers/registries.conf.d/50-labregistry.conf >/dev/null
printf 'docker:\n  labregistry:5000:\n    use-sigstore-attachments: true\n' | sudo tee /etc/containers/registries.d/50-labregistry.yaml >/dev/null
sudo systemctl enable --now docker-distribution >/dev/null 2>&1
cd ~/lab
for v in 1 2; do rpmbuild -bb --define "lab_ver $v" --define "_topdir $HOME/lab/rpmbuild" eldora-lab-config.spec >/dev/null 2>&1; done
export GNUPGHOME=$HOME/lab/gnupg; mkdir -p "$GNUPGHOME"; chmod 700 "$GNUPGHOME"
gpg --batch --quiet --passphrase '' --quick-gen-key "Eldora LAB5 RPM key A (RESEARCH ONLY) <lab5-A@invalid>" ed25519 sign never 2>/dev/null
mkdir -p ctx && cp rpmbuild/RPMS/noarch/*.rpm ctx/
rpmsign --define "_openpgp_sign_id lab5-A@invalid" --addsign ctx/*.rpm >/dev/null 2>&1
gpg --armor --export lab5-A@invalid > ctx/LAB5-RPM-KEY-A.asc
rpm -Kv ctx/eldora-lab-config-1-1.noarch.rpm 2>&1 | grep -i signature
printf 'lab-only-passphrase' > sigpass; [ -f sigA.private ] || skopeo generate-sigstore-key --output-prefix sigA --passphrase-file sigpass >/dev/null
echo "--- desktop base candidate: quay.io/fedora/fedora-silverblue:44"
S=$(date +%s); sudo podman pull -q quay.io/fedora/fedora-silverblue:44 >/dev/null; echo "pull seconds=$(( $(date +%s)-S ))"
sudo podman image inspect quay.io/fedora/fedora-silverblue:44 --format 'digest={{.Digest}} size={{.Size}} containers.bootc={{index .Labels "containers.bootc"}} ostree.bootable={{index .Labels "ostree.bootable"}} version={{index .Labels "org.opencontainers.image.version"}}'
sudo podman run --rm quay.io/fedora/fedora-silverblue:44 sh -c 'rpm -q bootc rpm-ostree gnome-shell gdm kernel-core pipewire xdg-desktop-portal NetworkManager shim-x64 grub2-efi-x64 bootupd 2>&1; ls -ld /usr/local /opt; readlink /usr/local /opt' 2>/dev/null
df -h / | tail -1
