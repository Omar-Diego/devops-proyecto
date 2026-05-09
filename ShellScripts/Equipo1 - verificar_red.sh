#!/bin/bash
# =============================================================
# verificar_red.sh
# Verifica la arquitectura de red creada
# Soluciones Tecnológicas del Futuro — Mayo 2026
# =============================================================

REGION='us-east-1'

echo '=== VPCs ==='
aws ec2 describe-vpcs \
  --region "${REGION}" \
  --filters Name=tag:Project,Values=STF-DevOps \
  --query 'Vpcs[*].[VpcId,CidrBlock,State]' \
  --output table

echo '=== Subredes ==='
aws ec2 describe-subnets \
  --region "${REGION}" \
  --filters Name=tag:Project,Values=STF-DevOps \
  --query 'Subnets[*].[SubnetId,CidrBlock,AvailabilityZone,MapPublicIpOnLaunch,Tags[?Key==`Name`].Value|[0]]' \
  --output table

echo '=== Internet Gateways ==='
aws ec2 describe-internet-gateways \
  --region "${REGION}" \
  --filters Name=tag:Project,Values=STF-DevOps \
  --query 'InternetGateways[*].[InternetGatewayId,Attachments[0].State,Tags[?Key==`Name`].Value|[0]]' \
  --output table

echo '=== NAT Gateways ==='
aws ec2 describe-nat-gateways \
  --region "${REGION}" \
  --filter Name=tag:Project,Values=STF-DevOps \
  --query 'NatGateways[*].[NatGatewayId,State,SubnetId]' \
  --output table

echo '=== Tablas de enrutamiento ==='
aws ec2 describe-route-tables \
  --region "${REGION}" \
  --filters Name=tag:Project,Values=STF-DevOps \
  --query 'RouteTables[*].[RouteTableId,Tags[?Key==`Name`].Value|[0]]' \
  --output table