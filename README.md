# K3s Declarative Nginx Cluster

A high-availability Nginx deployment on a hybrid K3s cluster (RHEL 9.7 Master & Rocky 10.1 Worker), focusing on **Zero-Root privilege**, **Declarative GitOps workflow**, and **SELinux hardening**.

## 🚀 Key Takeaways

### 1. Declarative Infrastructure
- Transitioned from imperative `kubectl run` to a structured directory-based deployment (`01-configs` to `04-networking`).
- Ensured **Idempotency**: The entire stack can be redeployed or repaired using `kubectl apply -f . --recursive`.

### 2. Non-Root Security Hardening
- Implemented **UID 101 (nginx)** execution, moving away from default root privileges.
- Solved the "Permission Denied" paradox in restricted OS environments (RHEL/Rocky) by using K8s `securityContext`.

### 3. Storage & Configuration Decoupling
- **Dynamic Provisioning**: Leveraged `local-path-provisioner` for persistent logging.
- **Config Injection**: Used ConfigMaps with `subPath` to inject custom Nginx configurations without rebuilding the image.

### 4. Hybrid Cloud Networking
- Verified **Flannel VXLAN** cross-node communication between RHEL and Rocky nodes.
- Managed NodePort services to expose applications across a multi-node internal network.
