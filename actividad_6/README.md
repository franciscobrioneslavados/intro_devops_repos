# Infraestructura Actividad 6 - DevOps Lab

Este proyecto automatiza la creación de un entorno de laboratorio multi-tecnología en AWS utilizando Terraform. El entorno incluye soporte para Docker, Podman, Docker Compose y Docker Swarm, todo protegido detrás de una instancia NAT personalizada.

## Estructura del Proyecto

- **VPC & NAT**: Infraestructura base necesaria para la conectividad.
- **Docker Host**: Instancia con Docker pre-instalado y una aplicación Flask básica.
- **Compose Host**: Entorno con Docker Compose y una aplicación conectada a PostgreSQL.
- **Podman Host**: Alternativa a Docker utilizando Podman.
- **Swarm Nodes**: Un cluster de 2 nodos listo para ser inicializado como un Swarm.

---

## Cómo Levantar la Infraestructura

Hemos preparado un `Makefile` para facilitar el despliegue por módulos. La **VPC y la NAT siempre se levantarán** independientemente de qué módulo elijas.

### Requisitos Previos

- Tener instalado Terraform y GNU Make.
- Configurar tus credenciales de AWS (ej. `aws configure`).

### Comandos Disponibles

| Comando | Acción |
| :--- | :--- |
| `make init` | Inicializa el proyecto (terraform init). |
| `make vpc` | Levanta solo la red base (VPC + NAT + Llaves). |
| `make docker` | Levanta la base + entorno Docker. |
| `make compose` | Levanta la base + entorno Docker Compose. |
| `make podman` | Levanta la base + entorno Podman. |
| `make swarm` | Levanta la base + los 2 nodos de Swarm. |
| `make k3s` | Levanta la base + nodo master de k3s. |
| `make all` | Levanta absolutamente todo el laboratorio. |
| `make destroy` | Elimina toda la infraestructura. |

---

## Conectividad y Pruebas

Una vez que Terraform termine, verás una lista de comandos `curl` y `ssh` en la terminal.

1.  **SSH**: Utiliza la llave generada automáticamente: `actividad6-dev-key.pem`.
2.  **Pruebas rápidas**: Copia y pega los comandos `curl` generados en los outputs para verificar que las aplicaciones estén respondiendo.

## Acceso a Kubernetes (k3s) desde Local

El servidor k3s ahora se encuentra en una **subred pública** para facilitar el acceso durante el lab:

1.  **Obtener el archivo de configuración**:
    ```bash
    make get-k3s-config
    ```
    (Este comando descarga el `k3s.yaml` y reemplaza automáticamente la IP por la IP pública del servidor).

2.  **Usar kubectl**:
    ```bash
    export KUBECONFIG=./k3s.yaml
    kubectl get nodes
    ```

---

## Notas Técnicas

- **Metadata**: Las aplicaciones muestran información dinámicamente obtenida del metadatos de AWS (IMDSv2).
- **Puertos**: Las aplicaciones web corren en el puerto **8080** expuesto al exterior. El tráfico es ruteado al puerto **80** interno de los contenedores.
