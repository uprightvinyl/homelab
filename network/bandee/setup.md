# uprightlab — Bandee Setup

This file documents manual steps that need to be carried out prior to using Ansible.

## First time UI Setup

### Set Static IP in Correct VLAN

1. Reset the switch to factory defaults and unplug from the network so that it does not receive a DHCP address. Without DHCP it will use a 192.168.1.0/24 subnet, which is outside of the 192.168.4.0/22 range we want to use, perfect.
    Note: The switch will by default try to grab an IP via DHCP first.
1. Connect port GE25 directly to the MacBook.
1. Configure the MacBook with a static IP address of 192.168.1.10/24.
1. Connect to the web UI using 192.168.1.254.
1. Login with the default credentials and create a new **admin** user. Store the creds in 1Password.
1. Open VLAN Management > VLAN Settings.
1. Click Add.
1. Create a new VLAN with ID VLAN 4 and click Apply.
1. Open VLAN Management > Port VLAN Membership
1. Select GE26 and click Join VLAN
1. Under Access VLAN ID, select 4. Click Apply.
1. Open IP Configuration > IPv4 Management and Interfaces > IPv4 Interface.
1. Delete the VLAN 1 interface configured with DHCP.
1. Click Add.
1. Create a new interface on VLAN 4, which uses Static IP Address as the IP Address Type. enter the following:
    - IP Address: 192.168.4.254
    - Network Mask: 255.255.252.0
1. Click Apply.
1. Connectivity will be lost. Change the port in use from GE25 to GE26 and plug the other end of the cable into the Eero, connectivity should be reestablished.
1. Click Save in the top menu bar to commit the config.

Note: Remember to use the Eero app to create an IPv4 reservation for bandee.

### SSH Access

Now that bandee is running on the correct static IP in the correct VLAN, let's setup SSH access.

1. Login via the Web UI and switch the Display Mode to **Advanced** (required to show the SSH Server option in the left hand menu).
1. Open Security > SSH Server > SSH User Authentication.
1. Enable **SSH User Authentication by Public Key** and **Automatic Login**.
1. Under **SSH User Authentication Table (by Public Key)**, click **Add**.
1. Click Apply
1. Enter **admin** for the username, select the Key Type as **RSA**, and paste in the RSA public key from the laptop. Remove anything other than the key material e.g. `ssh-rsa` at the beginning and any comments at the end.
    Note: You can use `cat ~/.ssh/id_rsa.pub` to get the rsa public key.
1. Open Security > TCP/UDP Services.
1. Enable the SSH Service and click Apply.
1. Click Save in the top menu bar.

With these steps done, you can now SSH to the switch on the correct IP address.

## Manual Configuration via SSH

The following steps will complete the remaining manual configuration of the switch. After this, the remaining switch configuration will be automated via Semaphore running on waddle.

1. SSH to bandee `ssh admin@192.168.4.254`.
1. Configure hostname, VLAN 10 and an interface for waddle.

    ```
    configure
    hostname bandee
    vlan database
    vlan 10
    exit
    interface gi1
    switchport mode access
    switchport access vlan 10
    exit
    exit
    ```

1. Commit the config to run at start, `copy running-config startup-config`.
    