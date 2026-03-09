# .NET (ASP.NET Core) ejemplo

## Objetivo

Montar una API Web mínima con ASP.NET Core y levantarla con Docker o Podman.

## Pasos para crear la app

1. En la carpeta `netcore_example` (si no existe, créala y entra):
   ```bash
   mkdir -p netcore_example && cd netcore_example
   ```
2. Crea el proyecto de API y restaura paquetes:
   ```bash
   dotnet --version # ultima version instalada 10.0.103
   dotnet new webapi -n NetCoreExample -o .
   dotnet restore
   ```
3. Ejecuta localmente para verificar:

   ```bash
   dotnet run
   ```

   - El servidor, por defecto, escucha en `https://localhost:7163` o `http://localhost:5171`.

## Docker / Podman

1. Añade un `Dockerfile` como este:

   ```Dockerfile
   FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
   WORKDIR /app
   EXPOSE 80

   FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
   WORKDIR /src
   COPY . ./
   RUN dotnet publish -c Release -o /app/publish

   FROM base AS final
   WORKDIR /app
   COPY --from=build /app/publish ./
   ENTRYPOINT ["dotnet", "NetCoreExample.dll"]
   ```

2. Construye la imagen:
   ```bash
   docker build -t netcore-example:latest .
   podman build -t netcore-example:latest .
   ```
3. Ejecuta el contenedor mapeando el puerto 80 (el Dockerfile fija `ASPNETCORE_URLS=http://+:80` para que Kestrel escuche ese puerto dentro del contenedor):
   ```bash
   docker run --rm -p 8080:80 netcore-example:latest
   podman run -d --rm --network duoc -p 8080:80 --name netcore-example localhost/netcore-example:latest
   ```
4. Accede a `http://localhost:8080/weatherforecast`.

5. Accede a los logs

   ```bash
   podman logs netcore-example
   ```

6. Detener el contenedor

   ```bash
   podman stop netcore-example
   ```

7. Eliminar el contenedor
   ```bash
   podman rm netcore-example
   ```

## Notas

- El contenedor se ejecuta en `Production` y el Dockerfile declara `ENV ASPNETCORE_URLS=http://+:80` para que Kestrel escuche el puerto 80 dentro de la imagen. Si cambias el puerto, actualiza ese valor o usa la variable en `docker run`/`podman run`.
- Para desarrollo local, puedes fijar `ASPNETCORE_ENVIRONMENT=Development` (y desactivar redirección HTTPS) antes de levantar la imagen y así usar los mismos puertos que `dotnet run`.
- Para retomar el desarrollo, modifica los controladores en `Controllers/WeatherForecastController.cs`.
