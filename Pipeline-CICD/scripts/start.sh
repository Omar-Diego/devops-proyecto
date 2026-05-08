#!/bin/bash
# start.sh — Reinicia la aplicación Flask+Redis con docker-compose
set -euo pipefail
APP_PATH='/opt/stf-app/DockerImage\&WebApp/Equipo 1 - ADP - 7. Docker'


echo '[start] Deteniendo servicios previos...'
cd "${APP_PATH}"
docker compose down 2>/dev/null || docker-compose down 2>/dev/null || true


echo '[start] Iniciando servicios con docker-compose...'
docker compose up -d --build 2>/dev/null || docker-compose up -d --build


echo '[start] Servicios iniciados. Estado:'
docker compose ps 2>/dev/null || docker-compose ps
