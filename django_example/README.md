# Django (Python) ejemplo

## Objetivo

Generar un proyecto Django que sirva contenido HTML simple y ejecutarlo con Docker o Podman.

## Pasos para crear la app

1. Prepara el entorno:
   ```bash
   cd django_example
   python3 -m venv venv
   source venv/bin/activate
   pip install django
   ```
2. Crea el proyecto y una app básica:
   ```bash
   django-admin startproject webapp .
   python manage.py startapp core
   ```
3. Define las apps, vistas y rutas con ejemplos concretos:
   - En `webapp/settings.py`, la app `core` debe estar declarada en `INSTALLED_APPS`:
     ```python
     INSTALLED_APPS = [
         "django.contrib.admin",
         "django.contrib.auth",
         "django.contrib.contenttypes",
         "django.contrib.sessions",
         "django.contrib.messages",
         "django.contrib.staticfiles",
         "core",
     ]
     ```
   - En `webapp/urls.py` importa el admin y `include`, y expón `/` a través de `core.urls`:

     ```python
     from django.contrib import admin
     from django.urls import path, include

     urlpatterns = [
         path("admin/", admin.site.urls),
         path("", include("core.urls")),
     ]
     ```

   - Crea `core/urls.py` define la ruta raíz hacia `home` (ya existe en el repositorio):

     ```python
     from django.urls import path
     from .views import home

     urlpatterns = [
         path("", home, name="home"),
     ]
     ```

   - En `core/views.py` usa un `HttpResponse` simple (o `render` si agregas plantillas) para devolver el saludo:

     ```python
     from django.http import HttpResponse

     def home(request):
         return HttpResponse("Hola desde Django y Docker/Podman!")
     ```

     Si prefieres renderizar una plantilla `templates/index.html`, agrega `TEMPLATES[0]["DIRS"] = [BASE_DIR / "templates"]` en `webapp/settings.py` y crea esa plantilla.

4. Aplica migraciones, crea un superusuario si necesitas acceder al admin y arranca el servidor local:
   ```bash
   python manage.py migrate
   python manage.py createsuperuser
   python manage.py runserver 0.0.0.0:8000
   ```

## Docker / Podman

1. Añade un `Dockerfile` como este:
   ```Dockerfile
   FROM python:3.12-slim
   WORKDIR /app
   COPY requirements.txt ./
   RUN pip install --no-cache-dir -r requirements.txt
   COPY . ./
   EXPOSE 8000
   CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
   ```
2. Genera `requirements.txt` antes de construir:
   ```bash
   pip freeze > requirements.txt
   ```
3. Construye la imagen:
   ```bash
   docker build -t django-example:latest .
   podman build -t django-example:latest .
   ```
4. Ejecuta el contenedor:
   ```bash
   docker run --rm -p 8000:8000 django-example
   podman run -d --rm --network duoc -p 8000:8000 --name django-example localhost/django-example:latest
   ```

## Notas

- Para producción conviene usar `gunicorn` y agregar `collectstatic`.
- Si cambias el nombre de la app o las rutas, actualiza `webapp/urls.py` y `core/urls.py`.
