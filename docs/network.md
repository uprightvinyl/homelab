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