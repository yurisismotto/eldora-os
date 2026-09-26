# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# Laboratory package for RES-0004 probes. Build with: rpmbuild -bb --define "lab_ver 1" (or 2)
%{!?lab_ver:%global lab_ver 1}
Name:           eldora-lab-config
Version:        %{lab_ver}
Release:        1
Summary:        RESEARCH ONLY laboratory package for RES-0004 probes
License:        LicenseRef-Not-Licensed-Research-Only
BuildArch:      noarch
%{?systemd_requires}

%description
RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION.
Configuration, sysusers and state-writing service used to observe
/etc, users/groups and /var behaviour across updates.

%install
mkdir -p %{buildroot}/etc/eldora-lab/conf.d %{buildroot}/usr/lib/eldora-lab \
         %{buildroot}/usr/lib/sysusers.d %{buildroot}/usr/lib/systemd/system \
         %{buildroot}/usr/lib/systemd/system-preset %{buildroot}/usr/bin
echo "value=%{lab_ver}" > %{buildroot}/etc/eldora-lab/unmodified.conf
echo "value=%{lab_ver}" > %{buildroot}/etc/eldora-lab/modified.conf
%if %{lab_ver} >= 2
echo "value=%{lab_ver}" > %{buildroot}/etc/eldora-lab/new-in-v2.conf
%endif
printf 'color=blue\nlevel=%s\n' %{lab_ver} > %{buildroot}/usr/lib/eldora-lab/defaults.conf
cat > %{buildroot}/usr/bin/eldora-lab-effective <<'EOS'
#!/bin/sh
# RESEARCH ONLY: vendor defaults in /usr, overridden by /etc drop-ins (last wins)
cat /usr/lib/eldora-lab/defaults.conf /etc/eldora-lab/conf.d/*.conf 2>/dev/null | awk -F= '{v[$1]=$2} END{for(k in v) print k"="v[k]}' | sort
EOS
chmod 0755 %{buildroot}/usr/bin/eldora-lab-effective
cat > %{buildroot}/usr/lib/sysusers.d/eldora-lab.conf <<'EOS'
u eldoralab - "Eldora lab service (RESEARCH ONLY)" /var/lib/eldora-lab
EOS
%if %{lab_ver} >= 2
cat >> %{buildroot}/usr/lib/sysusers.d/eldora-lab.conf <<'EOS'
u eldoralab2 - "Eldora lab v2 user (RESEARCH ONLY)"
g eldoralabextra -
EOS
%endif
cat > %{buildroot}/usr/lib/systemd/system/eldora-lab.service <<EOS
[Unit]
Description=RESEARCH ONLY eldora-lab state writer (schema %{lab_ver})
[Service]
Type=oneshot
RemainAfterExit=yes
User=eldoralab
StateDirectory=eldora-lab
ExecStart=/bin/sh -c 'echo "schema=%{lab_ver} boot=\$\$(cat /proc/sys/kernel/random/boot_id)" >> /var/lib/eldora-lab/state.log'
[Install]
WantedBy=multi-user.target
EOS
echo "enable eldora-lab.service" > %{buildroot}/usr/lib/systemd/system-preset/80-eldora-lab.preset

%post
%systemd_post eldora-lab.service

%files
%dir /etc/eldora-lab
%dir /etc/eldora-lab/conf.d
%config(noreplace) /etc/eldora-lab/unmodified.conf
%config(noreplace) /etc/eldora-lab/modified.conf
%if %{lab_ver} >= 2
%config(noreplace) /etc/eldora-lab/new-in-v2.conf
%endif
/usr/lib/eldora-lab/defaults.conf
/usr/bin/eldora-lab-effective
/usr/lib/sysusers.d/eldora-lab.conf
/usr/lib/systemd/system/eldora-lab.service
/usr/lib/systemd/system-preset/80-eldora-lab.preset
