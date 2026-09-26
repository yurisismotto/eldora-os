#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-D E5: create local ID conflicts, then stage signed 44-v2 (enforced policy). Reboot is done from the host.
set -uo pipefail
useradd -u 851 -m localdev && echo "local user localdev created with UID 851 (collides with v2 fixed UID for eldoralab2)"
groupadd -g 1500 eldoralabextra && echo "local group eldoralabextra created with GID 1500 (v2 wants GID 852)"
mkdir -p /var/lib/localdev-data && echo data > /var/lib/localdev-data/file && chown localdev: /var/lib/localdev-data/file
S=$(date +%s); bootc switch labregistry:5000/eldora-desk:44-v2 2>&1 | tail -3; echo "stage seconds=$(( $(date +%s)-S ))"
