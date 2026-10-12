#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1090
source "${AI_ENV_FILE:-$HOME/.ai-providers.env}" 2>/dev/null || true
echo "══════ Provider health ══════"

if [ -n "${GEMINI_API_KEY:-}" ]; then
  code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 15 \
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY" \
    -H 'Content-Type: application/json' \
    -d '{"contents":[{"parts":[{"text":"ok"}]}]}')
  printf "gemini : %s\n" "$code"
else echo "gemini : no key"; fi

if [ -n "${GROQ_API_KEY:-}" ]; then
  code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 15 \
    https://api.groq.com/openai/v1/chat/completions \
    -H "Authorization: Bearer $GROQ_API_KEY" -H 'Content-Type: application/json' \
    -d '{"model":"llama-3.3-70b-versatile","messages":[{"role":"user","content":"ok"}],"max_tokens":5}')
  printf "groq   : %s\n" "$code"
else echo "groq   : no key"; fi

if command -v ollama >/dev/null; then
  code=$(curl -sS -o /dev/null -w '%{http_code}' --max-time 30 \
    http://127.0.0.1:11434/api/chat \
    -d '{"model":"llama3.2:3b","messages":[{"role":"user","content":"ok"}],"stream":false}')
  printf "ollama : %s\n" "$code"
else echo "ollama : not installed"; fi

if curl -sS -o /dev/null --max-time 5 http://127.0.0.1:6333/collections; then
  echo "qdrant : OK"
else echo "qdrant : DOWN"; fi

if curl -sS -o /dev/null --max-time 5 http://127.0.0.1:5678/healthz; then
  echo "n8n    : OK"
else echo "n8n    : DOWN"; fi
