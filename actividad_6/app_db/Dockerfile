FROM python:3.9-slim

WORKDIR /app

# Instalar dependencias para psycopg2 si fuera necesario, aunque binary ya las trae
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py app.py

EXPOSE 80

CMD ["python", "app.py"]
