#!/bin/bash
# =============================================================
# configurar_security_groups.sh
# Crea Security Groups con acceso mínimo requerido
# Principio: denegar todo, permitir solo lo necesario
# Soluciones Tecnológicas del Futuro — Mayo 2026
# =============================================================

set -euo pipefail

REGION='us-east-1'
VPC_ID=$(aws ec2 describe-vpcs \
  --region "${REGION}" \
  --filters Name=tag:Name,Values=stf-vpc \
  --query 'Vpcs[0].VpcId' \
  --output text 2>/dev/null)

[ -z "${VPC_ID}" ] || [ "${VPC_ID}" = 'None' ] && \
  VPC_ID=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true --query 'Vpcs[0].VpcId' --output text)

echo "VPC objetivo: ${VPC_ID}"

# ── SG 1: Capa web (acepta HTTPS desde internet) ─────────────
echo '[1/3] Creando SG para capa web (HTTPS solamente)...'
SG_WEB=$(aws ec2 create-security-group \
  --group-name stf-sg-web \
  --description 'STF Web tier — HTTPS solo' \
  --vpc-id "${VPC_ID}" \
  --region "${REGION}" \
  --query 'GroupId' --output text)

aws ec2 authorize-security-group-ingress \
  --group-id "${SG_WEB}" \
  --protocol tcp --port 443 --cidr 0.0.0.0/0 \
  --region "${REGION}"
echo "SG Web: ${SG_WEB} — HTTPS/443 habilitado"

# ── SG 2: Capa aplicación (acepta solo desde SG web) ─────────
echo '[2/3] Creando SG para capa de aplicación...'
SG_APP=$(aws ec2 create-security-group \
  --group-name stf-sg-app \
  --description 'STF App tier — solo desde SG web' \
  --vpc-id "${VPC_ID}" \
  --region "${REGION}" \
  --query 'GroupId' --output text)

aws ec2 authorize-security-group-ingress \
  --group-id "${SG_APP}" \
  --protocol tcp --port 8080 \
  --source-group "${SG_WEB}" \
  --region "${REGION}"
echo "SG App: ${SG_APP} — 8080 desde ${SG_WEB}"

# ── SG 3: SSM (sin reglas de entrada — SSM no necesita puerto) ─
echo '[3/3] Creando SG para instancias SSM...'
SG_SSM=$(aws ec2 create-security-group \
  --group-name stf-sg-ssm \
  --description 'STF SSM — sin puerto SSH, sin inbound' \
  --vpc-id "${VPC_ID}" \
  --region "${REGION}" \
  --query 'GroupId' --output text)

aws ec2 authorize-security-group-egress \
  --group-id "${SG_SSM}" \
  --protocol tcp --port 443 --cidr 0.0.0.0/0 \
  --region "${REGION}" 2>/dev/null || true
echo "SG SSM: ${SG_SSM} — sin SSH, solo salida 443 para SSM Agent"

echo ''
echo '=== Security Groups creados:'
aws ec2 describe-security-groups \
  --group-ids "${SG_WEB}" "${SG_APP}" "${SG_SSM}" \
  --region "${REGION}" \
  --query 'SecurityGroups[*].[GroupId,GroupName,Description]' \
  --output table