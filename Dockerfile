# Use the .NET 7.0 runtime as the base image
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 5000

ENV ASPNETCORE_URLS=http://+:5000

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

# Build stage using .NET 7.0 SDK
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
COPY ["src/Play.Catalog.Contracts/Play.Catalog.Contracts.csproj", "src/Play.Catalog.Contracts/"]
COPY ["src/Play.Catalog.Service/Play.Catalog.Service.csproj", "src/Play.Catalog.Service/"]

# Configure GitHub Package Registry secrets for NuGet
RUN --mount=type=secret,id=GH_OWNER,dst=/GH_OWNER --mount=type=secret,id=GH_PAT,dst=/GH_PAT \
    dotnet nuget add source --username USERNAME --password `cat /GH_PAT` --store-password-in-clear-text --name github "https://nuget.pkg.github.com/`cat /GH_OWNER`/index.json"

# Restore dependencies
RUN dotnet restore "src/Play.Catalog.Service/Play.Catalog.Service.csproj"

# Copy the source code
COPY ./src ./src
WORKDIR "/src/Play.Catalog.Service"

# Publish the application
RUN dotnet publish "Play.Catalog.Service.csproj" -c Release --no-restore -o /app/publish /p:UseAppHost=false

# Final stage using .NET 7.0 runtime
FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Play.Catalog.Service.dll"]
