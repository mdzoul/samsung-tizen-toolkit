#!/usr/bin/env bash
# ==============================================================================
# tv-install.sh - Install a signed .wgt package onto connected Samsung Smart TV
# ==============================================================================
set -euo pipefail

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <signed-package.wgt>"
    exit 1
fi

WGT_FILE="$1"

if [ ! -f "$WGT_FILE" ]; then
    echo "[-] Error: Package file '$WGT_FILE' not found." >&2
    exit 1
fi

if ! command -v sdb &>/dev/null; then
    if [ -x "$HOME/.local/bin/sdb" ]; then
        export PATH="$HOME/.local/bin:$PATH"
    else
        echo "[-] Error: 'sdb' binary not found." >&2
        exit 1
    fi
fi

echo "[*] Checking connected SDB devices..."
DEVICES=$(sdb devices | grep -v "List of devices attached" | grep -v "^$" || true)
if [ -z "$DEVICES" ]; then
    echo "[-] Error: No active SDB device connected. Run scripts/tv-connect.sh first." >&2
    exit 1
fi

echo "[+] Target Device Detected:"
echo "$DEVICES"

echo "[*] Transferring and installing '$WGT_FILE' onto TV..."
sdb install "$WGT_FILE"

echo "[+] Installation complete! Check TV Smart Hub or app launcher."
