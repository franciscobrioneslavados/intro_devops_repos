# Guia de Despliegue: Amazon EKS (Elastic Kubernetes Service)

Este entorno automatiza por completo la infraestructura de la actividad basada en Amazon EKS utilizando Terraform. Reemplaza la creacion y configuracion manual del cluster por un flujo declarativo y predecible.

---

## Recursos Aprovisionados

La ejecucion del codigo de Terraform creara de forma automatizada:

1.  **Red (VPC):** Subredes publicas (para los balanceadores de carga y salida) y privadas (para albergar los Nodos Worker de manera segura).
2.  **NAT Instance:** Una instancia EC2 actuando como NAT personalizada para brindar salida a Internet a los nodos privados a bajo costo.
3.  **Amazon ECR:** Tres repositorios de imagenes para `frontend`, `backend` y `db`.
4.  **Amazon EKS (Control Plane):** Cluster de Kubernetes administrado.
5.  **Node Group Administrado:** Grupo de escalado de instancias EC2 (`t3.large` / tipo `SPOT` para control de costos) desplegado en subredes privadas.
6.  **Add-ons Esenciales:** Instalacion de `vpc-cni`, `kube-proxy`, `coredns` y `metrics-server`.

---

## Guia Paso a Paso para el Despliegue

Sigue el orden de las siguientes fases para desplegar el entorno completo con exito:

### Fase 1: Creacion de la Infraestructura con Terraform

1.  Posicionate en el directorio de EKS:

    ```bash
    cd terraform/environments/eks
    ```

2.  Crea tu archivo de variables locales a partir de la plantilla de ejemplo:

    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```

3.  **Configuracion de AWS Academy (CRITICO):**
    Abre `terraform.tfvars` con tu editor y edita los ARNs de los roles IAM. Los laboratorios de AWS Academy bloquean la creacion de roles IAM personalizados. Debes reutilizar los roles precreados de tu laboratorio:

    ```hcl
    project_name         = "intro-devops"
    owner_name           = "Tu Nombre"
    environment          = "lab"
    cluster_iam_role_arn = "arn:aws:iam::<TU_ACCOUNT_ID>:role/LabEksClusterRole-xxxx"
    node_iam_role_arn    = "arn:aws:iam::<TU_ACCOUNT_ID>:role/LabEksNodeRole-xxxx"
    ```

4.  Inicializa, valida y despliega la infraestructura:
    ```bash
    terraform init
    terraform validate
    terraform plan -out tfplan
    terraform apply tfplan
    ```
    _Nota: La creacion del cluster de EKS y el Node Group puede tardar entre 10 y 15 minutos en completarse._

---

### Fase 2: Autenticacion en Amazon ECR

Para que Docker o Podman puedan subir las imagenes de tu aplicacion a AWS, primero debes iniciar sesion en el registro privado de Amazon ECR:

```bash
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin <TU_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
```

Una vez autenticado, sigue las instrucciones detalladas de compilacion y subida de imagenes en los README individuales de cada capa:

- **Base de Datos:** [Instrucciones de Compilacion y Push de DB](../../../apps/db/README.md)
- **Backend Service:** [Instrucciones de Compilacion y Push de Backend](../../../apps/backend/README.md)
- **Frontend App:** [Instrucciones de Compilacion y Push de Frontend](../../../apps/frontend/README.md)

---

### Fase 3: Conexion con el Cluster via Kubectl

Una vez que el cluster de EKS este en estado activo, configura las credenciales de conexion en tu maquina local para poder interactuar con el mediante `kubectl`:

1.  Actualiza tu archivo kubeconfig (reemplaza con el nombre de tu cluster generado en los outputs de Terraform):

    ```bash
    aws eks update-kubeconfig --region us-east-1 --name intro-devops-lab-eks --alias intro-devops-lab-eks
    ```

2.  Verifica que tus nodos worker esten registrados y en estado saludable (`Ready`):
    ```bash
    kubectl get nodes
    ```

---

### Fase 4: Despliegue de la Aplicacion en Kubernetes

Aplica los manifiestos de Kubernetes de cada componente en orden secuencial (desde el directorio `terraform/environments/eks`):

1.  **Crear el Namespace y Secretos:**
    Asegurate de aplicar el namespace comun para aislar los recursos de la tienda:

    ```bash
    kubectl apply -f ../../../apps/namespace.yaml
    ```

2.  **Desplegar Base de Datos (MySQL):**

    ```bash
    kubectl apply -f ../../../apps/db/k8s
    ```

3.  **Desplegar Backend:**

    ```bash
    kubectl apply -f ../../../apps/backend/k8s
    ```

4.  **Desplegar Frontend (Expuesto al publico):**
    ```bash
    kubectl apply -f ../../../apps/frontend/k8s
    ```

---

### Fase 5: Validacion y Monitoreo

Monitorea el estado del despliegue y valida que todos los Pods, Servicios y Autoscalers esten operativos:

1.  Revisar el estado de los Pods (deberian transicionar a `Running`):

    ```bash
    kubectl get pods -n tienda
    ```

2.  Obtener la direccion DNS publica del Balanceador de Carga para abrir la aplicacion en tu navegador:

    ```bash
    kubectl get svc tienda-frontend -n tienda
    ```

    _Copia la direccion del campo `EXTERNAL-IP` (DNS del balanceador) y pegala en tu navegador web para visualizar la Tienda de Perritos._

3.  Revisar el estado de autoescalado horizontal (HPA):
    ```bash
    kubectl get hpa -n tienda
    ```
