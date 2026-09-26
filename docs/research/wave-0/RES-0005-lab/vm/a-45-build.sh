#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-A E4 step 2: build eldora-desk:45-v2 changing ONLY the base image reference (same Containerfile, same lab RPM v2).
cd ~/lab && REV=45 bash ./a-build-desk.sh quay.io/fedora/fedora-silverblue:45 45-v2 2 2>&1 | grep -vE '^\s*$' | tail -12
df -h / | tail -1
