#!/bin/bash
# =============================================================
# inventario_recursos.sh
# Lista todos los recursos activos en la cuenta AWS
# Soluciones Tecnológicas del Futuro — Mayo 2026
# Uso: ./inventario_recursos.sh [> reporte_$(date +%Y%m%d).txt]
# =============================================================

set -euo pipefail
REGION='us-east-1'

header() { echo ''; echo "=== $1 ==="; }

echo '============================================================'
echo '  INVENTARIO DE RECURSOS AWS — Learner Lab'
echo "  Cuenta: $(aws sts get-caller-identity --query Account --output text)"
echo "  Fecha:  $(date '+%Y-%m-%d %H:%M:%S')"
echo "  Región: ${REGION}"
echo '============================================================'

header 'INSTANCIAS EC2'
aws ec2 describe-instances \
  --region "${REGION}" \
  --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' \
  --output table

header 'SECURITY GROUPS'
aws ec2 describe-security-groups \
  --region "${REGION}" \
  --query 'SecurityGroups[*].[GroupId,GroupName,VpcId]' \
  --output table

header 'VPCs'
aws ec2 describe-vpcs \
  --region "${REGION}" \
  --query 'Vpcs[*].[VpcId,CidrBlock,State,Tags[?Key==`Name`].Value|[0]]' \
  --output table

header 'SUBREDES'
aws ec2 describe-subnets \
  --region "${REGION}" \
  --query 'Subnets[*].[SubnetId,CidrBlock,AvailabilityZone,MapPublicIpOnLaunch,Tags[?Key==`Name`].Value|[0]]' \
  --output table

header 'BUCKETS S3'
aws s3 ls

header 'TABLAS DYNAMODB'
aws dynamodb list-tables \
  --region "${REGION}" \
  --output table

header 'FUNCIONES LAMBDA'
aws lambda list-functions \
  --region "${REGION}" \
  --query 'Functions[*].[FunctionName,Runtime,State]' \
  --output table

header 'STACKS CLOUDFORMATION'
aws cloudformation list-stacks \
  --region "${REGION}" \
  --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE ROLLBACK_COMPLETE \
  --query 'StackSummaries[*].[StackName,StackStatus,CreationTime]' \
  --output table

header 'ALARMAS CLOUDWATCH'
aws cloudwatch describe-alarms \
  --region "${REGION}" \
  --query 'MetricAlarms[*].[AlarmName,StateValue,MetricName]' \
  --output table

header 'PIPELINES CODEPIPELINE'
aws codepipeline list-pipelines \
  --region "${REGION}" \
  --query 'pipelines[*].[name,updated]' \
  --output table 2>/dev/null || echo 'Sin pipelines.'

echo ''
echo '============================================================'
echo '  Reporte completado.'
echo '============================================================'