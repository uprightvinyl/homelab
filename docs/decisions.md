# uprightlab — Design Decisions

## Philosophy

### Use of AI

The homelab is primarily a learning environment. AI guidance is used to help understand concepts, accelerate implementation and for troubleshooting. However, AI is not blindly followed, as this defeats the primary learning purposes of this lab environment.

Whilst AI tools are used to assist in building and operating this lab, they are primarily used in an advisor capacity. Changes are not made without full understanding of their impact, and most code is written by humans. AI generated code is only generated for mundane tasks that are repeating a pattern already established by human work.

## Infrastructure

### bandee management interface

- Bandee's management interface lives on the Eero network, so I can access it whilst on the wifi. Bandee's management interface would be unreachable if configured on one of the other lab networks, as the Eero has no knowledge of those and so routes everything outside of its network to the internet.

### meta as dedicated bare metal Kubernetes control plane

- The Dell XPS 13 9350 runs the Kubernetes control plane on bare metal,
  outside of Proxmox, keeping it independent of the hypervisor layer
- Its built-in battery provides UPS-like resilience during power
  outages, keeping the control plane available while other nodes
  lose power

### Docker Compose used for services on waddle

- waddle will run lightweight infrastructure services, such as Pi-hole. These will run as Docker containers, allowing the container focus of the environment to be maintained, even on this small node that is not part of a k8s cluster.
- The configuration for Docker containers running on waddle will use Docker Compose, and the Compose files will be stored in GitHub.

### Ansible Gitops Workflow using Semaphore running on waddle

- waddle running on a Raspberry Pi 5 provides sufficient resources to run Semaphore alongside DNS and DHCP services.
- Semaphore will be deployed using Docker Compose, and then will be used to configure all other nodes in the lab via Ansible playbooks stored in GitHub.
- The initial bootstrap configuration of waddle will be carried out using an Ansible playbook run from the Macbook workstation.
- waddle will use SQLite for the Semaphore database, its embedded so keeps things simple by avoiding another container for MYSQL or PostgreSQL.

### DNS

- waddle will host an authoritative DNS server for the lab.
- upstream DNS will be provided using Cloudflare (1.1.1.1), initially this will not use a tunnel for DNS-over-HTTPS from waddle. This is for simplicity as there is no real need to encrypt DNS requests at this stage. This decision may be reviewed in the future, more out of curiosity than necessity.

### Checking switch state with show commands, not gathered facts

The bandee playbook needs to know the switch's current state — which VLANs exist, how ports are configured etc, so that a change is it only applied when something has actually drifted. The playbook does this by running targeted `show` commands with `community.ciscosmb.command` (e.g. `show vlan`) and guarding each change with a `when:` condition, rather than gathering structured facts with `community.ciscosmb.facts`.

The facts module, `community.ciscosmb.facts`, is the obvious first choice, but it doesn't expose the data needed effectively. Its facts are limited to model, version, hardware, interfaces, neighbours and the raw running-config — there is no list of configured VLANs. The two facts that look relevant aren't: `ansible_net_config` is just the running-config as text (so the text still needs parsing, only its a larger blob - show vlan vs the full running config), and `ansible_net_interfaces` lists the Layer 3 VLAN *interfaces* (SVIs), not Layer 2 VLAN-database membership — a VLAN can exist without an SVI, so it would give the wrong answer.

`show vlan` is therefore the most direct and authoritative source for "does this VLAN exist", and the lightest: the facts module runs a batch of show commands across every subset, whereas the guard needs just one. The general preference remains structured facts over text parsing wherever a collection provides them — this collection simply doesn't, so a targeted `show` is the pragmatic choice.

### Pinning Semaphore's encryption key

Semaphore encrypts its Key Store (SSH keys, the Ansible Vault password, the Cloudflare token) with a single AES-256 key, `SEMAPHORE_ACCESS_KEY_ENCRYPTION`. If it isn't set explicitly, Semaphore generates one and stores it inside the container filesystem — outside the data volume — so it is lost whenever the container is recreated, leaving the persisted database undecryptable ("cannot decrypt access key"). Because the Semaphore image is now a custom build that is rebuilt and recreated on deploy, the key is set explicitly: generated with `openssl rand -base64 32`, stored in 1Password, and injected via the gitignored `secrets-external.yaml` vault → `.env` → Compose. It is kept out of the committed vault because, combined with the database, it would expose every stored credential — including the Ansible Vault password.

### Proxmox nodes managed via API; OS-level automation intentionally minimal

Proxmox exposes a full REST API for everything hypervisor-specific: VM provisioning, storage, networking, cluster management and user administration. Rather than managing these through OS-level Ansible tasks over SSH, the `community.proxmox` collection is used to interact with the API directly. This is both safer (Proxmox owns its own config files, particularly `/etc/network/interfaces`) and more idiomatic — the same path used by Terraform, Cluster API and other ecosystem tooling.

SSH-based Ansible automation on the Proxmox nodes is therefore intentionally minimal, limited to one-off OS-level changes that the API cannot make. The only task in this category is enabling Intel IOMMU and loading VFIO modules on kirby for GPU passthrough (`ansible/playbooks/kirby-iommu.yaml`), which is run once from the workstation and never needs to run again.

The root user is left enabled on both nodes as the SSH bootstrap entry point. A 'chris' user is added to proxmox hosts for SSH access that is consistent with all other hosts. However,  day-to-day access and all ongoing automation use a Proxmox API token.

### Standalone Proxmox nodes, not a cluster

kirby and dede are kept as standalone Proxmox nodes rather than joined into a cluster. The decision follows from storage: the NAS (rick) isn't performant enough to serve as primary VM storage, so VMs use node-local storage on each host. With local rather than shared storage, the two headline benefits of a Proxmox cluster — high-availability failover and seamless live migration — aren't available anyway, since both depend on shared storage. Clustering would therefore buy only management convenience, not resilience.

It would also actively reduce robustness. A two-node cluster has no quorum majority, so if one node goes down the survivor loses quorum and drops to read-only — it can't start or stop VMs until the other returns. Two independent standalone nodes have no such failure mode; each is self-sufficient. Restoring quorum would mean adding a QDevice (a third corosync vote, typically hosted on waddle), which adds a component purely to claw back robustness that clustering gave away — a poor trade for management tidiness alone, and one that breaks the principle of keeping the Proxmox nodes' OS footprint minimal.

Standalone nodes also suit the eventual Kubernetes design. Worker VMs provisioned via Cluster API are treated as cattle: they don't migrate, and if a node fails the cluster reprovisions elsewhere. That failure-handling already lives at the Kubernetes layer, so cluster-level HA underneath it would be redundant.

### Unified management via Proxmox Datacenter Manager

The one genuine benefit clustering offered — a single console across both nodes — is provided instead by Proxmox Datacenter Manager (PDM), which is purpose-built to manage multiple standalone nodes (and clusters) from one pane without joining them. This gives a unified inventory, guest and snapshot view across kirby and dede while each node stays fully independent, resolving the management-convenience question without reintroducing the quorum fragility above. PDM is used for human, console-based management; automation continues to talk to each node's API directly via Ansible and the community.proxmox collection. PDM runs as its own lightweight appliance (VM or LXC) alongside the nodes.

## Security

The general rule of storing encrypted creds in GitHub has come down to whether they could be used to access my homelab remotely, and therefore possibly my home network as well. If its just a cred that is used only for something within the lab, such as a local password, then I'm comfortable storing it encrypted in GitHub. If it is something that can be used externally, it stays out of GitHub, is injected when needed, and is stored in 1Password.

### Storing of hashed creds and public keys in GitHub

The proxmox `answer.toml` has a hashed password included. This has been included for simplicity, rather than injecting the password later or excluding the file entirely. Proxmox doesn't support passwordless config, the install will fail without a password. The password is of significant complexity that it is not simple to hack, and is unique to each host, limiting the blast radius. And this is just for a homelab, which is not a critical environment.

The file also includes public keys. These are again included for simplicity, avoiding an extra step to add these or injecting them as part of the build process. The public key is designed to be public, it is useless without the private key. Again, in a more secure or production environment, omitting these keys would be preferred, but this is for my homelab. 

Both decisions weigh simplicity over complete security, without introducing a significant security risk.

Its also worth noting that both these secrets are useless without local access to the lab.

### Use of Ansible Vault

Instead of keeping credentials in plaintext (for example in a Docker Compose `.env` file), Ansible Vault is used to encrypt variables for use with Ansible and Compose.

Vault files are split by how the credential could be used, following the security rule above:

- **`secrets.yaml` — committed (encrypted).** Holds only *in-lab* credentials that are useless without local access to the lab (for example the Pi-hole and Semaphore admin passwords). They are stored AES-256 encrypted in the repo. This is acceptable because they cannot be used to reach the lab or home network from outside, and the vault passphrase is long, high-entropy and held only in 1Password. No private keys or externally-usable secrets are placed in this file.
- **`secrets-external.yaml` — excluded from the repo.** Holds anything that could be used from *outside* the lab (for example the Cloudflare Tunnel token). It is git-ignored, stored in 1Password, and injected at run time (locally, or via Semaphore's environment).

### Personal and Service Keys

A key is used for my personal Mac to access the environment. A separate "service" key is used on waddle for secure authentication between infrastructure nodes. If my machine is compromised or the key lost, avoiding reuse of that key for the services in my lab means the key only needs to be replaced on my personal device. 

### Use of RSA keys for bandee

As bandee doesn't support ED25519, RSA keys are used instead. This has to be generated separately. 

### Security Related Convenience Tradeoffs Accepted for the Lab

A few settings consciously favour convenience over hardening, because this is a
non-critical learning environment on a trusted local network with no
internet-facing services:

- **`host_key_checking = False`** (`ansible/ansible.cfg`) — Ansible does not
  verify SSH host keys. This avoids failures when hosts are rebuilt and their
  keys change, at the cost of host-key verification on the lab LAN. It would be
  re-enabled in a production or untrusted environment.
- **Passwordless sudo (`NOPASSWD:ALL`)** for the `chris` and `semaphore` users
  — lets cloud-init and Semaphore automate configuration without interactive
  prompts. The blast radius is limited to the lab, and access still requires the
  relevant SSH private key.

## OS Choice

### Meta - Ubuntu Server 24.04 LTS

- Meta will run Ubuntu Server 24.04 LTS. This aligns with what NKP uses and makes initial setup easier than dealing with Talos. A future switch to Talos may be considered, but not at this initial phase of the lab rebuild.