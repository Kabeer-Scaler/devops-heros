# Session 17: CI/CD and DevSecOps

## Homework demo

`demo/` contains a Flask application, unit tests, Dockerfile, Kubernetes manifests, and GitHub Actions workflow.

The pipeline implements this security gate:

```text
Test -> CodeQL SAST -> pip-audit SCA -> Gitleaks secret scan
     -> Docker build -> Trivy image scan -> GHCR push -> Kubernetes deploy
```

The image now runs as a non-root user and the Kubernetes Deployment includes health probes and CPU/memory requests and limits.

## Evidence

- [Tests and non-root image verification](screenshots/task-1-devsecops-pipeline/tests-and-image.png)
- [Local Kubernetes rollout](screenshots/task-1-devsecops-pipeline/kubernetes-rollout.png)

## Local result

All 8 unit tests passed. The locally built `session17-python:local` image returned a healthy `/health` response and was deployed successfully to the isolated `homework-s17` namespace.

The GHCR push and GitHub-hosted workflow are defined in the workflow.
