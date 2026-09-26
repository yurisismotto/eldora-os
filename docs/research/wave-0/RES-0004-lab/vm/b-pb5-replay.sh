#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-B PB5 T7: old validly-signed image served under a different tag, under two signedIdentity rules.
set -uo pipefail
R=labregistry:5000/eldora-lab
try() { echo "--- $1"; shift; out=$(bootc switch "$@" 2>&1); rc=$?; echo "$out" | tail -2; [ $rc -eq 0 ] && echo "RESULT: ACCEPTED (staged)" || echo "RESULT: REJECTED (rc=$rc)"; }
setid() { python3 - "$1" <<'EOF'
import json,sys
p="/etc/containers/policy.json"; d=json.load(open(p))
for k,v in d["transports"]["docker"].items():
    if sys.argv[1]=="exact": v[0].pop("signedIdentity",None)
    else: v[0]["signedIdentity"]={"type":"matchRepository"}
json.dump(d,open(p,"w"),indent=1)
EOF
echo "=== signedIdentity: $1"; }
setid matchRepository
try "T7a old v1 content under tag :latest (matchRepository)" $R:latest
setid exact
try "T7b old v1 content under tag :latest (default matchRepoDigestOrExact)" $R:latest
try "T7c original tag :v1 (default matchRepoDigestOrExact)" $R:v1
try "T7d v1 by digest (default matchRepoDigestOrExact)" $R@sha256:3b32234cdb9892885955d86dc42fc124d5a03714352ea6c8dec174781be0d16f
setid matchRepository
try "T6b-setup switch to moving tag :track (matchRepository)" $R:track
