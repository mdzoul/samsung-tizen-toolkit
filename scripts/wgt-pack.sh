#!/usr/bin/env bash
# ==============================================================================
# wgt-pack.sh - Package a modified source directory back into a Tizen .wgt file
# ==============================================================================
set -euo pipefail

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <source-directory> [output-package.wgt]"
    exit 1
fi

SRC_DIR="$1"
OUTPUT_WGT="${2:-}"

if [ ! -d "$SRC_DIR" ]; then
    echo "[-] Error: Directory '$SRC_DIR' does not exist." >&2
    exit 1
fi

if [ ! -f "$SRC_DIR/config.xml" ]; then
    echo "[-] Error: '$SRC_DIR' does not contain a 'config.xml' manifest." >&2
    exit 1
fi

if [ -z "$OUTPUT_WGT" ]; then
    CLEAN_DIR=$(echo "$SRC_DIR" | sed 's/_src$//' | sed 's/\/$//')
    OUTPUT_WGT="${CLEAN_DIR}-modified.wgt"
fi

# Ensure absolute output path so cd works properly
OUTPUT_WGT=$(realpath "$OUTPUT_WGT" 2>/dev/null || echo "$PWD/$OUTPUT_WGT")

echo "[*] Cleaning legacy signature files from '$SRC_DIR' (required for re-signing)..."
rm -f "$SRC_DIR/author-signature.xml" "$SRC_DIR/signature1.xml"

echo "[*] Packaging '$SRC_DIR' into '$OUTPUT_WGT'..."
(
    cd "$SRC_DIR"
    # Create zip without storing extra attributes or hidden OS files
    zip -r -q -9 "$OUTPUT_WGT" . -x "*.git*" "*.DS_Store*" "*Thumbs.db*"
)

echo "[+] Successfully created package: $OUTPUT_WGT ($(du -h "$OUTPUT_WGT" | cut -f1))"
echo "[*] Next Step: Sign this package using your Samsung Developer / Partner certificate"
echo "    profile before pushing via sdb install."
