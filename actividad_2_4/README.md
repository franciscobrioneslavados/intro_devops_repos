# Actividad 2.4: Infraestructura con Registros de Contenedores

Este proyecto despliega una aplicación de tres capas (**Pet Store**) en AWS utilizando Terraform, con la particularidad de que las imágenes de los contenedores se gestionan a través de registros externos (**Amazon ECR** o **GitHub Container Registry**).

## Guía de Inicio Rápido

### 1. Configuración de Variables

Asegúrate de configurar el archivo `terraform.tfvars` para elegir tu registro de preferencia:

```hcl
container_registry = "ecr" # Opciones: "ecr" o "github"
github_username    = "tu-usuario-gh"
owner_name         = "Tu Nombre"
ssh_allowed_cidrs  = ["tu.ip.v4.address/32"]
```

## Automatización con GitHub Actions

El proceso de Build y Push ahora está automatizado mediante un flujo de trabajo de **GitHub Actions**. Cada vez que realices un `push` a la rama `actividad_2_4`, se ejecutarán los siguientes pasos:

1.  **Checkout** del código.
2.  **Login en AWS ECR** (requiere secretos de AWS).
3.  **Login en GHCR** (usa el token automático de GitHub).
4.  **Build, Tag y Push** de las 3 imágenes (`frontend`, `backend`, `db`) al registro seleccionado.

### Control del Registro
Puedes controlar a qué registro se envían las imágenes de dos formas:
*   **Automática:** Modificando la variable `CONTAINER_REGISTRY` en `.github/workflows/push_images.yml` (opciones: `ecr`, `github`, `dockerhub`, `all`).
*   **Manual:** Al ejecutar el workflow manualmente desde la pestaña **Actions**, podrás elegir el registro de destino en un menú desplegable.

### Configuración de Secretos en GitHub
Para que el workflow funcione, debes añadir los siguientes **Secrets** en tu repositorio de GitHub (`Settings > Secrets and variables > Actions`):

*   `AWS_ACCESS_KEY_ID`: Tu llave de acceso de AWS.
*   `AWS_SECRET_ACCESS_KEY`: Tu llave secreta de AWS.
*   `DOCKERHUB_USERNAME`: Tu usuario de Docker Hub.
*   `DOCKERHUB_TOKEN`: Tu token de acceso (PAT) de Docker Hub.

> [!NOTE]
> El workflow está configurado para ejecutarse automáticamente en la rama `actividad_2_4`, pero también puedes dispararlo manualmente desde la pestaña **Actions**.

## Despliegue con Terraform

Inicializa el entorno y aplica los cambios:

```bash
terraform init
terraform plan
terraform apply
```

## Tecnologías Utilizadas

- **Infraestructura:** Terraform (AWS Provider)
- **Contenedores:** Docker
- **Registros:** Amazon ECR & GitHub Packages (GHCR)
- **Redes:** VPC con subredes públicas y privadas, Instancia NAT personalizada.
- **Acceso:** AWS Systems Manager (SSM) para administración remota.

## Salidas (Outputs)

Al finalizar el despliegue, Terraform proporcionará:

- `frontend_instances_info`: IP pública y comando curl para pruebas.
- `deployment_info`: Resumen del registro utilizado y las URLs de las imágenes desplegadas.
- `ssm_connect`: Comandos listos para conectar a cualquier instancia vía AWS CLI.

---

> [!IMPORTANT]
> Las instancias EC2 en subredes privadas dependen de la instancia **NAT** o de un NatGateway y de Route Tables para poder descargar las imágenes de los registros. Asegúrate de que la instancia NAT esté operativa y de que las Route Tables estén configuradas correctamente.
