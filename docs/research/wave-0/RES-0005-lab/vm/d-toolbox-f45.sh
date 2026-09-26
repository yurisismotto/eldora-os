#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-D on F45: diagnose the toolbox failure (read-mostly; no rebuild).
U=$(id -u labuser); E="XDG_RUNTIME_DIR=/run/user/$U DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$U/bus"
rpm -q toolbox podman
sudo -iu labuser env $E toolbox list 2>&1 | tail -4
sudo -iu labuser env $E toolbox run --container fedora-toolbox-44 sh -c 'grep VERSION_ID /etc/os-release; strace -V | head -1' 2>&1 | tail -3; echo "exit=${PIPESTATUS[0]}"
