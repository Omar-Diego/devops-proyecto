import boto3

# ================= Configuración =================
REGION = "us-east-1"                        # Cambiar a tu región (es vital que coincida con setup)
AMI_ID = "ami-0ea87431b78a82070"            # Amazon Linux 2023 AMI 2023.11.
INSTANCE_TYPE = "t3.micro"                  # Elegible para Free Tier
KEY_NAME = "DevOps"                         # REEMPLAZAR con el Nombre de tu Key Pair
SECURITY_GROUP_ID = "sg-0e2082afdea99ed4e"  # REEMPLAZAR con el ID de tu Security Group
# =================================================

# Free Tier: se recomienda no superar 1-2 instancias activas simultáneas
MAX_INSTANCIAS = 3

def contar_instancias_activas(ec2_client):
    """Cuenta las instancias EC2 actualmente en estado 'running' o 'pending'."""
    response = ec2_client.describe_instances(
        Filters=[{"Name": "instance-state-name", "Values": ["running", "pending"]}]
    )
    # Explicación: Boto3 devuelve "Reservations", y cada una contiene una lista de "Instances".
    total = sum(len(r["Instances"]) for r in response["Reservations"])
    return total

def aprovisionar_instancia():
    # Inicializa el cliente de EC2 en la región especificada
    ec2 = boto3.client("ec2", region_name=REGION)

    activas = contar_instancias_activas(ec2)
    print(f"Instancias activas actualmente: {activas}")

    # Validación de límite de seguridad implementado para proteger facturación
    if activas >= MAX_INSTANCIAS:
        print(f"Límite de seguridad de Free Tier alcanzado ({MAX_INSTANCIAS} instancia(s)). No se lanzará una nueva instancia.")
        return

    print("Lanzando nueva instancia EC2...")
    try:
        response = ec2.run_instances(
            ImageId=AMI_ID,
            InstanceType=INSTANCE_TYPE,
            KeyName=KEY_NAME,
            SecurityGroupIds=[SECURITY_GROUP_ID],
            MinCount=1,
            MaxCount=1,
            TagSpecifications=[{
                "ResourceType": "instance",
                "Tags": [{"Key": "Name", "Value": "DEV-27-instancia"}]
            }]
        )

        instance_id = response["Instances"][0]["InstanceId"]
        print(f"Instancia lanzada con éxito. ID: {instance_id}")
    except Exception as e:
        print(f"Ocurrió un error al lanzar la instancia: {e}")

if __name__ == "__main__":
    aprovisionar_instancia()