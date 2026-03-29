# Database - Actividad 4

Contenedor PostgreSQL para la aplicación TODO.

## Configuración

### Variables de Entorno

| Variable          | Descripción                | Default  |
| ----------------- | -------------------------- | -------- |
| POSTGRES_DB       | Nombre de la base de datos | todo_db  |
| POSTGRES_USER     | Usuario                    | user     |
| POSTGRES_PASSWORD | Contraseña                 | password |

### Puertos

| Puerto | Descripción |
| ------ | ----------- |
| 5432   | PostgreSQL  |

## Docker

### Build

```bash
docker build --platform linux/amd64 -t <ACCOUNT_ID>/actividad4-database:latest .
podman build --platform linux/amd64 -t <ACCOUNT_ID>/actividad4-database:latest .
```

### Push

```bash
docker push <ACCOUNT_ID>/actividad4-database:latest
podman push <ACCOUNT_ID>/actividad4-database:latest
```

### Run

```bash
docker run -d \
  --name actividad4-postgres \
  -e POSTGRES_DB=todo_db \
  -e POSTGRES_USER=user \
  -e POSTGRES_PASSWORD=password \
  -v postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  actividad4-database:latest
```

```bash
podman run -d \
  --name actividad4-postgres \
  -e POSTGRES_DB=todo_db \
  -e POSTGRES_USER=user \
  -e POSTGRES_PASSWORD=password \
  -v postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  actividad4-database:latest
```

### Docker Compose (local)

```yaml
version: "3.8"
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: todo_db
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

## Conexión

```bash
# Desde otra máquina
psql -h <IP_HOST> -U user -d todo_db

# Dentro del contenedor
docker exec -it actividad4-postgres psql -U user -d todo_db
```

## Backups

```bash
# Backup
docker exec actividad4-postgres pg_dump -U user todo_db > backup.sql

# Restore
cat backup.sql | docker exec -i actividad4-postgres psql -U user -d todo_db
```
