# CnCNet Docker Tunnel Server

This repository contains a Dockerfile to create a [CnCNet](https://cncnet.org/) tunnel server in Docker, using the prebuilt `cncnet-server` binary.

A tunnel server relays game traffic to help players connect to each other for online multiplayer in classic Command & Conquer titles (and other CnCNet-supported games).

[![Build and Publish Docker Image](https://github.com/CnCNet/cncnet-docker-tunnel/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/CnCNet/cncnet-docker-tunnel/actions/workflows/docker-publish.yml)

> [!IMPORTANT]
> **This image is based on the older `cncnet-server` binary and now-deprecated runtimes** — it pulls a build that depends on .NET 6 (end-of-life) and is pinned to Ubuntu 22.04.
>
> For new deployments, use the actively maintained **.NET Core** tunnel instead:
> **[CnCNet/cncnet-docker-dotnetcore-tunnel](https://github.com/CnCNet/cncnet-docker-dotnetcore-tunnel)** (.NET 8/9/10, configurable via environment variables, prebuilt images).
>
> This repo is kept for reference and existing setups.

---

## Quick Start (Prebuilt Image)

The image is automatically built and published to the GitHub Container Registry, so you can pull and run it directly — no need to clone this repo or build anything:

| Image |
| --- |
| `ghcr.io/cncnet/cncnet-docker-tunnel:latest` |

```sh
docker run -d --name my-tunnel-server \
    -p 50000:50000/tcp \
    -p 50000:50000/udp \
    -p 50001:50001/tcp \
    -p 50001:50001/udp \
    -p 8054:8054/udp \
    -p 3478:3478/udp \
    --cap-add=NET_RAW --cap-add=NET_ADMIN \
    --restart unless-stopped \
    ghcr.io/cncnet/cncnet-docker-tunnel:latest
```

Your server will appear in the CnCNet tunnel list under the default name **"My CnCNet tunnel"**. To use your own name (or other options) without rebuilding, override the start command at run time — append it after the image name:

```sh
docker run -d --name my-tunnel-server \
    -p 50000:50000/tcp -p 50000:50000/udp \
    -p 50001:50001/tcp -p 50001:50001/udp \
    -p 8054:8054/udp -p 3478:3478/udp \
    --cap-add=NET_RAW --cap-add=NET_ADMIN \
    --restart unless-stopped \
    ghcr.io/cncnet/cncnet-docker-tunnel:latest \
    ./cncnet-server --name "My Custom Tunnel Name" --maxclients 200 --port 50001 --portv2 50000
```

Prefer to build the image yourself (e.g. to bake in your own tunnel options)? Follow the steps below instead.

---

## Getting Started (Build It Yourself)

### 1. Clone this repo to your server

```sh
git clone https://github.com/CnCNet/cncnet-docker-tunnel.git
cd cncnet-docker-tunnel
```

### 2. (Optional) Edit your tunnel options

The server is launched by the final `CMD` line in the [`dockerfile`](dockerfile). Edit it to set your server name and any other options:

```dockerfile
CMD ./cncnet-server --name "My CnCNet tunnel" --maxclients 200 --port 50001 --portv2 50000 > cncnet-server.log 2>&1 && tail -f cncnet-server.log
```

### 3. Build the Docker image

Replace `my-tunnel-server` with a name that helps you identify your container:

```sh
docker build -t my-tunnel-server .
```

### 4. Run your new container with the below:

```sh
docker run -d --name my-tunnel-server \
    -p 50000:50000/tcp \
    -p 50000:50000/udp \
    -p 50001:50001/tcp \
    -p 50001:50001/udp \
    -p 8054:8054/udp \
    -p 3478:3478/udp \
    --cap-add=NET_RAW --cap-add=NET_ADMIN \
    --restart unless-stopped \
    -v /path/to/host/logs:/logs \
    my-tunnel-server
```

## Tunnel Options

You can edit your `dockerfile` (or the run-time command) to pass extra options to `cncnet-server`. Common options:

| Option | Description | Default |
| --- | --- | --- |
| `--name` | Name shown in the CnCNet tunnel list | `My CnCNet tunnel` |
| `--maxclients` | Maximum number of concurrent clients | `200` |
| `--port` | V2 tunnel port | `50001` |
| `--portv2` | V3 tunnel port | `50000` |

So your `dockerfile` run command may end up looking like:

```dockerfile
CMD ./cncnet-server --name "CnCNet UK | cncnet.org" --maxclients 200 --port 50001 --portv2 50000 > cncnet-server.log 2>&1 && tail -f cncnet-server.log
```

For example, to change the server name shown in the tunnel list.

### Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| 50000 | TCP/UDP | Tunnel V3 |
| 50001 | TCP/UDP | Tunnel V2 |
| 8054 | UDP | P2P / STUN |
| 3478 | UDP | P2P / STUN |

Make sure these ports are open in any firewall or cloud security group in front of your server.

### Using Docker Compose (Optional)

For easier management, you can run the prebuilt image with a `docker-compose.yml`:

```yml
services:
  cncnet:
    image: ghcr.io/cncnet/cncnet-docker-tunnel:latest
    container_name: cncnet-server
    restart: unless-stopped
    command: ./cncnet-server --name "MyTunnel" --maxclients 200 --port 50001 --portv2 50000
    ports:
      - "50000:50000/tcp"
      - "50000:50000/udp"
      - "50001:50001/tcp"
      - "50001:50001/udp"
      - "8054:8054/udp"
      - "3478:3478/udp"
    cap_add:
      - NET_RAW
      - NET_ADMIN
```

Then bring it up with:

```sh
docker compose up -d
```

## Logs

The server writes its output to `/app/cncnet-server.log` inside the container (not to the container's stdout, so `docker logs` will be empty). To view or follow it:

```sh
docker exec my-tunnel-server tail -f /app/cncnet-server.log
```

## Sponsored by

The CnCNet tunnel server software is a CnCNet project. CnCNet is sponsored by DigitalOcean.

<a href="https://www.digitalocean.com/?refcode=337544e2ec7b&utm_campaign=Referral_Invite&utm_medium=opensource&utm_source=CnCNet" title="Powered by Digital Ocean" target="_blank">
    <img src="https://opensource.nyc3.cdn.digitaloceanspaces.com/attribution/assets/PoweredByDO/DO_Powered_by_Badge_blue.svg" width="201px" alt="Powered By Digital Ocean" />
</a>
