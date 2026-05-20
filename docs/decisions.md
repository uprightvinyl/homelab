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

## Security

### Storing of hashed creds and public keys in GitHub

The proxmox `answer.toml` has a hashed password included. This has been included for simplicity, rather than injecting the password later or excluding the file entirely. Proxmox doesn't support passwordless config, the install will fail without a password. The password is of significant complexity that it is not simple to hack, and is unique to each host, limiting the blast radius. And this just for my homelab, which is not a critical environment.

The file also includes public keys. These are again included for simplicity, avoiding an extra step to add these or injecting them as part of the build process. The public key is designed to be public, it is useless without the private key. Again, in a more secure or production environment, omitting these keys would be preferred, but this is for my homelab. 

Both decisions weigh simplicity over complete security, without introducing a significant security risk.

### Personal and Service Keys

A key is used for my personal Mac to access the environment. A separate "service" key is used on waddle for secure authentication between infrastructure nodes. If my machine is compromised or the key lost, avoiding reuse of that key for the services in my lab means the key only needs to be replaced on my personal device. 

### Use of RSA keys for bandee

As bandee doesn't support ED25519, RSA keys are used instead. This has to be generated separately. 
