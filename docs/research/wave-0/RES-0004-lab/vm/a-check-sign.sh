#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-A: inspect RPM signatures (rpm 6) and re-sign with visible output if needed.
cd ~/lab; export GNUPGHOME=$HOME/lab/gnupg
echo "--- rpm -Kv signedA (before re-sign)"; rpm -Kv rpms/signedA/eldora-lab-config-1-1.noarch.rpm 2>&1 | head -6
echo "--- rpmsign with output"
rpmsign --define "_openpgp_sign_id lab-A@invalid" --addsign rpms/signedA/eldora-lab-config-1-1.noarch.rpm 2>&1 | tail -3
echo "--- rpm -Kv signedA (after)"; rpm -Kv rpms/signedA/eldora-lab-config-1-1.noarch.rpm 2>&1 | head -6
rpm --eval '%{?_openpgp_sign}|%{?__gpg}|%{?_openpgp_sign_id}'
