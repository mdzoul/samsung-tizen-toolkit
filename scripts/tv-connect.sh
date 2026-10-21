#!/usr/bin/env bash
# ==============================================================================
# tv-connect.sh - Samsung Smart TV SDB Connection & Diagnostics Helper
# ==============================================================================
set -euo pipefail

TV_IP="${1:-${SAMSUNG_TV_IP:-}}"
if [ -z "$TV_IP" ]; then
    read -rp "[?] Enter Samsung Smart TV IP Address (e.g., 192.168.1.100): " TV_IP
    if [ -z "$TV_IP" ]; then
        echo "[-] Error: TV IP address is required." >&2
        echo "    Usage: $0 <TV_IP> or set SAMSUNG_TV_IP environment variable." >&2
        exit 1
    fi
fi
SDB_PORT="${SAMSUNG_SDB_PORT:-26101}"

# Ensure sdb binary is discoverable
if ! command -v sdb &>/dev/null; then
    if [ -x "$HOME/.local/bin/sdb" ]; then
        export PATH="$HOME/.local/bin:$PATH"
    else
        echo "[-] Error: 'sdb' binary not found in PATH or ~/.local/bin/sdb." >&2
        exit 1
    fi
fi

echo "[*] Target Samsung Smart TV: ${TV_IP}:${SDB_PORT}"

# Verify Tailscale route conflicts (if Tailscale is running)
if command -v tailscale &>/dev/null; then
    if tailscale status &>/dev/null; then
        ACCEPT_ROUTES=$(tailscale debug prefs 2>/dev/null | grep -i "RouteAll:" || true)
        if echo "$ACCEPT_ROUTES" | grep -qi "true"; then
            echo "[!] Warning: Tailscale may be intercepting local subnets via route acceptance."
            echo "    If connection times out, run: tailscale set --accept-routes=false"
        fi
    fi
fi

echo "[*] Checking port connectivity to ${TV_IP}:${SDB_PORT}..."
if command -v nc &>/dev/null; then
    if ! nc -z -w 3 "$TV_IP" "$SDB_PORT"; then
        echo "[-] Error: Port ${SDB_PORT} is unreachable on ${TV_IP}."
        echo "    Ensure Developer Mode is ON (sequence: 1 2 3 4 5 on TV Apps screen) and TV was rebooted."
        exit 1
    fi
fi

echo "[*] Connecting SDB to ${TV_IP}:${SDB_PORT}..."
sdb connect "${TV_IP}:${SDB_PORT}"

echo "[*] Active SDB Devices:"
sdb devices
