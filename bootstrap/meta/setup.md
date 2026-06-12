# uprightlab — meta Setup

meta is a Dell XPS 13 9350 running Ubuntu Server 24.04 LTS on bare metal, to act as the Kubernetes control plane. It is installed unattended using Ubuntu's autoinstall (subiquity), driven by the cloud-init files in [cloud-init/meta](../../cloud-init/meta).

## Image Setup

0. Ensure [workstation/setup.md](../workstation/setup.md) has been completed.

1. Download the latest Ubuntu Server 24.04 LTS (Long Term Support) live-server ISO for amd64 from [https://releases.ubuntu.com/24.04/](https://releases.ubuntu.com/24.04/).

1. Identify the target USB device with `diskutil list`, then write the ISO to it. Use the raw device (`rdiskN`) for speed and replace `N` with the correct disk number.

    ```
    diskutil unmountDisk /dev/diskN
    sudo dd if=ubuntu-24.04.4-live-server-amd64.iso of=/dev/rdiskN bs=1m
    diskutil eject /dev/diskN
    ```

## Autoinstall Config USB

The autoinstall config is supplied on a second USB using cloud-init's NoCloud datasource. The installer looks for a filesystem labelled `CIDATA` containing `user-data` and `meta-data` at its root.

1. Identify the second USB with `diskutil list`, then format and label it.

    ```
    diskutil eraseDisk MS-DOS CIDATA /dev/diskN
    ```

1. Copy the autoinstall files to it.

    ```
    cp cloud-init/meta/user-data /Volumes/CIDATA/user-data
    cp cloud-init/meta/meta-data /Volumes/CIDATA/meta-data
    diskutil eject /dev/diskN
    ```

## Install

1. Connect meta to switch port gi9 (access VLAN 20) via the USB Ethernet adapter. Count ports left to right.

1. Insert both USB sticks (installer and CIDATA) and power on, pressing F12 for the Dell one-time boot menu. Select the installer USB.

1. At the GRUB menu, press `e` to edit the boot entry. Append `autoinstall` to the end of the line beginning `linux`, then press Ctrl-X (or F10) to boot. This tells the installer to proceed without the interactive "this will erase the disk" confirmation, using the config from the CIDATA USB.

1. The install runs unattended — it partitions the disk (guided LVM), configures the static network on VLAN 20, installs the OpenSSH server and the `chris` user, then reboots.

1. Remove the installer USB during the reboot so the machine boots from its internal disk rather than re-running the installer.

## Validation

Note: meta is on VLAN 20 (`10.0.20.0/24`). To reach it from the MacBook, confirm the Cloudflare WARP split-tunnel profile includes the `10.0.20.0/24` network.

1. Confirm meta is reachable. The DNS record already exists in Pi-hole.

    ```
    ping meta.lab.uprightlab.com
    ```

1. Confirm key-based SSH access as `chris`.

    ```
    ssh chris@meta.lab.uprightlab.com
    ```

With meta reachable, it can be onboarded to Semaphore (create the `semaphore` user and service key via Ansible), completing Stage 2d.