#!/bin/bash
# healthcheck.sh — Verifica que la app Flask responde HTTP 200
set -euo pipefail
PORT=5000
MAX=10
WAIT=3
for i in $(seq 1 $MAX); do
  CODE=$(curl -s -o /dev/null -w '%{http_code}' \
    http://localhost:${PORT}/ 2>/dev/null || echo '000')
  if [ "${CODE}" = '200' ]; then
    echo "[healthcheck] OK — HTTP ${CODE} en intento ${i}"
    exit 0
  fi
  echo "[healthcheck] Intento ${i}/${MAX} — HTTP ${CODE}. Esperando ${WAIT}s..."
  sleep "${WAIT}"
done
echo '[healthcheck] FALLO — la app no responde.'
exit 1
