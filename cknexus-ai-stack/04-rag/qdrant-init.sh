#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1090
source "${AI_ENV_FILE:-$HOME/.ai-providers.env}" 2>/dev/null || true
QDRANT=${QDRANT_URL:-http://127.0.0.1:6333}

# สร้าง collection (768 dims สำหรับ nomic-embed-text)
curl -sS -X PUT "$QDRANT/collections/cknexus" \
  -H 'Content-Type: application/json' \
  -d '{"vectors":{"size":768,"distance":"Cosine"}}' | head -c 200
echo
echo "── Collections ──"
curl -sS "$QDRANT/collections" | jq . 2>/dev/null || curl -sS "$QDRANT/collections"
