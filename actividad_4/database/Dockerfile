FROM postgres:16-alpine

ENV POSTGRES_DB=todo_db \
    POSTGRES_USER=user \
    POSTGRES_PASSWORD=password

# Directorio para inicialización
RUN mkdir -p /docker-entrypoint-initdb.d

VOLUME ["/var/lib/postgresql/data"]

EXPOSE 5432

HEALTHCHECK --interval=10s --timeout=5s --start-period=10s --retries=5 \
    CMD pg_isready -U user -d todo_db || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["postgres", "-c", "max_connections=100", "-c", "shared_buffers=256MB"]
