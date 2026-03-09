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
# Force Kestrel to listen on the same port we expose from the container.
ENV ASPNETCORE_URLS=http://+:80
ENTRYPOINT ["dotnet", "NetCoreExample.dll"]
