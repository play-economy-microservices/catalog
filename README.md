# play.catalog
Play Economy Catalog microservice


## Add the GitHub package source
```powershell
$version="1.0.1"
$owner="play-economy-microservices"
$gh_pat="[PAT HERE]"

dotnet pack src/Play.Catalog.Contracts/ --configuration Release -p:PackageVersion=$version -p:RepositoryUrl=https://github.com/$owner/play.catalog -o ../packages

dotnet nuget push ../packages/Play.Catalog.Contracts.$version.nupkg --api-key $gh_pat --source "github"
```

## Build the docker image
```powershell
$env:GH_OWNER="play-economy-microservices"
$env:GH_PAT="[PAT HERE]"
docker build --secret id=GH_OWNER --secret id=GH_PAT -t play.catalog:$version .
```

## Run the docker image
```powershell
docker run -it --rm -p 5002:5002 --name catalog -e MongoDBSettings__Host=mongo -e RabbitMQSettings__Host=rabbitmq  --network playinfra_default play.catalog:$version
```