# uprightlab — Tasks

## Phase 1 — Foundation

Setup the Raspberry Pi (piey) as the core foundation for the environment. This runs DNS, DHCP and Semaphore. Piey ensures every other host gets a predictable hostname and IP, and a consistent configuration using gitops.

## Phase 2 — Compute

Get the two beefy machines, ex-gaming kerbside found PC (kerby) and the existing homelab compute (nucky), installed with Proxmox and tuned via Ansible. Provides two hypervisor nodes connected to the NAS (nasy) for shared storage, managed as code.

### Phase 2a - Kerby build
- [ ] Build Proxmox install media and answer file
- [ ] Install Proxmox
- [ ] Relocate node to homelab

### Phase 2b - Nucky build
- [ ] Create answer file (reuse install media from Phase 2a)
- [ ] Install Proxmox

## Phase 3 — Kubernetes foundation

Preparing for Kubernetes, use the spare XPS laptop (lappy) to run as a bare metal Kubernetes control plane. Install Kubernetes control plane and CAPI elements, and get connected to the Proxmox API so as to provision VMs as worker nodes.

## Phase 4 — Kubernetes workloads

Provision worker node pools on kerby and nucky via CAPI. Aim to have a functioning multi-node cluster ready for workloads, including GPU-enabled workers on kerby.