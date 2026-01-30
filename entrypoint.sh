#!/bin/bash
set -e

BIN_SDK="/app/CastarSdk"
IP_CHECKER_URL="https://raw.githubusercontent.com/techroy23/IP-Checker/refs/heads/main/app.sh"
ENABLE_IP_CHECKER="${ENABLE_IP_CHECKER:-false}"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $*"
}

ARG=$1

validate_appkey_input() {
  # Case 1: Neither env var nor positional arg provided
  if [ -z "$APPKEY" ] && [ -z "$ARG" ]; then
    log " >>> An2Kin >>> ERROR: APPKEY not provided (env or arg)."
    log " >>> An2Kin >>> HINT"
    log " >>> An2Kin >>> docker run -d --name=castarsdk -e APPKEY=AbCdEfGhIjKLmNo -e PROXY=123.456.789.012:34567 techroy23/docker-castarsdk:latest"
    log " >>> An2Kin >>> OR"
    log " >>> An2Kin >>> docker run -d --name=castarsdk -e PROXY=123.456.789.012:34567 techroy23/docker-castarsdk:latest AbCdEfGhIjKLmNo"
    log " >>> An2Kin >>> For more details, check the README: https://github.com/techroy23/Docker-CastarSDK"
    exit 1

  # Case 2: Too many positional arguments
  elif [ $# -gt 1 ]; then
    log " >>> An2Kin >>> ERROR: Too many positional arguments. Only one APPKEY argument is allowed."
    exit 1

  # Case 3: Both env var and positional arg provided
  elif [ -n "$APPKEY" ] && [ -n "$ARG" ]; then
    log " >>> An2Kin >>> ERROR: Both APPKEY env and positional argument provided. Please use only one."
    exit 1

  # Case 4: Positional arg provided
  elif [ -n "$ARG" ]; then
    APPKEY="$ARG"
    log " >>> An2Kin >>> INFO: Using APPKEY from positional argument: $APPKEY"

  # Case 5: Env var provided
  else
    log " >>> An2Kin >>> INFO: Using APPKEY from environment: $APPKEY"
  fi

  export APPKEY
}


setup_iptables() {
  log " >>> An2Kin >>> Setting up iptables and redsocks..."
  if ! iptables -t nat -L REDSOCKS -n >/dev/null 2>&1; then
    iptables -t nat -N REDSOCKS
  else
    iptables -t nat -F REDSOCKS
  fi
  iptables -t nat -A REDSOCKS -d 127.0.0.0/8 -j RETURN
  iptables -t nat -A REDSOCKS -d $host -j RETURN
  iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports 12345

  if ! iptables -t nat -C OUTPUT -p tcp -j REDSOCKS 2>/dev/null; then
    iptables -t nat -A OUTPUT -p tcp -j REDSOCKS
  fi
}

cleanup() {
  log " >>> An2Kin >>> Cleaning up iptables and redsocks..."
  iptables -t nat -F REDSOCKS 2>/dev/null || true
  iptables -t nat -D OUTPUT -p tcp -j REDSOCKS 2>/dev/null || true
  iptables -t nat -X REDSOCKS 2>/dev/null || true

  if [ -n "$REDSOCKS_PID" ]; then
    kill "$REDSOCKS_PID" 2>/dev/null || true
  fi
}

setup_proxy() {
  if [ -n "$PROXY" ]; then
    log " >>> An2Kin >>> External routing via proxy: $PROXY"

    host=$(echo "$PROXY" | cut -d: -f1)
    port=$(echo "$PROXY" | cut -d: -f2)

    cat >/etc/redsocks.conf <<EOF
base {
  log_debug = off;
  log_info = off;
  log = "stderr";
  daemon = off;
  redirector = iptables;
}

redsocks {
  local_ip = 0.0.0.0;
  local_port = 12345;
  ip = $host;
  port = $port;
  type = socks5;
}
EOF

    redsocks -c /etc/redsocks.conf >/dev/null 2>&1 &
    REDSOCKS_PID=$!

    setup_iptables
  else
    log " >>> An2Kin >>> Proxy not set, proceeding with direct connection"
  fi
}

check_ip() {
  if [ "$ENABLE_IP_CHECKER" = "true" ]; then
    log " >>> An2Kin >>> Checking current public IP..."
    if curl -fsSL "$IP_CHECKER_URL" | sh; then
      log " >>> An2Kin >>> IP checker script ran successfully"
    else
      log " >>> An2Kin >>> WARNING: Could not fetch or execute IP checker script"
    fi
  else
    log " >>> An2Kin >>> IP checker disabled (ENABLE_IP_CHECKER=$ENABLE_IP_CHECKER)"
  fi
}

main() {
  validate_appkey_input
  trap cleanup EXIT
  while true; do
      setup_proxy
      check_ip
      log " >>> An2Kin >>> Starting binary..."
      "$BIN_SDK" -key="$APPKEY" &
      PID=$!
      log " >>> An2Kin >>> APP PID is $PID"
      wait $PID
      log " >>> An2Kin >>> Process exited, restarting..."
      sleep 5
  done
}

main
