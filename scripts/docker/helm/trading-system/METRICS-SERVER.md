# 使用Metrics Server配置Kubernetes HPA

本文档提供有关如何配置和验证Metrics Server以支持交易系统的HPA功能的指南。交易系统现在完全依赖于kube-system命名空间中的metrics-server提供的指标，已移除所有Prometheus相关依赖。

## 什么是Metrics Server?

Metrics Server是Kubernetes的集群范围资源使用数据聚合器。它从集群中的每个节点上的kubelet收集CPU和内存使用情况数据。HPA控制器使用这些数据来调整pod副本数量。

## 先决条件

在使用metrics-server之前，请确保：

1. 您有一个正常运行的Kubernetes集群
2. 您有足够的权限安装集群级资源
3. 确保metrics-server已部署在kube-system命名空间

## 安装Metrics Server

Metrics Server通常使用Helm安装：

```bash
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm install metrics-server metrics-server/metrics-server --namespace kube-system
```

如果您在Minikube上运行，可以使用插件轻松启用它：

```bash
minikube addons enable metrics-server
```

## 验证Metrics Server安装

安装Metrics Server后，可以通过以下方式验证其运行状况：

```bash
# 检查Pod是否正在运行
kubectl get pods -n kube-system | grep metrics-server

# 验证API可用性
kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes"
```

如果metrics-server正常工作，您应该看到节点指标的JSON输出。

## 常见的Metrics Server问题与解决方案

### 1. API未注册错误

错误: `Error from server (NotFound): the server could not find the requested resource`

解决方案：
- 检查metrics-server pod是否正在运行
- 检查pod是否存在错误日志
- 确保API service已正确注册

```bash
kubectl get apiservice v1beta1.metrics.k8s.io -o yaml
```

### 2. 证书问题

错误: `unable to retrieve container metrics`

解决方案：
- 使用适当的TLS设置运行metrics-server
- 在安装时添加 `--kubelet-insecure-tls` 参数（仅测试环境）

```bash
helm install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  --set args="{--kubelet-insecure-tls}"
```

### 3. HPA无法获取指标

错误: `unable to fetch metrics from resource metrics API` 或 `failed to get cpu utilization`

解决方案：
- 确保pod和容器已定义资源请求和限制
- 等待metrics-server收集足够的数据（通常需要1-2分钟）
- 检查metrics-server的权限

## 验证HPA配置

部署trading-system chart后，验证HPA是否能够正确获取指标：

```bash
kubectl get hpa -n trading-system
```

输出应该类似于：

```
NAME              REFERENCE                    TARGETS                       MINPODS   MAXPODS   REPLICAS   AGE
identity-hpa      Deployment/identity          2%/70%, 15%/80%              1         3         1          5m
account-hpa       Deployment/account           5%/70%, 20%/80%              1         3         1          5m
```

如果您看到`<unknown>/70%`这样的目标值，可能表示metrics-server尚未收集足够的数据，或者存在配置问题。

## 交易系统HPA配置说明

交易系统现在完全依赖于kube-system命名空间中的metrics-server提供的标准资源指标（CPU和内存），而不再使用Prometheus自定义指标。这简化了部署流程，减少了对额外监控组件的依赖。

HPA配置中使用的指标类型：
- CPU利用率 - 用于自动扩展CPU密集型服务
- 内存利用率 - 用于自动扩展内存密集型服务

## 生成负载测试HPA

您可以使用以下命令生成负载来测试HPA功能：

```bash
# 创建一个临时pod用于生成负载
kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://trading-service:8080/trading/api/orders; done"
```

在另一个终端窗口中，监视HPA状态：

```bash
kubectl get hpa -n trading-system -w
```

您应该看到CPU利用率增加，并且副本数量相应增加。

## 结论

正确配置的metrics-server是HPA功能的关键。通过确保metrics-server已正确安装并且可以收集容器指标，trading-system的HPA可以根据CPU和内存使用情况自动扩展服务。交易系统现在仅使用这些标准资源指标，简化了整体架构并减少了依赖项。 