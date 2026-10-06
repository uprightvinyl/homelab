# uprightlab — Nova Setup

This file documents the manual steps to build nova, the Nutanix host, prior to managing it as code.

nova is the lab's Nutanix cluster, running Nutanix Community Edition (CE). Its first — and currently only — node is nova01, an HP Z4 G4 workstation; further nodes would be nova02, nova03 and so on. The cluster hosts Prism Central, NKP (Nutanix Kubernetes Platform) and NAI (Nutanix AI). In this first phase nova runs behind coo on the management range (10.0.10.0/24) while the rest of the lab is in transit; it will join the wider lab when it returns.

## Prerequisites

- Hardware (nova01): HP Z4 G4, 8-core Xeon with hyperthreading (16 threads), 128GB RAM.
- Disks (all-flash) and their roles, as selected in the installer:
    - 120GB Intel DC S3510 SATA SSD (`sda`) → AHV host boot
    - 500GB Crucial P1 M.2 NVMe SSD (`nvme0n1`) → CVM home + SSD/hot tier
    - 256GB Micron 1300 SATA SSD (`sdb`) → capacity
  CE needs the CVM on an SSD of ~200GB or more (the NVMe qualifies) and a separate boot device (the 120GB).
- A My Nutanix (Next) account — required to sign in to Prism on first login, and for CE licensing.
- The CE installer image downloaded, and a USB stick to write it to.

## Network

Static addresses on the management range (10.0.10.0/24). The block is laid out to leave room for more nodes:

- **10.0.10.20–29** — AHV host + CVM pairs, two per node (room for five nodes):
    - nova01 — host **10.0.10.20**, CVM **10.0.10.21**
    - nova02–05 — host/CVM in `.22`/`.23` … `.28`/`.29`, assigned as nodes are added
- **10.0.10.30** — cluster VIP (Prism Element)
- **10.0.10.31** — Prism Central
- **10.0.10.32** — iSCSI data services IP (for Nutanix Volumes / the NKP CSI driver)
- **10.0.10.33–39** — reserved (Prism Central scale-out, NKP / NAI service IPs)

Common settings:

- Netmask: 255.255.255.0 (/24)
- Gateway: 10.0.10.1 (coo)
- DNS: 10.0.10.1 (interim; becomes waddle 10.0.10.10 when the lab returns)
- Node hostname: nova01 (cluster name: nova)

## Write the installer USB (macOS)

Writing the CE image with `dd` produced a stick that would not boot on this hardware. **UNetbootin** was used instead and booted cleanly.

1. Install UNetbootin — `brew install --cask unetbootin`, or download it from unetbootin.github.io.
1. In Disk Utility, format the USB stick as **MS-DOS (FAT)** — UNetbootin expects a FAT-formatted target.
1. Launch UNetbootin and select **Diskimage**, set the type to **ISO**, and browse to the CE image.
1. Set **Type: USB Drive**, select the stick's device (e.g. `/dev/disk4s1`), and click **OK**.
1. Wait for it to finish writing, then quit UNetbootin and eject the stick.

## BIOS (HP Z4 G4)

1. Power on and hit **F10** to enter BIOS.
1. Open Security > System Security to enable virtualisation: **Intel Virtualization Technology (VT-x)** and **VT-d** (Directed I/O). These are required for AHV and for later GPU/device passthrough.
1. Open Advanced > Secure Boot Configuration and set Configure Legacy Support and Secure Boot to **Legacy Support Disable and Secure Boot Disable**.
1. Save and exit.

## Install Nutanix CE

1. Boot from the USB stick (with all other disks wiped it should boot automatically, otherwise set it first in the boot order, or pick it from the F9 menu).
1. Set the disk selection: **120GB SATA (`sda`)** as hypervisor boot, **500GB NVMe (`nvme0n1`)** as the CVM / SSD tier, **256GB SATA (`sdb`)** as capacity. The installer USB (`sdc`) stays unused.
1. Enter the network details: Host IP **10.0.10.20**, CVM IP **10.0.10.21**, Netmask **255.255.255.0**, Gateway **10.0.10.1**. (CE 6.8.1 does not ask for a hostname here — that is set at cluster create / in Prism.)
1. Hit Next.
1. Scroll all the way to the bottom of EULA and then hit Start.
1. The install runs and reboots (allow ~30 minutes). Remove the USB once it has rebooted into AHV, if the USB was only the installer.

## Create / confirm the cluster

1. SSH to the CVM: `ssh nutanix@10.0.10.21` (default password `nutanix/4u`).
1. Check `cluster status`. If no cluster exists yet, create a single-node cluster: `cluster -s 10.0.10.21 create`.
1. Name the cluster **nova**: `ncli cluster edit-params new-name=nova` (or set it in Prism after first login).
1. Set the cluster virtual (Prism) IP to **10.0.10.30** (and the data services IP, **10.0.10.32**, if prompted) — this can also be done in Prism after first login.

## Access Prism Element

1. Browse to `https://10.0.10.30:9440` (or the CVM directly at `https://10.0.10.21:9440`).
1. Log in with `admin` / `Nutanix/4u`. You are forced to change the password on first login — store the new one in 1Password.
1. Sign in with your My Nutanix account when prompted (a CE requirement).

## Remote access

Goal: reach Prism without being at the Z4 in the garden office. Options, quickest first:

1. **On nova's own LAN** — a device on the eth2 wifi extender (bridged onto 10.0.10.0/24) reaches `https://10.0.10.30:9440` directly, no extra config.
1. **From the home network** (behind coo) — add a destination-NAT on coo forwarding its WAN port 9440 to Prism:

    ```
    configure
    set service nat rule 1 description "Prism Element"
    set service nat rule 1 type destination
    set service nat rule 1 inbound-interface eth0
    set service nat rule 1 protocol tcp
    set service nat rule 1 destination port 9440
    set service nat rule 1 inside-address address 10.0.10.30
    set service nat rule 1 inside-address port 9440
    commit
    save
    ```
    Then browse to `https://192.168.0.237:9440` (coo's current WAN address) from the home LAN.
1. **From anywhere** — run a tunnel (Tailscale, or a Cloudflare tunnel) on a small VM on the cluster once it is up. Do not expose Prism directly to the internet via a Virgin port-forward. This is a follow-on once there is a VM to host the tunnel.

## Follow-on (to document as built)

- Prism Central deployment.
- NKP (Nutanix Kubernetes Platform).
- NAI (Nutanix AI).
- Joining the wider lab when it returns (re-point DNS to waddle; integrate with bandee/coo routing).
