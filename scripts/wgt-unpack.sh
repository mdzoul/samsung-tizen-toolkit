#!/usr/bin/env bash
# ==============================================================================
# wgt-unpack.sh - Unpack a Samsung Tizen .wgt package for source editing
# ==============================================================================
set -euo pipefail

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <path-to-package.wgt> [output-directory]"
    exit 1
fi

WGT_FILE="$1"
OUTPUT_DIR="${2:-}"

if [ ! -f "$WGT_FILE" ]; then
    echo "[-] Error: File '$WGT_FILE' not found." >&2
    exit 1
fi

BASENAME=$(basename "$WGT_FILE" .wgt)
if [ -z "$OUTPUT_DIR" ]; then
    OUTPUT_DIR="${BASENAME}_src"
fi

echo "[*] Unpacking '$WGT_FILE' into '$OUTPUT_DIR'..."
mkdir -p "$OUTPUT_DIR"
unzip -q -o "$WGT_FILE" -d "$OUTPUT_DIR"

if [ -f "$OUTPUT_DIR/config.xml" ]; then
    echo "[+] Manifest 'config.xml' extracted successfully."
    echo "--- App Summary ---"
    grep -E "<widget|<tizen:application|<name|<tizen:privilege" "$OUTPUT_DIR/config.xml" | head -n 10 || true
    echo "-------------------"
else
    echo "[!] Warning: No 'config.xml' found. This may not be a standard Tizen Web Widget."
fi

echo "[+] Done. You can now inspect and edit the source code in '$OUTPUT_DIR'."
