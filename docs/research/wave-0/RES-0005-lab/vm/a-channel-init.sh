#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-A: build revision images r3 and r4 and point the lab ":channel" tag at r3.
cd ~/lab && bash a-channel.sh build 3 && bash a-channel.sh build 4 && bash a-channel.sh point 44-r3
