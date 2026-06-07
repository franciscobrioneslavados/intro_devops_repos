# Guia de Despliegue: Amazon ECS con AWS Fargate

Este entorno automatiza por completo la infraestructura de la actividad utilizando Amazon ECS (Elastic Container Service) bajo el modelo serverless AWS Fargate. Reemplaza los pasos tradicionales de orquestacion por una arquitectura gestionada y altamente escalable en AWS.

---

## Recursos Aprovisionados

La ejecucion de este modulo de Terraform creara de forma automatizada:
1.  **Red (VPC):** Subredes publicas (para el balanceador de carga y salida) y privadas (para albergar las tareas de Fargate de forma protegida).
2.  **NAT Instance:** Una instancia EC2 actuando como NAT personalizada para proveer salida a Internet a las tareas de base de datos y backend a bajo costo.
3.  **Amazon ECR:** Tres repositorios de imagenes para `frontend`, `backend` y `db`.
4.  **Cluster ECS:** Cluster logico de ECS configurado para ejecutar tareas de AWS Fargate.
5.  **Application Load Balancer (ALB):** Balanceador de carga publico configurado para enrutar el trafico externo de los usuarios.
6.  **AWS Cloud Map:** Registro privado de Service Discovery para permitir que el servicio del backend localice de forma segura a la base de datos MySQL en la red privada.
7.  **Definiciones de Tareas y Servicios ECS:** Configuraciones de CPU, memoria, variables de entorno y politicas de ejecucion para cada contenedor.
8.  **Autoscaling por CPU:** Politicas de escalado automatico basadas en la utilizacion de CPU para los servicios del frontend y backend.

---

## Arquitectura y Enrutamiento: Diferencias con EKS

A diferencia de un despliegue tradicional en EKS (donde la comunicacion interna se gestiona a través de IPs virtuales y CoreDNS de Kubernetes), en ECS Fargate implementamos una arquitectura optimizada utilizando las capacidades del balanceador y la red de AWS:

*   **Enrutamiento Inteligente en el ALB:** Para evitar modificar las variables de entorno de la imagen del frontend, el Application Load Balancer centraliza las solicitudes externas en el puerto 80 y las redirige en funcion de la ruta:
    - Las solicitudes dirigidas a `/api/*` se envian directamente al Target Group del Backend.
    - Todas las demas solicitudes (ruta raiz `/`) se envian al Target Group del Frontend.
*   **Conectividad de Base de Datos:** El backend se conecta con la base de datos MySQL en la red privada utilizando Service Discovery de AWS Cloud Map, resolviendo el nombre de host a través del espacio de nombres privado (ej: `mysql.tienda.local`).

---

## Guia Paso a Paso para el Despliegue

### Fase 1: Creacion de la Infraestructura con Terraform

1.  Posicionate en el directorio de ECS:
    ```bash
    cd terraform/environments/ecs
    ```

2.  Crea tu archivo de variables locales a partir de la plantilla de ejemplo:
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```

3.  Inicializa, valida y despliega la infraestructura:
    ```bash
    terraform init
    terraform validate
    terraform plan -out tfplan
    terraform apply tfplan
    ```
    *Nota: Terraform creara los repositorios ECR de inmediato. Sin embargo, los servicios de ECS Fargate entraran en un bucle de reinicio intentando descargar las imagenes. Esto es normal hasta que completes la Fase 2.*

---

### Fase 2: Autenticacion en Amazon ECR y Publicacion de Imagenes

Para que los servicios de Fargate puedan iniciar, debes compilar y subir las imagenes de tu aplicacion:

1.  Inicia sesion en el registro privado de Amazon ECR (reemplaza `<ACCOUNT_ID>`):
    ```bash
    aws ecr get-login-password --region us-east-1 \
      | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
    ```

2.  Sigue las guias de compilacion y push detalladas para cada componente (utiliza el tag `:ecs-v1` o el configurado en tus variables):
    - **Base de Datos:** [Instrucciones de Compilacion y Push de DB](../../../apps/db/README.md)
    - **Backend Service:** [Instrucciones de Compilacion y Push de Backend](../../../apps/backend/README.md)
    - **Frontend App:** [Instrucciones de Compilacion y Push de Frontend](../../../apps/frontend/README.md)

---

### Fase 3: Validacion del Despliegue

Una vez que las imagenes se hayan subido con exito a Amazon ECR:

1.  Los servicios de ECS Fargate detectaran la disponibilidad de las imagenes y lanzaran las tareas correspondientes de forma automatica.
2.  Obten la direccion DNS publica de tu balanceador de carga ejecutando:
    ```bash
    terraform output alb_dns_name
    ```
3.  Copia la direccion DNS provista, pegala en tu navegador y comprueba que la **Tienda de Perritos** carga correctamente y se conecta al backend a traves del balanceador.
