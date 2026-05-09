#!/bin/bash
# =============================================================
# verificar_cli.sh
# Verifica y configura la AWS CLI en Cloud9
# Soluciones Tecnológicas del Futuro — Mayo 2026
# =============================================================

set -euo pipefail

echo '=== Verificación de AWS CLI en Cloud9 ==='

# Versión de la CLI
echo '[1] Versión de AWS CLI:'
aws --version

# Configurar región por defecto
echo '[2] Configurando región por defecto: us-east-1'
aws configure set default.region us-east-1
aws configure set default.output json

# Verificar identidad del rol
echo '[3] Identidad del rol activo:'
aws sts get-caller-identity | python3 -m json.tool

# Listar la configuración activa
echo '[4] Configuración activa:'
aws configure list

# Probar acceso listando zonas de disponibilidad
echo '[5] Zonas de disponibilidad disponibles en us-east-1:'
aws ec2 describe-availability-zones \
  --region us-east-1 \
  --query 'AvailabilityZones[*].ZoneName' \
  --output table

echo '=== Autenticación verificada correctamente. ==='