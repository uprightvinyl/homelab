# uprightlab — Network Info

## VLANs

| VLAN | Name | Subnet | Purpose |
|------|------|--------|---------|
| 4 | Home | `192.168.4.0/22` | Eero uplink, home devices, rick |
| 10 | Management | `10.0.10.0/24` | Proxmox and Nutanix hosts, waddle, bandee |
| 20 | Kubernetes | `10.0.20.0/24` | K8s nodes and pod traffic |
| 30 | Workloads | `10.0.30.0/24` | General purpose VMs |

## IP Addressing

| Host | VLAN | Subnet | IP |
|------|------|--------|----|
| bandee (management) | 4 | `192.168.4.0/22` | `192.168.4.254` |
| bandee (VLAN 10 gateway) | 10 | `10.0.10.0/24` | `10.0.10.1` |
| coo (LAN) | 10 | `10.0.10.0/24` | `10.0.10.2` |
| coo (WAN, Eero reservation) | 4 | `192.168.4.0/22` | `192.168.4.253` |
| waddle | 10 | `10.0.10.0/24` | `10.0.10.10` |
| dede (to be re-added) | 10 | `10.0.10.0/24` | `10.0.10.11` |
| nova01 (ahv) — `NTNX-1db48058-A` | 10 | `10.0.10.0/24` | `10.0.10.20` |
| nova01 (cvm) — `NTNX-1db48058-A-CVM` | 10 | `10.0.10.0/24` | `10.0.10.21` |
| nova cluster VIP (Prism Element) | 10 | `10.0.10.0/24` | `10.0.10.30` |
| nova iSCSI data services | 10 | `10.0.10.0/24` | `10.0.10.31` |
| pc (Prism Central) | 10 | `10.0.10.0/24` | `10.0.10.32` |
| meta | 20 | `10.0.20.0/24` | `10.0.20.10` |
| rick | 4 | `192.168.4.0/22` | `192.168.4.20` |

## Switch Ports

| Port | Host | VLAN | Type |
|------|------|------|------|
| gi1  | waddle | 10 | Access |
| gi2  | rick | 4 | Access |
| gi3  | nova01 | 4, 10, 20, 30 | Trunk |
| gi4  | Reserved (dede, re-add later) | - | - |
| gi5-gi8 | Reserved for future compute hosts | - | - |
| gi9  | meta | 20 | Access |
| gi25 | coo (LAN / edge NAT uplink) | 10 | Access |
| gi26 | Eero uplink | 4 | Access |

## Routing

bandee routes between the lab VLANs (10, 20, 30) and the home network (VLAN 4), and sends everything else to coo via its default gateway (`10.0.10.2`). coo routes the lab range (`10.0.0.0/16`) back via bandee (`10.0.10.1`), and sends internet traffic out its WAN to the Eero (`192.168.4.1`).

rick has a static route to the lab (`10.0.0.0/16`) via bandee, as its default gateway is the Eero.

## DNS

The lab uses a dedicated sub-domain of `lab.uprightlab.com`. This avoids the usage of .local which is discouraged due to potential mDNS clashes. Using a proper TLD allows the use of certs issued by Let's Encrypt.

DNS in the lab is handled by waddle. 

## DHCP

DHCP in the lab is handled by waddle. Range TBC. 

DHCP in the home network is handled by the Eero devices.

## NTP

Handled by pihole on waddle for entire network. 

## Internet Access

Internet access and outbound NAT for the lab are provided by coo, a Ubiquiti EdgeRouter, rather than the previously planned OPNsense VM or the waddle wifi workaround. Outbound traffic goes from bandee to coo, which masquerades it out to the Eero; the Virgin Hub is in modem mode, so the Eero's NAT is the only other layer. A dedicated hardware router at the edge is always on and independent of any hypervisor, so the lab's internet does not depend on a compute node being up first. coo owns only the edge role; bandee handles inter-VLAN routing. See docs/decisions.md for the reasoning.

Remote access is via the Cloudflare Tunnel and WARP, which route `10.0.10.0/24` to the lab. coo has no port forwards; a jump box is planned as a break-glass.

## Firewalling

Firewalling between VLANs, the lab and home devices is not in place for simplicity. At present there is no requirement to segregate the two networks.