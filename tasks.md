# uprightlab — Tasks

## Milestone 0 — Preparation

This milestone prepares the MacBook so it is able to complete the rest of the lab build.

- [x] Clone Git repository to MacBook
- [x] Generate workstation key for SSH usage and update code with public key.
- [ ] Install pre-requisites tools using brew and brewfile (Ansible, rpi-imager etc)

## Milestone 1 — Foundation

Setup foundational infrastructure including the core switch and Raspberry Pi (piey). Piey runs DNS and DHCP for the lab. Piey ensures every other host gets a predictable hostname and IP.

### Stage 1a — Switch bootstrap
- [ ] Configure management VLAN 10
- [ ] Configure uplink to Eero (VLAN 4)
- [ ] Configure 1 x access port for piey, using VLAN 10.

### Stage 1b — Pi bootstrap
- [ ] Flash SD card with Raspberry Pi OS and add cloud init files
- [ ] Build piey using SD card, confirm network availability
- [ ] Connect to piey from workstation and run Ansible playbook to deploy & configure Docker and Pi-hole
- [ ] Add lab host static DNS records to Pi-hole via Ansible.

### Stage 1c — Switch config completion
- [ ] Use Ansible playbook to complete configuration of switch (additional VLANs, trunk ports, inter VLAN routing etc)

## Milestone 2 — Compute

Get the two beefy machines, ex-gaming kerbside found PC (kerby) and the existing homelab compute (nucky), installed with Proxmox and tuned via Ansible. Provides two hypervisor nodes connected to the NAS (nasy) for shared storage, managed as code.

### Stage 2a — Kerby build
- [ ] Build Proxmox install media and answer file
- [ ] Install Proxmox
- [ ] Relocate node to homelab

### Stage 2b — Nucky build
- [ ] Create answer file (reuse install media from Stage 2a)
- [ ] Install Proxmox

## Milestone 3 — Kubernetes foundation

Preparing for Kubernetes, use the spare XPS laptop (lappy) to run as a bare metal Kubernetes control plane. Install Kubernetes control plane and CAPI elements, and get connected to the Proxmox API so as to provision VMs as worker nodes.

## Milestone 4 — Kubernetes workloads

Provision worker node pools on kerby and nucky via CAPI. Aim to have a functioning multi-node cluster ready for workloads, including GPU-enabled workers on kerby. Deploy AWX.