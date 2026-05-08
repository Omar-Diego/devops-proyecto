# Proyecto DevOps

[![GitHub license](https://img.shields.io/github/license/Omar-Diego/devops-proyecto)](https://github.com/Omar-Diego/devops-proyecto/blob/develop/LICENSE)
[![Python version](https://img.shields.io/badge/python-3.8%2B-blue)](https://www.python.org/)
[![AWS](https://img.shields.io/badge/AWS-Ready-orange)](https://aws.amazon.com/)

> Un proyecto integral de implementación DevOps usando AWS, Python, Docker y prácticas de CI/CD para la gestión automatizada de infraestructura y generación de reportes de recursos.

---

## 🚀 Descripción del Proyecto

Este proyecto demuestra la implementación de prácticas DevOps en un entorno cloud de AWS. Proporciona scripts de automatización para:

- **Aprovisionamiento de Instancias EC2**: Lanzamiento programático de instancias EC2 de AWS con límites de seguridad
- **Infraestructura como Código (IaC)**: Plantillas CloudFormation para aprovisionamiento automatizado de recursos
- **Reporte de Recursos**: Generación de reportes completos sobre instancias EC2 y buckets S3
- **Contenerización**: Docker y Docker Compose para aplicaciones web con backend Redis
- **Configuración de Entorno**: Instalación automatizada de dependencias de desarrollo
- **Automatización de Tareas**: Programación de tareas cron para la gestión de logs

### Objetivos Clave

- Aprender e implementar principios de Infraestructura como Código (IaC)
- Comprender la interacción con la API de AWS usando Python y Boto3
- Practicar la automatización con scripts de shell
- Establecer patrones de codificación segura (por ejemplo, límites de seguridad para la creación de recursos)
- Implementar contenerización con Docker y Docker Compose

---

## ✨ Características

| Característica              | Descripción                                                                |
| --------------------------- | -------------------------------------------------------------------------- |
| **Aprovisionamiento EC2**   | Creación automatizada de instancias EC2 con límites de seguridad Free Tier |
| **Plantilla CloudFormation** | Plantilla IaC para aprovisionar EC2, S3 y Roles de IAM en AWS             |
| **Reporte de Recursos**     | Genera reportes detallados de recursos EC2 y S3 en AWS                     |
| **Contenedor Docker**      | Imagen Docker multilStage con aplicación Flask y Redis                  |
| **Docker Compose**        | Orquestación de servicios web y base de datos con redes y volúmenes      |
| **Gestión de Dependencias** | Instalación automatizada de herramientas de entorno de desarrollo          |
| **Automatización con Cron** | Tareas programadas para limpieza de logs                                   |
| **Salida Dual**             | Los scripts muestran salida tanto en terminal como en archivos de log      |

---

## 📦 Prerrequisitos

Antes de usar este proyecto, asegúrate de contar con lo siguiente:

### Requisitos del Sistema

- **Sistema Operativo**: Linux (se recomienda Ubuntu/Debian), macOS o Windows con WSL2
- **Git**: Versión 2.x o superior
- **Python**: Versión 3.8 o superior
- **Docker**: Versión 20.x o superior (para contenerización)
- **Docker Compose**: Versión 2.x o superior

### Requisitos de AWS

- Cuenta de AWS (compatible con AWS Learner Lab)
- AWS CLI instalado y configurado
- Credenciales de AWS válidas con permisos adecuados:
  - `ec2:DescribeInstances`
  - `ec2:RunInstances`
  - `s3:ListBuckets`
  - `s3:ListObjects`
  - `cloudformation:*` (si usas plantillas CloudFormation)

### Dependencias de Python

- boto3
- botocore
- python-dateutil
- flask
- redis

---

## 🔧 Instrucciones de Instalación

### 1. Clona el Repositorio

```bash
git clone https://github.com/Omar-Diego/devops-proyecto.git
cd devops-proyecto
```

### 2. Crea un Entorno Virtual de Python

```bash
# Crear entorno virtual
python3 -m venv .venv

# Activar en Linux/macOS
source .venv/bin/activate

# Activar en Windows
.venv\Scripts\activate
```

### 3. Instala las Dependencias de Python

```bash
pip install -r requirements.txt
```

### 4. Configura tus Credenciales de AWS

```bash
aws configure
```

Ingresa tu AWS Access Key ID, Secret Access Key y la región por defecto cuando se te solicite.

**Alternativa**: Usa un archivo de credenciales de AWS o variables de entorno:

```bash
export AWS_ACCESS_KEY_ID="tu_access_key"
export AWS_SECRET_ACCESS_KEY="tu_secret_key"
export AWS_DEFAULT_REGION="us-east-1"
```

### 5. Verifica la Instalación

```bash
python -c "import boto3; print('¡Boto3 instalado correctamente!')"
```

---

## 📖 Guía de Uso

### Aprovisionamiento de Instancias EC2

Lanza instancias EC2 con límites de seguridad automáticos para Free Tier:

```bash
python Equipo1-aprovisionar_ec2.py
```

**Salida esperada:**

```
Instancias activas actualmente: 0
Lanzando nueva instancia EC2...
Instancia lanzada con éxito. ID: i-xxxxxxxxxxxxx
```

### Reporte de Recursos

Genera un reporte completo de tus recursos en AWS:

```bash
python Equipo1-reporte_recursos.py
```

**Ejemplo de salida:**

```
==================================================
REPORTE DE INSTANCIAS EC2
==================================================

Instancia #1
  ID: i-0abcdef1234567890
  Nombre: DEV-27-instancia
  Tipo: t3.micro
  Estado: running
  IP Pública: 54.123.45.67
  Región: us-east-1

Total de instancias: 1

==================================================
REPORTE DE BUCKETS S3
==================================================

  Bucket: mi-bucket
  Creado: 2024-01-15 10:30:00
  Región: us-east-1
  Objetos: 5

Total de buckets: 1
Reporte finalizado.
```

### Instalación de Dependencias del Sistema

Ejecuta el script de instalación para configurar las herramientas de desarrollo:

```bash
chmod +x Equipo1-instalar_dependencias.sh
./Equipo1-instalar_dependencias.sh
```

Este script instala:

- Git
- Vim
- Docker
- Python3 y pip

Y configura una tarea cron diaria para limpieza de logs.

### Automatización de Actualización del Sistema

Ejecuta una actualización simple del sistema:

```bash
chmod +x Equipo1-automatizar.sh
./Equipo1-automatizar.sh
```

---

## ☁️ Plantilla CloudFormation

Esta plantilla aprovisiona recursos de infraestructura en AWS de manera declarativa.

### Recursos Creados

| Recurso                  | Descripción                                                              |
| ------------------------- | -------------------------------------------------------------------------- |
| **Rol de IAM**           | Rol con política AmazonS3ReadOnlyAccess para acceso a S3                 |
| **Perfil de Instancia** | Perfil para asociar el Rol de IAM a la instancia EC2                       |
| **Instancia EC2**        | Instancia EC2 con tipo t3.micro o t3.small                                |
| **Bucket S3**            | Bucket S3 con nombre único basado en el ID de cuenta                      |

### Uso de la Plantilla

#### Desde AWS CLI

```bash
# Crear stack de CloudFormation
aws cloudformation create-stack \
  --stack-name mi-stack-devops \
  --template-body file://CloudFormTemplate/Equipo\ 1\ -\ ADP-\ 6.\ Plantilla\ CloudFormation.yml \
  --parameters ParameterKey=TipoDeInstancia,ParameterValue=t3.micro \
  --region us-east-1
```

#### Desde Console AWS

1. Ve a CloudFormation en AWS Console
2. Crea un nuevo stack
3. Sube el archivo `Plantilla CloudFormation.yml`
4. Especifica los parámetros (TipoDeInstancia)
5. Ejecuta el stack

### Parámetros

| Parámetro        | Tipo    | Default        | Descripción                              |
| ---------------- | ------- | --------------- | ------------------------------------------ |
| TipoDeInstancia  | String  | t3.micro       | Tipo de instancia EC2 (t3.micro/t3.small) |
| AMIId            | String  | Latest AL2023   | ID de la AMI de Amazon Linux 2023         |

### Outputs

| Output              | Descripción                      |
| -------------------- | -------------------------------- |
| EC2IdOutput         | ID de la instancia EC2 creada   |
| BucketNameOutput    | Nombre del bucket S3 creado      |

---

## 🐳 Docker: Imagen y Aplicación Web

Esta sección contiene la configuración de contenedorización con Docker y Docker Compose.

### Estructura

```
DockerImage&WebApp/Equipo 1 - ADP - 7. Docker/
├── docker-compose.yml          # Orquestación de servicios
├── app/
│   ├── app.py                # Aplicación Flask
│   ├── Dockerfile            # Imagen Docker multilStage
│   └── requirements.txt     # Dependencias Python
└── .dockerignore            # Archivos a excluir
```

### Construcción de la Imagen Docker

```bash
cd DockerImage&WebApp/Equipo\ 1\ -\ ADP\ -\ 7.\ Docker
docker build -t mi-app-flask ./app
```

### Ejecución con Docker Compose

```bash
# Iniciar todos los servicios
docker-compose up -d

# Ver logs
docker-compose logs -f

# Detener servicios
docker-compose down
```

### Servicios

| Servicio | Imagen              | Puerto   | Descripción                          |
| -------- | ------------------- | -------- | ------------------------------------- |
| web      | Flask + Redis      | 5000     | Aplicación web con contador de visitas |
| db       | Redis (alpine)     | 6379     | Base de datos para persistencia       |

### Redes

- **frontend**: Red para el servicio web
- **backend**: Red para la base de datos Redis

### Volúmenes

- **redis_data**: Volumen para persistir datos de Redis

### Características de la Imagen Docker

- **Multi-stage Build**: Construcción en dos etapas para optimizar tamaño
- **Entorno Virtual**: Python venv para aislamiento de dependencias
- **Usuario no root**: Ejecución con usuario sin privilegios
- ** slim**: Imagen base ligera python:3.9-slim

### Aplicación Flask

La aplicación web es una API REST simple que:

- Serve en el puerto 5000
- Conecta al servicio Redis (host: `db`, puerto: 6379)
- Mantiene un contador de visitas en Redis
- Retorna JSON con mensaje y número de visitas

**Endpoints:**

| Endpoint | Método | Descripción                    |
| -------- |--------| --------------------------------|
| `/`      | GET    | Retorna mensaje y contador     |

**Ejemplo de uso:**

```bash
# Iniciar servicios
docker-compose up -d

# Probar endpoint
curl http://localhost:5000/

# Respuesta esperada
{"message": "¡Hola!", "visitas": 1}

# Visitas increase con cada request
curl http://localhost:5000/
{"message": "¡Hola!", "visitas": 2}
```

---

## ⚙️ Detalles de Configuración

### Configuración de Aprovisionamiento EC2

Edita `Equipo1-aprovisionar_ec2.py` para personalizar:

```python
# Sección de configuración - modifica estos valores
REGION = "us-east-1"                          # Región de AWS
AMI_ID = "ami-0ea87431b78a82070"              # AMI de Amazon Linux 2023
INSTANCE_TYPE = "t3.micro"                    # Tipo de instancia
KEY_NAME = "DevOps"                           # Nombre de tu Key Pair
SECURITY_GROUP_ID = "sg-0e2082afdea99ed4e"    # ID de tu Security Group
MAX_INSTANCIAS = 3                            # Límite de seguridad Free Tier
```

### Configuración de Reporte de Recursos

Modifica la región en `Equipo1-reporte_recursos.py`:

```python
REGION = "us-east-1"  # Cambia a tu región deseada
```

### Variables de Entorno

Para mayor seguridad, usa variables de entorno en vez de credenciales en el código:

```bash
# Archivo .env (agrega a .gitignore)
AWS_ACCESS_KEY_ID=tu_access_key
AWS_SECRET_ACCESS_KEY=tu_secret_key
AWS_DEFAULT_REGION=us-east-1
```

---

## 📚 Referencia de API

### Módulo de Aprovisionamiento EC2 (`Equipo1-aprovisionar_ec2.py`)

#### Funciones

| Función                                 | Descripción                   | Parámetros                      | Retorna                                     |
| --------------------------------------- | ----------------------------- | ------------------------------- | ------------------------------------------- |
| `contar_instancias_activas(ec2_client)` | Cuenta instancias EC2 activas | `ec2_client`: cliente boto3 EC2 | `int`: Número de instancias activas/pending |
| `aprovisionar_instancia()`              | Lanza una nueva instancia EC2 | Ninguno                         | `None`                                      |

### Módulo de Reporte de Recursos (`Equipo1-reporte_recursos.py`)

#### Funciones

| Función                   | Descripción                             | Parámetros                  | Retorna                                     |
| ------------------------- | --------------------------------------- | --------------------------- | ------------------------------------------- |
| `reporte_ec2(ec2_client)` | Genera reporte de instancias EC2        | `ec2_client`: cliente boto3 | `list`: Lista de diccionarios de instancias |
| `reporte_s3(s3_client)`   | Genera reporte de buckets S3            | `s3_client`: cliente boto3  | `list`: Lista de diccionarios de buckets    |
| `generar_reporte()`       | Función principal para generar reportes | Ninguno                     | `None`                                      |

#### Clase Logger

Redireccionador personalizado de stdout que escribe tanto en terminal como en archivo de log:

```python
class Logger(object):
  def __init__(self, filename="Equipo1-reporte_recursos.log")
  def write(self, message)
  def flush(self)
```

### Script de Instalación (`Equipo1-instalar_dependencias.sh`)

El script realiza:

1. Actualización y mejora de paquetes del sistema
2. Instalación de: git, vim, docker.io, python3, python3-pip
3. Habilitación y arranque del servicio Docker
4. Configuración de tarea cron diaria para limpieza de logs

---

## 📂 Estructura del Proyecto

```
devops-proyecto/
├── README.md                                    # Este archivo
├── requirements.txt                            # Dependencias de Python
├── .gitignore                                  # Reglas de exclusión de Git
│
├── Python Scripts/
│   ├── Equipo1-aprovisionar_ec2.py            # Aprovisionamiento EC2
│   └── Equipo1-reporte_recursos.py           # Reporte de recursos
│
├── Shell Scripts/
│   ├── Equipo1-instalar_dependencias.sh      # Instalador de dependencias
│   └── Equipo1-automatizar.sh                # Script de automatización
│
├── CloudFormTemplate/
│   └── Equipo 1 - ADP- 6. Plantilla CloudFormation.yml  # Plantilla CloudFormation
│
├── DockerImage&WebApp/
│   └── Equipo 1 - ADP - 7. Docker/
│       ├── docker-compose.yml                 # Orquestación Docker Compose
│       ├── .dockerignore                      # Archivos a excluir en Docker
│       └── app/
│           ├── app.py                        # Aplicación Flask
│           ├── Dockerfile                     # Imagen Docker
│           └── requirements.txt             # Dependencias Flask
│
└── Logs/ (generados)
    ├── Equipo1-instalacion_entorno.log
    ├── Equipo1-reporte_recursos.log
    └── Equipo1-ejecucion_cron.log
```

---
## Pipeline CI/CD (Punto 7)

Este proyecto implementa un pipeline de integración y despliegue continuo usando:
- **AWS CodePipeline** como orquestador
- **AWS Lambda** para la lógica de despliegue (sin CodeBuild)
- **AWS Systems Manager** para ejecutar comandos en EC2 sin SSH
- **Amazon CloudWatch + SNS** para rollback automático ante fallos

### Archivos del pipeline

| Archivo | Descripción |
|---------|-------------|
| `Pipeline-CICD/deploy_handler.py` | Lambda de despliegue |
| `Pipeline-CICD/rollback_handler.py` | Lambda de rollback automático |
| `Pipeline-CICD/scripts/install.sh` | Instala dependencias en EC2 |
| `Pipeline-CICD/scripts/start.sh` | Inicia la app con docker-compose |
| `Pipeline-CICD/scripts/healthcheck.sh` | Verifica HTTP 200 |
| `Pipeline-CICD/crear_pipeline.sh` | Crea el pipeline desde CLI |

### Cómo activar un despliegue

```bash
git add .
git commit -m 'feat: descripción del cambio'
git push origin main
```

### Monitorear el estado

```bash
aws codepipeline get-pipeline-state --name stf-pipeline --region us-east-1
```

<p align="center">
  <strong>¡Feliz DevOps! 🚀</strong>
</p>
