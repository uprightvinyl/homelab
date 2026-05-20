# uprightlab — Build History

## May 2026

### Wednesday 20th

Reset and reconfigured bandee to uplink via the Eero, rather than the Telstra modem. This means that if the modem is changed or no longer required, the homelab is insulated from that change. A lot of trial and error was required for this, but I managed to get a clear and repeatable process documented at [network/bandee/setup.md](network/bandee/setup.md). The management IP was placed on the 192.168.4.0/22 Eero range rather than the planned 10.0.10.x management VLAN, as the Eero has no knowledge of the 
10.x.x.x ranges. See docs/decisions.md for full reasoning.

### Monday 18th

Kirby is being built first. It is "new" hardware so sits under my desk whilst being built. Once Proxmox is installed, it will be moved to the homelab under the stairs. Dede will be rebuilt in place as it is already under the stairs. Kirby will need the service key adding after being built as it will be built before the Raspberry Pi node (waddle). Dede will be built once the waddle node is running and the Ansible playbook and Proxmox `answer.toml` are finalised during the build of kirby. At that point dede will not need the service key added, it will already be included in the `answer.toml`.
