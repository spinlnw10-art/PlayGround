#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
#  CK-NEXUS AI Stack — Master Installer
# ══════════════════════════════════════════════════════════════
set -euo pipefail
cd "$(dirname "$0")"
STACK_ROOT="$(pwd)"
export STACK_ROOT
export AI_ENV_FILE="${AI_ENV_FILE:-$HOME/.ai-providers.env}"
LOG_DIR="${LOG_DIR:-$STACK_ROOT}"
LOG="$LOG_DIR/cknexus-ai-stack-install-$(date -u +%Y%m%dT%H%M%SZ).log"
exec > >(tee -a "$LOG") 2>&1

C_G="\033[1;32m"; C_B="\033[1;34m"; C_Y="\033[1;33m"; C_N="\033[0m"
say(){ echo -e "${C_B}▶${C_N} $*"; }
ok(){  echo -e "${C_G}✓${C_N} $*"; }
warn(){ echo -e "${C_Y}⚠${C_N} $*"; }

echo "════════════════════════════════════════════════════════════"
echo "  CK-NEXUS AI Stack — Installer"
echo "  $(hostname) @ $(date -u)"
echo "  Root: $STACK_ROOT"
echo "════════════════════════════════════════════════════════════"
echo

say "[1/6] ตรวจสภาพแวดล้อม"
./00-prereq/check.sh | tee /tmp/prereq.out
echo
say "[1b/6] Pre-flight (RAM/Disk/n8n/Swap)"
if ! ./00-prereq/preflight.sh; then
  warn "Pre-flight ไม่ผ่าน — หยุดก่อนเพื่อเลี่ยง downtime"
  warn "ถ้าตั้งใจข้าม: SKIP_PREFLIGHT=1 ./install.sh"
  if [ "${SKIP_PREFLIGHT:-0}" != "1" ]; then
    exit 1
  fi
fi
echo

say "[0/6] Backup .env ก่อน (ถ้ามี)"
if [ -f "$AI_ENV_FILE" ]; then
  cp -a "$AI_ENV_FILE" "${AI_ENV_FILE}.bak-$(date -u +%Y%m%dT%H%M%SZ)"
  ok "backup env แล้ว"
fi

say "[2/6] ตั้งค่า API keys"
if [ -f "$AI_ENV_FILE" ] && [ -s "$AI_ENV_FILE" ]; then
  ok "$AI_ENV_FILE มีอยู่แล้ว — ข้าม"
  echo "  (รัน ./01-env/setup-env.sh ถ้าต้องการเปลี่ยน)"
else
  ./01-env/setup-env.sh
fi
echo

say "[3/6] ติดตั้ง Ollama"
./02-install/01-ollama.sh || warn "Ollama ติดตั้งไม่สมบูรณ์"
echo

say "[4/6] ติดตั้ง Qdrant"
./02-install/02-qdrant.sh || warn "Qdrant ติดตั้งไม่สมบูรณ์"
echo

say "[5/6] ผูก env เข้า n8n"
./02-install/03-n8n-env.sh
echo

say "[6/6] Verify"
./02-install/99-verify.sh
echo

echo "════════════════════════════════════════════════════════════"
ok "ติดตั้งเสร็จ"
echo "════════════════════════════════════════════════════════════"
echo
echo "  Log: $LOG"
echo
echo "  ขั้นถัดไป:"
echo "    1) Import workflows เข้า n8n:"
echo "       $STACK_ROOT/03-workflows/*.json"
echo "    2) ตั้ง Qdrant collection:"
echo "       $STACK_ROOT/04-rag/qdrant-init.sh"
echo "    3) ทดสอบ:"
echo "       $STACK_ROOT/05-clients/cli-chat.sh 'say OK'"
echo "    4) Health:"
echo "       $STACK_ROOT/06-ops/health.sh"
echo
