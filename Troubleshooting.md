# Troubleshooting & Lessons Learned

During the deployment on RHEL 9 and Rocky 10, several critical "roadblocks" were encountered and resolved.

## 1. Nginx Cache Directory Permission Denied
**Issue:** `nginx: [emerg] mkdir() "/var/cache/nginx/client_temp" failed (13: Permission denied)`

**Root Cause:** When running as a non-root user (`runAsUser: 101`), the container cannot write to `/var/cache/nginx` because the directory is owned by root in the official image.

**Fix:** Mounted an `emptyDir` volume to `/var/cache/nginx` and `/var/run`. This provides a fresh, writable temporary space owned by the Pod's service group.

---

## 2. YAML Decoding Error (Invalid Field)
**Issue:** `strict decoding error: unknown field "spec.template.spec.volumeMounts"`

**Root Cause:** Incorrect YAML indentation. `volumeMounts` was placed at the same level as `containers` instead of inside a specific container's definition.

**Fix:** Relocated `volumeMounts` directly under the `- name: nginx-server` container spec.

---

## 3. SELinux Blocking subPath Mounts
**Issue:** Container failed to start or could not read `/etc/nginx/nginx.conf`.

**Root Cause:** RHEL 9's SELinux policy restricts container processes from accessing host-mounted files unless the correct security context is applied.

**Fix:** Added `seLinuxOptions` to the `securityContext`:
```yaml
securityContext:
  seLinuxOptions:
    type: "container_t"
```

## 4. Firewalld Port 10250 (Kubelet API)
**Issue**: Pre-flight check failed to detect port 10250.

**Root Cause**: Kubelet needs port 10250/tcp for the Master to retrieve logs and metrics from Worker nodes.

**Fix**: Manually enabled the port on the host:
```bash
sudo firewall-cmd --permanent --add-port=10250/tcp && sudo firewall-cmd --reload
```
