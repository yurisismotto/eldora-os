#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-D E2: (e) toolbox via a proper login shell under the enforced policy; (c) M2b setup: registry channel + rpm-ostree layering.
set -uo pipefail
echo "=== (e) toolbox as labuser (login shell)"
sudo -iu labuser podman version --format '{{.Client.Version}}' 2>&1 | tail -1
S=$(date +%s); sudo -iu labuser toolbox create -y 2>&1 | tail -3; echo "toolbox create exit=$? seconds=$(( $(date +%s)-S ))"
echo "=== (c) M2b: switch to registry channel, then rpm-ostree layering"
bootc switch labregistry:5000/eldora-desk:channel 2>&1 | tail -2
S=$(date +%s); rpm-ostree install -y strace 2>&1 | tail -3; echo "rpm-ostree install seconds=$(( $(date +%s)-S ))"
rpm-ostree status 2>&1 | grep -E '●|LayeredPackages|Version' | head -6
