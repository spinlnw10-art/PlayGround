#!/usr/bin/env bash
set -euo pipefail
RAM_MB=$(free -m | awk '/^Mem:/{print $2}')
if [ "$RAM_MB" -lt 3500 ]; then
  echo "⚠  RAM ${RAM_MB}MB < 3.5GB — ข้าม Ollama"
  exit 0
fi
if command -v ollama >/dev/null 2>&1; then
  echo "✓ Ollama มีอยู่แล้ว: $(ollama --version 2>&1 | head -1)"
else
  echo "▶ ติดตั้ง Ollama..."
  curl -fsSL https://ollama.com/install.sh | sh
fi
systemctl enable --now ollama
sleep 3
systemctl is-active ollama && echo "✓ ollama active"
echo "▶ ดึงโมเดล..."
ollama pull llama3.2:3b      || echo "⚠  pull llama3.2:3b ล้มเหลว"
ollama pull nomic-embed-text || echo "⚠  pull nomic-embed-text ล้มเหลว"
ollama list
