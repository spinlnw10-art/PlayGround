#!/usr/bin/env bash
set -euo pipefail
if docker ps --format '{{.Names}}' | grep -q '^qdrant$'; then
  echo "✓ Qdrant already running"
else
  mkdir -p "${QDRANT_DATA_DIR:-$HOME/qdrant_data}"
  docker run -d --name qdrant --restart unless-stopped \
    -p 127.0.0.1:6333:6333 \
    -v "${QDRANT_DATA_DIR:-$HOME/qdrant_data}:/qdrant/storage" \
    qdrant/qdrant:latest
  sleep 3
fi
docker ps --format 'table {{.Names}}\t{{.Status}}' | grep qdrant
curl -s http://127.0.0.1:6333/collections | head -c 200; echo
echo "✓ Qdrant: http://127.0.0.1:6333"
