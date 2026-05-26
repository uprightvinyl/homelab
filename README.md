# uprightlab

A personal homelab built and operated as code — Proxmox, Kubernetes and a
GitOps workflow — used as a hands-on environment for learning infrastructure
and as a reference I can share and demo.

## What this is

uprightlab is my home lab: a small set of mixed hardware that I rebuild and
extend deliberately, to learn the tools and patterns behind modern
infrastructure. Everything here — network, hosts and services — is described as
code in this repository and applied through automation rather than by hand.

It is intentionally a *learning* environment, so decisions favour understanding
and repeatability over being the fastest or most production-hardened option.

## Architecture

| Host | Hardware | Role |
|------|----------|------|
| bandee | Cisco SG350-28 | Core switch — VLANs and inter-VLAN routing |
| waddle | Raspberry Pi 5 | DNS, DHCP and GitOps (Pi-hole, Semaphore) |
| dede | Intel NUC 11 Pro | Proxmox node |
| kirby | Custom PC (i7-6700K, GTX 980 Ti) | Proxmox node, GPU passthrough |
| meta | Dell XPS 13 | Bare-metal Kubernetes control plane |
| rick | QNAP TS-251 | Shared NFS storage |

The network is segmented into VLANs for management, Kubernetes and workloads,
with the lab living under the `lab.uprightlab.com` domain. Remote access is via
a Cloudflare Tunnel and WARP. See [docs/network.md](docs/network.md) and
[docs/hardware.md](docs/hardware.md) for detail.

## Tooling

- **Ansible** — host configuration; run from the workstation for bootstrap and
  from Semaphore thereafter.
- **Semaphore** — GitOps runner on waddle that applies Ansible playbooks from
  this repository.
- **Docker Compose** — lightweight services on waddle (Pi-hole, Cloudflared,
  Semaphore).
- **cloud-init** — first-boot configuration of new hosts.
- **Proxmox** — virtualisation for the compute nodes (planned).
- **Kubernetes + Cluster API** — the eventual workload platform (planned).

## Current status

- **Milestone 0 — Preparation:** complete.
- **Milestone 1 — Foundation:** switch and waddle in place; DNS, DHCP, remote
  access and the Semaphore GitOps loop are running. Remaining: complete the
  switch configuration via Ansible.
- **Milestone 2 — Compute:** Proxmox on kirby and dede (upcoming).
- **Milestone 3 — Kubernetes foundation:** control plane on meta (upcoming).
- **Milestone 4 — Kubernetes workloads:** Cluster API workers, GPU workloads
  and AWX (upcoming).

See [tasks.md](tasks.md) for the full breakdown and
[docs/history.md](docs/history.md) for the build log.

## Repository layout

| Path | Contents |
|------|----------|
| `ansible/` | Inventory, playbooks and templates |
| `bootstrap/` | Manual first-time setup notes per host |
| `cloud-init/` | First-boot host configuration |
| `cloudflare/` | Remote access (Tunnel / WARP) setup |
| `docker/` | Docker Compose stacks |
| `proxmox/` | Proxmox answer files |
| `docs/` | Design decisions, network, hardware and history |

## Documentation

- [Design decisions](docs/decisions.md)
- [Network design](docs/network.md)
- [Hardware inventory](docs/hardware.md)
- [Build history](docs/history.md)

## How AI is used

AI assistants help with this lab in an **advisor** capacity — explaining
concepts, accelerating mundane work and helping with troubleshooting — but
changes are understood before they are made, and most work is done by hand. The
guidance given to AI tools lives in [AGENTS.md](AGENTS.md) (and `CLAUDE.md` for
Claude Code). See the "Use of AI" section in [docs/decisions.md](docs/decisions.md).