# =============================================================
# Pipeline-CICD/deploy_handler.py
# Lambda invocada por CodePipeline — etapa Deploy
# Reemplaza CodeBuild (no disponible en esta cuenta)
# Soluciones Tecnológicas del Futuro
# =============================================================
import boto3, json, os, time
from datetime import datetime


REGION   = os.environ.get('AWS_REGION', 'us-east-1')
APP_TAG  = os.environ.get('APP_TAG_NAME', 'DEV-27-instancia')
APP_PATH = os.environ.get('APP_PATH', '/opt/stf-app')


pipeline_client = boto3.client('codepipeline', region_name=REGION)
ssm             = boto3.client('ssm',          region_name=REGION)
ec2             = boto3.client('ec2',          region_name=REGION)




def obtener_instancias():
    resp = ec2.describe_instances(Filters=[
        {'Name':'tag:Name',            'Values':[APP_TAG]},
        {'Name':'instance-state-name', 'Values':['running']}
    ])
    ids = [i['InstanceId'] for r in resp['Reservations'] for i in r['Instances']]
    if not ids:
        raise ValueError(f'No hay instancias corriendo con tag Name={APP_TAG}')
    print(f'[INFO] Instancias: {ids}')
    return ids




def ejecutar_ssm(instance_ids, bucket, key, ts):
    comandos = [
        f'echo "=== Deploy {ts} ==="',
        f'aws s3 cp s3://{bucket}/{key} /tmp/deploy.zip --region {REGION}',
        f'sudo mkdir -p {APP_PATH}',
        f'sudo unzip -o /tmp/deploy.zip -d {APP_PATH}',
        f'sudo chown -R ubuntu:ubuntu {APP_PATH}',
        f'cd {APP_PATH} && [ -f requirements.txt ] && pip3 install -r requirements.txt --quiet || true',
        f'bash {APP_PATH}/Pipeline-CICD/scripts/install.sh  2>&1 || true',
        f'bash {APP_PATH}/Pipeline-CICD/scripts/start.sh    2>&1',
        f'sleep 5',
        f'bash {APP_PATH}/Pipeline-CICD/scripts/healthcheck.sh 2>&1',
        f'echo "Deploy completado: $(date)"'
    ]
    resp = ssm.send_command(
        InstanceIds=instance_ids,
        DocumentName='AWS-RunShellScript',
        Comment=f'Deploy {ts} via CodePipeline',
        Parameters={'commands': comandos},
        TimeoutSeconds=300
    )
    return resp['Command']['CommandId']




def esperar_ssm(command_id, instance_ids, timeout=270):
    inicio = time.time()
    while time.time() - inicio < timeout:
        time.sleep(8)
        ok = []
        for inst in instance_ids:
            try:
                r = ssm.get_command_invocation(CommandId=command_id, InstanceId=inst)
                st = r['Status']
                if st in ('Pending','InProgress','Delayed'):
                    ok.append(False)
                elif st == 'Success':
                    print(f'  [OK] {inst}')
                    ok.append(True)
                else:
                    print(f'  [FAIL] {inst}: {r["StandardErrorContent"][-300:]}')
                    return False
            except Exception:
                ok.append(False)
        if all(ok):
            return True
    return False




def lambda_handler(event, context):
    job_id = event['CodePipeline.job']['id']
    try:
        data    = event['CodePipeline.job']['data']
        s3_loc  = data['inputArtifacts'][0]['location']['s3Location']
        bucket  = s3_loc['bucketName']
        key     = s3_loc['objectKey']
        ts      = datetime.utcnow().strftime('%Y%m%d-%H%M%S')
        print(f'[START] Deploy {ts} | s3://{bucket}/{key}')
        ids   = obtener_instancias()
        cmd   = ejecutar_ssm(ids, bucket, key, ts)
        exito = esperar_ssm(cmd, ids)
        if exito:
            pipeline_client.put_job_success_result(jobId=job_id)
        else:
            pipeline_client.put_job_failure_result(
                jobId=job_id,
                failureDetails={'type':'JobFailed','message':'SSM fallido'}
            )
    except Exception as e:
        print(f'[ERROR] {e}')
        pipeline_client.put_job_failure_result(
            jobId=job_id,
            failureDetails={'type':'JobFailed','message':str(e)[:250]}
        )
