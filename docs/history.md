# uprightlab — Build History

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
