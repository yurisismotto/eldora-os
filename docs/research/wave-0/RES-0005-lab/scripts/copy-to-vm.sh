#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# Usage: copy-to-vm.sh <a|d> <user> <local-file> <remote-path>
D=$(cd "$(dirname "$0")" && pwd)
bash "$D/labssh.sh" "$1" "$2" "mkdir -p \"\$(dirname '$4')\" && cat > '$4'" < "$3" && echo "copied $(basename "$3") -> vm-$1:$4"
