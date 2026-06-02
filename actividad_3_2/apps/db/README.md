# Guia de Construccion y Publicacion: Base de Datos (MySQL)

Este directorio contiene los archivos necesarios para empaquetar y personalizar la base de datos MySQL utilizada por la aplicacion de la Tienda de Perritos. El proceso incluye una base de datos preconfigurada con el archivo de inicializacion `init.sql`.

---

## Requisitos Previos

Antes de proceder, asegurate de cumplir con:

1.  **Motor de contenedores:** Tener instalado y en ejecucion Docker Desktop (o en su defecto Podman).
2.  **AWS CLI:** Configurado con credenciales vigentes de tu cuenta de AWS Academy.
3.  **Repositorio ECR:** Haber ejecutado la fase de Terraform en la carpeta `eks/` para aprovisionar el repositorio de base de datos.

> [!IMPORTANT]
> **Compatibilidad de Arquitectura (MacOS M1/M2/M3):**
> Dado que los Nodos Worker de Amazon EKS corren sobre arquitectura `x86_64` (AMD64) e instancias EC2 estandar, si estas compilando desde un computador Mac con chip Apple Silicon (M1/M2/M3/M4), **debes** forzar la plataforma de destino agregando el parametro `--platform linux/amd64`. De lo contrario, los Pods fallaran en EKS con un error de tipo `Exec format error`.

---

## Paso a Paso: Compilacion y Carga a Amazon ECR

### Paso 1: Autenticacion en Amazon ECR

Inicia sesion en el registro oficial de ECR para tu cuenta de AWS Academy. Reemplaza `<ACCOUNT_ID>` con el identificador numerico de tu cuenta AWS:

```bash
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
```

_(Si utilizas Podman, descomenta e implementa la version para Podman en tu terminal)_.

---

### Paso 2: Compilacion y Push utilizando Docker

Ejecuta los siguientes comandos desde este directorio (`apps/db`):

1.  **Construir la imagen localmente** (forzando arquitectura compatible):

    ```bash
    docker buildx build --platform linux/amd64 -t intro-devops-lab-db .
    ```

2.  **Etiquetar la imagen** apuntando a tu repositorio de ECR (reemplaza `<ACCOUNT_ID>`):

    ```bash
    docker tag intro-devops-lab-db <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/intro-devops-lab-db:eks-v1
    ```

3.  **Subir la imagen a la nube:**
    ```bash
    docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/intro-devops-lab-db:eks-v1
    ```

---

### Paso 3: Compilacion y Push utilizando Podman (Alternativa)

Si tu sistema utiliza Podman en lugar de Docker, ejecuta:

1.  **Construir la imagen:**

    ```bash
    podman build --platform linux/amd64 -t intro-devops-lab-db .
    ```

2.  **Etiquetar la imagen:**

    ```bash
    podman tag intro-devops-lab-db <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/intro-devops-lab-db:eks-v1
    podman tag intro-devops-lab-db <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/intro-devops-lab-db:ecs-v1
    ```

3.  **Subir la imagen:**
    ```bash
    podman push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/intro-devops-lab-db:eks-v1
    podman push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/intro-devops-lab-db:ecs-v1
    ```
