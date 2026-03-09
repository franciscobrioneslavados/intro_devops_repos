# Nginx con contenido estático

## Objetivo

Servir una página HTML mínima con Nginx y levantarla en un contenedor Docker o Podman.

## Pasos para crear la app

1. Crea la estructura de archivos:
   ```bash
   mkdir -p nginx_example/html
   cd nginx_example
   ```
2. Agrega una página básica en `html/index.html`:
   ```html
   <!DOCTYPE html>
   <html lang="es">
     <head>
       <meta charset="UTF-8" />
       <title>Nginx Examples</title>
     </head>
     <body>
       <h1>Hola desde Nginx con Docker/Podman</h1>
       <p>Contenido estático servido por Nginx.</p>
     </body>
   </html>
   ```
3. Crea una configuración personalizada `default.conf`:
   ```nginx
   server {
     listen 80;
     server_name localhost;
     location / {
       root /usr/share/nginx/html;
       index index.html;
     }
   }
   ```

## Docker / Podman

1. Añade un `Dockerfile` sencillo:
   ```Dockerfile
   FROM nginx:stable-alpine
   COPY html/ /usr/share/nginx/html/
   COPY default.conf /etc/nginx/conf.d/default.conf
   EXPOSE 80
   ```
2. Construye la imagen:
   ```bash
   docker build -t nginx-static:latest .
   podman build -t nginx-static:latest .
   ```
3. Levanta el contenedor:
   ```bash
   docker run --rm -p 8080:80 nginx-static:latest
   podman run -d --rm --network duoc -p 8080:80 --name nginx-static localhost/nginx-static:latest
   ```
4. Abre `http://localhost:8080` para ver la página.

## Notas

- Puedes editar los archivos HTML o CSS dentro de `html/` y volver a construir la imagen.
- Usa `docker logs` o `podman logs` para depurar si Nginx falla en el arranque.
