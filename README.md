# Repositorio de imágenes Docker y Podman

Colección de proyectos de ejemplo (Express, ASP.NET Core, Flask, Django y Nginx) pensados para aprender cómo contenerizarlos y ejecutarlos con Docker o Podman.

## 1. Repositorios disponibles
| Carpeta | Descripción | Puerto | Comentario |
|---|---|---|---|
| `express_example/` | API Node/Express mínima | 3000 | `npm start` devuelve un saludo
| `netcore_example/` | API ASP.NET Core con `weatherforecast` | 8080 (contenedor) | Usa `dotnet publish` en el build
| `flask_example/` | App Flask simple | 5000 | `flask --app app run`
| `django_example/` | Proyecto Django con vista principal | 8000 | `python manage.py runserver`
| `nginx_example/` | Nginx sirviendo contenido estático | 8080 | `index.html` propio en `html/`

Cada subcarpeta incluye un `README.md` con pasos específi cos de desarrollo, los `Dockerfile` y los artefactos que generan cada app.

---
## 2. Instrucciones para Podman
1. **Instalación:**
   - En macOS/Windows con Podman Machine: `brew install podman` o `choco install podman`, luego `podman machine init` y `podman machine start`.
   - En Linux: instala el paquete oficial (`sudo dnf install podman`, `sudo apt install podman`, etc.) y verifica con `podman --version`.
2. **Red compartida:** Podman no expone automáticamente todos los puertos a `localhost` porque los contenedores corren dentro de una red aislada. Crea una red custom para unir los servicios:
   ```bash
   podman network create webapps
   podman network ls
   ```
3. **Construcción y ejecución:**
   ```bash
   podman build -t express-example ./express_example
   podman run --rm --network webapps -p 3000:3000 express-example
   ```
   Repite para cada proyecto cambiando la ruta y el puerto (`-p 8080:80` para `.NET`/`nginx`, `-p 5000:5000` para Flask, `-p 8000:8000` para Django).
4. **Acceso:** Con el mapeo de puertos en la misma máquina, `http://localhost:<puerto>` funciona como con Docker. Si usas Podman Machine, asegúrate de mapear los puertos (`-p` los expone al host virtual) y abre `http://localhost:<puerto>` en tu navegador.
5. **Control:**
   ```bash
   podman ps
   podman stop <CONTAINER_ID>
   podman rm <CONTAINER_ID>
   podman logs <CONTENDOR_ID>
   ```

> Nota: Podman no requiere un demonio; cada comando crea su propio contenedor. Para reusar builds, elimina contenedores antiguos y usa la red `webapps` como única fuente compartida.

---
## 3. Instrucciones para Docker
1. **Instalación:** instálalo desde [https://docs.docker.com/get-docker](https://docs.docker.com/get-docker) y verifica con `docker --version`.
2. **Build y run básicos:**
   ```bash
   docker build -t nginx-static ./nginx_example
   docker run --rm -p 8080:80 --name nginx-example nginx-static
   ```
   Los pasos para cada repositorio son similares; revisa cada carpeta si necesitas configurar variables o puertos distintos.
3. **Opciones útiles:**
   - `docker ps`, `docker stop`, `docker rm`, `docker logs` (igual que con Podman).
   - `docker network create webapps` si deseas aislar los servicios y que se vean entre sí; de otro modo Docker ya expone `localhost` por defecto.
4. **Recomendación:** limpia imágenes y contenedores viejos antes de rebuild (`docker system prune -f` o comandos específicos) y vuelve a ejecutar `docker build` si cambias código o dependencias.

---
## 4. Flujo sugerido para cada servicio
1. Genera el código base siguiendo el `README.md` de su carpeta (por ejemplo, `express_example/README.md`).
2. Compila/instala dependencias localmente (`npm install`, `dotnet restore`, `pip install -r requirements.txt`).
3. Construye la imagen con Docker o Podman (construye una tag por proyecto).
4. Ejecuta el contenedor especificando `-p <host>:<container>`; para Podman además agrega `--network webapps`.
5. Confirma que el navegador/`curl` accede al puerto indicado.
6. Cuando termines, usa los comandos de parada/limpieza para liberar recursos.

---
## 5. Automatizar builds con GitHub Actions
1. Crea una rama de despliegue (por ejemplo `deploy`) que contenga los artefactos prometidos y el archivo de workflow `.github/workflows/build-and-push.yml`.
2. El workflow se dispara en `main`, `deploy` y `test`; antes de buildear las imágenes ejecuta los tests/coverage de Express y Flask (`npm test`, `npm run coverage`, `pytest --cov=app ...`). Además publica los artefactos de cobertura (`coverage/lcov.info` para Express y `coverage.xml`/`coverage.json` para Flask) para que puedas descargarlos desde la ejecución fallida o exitosa del pipeline.
3. Define los secretos de GitHub necesarios antes de activar el workflow:
   - `DOCKERHUB_USERNAME`: tu usuario o namespace en Docker Hub (usado como repositorio).
   - `DOCKERHUB_TOKEN`: token de acceso generado desde https://hub.docker.com/settings/security.
4. Cada vez que envíes cambios a `deploy` (o hagas `workflow_dispatch`), la acción compila las imágenes de cada carpeta y las sube a `${DOCKERHUB_USERNAME}/<imagen>:latest`. Ajusta las etiquetas en el workflow si necesitas versiones específicas o tags adicionales.
