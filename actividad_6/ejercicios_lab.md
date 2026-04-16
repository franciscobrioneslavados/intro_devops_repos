# Guía de Ejercicios: Laboratorio DevOps (Docker, Podman, Compose, Swarm)

Esta guía utiliza las carpetas `app_single` y `app_db` de este repositorio.

## 1. Conexión a las Instancias
Utiliza los comandos SSH de los outputs de Terraform.

---

## 2. Docker: Construcción y Ejecución (Docker Host)

Usaremos la aplicación en la carpeta `/app_single`.

1. Conéntate al host de Docker.
2. Crea una carpeta para la app: `mkdir app && cd app`
3. Copia el contenido de `app_single/` (puedes usar `cat` o `nano` para cada archivo).
4. Construye la imagen:
   ```bash
   docker build -t mi-app-flask:v1 .
   ```
5. Ejecuta el contenedor:
   ```bash
   docker run -d --name flask-web -p 80:80 mi-app-flask:v1
   ```
6. Prueba: `curl http://localhost`

---

## 3. Docker Compose: Aplicación con Base de Datos (Compose Host)

Usaremos la aplicación en la carpeta `/app_db`.

1. Conéntate al host de Compose.
2. Crea la carpeta `app` y copia los archivos de `app_db/`.
3. Levanta el stack:
   ```bash
   docker compose up -d
   ```
4. **¿Qué sucede internamente?**
   - La aplicación inicia un hilo que guarda un log en la base de datos cada 60 segundos.
   - PostgreSQL utiliza un volumen persistente.
5. Accede a `http://<compose_host_public_ip>:8080`.

---

## 4. Podman: Contenedores sin Daemon (Podman Host)

Usaremos la aplicación en `/app_single`.

1. Conéntate al host de Podman.
2. Construye la imagen:
   ```bash
   podman build -t mi-app-podman .
   ```
3. Ejecuta:
   ```bash
   podman run -d --name web-podman -p 80:80 mi-app-podman
   ```

---

## 5. Docker Swarm: Alta Disponibilidad (Swarm Nodes)

### A. Preparación (Manager Node)
1. Inicializa: `docker swarm init --advertise-addr <IP_PRIVADA>`
2. Une al segundo nodo usando el token generado.

### B. Despliegue de Stack (Manager Node)
1. Usa el archivo `swarm-stack.yml` ubicado en `/app_single`.
2. Despliega:
   ```bash
   docker stack deploy -c swarm-stack.yml mi-web-stack
   ```
3. Escala el servicio:
   ```bash
   docker service scale mi-web_web=5
   ```
