#!/bin/bash
# =============================================================
# conectar_ssm.sh
# Conecta a instancias EC2 via AWS Systems Manager
# Sin SSH, sin puerto 22, sin llaves PEM
# Soluciones Tecnológicas del Futuro — Mayo 2026
# =============================================================

set -euo pipefail

REGION='us-east-1'
APP_TAG='STF-App'

# ── Obtener el ID de la primera instancia activa con el tag ───
INSTANCE_ID=$(aws ec2 describe-instances \
  --region "${REGION}" \
  --filters \
    Name=tag:Name,Values="${APP_TAG}" \
    Name=instance-state-name,Values=running \
  --query 'Reservations[0].Instances[0].InstanceId' \
  --output text)

if [ -z "${INSTANCE_ID}" ] || [ "${INSTANCE_ID}" = 'None' ]; then
  echo '[ERROR] No se encontró ninguna instancia ${APP_TAG} en estado running.'
  exit 1
fi

echo "Instancia encontrada: ${INSTANCE_ID}"

# ── Verificar que SSM Agent está disponible en la instancia ───
echo 'Verificando disponibilidad del SSM Agent...'
SSM_PING=$(aws ssm describe-instance-information \
  --region "${REGION}" \
  --filters Key=InstanceIds,Values="${INSTANCE_ID}" \
  --query 'InstanceInformationList[0].PingStatus' \
  --output text 2>/dev/null || echo 'Unknown')

echo "Estado del SSM Agent: ${SSM_PING}"

if [ "${SSM_PING}" != 'Online' ]; then
  echo '[WARN] El SSM Agent no está en línea aún. Esperando 30 segundos...'
  sleep 30
fi

# ── Iniciar sesión SSM interactiva ────────────────────────────
echo "Abriendo sesión SSM en ${INSTANCE_ID}..."
aws ssm start-session \
  --target "${INSTANCE_ID}" \
  --region "${REGION}"

# ── Ejecutar un comando remoto sin sesión interactiva ─────────
# Descomentar para ejecutar comandos sin abrir shell:
# aws ssm send-command \
#   --instance-ids "${INSTANCE_ID}" \
#   --document-name 'AWS-RunShellScript' \
#   --parameters 'commands=["whoami","uptime","df -h"]' \
#   --region "${REGION}" \
#   --query 'Command.CommandId' --output text