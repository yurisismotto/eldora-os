#!/usr/bin/env python3
# RESEARCH ONLY - NOT PRODUCTION - NOT ELDORA IMPLEMENTATION
# Fetch primary documentation and print passages relevant to the UEFI /boot automount finding (documentary check).
import re, urllib.request
def get(u):
    r = urllib.request.Request(u, headers={"User-Agent": "curl/8.0"})
    html = urllib.request.urlopen(r, timeout=40).read().decode("utf-8", "ignore")
    return re.sub(r"\s+", " ", re.sub(r"<[^>]+>", " ", html))
docs = {
    "systemd-gpt-auto-generator(8)": ("https://www.freedesktop.org/software/systemd/man/latest/systemd-gpt-auto-generator.html",
                                      ["/boot/", "automount", "systemd.gpt_auto", "LoaderDevicePartUUID", "fstab"]),
    "bootc book": ("https://bootc.dev/bootc/print.html", ["gpt-auto", "gpt_auto", "automount", "/boot/efi"]),
    "ostree deployments": ("https://ostreedev.github.io/ostree/deployment/", ["/boot"]),
}
for name, (url, keys) in docs.items():
    s = get(url); print(f"== {name} ({len(s)} chars) {url}")
    for k in keys:
        idx = [m.start() for m in re.finditer(re.escape(k), s)][:2]
        if not idx: print(f"  NOT FOUND: {k}")
        for i in idx: print(f"  [{k}] ...{s[max(0, i-150):i+260]}...")
