#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-A: build lab bootc images FROM quay.io/fedora/fedora-bootc:44, sign with ephemeral sigstore keys,
# push to the lab-only local registry, and install v1 to the second disk (/dev/vdb) for VM-B.
set -euo pipefail
cd ~/lab; R=labregistry:5000/eldora-lab
sudo mkdir -p /etc/containers/registries.d
printf 'docker:\n  labregistry:5000:\n    use-sigstore-attachments: true\n' | sudo tee /etc/containers/registries.d/50-labregistry.yaml >/dev/null
echo "--- pull base"; sudo podman pull -q quay.io/fedora/fedora-bootc:44
sudo podman image inspect quay.io/fedora/fedora-bootc:44 --format 'base digest={{.Digest}} version={{index .Labels "org.opencontainers.image.version"}} created={{.Created}}'
sudo podman run --rm quay.io/fedora/fedora-bootc:44 sh -c 'rpm -q bootc rpm-ostree ostree kernel-core systemd; grep PRETTY /etc/os-release' 2>/dev/null
mkdir -p ctx && cp rpms/signedA/*.rpm ctx/ && cp containerfile ctx/Containerfile
# ephemeral sigstore keys A (trusted) and B (untrusted)
printf 'lab-only-passphrase' > sigpass
for k in A B; do [ -f sig$k.private ] || skopeo generate-sigstore-key --output-prefix sig$k --passphrase-file sigpass >/dev/null; done
build() { sudo podman build -q --build-arg LAB_VER=$1 ${3:+--label lab.variant=$3} -t "$2" ctx >/dev/null; echo "built $2"; }
build 1 $R:v1; build 2 $R:v2; build 2 $R:v2u unsigned; build 2 $R:v2b keyB
push() { sudo podman push -q --tls-verify=false ${2:+--sign-by-sigstore-private-key sig$2.private --sign-passphrase-file sigpass} "$1"; echo "pushed $1 (signed by: ${2:-none})"; }
push $R:v1 A; push $R:v2 A; push $R:v2u; push $R:v2b B
# replacement image for PB4: plain Fedora bootc base (no lab package), signed A
sudo podman tag quay.io/fedora/fedora-bootc:44 labregistry:5000/eldora-lab-plain:44
push labregistry:5000/eldora-lab-plain:44 A
for t in v1 v2 v2u v2b; do printf '%s ' $t; skopeo inspect --tls-verify=false docker://$R:$t --format '{{.Digest}}'; done
curl -s http://labregistry:5000/v2/_catalog; echo
echo "--- install v1 to /dev/vdb"
sudo install -m 0644 ~/.ssh/authorized_keys /root/lab-root-keys
sudo podman run --rm --privileged --pid=host -v /dev:/dev -v /var/lib/containers:/var/lib/containers \
  -v /root/lab-root-keys:/lab-root-keys:ro --security-opt label=type:unconfined_t $R:v1 \
  bootc install to-disk --wipe --root-ssh-authorized-keys /lab-root-keys --target-imgref $R:v1 /dev/vdb 2>&1 | tail -6
sync; echo "install done"
