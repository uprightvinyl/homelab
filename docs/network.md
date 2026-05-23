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
| rick | 4 | `192.168.4.0/22` | `192.168.4.10` |

## Switch Ports

| Port | Host | VLAN |
|------|------|------|
| gi1  | waddle | 10 |
| gi26 | Eero uplink | 4 |


## DNS

The lab uses a dedicated sub-domain of `lab.uprightlab.com`. This avoids the usage of .local which is discouraged due to potential mDNS clashes. Using a proper TLD allows the use of certs issued by Let's Encrypt.

DNS in the lab is handled by waddle. 

## DHCP

DHCP in the lab is handled by waddle. Range TBC. 

DHCP in the home network is handled by the Eero devices.

## Internet Access

Internet access for the lab routes via the Cisco switch, Eero and 5g modem. 

## Firewalling

Firewalling between VLANs, the lab and home devices is not in place for simplicity. At present there is no requirement to segregate the two networks.