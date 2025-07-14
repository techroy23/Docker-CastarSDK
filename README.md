# Castar SDK Docker Image 🐳

Minimal Alpine Linux based Docker image to run the Castar SDK with a configurable API key.

## Features ✨
- Lightweight Alpine Linux base image
- Installs only necessary packages (curl, unzip)
- Downloads and unpacks the Castar SDK binary at build time
- Marks the SDK binary as executable
- Single environment variable configuration

## Prerequisites ⚙️
- Docker engine

## Usage 🚀
  ```bash
  docker run --rm \
    -e APPKEY=YOUR_CASTAR_SDK_KEY \
    ghcr.io/techroy23/docker-castarsdk:latest
  ```
