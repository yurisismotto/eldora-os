#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-D: retry toolbox with the user's session environment (as a real session would have).
U=$(id -u labuser)
E="XDG_RUNTIME_DIR=/run/user/$U DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$U/bus"
sudo -iu labuser env $E toolbox --verbose create -y 2>&1 | grep -iE 'error|created|level=error' | tail -4; echo "exit=${PIPESTATUS[0]}"
sudo -iu labuser env $E toolbox run sh -c 'grep PRETTY /etc/os-release; sudo dnf -y -q install strace >/dev/null 2>&1; strace -V | head -1' 2>&1 | tail -2
