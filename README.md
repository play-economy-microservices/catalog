# play.catalog

Play Economy Catalog microservice

## Add the GitHub package source

```powershell
$version="1.0.3"
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

## Create the Kubernetes Namespace

```powershell
$namespace="catalog"

kubectl create namespace $namespace
```

## Creating the Azure Managed Identity and granting it access to the Key Vault

```powershell
$namespace="catalog"
$appname="playeconomy"

az identity create --resource-group $appname --name $namespace

$IDENTITY_CLIENT_ID=az identity show -g $appname -n $namespace --query clientId -otsv
az keyvault set-policy -n $appname --secret-permissions get list --spn $IDENTITY_CLIENT_ID
```

## Create the Kubernetes Pod

```powershell
$namespace="catalog"

kubectl apply -f ./kubernetes/catalog.yaml -n $namespace
```

## Establish the federated identity credential

```powershell PowerShell
$appname="playeconomy"
$namespace="catalog"

$AKS_OIDC_ISSUER=az aks show -n $appname -g $appname --query "oidcIssuerProfile.issuerUrl" -otsv

az identity federated-credential create --name $namespace --identity-name $namespace
--resource-group $appname --issuer $AKS_OIDC_ISSUER --subject "system:serviceaccount:${namespace}:${namespace}-serviceaccount"
```

## Install the Helm Chart

```powershell
$appname="playeconomyacr"
$namespace="catalog"

$helmUser=[guid]::Empty.Guid
$helmPassword=az acr login --name $appname --expose-token --output tsv --query accessToken

# This is no longer needed after Helm v3.8.0

$env:HELM_EXPERIMENTAL_OCI=1

# authenticate

helm registry login "$appname.azurecr.io" --username $helmUser --password $helmPassword

# Install the Helm Chart from ACR with catalog Values

$chartVersion="0.1.0"
helm upgrade catalog-service oci://$appname.azurecr.io/helm/microservice --version $chartVersion -f ./helm/values.yaml -n $namespace --install
```
