# uprightlab - Cloudflare Setup

## Tunnel Setup

1. Open [dash.cloudflare.com](dash.cloudflare.com) and login.
1. Select Networks > Connectors.
1. Click Create a tunnel.
1. Select Cloudflared
1. Name the tunnel `uprightlab-tunnel` and click Save tunnel.
1. Select Docker and copy the command. Add just the token to
1. Click Next and then click Complete Setup. Or click back until you return to the Connectors page. The tunnel should have still been created. We can configure further items once the tunnel is established.

** Note: The token included in the copy command is sensitive and should never be committed to Git Hub.