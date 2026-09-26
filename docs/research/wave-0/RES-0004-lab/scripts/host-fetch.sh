#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# Host side: download and verify the Fedora Cloud 44 base image into $L (no host changes).
set -euo pipefail
L=/home/yuri/.claude/jobs/95dfae05/tmp/lab
mkdir -p "$L/gnupg" "$L/logs"; chmod 700 "$L/gnupg"; cd "$L"
B=https://dl.fedoraproject.org/pub/fedora/linux/releases/44/Cloud/x86_64/images
curl -sSfL -o CHECKSUM "$B/Fedora-Cloud-44-1.7-x86_64-CHECKSUM"
curl -sSfL -o fedora.gpg https://fedoraproject.org/fedora.gpg
export GNUPGHOME="$L/gnupg"
gpg -q --import fedora.gpg 2>/dev/null || true
gpg --verify CHECKSUM 2>&1 | grep -E "Good signature|BAD signature|using" || true
[ -f base44.qcow2 ] || curl -sSfL -o base44.qcow2 "$B/Fedora-Cloud-Base-Generic-44-1.7.x86_64.qcow2"
echo "expected: $(grep 'Generic-44-1.7.x86_64.qcow2)' CHECKSUM | awk '{print $NF}')"
echo "actual:   $(sha256sum base44.qcow2 | cut -d' ' -f1)"
ls -l base44.qcow2
