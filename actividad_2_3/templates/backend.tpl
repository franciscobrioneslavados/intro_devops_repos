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
usermod -a -G docker ubuntu
usermod -a -G docker ssm-user

# 2. Run Backend
cd /home/ubuntu/app/backend
docker build -t tienda-backend .
docker run -d --name backend -p 3001:3001 \
  -e DB_HOST=${db_host} \
  -e DB_USER=root \
  -e DB_PASSWORD=admin123 \
  -e DB_NAME=tienda_perritos \
  -e DB_PORT=3306 \
  tienda-backend
