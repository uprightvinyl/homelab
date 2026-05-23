# uprightlab — Cloudflare Setup

## Tunnel Setup

1. Open [dash.cloudflare.com](dash.cloudflare.com) and login.
1. Select Networking > Tunnels.
1. Click Create a tunnel.
1. Select Cloudflared
1. Name the tunnel `uprightlab-tunnel` and click Save tunnel.
1. Select Docker and copy the command. Add just the token to 1Password.
1. Click Cancel. The tunnel should have still been created. We can configure further items once the tunnel is established after the Cloudflared docker container is running on waddle

**Note: The token included in the copy command is sensitive and should never be committed to GitHub.**

## Cloudflare Remote Access

1. Open [dash.cloudflare.com](dash.cloudflare.com) and login.
1. Click on Zero Trust from the left hand menu.
1. Under "Replace my client-based or site-to-site VPN" click Get Started. Follow the wizard to get the Macbook setup for access to homelab networks using WARP. Add 10.0.10.0/24 when asked. Note that cloudflared shouldn't be required on the Macbook. Once complete, add the other networks to the device profile and confirm for the profile that split tunnelling is enabled and includes the private subnets in the network.
