#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-A: build revision images and move the lab ":channel" tag (simulated upstream publication).
# Usage: a-channel.sh build <rev>        -> builds eldora-desk:44-r<rev> (LAB_VER 2, REV rev), signed, pushed
#        a-channel.sh point <tag>        -> points :channel at <tag> (signature attachments follow the digest)
set -uo pipefail
cd ~/lab; R=labregistry:5000/eldora-desk
case "$1" in
  build) REV="$2" bash ./a-build-desk.sh quay.io/fedora/fedora-silverblue:44 "44-r$2" 2 2>&1 | grep -E 'seconds|digest' ;;
  point) skopeo copy -q --src-tls-verify=false --dest-tls-verify=false --remove-signatures "docker://$R:$2" "docker://$R:channel"
         echo "channel -> $2 ($(skopeo inspect --tls-verify=false docker://$R:channel --format '{{.Digest}}'))" ;;
esac
