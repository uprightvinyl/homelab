# uprightlab — Network Info

## VLANs

| VLAN | Name | Subnet | Purpose |
|------|------|--------|---------|
| 4 | Home | `192.168.4.0/22` | Eero uplink, home devices, rick |
| 10 | Management | `10.0.10.0/24` | Proxmox hosts, waddle, bandee |
| 20 | Kubernetes | `10.0.20.0/24` | K8s nodes and pod traffic |
| 30 | Workloads | `10.0.30.0/24` | General purpose VMs |

## IP Addressing

| Host | VLAN | Subnet | IP |
|------|------|--------|----|
| bandee (management) | 10 | `10.0.10.0/24` | `10.0.10.1` |
| waddle | 10 | `10.0.10.0/24` | `10.0.10.10` |
| dede | 10 | `10.0.10.0/24` | `10.0.10.11` |
| kirby | 10 | `10.0.10.0/24` | `10.0.10.12` |
| meta | 20 | `10.0.20.0/24` | `10.0.20.10` |
| rick | 4 | `192.168.4.0/22` | `192.168.4.20` |

## Switch Ports

| Port | Host | VLAN | Type |
|------|------|------|------|
| gi1  | waddle | 10 | Access |
| gi2  | rick | 4 | Access |
| gi3  | dede | 4, 10, 20, 30 | Trunk |
| gi4  | kirby | 4, 10, 20, 30 | Trunk |
| gi5-gi8 | Reserved for future compute hosts | - | - |
| gi9  | meta | 20 | Access |
| gi26 | Eero uplink | 4 | Access |

## Routing
Routing for the lab is managed by bandee. 

Rick has a static route configured so that can communicate with the lab (10.0.0.0/16) whilst ist default gateway is the eero device. 

## DNS

The lab uses a dedicated sub-domain of `lab.uprightlab.com`. This avoids the usage of .local which is discouraged due to potential mDNS clashes. Using a proper TLD allows the use of certs issued by Let's Encrypt.

DNS in the lab is handled by waddle. 

## DHCP

DHCP in the lab is handled by waddle. Range TBC. 

DHCP in the home network is handled by the Eero devices.

## NTP

Handled by pihole on waddle for entire network. 

## Internet Access

Internet access and outbound NAT for the lab are provided by coo, a Ubiquiti EdgeRouter. coo replaces the earlier plan to route internet access via an OPNsense VM, and the interim waddle wifi workaround. A dedicated hardware router at the edge is always on and independent of any hypervisor, so the lab's internet no longer depends on a compute node being up first. See docs/decisions.md for the reasoning.

coo owns only the edge role (WAN and outbound NAT); bandee continues to handle inter-VLAN routing. While the lab is in transit, coo runs standalone — see Interim setup below.

## Interim setup (lab in transit)

While the rest of the lab is being shipped, coo is the only live network device, running standalone as the edge router for the new Nutanix host (Z4):

- eth0 (WAN): DHCP client, plugged into the upstream Virgin router (double NAT; outbound only).
- eth1 (LAN): 10.0.10.1/24, serving the management range with NAT, a DHCP pool (10.0.10.100–150) and a DNS forwarder (until waddle provides DNS).

coo temporarily holds 10.0.10.1 — bandee's designated management and gateway address — because bandee is absent. The two are never live at the same time: when the lab returns, bandee reclaims 10.0.10.1 and coo is rebuilt as the edge NAT. This keeps the Nutanix host's gateway (10.0.10.1) constant across the move, so it needs no re-addressing — only its DNS entry moves from coo to waddle.

## Firewalling

Firewalling between VLANs, the lab and home devices is not in place for simplicity. At present there is no requirement to segregate the two networks.