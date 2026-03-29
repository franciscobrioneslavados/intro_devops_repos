# Frontend - Actividad 4

Aplicación TODO desarrollada con React, TypeScript, Material UI y desplegada con Docker + Nginx.

## Tecnologías

- **React 19** - Framework UI
- **React Router v7** - Enrutamiento
- **TypeScript** - Tipado estático
- **Material UI (MUI)** - Componentes UI
- **Vite** - Bundler y dev server
- **Docker** - Contenedores

## Scripts

```bash
# Instalación de dependencias
npm install

# Desarrollo
npm run dev

# Build para producción
npm run build

# Verificación de tipos
npm run typecheck
```

## Docker/Podman

### Build

```bash
docker build --platform linux/amd64 -t <ACCOUNT_ID>/actividad4-frontend:latest .
podman build --platform linux/amd64 -t <ACCOUNT_ID>/actividad4-frontend:latest .
```

### Push

```bash
docker push <ACCOUNT_ID>/actividad4-frontend:latest
podman push <ACCOUNT_ID>/actividad4-frontend:latest
```

### Run

```bash
docker run -d -p 80:3000 --name actividad4-frontend <ACCOUNT_ID>/actividad4-frontend:latest
podman run -d -p 80:3000 --name actividad4-frontend <ACCOUNT_ID>/actividad4-frontend:latest
```

## Verificar variables de entorno

```bash
docker inspect actividad4-frontend | grep -A 5 "Env"
docker exec actividad4-frontend printenv | grep BACKEND_HOST
```

## Estructura del Proyecto

```
frontend/
├── app/
│   ├── components/
│   │   └── TodoApp.tsx      # Componente principal TODO
│   ├── routes/
│   │   └── home.tsx         # Ruta principal
│   └── root.tsx             # Layout con MUI Theme
├── nginx/
│   └── nginx.conf           # Configuración Nginx
├── public/                  # Archivos estáticos
├── Dockerfile               # Multi-stage build
└── vite.config.ts          # Configuración Vite
```

## Características del TODO

- ✅ Agregar tareas
- ✅ Marcar tareas como completadas
- ✅ Eliminar tareas
- ✅ Editar tareas
- ✅ Contador de tareas pendientes/completadas
- ✅ Diseño responsive con Material UI

## Endpoints

| Endpoint  | Descripción                 |
| --------- | --------------------------- |
| `/`       | Aplicación TODO             |
| `/health` | Health check (retorna "OK") |
