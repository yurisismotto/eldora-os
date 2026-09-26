#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-B PB5: update trust chain tests using `bootc switch` (staging only; results = accepted/rejected).
set -uo pipefail
R=labregistry:5000/eldora-lab
echo "--- post-switch check: layered htop discarded?"; command -v htop || echo "htop: absent (layering discarded by bootc switch)"; rpm-ostree status 2>&1 | grep -c LayeredPackages | sed 's/^/LayeredPackages lines: /'
try() { echo "--- $1"; shift; out=$(bootc switch "$@" 2>&1); rc=$?; echo "$out" | tail -2; [ $rc -eq 0 ] && echo "RESULT: ACCEPTED (staged)" || echo "RESULT: REJECTED (rc=$rc)"; }
echo "=== default policy: $(python3 -c 'import json;print(json.load(open("/etc/containers/policy.json"))["default"])')"
try "T1 default policy, UNSIGNED image v2u" $R:v2u
try "T5 default policy + --enforce-container-sigpolicy, signed image v2" --enforce-container-sigpolicy $R:v2
cp /etc/containers/policy.json /root/policy.json.orig
mkdir -p /etc/pki/lab
cat > /etc/containers/policy.json <<'EOF'
{
  "default": [{"type": "reject"}],
  "transports": {
    "docker": {
      "labregistry:5000/eldora-lab": [{"type": "sigstoreSigned", "keyPath": "/etc/pki/lab/sigA.pub", "signedIdentity": {"type": "matchRepository"}}],
      "labregistry:5000/eldora-lab-plain": [{"type": "sigstoreSigned", "keyPath": "/etc/pki/lab/sigA.pub", "signedIdentity": {"type": "matchRepository"}}]
    },
    "containers-storage": {"": [{"type": "insecureAcceptAnything"}]},
    "docker-daemon": {"": [{"type": "reject"}]}
  }
}
EOF
echo "=== enforced sigstore policy (trusted key A only)"
try "T2 signed with trusted key A (v2)" $R:v2
try "T3 UNSIGNED (v2u)" $R:v2u
try "T4 signed with UNTRUSTED key B (v2b)" $R:v2b
try "T2b signed A + --enforce-container-sigpolicy (v1)" --enforce-container-sigpolicy $R:v1
echo "=== T6 digest pinning"
V1D=$(skopeo inspect --tls-verify=false docker://$R:v1 --format '{{.Digest}}'); echo "v1 digest=$V1D"
try "T6a switch to digest reference" "$R@$V1D"
echo "--- bootc upgrade --check with digest-pinned reference"; bootc upgrade --check 2>&1 | tail -2
bootc status --format=humanreadable 2>&1 | grep -E 'Staged image|Booted image' | head -2
