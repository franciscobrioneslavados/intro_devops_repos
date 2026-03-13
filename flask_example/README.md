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

3. Agrega dos endpoints REST simples:

   ```python
   from flask import Flask, jsonify, request

   app = Flask(__name__)

   def _parse_arg(name):
       try:
           return float(request.args.get(name, 0))
       except (TypeError, ValueError):
           return 0.0

   @app.route('/sum')
   def sum_values():
       a = _parse_arg('a')
       b = _parse_arg('b')
       return jsonify(result=a + b)

   @app.route('/subtract')
   def subtract_values():
       a = _parse_arg('a')
       b = _parse_arg('b')
       return jsonify(result=a - b)
   ```

   Puedes probarlos con `curl http://localhost:5000/sum?a=7&b=5` y `curl http://localhost:5000/subtract?a=10&b=4`.

4. Crea `requirements.txt` para fijar dependencias:
   ```bash
   pip freeze > requirements.txt
   ```
5. Prueba localmente:
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
