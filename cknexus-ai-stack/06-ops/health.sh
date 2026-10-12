#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STACK_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck disable=SC1090
source "${AI_ENV_FILE:-$HOME/.ai-providers.env}" 2>/dev/null || true
echo "══════ CK-NEXUS AI Stack — Health ══════"
echo "Time: $(date -u)"
echo "Root: $STACK_ROOT"
echo
echo "── systemd ──"
for s in n8n ollama docker; do
  st=$(systemctl is-active "$s" 2>/dev/null || true)
  printf "%-10s : %s\n" "$s" "${st:-n/a}"
done
echo
echo "── docker ──"
docker ps --format 'table {{.Names}}\t{{.Status}}' 2>/dev/null | grep -E 'qdrant|trypost' || echo "(none)"
echo
echo "── endpoints ──"
printf "n8n healthz   : %s\n" "$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 http://127.0.0.1:5678/healthz || echo DOWN)"
printf "ollama        : %s\n" "$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 http://127.0.0.1:11434/api/tags || echo DOWN)"
printf "qdrant        : %s\n" "$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 http://127.0.0.1:6333/collections || echo DOWN)"
echo
echo "── providers ──"
"$STACK_ROOT/02-install/99-verify.sh" 2>/dev/null || true
echo
echo "── disk ──"
df -h "$STACK_ROOT" | tail -1
echo
echo "── RAM ──"
free -h | grep -E 'Mem|Swap'
