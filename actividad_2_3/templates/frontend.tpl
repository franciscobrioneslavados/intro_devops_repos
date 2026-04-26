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

# 2. Configure Nginx proxy to Backend
# Modificamos la configuración de Nginx para apuntar al IP del backend
sed -i "s/backend:3001/${backend_host}:3001/g" /home/ubuntu/app/frontend/default.conf

# 3. Run Frontend
cd /home/ubuntu/app/frontend
docker build -t tienda-frontend .
docker run -d --name frontend -p 80:80 tienda-frontend
