# uprightlab — Shutdown & Startup Procedure

Steps to fully power the lab down and bring it back up — e.g. for relocation or extended downtime. Order matters: shut down consumers before providers; start providers before consumers.

## Relocation note

The Eero and its `192.168.4.0/22` network move with the lab. The lab only ever peers with VLAN 4 / `192.168.4.0/22` and has no knowledge of anything upstream of the Eero, so **no lab network reconfiguration is required on power-up**. The only task at a new location is to give the Eero a working internet uplink (modem/ISP). Everything downstream — bandee's uplink, rick, waddle's wifi, coo's WAN — comes back unchanged, provided the Eero keeps its config (SSID, DHCP reservations, including coo's 192.168.4.253).

## Shutdown

1. **Capture state first** — commit and push everything; confirm `git status` is clean.
2. **Shut down meta** — `sudo shutdown -h now`.
3. **Shut down the Proxmox nodes** (dede, when re-added) — UI *Shutdown* or `sudo shutdown -h now`. Before rick, so the `rick-nfs` mount unmounts cleanly.
4. **Shut down waddle** — `sudo shutdown -h now` (stops Pi-hole / Semaphore / cloudflared cleanly; data persists on volumes).
5. **Shut down rick** — QNAP UI *Shutdown* (parks the HDDs for transit).
6. **Power off bandee** — SSH in (`ssh chris@192.168.4.254`), `copy running-config startup-config`, then pull power. (No graceful shutdown; saved config is enough.)
7. **Power off coo** — its config is saved by the coo playbook, so it can be powered off last.

## Startup

0. **Eero** — power on and confirm it has internet (needed for waddle's wifi, NTP upstream, and the Cloudflare tunnel).
1. **bandee and coo** — power on first (network fabric and the lab's internet). Both boot from their saved config; no action needed.
2. **rick** — power on (storage available before the nodes mount it).
3. **waddle** — power on. Confirm it has internet; provides DNS, DHCP, NTP, Semaphore.
4. **Proxmox nodes** (dede, when re-added) — power on; they mount `rick-nfs`.
5. **meta** — power on.

## Post-startup checks

- DNS resolves (`ping waddle.lab.uprightlab.com` via Pi-hole).
- Nodes reachable on VLAN 10; `rick-nfs` shows `active` in `pvesm status`.
- NTP synced (`chronyc sources` on nodes / `timedatectl` on meta point at waddle).
- Lab internet via coo: `ping 1.1.1.1` from bandee succeeds.
- waddle has internet; Cloudflare tunnel healthy in the dashboard (WARP access restored).