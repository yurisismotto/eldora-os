#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-A: build revision r5 and move ":channel" to it (next simulated upstream publication).
cd ~/lab && bash a-channel.sh build 5 && bash a-channel.sh point 44-r5
