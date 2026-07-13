# uprightlab — Tasks

> Note: Lab Worked Paused due to relocation. Status prior to power down: OPNsense base interfaces done (VLAN-10 LAN untagged); cutover NOT done; OPNsense API/Ansible config pending; then AWS pivot.

## Milestone 0 — Preparation

This milestone prepares the MacBook so it is able to complete the rest of the lab build.

- [x] Clone Git repository to MacBook
- [x] Generate workstation key for SSH usage and update code with public key.
- [x] Install pre-requisites tools using brew and brewfile (Ansible, rpi-imager etc)
- [x] Add static routes to MacBook

## Milestone 1 — Foundation

Setup foundational infrastructure including the core switch and Raspberry Pi (waddle). waddle runs DNS and DHCP for the lab. waddle ensures every other host gets a predictable hostname and IP.

### Stage 1a — Switch bootstrap

More info on the exact steps can be found here: [network/bandee/setup.md](network/bandee/setup.md)

- [x] Configure management interface and uplink to Eero via UI (VLAN 4).
- [x] Configure management VLAN 10
- [x] Configure 1 x access port for waddle, using VLAN 10.
- [x] Configure inter-vlan routing

### Stage 1b — Pi bootstrap
- [x] Flash SD card with Raspberry Pi OS and add cloud init files
- [x] Build waddle using SD card, confirm network availability
- [x] Write Docker Compose file for waddle
- [x] Run playbook from workstation to deploy Docker, Pi-hole and Semaphore via Docker Compose using Ansible
- [x] Configure Cloudflare for remote access to waddle and remove static routes from Macbook

### Stage 1c — Semaphore bootstrap & Initial GitOps

- [x] Configure Semaphore — connect to GitHub repo and add service key
- [x] Add lab host static DNS records to Pi-hole via Ansible
- [x] Use Ansible playbook to complete configuration of switch (additional VLANs, trunk ports, inter VLAN routing etc).

## Milestone 2 — Compute

Get the compute hardware built and moved into the lab. That covers the two beefy machines, ex-gaming kerbside found PC (kirby) and the existing homelab compute (dede), and the Dell XPS laptop. OS installed, and ready for config using ansible from Semaphore.

### Stage 2a — Kirby build
- [x] Relocate node to homelab
- [x] Build Proxmox install media and answer file
- [x] Install Proxmox
- [x] Configure GPU passthrough with Ansible Playbook

### Stage 2b — Dede build
- [x] Create answer file (reuse install media from Stage 2a)
- [x] Install Proxmox

### Stage 2c - Meta build
- [x] Create Ubuntu server media
- [x] Create Ubuntu cloudinit
- [x] Install Ubuntu Server
- [x] Move meta to lab

### Stage 2d - Ansible
- [x] Create proxmox API user for semaphore
- [x] Create and test basic Ansible runbook for proxmox hosts.
- [x] Onboard meta to Semaphore.

## Milestone 3 — Proxmox Config and OPNsense

Build out full proxmox config (storage connectivity, DNS, NTP, virtual networks, templates, ISOs), and deploy first VM - OPNsense. That will allow internet connectivity from all nodes in the lab, and allow for  switching off the wifi card in waddle.

### Stage 3a — Proxmox networking & storage
- [x] Make vmbr0 VLAN-aware on both nodes
- [x] Decide and configure ISO storage (local vs rick NFS)
- [x] Configure NTP
- [x] Add dede's MX500 as an lvmthin VM pool

### Stage 3b — OPNsense (via OpenTofu)

**OpenTofu foundation**
- [x] Install OpenTofu (add to Brewfile)
- [x] Create tofu project skeleton (providers.tf, main.tf, variables.tf)
- [x] Wire bpg/proxmox provider to the API token (env var, not committed)
- [x] Gitignore tfstate, .terraform/, tfvars

**ISO**
- [x] Download OPNsense installer ISO
- [x] Upload ISO to rick-nfs

**Provision VM**
- [x] Define OPNsense VM in OpenTofu (dede; boot from ISO; net0 tag=4 WAN, net1 tag=10 LAN; local disk)
- [x] tofu apply to create the VM

**Install & configure**
- [x] Install OPNsense from ISO (console/VNC)
- [x] Configure WAN (VLAN 4) and LAN (VLAN 10) interfaces
- [ ] Configure outbound NAT for lab subnets (10.x)
- [ ] Decide how much OPNsense config is captured as code vs GUI

**Cut over**
- [ ] Point bandee default route at OPNsense LAN
- [ ] Verify lab internet from a Proxmox node
- [ ] Disable waddle wifi

### Stage 3c - Proxmox post internet connectivity config
- [ ] Switch to no-subscription repos + updates
- [ ] Install sudo on Proxmox nodes

## Milestone 4 — Kubernetes foundation

Preparing for Kubernetes, use the spare XPS laptop (meta) to run as a bare metal Kubernetes control plane. Install Kubernetes control plane and CAPI elements, and get connected to the Proxmox API so as to provision VMs as worker nodes.

## Milestone 5 — Kubernetes workloads

Provision worker node pools on kirby and dede via CAPI. Aim to have a functioning multi-node cluster ready for workloads, including GPU-enabled workers on kirby. Deploy AWX.

## Items to Scheduled

- Deploy OPNSense for hide NAT out to the internet/eero network (Deploy VM with VLAN 4 and 10 attached)
- Disabled wifi on waddle once OPNSense is in place.
- Switch DNS host management to using the Ansible API or a collection, rather than being in the Docker Compose file which requires a restart of the container every time a DNS record is added.
- Add manually configured switch config items to Ansible playbook.
- Deploy PDM