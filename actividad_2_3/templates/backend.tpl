#!/bin/bash
# 1. Extract application
APP_ZIP_B64="${app_zip_b64}"
apt-get update
apt-get install -y unzip docker.io
systemctl start docker
systemctl enable docker
mkdir -p /home/ubuntu/app
echo "$APP_ZIP_B64" | base64 -d > /home/ubuntu/app.zip
unzip /home/ubuntu/app.zip -d /home/ubuntu/app
chown -R ubuntu:ubuntu /home/ubuntu/app

# Dar permisos a docker a los usuarios ubuntu y ssm-user
usermod -aG docker ubuntu
usermod -aG docker ssm-user

# 2. Run Backend
cd /home/ubuntu/app/backend

# Esperar a que la base de datos esté lista (aproximadamente)
sleep 20

docker build -t tienda-backend .
docker run -d --name backend -p 3001:3001 \
  -e DB_HOST=${db_host} \
  -e DB_USER=alumno \
  -e DB_PASSWORD=alumno123 \
  -e DB_NAME=tienda_perritos \
  -e DB_PORT=3306 \
  tienda-backend
