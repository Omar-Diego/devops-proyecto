import boto3
from datetime import datetime

REGION = "us-east-1"  # Cambia según tu región configurada en AWS

def reporte_ec2(ec2_client):
    print("\n" + "="*50)
    print("REPORTE DE INSTANCIAS EC2")
    print("="*50)

    response = ec2_client.describe_instances()
    instancias = []

    for reserva in response["Reservations"]:
        for inst in reserva["Instances"]:
            nombre = next(
                (tag["Value"] for tag in inst.get("Tags", []) if tag["Key"] == "Name"),
                "Sin nombre"
            )
            instancias.append({
                "ID": inst["InstanceId"],
                "Nombre": nombre,
                "Tipo": inst["InstanceType"],
                "Estado": inst["State"]["Name"],
                "IP Pública": inst.get("PublicIpAddress", "N/A"),
                "Región": REGION
            })

    if not instancias:
        print("No se encontraron instancias EC2.")
    else:
        for i, inst in enumerate(instancias, 1):
            print(f"\nInstancia #{i}")
            for clave, valor in inst.items():
                print(f"  {clave}: {valor}")

    print(f"\nTotal de instancias: {len(instancias)}")
    return instancias

def reporte_s3(s3_client):
    print("\n" + "="*50)
    print("REPORTE DE BUCKETS S3")
    print("="*50)

    response = s3_client.list_buckets()
    buckets = response.get("Buckets", [])

    if not buckets:
        print("No se encontraron buckets S3.")
    else:
        for bucket in buckets:
            nombre = bucket["Name"]
            creado = bucket["CreationDate"].strftime("%Y-%m-%d %H:%M:%S")

            try:
                loc = s3_client.get_bucket_location(Bucket=nombre)
                region = loc.get("LocationConstraint") or "us-east-1"
            except Exception:
                region = "No disponible"

            try:
                objetos = s3_client.list_objects_v2(Bucket=nombre)
                cantidad = objetos.get("KeyCount", 0)
                objetos_lista = [obj["Key"] for obj in objetos.get("Contents", [])]
            except Exception:
                cantidad = 0
                objetos_lista = []

            print(f"\n  Bucket: {nombre}")
            print(f"  Creado: {creado}")
            print(f"  Región: {region}")
            print(f"  Objetos: {cantidad}")
            if objetos_lista:
                for obj in objetos_lista[:5]:
                    print(f"    - {obj}")
                if cantidad > 5:
                    print(f"    ... y {cantidad - 5} más.")

    print(f"\nTotal de buckets: {len(buckets)}")
    return buckets

def generar_reporte():
    print(f"\nReporte generado el: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    # Inicializando clientes de Boto3 para EC2 y S3
    ec2 = boto3.client("ec2", region_name=REGION)
    s3 = boto3.client("s3", region_name=REGION)

    reporte_ec2(ec2)
    reporte_s3(s3)

    print("\nReporte finalizado.")

if __name__ == "__main__":
    generar_reporte()
