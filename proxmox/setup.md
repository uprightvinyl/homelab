# uprightlab - Proxmox Setup

## Create ISO

By default, the Proxmox ISO boots into GUI mode. We want to change that to automated mode. 

1. Download the ISO from the Proxmox site. Copy it to a folder called proxmox-build.
1. Make sure Docker Desktop is running.
1. Change to the proxmox-build folder, then start a Docker container locally: `docker run --rm -it -v "$PWD:/work" --platform linux/amd64 debian:trixie bash`
1. Run the following in the container as there is no Mac version of `proxmox-auto-install-assistant`.

    ```
    apt update && apt install -y curl whois
    curl -sLo /usr/share/keyrings/proxmox-release.gpg \
    https://enterprise.proxmox.com/debian/proxmox-release-trixie.gpg
    echo 'deb [signed-by=/usr/share/keyrings/proxmox-release.gpg] http://download.proxmox.com/debian/pve trixie pve-no-subscription' \
    > /etc/apt/sources.list.d/pve.list
    apt update && apt install -y proxmox-auto-install-assistant

    cd /work
    proxmox-auto-install-assistant prepare-iso proxmox-ve_9.*.iso \
    --fetch-from partition
    ```

1. Then use Raspberry Pi Imager (Select "Use custom" for OS), balenaEtcher or `dd` to write the ISO to a USB stick.

## Gathering Hardware Details

1. Boot target hosts using ISO and enter Debug Mode (Advanced Options > Debug Mode)
1. Grab MAC address using the following command: `proxmox-auto-install-assistant device-info -t network`
1. Grab disks info using the following command: `proxmox-auto-install-assistant device-info -t disk`
1. Use this info to filter for the correct devices in the relevant answer file.

## Answer Files

1. Copy the relevant answer file from /proxmox/answer-files to a different USB stick. The device must be named "PROXMOX-AIS". 
    1. Find the USB device label `diskutil list`
    1. Erase the disk and set the correct name `diskutil eraseDisk MS-DOS PROXMOX-AIS /dev/diskX`
    1. Copy the answer file `cp proxmox/answer-files/hostname.answer.toml /Volumes/PROXMOX-AIS/answer.toml`
1. Unplug the device and plug into the server alongside the ISO USB.