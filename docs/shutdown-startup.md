# uprightlab — Shutdown & Startup Procedure

Steps to fully power the lab down and bring it back up — e.g. for relocation or extended downtime. Order matters: shut down consumers before providers; start providers before consumers.

## Relocation note

The Eero and its `192.168.4.0/22` network move with the lab. The lab only ever peers with VLAN 4 / `192.168.4.0/22` and has no knowledge of anything upstream of the Eero, so **no lab network reconfiguration is required on power-up**. The only task at a new location is to give the Eero a working internet uplink (modem/ISP). Everything downstream — bandee's uplink, rick, waddle's wifi, OPNsense's WAN — comes back unchanged, provided the Eero keeps its config (SSID, DHCP reservations).

## Shutdown

1. **Capture state first**
   - Commit and push everything; confirm `git status` is clean.
   - Back up the OpenTofu state (`tofu/opnsense/terraform.tfstate`) — it's git-ignored and lives only on the workstation.
2. **Stop VMs** — on dede: `qm shutdown 100` (OPNsense). Disks persist; do not destroy.
3. **Shut down meta** — `sudo shutdown -h now`.
4. **Shut down the Proxmox nodes** (kirby, dede) — UI *Shutdown* or `sudo shutdown -h now`. Before rick, so the `rick-nfs` mount unmounts cleanly.
5. **Shut down waddle** — `sudo shutdown -h now` (stops Pi-hole / Semaphore / cloudflared cleanly; data persists on volumes).
6. **Shut down rick** — QNAP UI *Shutdown* (parks the HDDs for transit).
7. **Power off bandee** — SSH in (`ssh chris@192.168.4.254`), `copy running-config startup-config`, then pull power. (No graceful shutdown; saved config is enough.)

## Startup

0. **Eero** — power on and confirm it has internet (needed for waddle's wifi, NTP upstream, and the Cloudflare tunnel).
1. **bandee** — power on first (network fabric). Boots from `startup-config`; no action needed.
2. **rick** — power on (storage available before the nodes mount it).
3. **waddle** — power on. Confirm the wifi reconnected and it has internet; provides DNS, DHCP, NTP, Semaphore.
4. **Proxmox nodes** (kirby, dede) — power on; they mount `rick-nfs`.
5. **meta** — power on.
6. **OPNsense VM** — on dede: `qm start 100` (unless set to start on boot). Not critical for lab operation until the NAT cutover is done.

## Post-startup checks

- DNS resolves (`ping waddle.lab.uprightlab.com` via Pi-hole).
- Nodes reachable on VLAN 10; `rick-nfs` shows `active` in `pvesm status`.
- NTP synced (`chronyc sources` on nodes / `timedatectl` on meta point at waddle).
- waddle has internet; Cloudflare tunnel healthy in the dashboard (WARP access restored).