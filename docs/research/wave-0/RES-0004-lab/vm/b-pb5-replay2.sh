#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-B PB5 T7b (repeat): exact identity rule; stage :v2 first so that :latest is a real change.
set -uo pipefail
R=labregistry:5000/eldora-lab
try() { echo "--- $1"; shift; out=$(bootc switch "$@" 2>&1); rc=$?; echo "$out" | tail -2; [ $rc -eq 0 ] && echo "RESULT: ACCEPTED (staged)" || echo "RESULT: REJECTED (rc=$rc)"; }
python3 - <<'EOF'
import json
p="/etc/containers/policy.json"; d=json.load(open(p))
for v in d["transports"]["docker"].values(): v[0].pop("signedIdentity",None)
json.dump(d,open(p,"w"),indent=1)
EOF
echo "=== signedIdentity: default (matchRepoDigestOrExact)"
try "T7b-pre stage :v2" $R:v2
try "T7b old v1 content under tag :latest" $R:latest
try "T6b-exact moving tag :track (content v1, signed as :v1)" $R:track
python3 - <<'EOF'
import json
p="/etc/containers/policy.json"; d=json.load(open(p))
for v in d["transports"]["docker"].values(): v[0]["signedIdentity"]={"type":"matchRepository"}
json.dump(d,open(p,"w"),indent=1)
EOF
echo "=== signedIdentity: matchRepository (restored)"
try "T6b-setup stage moving tag :track" $R:track
