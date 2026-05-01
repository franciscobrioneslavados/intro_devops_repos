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

# 2. Run DB
cd /home/ubuntu/app/db
docker build -t tienda-db .
docker run -d --name db -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=admin123 \
  -e MYSQL_DATABASE=tienda_perritos \
  tienda-db
