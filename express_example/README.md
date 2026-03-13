# Express (Node.js) ejemplo

## Objetivo

Guía sencilla para crear una API mínima con Express y contenerizarla con Docker o Podman.

## Pasos para crear la app

1. Crea el directorio y entra en él (si aún no existe):
   ```bash
   mkdir express_example && cd express_example
   ```
2. Inicializa npm y agrega Express:
   ```bash
   npm init -y
   npm install express
   ```
3. Crea un servidor básico en `index.js`:

   ```js
   const express = require("express");
   const app = express();
   const port = process.env.PORT || 3000;

   app.get("/", (req, res) => {
     res.send("Hola desde Express y Docker/Podman!");
   });

   app.listen(port, () => console.log(`Escuchando en ${port}`));
   ```

4. Añade un script de inicio en `package.json` si no existe:
   ```json
   "scripts": {
     "start": "node index.js"
   }
   ```

## Docker / Podman

1. Crea un `Dockerfile` mínimo:
   ```Dockerfile
   FROM node:22-alpine
   WORKDIR /usr/src/app
   COPY package*.json ./
   RUN npm install
   COPY . ./
   EXPOSE 3000
   CMD ["npm", "start"]
   ```
2. Construye la imagen:
   ```bash
   docker build -t express-example .
   podman build -t express-example .
   ```
3. Ejecuta el contenedor en el puerto 3000:
   ```bash
   docker run --rm -p 3000:3000 express-example
   podman run -d --rm --network duoc -p 3000:3000 --name express-example localhost/express-example:latest
   ```
4. Verifica en el navegador o con `curl http://localhost:3000`.

## Notas

- Mantén el código en `index.js` y `package.json` al mismo nivel que el `Dockerfile`.
- Para cambiar el puerto expuesto, actualiza `EXPOSE` y el mapeo `-p`.
## Pruebas unitarias y cobertura

- Instala las dependencias (`npm install`) y ejecuta `npm test`. El script `test.js` invoca `app.handle` directamente para evitar abrir puertos en el sandbox y verifica el saludo de `/`.
- Para ver cobertura, ejecuta `npm run coverage`; `nyc` instrumenta `index.js` y genera los reportes `text`, `lcov` y `html` en `coverage/index.html`. Descarga ese HTML si quieres revisar la cobertura visualmente.
