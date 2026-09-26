#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-B PB5 T6b: tag-tracking vs digest-pinned reference after the registry tag moved.
set -uo pipefail
R=labregistry:5000/eldora-lab
bootc status --format=humanreadable 2>&1 | grep -E 'Booted image|Digest' | head -2
echo "--- tag-tracking reference (:track moved v1 -> v2)"; bootc upgrade --check 2>&1 | tail -3
echo "--- digest-pinned reference"; bootc switch "$R@sha256:3b32234cdb9892885955d86dc42fc124d5a03714352ea6c8dec174781be0d16f" 2>&1 | tail -1
bootc upgrade --check 2>&1 | tail -2
echo "--- restore tag-tracking reference for later tests"; bootc switch $R:v2 2>&1 | tail -1
