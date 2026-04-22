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

## The Big Picture

<img width="522" height="288" alt="image" src="https://github.com/user-attachments/assets/7422bb33-a47e-4606-a2d3-f46302c1723d" />

### Nodes Status

<img width="1116" height="737" alt="image" src="https://github.com/user-attachments/assets/47331f8f-01d9-431b-a521-42d829227cdb" />

### Storage & Security

<img width="857" height="47" alt="image" src="https://github.com/user-attachments/assets/e1935614-05b5-408d-9578-b67c135f0973" />

### User Experience

<img width="1152" height="379" alt="Screenshot 2026-04-22 113611" src="https://github.com/user-attachments/assets/69a423ec-91fa-41db-bd0f-7f76f287c95d" />



