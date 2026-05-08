#!/bin/bash
# =============================================================
# Pipeline-CICD/crear_pipeline.sh
# Crea el pipeline desde CLI (alternativa a la consola web)
# Reemplazar CONNECTION_ARN con el ARN de la conexión de GitHub
# =============================================================

set -euo pipefail
REGION='us-east-1'
BUCKET='devops-equipo1-storage'

# Obtener el ARN del rol del servicio de CodePipeline
ROL_PIPELINE=$(aws iam list-roles \
  --query "Roles[?contains(RoleName,'AWSCodePipelineServiceRole')].Arn | [0]" \
  --output text 2>/dev/null || echo 'REEMPLAZAR_CON_ARN_DEL_ROL')

# ARN de la conexion de GitHub (obtenido en el paso 7.5)
CONNECTION_ARN='arn:aws:codestar-connections:us-east-1:245436971760:connection/REEMPLAZAR'

aws codepipeline create-pipeline \
  --region "${REGION}" \
  --pipeline "{
    \"name\": \"stf-pipeline\",
    \"roleArn\": \"${ROL_PIPELINE}\",
    \"artifactStore\": {
      \"type\": \"S3\",
      \"location\": \"${BUCKET}\"
    },
    \"stages\": [
      {
        \"name\": \"Source\",
        \"actions\": [{
          \"name\": \"Source\",
          \"actionTypeId\": {
            \"category\": \"Source\",
            \"owner\": \"AWS\",
            \"provider\": \"CodeStarSourceConnection\",
            \"version\": \"1\"
          },
          \"configuration\": {
            \"ConnectionArn\": \"${CONNECTION_ARN}\",
            \"FullRepositoryId\": \"Omar-Diego/devops-proyecto\",
            \"BranchName\": \"main\"
          },
          \"outputArtifacts\": [{\"name\": \"SourceArtifact\"}]
        }]
      },
      {
        \"name\": \"Deploy\",
        \"actions\": [{
          \"name\": \"Deploy\",
          \"actionTypeId\": {
            \"category\": \"Invoke\",
            \"owner\": \"AWS\",
            \"provider\": \"Lambda\",
            \"version\": \"1\"
          },
          \"configuration\": {\"FunctionName\": \"stf-deploy\"},
          \"inputArtifacts\": [{\"name\": \"SourceArtifact\"}]
        }]
      }
    ]
  }"

echo 'Pipeline stf-pipeline creado.'
aws codepipeline get-pipeline-state \
  --name stf-pipeline --region us-east-1 \
  --query 'stageStates[*].[stageName,latestExecution.status]' \
  --output table