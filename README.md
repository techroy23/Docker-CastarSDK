## CastarSDK Docker Image

A minimal Alpine based Docker image for running the **CastarSDK**.

## Links
| DockerHub | GitHub | Invite |
|----------|----------|----------|
| [![Docker Hub](https://img.shields.io/badge/ㅤ-View%20on%20Docker%20Hub-blue?logo=docker&style=for-the-badge)](https://hub.docker.com/r/techroy23/docker-castarsdk) | [![GitHub Repo](https://img.shields.io/badge/ㅤ-View%20on%20GitHub-black?logo=github&style=for-the-badge)](https://github.com/techroy23/Docker-CastarSDK) | [![Invite Link](https://img.shields.io/badge/ㅤ-Join%20CastarSDK%20Now-brightgreen?logo=linktree&style=for-the-badge)](https://www.castarsdk.com/register?c=c5b7ba22) |

## Features
- Lightweight Alpine Linux base image.
- Configurable environment variable (`APPKEY`).
- Multi‑arch support: `amd64` and `arm64`.
- Auto‑update support with `--pull=always`.
- Proxy support via Redsocks.

## Usage
- Before running the container, increase socket buffer sizes (required for high‑throughput streaming).
- To make these settings persistent across reboots, add them to /etc/sysctl.conf or a drop‑in file under /etc/sysctl.d/.

```bash
sudo sysctl -w net.core.rmem_max=8000000
sudo sysctl -w net.core.wmem_max=8000000
```

## Environment variables
| Variable | Requirement | Description |
|:--------:|:-----------:|:-----------:|
| via ENV<br />`-e APPKEY=AbCdEfGhIjKLmNo`<br />via ARG<br />`AbCdEfGhIjKLmNo` | Required | Your CastarSDK key. Container exits if not provided. |
| `PROXY` | Optional | External proxy endpoint in the form `host:port`. |

## Run via ENV
```bash
docker run -d \
  --name=castarsdk \
  --cpus=0.25 --pull=always --restart=always \
  --log-driver=json-file --log-opt max-size=1m --log-opt max-file=1 \
  --cap-add=NET_ADMIN --cap-add=NET_RAW --sysctl net.ipv4.ip_forward=1 \
  -e APPKEY=AbCdEfGhIjKLmNo \
  -e PROXY=123.456.789.012:34567 \
  techroy23/docker-castarsdk:latest
```

## Run via ARG
```bash
docker run -d \
  --name=castarsdk \
  --cpus=0.25 --pull=always --restart=always \
  --log-driver=json-file --log-opt max-size=1m --log-opt max-file=1 \
  --cap-add=NET_ADMIN --cap-add=NET_RAW --sysctl net.ipv4.ip_forward=1 \
  -e PROXY=123.456.789.012:34567 \
  techroy23/docker-castarsdk:latest AbCdEfGhIjKLmNo
```

# Invite Link
### https://www.castarsdk.net/register?c=c5b7ba22
