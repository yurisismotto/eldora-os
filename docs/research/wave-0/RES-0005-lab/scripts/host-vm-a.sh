#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# Host side: fetch+verify Fedora Cloud 44 (if absent), create and start VM-A (builder, registry, LAB-M1). Writes only under $L.
set -euo pipefail
L=/home/yuri/.claude/jobs/95dfae05/tmp/lab5
mkdir -p "$L/gnupg" "$L/logs"; chmod 700 "$L/gnupg"; cd "$L"
B=https://dl.fedoraproject.org/pub/fedora/linux/releases/44/Cloud/x86_64/images
if [ ! -f base44.qcow2 ]; then
  curl -sSfL -o CHECKSUM "$B/Fedora-Cloud-44-1.7-x86_64-CHECKSUM"
  curl -sSfL -o fedora.gpg https://fedoraproject.org/fedora.gpg
  GNUPGHOME="$L/gnupg" gpg -q --import fedora.gpg 2>/dev/null || true
  GNUPGHOME="$L/gnupg" LC_ALL=C gpg --verify CHECKSUM 2>&1 | grep -E "Good signature|BAD|using" || true
  curl -sSfL -o base44.qcow2 "$B/Fedora-Cloud-Base-Generic-44-1.7.x86_64.qcow2"
  echo "expected: $(grep 'Generic-44-1.7.x86_64.qcow2)' CHECKSUM | awk '{print $NF}')"
  echo "actual:   $(sha256sum base44.qcow2 | cut -d' ' -f1)"
fi
[ -f labkey ] || ssh-keygen -q -t ed25519 -N '' -C 'eldora-lab5-ephemeral' -f labkey
[ -f vm-a.qcow2 ] || qemu-img create -q -f qcow2 -F qcow2 -b base44.qcow2 vm-a.qcow2 100G
[ -f target-disk.qcow2 ] || qemu-img create -q -f qcow2 target-disk.qcow2 40G
mkdir -p seed-a
printf 'instance-id: eldora-lab5-vm-a\nlocal-hostname: lab5-builder\n' > seed-a/meta-data
{ echo '#cloud-config'; echo 'users:'; echo '  - name: lab'; echo '    sudo: ALL=(ALL) NOPASSWD:ALL'
  echo '    shell: /bin/bash'; echo '    ssh_authorized_keys:'; echo "      - $(cat labkey.pub)"; } > seed-a/user-data
genisoimage -quiet -output seed-a.iso -volid cidata -joliet -rock seed-a/user-data seed-a/meta-data
qemu-system-x86_64 -name lab5-vm-a -enable-kvm -machine q35 -cpu host -smp 4 -m ${MEM_A:-3072} \
  -drive file=vm-a.qcow2,if=virtio,format=qcow2 \
  -drive file=target-disk.qcow2,if=virtio,format=qcow2 \
  -drive file=seed-a.iso,if=virtio,format=raw,readonly=on \
  -netdev user,id=n0,hostfwd=tcp:127.0.0.1:2231-:22,hostfwd=tcp:127.0.0.1:5000-:5000 \
  -device virtio-net-pci,netdev=n0 -display none -serial file:logs/vm-a-serial.log \
  -daemonize -pidfile vm-a.pid
echo "VM-A started, pid $(cat vm-a.pid)"
