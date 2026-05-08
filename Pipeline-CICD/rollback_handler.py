# =============================================================
# Pipeline-CICD/rollback_handler.py
# Lambda de rollback — invocada por SNS ante alarma CloudWatch
# Concurrencia reservada: 10 (configurar en consola Lambda)
# Soluciones Tecnológicas del Futuro
# =============================================================
import boto3, json, os, time
from datetime import datetime


REGION    = os.environ.get('AWS_REGION', 'us-east-1')
S3_BUCKET = os.environ.get('S3_BUCKET', 'devops-equipo1-storage')
APP_TAG   = os.environ.get('APP_TAG_NAME', 'Servidor-Produccion')
APP_PATH  = os.environ.get('APP_PATH', '/opt/stf-app')


ec2 = boto3.client('ec2', region_name=REGION)
ssm = boto3.client('ssm', region_name=REGION)
s3  = boto3.client('s3',  region_name=REGION)




def version_anterior():
    pag  = s3.get_paginator('list_objects_v2')
    objs = []
    for page in pag.paginate(Bucket=S3_BUCKET, Prefix='pipeline-artifacts/'):
        for o in page.get('Contents', []):
            if o['Key'].endswith('.zip'):
                objs.append(o)
    objs.sort(key=lambda x: x['LastModified'], reverse=True)
    if len(objs) < 2:
        raise ValueError('No hay version anterior para rollback')
    return objs[1]['Key']




def instancias():
    resp = ec2.describe_instances(Filters=[
        {'Name':'tag:Name',            'Values':[APP_TAG]},
        {'Name':'instance-state-name', 'Values':['running']}
    ])
    return [i['InstanceId'] for r in resp['Reservations'] for i in r['Instances']]




def ejecutar_rollback(ids, s3_key, ts):
    cmds = [
        f'echo "=== ROLLBACK a {s3_key} ==="',
        f'aws s3 cp s3://{S3_BUCKET}/{s3_key} /tmp/rollback.zip --region {REGION}',
        f'sudo unzip -o /tmp/rollback.zip -d {APP_PATH}',
        f'sudo chown -R ubuntu:ubuntu {APP_PATH}',
        f'bash {APP_PATH}/Pipeline-CICD/scripts/start.sh 2>&1',
        'sleep 5',
        f'bash {APP_PATH}/Pipeline-CICD/scripts/healthcheck.sh 2>&1',
        f'echo "Rollback completado: $(date)"'
    ]
    resp = ssm.send_command(
        InstanceIds=ids,
        DocumentName='AWS-RunShellScript',
        Comment=f'Rollback {ts}',
        Parameters={'commands': cmds},
        TimeoutSeconds=300
    )
    return resp['Command']['CommandId']




def lambda_handler(event, context):
    ts = datetime.utcnow().isoformat()
    print(f'[ROLLBACK START] {ts}')
    try:
        key = version_anterior()
        ids = instancias()
        if not ids:
            raise ValueError('Sin instancias activas')
        cmd = ejecutar_rollback(ids, key, ts)
        print(f'[OK] Rollback enviado: {cmd}')
        return {'statusCode':200,'body':json.dumps({'key':key,'ids':ids,'cmd':cmd})}
    except Exception as e:
        print(f'[ERROR] {e}')
        return {'statusCode':500,'body':str(e)}