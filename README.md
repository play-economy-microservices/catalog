# play.catalog
Play Economy Catalog microservice


## Add the GitHub package source
```powershell
$version="1.0.2"
$owner="play-economy-microservices"
$gh_pat="[PAT HERE]"

dotnet pack src/Play.Catalog.Contracts/ --configuration Release -p:PackageVersion=$version -p:RepositoryUrl=https://github.com/$owner/play.catalog -o ../packages

dotnet nuget push ../packages/Play.Catalog.Contracts.$version.nupkg --api-key $gh_pat --source "github"
```

## Build the docker image
```powershell
$env:GH_OWNER="play-economy-microservices"
$env:GH_PAT="[PAT HERE]"
docker build --secret id=GH_OWNER --secret id=GH_PAT -t "$appname.azurecr.io/play.catalog:$version" .
```

## Run the docker image
```powershell
$cosmosDbConnString="[CONN STRING HERE]"
$serviceBusConnString="[CONN STRING HERE]"
docker run -it --rm -p 5001:5000 --name catalog -e 
MongoDBSettings__ConnectionString=$cosmosDbConnString -e 
ServiceBusSettings__ConnectionString=$serviceBusConnString -e
ServiceSettings__MessageBroker="SERVICEBUS" play.catalog:$version
```

## Publishing the Docker image
```powershell
$appname="playeconomycontainerregistry"
$version="1.0.2"
$env:GH_PAT="[PAT HERE]"
az acr login --name $appname
docker push "$appname.azurecr.io/play.catalog:$version"
```
