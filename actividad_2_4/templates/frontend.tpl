#!/bin/bash
# 1. Install Docker and AWS CLI
apt-get update
apt-get install -y docker.io awscli
systemctl start docker
systemctl enable docker

# Dar permisos a docker a los usuarios ubuntu y ssm-user
usermod -aG docker ubuntu
usermod -aG docker ssm-user

# 2. Login to Registry if ECR
if [ "${container_registry}" == "ecr" ]; then
  REGISTRY_URL=$(echo "${image_url}" | cut -d'/' -f1)
  REGION=$(echo $REGISTRY_URL | cut -d'.' -f4)
  aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REGISTRY_URL
fi

# 3. Pull and Run Frontend
# Usamos --add-host para mapear 'backend' al IP privado de la instancia backend
docker pull ${image_url}
docker run -d --name frontend -p 80:80 \
  --add-host=backend:${backend_host} \
  ${image_url}
