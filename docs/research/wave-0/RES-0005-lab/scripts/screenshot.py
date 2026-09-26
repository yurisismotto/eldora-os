#!/usr/bin/env python3
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# Usage: screenshot.py <label>   Takes a PNG screendump of VM-D through its HMP monitor socket (evidence only).
import socket, sys, time, os
L = "/home/yuri/.claude/jobs/95dfae05/tmp/lab5"
out = f"{L}/shots/{sys.argv[1]}.png"
os.makedirs(f"{L}/shots", exist_ok=True)
s = socket.socket(socket.AF_UNIX); s.connect(f"{L}/vm-d.mon"); time.sleep(0.3); s.recv(65536)
s.sendall(f"screendump {out} -f png\n".encode()); time.sleep(1.5); s.close()
print(out if os.path.exists(out) else "screendump FAILED")
