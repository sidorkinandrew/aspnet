# https://hub.docker.com/_/microsoft-dotnet
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /source

# copy csproj and restore as distinct layers
COPY *.sln .
COPY aspnetapp/*.csproj ./aspnetapp/
RUN dotnet restore -r linux-x64

# copy everything else and build app
FROM build AS publish
COPY aspnetapp/. ./aspnetapp/
WORKDIR /source/aspnetapp
RUN dotnet publish -c release -o /app -r linux-x64 # --self-contained false --no-restore

FROM registry.access.redhat.com/ubi8-minimal AS runtime
RUN microdnf install libicu glibc-devel
WORKDIR /app
#ENV InfoManagement__Checksum__Root=/opt/app/checksum/
ENV ASPNETCORE_URLS=http://++:8080
EXPOSE 8080

# final stage/image
#FROM mcr.microsoft.com/dotnet/aspnet:6.0-bullseye-slim-amd64
FROM runtime AS final
WORKDIR /app
COPY --from=publish /app ./
ENTRYPOINT ["./aspnetapp"]