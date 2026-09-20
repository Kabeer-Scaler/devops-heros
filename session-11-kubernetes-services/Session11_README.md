# Session 11: Kubernetes Services, DNS & Workload Identity

**Author:** [Your Name]  
**Course:** SST DevOps & Cloud [SWE]  
**Session:** 11  
**Repository Directory:** `session-11-kubernetes-services`

> **Submission note:** The commands and task structure below are based on the supplied **DevOps Assignment Season 2** Markdown. Obvious URL-formatting artifacts caused by Markdown rendering have been normalized so the shell commands are copyable. Terminal output is machine-specific, so every task contains a placeholder that must be replaced with your real output before submission.


```bash
mkdir -p screenshots
```

This session covers Kubernetes Service types, DNS/service discovery, workload identity and service-selection architecture.

---
## Task 1: Kubernetes Port Architecture & Clarification Drill

- **Short Description:** Document and visually map the 4 distinct port definitions in Kubernetes. Illustrate how a packet flows from an external client through the node, into the service, and down to the application process inside the container.
- **Manifest Reference:** Concept mapping across all `service.yaml` and `app-deployment.yaml` files.
- **Key Commands to Run:**
    
    ```bash
    # Inspect port declarations across pod and service
    kubectl explain pod.spec.containers.ports.containerPort
    kubectl explain service.spec.ports
    ```
    
- **Architecture Flowchart to Document:**
    
    ```
    Client Browser ──► [nodePort: 30080] (Host IP)
                            │
                            ▼
                       [port: 8080] (Service VIP)
                            │
                            ▼
                       [targetPort: 80] (Pod Network)
                            │
                            ▼
                       [containerPort: 80] (Container Engine / Nginx)
    ```

### Solution / Observation

The packet-flow model for the assignment is `nodePort -> Service port -> targetPort -> application/container port`. `containerPort` documents the container-side application port; `targetPort` is where the Service forwards; `port` is the Service port; `nodePort` exposes a high port on nodes.

### Actual Terminal Output

Replace the placeholder below with the output from **your own machine**. Do not submit the sample/expected output as if it were your execution.

```text
PASTE YOUR ACTUAL TERMINAL OUTPUT FOR TASK 1 HERE
```

### Screenshot

Combine the required evidence for this task into one screenshot and save it as `screenshots/task1.png`.

![Task 1](./screenshots/task1.png)

---

## Task 2: Type 1 Service — ClusterIP (Default Internal Networking)

- **Short Description:** Deploy a 3-replica backend (`web-app-clusterip`), create a `ClusterIP` service on port `8080` targeting container port `80`, inspect automatic endpoint binding, and test connectivity from an ephemeral client pod using short names and full FQDN.
- **Working Directory:** `session-11-kubernetes-services/01-clusterip/`
- **Commands to Run:**
    
    ```bash
    # 1. Deploy backend app and ClusterIP service
    kubectl apply -f 01-clusterip/app-deployment.yaml
    kubectl apply -f 01-clusterip/service.yaml
    
    # 2. Verify pods, service, and endpoints
    kubectl get pods -l app=web-clusterip -o wide
    kubectl get svc web-service-clusterip
    kubectl get endpoints web-service-clusterip
    
    # 3. Deploy diagnostic client pod
    kubectl apply -f 01-clusterip/client-pod.yaml
    kubectl wait --for=condition=ready pod/curl-client --timeout=60s
    
    # 4. Test internal resolution methods from inside the cluster
    kubectl exec -it curl-client -- curl -s http://web-service-clusterip:8080 | grep -i "<title>"
    kubectl exec -it curl-client -- curl -s http://web-service-clusterip.default.svc.cluster.local:8080 | grep -i "<title>"
    ```

### Solution / Observation

A ClusterIP Service is reachable from inside the cluster. Successful DNS/service-name and FQDN curls prove both CoreDNS resolution and Service-to-Pod endpoint routing.

### Actual Terminal Output

Replace the placeholder below with the output from **your own machine**. Do not submit the sample/expected output as if it were your execution.

```text
PASTE YOUR ACTUAL TERMINAL OUTPUT FOR TASK 2 HERE
```

### Screenshot

Combine the required evidence for this task into one screenshot and save it as `screenshots/task2.png`.

![Task 2](./screenshots/task2.png)

---

## Task 3: Type 2 Service — NodePort (Host-Level External Ingress)

- **Short Description:** Deploy a 2-replica Nginx app and expose it externally by opening port `30080` on every cluster node. Verify that hitting any node IP on port `30080` directs traffic to the underlying pods.
- **Working Directory:** `session-11-kubernetes-services/02-nodeport/`
- **Commands to Run:**
    
    ```bash
    # 1. Deploy application and NodePort service
    kubectl apply -f 02-nodeport/app-deployment.yaml
    kubectl apply -f 02-nodeport/service.yaml
    
    # 2. Verify the NodePort mapping
    kubectl get svc web-service-nodeport
    
    # 3. Retrieve Minikube IP and verify node port access
    MINIKUBE_IP=$(minikube ip)
    curl -I http://${MINIKUBE_IP}:30080
    
    # 4. Alternatively test via minikube service tunnel (macOS/Docker driver)
    minikube service web-service-nodeport --url
    ```

### Solution / Observation

A NodePort Service exposes a high node port (the assignment uses `30080`). If direct Minikube-node routing is unavailable with the Docker driver, `minikube service ... --url` provides a host-reachable forwarding URL.

### Actual Terminal Output

Replace the placeholder below with the output from **your own machine**. Do not submit the sample/expected output as if it were your execution.

```text
PASTE YOUR ACTUAL TERMINAL OUTPUT FOR TASK 3 HERE
```

### Screenshot

Combine the required evidence for this task into one screenshot and save it as `screenshots/task3.png`.

![Task 3](./screenshots/task3.png)

---

## Task 4: Type 3 Service — LoadBalancer (Cloud-Native Ingress Simulation)

- **Short Description:** Deploy a 3-replica workload exposed through `type: LoadBalancer`. Use `minikube tunnel` to simulate a cloud provider assigning an `EXTERNAL-IP`, and confirm that Kubernetes automatically configures internal `NodePort` and `ClusterIP` layers.
- **Working Directory:** `session-11-kubernetes-services/03-loadbalancer/`
- **Commands to Run:**
    
    ```bash
    # 1. Deploy application and LoadBalancer service
    kubectl apply -f 03-loadbalancer/app-deployment.yaml
    kubectl apply -f 03-loadbalancer/service.yaml
    
    # 2. Check service status (will initially show <pending> without tunnel)
    kubectl get svc web-service-loadbalancer
    
    # 3. In a separate terminal, start the Minikube LoadBalancer tunnel
    minikube tunnel
    
    # 4. In primary terminal, observe EXTERNAL-IP populated
    kubectl get svc web-service-loadbalancer
    
    # 5. Access the application directly on standard port 80
    EXTERNAL_IP=$(kubectl get svc web-service-loadbalancer -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    curl -s "http://${EXTERNAL_IP}:80" | grep -i "<title>"
    ```

### Solution / Observation

A `LoadBalancer` Service initially lacks a cloud-assigned external address in local Minikube. `minikube tunnel` simulates the external-load-balancer path so the Service receives an external IP that can be tested directly.

### Actual Terminal Output

Replace the placeholder below with the output from **your own machine**. Do not submit the sample/expected output as if it were your execution.

```text
PASTE YOUR ACTUAL TERMINAL OUTPUT FOR TASK 4 HERE
```

### Screenshot

Combine the required evidence for this task into one screenshot and save it as `screenshots/task4.png`.

![Task 4](./screenshots/task4.png)

---

## Task 5: Type 4 Service — ExternalName (CoreDNS CNAME Alias Redirection)

- **Short Description:** Create an `ExternalName` service that acts as an internal DNS CNAME alias pointing to an external domain (e.g., `api.github.com`). Verify that no cluster IP or endpoints are created, and confirm CNAME resolution using `nslookup`.
- **Working Directory:** `session-11-kubernetes-services/04-externalname/`
- **Commands to Run:**
    
    ```bash
    # 1. Apply ExternalName service and client pod
    kubectl apply -f 04-externalname/service.yaml
    kubectl apply -f 04-externalname/client-pod.yaml
    kubectl wait --for=condition=ready pod/dns-test-client --timeout=60s
    
    # 2. Inspect the service (Notice CLUSTER-IP is <none>, EXTERNAL-IP is the target domain)
    kubectl get svc external-database-service
    
    # 3. Verify DNS resolution returns canonical name (CNAME)
    kubectl exec -it dns-test-client -- nslookup external-database-service
    
    # 4. Test outbound traffic through the alias
    kubectl exec -it dns-test-client -- curl -s -k https://external-database-service
    ```

### Solution / Observation

An `ExternalName` Service has no Pod selector or normal endpoint set; DNS returns a CNAME-style alias to the configured external hostname. `nslookup` inside the client Pod is the key proof.

### Actual Terminal Output

Replace the placeholder below with the output from **your own machine**. Do not submit the sample/expected output as if it were your execution.

```text
PASTE YOUR ACTUAL TERMINAL OUTPUT FOR TASK 5 HERE
```

### Screenshot

Combine the required evidence for this task into one screenshot and save it as `screenshots/task5.png`.

![Task 5](./screenshots/task5.png)

---

## Task 6: Type 5 Service — Headless Service (`clusterIP: None` & Stateful Workloads)

- **Short Description:** Deploy a 3-replica `StatefulSet` with a Headless Service (`clusterIP: None`). Prove that CoreDNS returns individual `A` records for all matching Pod IPs directly rather than a single VIP, and curl an ordinal pod hostname directly.
- **Working Directory:** `session-11-kubernetes-services/05-headless/`
- **Commands to Run:**
    
    ```bash
    # 1. Apply Headless service and StatefulSet
    kubectl apply -f 05-headless/service.yaml
    kubectl apply -f 05-headless/app-statefulset.yaml
    kubectl apply -f 05-headless/client-pod.yaml
    
    # 2. Wait for stateful pods (web-stateful-0, 1, 2) to become Ready
    kubectl rollout status statefulset/web-stateful --timeout=120s
    kubectl get pods -l app=web-headless -o wide
    
    # 3. Inspect Service (Notice CLUSTER-IP is explicitly None)
    kubectl get svc web-service-headless
    
    # 4. Perform DNS lookup on Headless Service name -> Returns ALL pod IPs
    kubectl exec -it headless-dns-client -- nslookup web-service-headless
    
    # 5. Query an individual Pod directly via its stable FQDN
    kubectl exec -it headless-dns-client -- nslookup web-stateful-0.web-service-headless.default.svc.cluster.local
    kubectl exec -it headless-dns-client -- curl -s http://web-stateful-0.web-service-headless:80 | grep -i "<title>"
    ```

### Solution / Observation

With `clusterIP: None`, DNS can return Pod addresses rather than one Service VIP. Pairing the headless Service with a StatefulSet also enables stable ordinal hostnames such as `web-stateful-0.<service>`.

### Actual Terminal Output

Replace the placeholder below with the output from **your own machine**. Do not submit the sample/expected output as if it were your execution.

```text
PASTE YOUR ACTUAL TERMINAL OUTPUT FOR TASK 6 HERE
```

### Screenshot

Combine the required evidence for this task into one screenshot and save it as `screenshots/task6.png`.

![Task 6](./screenshots/task6.png)

---

## Task 7: Services Without Selectors (Manual Endpoints Mapping)

- **Short Description:** Define a Service without selectors (`empty-endpoints.yaml` pattern) and manually bind it to an external backend IP address using a separate `Endpoints` manifest. Demonstrate how Kubernetes abstracts legacy or external infrastructure.
- **Commands to Run:**
    
    ```bash
    # 1. Create Service without a selector
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Service
    metadata:
      name: external-legacy-db
    spec:
      ports:
        - protocol: TCP
          port: 3306
          targetPort: 3306
    EOF
    
    # 2. Verify endpoints are initially empty (<none>)
    kubectl get endpoints external-legacy-db
    
    # 3. Manually create matching Endpoints object pointing to external IP
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Endpoints
    metadata:
      name: external-legacy-db
    subsets:
      - addresses:
          - ip: 192.168.1.150
        ports:
          - port: 3306
    EOF
    
    # 4. Verify endpoints are now successfully attached
    kubectl get endpoints external-legacy-db
    ```

### Solution / Observation

Without a selector, Kubernetes cannot automatically discover backend Pods. A manually created Endpoints object with the same Service name supplies the destination address explicitly, demonstrating routing to legacy/external infrastructure.

### Actual Terminal Output

Replace the placeholder below with the output from **your own machine**. Do not submit the sample/expected output as if it were your execution.

```text
PASTE YOUR ACTUAL TERMINAL OUTPUT FOR TASK 7 HERE
```

### Screenshot

Combine the required evidence for this task into one screenshot and save it as `screenshots/task7.png`.

![Task 7](./screenshots/task7.png)

---

## Task 8: FQDN & CoreDNS Deep Dive Architecture Analysis

- **Short Description:** Inspect the cluster DNS configuration inside running pods. Break down the anatomy of a Kubernetes FQDN, examine `/etc/resolv.conf`, test search domain completion, and explain why `ndots:5` causes latency in production when making external API calls.
- **Commands to Run:**
    
    ```bash
    # 1. Verify CoreDNS pods are active in kube-system
    kubectl get pods -n kube-system -l k8s-app=kube-dns -o wide
    
    # 2. Inspect /etc/resolv.conf inside any running pod
    kubectl exec -it curl-client -- cat /etc/resolv.conf
    
    # 3. Test DNS search domain expansion
    # Querying 'web-service-clusterip' automatically expands to:
    # 'web-service-clusterip.default.svc.cluster.local'
    kubectl exec -it curl-client -- nslookup web-service-clusterip
    
    # 4. Demonstrate ndots:5 external query latency mechanism
    # Queries to an external domain (e.g., api.stripe.com) will traverse local search paths first
    kubectl exec -it curl-client -- nslookup api.github.com
    ```

### Solution / Observation

Kubernetes service discovery expands short names through search suffixes such as `<namespace>.svc.cluster.local`. Inspecting `/etc/resolv.conf` exposes the DNS server, search list and `ndots:5`; external names with too few dots may be tried against search suffixes first, creating extra DNS lookups.

### Actual Terminal Output

Replace the placeholder below with the output from **your own machine**. Do not submit the sample/expected output as if it were your execution.

```text
PASTE YOUR ACTUAL TERMINAL OUTPUT FOR TASK 8 HERE
```

### Screenshot

Combine the required evidence for this task into one screenshot and save it as `screenshots/task8.png`.

![Task 8](./screenshots/task8.png)

---

## Task 9: Pod Identity & Lifecycle Invariance Drill — Deployment (Stateless) vs. StatefulSet (Stateful)

- **Short Description:** Deploy both a stateless Deployment and an ordinal StatefulSet. Inspect their naming schemes, delete a running pod from each controller using `kubectl delete pod`, and observe that the Deployment spawns an ephemeral pod with a completely new random hash, whereas the StatefulSet strictly resurrects the exact same ordinal index (`web-stateful-0`).
- **Manifest Reference:**
    - Deployment: `session-11-kubernetes-services/01-clusterip/app-deployment.yaml`
    - StatefulSet: `session-11-kubernetes-services/05-headless/app-statefulset.yaml`
    - Service: `session-11-kubernetes-services/05-headless/service.yaml`
- **Commands to Run:**
    
    ```bash
    # 1. Apply both workloads
    kubectl apply -f session-11-kubernetes-services/01-clusterip/app-deployment.yaml
    kubectl apply -f session-11-kubernetes-services/05-headless/service.yaml
    kubectl apply -f session-11-kubernetes-services/05-headless/app-statefulset.yaml
    
    # 2. Wait for pods to become Ready and observe the naming conventions
    kubectl get pods -l app=web-clusterip
    kubectl get pods -l app=web-headless
    
    # 3. Capture the exact pod names before deletion
    DEPLOY_POD=$(kubectl get pods -l app=web-clusterip -o jsonpath='{.items[0].metadata.name}')
    echo "Deleting Stateless Deployment Pod: ${DEPLOY_POD}"
    kubectl delete pod "${DEPLOY_POD}"
    
    # 4. Check the Deployment pods immediately — notice a brand-new random hash is generated!
    kubectl get pods -l app=web-clusterip
    
    # 5. Delete an ordinal StatefulSet pod (web-stateful-0)
    echo "Deleting StatefulSet Pod: web-stateful-0"
    kubectl delete pod web-stateful-0
    
    # 6. Check the StatefulSet pods immediately — notice web-stateful-0 is recreated identically!
    kubectl get pods -l app=web-headless
    ```
    
- **Expected Behavioral Comparison:**
    - **Stateless Pod Deleted:** `web-app-clusterip-6c679b9456-4d9vz` ──► Replaced by: `web-app-clusterip-6c679b9456-x8k2m` *(New random identity)*
    - **Stateful Pod Deleted:** `web-stateful-0` ──► Replaced by: `web-stateful-0` *(Deterministic, invariant identity)*

### Solution / Observation

Deployment Pod identity is disposable: deleting one yields a replacement with a new generated suffix. StatefulSet identity is ordinal: deleting `web-stateful-0` causes the controller to recreate `web-stateful-0`.

### Actual Terminal Output

Replace the placeholder below with the output from **your own machine**. Do not submit the sample/expected output as if it were your execution.

```text
PASTE YOUR ACTUAL TERMINAL OUTPUT FOR TASK 9 HERE
```

### Screenshot

Combine the required evidence for this task into one screenshot and save it as `screenshots/task9.png`.

![Task 9](./screenshots/task9.png)

---

## Task 10: Master Architectural Matrix — Deployment vs. StatefulSet vs. DaemonSet

- **Short Description:** Create an engineering reference matrix evaluating the differences between Deployments, StatefulSets, and DaemonSets. Document their scheduling paradigms, storage lifetimes, identity models, network coupling, and failure domains.
- **Manifests Inspected:**
    - `session10-k8s-core-objects/deployment/deployment-v1.yaml`
    - `session10-k8s-core-objects/daemonset/node-agent-ds.yaml`
    - `session10-k8s-core-objects/k8s-core-objects/statefulset.yml`
- **Commands to Run:**
    
    ```bash
    # Inspect resource definitions and schema specifications
    kubectl explain deployment.spec
    kubectl explain statefulset.spec
    kubectl explain daemonset.spec
    ```
    
- **Engineering Matrix to Document in Submission:**

| Architectural Metric | Deployment | StatefulSet | DaemonSet |
| --- | --- | --- | --- |
| **Primary Workload Type** | Stateless microservices, Web APIs | Clustered databases, Distributed queues | Node-level infrastructure agents |
| **Pod Naming Scheme** | Random hash (`<deploy>-<rs-hash>-<random>`) | Deterministic ordinal (`<name>-0, 1, 2`) | Deterministic node hash (`<ds>-<random>`) |
| **Pod Identity Persistence** | Ephemeral (disposable upon death) | Invariant (identity, IP, hostname stick) | Bound to individual worker node |
| **Startup / Shutdown Order** | Non-ordered, parallel | Strictly sequential (`0 -> 1 -> 2`, reversed on termination) | Parallel across all eligible nodes |
| **Storage Mechanism** | Shared volume or ephemeral emptyDir | Dedicated PersistentVolume per ordinal via `volumeClaimTemplates` | HostPath mounts or node-local storage |
| **Associated Service Type** | Standard `ClusterIP` / `NodePort` / `LoadBalancer` | **Headless Service** (`clusterIP: None`) mandatory for discovery | None or local `ClusterIP` |
| **Scaling Behavior** | Scales arbitrarily across healthy nodes | Scales ordinally (adds/removes at the tail) | Scales automatically when nodes join/leave |
| **Production Examples** | Nginx, Python Flask, Node.js API, Go services | Kafka, MongoDB, Cassandra, PostgreSQL, ZooKeeper | Fluentd, Prometheus Node Exporter, Cilium, Falco |

### Solution / Observation

The supplied matrix is the required architectural comparison: Deployments favor interchangeable stateless replicas, StatefulSets favor stable ordered identities/storage, and DaemonSets place node-level agents across eligible nodes.

### Actual Terminal Output

Replace the placeholder below with the output from **your own machine**. Do not submit the sample/expected output as if it were your execution.

```text
PASTE YOUR ACTUAL TERMINAL OUTPUT FOR TASK 10 HERE
```

### Screenshot

Combine the required evidence for this task into one screenshot and save it as `screenshots/task10.png`.

![Task 10](./screenshots/task10.png)

---

## Task 11: Production Cost Optimization & Service Selection Decision Tree

- **Short Description:** Document the Kubernetes Service Decision Tree and conduct a cost-optimization analysis. Detail why provisioning 50 `type: LoadBalancer` services creates an enterprise billing anti-pattern in public clouds (AWS/GCP/Azure) and demonstrate how an Ingress Controller eliminates this overhead.
- **Architecture Diagram to Document:**
    
    ```
    ANTI-PATTERN (Expensive: $25/mo per service):
    Microservice A ──► AWS NLB 1 ($25/mo) ──► ClusterIP A
    Microservice B ──► AWS NLB 2 ($25/mo) ──► ClusterIP B
    Microservice C ──► AWS NLB 3 ($25/mo) ──► ClusterIP C
    Total for 50 services = $1,250 / month
    
    BEST PRACTICE (Cost-Optimized: Single Entrypoint):
    Public Internet ──► 1 Unified AWS Load Balancer ($25/mo)
                                │
                                ▼
                     [ NGINX Ingress Controller ]
                     (Layer 7 Host & Path Routing)
                        │            │            │
                        ▼            ▼            ▼
                   ClusterIP A  ClusterIP B  ClusterIP C
    Total for 50 services = $25 / month (Savings: $1,225/mo)
    ```
    
- **Service Selection Logic Tree to Document:**
    
    ```
    Need to expose service outside cluster?
    │
    ├── NO ──► Need direct pod-to-pod discovery (Kafka/DB)?
    │           ├── YES ──► Use HEADLESS SERVICE (clusterIP: None)
    │           └── NO  ──► Use CLUSTERIP (Default)
    │
    └── YES ──► Connecting to an external 3rd-party domain (AWS RDS / Stripe)?
                ├── YES ──► Use EXTERNALNAME
                └── NO  ──► Are you on Public Cloud (AWS/GCP/Azure)?
                             ├── YES (HTTP/HTTPS) ──► Expose 1 INGRESS via LOADBALANCER,
                             │                        apps as internal CLUSTERIP
                             ├── YES (TCP/UDP)    ──► Direct LOADBALANCER
                             └── NO (On-Prem/Dev) ──► NODEPORT
    ```

### Solution / Observation

The decision tree is the submission solution in the assignment: internal services normally use ClusterIP, direct stateful discovery can use headless Services, external aliases use ExternalName, and HTTP/HTTPS production exposure is consolidated behind an Ingress/load-balancer entry point rather than one load balancer per microservice.

### Actual Terminal Output

Replace the placeholder below with the output from **your own machine**. Do not submit the sample/expected output as if it were your execution.

```text
PASTE YOUR ACTUAL TERMINAL OUTPUT FOR TASK 11 HERE
```

### Screenshot

Combine the required evidence for this task into one screenshot and save it as `screenshots/task11.png`.

![Task 11](./screenshots/task11.png)

---

## Task 12: Minikube Docker-Driver Port Binding & Tunnel Gotcha Analysis

- **Short Description:** Analyze and document why running `curl http://<Node-IP>:<NodePort>` fails on macOS and Windows when using Minikube with the Docker driver. Execute and verify the two standard operational solutions: the temporary network forwarder (`minikube service <svc> --url`) and the continuous Layer 3 routing daemon (`minikube tunnel`).
- **Root Cause Explanation to Document:**
    - In standard bare-metal Linux clusters, the worker node IP belongs directly to a physical interface reachable on the local network.
    - When using Minikube on macOS or Windows with the Docker driver (`-driver=docker`), Minikube runs inside an **isolated Docker container**. The node IP (e.g., `192.168.49.2`) belongs to an internal Docker network bridge (`docker0`/`bridge`) that macOS/Windows host kernels cannot directly route to without specialized proxying.
- **Commands to Run & Verify Workarounds:**
    
    ```bash
    # 1. Re-verify the NodePort service is active
    kubectl get svc web-service-nodeport
    
    # 2. Attempt direct curl on Node IP (Demonstrating the failure)
    NODE_IP=$(minikube ip)
    echo "Testing direct connection to ${NODE_IP}:30080 (Expect timeout/failure on macOS Docker driver)..."
    curl --connect-timeout 2 -s "http://${NODE_IP}:30080" || echo "Connection Failed as expected!"
    
    # -------------------------------------------------------------
    # WORKAROUND 1: Dynamic Local Proxy via Minikube Service
    # -------------------------------------------------------------
    # Minikube binds an open loopback port on 127.0.0.1 directly into the Docker bridge
    minikube service web-service-nodeport --url
    
    # Test the output URL provided by minikube service (e.g., http://127.0.0.1:51234)
    # curl -I http://127.0.0.1:<generated-port>
    
    # -------------------------------------------------------------
    # WORKAROUND 2: Continuous L3 Route Tunnel (Production Simulation)
    # -------------------------------------------------------------
    # In a separate terminal window, launch minikube tunnel (requires sudo for host network routing tables):
    minikube tunnel
    
    # In your primary terminal, test direct localhost access on the mapped port:
    curl -I http://localhost:30080
    ```

### Solution / Observation

The assignment attributes direct NodeIP:NodePort failures on macOS/Windows Docker-driver setups to Minikube's isolated Docker network. The demonstrated workarounds are `minikube service <svc> --url` and `minikube tunnel`.

### Actual Terminal Output

Replace the placeholder below with the output from **your own machine**. Do not submit the sample/expected output as if it were your execution.

```text
PASTE YOUR ACTUAL TERMINAL OUTPUT FOR TASK 12 HERE
```

### Screenshot

Combine the required evidence for this task into one screenshot and save it as `screenshots/task12.png`.

![Task 12](./screenshots/task12.png)

---

## Final Submission Checklist

- [ ] `screenshots/task1.png` exists and contains the required evidence for Task 1.
- [ ] `screenshots/task2.png` exists and contains the required evidence for Task 2.
- [ ] `screenshots/task3.png` exists and contains the required evidence for Task 3.
- [ ] `screenshots/task4.png` exists and contains the required evidence for Task 4.
- [ ] `screenshots/task5.png` exists and contains the required evidence for Task 5.
- [ ] `screenshots/task6.png` exists and contains the required evidence for Task 6.
- [ ] `screenshots/task7.png` exists and contains the required evidence for Task 7.
- [ ] `screenshots/task8.png` exists and contains the required evidence for Task 8.
- [ ] `screenshots/task9.png` exists and contains the required evidence for Task 9.
- [ ] `screenshots/task10.png` exists and contains the required evidence for Task 10.
- [ ] `screenshots/task11.png` exists and contains the required evidence for Task 11.
- [ ] `screenshots/task12.png` exists and contains the required evidence for Task 12.
- [ ] Every `PASTE YOUR ACTUAL TERMINAL OUTPUT` placeholder has been replaced.
- [ ] The README and referenced manifests are committed to GitHub.
