# uprightlab — Build History

## November 2026

### Tuesday 24th

- Moved Pi-hole on waddle to UK time, syncing from `uk.pool.ntp.org`, and refreshed its lab host records: kirby removed, rick corrected to 192.168.4.20, and coo, nova01, nova and pc added. waddle's NTP server was already running and reachable, so it was not the cause of the time problems elsewhere.
- Fixed bandee's clock, which had been stuck in 2023. waddle was listed as a time server but without polling enabled, so bandee never queried it. The playbook now checks for polling, removes the SG350's default time servers so waddle is the only source, and sets GMT with BST summer time.
- Started planning Zigbee home automation on waddle, using a Sonoff Dongle Lite MG21 with Mosquitto, Zigbee2MQTT and Home Assistant, to monitor the lab's power and control an electric heater. Ordered a second Sonoff S60ZBTPG plug and a Bosch Room Thermostat II.
- Deployed Mosquitto and Zigbee2MQTT on waddle via Semaphore. The dongle connected first time and formed a new Zigbee network on channel 25, with no devices joined yet. Once it arrives, the new plug will be paired first and swapped in for the lab's existing one with everything powered down, rather than pairing the existing plug while it feeds the lab.

### Wednesday 18th

- Rebuilt coo as the lab's permanent edge NAT. Removed the interim bridge, DHCP pool, DNS forwarder and port forwards, moved eth1 to 10.0.10.2 on bandee gi25, and pointed bandee's default route at coo. The lab now has outbound internet without relying on waddle's wifi workaround. Remote access is via the Cloudflare Tunnel and WARP, with a jump box planned as a break-glass.
- Brought coo under Ansible. After testing both against coo, `community.network.edgeos_config` was chosen over `vyos.vyos` — the VyOS modules hang on the EdgeOS pager — and pinned at 5.1.0, its final release. The new coo playbook manages the lab route, outbound NAT, NTP, time zone, domain and hardware offload; the first run committed and saved cleanly, a second run made no changes, and the Configure coo template now runs the same way from Semaphore.

### Tuesday 3rd

- Tidied bandee's switch ports now the lab is reassembled: nova01 settled on the gi3 trunk (native VLAN 10); gi4 cleared and shut down, freed from the retired kirby and reserved for dede's eventual return; and gi25 added as a VLAN 10 access port for coo's LAN side. Applied the change via Semaphore and verified each port on the switch.
- Connected coo's WAN (eth0) to the spare powerline port on the Eero segment, with a reserved static lease (192.168.4.253), and confirmed it is reachable — the first step of rebuilding coo as the lab's permanent edge NAT. The LAN side (eth1 → gi25) and the NAT/routing cutover follow next.
- Retired kirby from the lab, to be repurposed as a sim-racing PC (it keeps its Quadro P4000; the Crucial P1 NVMe may later be reclaimed for dede). Moved its entry to a new Retired section in the hardware inventory.

## October 2026

### 27th October – 2nd November

- Brought the lab's home network back up after the Australia → UK move: set up the newly-arrived Eero mesh and switched the Virgin Hub into modem mode, so the Eero is the sole router and a layer of NAT is removed.
- Reconnected and powered up the lab hardware — bandee, waddle, rick and nova01 are plugged in and running. Verified connectivity: SSH to bandee, HTTPS to rick, and from bandee reached nova01 and waddle by ping.

### Thursday 15th

- Lab hardware arrived from the Australia→UK move. Reshuffled disks to resolve the Nutanix CVM failing to start — the Crucial P1 NVMe (Silicon Motion SM2263) can't be VFIO-passed to a CVM, so it moved to kirby for Proxmox use. nova01 was given a Samsung 970 EVO Plus 1TB (CVM/hot tier) and dede's 1TB MX500 (data), with the Intel S3510 as boot; dede's VM pool moved onto the 256GB Micron (renamed `mx500` → `vmdata`).
- Reinstalled Nutanix CE successfully and created the single-node `nova` cluster; Prism Element is up on VIP 10.0.10.30. Set up remote access to Prism and the CVM via port-forwards on coo, changed all default Nutanix passwords (stored in 1Password), and brought the lab docs into line with the final build.

### Tuesday 6th

- Built nova01, the first node of the nova cluster — an HP Z4 G4 running Nutanix Community Edition (AOS 6.8.1 / AHV). Installed on the management range behind coo (host 10.0.10.20, CVM 10.0.10.21); booted successfully, with the gateway and internet reachable. Reserved the 10.0.10.20–39 block for the Nutanix cluster (node host/CVM pairs, Prism Element VIP, Prism Central and the data services IP).

## September 2026

### Tuesday 22nd

- Built coo, a Ubiquiti EdgeRouter ERLite-3, as the lab's edge router, ahead of the rest of the lab arriving from shipping. In this interim standalone setup it provides internet access (NAT), DHCP and DNS on the management range for the new Nutanix host (Z4), which can therefore be built now with its final IP. coo will become the lab's permanent edge NAT, replacing the planned OPNsense VM and the waddle wifi workaround.

## July 2026

### Monday 13th July

- Opentofu bootstratped and OPNsense VM deployed.
- OPNsense installed and interfaces configured.
- Lab cleanly shutdown for tranist.

### Sunday 5th

- Configured second disk on dede

### Saturday 4th

- Added NFS storage from rick to the two proxmox hosts
- Added static route on rick so it can route to the 10.x.x.x networks
- Configured NTP on waddle and configured all other hosts to use waddle for their time source (including bandee)

### Friday 3rd

- Added VLAN aware networking to proxmox hosts
- Moved proxmox network config to a task in sempahore

## June 2026

### Monday 15th

- Onboarded meta to ansible and semaphore.
- Hardened config on meta to avoid sleep.
- Switch proxmox nodes to be VLAN-aware. Management IP stays untagged on native VLAN 10.

### Sunday 14th

- Added chris user to proxmox hosts.
- Onboarded proxmox hosts to semaphore.

### Saturday 13th

- Replaced GPU in kirby with a secondhand RTX 3060 12GB.

### Friday 12th

- meta built, connected and SSH access confirmed

## May 2026

### Wednesday 27th

- Updated semaphore to run from a custom image build that supports RSA keys to connect to bandee
- Added remaining switch config.
- Milestone 1 now completed!

### Tuesday 26th

- Moved to using Claude Code, still in advisory mode.
- Scanned repository with gitleaks and updated files such as README.md and LICENSE.
- Made repository public.
- Built out components for bandee's build, with a loop built to make the playbook idempotent as bandee has limited facts support.
- Added bandee's playbook to Semaphore and tiggered first automated gitops loop by adding an additional VLAN to the existing playbook.

### Saturday 23rd

- Setup remote access using Cloudflare WARP. 
- Completed initial Semaphore setup, getting the config of waddle to apply via Semaphore from GitHub, rather than manually from my Macbook. Setup auth so that Semaphore uses its own user, rather my user, to make it clear who/what is performing each action.

### Friday 22nd

- First time working with Ansible. Docker Compose file written for waddle to deploy Pi-hole, Cloudflared and Semaphore. Folder structure and playbook written to get Docker and Docker Compose running. Successfully got Pi-Hole and Semaphore available on the network, and Cloudflare Tunnel into a healthy status.
- Had to enable wifi on waddle to allow it to get internet access. The Eero network has no support for static routes and so has no idea where to route return packets for anything other than its own 192.168.4.0/22 network. Will likely fix this later by deploying OPNsense for outbound NAT.

### Thursday 21st

- Picked up a few supplies from Scorptec, including a case and power supply for the Pi 5, and 2 x SD card (one spare, one for the DakBoard Pi 3 so the one it was using could go into the Pi 5).
- Built the cloud-init config for waddle and then flashed the SD card with the image including the config files.
- After some trial and error, mainly due to typos, successfully booted waddle on to the network.

### Wednesday 20th

- Reset and reconfigured bandee to uplink via the Eero, rather than the Telstra modem. This means that if the modem is changed or no longer required, the homelab is insulated from that change. A lot of trial and error was required for this, but I managed to get a clear and repeatable process documented at [network/bandee/setup.md](network/bandee/setup.md). The management IP was placed on the 192.168.4.0/22 Eero range rather than the planned 10.0.10.x management VLAN, as the Eero has no knowledge of the 10.x.x.x ranges. See docs/decisions.md for full reasoning.
- Switched out the Raspberry Pi 5 in my DakBoard for a spare Raspberry Pi 3. The DakBoard doesn't need all the power of the 5, but the homelab does :D. 

### Monday 18th

Kirby is being built first. It is "new" hardware so sits under my desk whilst being built. Once Proxmox is installed, it will be moved to the homelab under the stairs. Dede will be rebuilt in place as it is already under the stairs. Kirby will need the service key adding after being built as it will be built before the Raspberry Pi node (waddle). Dede will be built once the waddle node is running and the Ansible playbook and Proxmox `answer.toml` are finalised during the build of kirby. At that point dede will not need the service key added, it will already be included in the `answer.toml`.
