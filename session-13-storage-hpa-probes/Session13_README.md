# Session 13: Kubernetes Storage, HPA, and Probes

## Homework tasks completed

1. **Volumes:** documented and deployed `emptyDir`, `hostPath`, a manual PV/PVC pair, and a dynamic PVC. The manual PVC uses the explicit `manual` StorageClass so it binds to `student-pv` predictably.
2. **HPA:** deployed an Nginx workload, service, CPU-based HPA, and BusyBox load generator. Metrics Server was enabled locally; load raised CPU to 83% of the 50% target and the HPA requested a second replica.
3. **Mini project:** deployed the `production-webapp` namespace, PVC, Service, two-replica Deployment, startup/readiness/liveness probes, and HPA.

## Evidence

- Task 1 - [storage verification](screenshots/task-1-volumes/storage-verification.png)
- Task 2 - [HPA scaling under load](screenshots/task-2-hpa/hpa-scaling.png)
- Task 3 - [mini-project resources](screenshots/task-3-mini-project/resources.png)

## Commands used

```bash
kubectl apply -f 01-volumes/
kubectl apply -f 02-persistent-storage/
kubectl get pv,pvc,pods
kubectl get hpa
kubectl top pods
kubectl describe hpa hpa-demo
```

The implementation files are organized by topic under `01-volumes/` through `05-probes/` and `mini-project/`.
