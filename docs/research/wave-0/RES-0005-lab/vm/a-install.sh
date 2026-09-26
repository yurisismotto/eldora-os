#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-A: install a desktop lab image to /dev/vdb as a GENERIC image (EFI fallback path; no firmware boot entry needed).
# Usage: a-install.sh <tag>
set -uo pipefail
R=labregistry:5000/eldora-desk; TAG="$1"
S=$(date +%s)
sudo podman run --rm --privileged --pid=host -v /dev:/dev -v /var/lib/containers:/var/lib/containers \
  -v /root/lab-root-keys:/lab-root-keys:ro --security-opt label=type:unconfined_t "$R:$TAG" \
  bootc install to-disk --wipe --generic-image --filesystem xfs --root-ssh-authorized-keys /lab-root-keys --target-imgref "$R:$TAG" /dev/vdb 2>&1 | grep -viE '^\s*$' | tail -5
echo "install seconds=$(( $(date +%s)-S ))"; sync
sudo mkdir -p /mnt/esp && sudo mount -o ro /dev/vdb2 /mnt/esp && sudo find /mnt/esp -maxdepth 3 -type f | sort; sudo umount /mnt/esp
