# uprightlab - Network Info

## VLANs

| VLAN | Name | Subnet | Purpose |
|------|------|--------|---------|
| 4 | Home | `192.168.4.0/22` | Eero uplink, home devices, nasy |
| 10 | Management | `10.0.10.0/24` | Proxmox hosts, piey, switchy |
| 20 | Kubernetes | `10.0.20.0/24` | K8s nodes and pod traffic |
| 30 | Workloads | `10.0.30.0/24` | General purpose VMs |

## IP Addressing

| Host | VLAN | Subnet | IP |
|------|------|--------|----|
| switchy (management) | 10 | `10.0.10.0/24` | `10.0.10.1` |
| piey | 10 | `10.0.10.0/24` | `10.0.10.10` |
| nucky | 10 | `10.0.10.0/24` | `10.0.10.11` |
| kerby | 10 | `10.0.10.0/24` | `10.0.10.12` |
| lappy | 20 | `10.0.20.0/24` | `10.0.20.10` |
| nasy | 4 | `192.168.4.0/22` | TBD |

## DNS

The lab uses a dedicated sub-domain of `lab.uprightlab.com`. This avoids the usage of .local which is discouraged due to potential mDNS clashes. Using a proper TLD allows the use of certs issued by Lets Encrypt.

DNS in the lab is handled by piey. 

## DHCP

DHCP in the lab is handled by piey. Range TBC. 

DHCP in the home network is handled by the Eero devices.

## Internet Access

Internet access for the lab routes via the Cisco switch, Eero and 5g modem. 

## Firewalling

Firewalling between VLANs, the lab and home devices is not in place for simplicity. At present there is no requirement to segregate the two networks.