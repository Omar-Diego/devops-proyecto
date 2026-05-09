#!/bin/bash
# =============================================================
# crear_ec2.sh
# Crea una instancia EC2 con LabInstanceProfile
# Límite: máximo 9 instancias simultáneas en Learner Lab
# Soluciones Tecnológicas del Futuro — Mayo 2026
# =============================================================

set -euo pipefail

REGION='us-east-1'
AMI_ID='ami-0c02fb55956c7d316'
INSTANCE_TYPE='t2.micro'
INSTANCE_NAME='STF-App'
SG_NAME='stf-sg-app'

# ── Verificar cuántas instancias hay en ejecución ─────────────
RUNNING=$(aws ec2 describe-instances \
  --region "${REGION}" \
  --filters Name=instance-state-name,Values=running,pending \
  --query 'length(Reservations[*].Instances[*])' \
  --output text)

echo "Instancias activas actualmente: ${RUNNING}"

if [ "${RUNNING}" -ge 9 ]; then
  echo '[ERROR] Límite de 9 instancias alcanzado. Detener o terminar una antes de continuar.'
  exit 1
fi

# ── Obtener el ID del Security Group stf-sg-app ───────────────
SG_ID=$(aws ec2 describe-security-groups \
  --region "${REGION}" \
  --filters Name=group-name,Values="${SG_NAME}" \
  --query 'SecurityGroups[0].GroupId' \
  --output text 2>/dev/null || echo '')

if [ -z "${SG_ID}" ] || [ "${SG_ID}" = 'None' ]; then
  echo '[WARN] Security Group ${SG_NAME} no encontrado. Creándolo...'
  VPC_ID=$(aws ec2 describe-vpcs \
    --region "${REGION}" \
    --filters Name=tag:Name,Values=stf-vpc \
    --query 'Vpcs[0].VpcId' \
    --output text 2>/dev/null || echo 'None')
  if [ "${VPC_ID}" = 'None' ] || [ -z "${VPC_ID}" ]; then
    VPC_ID=$(aws ec2 describe-vpcs \
      --region "${REGION}" \
      --filters Name=isDefault,Values=true \
      --query 'Vpcs[0].VpcId' \
      --output text)
  fi
  SG_ID=$(aws ec2 create-security-group \
    --group-name "${SG_NAME}" \
    --description 'STF App Security Group — sin SSH' \
    --vpc-id "${VPC_ID}" \
    --region "${REGION}" \
    --query 'GroupId' --output text)
  echo "Security Group creado: ${SG_ID}"
fi

# ── Lanzar la instancia ───────────────────────────────────────
echo "Lanzando instancia ${INSTANCE_TYPE} con LabInstanceProfile..."

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "${AMI_ID}" \
  --count 1 \
  --instance-type "${INSTANCE_TYPE}" \
  --iam-instance-profile Name=LabInstanceProfile \
  --security-group-ids "${SG_ID}" \
  --no-associate-public-ip-address \
  --tag-specifications \
    "ResourceType=instance,Tags=[{Key=Name,Value=${INSTANCE_NAME}},{Key=Project,Value=STF-DevOps},{Key=Env,Value=production}]" \
  --metadata-options HttpTokens=required,HttpEndpoint=enabled \
  --region "${REGION}" \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "[OK] Instancia creada: ${INSTANCE_ID}"

# ── Esperar a que la instancia esté running ───────────────────
echo 'Esperando a que la instancia esté en estado running...'
aws ec2 wait instance-running \
  --instance-ids "${INSTANCE_ID}" \
  --region "${REGION}"

echo "[OK] Instancia ${INSTANCE_ID} en estado running."

# ── Verificar estado ─────────────────────────────────────────
aws ec2 describe-instances \
  --instance-ids "${INSTANCE_ID}" \
  --region "${REGION}" \
  --query 'Reservations[0].Instances[0].[InstanceId,InstanceType,State.Name,PrivateIpAddress]' \
  --output table