# ---------- build ----------
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# ---------- runtime ----------
FROM nginx:stable-alpine

# Copy the built assets to Nginx
COPY --from=builder /app/build/client /usr/share/nginx/html

# Copy the Nginx configuration template
# Nginx docker image will automatically use envsubst on this file
COPY nginx/nginx.conf.template /etc/nginx/templates/default.conf.template

ENV BACKEND_HOST=localhost

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]