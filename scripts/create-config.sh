#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXAMPLE="$ROOT_DIR/config/SolarConfig.example.mc"
TARGET="$ROOT_DIR/source/SolarConfig.mc"

if [[ -e "$TARGET" && "${1:-}" != "--force" ]]; then
    echo "Refusing to overwrite $TARGET"
    echo "Run '$0 --force' to replace it with the example configuration."
    exit 1
fi

cp "$EXAMPLE" "$TARGET"
chmod 600 "$TARGET"

echo "Created source/SolarConfig.mc"
echo "Edit API_URL and API_TOKEN before building."
