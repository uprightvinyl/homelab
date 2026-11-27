# uprightlab — Shutdown & Startup Procedure

Steps to fully power the lab down and bring it back up — e.g. for relocation or extended downtime. Order matters: shut down consumers before providers; start providers before consumers.

## Relocation note

The Eero and its `192.168.4.0/22` network move with the lab. The lab only ever peers with VLAN 4 / `192.168.4.0/22` and has no knowledge of anything upstream of the Eero, so **no lab network reconfiguration is required on power-up**. The only task at a new location is to give the Eero a working internet uplink (modem/ISP). Everything downstream — bandee's uplink, rick, waddle's wifi, coo's WAN — comes back unchanged, provided the Eero keeps its config (SSID, DHCP reservations, including coo's 192.168.4.253).

## Shutdown

1. **Capture state first** — commit and push everything; confirm `git status` is clean.
2. **Shut down meta** — `sudo shutdown -h now`.
3. **Shut down the Proxmox nodes** (dede, when re-added) — UI *Shutdown* or `sudo shutdown -h now`. Before rick, so the `rick-nfs` mount unmounts cleanly.
4. **Shut down nova01** — before waddle, as remote access to the CVM relies on WARP via cloudflared on waddle. SSH to the CVM (`ssh nutanix@10.0.10.21`), then:
   1. Check the cluster is stopped with `cluster status`. If it isn't, shut down Prism Central's VM first, then run `cluster stop` and type `I agree` when prompted.
   2. Check only the CVM is running on the host: `ssh root@192.168.5.1 "virsh list --all"`. If Prism Central's VM still shows as running, `virsh shutdown <name>` it and wait for it to shut off.
   3. Schedule the AHV host's shutdown, then shut down the CVM straight away:

      ```
      ssh root@192.168.5.1 "shutdown -h +5"
      cvm_shutdown -P now
      ```

      The CVM takes a minute or two to shut down, and the host powers off five minutes after being scheduled. `192.168.5.1` is the host's internal address, which the CVM can always reach. To cancel the host's shutdown before it happens, run `ssh root@192.168.5.1 "shutdown -c"` from the CVM.
5. **Shut down waddle** — `sudo shutdown -h now` (stops Pi-hole / Semaphore / cloudflared cleanly; data persists on volumes).
6. **Shut down rick** — QNAP UI *Shutdown* (parks the HDDs for transit).
7. **Power off bandee** — SSH in (`ssh chris@192.168.4.254`), `copy running-config startup-config`, then pull power. (No graceful shutdown; saved config is enough.)
8. **Power off coo** — its config is saved by the coo playbook, so it can be powered off last.

## Startup

0. **Eero** — power on and confirm it has internet (needed for waddle's wifi, NTP upstream, and the Cloudflare tunnel).
1. **bandee and coo** — power on first (network fabric and the lab's internet). Both boot from their saved config; no action needed.
2. **rick** — power on (storage available before the nodes mount it).
3. **waddle** — power on. Confirm it has internet; provides DNS, DHCP, NTP, Semaphore.
4. **Proxmox nodes** (dede, when re-added) — power on; they mount `rick-nfs`.
5. **meta** — power on.
6. **nova01** — power on; the CVM starts on its own. After a few minutes, SSH to the CVM (`ssh nutanix@10.0.10.21`) and run `cluster start`. Once `cluster status` shows all services as `UP`, start Prism Central's VM. Its name was set to `pc` at deployment; confirm with `acli vm.list` if unsure:

   ```
   acli vm.on pc
   ```

   Or in one step from the workstation (with WARP connected): `ssh nutanix@10.0.10.21 'source /etc/profile; acli vm.on pc'`. Prism Central takes 10–20 minutes to come up at `https://10.0.10.32:9440`. If it doesn't, SSH to it (`ssh nutanix@10.0.10.32`), check `cluster status`, and run `cluster start` if its services are down.

## Moving the lab's power supply

The lab's multi-way adapter is fed through the `lab-plug` Zigbee smart plug, which monitors the lab's power use. Anything that cuts the plug's power — moving the lab to another socket, or a firmware update on the plug — takes waddle down with it, including Zigbee2MQTT. So treat it as a planned power cut:

1. Follow the shutdown order above, but leave waddle, bandee and coo running for now.
2. Shut down waddle, then save bandee's and coo's config:
   - waddle: `ssh chris@10.0.10.10 'sudo shutdown -h now'`, then wait for its activity light to stop.
   - bandee: `ssh chris@192.168.4.254`, then `copy running-config startup-config`.
   - coo: `ssh chris@192.168.4.253`, then `configure`, `compare saved`, `save`, `exit`. If `exit` complains about uncommitted changes, investigate before saving.
3. Switch off and move the multi-way. Powering it again brings up bandee, coo and waddle by themselves; nova01 and rick stay off until powered on.
4. With the lab plug free, do whatever needed it free, such as pairing or a firmware update. Its Zigbee2MQTT page is reachable at `http://192.168.4.55:8080` (waddle's wifi address) from the home network.
5. To move the lab back onto the plug, repeat steps 2–3. With power-on behaviour set to `on`, the plug switches on as soon as it is plugged in.
6. Power on rick, then nova01, and run the post-startup checks.

Notes:
- **WARP and the home network:** with WARP connected, SSH to devices on the home network (bandee, coo, waddle's wifi address) fails. Disconnect WARP for those, and reconnect it for VLAN 10 addresses.
- **Lab plug firmware:** only update it with the lab on another socket, as the update may restart the plug.
- **Lab plug settings:** power-on behaviour `on`, no inching, and no minimum-power or minimum-current overload limits, so the plug never switches the lab off by itself.
- **Typical draw:** about 26 W for bandee, coo and waddle alone, and about 126 W with nova01 (cluster stopped) and rick added.

## Post-startup checks

- DNS resolves (`ping waddle.lab.uprightlab.com` via Pi-hole).
- Nodes reachable on VLAN 10; `rick-nfs` shows `active` in `pvesm status`.
- NTP synced (`chronyc sources` on nodes / `timedatectl` on meta point at waddle).
- Lab internet via coo: `ping 1.1.1.1` from bandee succeeds.
- waddle has internet; Cloudflare tunnel healthy in the dashboard (WARP access restored).