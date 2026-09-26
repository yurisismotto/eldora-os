#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-B PB4: stage replacement by a different image (plain fedora-bootc:44, no lab package), signed with key A.
set -uo pipefail
bootc switch labregistry:5000/eldora-lab-plain:44 2>&1 | tail -2
bootc status --format=humanreadable 2>&1 | grep -E 'Staged image|Booted image'
