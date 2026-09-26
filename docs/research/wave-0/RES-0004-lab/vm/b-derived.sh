#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-B PB2 O1: persistent CLI tool via a LOCAL derived image (documented bootc escape hatch).
set -uo pipefail
bootc status --format=humanreadable 2>&1 | grep -E 'Booted image|Version' | head -2
mkdir -p /root/local-derive && cd /root/local-derive
printf 'FROM labregistry:5000/eldora-lab:v2\nRUN dnf -y -q install strace && dnf clean all\nRUN bootc container lint\n' > Containerfile
echo "--- step 1: build local derived image"; S=$(date +%s)
podman build -q -t localhost/eldora-local:v2-strace . 2>&1 | tail -2; echo "build seconds=$(( $(date +%s)-S ))"
echo "--- step 2: switch to local image"; bootc switch --transport containers-storage localhost/eldora-local:v2-strace 2>&1 | tail -3
bootc status --format=humanreadable 2>&1 | grep -E 'Staged image|Booted image|Version'
