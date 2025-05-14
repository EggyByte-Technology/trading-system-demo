helm install monitoring-stack prometheus-community/kube-prometheus-stack `
    --namespace monitoring --create-namespace `
    --set grafana.adminPassword="admin123" `
    --set grafana.service.type=ClusterIP `
    --set grafana.additionalDataSources[0].name="Loki" `
    --set grafana.additionalDataSources[0].type="loki" `
    --set grafana.additionalDataSources[0].access="proxy" `
    --set grafana.additionalDataSources[0].url="http://loki-stack.monitoring.svc.cluster.local:3100"


helm install loki-stack grafana/loki-stack `
    --namespace monitoring `
    --set grafana.enabled=false `
    --set prometheus.enabled=false `
    --set promtail.enabled=true

helm upgrade --install loki-stack grafana/loki-stack `
    --namespace monitoring --create-namespace `
    --set loki.persistence.enabled=true `
    --set loki.persistence.storageClassName=default-storage `
    --set loki.persistence.size=20Gi `
    --set grafana.enabled=true `
    --set grafana.adminPassword="admin123" `
    --set prometheus.enabled=true `
    --set promtail.enabled=true
    
helm upgrade --install trading-system builder\helm\trading-system --namespace=trading-system --create-namespace 

```
// 0. Configure the Helm repository
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

// 1. Install the Istio base chart which contains cluster-wide Custom Resource Definitions (CRDs) which must be installed prior to the deployment of the Istio control plane
helm install istio-base istio/base -n istio-system --set defaultRevision=default --create-namespace

// 2. Validate the CRD installation with the helm ls command
helm ls -n istio-system

// 3. Install the Istio discovery chart which deploys the istiod service
helm upgrade --install istiod istio/istiod -n istio-system `
    --set sidecarInjectorWebhook.enableNamespacesByDefault=true `
    --set values.global.proxy.autoInject=enabled `
    --set kiali.enabled=true `
    --create-namespace --wait

// 4. Verify the Istio discovery chart installation
helm ls -n istio-system

// 5. Get the status of the installed helm chart of istiod to ensure it is deployed
helm status istiod -n istio-system

// 6. Check istiod service is successfully installed and its pods are running
kubectl get deployments -n istio-system --output wide

// 7. Install an ingress gateway
helm upgrade --install istio-ingress istio/gateway -n istio-ingress `
    --set service.type=ClusterIP `
    --set meshConfig.accessLogFile="/dev/stdout" `
    --set meshConfig.accessLogEncoding="JSON" `
    --create-namespace --wait

// 8. Get the status of the installed helm chart of istio-ingress to ensure it is deployed
helm status istio-ingress -n istio-ingress
```

helm install kiali-server kiali/kiali-server `
    --namespace istio-system --create-namespace `
    --set auth.strategy="anonymous"