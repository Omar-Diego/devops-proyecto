#!/bin/bash
# =============================================================
# validar_permisos_labrole.sh
# Valida permisos del LabRole con IAM Policy Simulator
# Soluciones Tecnológicas del Futuro — Mayo 2026
# =============================================================

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
LABROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/LabRole"

echo '=== Validación de permisos del LabRole ==='
echo "Rol: ${LABROLE_ARN}"

# ── Verificar permisos S3 ──────────────────────────────────
echo ''
echo '--- Permisos S3 ---'
aws iam simulate-principal-policy \
  --policy-source-arn "${LABROLE_ARN}" \
  --action-names s3:CreateBucket s3:PutObject s3:GetObject s3:ListBucket s3:DeleteObject \
  --resource-arns 'arn:aws:s3:::*' 'arn:aws:s3:::*/*' \
  --query 'EvaluationResults[*].[EvalActionName,EvalDecision]' \
  --output table

# ── Verificar permisos EC2 ─────────────────────────────────
echo ''
echo '--- Permisos EC2 ---'
aws iam simulate-principal-policy \
  --policy-source-arn "${LABROLE_ARN}" \
  --action-names ec2:RunInstances ec2:DescribeInstances ec2:TerminateInstances \
    ec2:CreateVpc ec2:CreateSubnet ec2:CreateSecurityGroup \
  --resource-arns 'arn:aws:ec2:*:*:instance/*' 'arn:aws:ec2:*:*:*' \
  --query 'EvaluationResults[*].[EvalActionName,EvalDecision]' \
  --output table

# ── Verificar permisos DynamoDB ────────────────────────────
echo ''
echo '--- Permisos DynamoDB ---'
aws iam simulate-principal-policy \
  --policy-source-arn "${LABROLE_ARN}" \
  --action-names dynamodb:CreateTable dynamodb:PutItem dynamodb:GetItem \
    dynamodb:UpdateItem dynamodb:DeleteItem dynamodb:Scan \
  --resource-arns 'arn:aws:dynamodb:*:*:table/*' \
  --query 'EvaluationResults[*].[EvalActionName,EvalDecision]' \
  --output table

# ── Verificar permisos Lambda ──────────────────────────────
echo ''
echo '--- Permisos Lambda ---'
aws iam simulate-principal-policy \
  --policy-source-arn "${LABROLE_ARN}" \
  --action-names lambda:CreateFunction lambda:InvokeFunction \
    lambda:PutFunctionConcurrency lambda:GetFunction \
  --resource-arns 'arn:aws:lambda:*:*:function:*' \
  --query 'EvaluationResults[*].[EvalActionName,EvalDecision]' \
  --output table

echo ''
echo '=== Validación completada. ==='
echo 'Para validación visual, usar: https://policysim.aws.amazon.com/'