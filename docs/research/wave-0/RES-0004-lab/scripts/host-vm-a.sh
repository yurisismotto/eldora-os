#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# Host side: create and start VM-A (LAB-M1 + builder). Writes only under $L.
set -euo pipefail
L=/home/yuri/.claude/jobs/95dfae05/tmp/lab
cd "$L"
[ -f labkey ] || ssh-keygen -q -t ed25519 -N '' -C 'eldora-lab-ephemeral' -f labkey
[ -f vm-a.qcow2 ] || qemu-img create -q -f qcow2 -F qcow2 -b base44.qcow2 vm-a.qcow2 60G
[ -f m3-disk.qcow2 ] || qemu-img create -q -f qcow2 m3-disk.qcow2 20G
mkdir -p seed-a
printf 'instance-id: eldora-lab-vm-a\nlocal-hostname: lab-m1\n' > seed-a/meta-data
{
  echo '#cloud-config'
  echo 'users:'
  echo '  - name: lab'
  echo '    sudo: ALL=(ALL) NOPASSWD:ALL'
  echo '    shell: /bin/bash'
  echo '    ssh_authorized_keys:'
  echo "      - $(cat labkey.pub)"
} > seed-a/user-data
genisoimage -quiet -output seed-a.iso -volid cidata -joliet -rock seed-a/user-data seed-a/meta-data
qemu-system-x86_64 -name vm-a -enable-kvm -machine q35 -cpu host -smp 4 -m 5120 \
  -drive file=vm-a.qcow2,if=virtio,format=qcow2 \
  -drive file=m3-disk.qcow2,if=virtio,format=qcow2 \
  -drive file=seed-a.iso,if=virtio,format=raw,readonly=on \
  -netdev user,id=n0,hostfwd=tcp:127.0.0.1:2221-:22,hostfwd=tcp:127.0.0.1:5000-:5000 \
  -device virtio-net-pci,netdev=n0 -display none -serial file:logs/vm-a-serial.log \
  -daemonize -pidfile vm-a.pid
echo "VM-A started, pid $(cat vm-a.pid)"
