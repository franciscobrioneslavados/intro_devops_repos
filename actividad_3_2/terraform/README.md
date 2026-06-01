# Arquitectura como Codigo (IaC) - Actividad 3.2

Este directorio centraliza la infraestructura de la Actividad 3.2, automatizando la transicion de despliegues manuales a arquitecturas robustas y reproducibles en la nube de AWS utilizando Terraform.

El repositorio proporciona dos entornos completamente automatizados, modulares e independientes, disenados para operar bajo las restricciones de AWS Academy / Learner Labs:

*   environments/eks: Infraestructura para la orquestacion basada en Amazon EKS (Elastic Kubernetes Service).
*   environments/ecs: Infraestructura para la orquestacion serverless basada en Amazon ECS (Elastic Container Service) con AWS Fargate.

---

## Estructura del Directorio

```text
terraform/
├── README.md                  # Este documento (Guia de inicio rapido de IaC)
└── environments/
    ├── eks/                   # Automatizacion EKS
    │   ├── main.tf            # Recursos (VPC, EKS, Node Group, ECR, Add-ons)
    │   ├── variables.tf       # Parametros del entorno (CIDR, roles, tipos de instancia)
    │   ├── outputs.tf         # Salidas utiles (Comandos kubectl, URLs de ECR)
    │   ├── providers.tf       # Configuracion de proveedores AWS y Kubernetes
    │   └── README.md          # Guia paso a paso para el despliegue de EKS
    └── ecs/                   # Automatizacion ECS (Fargate)
        ├── main.tf            # Recursos (VPC, ECS, Fargate, ALB, Cloud Map, ECR)
        ├── variables.tf       # Parametros del entorno
        ├── outputs.tf         # Salidas utiles (URL DNS del ALB)
        └── README.md          # Guia paso a paso para el despliegue de ECS
```

---

## Consideraciones Generales y Buenas Practicas

1.  **Aislamiento de Entornos:** Los entornos de `eks` y `ecs` son totalmente independientes y no comparten recursos entre si.
2.  **Modulo VPC Externo:** Ambos entornos automatizan la red mediante el modulo oficial de AWS VPC desde el registro publico de Terraform:
    `git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=v6.5.1`
3.  **Dependencia de Imagenes (ECR):** Los repositorios de Amazon ECR son creados en la primera fase de Terraform. Debes compilar, etiquetar y subir las imagenes Docker de `frontend`, `backend` y `db` a sus respectivos repositorios antes de que los servicios de Kubernetes o ECS puedan iniciar con exito.
4.  **Base de Datos en Desarrollo:** La base de datos MySQL en esta actividad esta configurada de forma efimera mediante un almacenamiento temporal para fines academicos y de laboratorio. Para entornos productivos, se recomienda encarecipamente migrar a Amazon RDS o Aurora.
5.  **Alineacion con AWS Academy:** Por defecto, los archivos y configuraciones estan preconfigurados para la region de N. Virginia (`us-east-1`), que es la region oficial asignada para los entornos educativos de AWS Academy.

---

## Flujo de Despliegue para Amazon EKS (Kubernetes)

Este flujo despliega un cluster EKS administrado con Nodos Worker en subredes privadas. La comunicacion interna de la aplicacion se realiza a través de Services de Kubernetes y DNS interno de CoreDNS.

### Comandos de Despliegue de Infraestructura

```bash
cd environments/eks
cp terraform.tfvars.example terraform.tfvars
# (Edita terraform.tfvars con tus roles LabEksClusterRole y LabEksNodeRole de AWS Academy)

terraform init
terraform validate
terraform plan -out tfplan
terraform apply tfplan
```

### Guia de Despliegue Completo de la Aplicacion
Para ver los pasos detallados de compilacion de imagenes, configuracion de kubectl y despliegue de manifiestos YAML, accede a:
[Guia Detallada de Despliegue en Amazon EKS](./environments/eks/README.md)

---

## Flujo de Despliegue para Amazon ECS (AWS Fargate)

Este flujo despliega la aplicacion utilizando contenedores serverless en ECS Fargate. La comunicacion interna entre el frontend y el backend se realiza de forma transparente a traves de un Application Load Balancer (ALB) publico utilizando enrutamiento basado en rutas (`/api/*` para backend y `/` para frontend), y con Cloud Map privado para conectar el backend a la base de datos MySQL.

### Comandos de Despliegue de Infraestructura

```bash
cd environments/ecs
cp terraform.tfvars.example terraform.tfvars
# (Edita terraform.tfvars si necesitas personalizar alguna configuracion del cluster)

terraform init
terraform validate
terraform plan -out tfplan
terraform apply tfplan
```

### Guia de Despliegue Completo de la Aplicacion
Para ver los pasos detallados de compilacion de imagenes, enrutamiento basado en rutas de ALB y despliegue de tareas en Fargate, accede a:
[Guia Detallada de Despliegue en Amazon ECS](./environments/ecs/README.md)
