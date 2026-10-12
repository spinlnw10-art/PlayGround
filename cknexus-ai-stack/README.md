# CK-NEXUS AI Stack

ระบบผู้ช่วย AI ฟรี 100% — self-hosted บน VPS
ใช้ n8n + Ollama + Gemini + Groq + Qdrant

## Quick Start

    cd cknexus-ai-stack
    ./install.sh

> บน VPS ใช้ path `/root/cknexus-ai-stack` — ใน repo นี้ใช้ relative path ได้เลย
> scripts จะ resolve `STACK_ROOT` อัตโนมัติ และใช้ `$HOME/.ai-providers.env` เก็บ keys (mode 600)

## โครงสร้าง

- 00-prereq/   ตรวจสภาพแวดล้อม
- 01-env/      จัดการ API keys
- 02-install/  ติดตั้ง services
- 03-workflows/ n8n workflows (import เข้า n8n)
- 04-rag/      Qdrant + embeddings
- 05-clients/  CLI tools + IDE config
- 06-ops/      health, backup, logs

## Services

| Service  | Port        | คำสั่ง |
|----------|-------------|--------|
| n8n      | 5678        | systemctl status n8n |
| Ollama   | 11434       | systemctl status ollama |
| Qdrant   | 6333        | docker logs qdrant |

## คำสั่งบ่อย

    ./06-ops/health.sh                 # ตรวจทุก service
    ./05-clients/cli-chat.sh "สวัสดี"  # chat ผ่าน webhook
    ./06-ops/backup.sh                 # backup stack
    ./06-ops/logs.sh                   # ดู log รวม

## Provider fallback

gemini → groq → ollama (อัตโนมัติ)

## ลิงก์

- n8n:    http://127.0.0.1:5678  (SSH tunnel)
- Qdrant: http://127.0.0.1:6333/dashboard

## ค่าใช้จ่าย

| Component | Cost |
|-----------|------|
| n8n (self-hosted) | ฟรี |
| Ollama | ฟรี |
| Gemini free tier | ฟรี 1,500/วัน |
| Groq free tier | ฟรี 14,400/วัน |
| Qdrant (Docker) | ฟรี |
| Continue.dev | ฟรี |
| **รวม** | **0 บาท** |
