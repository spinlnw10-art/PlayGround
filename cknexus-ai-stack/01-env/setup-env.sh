#!/usr/bin/env bash
set -euo pipefail
# ENV เก็บที่ $HOME เพื่อรองรับทั้ง VPS (/root) และ dev machine
ENV_FILE="${AI_ENV_FILE:-$HOME/.ai-providers.env}"

echo "══════ ตั้งค่า AI Providers ══════"
echo "Gemini:     https://aistudio.google.com/app/apikey"
echo "Groq:       https://console.groq.com/keys"
echo "OpenRouter: https://openrouter.ai/keys  (optional)"
echo

read -rsp "GEMINI_API_KEY (Enter=skip): "     GEMINI_API_KEY;     echo
read -rsp "GROQ_API_KEY (Enter=skip): "       GROQ_API_KEY;       echo
read -rsp "OPENROUTER_API_KEY (Enter=skip): " OPENROUTER_API_KEY; echo

GEMINI_API_KEY=${GEMINI_API_KEY//[[:space:]]/}
GROQ_API_KEY=${GROQ_API_KEY//[[:space:]]/}
OPENROUTER_API_KEY=${OPENROUTER_API_KEY//[[:space:]]/}

install -m 600 /dev/null "$ENV_FILE"
{
  echo "# AI Providers — $(date -u)"
  [[ -n $GEMINI_API_KEY     ]] && echo "GEMINI_API_KEY=$GEMINI_API_KEY"
  [[ -n $GROQ_API_KEY       ]] && echo "GROQ_API_KEY=$GROQ_API_KEY"
  [[ -n $OPENROUTER_API_KEY ]] && echo "OPENROUTER_API_KEY=$OPENROUTER_API_KEY"
  echo "OLLAMA_BASE_URL=http://127.0.0.1:11434"
  echo "OLLAMA_MODEL=llama3.2:3b"
  echo "EMBED_MODEL=nomic-embed-text"
  echo "QDRANT_URL=http://127.0.0.1:6333"
  echo "AI_PRIMARY=gemini"
  echo "AI_FALLBACK_1=groq"
  echo "AI_FALLBACK_2=ollama"
} > "$ENV_FILE"
chmod 600 "$ENV_FILE"

echo "✓ บันทึก $ENV_FILE ($(stat -c '%A %s' "$ENV_FILE"))"
