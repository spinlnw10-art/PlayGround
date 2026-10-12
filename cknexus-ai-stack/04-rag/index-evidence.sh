#!/usr/bin/env bash
# Index CK-NEXUS evidence → Qdrant
set -euo pipefail
# shellcheck disable=SC1090
source "${AI_ENV_FILE:-$HOME/.ai-providers.env}"
QDRANT=${QDRANT_URL:-http://127.0.0.1:6333}
SRC=${1:-$HOME/cknexus-q10-q16-closure-evidence-20261011T155513Z}

echo "▶ Index จาก $SRC"
[ -d "$SRC" ] || { echo "✗ ไม่พบ $SRC"; exit 1; }

ID=1
find "$SRC" -type f \( -name '*.md' -o -name '*.txt' -o -name '*.json' \) | while read -r f; do
  CONTENT=$(head -c 4000 "$f" | tr '\n' ' ' | sed 's/"/\\"/g')
  [ -z "$CONTENT" ] && continue

  # embed ผ่าน Ollama
  VEC=$(curl -sS "${OLLAMA_BASE_URL}/api/embeddings" \
    -d "{\"model\":\"${EMBED_MODEL}\",\"prompt\":\"$CONTENT\"}" | jq -c '.embedding')

  [ "$VEC" = "null" ] && continue

  curl -sS -X PUT "$QDRANT/collections/cknexus/points" \
    -H 'Content-Type: application/json' \
    -d "{\"points\":[{\"id\":$ID,\"vector\":$VEC,\"payload\":{\"path\":\"$f\",\"preview\":\"${CONTENT:0:200}\"}}]}" \
    >/dev/null

  echo "  ✓ $f"
  ID=$((ID+1))
done
echo "✓ Indexed. ตรวจ: curl $QDRANT/collections/cknexus"
