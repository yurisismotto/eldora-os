#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-D: toolbox policy detail; M2b follow-upstream test (bootc vs rpm-ostree) after channel moved to r5.
set -uo pipefail
echo "=== (e) toolbox pull error detail"; sudo -iu labuser podman pull -q registry.fedoraproject.org/fedora-toolbox:44 2>&1 | tail -2
echo "=== (c) layered deployment booted"; cat /usr/lib/eldora-lab/revision; command -v strace
echo "--- bootc upgrade --check"; bootc upgrade --check 2>&1 | tail -1
echo "--- rpm-ostree upgrade (follows the OCI channel?)"; S=$(date +%s); rpm-ostree upgrade 2>&1 | tail -4; echo "seconds=$(( $(date +%s)-S ))"
rpm-ostree status 2>&1 | grep -E '●|LayeredPackages|Version' | head -4
