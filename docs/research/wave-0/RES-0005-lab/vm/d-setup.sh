#!/bin/bash
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# VM-D: client config (lab registry, ENFORCED trust policy), test user with GDM autologin, user marker. Machine/user state only.
set -uo pipefail
grep -q labregistry /etc/hosts || echo "10.0.2.2 labregistry" >> /etc/hosts
mkdir -p /etc/containers/registries.conf.d /etc/containers/registries.d /etc/pki/lab
printf '[[registry]]\nlocation = "labregistry:5000"\ninsecure = true\n' > /etc/containers/registries.conf.d/50-labregistry.conf
printf 'docker:\n  labregistry:5000:\n    use-sigstore-attachments: true\n' > /etc/containers/registries.d/50-labregistry.yaml
cp /etc/containers/policy.json /root/policy.json.orig
cat > /etc/containers/policy.json <<'EOF'
{
  "default": [{"type": "reject"}],
  "transports": {
    "docker": {
      "labregistry:5000/eldora-desk": [{"type": "sigstoreSigned", "keyPath": "/etc/pki/lab/sigA.pub", "signedIdentity": {"type": "matchRepository"}}]
    },
    "containers-storage": {"": [{"type": "insecureAcceptAnything"}]}
  }
}
EOF
useradd -m -c "Lab desktop user" labuser && echo 'labuser:lab-only-pass' | chpasswd
mkdir -p /home/labuser/.config && touch /home/labuser/.config/gnome-initial-setup-done
echo "user data" > /home/labuser/marker.txt; chown -R labuser:labuser /home/labuser
mkdir -p /etc/gdm && printf '[daemon]\nAutomaticLoginEnable=True\nAutomaticLogin=labuser\n' > /etc/gdm/custom.conf
systemctl is-enabled bootc-fetch-apply-updates.timer 2>&1 | sed 's/^/auto-update timer: /'
