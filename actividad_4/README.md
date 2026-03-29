# Actividad 4: DevOps & Cloud Infrastructure

Este repositorio contiene una aplicación de lista de tareas (**TODO App**) de 3 niveles plenamente funcional, desplegada de forma automatizada en **Amazon Web Services (AWS)** utilizando **Terraform** como Infraestructura como Código (IaC).

## 🏗️ Arquitectura del Sistema

La solución está diseñada para máxima seguridad y escalabilidad, separando las capas en subredes públicas y privadas:

### 1. Capa de Presentación (Frontend)

- **Tecnología**: React Router 7 (SPA Mode) servida por **Nginx**.
- **Despliegue**: Instancia EC2 en **Subred Pública**.
- **Rol Dinámico**: Nginx actúa como **Proxy Inverso** redirigiendo las peticiones `/api` hacia la IP interna del backend.

### 2. Capa de Lógica (Backend)

- **Tecnología**: Node.js (Express) + Prisma ORM.
- **Despliegue**: Instancia EC2 en **Subred Privada**.
- **Seguridad**: Solo es accesible a través del Frontend por el puerto 3000. No tiene IP pública directa.

### 3. Capa de Datos (Database)

- **Tecnología**: PostgreSQL containerizado.
- **Despliegue**: Instancia EC2 en **Subred Privada**.
- **Seguridad**: Solo accesible desde el Backend por el puerto 5432.

### 4. Conectividad (NAT Instance)

- **Tecnología**: Amazon Linux 2 configurada como puerta de enlace de red.
- **Propósito**: Permite que las instancias en subredes privadas (Backend y DB) salgan a internet para descargar paquetes e imágenes, sin exponerlas a ataques externos.

---

## 🚀 Guía de Despliegue Rápido

### Prerrequisitos

- Cuenta de AWS activa.
- Terraform instalado localmente.
- Docker o Podman para la construcción de imágenes.
- Par de llaves SSH `.pem` configurado en AWS.

### Paso 1: Configurar Infraestructura (IaC)

1.  Navegar a la carpeta `iac/`.
2.  Crear un archivo `terraform.tfvars` basado en `terraform.tfvars.example`.
3.  Inicializar y aplicar:
    ```bash
    terraform init
    terraform apply
    ```
4.  Anota los `outputs` (IPs públicas de Frontend y NAT, IPs privadas de Backend y DB).

### Paso 2: Construir y Subir Imágenes

Construye las imágenes para arquitectura `linux/amd64` desde las carpetas raíz de cada componente:

```bash
# Frontend
podman build --platform linux/amd64 -t <DOCKERHUB_USER>/actividad4-frontend:latest ./frontend
podman push <DOCKERHUB_USER>/actividad4-frontend:latest

# Backend
podman build --platform linux/amd64 -t <DOCKERHUB_USER>/actividad4-backend:latest ./backend
podman push <DOCKERHUB_USER>/actividad4-backend:latest

# Database
podman build --platform linux/amd64 -t <DOCKERHUB_USER>/actividad4-database:latest ./database
podman push <DOCKERHUB_USER>/actividad4-database:latest
```

### Paso 3: Lanzar Contenedores en AWS

Accede por SSH a cada instancia (a través del Frontend o Bastion) y ejecuta el comando `docker run` correspondiente (inyectado automáticamente vía `user_data` si usas Terraform, o manualmente para pruebas).

---

## 🔧 Solución de Problemas (Troubleshooting)

| Problema                    | Causa Probable                  | Solución                                                                      |
| :-------------------------- | :------------------------------ | :---------------------------------------------------------------------------- |
| **Timeout en Backend/DB**   | NAT Instance no está enrutando. | Verificar `net.ipv4.ip_forward = 1` y reglas de `iptables` en la NAT.         |
| **Prisma Connection Error** | Falta OpenSSL en Alpine.        | Asegurar `RUN apk add openssl libc6-compat` en el Dockerfile del Backend.     |
| **Timeout en el Navegador** | Llamada a IP Privada.           | El Frontend debe usar **Nginx Proxy** para llamar al Backend por red interna. |
| **Error 400 Bad Request**   | Formato de JSON del Backend.    | El Frontend debe acceder al campo `.data` de la respuesta del Backend.        |

---

## 🔒 Seguridad

- Las instancias privadas no tienen SSH expuesto a internet. Usa **SSH Agent Forwarding** desde el Frontend.
- Nunca subas archivos `.pem` o `terraform.tfstate` al repositorio. Están protegidos por `.gitignore`.

---

_Desarrollado para la Actividad 4 - Introduccion de Herramientas DEVOPS - DuocUC 2026._
