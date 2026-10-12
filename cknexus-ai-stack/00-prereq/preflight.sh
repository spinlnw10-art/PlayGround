#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
#  CK-NEXUS — Pre-flight check (รันก่อน install.sh บน VPS)
#  ตรวจ 4 ข้อ: RAM / Disk / n8n traffic / Swap-OOM risk
#  exit 0 = ผ่าน (มี warn ได้), exit 1 = ไม่ผ่านต้องแก้ก่อน
# ══════════════════════════════════════════════════════════════
set -euo pipefail

C_G="\033[1;32m"; C_Y="\033[1;33m"; C_R="\033[1;31m"; C_N="\033[0m"
ok(){   echo -e "${C_G}✓${C_N} $*"; }
warn(){ echo -e "${C_Y}⚠${C_N} $*"; }
fail(){ echo -e "${C_R}✗${C_N} $*"; }

FAIL=0
ENV_FILE="${AI_ENV_FILE:-$HOME/.ai-providers.env}"

echo "══════ Pre-flight — CK-NEXUS AI Stack ══════"
echo "Host: $(hostname) @ $(date -u)"
echo

# ── 1) RAM ≥ 3.5GB? ──────────────────────────────────────────
RAM_MB=$(free -m | awk '/^Mem:/{print $2}')
if [ "$RAM_MB" -ge 3500 ]; then
  ok "1) RAM ${RAM_MB}MB ≥ 3.5GB — Ollama ได้"
else
  warn "1) RAM ${RAM_MB}MB < 3.5GB — Ollama จะถูก skip, ต้องมี Gemini/Groq key แทน"
  # shellcheck disable=SC1090
  source "$ENV_FILE" 2>/dev/null || true
  if [ -z "${GEMINI_API_KEY:-}${GROQ_API_KEY:-}" ]; then
    fail "   → ไม่มี GEMINI/GROQ key ใน $ENV_FILE — รัน 01-env/setup-env.sh ก่อน"
    FAIL=1
  else
    ok "   → มี cloud key สำรองแล้ว"
  fi
fi

# ── 2) Disk เหลือ ≥ 4GB? ─────────────────────────────────────
# df --output=avail -m ให้เลขเพียวๆ ใช้งานได้ทั้ง / และ /root
AVAIL_MB=$(df -m --output=avail "${STACK_ROOT:-$HOME}" 2>/dev/null | tail -1 | tr -d ' ')
if [ "${AVAIL_MB:-0}" -ge 4096 ]; then
  ok "2) Disk เหลือ ${AVAIL_MB}MB ≥ 4GB"
else
  fail "2) Disk เหลือ ${AVAIL_MB:-?}MB < 4GB — ลบ cknexus-* เก่า หรือขยับ Qdrant storage (QDRANT_DATA_DIR)"
  FAIL=1
fi

# ── 3) n8n active + traffic? (install.sh จะ restart n8n) ─────
if systemctl is-active --quiet n8n 2>/dev/null; then
  warn "3) n8n กำลัง active — install.sh ขั้น [5/6] จะ restart n8n (session ปัจจุบันอาจถูกตัด)"
  # นับ executions ล่าสุดถ้ามี sqlite (best-effort, ไม่ fail ถ้าไม่มี)
  N8N_DB="$HOME/.n8n/database.sqlite"
  if [ -f "$N8N_DB" ] && command -v sqlite3 >/dev/null 2>&1; then
    RECENT=$(sqlite3 "$N8N_DB" "SELECT COUNT(*) FROM execution_entity WHERE startedAt > datetime('now','-15 minutes');" 2>/dev/null || echo "?")
    echo "   executions 15 นาทีล่าสุด: $RECENT"
    if [ "$RECENT" != "0" ] && [ "$RECENT" != "?" ]; then
      warn "   → มี traffic ค้างอยู่ — แนะนำรันนอกเวลาพีค หรือ backup ก่อน"
    fi
  else
    echo "   (ข้ามเช็ค traffic — ไม่มี sqlite3 หรือ DB)"
  fi
else
  ok "3) n8n ไม่ได้ active — restart ไม่มีผลกระทบ"
fi

# ── 4) Swap/OOM risk? ────────────────────────────────────────
read -r _ SWAP_TOTAL SWAP_USED _ < <(free -m | awk '/^Swap:/{print $1,$2,$3,$4,$5}')
SWAP_TOTAL=${SWAP_TOTAL:-0}; SWAP_USED=${SWAP_USED:-0}
if [ "$SWAP_TOTAL" -gt 0 ]; then
  PCT=$(( SWAP_USED * 100 / SWAP_TOTAL ))
  if [ "$PCT" -ge 90 ]; then
    warn "4) Swap ใช้ ${PCT}% (${SWAP_USED}/${SWAP_TOTAL}MB) — เสี่ยง OOM สำหรับ Ollama 3B → ใช้ /brief + cloud providers ไปก่อน"
  else
    ok "4) Swap ใช้ ${PCT}% — ปกติ"
  fi
else
  warn "4) ไม่มี Swap — ถ้า RAM น้อย Ollama 3B อาจ OOM (พิจารณาเพิ่ม swapfile)"
fi

echo
if [ "$FAIL" -eq 0 ]; then
  echo -e "${C_G}Pre-flight ผ่าน — รัน ./install.sh ได้${C_N}"
else
  echo -e "${C_R}Pre-flight ไม่ผ่าน — แก้ข้อ ✗ ก่อนรัน install.sh${C_N}"
  exit 1
fi
