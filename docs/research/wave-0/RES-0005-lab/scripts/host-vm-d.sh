#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# Host side: detach the installed target disk from VM-A, restart VM-A, and start VM-D (UEFI + Secure Boot,
# Microsoft certificates enrolled; firmware read-only from /usr/share/edk2/ovmf, NVRAM template COPIED into $L).
set -euo pipefail
L=/home/yuri/.claude/jobs/95dfae05/tmp/lab5; D=$(cd "$(dirname "$0")" && pwd); cd "$L"
if [ ! -f vm-d.qcow2 ]; then
  bash "$D/labssh.sh" a lab 'sudo systemctl poweroff' || true
  for i in $(seq 1 60); do [ -f vm-a.pid ] && kill -0 "$(cat vm-a.pid)" 2>/dev/null || break; sleep 2; done
  mv target-disk.qcow2 vm-d.qcow2
  bash "$D/host-vm-a.sh"
fi
# memory-constrained E4 phase: VM-A is started separately by the caller (MEM_A) when vm-d.qcow2 already exists
[ -f vm-d-vars.fd ] || cp /usr/share/edk2/ovmf/OVMF_VARS.secboot.fd vm-d-vars.fd
qemu-system-x86_64 -name lab5-vm-d -enable-kvm -machine q35,smm=on -cpu host -smp 4 -m ${MEM_D:-4096} \
  -global driver=cfi.pflash01,property=secure,value=on \
  -drive if=pflash,format=raw,unit=0,readonly=on,file=/usr/share/edk2/ovmf/OVMF_CODE.secboot.fd \
  -drive if=pflash,format=raw,unit=1,file=vm-d-vars.fd \
  -drive file=vm-d.qcow2,if=virtio,format=qcow2 \
  -netdev user,id=n0,hostfwd=tcp:127.0.0.1:2232-:22 -device virtio-net-pci,netdev=n0 \
  -device virtio-vga -audiodev none,id=snd0 -device intel-hda -device hda-duplex,audiodev=snd0 \
  -display none -monitor unix:vm-d.mon,server,nowait -serial file:logs/vm-d-serial.log \
  -daemonize -pidfile vm-d.pid
echo "VM-D started (UEFI SB), pid $(cat vm-d.pid)"
