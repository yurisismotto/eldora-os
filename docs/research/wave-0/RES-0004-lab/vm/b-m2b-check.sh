#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-B: M2b check — does rpm-ostree layering block bootc upgrade/switch? Then remove the layering.
set -uo pipefail
command -v htop && echo "htop persistent after reboot"
rpm-ostree status 2>&1 | grep -E '●|LayeredPackages' | head -3
echo "--- bootc upgrade --check"; bootc upgrade --check 2>&1 | tail -3
echo "--- bootc upgrade"; bootc upgrade 2>&1 | tail -3
echo "--- bootc switch (to same v2 tag)"; bootc switch labregistry:5000/eldora-lab:v2 2>&1 | tail -3
echo "--- rpm-ostree upgrade (rpm-ostree still manages it)"; rpm-ostree upgrade --check 2>&1 | tail -3
echo "--- revert: rpm-ostree uninstall htop"; rpm-ostree uninstall htop 2>&1 | tail -2
