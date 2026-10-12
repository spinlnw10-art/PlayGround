#!/usr/bin/env bash
set -euo pipefail
mkdir -p /etc/systemd/system/n8n.service.d
cat > /etc/systemd/system/n8n.service.d/30-ai-providers.conf <<CONF
[Service]
EnvironmentFile=-${AI_ENV_FILE:-/root/.ai-providers.env}
CONF
systemctl daemon-reload
if systemctl is-active --quiet n8n; then
  systemctl restart n8n
  sleep 5
fi
echo "✓ n8n=$(systemctl is-active n8n)"
echo "── env ที่ n8n เห็น ──"
PID=$(pgrep -f 'n8n start' | head -1 || true)
if [ -n "$PID" ]; then
  tr '\0' '\n' < /proc/"$PID"/environ | grep -E 'GEMINI|GROQ|OLLAMA|QDRANT' | sed 's/=.*/=***/'
fi
