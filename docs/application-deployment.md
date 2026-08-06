# Weather Application Deployment Guide

This guide explains how to run, containerize, and deploy the Remix Weather
Application to the test and production Azure Kubernetes Service (AKS)
environments.

## Prerequisites

- Node.js 18 or later
- npm
- Docker
- Azure CLI
- `kubectl`
- Access to the team's Azure subscription
- An OpenWeather API key
- The test and production AKS clusters created by Terraform
- The Azure Container Registry (ACR) created by Terraform
- The test and production Azure Cache for Redis instances

## Required configuration

The application reads its configuration from environment variables.

| Variable | Secret | Description |
| --- | --- | --- |
| `WEATHER_API_KEY` | Yes | OpenWeather API key |
| `REDIS_HOST` | No | Azure Redis hostname |
| `REDIS_PORT` | No | Redis port; Azure TLS connections normally use `6380` |
| `REDIS_PASSWORD` | Yes | Azure Redis access key |
| `REDIS_TLS` | No | Set to `true` for Azure Redis and `false` for local Redis |
| `PORT` | No | Application port; defaults to `3000` |
| `NODE_ENV` | No | Runtime environment |

Never commit API keys, Redis access keys, `.env` files, or a real
`k8s/**/secret.yaml` file.

## Install and validate the application

From the repository root, install the locked dependencies:

```bash
npm ci
```

Run the local checks:

```bash
npm run typecheck
npm run lint
npm run build
```

## Run the application locally

Enter the OpenWeather API key without saving it in shell history:

```bash
read -s "WEATHER_API_KEY?Enter OpenWeather API key: "; export WEATHER_API_KEY; echo
```

Start the application:

```bash
npm run dev
```

Open <http://localhost:3000>. Stop the application with `Control+C`.

## Test Redis caching locally

Start a temporary Redis container:

```bash
docker run --rm --name weather-redis -p 6379:6379 redis:7-alpine
```

In another terminal, configure the application to use local Redis:

```bash
export REDIS_HOST=127.0.0.1
export REDIS_PORT=6379
export REDIS_TLS=false
read -s "WEATHER_API_KEY?Enter OpenWeather API key: "; export WEATHER_API_KEY; echo
npm run dev
```

Open or refresh <http://localhost:3000> twice. The application log should show
a write followed by a cache hit:

```text
Saved weather data to Redis: weather:45.3211:-75.7391:metric
Redis cache hit: weather:45.3211:-75.7391:metric
```

The cache entry expires after ten minutes. If Redis is unavailable, the
application falls back to in-memory caching.

## Build and run the Docker image

Build the image from the repository root:

```bash
docker build -t weather-app:local .
```

Run the image with the OpenWeather API key from the current shell:

```bash
docker run --rm \
  --name weather-app \
  -p 3000:3000 \
  -e WEATHER_API_KEY \
  weather-app:local
```

Open <http://localhost:3000>. Stop the container with `Control+C`.

## Values required from the Azure infrastructure

Obtain the following values from the Terraform outputs or the team member
responsible for the Azure infrastructure:

- ACR login server
- Test AKS resource group and cluster name
- Production AKS resource group and cluster name
- Test Redis hostname and access key
- Production Redis hostname and access key

The AKS managed identities must have permission to pull images from ACR.

## Build and push an image to ACR manually

CI/CD normally performs this step. For manual verification, set the values for
the team's ACR and the image tag:

```bash
export ACR_NAME="replace-with-acr-name"
export ACR_LOGIN_SERVER="${ACR_NAME}.azurecr.io"
export IMAGE_TAG="$(git rev-parse --short HEAD)"

az login
az acr login --name "$ACR_NAME"

docker build \
  -t "${ACR_LOGIN_SERVER}/weather-app:${IMAGE_TAG}" \
  .

docker push "${ACR_LOGIN_SERVER}/weather-app:${IMAGE_TAG}"
```

Use an immutable commit SHA tag instead of `latest` for AKS deployments.

## Kubernetes structure

The Kubernetes configuration uses a reusable base with environment overlays:

```text
k8s/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   ├── secret.example.yaml
│   └── kustomization.yaml
├── test/
│   ├── namespace.yaml
│   └── kustomization.yaml
└── prod/
    ├── namespace.yaml
    └── kustomization.yaml
```

The test deployment uses one replica. The production deployment uses two
application replicas and can run on the autoscaling production AKS cluster.

## Configure an environment overlay

Before deployment, update the selected overlay with the real ACR login server,
image tag, and Redis hostname. The committed placeholder values are:

```text
replace-with-acr-name.azurecr.io
replace-with-test-redis-hostname
replace-with-prod-redis-hostname
```

Update the `images` section in the selected overlay without changing the base
Deployment:

```yaml
images:
  - name: weather-app
    newName: replace-with-acr-name.azurecr.io/weather-app
    newTag: replace-with-commit-sha
```

Make this change in `k8s/test/kustomization.yaml` or
`k8s/prod/kustomization.yaml` as appropriate. CI/CD should perform the same
image replacement with the current commit SHA.

Render and inspect an overlay before applying it:

```bash
kubectl kustomize k8s/test
kubectl kustomize k8s/prod
```

## Deploy to the test AKS cluster

Get the test cluster credentials:

```bash
export TEST_AKS_RESOURCE_GROUP="replace-with-test-resource-group"
export TEST_AKS_CLUSTER="replace-with-test-cluster-name"

az aks get-credentials \
  --resource-group "$TEST_AKS_RESOURCE_GROUP" \
  --name "$TEST_AKS_CLUSTER" \
  --overwrite-existing
```

Apply the namespace first:

```bash
kubectl apply -f k8s/test/namespace.yaml
```

Create or update the Secret without writing a secret file:

```bash
read -s "WEATHER_API_KEY?Enter OpenWeather API key: "; export WEATHER_API_KEY; echo
read -s "REDIS_PASSWORD?Enter test Redis access key: "; export REDIS_PASSWORD; echo

kubectl create secret generic weather-app-secrets \
  --namespace weather-test \
  --from-literal=WEATHER_API_KEY="$WEATHER_API_KEY" \
  --from-literal=REDIS_PASSWORD="$REDIS_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -
```

Deploy the test overlay:

```bash
kubectl apply -k k8s/test
kubectl rollout status deployment/weather-app \
  --namespace weather-test \
  --timeout=180s
```

## Deploy to the production AKS cluster

Get the production cluster credentials:

```bash
export PROD_AKS_RESOURCE_GROUP="replace-with-prod-resource-group"
export PROD_AKS_CLUSTER="replace-with-prod-cluster-name"

az aks get-credentials \
  --resource-group "$PROD_AKS_RESOURCE_GROUP" \
  --name "$PROD_AKS_CLUSTER" \
  --overwrite-existing
```

Apply the namespace and create the production Secret:

```bash
kubectl apply -f k8s/prod/namespace.yaml

read -s "WEATHER_API_KEY?Enter OpenWeather API key: "; export WEATHER_API_KEY; echo
read -s "REDIS_PASSWORD?Enter production Redis access key: "; export REDIS_PASSWORD; echo

kubectl create secret generic weather-app-secrets \
  --namespace weather-prod \
  --from-literal=WEATHER_API_KEY="$WEATHER_API_KEY" \
  --from-literal=REDIS_PASSWORD="$REDIS_PASSWORD" \
  --dry-run=client -o yaml | kubectl apply -f -
```

Deploy the production overlay:

```bash
kubectl apply -k k8s/prod
kubectl rollout status deployment/weather-app \
  --namespace weather-prod \
  --timeout=180s
```

## Verify a deployment

Check the Kubernetes resources:

```bash
export APP_NAMESPACE="weather-test"
kubectl get pods,service,deployment --namespace "$APP_NAMESPACE"
```

Wait for the `EXTERNAL-IP` on the `weather-app` LoadBalancer Service:

```bash
kubectl get service weather-app \
  --namespace "$APP_NAMESPACE" \
  --watch
```

Open the external IP shown by the command and refresh the page twice. Check the application
logs for a Redis write and cache hit:

```bash
kubectl logs \
  --namespace "$APP_NAMESPACE" \
  deployment/weather-app \
  --tail=100
```

## Troubleshooting

### Pod remains in `Pending`

```bash
export POD_NAME="replace-with-pod-name"
kubectl describe pod "$POD_NAME" --namespace "$APP_NAMESPACE"
```

Check AKS node capacity, resource requests, and scheduling events.

### `ImagePullBackOff`

Confirm that the image and tag exist in ACR and that the AKS managed identity
has the `AcrPull` role.

### `CreateContainerConfigError`

Confirm that `weather-app-secrets` exists in the same namespace as the
Deployment:

```bash
kubectl get secret weather-app-secrets --namespace "$APP_NAMESPACE"
```

### Redis connection errors

Confirm the environment-specific Redis hostname, port `6380`, TLS setting, and
access key. Review the application logs without printing the Secret values.

### Application rollout fails

```bash
kubectl rollout status deployment/weather-app --namespace "$APP_NAMESPACE"
kubectl describe deployment weather-app --namespace "$APP_NAMESPACE"
kubectl logs deployment/weather-app --namespace "$APP_NAMESPACE" --tail=100
```

## Cleanup

Remove only the application resources from an environment:

```bash
kubectl delete -k k8s/test
kubectl delete -k k8s/prod
```

After testing and submission, the team must destroy the Azure infrastructure
with the appropriate Terraform environment configuration to avoid charges and
the course overuse penalty.
