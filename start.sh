#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
/usr/bin/time -p mkdir -p dist
/usr/bin/time -p cp -f index.html dist/index.html
/usr/bin/time -p test -f dist/index.html
/usr/bin/time -p mkdir -p "${OPENCODE_WEB_DIR:?OPENCODE_WEB_DIR is not set}"
/usr/bin/time -p bash -c 'printf "%s" "{\"project\":\"$(pwd)\",\"directory\":\"$(pwd)/dist\"}" > "$OPENCODE_WEB_DIR/deployment-output.json"'
/usr/bin/time -p cat "$OPENCODE_WEB_DIR/deployment-output.json"
/usr/bin/time -p python3 -m http.server "${PORT:-3000}" --directory dist
