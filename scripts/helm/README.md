# Trading System Helm Charts

This directory contains Helm charts for deploying the Trading System application and its monitoring infrastructure on Kubernetes.

## Overview

The Trading System Helm deployment consists of:

1. **Trading System** - A microservices-based financial trading platform
2. **Metrics Server** - Monitoring and metrics collection
3. **MongoDB** - Sharded database cluster for Trading System data

## Prerequisites

- Kubernetes cluster (v1.19+)
- Helm v3.7+
- kubectl configured to connect to your cluster
- Istio (optional, for service mesh features)

## Quick Start

Use the `helm-install.ps1` script to deploy all components:

```powershell
# From the helm directory
./helm-install.ps1
```

This will deploy:
- Prometheus in the "monitoring" namespace
- Trading System in the "trading-system" namespace

## Custom Deployment

You can customize the deployment by specifying which charts to install and their namespace:

```powershell
# Deploy only Trading System with a custom namespace
./helm-install.ps1 -Charts "trading-system" -NamespaceMap @{"trading-system" = "finance-app"}

# Deploy with custom values files
./helm-install.ps1 -Values @{
  prometheus = "./prometheus/my-prometheus-values.yaml";
  "trading-system" = "./trading-system/my-trading-values.yaml"
}
```

## Architecture

### Trading System Components

The Trading System consists of the following microservices:

- **Identity Service** - Authentication and user management
- **Account Service** - Financial accounts and balances
- **Market Data Service** - Real-time market data
- **Trading Service** - Order execution and management
- **Risk Service** - Risk assessment and limits
- **Notification Service** - Real-time notifications and WebSockets

### MongoDB Sharded Cluster

The system uses a MongoDB sharded cluster with:

- Config Servers (3 replicas)
- Shard Servers (2 shards, 2 replicas each)
- Router (mongos) instances (2 replicas)

### Monitoring and Scaling

The deployment includes:

- **Prometheus and Grafana** for metrics collection and visualization
- **Custom HPA metrics** for autoscaling based on custom metrics
- **Prometheus Adapter** for exposing metrics to Kubernetes
- **Service Monitors** for automatic service discovery

## Monitoring Configuration

The Trading System exposes metrics that Prometheus collects for monitoring and HPA:

1. **Service Metrics** - HTTP request count, error rates, latencies
2. **MongoDB Metrics** - Connection counts, operation rates, replication lag
3. **Infrastructure Metrics** - CPU, memory, network usage

Grafana dashboards are provided for:
- Trading System Overview
- MongoDB Performance
- Service Request Rates

## Horizontal Pod Autoscaling (HPA)

The system uses HPA based on:

1. **CPU and Memory usage**
2. **Request rate**
3. **MongoDB operation rates**

The HPA settings can be tuned in `values-custom.yaml` files.

## Access Services

After deployment, you can access:

1. **Grafana Dashboard**:
   ```shell
   kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
   # Access at http://localhost:3000 (default username: admin, password: admin)
   ```

2. **Trading System API**:
   ```shell
   kubectl port-forward -n trading-system svc/identity 8080:8080
   # Access at http://localhost:8080
   ```

## Further Documentation

- [Trading System API Documentation](../api-interface-documentation.md)
- [Prometheus Documentation](https://prometheus.io/docs/prometheus/latest/getting_started/)
- [Kubernetes HPA Documentation](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) 