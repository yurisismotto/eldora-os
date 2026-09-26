#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-A (lab registry): simulate registry-side changes WITHOUT any signing key:
#  T6b: create tag "track" -> v1 content, later moved to v2 content (tag movement)
#  T7 : create tag "latest" -> OLD v1 content (re-pointing a tag to an older, validly signed image)
set -euo pipefail
R=labregistry:5000/eldora-lab
cp() { skopeo copy -q --src-tls-verify=false --dest-tls-verify=false --remove-signatures "docker://$R:$1" "docker://$R:$2"; echo "tag $2 -> content of $1 ($(skopeo inspect --tls-verify=false docker://$R:$2 --format '{{.Digest}}'))"; }
case "${1:-}" in
  init) cp v1 track; cp v1 latest ;;
  move) cp v2 track ;;
  *) echo "usage: init|move"; exit 2 ;;
esac
