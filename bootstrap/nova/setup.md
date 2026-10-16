# uprightlab — Nova Setup

This file documents the manual steps to build nova, the Nutanix host, prior to managing it as code.

nova is the lab's Nutanix cluster, running Nutanix Community Edition (CE). Its first — and currently only — node is nova01, an HP Z4 G4 workstation; further nodes would be nova02, nova03 and so on. The cluster hosts Prism Central, NKP (Nutanix Kubernetes Platform) and NAI (Nutanix AI). In this first phase nova runs behind coo on the management range (10.0.10.0/24) while the rest of the lab is in transit; it will join the wider lab when it returns.

## Prerequisites

- Hardware (nova01): HP Z4 G4, 8-core Xeon with hyperthreading (16 threads), 128GB RAM. A Quadro P4000 is fitted for the CE install; an RTX 3060 12GB is planned for NAI (GPU passthrough), pending a dual 6-pin → 8-pin PCIe power adapter for the Z4's PSU.
- Disks and their roles, as selected in the installer:
    - 970 EVO Plus 1TB M.2 NVMe SSD → CVM home + SSD/hot tier
    - 120GB Intel DC S3510 SATA SSD → AHV host boot
    - 1TB Crucial MX500 SATA SSD → data
  CE needs the CVM **and** data disks to each be ≥200GB and reachable by the CVM — see the passthrough note below, which dictated the disk choice.
- **NVMe passthrough gotcha:** the CVM gets its storage disks by PCI passthrough (VFIO). The original Crucial P1 (Silicon Motion SM2263 controller) **cannot be passed through** — QEMU fails with "MSI-X table & pba overlap" and the CVM will not start. So an NVMe that can't pass through can only serve as AHV **boot** (the host uses it directly, no passthrough); CVM/data disks must be passthrough-friendly — a Samsung/WD-controller NVMe, or SATA SSDs (the CVM gets those as virtio, no passthrough). The P1 was moved to kirby, where Proxmox uses it directly and is unaffected. See docs/decisions.md.
- A My Nutanix (Next) account — required to sign in to Prism on first login, and for CE licensing.
- The CE installer image downloaded, and a USB stick to write it to.

## Network

Static addresses on the management range (10.0.10.0/24). The block is laid out to leave room for more nodes:

- **10.0.10.20–29** — AHV host + CVM pairs, two per node (room for five nodes):
    - nova01 — host **10.0.10.20**, CVM **10.0.10.21**
    - nova02–05 — host/CVM in `.22`/`.23` … `.28`/`.29`, assigned as nodes are added
- **10.0.10.30** — cluster VIP (Prism Element)
- **10.0.10.31** — iSCSI data services IP (for Nutanix Volumes / the NKP CSI driver)
- **10.0.10.32** — Prism Central
- **10.0.10.33–39** — reserved (Prism Central scale-out, NKP / NAI service IPs)

Common settings:

- Netmask: 255.255.255.0 (/24)
- Gateway: 10.0.10.1 (coo)
- DNS: 10.0.10.1 (interim; becomes waddle 10.0.10.10 when the lab returns)
- Cluster name: **nova** (set with `ncli cluster edit-params new-name=nova`).
- Node identity: CE does not let you set a host name, so the AHV host keeps its auto-generated name (`NTNX-1db48058-A`), and the CVM is `NTNX-1db48058-A-CVM` by design (the ID is regenerated on each reinstall). Renaming the host afterward is a gated KB procedure, so it was left as-is. **nova01** is the lab's name for the node, carried in DNS/docs (`nova01.lab.uprightlab.com` → `10.0.10.20`), not on the host itself.

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
1. Set the disk selection: the **970 EVO Plus 1TB NVMe** as the CVM / SSD tier, the **120GB Intel SATA** as hypervisor boot, and the **1TB MX500 SATA** as the data disk. The installer USB stays unused.
1. Enter the network details: Host IP **10.0.10.20**, CVM IP **10.0.10.21**, Netmask **255.255.255.0**, Gateway **10.0.10.1**.
1. Hit Next.
1. Scroll all the way to the bottom of EULA and then hit Start (Tip: use the Page Down key).
1. The install runs and reboots (allow ~30 minutes). Remove the USB once it has rebooted into AHV, if the USB was only the installer.

## Create / confirm the cluster

These steps follow Nutanix's CE Getting Started → Cluster Configuration (see References).

1. Login at the console or SSH to the AHV host as root (default password `nutanix/4u`), then hop to the local CVM over the internal link: `ssh nutanix@192.168.5.2` (default password `nutanix/4u`). Once the cluster is up, the CVM is also reachable via ssh using the external IP (10.0.10.21)
1. Create a single-node cluster: `cluster -s 10.0.10.21 --redundancy_factor=1 create`. Wait until all services report **UP**.
1. Name the cluster **nova**: `ncli cluster edit-params new-name=nova` (or set it in Prism after first login).
1. Set coo as a local DNS server: `ncli cluster add-to-name-servers servers=10.0.10.1`
1. Set the cluster virtual (Prism) IP to **10.0.10.30**: `ncli cluster set-external-ip-address external-ip-address=10.0.10.30`.
1. Leave ntp servers, it is already set to use ntp.pool.org.

## Access Prism Element

1. Browse to `https://10.0.10.30:9440` (or the CVM directly at `https://10.0.10.21:9440`).
1. Log in with `admin` / `Nutanix/4u`. You are forced to change the password on first login — store the new one in 1Password.
1. Sign in with your My Nutanix account when prompted (a CE requirement).

## Remote access

1. **On nova's own LAN** — a device on the eth2 wifi extender (bridged onto 10.0.10.0/24) reaches `https://10.0.10.30:9440` directly, no extra config.
1. **From the home network** (behind coo) — coo port-forwards its WAN to Prism and the CVM; the DNAT rules live in bootstrap/coo/setup.md. With those in place, from the home LAN: Prism at `https://192.168.0.253:9440`, and the CVM shell via `ssh nutanix@192.168.0.253 -p 2221` (`192.168.0.253` is coo's reserved WAN address).

## Default Passwords

Change every default credential to a strong, unique password and record each in 1Password. No password values go in this file — they are plaintext passwords, so they live in 1Password and are never committed to the repo.

1. SSH to the CVM: `ssh nutanix@192.168.0.253 -p 2221`
1. Update the nutanix user's password on the cvm: `sudo passwd nutanix`
1. Update the admin user's password on the cvm: `sudo passwd admin`
1. Update the AHV users:
   1. `ssh root@10.0.10.20`
   1. `passwd`
   1. Change the password for the root user.
   1. `passwd admin`
   1. Change the password for the admin user.
   1. `passwd nutanix`
   1. Change the password for the nutanix user.

## Prism Element

1. Open PE
1. Click the cog icon in the top left.
1. Click Cluster Details and update the following:
   1. Change the name to `nova`
   1. Change the FQDN to `nova.lab.uprightlab.com`
   1. Enter the iSCSI Data Services IP as `10.0.10.31`
1. Open PE > LCM.
1. Click **Perform Inventory**. When prompted, select **Enable Auto Inventory** and **Enable Auto Update for NCC**.
1. Click Proceed.

Once the Inventory has finished there will be updates to install. 

1. Click Updates > Software.
1. Select all updates and then click View Upgrade Plan.
1. Click Next, then click Apply X Updates.
1. Repeat that process until no further updates are shown.
1. Review the Nutanix portal for the latest updates of AOS and AHV. If these are not beeing shown by LCM, download the LCM bundles and upload those so the upgrade can complete at the latest versions of all software.

## Prism Central deployment

Launched from Prism Element (deploy Prism Central). **Small single-node** was chosen: Extra Small does not support the microservices platform (CMSP) that NKP and NAI depend on (see the XS-limitations reference below), and HA scale-out gives no real resilience on a single physical node.

Step 1 — Version:

1. Create PC Name: `pc`.
1. Version: `pc.7.6.0.8` (latest compatible public version; "Only show compatible versions" ticked).

Step 2 — Size and Scale:

1. Size: **Small (S)** — 6 vCPU, 28 GB RAM, 500 GiB disk (supports up to 2500 VMs / 25 clusters / 200 hosts).
1. Leave **Enable High Availability (HA)** unchecked — single-node.

Step 3 — Configuration:

1. Network: **`vlan10-mgmt`** (the untagged VLAN 10 subnet).
1. Subnet Mask `255.255.255.0`, Gateway `10.0.10.1` (coo).
1. DNS `10.0.10.1` (coo — interim; becomes waddle `10.0.10.10` when the lab returns).
1. NTP `pool.ntp.org` (interim; repoint to waddle once it is up).
1. Container: the cluster's default storage container (`default-container-…`).
1. IP Address: **`10.0.10.32`**.
1. Internal Network Configuration: left collapsed / at defaults — this relates to PC's internal (microservices) network; revisit when enabling CMSP for NKP/NAI.
1. Click **Deploy** and wait for PC to come up at `https://10.0.10.32:9440`.

After deployment:

- Change PC's default `admin` password and store it in 1Password.
- Remote access from home needs its own coo port-forward — PC is a separate service on `10.0.10.32:9440`, distinct from the PE VIP `.30` forward. Add a rule following bootstrap/coo/setup.md (e.g. WAN `:9441` → `10.0.10.32:9440`).
- Before NKP/NAI, enable CMSP (microservices), which needs its own reserved IP block — see the `.33–.39` reservation in the Network section.

Reference — Extra Small PC limitations: https://portal.nutanix.com/page/documents/details?targetId=Prism-Central-Guide-vpc_7_6:mul-xs-pc-c.html

## Follow-on (to document as built)

- NKP (Nutanix Kubernetes Platform).
- NAI (Nutanix AI).
- Joining the wider lab when it returns (re-point DNS to waddle; integrate with bandee/coo routing).

## References

- Nutanix Community Edition — Getting Started, Cluster Configuration: https://portal.nutanix.com/page/documents/details?targetId=Nutanix-Community-Edition-Getting-Started-v2_1:top-cluster-config-ce-t.html
