# DevOps Proyecto

> Proyecto de implementación de prácticas DevOps utilizando AWS, Docker, Python y CI/CD.

---

## Descripción

Este repositorio contiene la infraestructura, scripts y pipelines necesarios para implementar
un flujo de trabajo DevOps completo, incluyendo:

- Aprovisionamiento de infraestructura con **AWS CloudFormation**
- Automatización con **Python y Boto3**
- Containerización con **Docker**
- Pipeline CI/CD con **AWS CodePipeline**
- Monitoreo con **AWS CloudWatch**

---

## Prerrequisitos

- Git 2.x+
- Python 3.8+
- Docker 20.x+
- AWS CLI configurado
- Cuenta en AWS (Learner Lab)

---

## Ramas

| Rama        | Propósito                                           |
| ----------- | --------------------------------------------------- |
| `main`      | Código en producción — protegida, solo merge via PR |
| `develop`   | Integración de features — protegida, requiere PR    |
| `feature/*` | Desarrollo de nuevas funcionalidades                |

---