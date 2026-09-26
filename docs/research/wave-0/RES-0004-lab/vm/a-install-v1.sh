#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-A: install lab image v1 to /dev/vdb (disposable second disk) with an explicit root filesystem.
set -euo pipefail
R=labregistry:5000/eldora-lab
sudo podman run --rm --privileged --pid=host -v /dev:/dev -v /var/lib/containers:/var/lib/containers \
  -v /root/lab-root-keys:/lab-root-keys:ro --security-opt label=type:unconfined_t $R:v1 \
  bootc install to-disk --wipe --filesystem xfs --root-ssh-authorized-keys /lab-root-keys --target-imgref $R:v1 /dev/vdb 2>&1 | tail -8
sync; lsblk -f /dev/vdb
