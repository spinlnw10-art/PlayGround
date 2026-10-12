#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STACK_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TS=$(date -u +%Y%m%dT%H%M%SZ)
OUT_DIR="${BACKUP_DIR:-$HOME}/cknexus-ai-backup-${TS}"
mkdir -p "$OUT_DIR"

# copy config (ไม่รวม keys จริง)
cp -a "$STACK_ROOT" "$OUT_DIR/cknexus-ai-stack" 2>/dev/null || true
cp -a "$HOME/.n8n" "$OUT_DIR/.n8n" 2>/dev/null || true
cp -a /etc/systemd/system/n8n.service.d "$OUT_DIR/n8n.service.d" 2>/dev/null || true
docker exec qdrant tar -czf - /qdrant/storage > "$OUT_DIR/qdrant-storage.tar.gz" 2>/dev/null || true

# report
{
  echo "Backup: $TS"
  echo "Host:   $(hostname)"
  echo "Kernel: $(uname -r)"
  echo "Files:"
  find "$OUT_DIR" -type f | head -50
} > "$OUT_DIR/MANIFEST.txt"

tar czf "${OUT_DIR}.tar.gz" -C "$(dirname "$OUT_DIR")" "$(basename "$OUT_DIR")"
sha256sum "${OUT_DIR}.tar.gz" > "${OUT_DIR}.tar.gz.sha256"
rm -rf "$OUT_DIR"
echo "✓ Backup: ${OUT_DIR}.tar.gz"
