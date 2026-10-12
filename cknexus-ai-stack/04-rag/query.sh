#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1090
source "${AI_ENV_FILE:-$HOME/.ai-providers.env}"
QDRANT=${QDRANT_URL:-http://127.0.0.1:6333}
Q="${1:-Q10 ปิดอะไร}"

VEC=$(curl -sS "${OLLAMA_BASE_URL}/api/embeddings" \
  -d "{\"model\":\"${EMBED_MODEL}\",\"prompt\":\"$Q\"}" | jq -c '.embedding')

curl -sS -X POST "$QDRANT/collections/cknexus/points/search" \
  -H 'Content-Type: application/json' \
  -d "{\"vector\":$VEC,\"limit\":5,\"with_payload\":true}" | jq '.result[] | {score,path:.payload.path}'
