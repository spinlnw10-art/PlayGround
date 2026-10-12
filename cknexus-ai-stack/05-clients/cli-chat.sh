#!/usr/bin/env bash
MSG="${1:-say OK}"
curl -sS -X POST http://127.0.0.1:5678/webhook/free-ai \
  -H 'Content-Type: application/json' \
  -d "{\"message\":\"$MSG\",\"sessionId\":\"cli\"}" | jq .
