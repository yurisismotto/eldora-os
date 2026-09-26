#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-D: after channel moved to an UNSIGNED image, does rpm-ostree (origin ostree-unverified-registry) accept it? Compare bootc.
set -uo pipefail
cat /usr/lib/eldora-lab/revision; command -v strace
python3 -c 'import json;d=json.load(open("/etc/containers/policy.json"));print("policy default:",d["default"])'
echo "--- rpm-ostree upgrade to unsigned channel content"; rpm-ostree upgrade 2>&1 | tail -3; echo "exit=$?"
rpm-ostree status 2>&1 | grep -E '●|Version' | head -3
echo "--- bootc (same policy) against unsigned image, for comparison"; bootc switch --apply=false labregistry:5000/eldora-desk:44-r6u 2>&1 | tail -1
