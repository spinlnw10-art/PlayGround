#!/usr/bin/env bash
set -euo pipefail
echo "══════ สภาพแวดล้อม ══════"
echo "Host:   $(hostname)"
echo "User:   $(whoami)"
echo "Kernel: $(uname -r)"
echo
echo "── CPU ──"
nproc
echo
echo "── RAM ──"
free -h
RAM_MB=$(free -m | awk '/^Mem:/{print $2}')
SWAP_MB=$(free -m | awk '/^Swap:/{print $2}')
echo "RAM: ${RAM_MB}MB  Swap: ${SWAP_MB}MB"
if [ "$RAM_MB" -lt 3500 ]; then
  echo "⚠  RAM < 3.5GB → ข้าม Ollama"
fi
echo
echo "── Disk ──"
df -h "${STACK_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
echo
echo "── Docker ──"
docker --version 2>/dev/null || echo "✗ ไม่มี Docker"
docker ps --format 'table {{.Names}}\t{{.Status}}' 2>/dev/null || true
echo
echo "── Services ──"
for svc in n8n ollama docker postgresql redis-server; do
  st=$(systemctl is-active "$svc" 2>/dev/null || true)
  printf "%-15s : %s\n" "$svc" "${st:-n/a}"
done
echo
echo "── Tools ──"
for t in node npm python3 curl jq git; do
  printf "%-10s : %s\n" "$t" "$(command -v "$t" >/dev/null && $t --version 2>&1 | head -1 || echo 'missing')"
done
