#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-B: group-membership test for a /usr/lib/group group, then stage update to lab image v2 (tag switch).
set -uo pipefail
echo "--- usermod -aG for a group defined only in /usr/lib/group"
G=$(awk -F: '$1=="wheel"||$1=="adm"{print $1; exit}' /usr/lib/group); grep -H "^$G:" /etc/group /usr/lib/group
usermod -aG "$G" labuser; echo "usermod -aG $G exit=$?"; id labuser; grep -H "^$G:" /etc/group /usr/lib/group
echo "--- bootc upgrade --check on v1 tag (install digest differs from registry digest)"; bootc upgrade --check 2>&1 | tail -3
echo "--- bootc switch to v2 (default policy)"; time bootc switch labregistry:5000/eldora-lab:v2 2>&1 | tail -4
bootc status --format=humanreadable 2>&1 | grep -E 'Staged|Booted|Rollback|Digest|Version'
