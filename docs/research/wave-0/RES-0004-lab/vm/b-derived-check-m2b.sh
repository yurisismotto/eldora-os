#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-B: verify local derived image; what upgrades now track; then narrow M2b check (rpm-ostree layering vs bootc upgrade).
set -uo pipefail
bootc status --format=humanreadable 2>&1 | grep -E 'Booted image|Version' | head -2
command -v strace && strace -V | head -1
echo "--- bootc upgrade --check while tracking the local image"; bootc upgrade --check 2>&1 | tail -3
echo "--- switch back to registry v2 (revert customization)"; bootc switch labregistry:5000/eldora-lab:v2 2>&1 | tail -2
echo "################ M2b narrow check ################"
echo "--- rpm-ostree install htop (client-side layering on bootc host)"; S=$(date +%s)
rpm-ostree install -y htop 2>&1 | tail -4; echo "seconds=$(( $(date +%s)-S ))"
rpm-ostree status 2>&1 | grep -E 'LayeredPackages|Deployments|●|Version' | head -8
