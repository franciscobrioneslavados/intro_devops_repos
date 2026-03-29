# Backend - Actividad 4

REST API para la aplicación TODO, desarrollada con Node.js, Express, TypeScript y PostgreSQL.

## Tecnologías

- **Node.js 20** - Runtime
- **Express.js** - Framework web
- **TypeScript** - Tipado estático
- **Prisma** - ORM
- **PostgreSQL** - Base de datos
- **Docker** - Contenedores

## Scripts

```bash
# Instalar dependencias
npm install

# Desarrollo
npm run dev

# Build
npm run build

# Generar cliente Prisma
npm run prisma:generate

# Sincronizar schema con DB
npm run prisma:push
```

## Configuración

1. Copia el archivo de ejemplo:

   ```bash
   cp .env.example .env
   ```

2. Edita `.env` con tu configuración de PostgreSQL:
   ```env
   DATABASE_URL="postgresql://user:password@localhost:5432/todo_db"
   PORT=3000
   ```

## Docker/Podman

El contenedor **automáticamente sincroniza las tablas** con PostgreSQL al iniciar.

### Build

```bash
docker build --platform linux/amd64 -t <ACCOUNT_ID>/actividad4-backend:latest .
podman build --platform linux/amd64 -t <ACCOUNT_ID>/actividad4-backend:latest .
```

### Push

```bash
docker push <ACCOUNT_ID>/actividad4-backend:latest
podman push <ACCOUNT_ID>/actividad4-backend:latest
```

### Run

```bash
docker run -d -p 3000:3000 --name actividad4-backend <ACCOUNT_ID>actividad4-backend:latest
podman run -d -p 3000:3000 --name actividad4-backend <ACCOUNT_ID>/actividad4-backend:latest
```

### Flujo de inicio

```
1. Container inicia
2. Ejecuta `prisma db push` (crea tablas si no existen)
3. Inicia servidor Express en puerto 3000
```

## API Endpoints

| Método | Endpoint              | Descripción               |
| ------ | --------------------- | ------------------------- |
| GET    | /health               | Health check              |
| GET    | /api/todos            | Listar todas las tareas   |
| GET    | /api/todos/:id        | Obtener una tarea         |
| POST   | /api/todos            | Crear tarea               |
| PUT    | /api/todos/:id        | Actualizar tarea          |
| DELETE | /api/todos/:id        | Eliminar tarea            |
| PATCH  | /api/todos/:id/toggle | Cambiar estado completado |

## Ejemplos

### Crear tarea

```bash
curl -X POST http://localhost:3000/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title": "Mi primera tarea", "description": "Descripción opcional"}'
```

### Listar tareas

```bash
curl http://localhost:3000/api/todos
```

### Marcar como completada

```bash
curl -X PATCH http://localhost:3000/api/todos/1/toggle
```

## Estructura del Proyecto

```
backend/
├── src/
│   ├── config/
│   │   └── database.ts
│   ├── controllers/
│   │   └── todo.controller.ts
│   ├── middleware/
│   │   └── error.middleware.ts
│   ├── routes/
│   │   └── todo.routes.ts
│   ├── services/
│   │   └── todo.service.ts
│   ├── types/
│   │   └── todo.ts
│   └── index.ts
├── prisma/
│   └── schema.prisma
├── scripts/
│   └── entrypoint.sh      # Auto-sync DB
├── Dockerfile
└── package.json
```

## Modelo de Datos

### Todo

| Campo       | Tipo     | Descripción           |
| ----------- | -------- | --------------------- |
| id          | Int      | Identificador único   |
| title       | String   | Título de la tarea    |
| description | String?  | Descripción opcional  |
| completed   | Boolean  | Estado de completitud |
| createdAt   | DateTime | Fecha de creación     |
| updatedAt   | DateTime | Última actualización  |
