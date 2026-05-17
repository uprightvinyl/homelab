# uprightlab - Hardware Inventory

## Hardware inventory

### piey — Raspberry Pi 3B+
- Hostname: piey.uprightlab.local
- Role: DNS, DHCP, Ansible Semaphore
- CPU: 1.4GHz quad-core ARM Cortex-A53
- RAM: 1GB SDRAM
- Storage: 32GB SD card
- Network: Gigabit Ethernet (over USB 2.0), dual-band Wi-Fi
- Note: 1GB RAM constrains what can run here

### nucky — Intel NUC 11 Pro (NUC11TNHi5)
- Hostname: nucky.uprightlab.local
- Role: Proxmox node
- CPU: Intel Core i5-1135G7 @ 2.40GHz (8 cores)
- RAM: 64GB DDR4 SO-DIMM
- Storage: 250GB Samsung 980 NVMe, 1TB Crucial MX500 SSD
- Network: Intel i225-LM 2.5GbE, Wi-Fi 6

### kerby — kerbside PC
- Hostname: kerby.uprightlab.local
- Role: Proxmox node
- CPU: Intel Core i7-6700K
- Motherboard: ASUS Z170-Deluxe
- RAM: 32GB (4 x 8GB) Corsair DDR4 2133MHz
- Storage: 500GB Crucial BX100 SATA SSD
- GPU: Gigabyte GTX 980 Ti Xtreme Gaming 6GB (PCIe passthrough)

### nasy — QNAP TS-251
- Hostname: nasy.uprightlab.local
- Role: shared storage, NFS exports
- CPU: Intel Celeron J1800 (2 cores)
- RAM: 1GB DDR3L
- Storage: 2 x 2TB Western Digital WD20EFRX-68EUZN0
- Network: 2 x Gigabit Ethernet

### lappy — Dell XPS 13 9350
- Hostname: lappy.uprightlab.local
- Role: bare metal Kubernetes control plane
- CPU: Intel Core i7-6560U @ 2.20Ghz (2 Cores, 4 Threads)
- RAM: 16GB DDR3L
- Storage: 512GB SSD

### switchy — Cisco SG350-28
- Hostname: switchy.uprightlab.local
- Role: core network switch
- Ports: 28 x Gigabit Ethernet
- Features: managed, VLAN capable
