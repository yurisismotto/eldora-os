#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-A (LAB-M1) PB4-symmetric: remove the lab package and observe leftover machine state.
set -uo pipefail
sudo dnf -y remove eldora-lab-config 2>&1 | grep -iE 'rpmsave|warning|Removing' | head -5
echo "--- /etc/eldora-lab after removal"; sudo ls -la /etc/eldora-lab /etc/eldora-lab/conf.d 2>&1 | grep -v '^total'
echo "--- users/groups after removal"; getent passwd eldoralab eldoralab2; getent group eldoralab eldoralabextra
echo "--- /var state after removal"; sudo ls -ln /var/lib/eldora-lab 2>&1
