# Trading System Helm Chart

This Helm chart deploys the Trading System microservices with MongoDB sharded cluster using metrics-server for autoscaling.

## Prerequisites

- Kubernetes cluster
- Helm v3.0+
- Istio installed in the cluster
- Metrics Server installed in kube-system namespace

## Installation

1. Configure the `values.yaml` file with your specific settings
2. Install the chart:

```bash
helm install trading-system ./trading-system --namespace trading-system --create-namespace
```

## Architecture

This Helm chart deploys:

1. A Kubernetes namespace with Istio sidecar injection enabled
2. An Istio Gateway for external traffic
3. Virtual Services for each microservice to route traffic based on URL paths
4. Kubernetes Deployments and Services for each microservice
5. MongoDB sharded cluster with config servers, shard servers, and router
6. Horizontal Pod Autoscalers (HPA) for all services using metrics-server

## MongoDB Sharded Cluster

The chart deploys a MongoDB sharded cluster with:

- Config servers (3 replicas in a replica set)
- Shard servers (2 shards with 2 replicas each)
- Router (mongos) instances (2 replicas)

All microservices are configured to connect to the MongoDB router.

## Autoscaling Configuration

### Metrics Server

This chart uses the Kubernetes [Metrics Server](https://github.com/kubernetes-sigs/metrics-server) for HPA (Horizontal Pod Autoscaler) functionality. Metrics Server should be installed separately in your Kubernetes cluster.

To install Metrics Server:

```
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm install metrics-server metrics-server/metrics-server --namespace kube-system
```

### HPA Configuration

HPA is configured to use CPU and memory metrics from the Metrics Server deployed in the kube-system namespace.

```yaml
# Basic HPA Configuration
hpa:
  enabled: true
  minReplicas: 1
  maxReplicas: 5
  metrics:
    cpu:
      enabled: true
      targetAverageUtilization: 70
    memory:
      enabled: true
      targetAverageUtilization: 80
```

## Configuration

### Global Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.domain` | Domain name for the application | `trading-system.example.com` |
| `global.namespace` | Kubernetes namespace | `trading-system` |
| `global.istio.gateway` | Name of the Istio gateway | `trading-system-gateway` |

### MongoDB Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `mongodb.shardedCluster` | Enable sharded cluster | `true` |
| `mongodb.auth.rootUsername` | MongoDB root username | `root` |
| `mongodb.auth.rootPassword` | MongoDB root password | `aB8zD3fG5hJ7kL9mN1pQ3rS5tV7xY9zAcEgIkMoQs` |
| `mongodb.configServer.replicas` | Config server replicas | `3` |
| `mongodb.shardServer.replicas` | Replicas per shard | `2` |
| `mongodb.shardServer.shards` | Number of shards | `2` |
| `mongodb.router.replicas` | Router (mongos) replicas | `2` |

### HPA Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `hpa.enabled` | Enable HPA | `true` |
| `hpa.minReplicas` | Minimum replicas | `1` |
| `hpa.maxReplicas` | Maximum replicas | `5` |
| `hpa.metrics.cpu.targetAverageUtilization` | Target CPU utilization | `70` |

### Service Settings

Each service has the following configurable parameters:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `services.[service].name` | Service name | Various defaults |
| `services.[service].port` | Service port | `8080` |
| `services.[service].path` | URL path prefix | Varies by service |
| `services.[service].containerPort` | Container port | `8080` |
| `services.[service].image` | Image name | Service name |
| `services.[service].hpa.enabled` | Enable HPA for service | `true` |
| `services.[service].hpa.minReplicas` | Min replicas for service | Varies |
| `services.[service].hpa.maxReplicas` | Max replicas for service | Varies |

### Istio Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `istio.gateway.hosts` | List of hosts for the gateway | `["trading-system.example.com", "localhost"]` |
| `istio.gateway.tls.enabled` | Enable TLS | `false` |

## Services and Routes

| Service | URL Path | Description |
|---------|----------|-------------|
| Identity Service | `/identity/*` | Authentication and user management |
| Account Service | `/account/*` | Account and asset management |
| Market Data Service | `/market-data/*` | Market data and metrics |
| Trading Service | `/trading/*` | Order management |
| Risk Service | `/risk/*` | Risk evaluation and control |
| Notification Service | `/notification/*` | Notifications management |
| WebSocket | `/ws/*` | Real-time data streaming | 