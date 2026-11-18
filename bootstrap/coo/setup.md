# uprightlab — Coo Setup

This file documents the manual steps to build coo, the EdgeRouter, prior to managing it as code.

coo is a Ubiquiti EdgeRouter ERLite-3 and is the lab's edge NAT gateway. It sits between bandee (on the management VLAN) and the Eero home network, giving every lab VLAN outbound internet access via NAT. bandee keeps inter-VLAN routing and sends only its default route to coo. DHCP and DNS for the lab are provided by waddle, not coo. See docs/decisions.md for the reasoning.

## Port roles

- **eth0** — WAN. DHCP client on the Eero home network (192.168.4.0/22), connected via the spare port on the lab-end powerline adapter. The Eero reserves 192.168.4.253 for it.
- **eth1** — LAN. Static 10.0.10.2/24, connected to bandee gi25 (VLAN 10 access port).
- **eth2** — spare, unconfigured.

## Prerequisites

- bandee gi25 is configured as a VLAN 10 access port. This is managed by the bandee playbook (`ansible/inventory/host_vars/bandee/vars.yaml`).
- bandee holds 10.0.10.1 on VLAN 10, and its default route points at coo once coo is built — see [Point bandee at coo](#point-bandee-at-coo).

## First time UI setup

1. Connect eth1 to the home network (e.g. the spare powerline port). The factory default is for eth1 to be configured for DHCP.
1. Find the DHCP address given to the ERLite in the Eero app.
1. Browse to `https://192.168.4.xxx` and log in with the default credentials `ubnt` / `ubnt`.
1. Check the version on the dashboard and upgrade to the latest EdgeOS **e100 / EdgeMAX Lite** image (System > Upgrade, or `add system image <url>`). coo runs EdgeOS v3.0.1.
1. Reboot if prompted.
1. SSH to the host (```ssh ubnt@192.168.4.xxx```), then set the hostname and create a **chris** admin user with an SSH key and a real password, and store the password in 1Password.

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
1. Log back in as **chris**, then remove the default **ubnt** user.

    ```
    configure
    delete system login user ubnt
    commit
    save
    ```

1. Reconfigure **eth0** as a DHCP client — this becomes the permanent WAN port. You are still connected via eth1, so the session stays up.

    ```
    configure
    set interfaces ethernet eth0 address dhcp
    set interfaces ethernet eth0 description WAN
    commit
    save
    ```

1. Move the cable from eth1 to **eth0**. This drops the session; eth0 picks up its own lease from the Eero.
1. In the Eero app, add a DHCP reservation of **192.168.4.253** for coo's eth0, then reboot coo (or renew the lease) so it picks up the reserved address. Management continues over eth0 at `192.168.4.253`.

## LAN interface, outbound NAT and Semaphore user

With the WAN up on eth0, set up what Ansible needs to reach and run against coo: the LAN address, outbound NAT and a service user.

- The interface addresses stay manual because they are how Ansible connects — a bad push to them could cut Semaphore off mid-run.
- Outbound NAT is also set here, even though the playbook manages it too. Semaphore needs internet access to pull this repository and install collections, and the lab only has internet once coo is masquerading. Setting it by hand means rebuilding coo doesn't depend on waddle's wifi workaround; the playbook then adopts the rule on its first run.

1. Configure the LAN interface and outbound NAT, and create the **semaphore** user with the Semaphore ed25519 public key (`ansible/files/semaphore_service_key.pub`, key material only):

    ```
    configure
    delete interfaces ethernet eth1 address dhcp
    set interfaces ethernet eth1 address 10.0.10.2/24
    set interfaces ethernet eth1 description LAN
    set service nat rule 5000 description 'masquerade to WAN'
    set service nat rule 5000 outbound-interface eth0
    set service nat rule 5000 type masquerade
    set system login user semaphore level admin
    set system login user semaphore authentication plaintext-password <random password>
    set system login user semaphore authentication public-keys semaphore type ssh-ed25519
    set system login user semaphore authentication public-keys semaphore key <ed25519 key material>
    commit
    save
    exit
    ```
    Note: `level admin` is needed to enter configuration mode. EdgeOS requires a password on every user, even one that logs in with a key, so generate a long random one and store it in 1Password.
1. Connect eth1 to bandee **gi25**.
1. Create the vaulted host vars for coo, holding the service user's name:

    ```
    ansible-vault create ansible/inventory/host_vars/coo/secrets.yaml
    ```
    Content: `vault_coo_semaphore_user: semaphore`

## Remaining configuration (Ansible)

Everything else on coo is managed by `ansible/playbooks/coo.yaml`, using `community.network.edgeos_config`:

- A static route for the lab networks (10.0.0.0/16) via bandee. coo is directly connected only to VLAN 10, so without it, replies to VLAN 20 and 30 would leave via the WAN.
- Outbound NAT (masquerade on the WAN), adopted from the bootstrap.
- NTP from waddle, the Europe/London time zone and the lab domain.
- Hardware offload. The ERLite-3 is a Cavium platform, so it uses `ipv4 forwarding` (`hwnat` is for the ER-X). Without offload, routing runs on the CPU at roughly 300 Mbps.

The playbook needs `community.network`, which is no longer part of the `ansible` package. Semaphore installs it from `ansible/playbooks/collections/requirements.yml`; on the workstation, it is in `ansible/requirements.yaml`.

1. Add a Semaphore task template following bootstrap/semaphore/setup.md: name **Configure coo**, path `ansible/playbooks/coo.yaml`, the **uprightlab** inventory (which carries the ed25519 service key — not uprightlab-rsa, which is for bandee), and the Ansible Vault Password.
1. Run it with `--check --diff` first to preview the changes (edgeos_config supports check mode), then run it for real.
1. Check offload on coo with `show ubnt offload`, and reboot if it does not show as enabled.

## Point bandee at coo

bandee routes between the lab VLANs and sends everything else to coo. On bandee:

```
configure terminal
no ip route 0.0.0.0 0.0.0.0 192.168.4.1
ip route 0.0.0.0 0.0.0.0 10.0.10.2
end
copy running-config startup-config
```

## Remote access

coo has no port forwards. Remote access to the lab is via the Cloudflare Tunnel and WARP (see cloudflare/setup.md), which route 10.0.10.0/24 to lab hosts at their real addresses.

A jump box is planned as a break-glass for when the tunnel is unavailable. When it is built, it will get a single destination-NAT rule on coo's WAN, plus a masquerade rule scoped to the jump box so its replies return via coo rather than directly from bandee.

coo's WAN firewall is not enabled. coo sits behind the Eero's own NAT, so its WAN is reachable only from the home network, not the public internet.

## Testing

| From | Command | Shows |
|------|---------|-------|
| coo | `ping 10.0.10.1`, `ping 10.0.10.10` | LAN side is up |
| coo | `ping 10.0.20.10` | Static route to VLAN 20 via bandee works |
| bandee | `show ip route` | Default route is via `10.0.10.2` |
| waddle or the nova01 CVM | `ping 1.1.1.1`, then `ping bbc.co.uk` | Outbound NAT and DNS work |
