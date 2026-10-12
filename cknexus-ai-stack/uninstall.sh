#!/usr/bin/env bash
set -euo pipefail
echo "⚠  ลบ CK-NEXUS AI Stack"
echo "  (ไม่ลบ n8n หรือข้อมูลเดิม)"
read -rp "ยืนยัน? [y/N] " a
[[ "$a" == "y" ]] || exit 0

docker stop qdrant 2>/dev/null && docker rm qdrant 2>/dev/null || true
systemctl stop ollama 2>/dev/null || true
rm -f /etc/systemd/system/n8n.service.d/30-ai-providers.conf
systemctl daemon-reload
echo "✓ ลบแล้ว (config ที่ cknexus-ai-stack/ ยังอยู่)"
