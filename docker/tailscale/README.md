# Tailscale

This container joins the ThinkCentre to your Tailscale tailnet.

Create a local env file before provisioning:

```sh
cp docker/tailscale/.env.example docker/tailscale/.env
nano docker/tailscale/.env
```

Use a **Tailscale auth key**, not an API key:

```text
TAILSCALE_AUTH_KEY=tskey-auth-...
```

If the logs say this, the value is an API key or another non-device key:

```text
key cannot be used for node auth
CONTROL_API_SCOPE_ALL
```

After changing the key:

```sh
sudo bash scripts/provision.sh services
sudo docker logs tailscale --tail=80
```

When registration succeeds, the machine should appear in the Tailscale dashboard
as `thinkcenter`. After it appears, consider disabling device key expiry for this
server in the dashboard.

The auth key expiration only controls how long the key can register new devices.
It does not disconnect a server that already joined the tailnet.
