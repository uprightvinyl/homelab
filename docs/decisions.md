# uprightlab - Design decisions

## Use of AI

The homelab is primarily a learning environment. AI guidance is used to help understand concepts, accelerate implementation and for troubleshooting. However, AI is not blindly followed, as this defeats the primary learning purposes of this lab environment.

Whilst AI tools are used to assist in building and operating this lab, they are primarily used in an advisor capacity. Changes are not made without full understanding of their impact, and most code is written by humans. AI generated code is only generated for mundane tasks that are repeating a pattern already established by human work.

### lappy as dedicated bare metal Kubernetes control plane
- The Dell XPS 13 9350 runs the Kubernetes control plane on bare metal,
  outside of Proxmox, keeping it independent of the hypervisor layer
- Its built-in battery provides UPS-like resilience during power
  outages, keeping the control plane available while other nodes
  lose power
