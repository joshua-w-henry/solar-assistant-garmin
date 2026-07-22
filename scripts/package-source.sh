#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_NAME="$(basename "$ROOT_DIR")"
OUTPUT="${1:-$ROOT_DIR/../${REPO_NAME}-source.zip}"

"$ROOT_DIR/scripts/check-secrets.sh" --allow-local-config

cd "$(dirname "$ROOT_DIR")"
rm -f "$OUTPUT"
zip -r "$OUTPUT" "$REPO_NAME" \
    -x "*/.git/*" \
       "*/bin/*" \
       "*/build/*" \
       "*/source/SolarConfig.mc" \
       "*.prg" "*.iq" "*.key" "*.der" "*.pem" "*.p12" "*.pfx"

echo "Created $OUTPUT"
