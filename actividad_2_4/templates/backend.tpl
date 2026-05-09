#!/bin/bash
# 1. Install Docker, Curl and Unzip
apt-get update
apt-get install -y docker.io curl unzip
systemctl start docker
systemctl enable docker

# 2. Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip ./aws

# Dar permisos a docker a los usuarios ubuntu y ssm-user
usermod -aG docker ubuntu
usermod -aG docker ssm-user

# 3. Login to Registry if ECR
if [ "${container_registry}" == "ecr" ]; then
  REGISTRY_URL=$(echo "${image_url}" | cut -d'/' -f1)
  REGION=$(echo $REGISTRY_URL | cut -d'.' -f4)
  aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REGISTRY_URL
fi

# 4. Pull and Run Backend
docker pull ${image_url}
docker run -d --name backend -p 3001:3001 \
  -e DB_HOST=${db_host} \
  -e DB_USER=alumno \
  -e DB_PASSWORD=alumno123 \
  -e DB_NAME=tienda_perritos \
  -e DB_PORT=3306 \
  ${image_url}
