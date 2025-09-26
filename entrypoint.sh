#!/bin/bash
set -euo pipefail

BIN_SDK="/app/CastarSdk_amd64"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $*"
}

# Ensure APPKEY is provided
if [ -z "${APPKEY:-}" ]; then
  log "ERROR: APPKEY environment variable is not set."
  exit 1
fi

# Main supervision loop
while true; do
    log "Starting binary..."
    "$BIN_SDK" -key="$APPKEY" "$@" &
    PID=$!

    # Background sleep timer
    sleep 10800 &
    SLEEP_PID=$!

    # Wait for either the binary or the sleep to finish
    wait -n $PID $SLEEP_PID

    if kill -0 $PID 2>/dev/null; then
        log "time elapsed, killing process $PID"
        kill -TERM $PID
        wait $PID || true
    else
        log "Process exited, restarting..."
    fi

    # Clean up sleep process if still running
    kill $SLEEP_PID 2>/dev/null || true
done
