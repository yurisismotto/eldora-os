#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-A: build revision r6 and push it UNSIGNED, then move ":channel" to it (trust test for the rpm-ostree client path).
set -uo pipefail
cd ~/lab; R=labregistry:5000/eldora-desk
sudo podman build -q --build-arg BASE=quay.io/fedora/fedora-silverblue:44 --build-arg LAB_VER=2 --build-arg REV=6 -t $R:44-r6u ctx 2>&1 | tail -1
sudo podman push -q --tls-verify=false $R:44-r6u && echo "pushed 44-r6u UNSIGNED"
bash a-channel.sh point 44-r6u
