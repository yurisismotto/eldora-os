#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-D E2 (d): does the local derived image follow upstream? Plain check, then documented rebuild + upgrade.
set -uo pipefail
echo "--- step 0: plain bootc upgrade --check after upstream moved"; bootc upgrade --check 2>&1 | tail -1
echo "--- step 1: rebuild local image with --pull=always"; S=$(date +%s)
podman build -q --pull=always -t localhost/eldora-local:latest -f /etc/eldora-lab-local/Containerfile /etc/eldora-lab-local 2>&1 | tail -1; echo "rebuild seconds=$(( $(date +%s)-S ))"
echo "--- step 2: bootc upgrade"; S=$(date +%s); bootc upgrade 2>&1 | tail -3; echo "upgrade seconds=$(( $(date +%s)-S ))"
bootc status --format=humanreadable 2>/dev/null | grep -E 'Staged image|Booted image' | head -2
echo "--- podman storage used by local builds"; podman system df 2>/dev/null | head -3
