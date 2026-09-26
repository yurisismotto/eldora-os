#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-D: (e) toolbox with an explicit policy entry for the Fedora toolbox registry; then remove M2b layering.
set -uo pipefail
python3 - <<'EOF'
import json
p="/etc/containers/policy.json"; d=json.load(open(p))
# LAB: explicit (weaker) trust entry for the Fedora toolbox image; Fedora publishes no signature observed in RES-0001/0004.
d["transports"]["docker"]["registry.fedoraproject.org/fedora-toolbox"]=[{"type":"insecureAcceptAnything"}]
json.dump(d,open(p,"w"),indent=1)
EOF
S=$(date +%s); sudo -iu labuser toolbox create -y 2>&1 | tail -2; echo "toolbox create exit=$? seconds=$(( $(date +%s)-S ))"
sudo -iu labuser toolbox run sh -c 'grep PRETTY /etc/os-release; sudo dnf -y -q install strace >/dev/null 2>&1; strace -V | head -1' 2>&1 | tail -2
echo "--- remove M2b layering (return to bootc path)"; rpm-ostree reset 2>&1 | tail -1; bootc upgrade --check 2>&1 | tail -1
