# uprightlab — Coo Setup

This file documents the manual steps to build coo, the EdgeRouter, prior to managing it as code.

coo is a Ubiquiti EdgeRouter ERLite-3. In this first phase — while the rest of the lab is in transit — it acts as a standalone edge router and NAT gateway. It gives the new Nutanix host (on the Z4) internet access and an IP on the lab's management range (10.0.10.0/24), so the host does not need re-addressing when the lab arrives.

When the lab returns, coo will be rebuilt as the lab's permanent edge NAT — sitting between bandee and the Eero, retiring the OPNsense VM and the waddle wifi workaround. That rebuild is a separate exercise and is not covered here yet. See docs/decisions.md for the reasoning.

## Port roles

- **eth0** — WAN. DHCP client, plugged into the upstream Virgin router.
- **eth1** — LAN. Static 10.0.10.1/24, serving the lab side (the Z4 for now).
- **eth2** — spare LAN port.

Note: the ERLite-3's ports are independent routed interfaces by default, so eth1 connects straight to the Z4 with no switch in between.

## First time UI setup

1. Connect eth1 to the Virgin Router. The factory default is for eth1 to be configured for DHCP.
1. Connect to the Virgin router (`https://192.168.0.1`) and find the DHCP address given to the ERlite.
1. Browse to `https://192.168.0.xxx` and log in with the default credentials `ubnt` / `ubnt`.
1. Check the version on the dashboard. If it is an old EdgeOS 1.x, upgrade to the latest EdgeOS 2.x **e100 / EdgeMAX Lite** image (System > Upgrade, or `add system image <url>`).
1. Reboot if prompted.
1. SSH to the host (```ssh ubnt@192.168.0.x```), then set the hostname and create a **chris** admin user with an SSH key and a real password, and store the password in 1Password. Note, for the ssh key, just the key, remove comments.
    
    ```
    configure
    set system host-name coo
    set system login user chris level admin
    set system login user chris authentication plaintext-password <temporary-password>
    set system login user chris authentication public-keys chris type ssh-ed25519
    set system login user chris authentication public-keys chris key <ed25519 key material>
    commit
    save
    ```
    Note: use the same ed25519 public key as the other lab hosts. Paste only the key material — no `ssh-ed25519` prefix and no trailing comment.
1. Log back in as **chris**, then remove or disable the default **ubnt** user.

    ```
    configure
    delete system login user ubnt
    commit
    save
    ```

1. Reconfigure **eth0** as a DHCP client — this becomes the permanent WAN port. Once this change is made, connectivity will be lost.

    ```
    configure
    set interfaces ethernet eth0 address dhcp
    set interfaces ethernet eth0 description WAN
    commit
    save
    ```

1. Move the uplink cable from eth1 to **eth0**. Management continues over eth0, which still sits inside the private network behind the Virgin router.

## Interfaces, NAT and services

With the WAN up on eth0, configure eth1 as the lab LAN and add the services. Management stays on the eth0 (WAN) side for now, which is inside the private network behind the Virgin router.

1. Configure the LAN interface:

    ```
    configure
    delete interfaces ethernet eth1 address dhcp
    set interfaces ethernet eth1 address 10.0.10.1/24
    set interfaces ethernet eth1 description LAN
    ```
1. Add outbound NAT (masquerade on the WAN):

    ```
    set service nat rule 5000 description "masquerade to WAN"
    set service nat rule 5000 outbound-interface eth0
    set service nat rule 5000 type masquerade
    ```
1. Add a DNS forwarder for the LAN, used until waddle provides DNS:

    ```
    set service dns forwarding listen-on eth1
    set service dns forwarding name-server 1.1.1.1
    set service dns forwarding name-server 1.0.0.1
    set service dns forwarding cache-size 150
    ```
1. Add a small DHCP pool for convenience, leaving .1, .10 and .20–.29 free for statics:

    ```
    set service dhcp-server shared-network-name LAN subnet 10.0.10.0/24 default-router 10.0.10.1
    set service dhcp-server shared-network-name LAN subnet 10.0.10.0/24 dns-server 10.0.10.1
    set service dhcp-server shared-network-name LAN subnet 10.0.10.0/24 domain-name lab.uprightlab.com
    set service dhcp-server shared-network-name LAN subnet 10.0.10.0/24 start 10.0.10.100 stop 10.0.10.150
    commit
    save
    ```
1. Plug a client (or the Z4) into **eth1** to test the LAN: it should pull a lease in 10.0.10.100–150, reach the router at 10.0.10.1, and route to the internet — `ping 1.1.1.1` (NAT), then `ping bbc.co.uk` (DNS).

