# Flask (Python) ejemplo

## Objetivo

Montar una pequeña aplicación Flask y desplegarla con Docker o Podman.

## Pasos para crear la app

1. Crea un entorno virtual y activa:
   ```bash
   cd flask_example
   python --version
   python3 -m venv venv # o el alias python -m venv venv
   source venv/bin/activate # para linux y mac, en windows es venv\Scripts\activate
   ```
2. Instala Flask y crea el archivo `app.py`:

   ```bash
   pip install flask
   cat <<'PY' > app.py
   from flask import Flask

   app = Flask(__name__)

   @app.route('/')
   def home():
       return 'Hola desde Flask y Docker/Podman!'

   if __name__ == '__main__':
       app.run(host='0.0.0.0', port=5000)
   PY
   ```

3. Crea `requirements.txt` para fijar dependencias:
   ```bash
   pip freeze > requirements.txt
   ```
4. Prueba localmente:
   ```bash
   flask --app app run
   ```

## Docker / Podman

1. Añade un `Dockerfile` así:
   ```Dockerfile
   FROM python:3.13-slim
   WORKDIR /app
   COPY requirements.txt ./
   RUN pip install --no-cache-dir -r requirements.txt
   COPY . ./
   EXPOSE 8080
   CMD ["flask", "--app", "app", "run", "--host", "0.0.0.0", "--port", "8080"]
   ```
2. Construye la imagen:
   ```bash
   docker build -t flask-example:latest .
   podman build -t flask-example:latest .
   ```
3. Ejecuta el contenedor:
   ```bash
   docker run --rm -p 8080:8080 flask-example:latest
   podman run -d --rm --network duoc -p 8080:8080 --name flask-example localhost/flask-example:latest
   ```
4. Visita `http://localhost:8080`.

5. Accede a los logs

   ```bash
   podman logs flask-example
   ```

6. Detener el contenedor

   ```bash
   podman stop flask-example
   ```

7. Eliminar el contenedor
   ```bash
   podman rm flask-example
   ```

## Notas

- Si haces cambios en `app.py`, vuelve a crear la imagen para incluirlos.
- Podrías usar `pip install gunicorn` y cambiar el CMD del contenedor para producción.
## Pruebas unitarias y cobertura

- Usa `make` para estandarizar los pasos:
  ```bash
  cd flask_example
  make deps       # crea/actualiza el virtualenv e instala pip + requirements
  make test       # corre pytest + cobertura y genera report.html
  make coverage   # ejecuta coverage html para crear htmlcov/index.html
  make clean      # elimina artefactos generados por las pruebas
  ```
- Si no tienes `make`, ejecuta manualmente los comandos descritos arriba: `python -m pytest ...` seguido de `coverage html -d htmlcov`. Los artefactos HTML (`htmlcov/index.html` y `report.html`) son los que se suben como artifacts en GitHub Actions.
