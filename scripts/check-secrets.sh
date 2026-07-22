#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

allow_local_config=false
if [[ "${1:-}" == "--allow-local-config" ]]; then
    allow_local_config=true
fi

status=0

if [[ -f source/SolarConfig.mc && "$allow_local_config" == false ]]; then
    echo "ERROR: source/SolarConfig.mc exists and is intentionally gitignored."
    echo "Do not include it in a public archive or commit."
    status=1
fi

if grep -RInE \
    --exclude='*.svg' \
    --exclude='*.jpg' \
    --exclude='check-secrets.sh' \
    --exclude-dir='.git' \
    --exclude-dir='bin' \
    --exclude-dir='build' \
    'jjcscedmc|192\.168\.[0-9]+\.[0-9]+|10\.[0-9]+\.[0-9]+\.[0-9]+|172\.(1[6-9]|2[0-9]|3[01])\.[0-9]+\.[0-9]+' \
    .; then
    echo "ERROR: possible personal domain or private IP found."
    status=1
fi

# A real local config is handled above. This catches hard-coded API tokens elsewhere.
if grep -RInE \
    --exclude='SolarConfig.example.mc' \
    --exclude='SolarConfig.mc' \
    --exclude='*.svg' \
    --exclude='*.jpg' \
    --exclude-dir='.git' \
    --exclude-dir='bin' \
    --exclude-dir='build' \
    'const[[:space:]]+API_TOKEN[[:space:]]*=[[:space:]]*"[^"]+"' \
    .; then
    echo "ERROR: hard-coded API token found outside the ignored local config."
    status=1
fi

if [[ $status -eq 0 ]]; then
    echo "No obvious committed secrets or personal endpoints found."
fi

exit $status
