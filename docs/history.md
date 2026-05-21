# uprightlab — Build History

## May 2026

### Thursday 21st

- Picked up a few supplies from Scorptec, including a case and power supply for the Pi 5, and 2 x SD card (one spare, one for the DakBoard Pi 3 so the one it was using could go into the Pi 5).
- Built the cloud-init config for waddle and then flashed the SD card with the image including the config files.
- After some trial and error, mainly due to typos, successfully booted waddle on to the network.

### Wednesday 20th

- Reset and reconfigured bandee to uplink via the Eero, rather than the Telstra modem. This means that if the modem is changed or no longer required, the homelab is insulated from that change. A lot of trial and error was required for this, but I managed to get a clear and repeatable process documented at [network/bandee/setup.md](network/bandee/setup.md). The management IP was placed on the 192.168.4.0/22 Eero range rather than the planned 10.0.10.x management VLAN, as the Eero has no knowledge of the 10.x.x.x ranges. See docs/decisions.md for full reasoning.
- Switched out the Raspberry Pi 5 in my DakBoard for a spare Raspberry Pi 3. The DakBoard doesn't need all the power of the 5, but the homelab does :D. 

### Monday 18th

Kirby is being built first. It is "new" hardware so sits under my desk whilst being built. Once Proxmox is installed, it will be moved to the homelab under the stairs. Dede will be rebuilt in place as it is already under the stairs. Kirby will need the service key adding after being built as it will be built before the Raspberry Pi node (waddle). Dede will be built once the waddle node is running and the Ansible playbook and Proxmox `answer.toml` are finalised during the build of kirby. At that point dede will not need the service key added, it will already be included in the `answer.toml`.
