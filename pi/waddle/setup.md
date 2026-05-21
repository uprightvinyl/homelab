# uprightlab - waddle Setup

## Image Setup

0. Ensure [workstation/setup.md](../../workstation/setup.md) has been completed.

1. Head to [https://www.raspberrypi.com/software/operating-systems/](https://www.raspberrypi.com/software/operating-systems/) and grab the URL for the latest Raspberry Pi OS Lite release. It needs to be based on Debian Trixie to include cloudinit support.

1. Run `diskutil list` to confirm the path for the destination device to write to with the `rpi-imager`

1. Run the following command from the `homelab` folder to prepare the OS install image for waddle

    ```
    rpi-imager --cli \
    --cloudinit-userdata pi/waddle/user-data \
    --cloudinit-networkconfig pi/waddle/network-config \
    *downloadurl* \
    *device*
    ```

    For example:

    ```
    rpi-imager --cli \
    --cloudinit-userdata pi/waddle/user-data \
    --cloudinit-networkconfig pi/waddle/network-config \
    https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2026-04-21/2026-04-21-raspios-trixie-arm64-lite.img.xz \
    /dev/disk4
    ```