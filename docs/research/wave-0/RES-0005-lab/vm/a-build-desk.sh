#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-A: build/sign/push desktop lab images; optionally install one to /dev/vdb.
# Usage: [REV=n] a-build-desk.sh <base-image> <tag> <lab_ver> [install]
set -uo pipefail
cd ~/lab; R=labregistry:5000/eldora-desk; BASE="$1"; TAG="$2"; V="$3"
cp containerfile ctx/Containerfile
S=$(date +%s)
sudo podman build -q --build-arg BASE="$BASE" --build-arg LAB_VER="$V" --build-arg REV="${REV:-0}" -t "$R:$TAG" ctx 2>&1 | grep -vE '^\s*$' | tail -4
echo "build seconds=$(( $(date +%s)-S )) exit=${PIPESTATUS[0]}"
S=$(date +%s)
sudo podman push -q --tls-verify=false --sign-by-sigstore-private-key sigA.private --sign-passphrase-file sigpass "$R:$TAG" 2>&1 | tail -2
echo "push seconds=$(( $(date +%s)-S ))"
printf 'registry digest: '; skopeo inspect --tls-verify=false "docker://$R:$TAG" --format '{{.Digest}} layers={{len .Layers}}'
sudo podman run --rm "$R:$TAG" sh -c 'grep -E "^eldoralab" /etc/passwd /etc/group' 2>/dev/null
if [ "${4:-}" = install ]; then
  sudo install -m 0644 ~/.ssh/authorized_keys /root/lab-root-keys
  S=$(date +%s)
  sudo podman run --rm --privileged --pid=host -v /dev:/dev -v /var/lib/containers:/var/lib/containers \
    -v /root/lab-root-keys:/lab-root-keys:ro --security-opt label=type:unconfined_t "$R:$TAG" \
    bootc install to-disk --wipe --filesystem xfs --root-ssh-authorized-keys /lab-root-keys --target-imgref "$R:$TAG" /dev/vdb 2>&1 | tail -4
  echo "install seconds=$(( $(date +%s)-S ))"; sync; lsblk -f /dev/vdb | tail -3
fi
