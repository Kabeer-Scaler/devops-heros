# Session 20: Monitoring, Observability, and GitOps

## Homework tasks completed

1. **Monitoring:** Prometheus and Grafana were run locally with Docker Compose. Prometheus returned a successful `up` query and Grafana returned a healthy API response.
2. **Observability:** documentation and examples cover metrics, logs, and traces, their purpose, and Kubernetes observability. The local Metrics Server provided live node metrics and logs.
3. **GitOps:** declarative Deployment, Service, namespace, and Argo CD Application manifests are included. The Kubernetes manifests were validated with client-side dry runs; no external Git repository or Argo CD installation was created.

## Evidence

- [Prometheus and Grafana health](screenshots/task-1-monitoring/prometheus-grafana-health.png)
- [Live metrics and Metrics Server logs](screenshots/task-2-observability/cluster-metrics-and-logs.png)
- [GitOps manifest validation](screenshots/task-3-gitops/manifest-validation.png)

## Key model

```text
Metrics = numeric measurements
Logs    = discrete events
Traces  = a request's path through services

Git = desired state
Argo CD = reconciler
Kubernetes = actual state
```
