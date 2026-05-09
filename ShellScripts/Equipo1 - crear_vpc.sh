#!/bin/bash
# =============================================================
# crear_vpc.sh
# Crea VPC completa con subredes públicas y privadas
# Soluciones Tecnológicas del Futuro — Mayo 2026
# =============================================================

set -euo pipefail

REGION='us-east-1'
VPC_CIDR='10.0.0.0/16'

tag() {
  local RESOURCE_ID="$1" NAME="$2"
  aws ec2 create-tags \
    --resources "${RESOURCE_ID}" \
    --tags Key=Name,Value="${NAME}" Key=Project,Value=STF-DevOps \
    --region "${REGION}"
}

echo '================================================='
echo ' STF - Creacion de VPC y red'
echo " Region: ${REGION}  CIDR: ${VPC_CIDR}"
echo '================================================='

echo '[1/10] Creando VPC...'
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block "${VPC_CIDR}" \
  --region "${REGION}" \
  --query 'Vpc.VpcId' --output text)
tag "${VPC_ID}" 'stf-vpc'
aws ec2 modify-vpc-attribute --vpc-id "${VPC_ID}" --enable-dns-support --region "${REGION}"
aws ec2 modify-vpc-attribute --vpc-id "${VPC_ID}" --enable-dns-hostnames --region "${REGION}"
echo "VPC: ${VPC_ID}"

echo '[2/10] Creando subred publica us-east-1a...'
SUBNET_PUB_1A=$(aws ec2 create-subnet \
  --vpc-id "${VPC_ID}" --cidr-block 10.0.1.0/24 \
  --availability-zone us-east-1a --region "${REGION}" \
  --query 'Subnet.SubnetId' --output text)
tag "${SUBNET_PUB_1A}" 'stf-subnet-public-1a'
aws ec2 modify-subnet-attribute --subnet-id "${SUBNET_PUB_1A}" --map-public-ip-on-launch --region "${REGION}"

echo '[3/10] Creando subred publica us-east-1b...'
SUBNET_PUB_1B=$(aws ec2 create-subnet \
  --vpc-id "${VPC_ID}" --cidr-block 10.0.2.0/24 \
  --availability-zone us-east-1b --region "${REGION}" \
  --query 'Subnet.SubnetId' --output text)
tag "${SUBNET_PUB_1B}" 'stf-subnet-public-1b'
aws ec2 modify-subnet-attribute --subnet-id "${SUBNET_PUB_1B}" --map-public-ip-on-launch --region "${REGION}"

echo '[4/10] Creando subred privada us-east-1a...'
SUBNET_PRV_1A=$(aws ec2 create-subnet \
  --vpc-id "${VPC_ID}" --cidr-block 10.0.3.0/24 \
  --availability-zone us-east-1a --region "${REGION}" \
  --query 'Subnet.SubnetId' --output text)
tag "${SUBNET_PRV_1A}" 'stf-subnet-private-1a'

echo '[5/10] Creando subred privada us-east-1b...'
SUBNET_PRV_1B=$(aws ec2 create-subnet \
  --vpc-id "${VPC_ID}" --cidr-block 10.0.4.0/24 \
  --availability-zone us-east-1b --region "${REGION}" \
  --query 'Subnet.SubnetId' --output text)
tag "${SUBNET_PRV_1B}" 'stf-subnet-private-1b'

echo '[6/10] Creando Internet Gateway...'
IGW_ID=$(aws ec2 create-internet-gateway \
  --region "${REGION}" \
  --query 'InternetGateway.InternetGatewayId' --output text)
tag "${IGW_ID}" 'stf-igw'
aws ec2 attach-internet-gateway \
  --internet-gateway-id "${IGW_ID}" \
  --vpc-id "${VPC_ID}" --region "${REGION}"
echo "IGW: ${IGW_ID}"

echo '[7/10] Creando Elastic IP y NAT Gateway...'
EIP_ALLOC=$(aws ec2 allocate-address \
  --domain vpc --region "${REGION}" \
  --query 'AllocationId' --output text)
NAT_GW=$(aws ec2 create-nat-gateway \
  --subnet-id "${SUBNET_PUB_1A}" \
  --allocation-id "${EIP_ALLOC}" \
  --region "${REGION}" \
  --query 'NatGateway.NatGatewayId' --output text)
tag "${NAT_GW}" 'stf-nat-gw'
echo "NAT GW: ${NAT_GW}. Esperando disponibilidad..."
aws ec2 wait nat-gateway-available \
  --nat-gateway-ids "${NAT_GW}" --region "${REGION}"
echo 'NAT GW disponible.'

echo '[8/10] Creando tabla de rutas publica...'
RT_PUB=$(aws ec2 create-route-table \
  --vpc-id "${VPC_ID}" --region "${REGION}" \
  --query 'RouteTable.RouteTableId' --output text)
tag "${RT_PUB}" 'stf-rtb-public'
aws ec2 create-route \
  --route-table-id "${RT_PUB}" \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id "${IGW_ID}" --region "${REGION}"
for SUBNET in "${SUBNET_PUB_1A}" "${SUBNET_PUB_1B}"; do
  aws ec2 associate-route-table \
    --route-table-id "${RT_PUB}" \
    --subnet-id "${SUBNET}" --region "${REGION}" > /dev/null
done
echo "Tabla publica: ${RT_PUB}"

echo '[9/10] Creando tabla de rutas privada...'
RT_PRV=$(aws ec2 create-route-table \
  --vpc-id "${VPC_ID}" --region "${REGION}" \
  --query 'RouteTable.RouteTableId' --output text)
tag "${RT_PRV}" 'stf-rtb-private'
aws ec2 create-route \
  --route-table-id "${RT_PRV}" \
  --destination-cidr-block 0.0.0.0/0 \
  --nat-gateway-id "${NAT_GW}" --region "${REGION}"
for SUBNET in "${SUBNET_PRV_1A}" "${SUBNET_PRV_1B}"; do
  aws ec2 associate-route-table \
    --route-table-id "${RT_PRV}" \
    --subnet-id "${SUBNET}" --region "${REGION}" > /dev/null
done
echo "Tabla privada: ${RT_PRV}"

echo ''
echo '[10/10] Resumen de la infraestructura creada:'
echo "  VPC:               ${VPC_ID}  (${VPC_CIDR})"
echo "  Subred publica 1a: ${SUBNET_PUB_1A}  (10.0.1.0/24)"
echo "  Subred publica 1b: ${SUBNET_PUB_1B}  (10.0.2.0/24)"
echo "  Subred privada 1a: ${SUBNET_PRV_1A}  (10.0.3.0/24)"
echo "  Subred privada 1b: ${SUBNET_PRV_1B}  (10.0.4.0/24)"
echo "  Internet GW:       ${IGW_ID}"
echo "  NAT GW:            ${NAT_GW}"
echo "  Tabla rutas pub:   ${RT_PUB}"
echo "  Tabla rutas prv:   ${RT_PRV}"
echo ''
echo '================================================='
echo ' VPC creada exitosamente.'
echo '================================================='