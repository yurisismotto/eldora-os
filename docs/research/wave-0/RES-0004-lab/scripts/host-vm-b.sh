#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# Host side: detach the installed disk from VM-A, restart VM-A (registry), start VM-B (LAB-M3). Writes only under $L.
set -euo pipefail
L=/home/yuri/.claude/jobs/95dfae05/tmp/lab; D=$(cd "$(dirname "$0")" && pwd); cd "$L"
if [ ! -f vm-b.qcow2 ]; then
  bash "$D/labssh.sh" a lab 'sudo systemctl poweroff' || true
  for i in $(seq 1 60); do kill -0 "$(cat vm-a.pid)" 2>/dev/null || break; sleep 2; done
  mv m3-disk.qcow2 vm-b.qcow2
  bash "$D/host-vm-a.sh"
fi
qemu-system-x86_64 -name vm-b -enable-kvm -machine q35 -cpu host -smp 4 -m 4096 \
  -drive file=vm-b.qcow2,if=virtio,format=qcow2 \
  -netdev user,id=n0,hostfwd=tcp:127.0.0.1:2222-:22 \
  -device virtio-net-pci,netdev=n0 -display none -serial file:logs/vm-b-serial.log \
  -daemonize -pidfile vm-b.pid
echo "VM-B started, pid $(cat vm-b.pid)"
