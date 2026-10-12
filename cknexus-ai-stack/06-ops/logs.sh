#!/usr/bin/env bash
echo "══════ n8n (last 30) ══════"
journalctl -u n8n -n 30 --no-pager 2>/dev/null | tail -30
echo
echo "══════ ollama (last 20) ══════"
journalctl -u ollama -n 20 --no-pager 2>/dev/null | tail -20
echo
echo "══════ qdrant (last 20) ══════"
docker logs --tail 20 qdrant 2>&1 | tail -20
