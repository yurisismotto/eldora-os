#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-A: build lab RPMs v1/v2, create ephemeral lab GPG keys, produce signed/unsigned variants and a local repo.
set -euo pipefail
cd ~/lab
for v in 1 2; do rpmbuild -bb --define "lab_ver $v" --define "_topdir $HOME/lab/rpmbuild" eldora-lab-config.spec >/dev/null 2>&1; done
mkdir -p rpms/unsigned rpms/signedA rpms/signedB repo-signedA
cp rpmbuild/RPMS/noarch/eldora-lab-config-*.rpm rpms/unsigned/
ls rpms/unsigned
# Ephemeral lab keys (never leave the VM): A = "trusted", B = "untrusted"
export GNUPGHOME=$HOME/lab/gnupg; mkdir -p "$GNUPGHOME"; chmod 700 "$GNUPGHOME"
for k in A B; do
  gpg --batch --quiet --passphrase '' --quick-gen-key "Eldora LAB key $k (RESEARCH ONLY, ephemeral) <lab-$k@invalid>" ed25519 sign never
done
gpg --list-keys --with-colons | awk -F: '/^uid/{print "key uid: "$10}'
for k in A B; do
  cp rpms/unsigned/*.rpm "rpms/signed$k/"
  rpmsign --define "_openpgp_sign_id lab-$k@invalid" --define "_gpg_name lab-$k@invalid" --addsign rpms/signed$k/*.rpm >/dev/null 2>&1
  gpg --armor --export "lab-$k@invalid" > "rpms/LAB-KEY-$k.asc"
done
for k in A B; do printf 'signed%s: ' $k; rpm -qp --qf '%{name}-%{version} sig=%{SIGPGP:pgpsig}%{RSAHEADER:pgpsig}\n' rpms/signed$k/eldora-lab-config-1-1.noarch.rpm 2>/dev/null | head -1; done
printf 'unsigned: '; rpm -qp --qf '%{name}-%{version} sig=%{SIGPGP:pgpsig}%{RSAHEADER:pgpsig}\n' rpms/unsigned/eldora-lab-config-1-1.noarch.rpm 2>/dev/null | head -1
cp rpms/signedA/*.rpm repo-signedA/ && createrepo_c -q repo-signedA && echo "repo-signedA created"
