#!/bin/bash
# install.sh — Instala dependencias de la aplicación en EC2 (Ubuntu)
set -euo pipefail
APP_PATH='/opt/stf-app'
echo '[install] Verificando dependencias Python...'
cd "${APP_PATH}"
if [ -f requirements.txt ]; then
  pip3 install -r requirements.txt --quiet
  echo '[install] Dependencias instaladas.'
else
  echo '[install] No hay requirements.txt — omitiendo.'
fi