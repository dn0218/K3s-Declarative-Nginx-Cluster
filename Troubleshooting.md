# Troubleshooting & Lessons Learned

During the deployment on RHEL 9 and Rocky 10, several critical "roadblocks" were encountered and resolved.

## 1. Nginx Cache Directory Permission Denied

<img width="1054" height="306" alt="Screenshot 2026-04-22 111832" src="https://github.com/user-attachments/assets/dd4b4ab2-dae5-459d-968f-7e12dea07c8b" />

**Issue:** `nginx: [emerg] mkdir() "/var/cache/nginx/client_temp" failed (13: Permission denied)`

**Root Cause:** When running as a non-root user (`runAsUser: 101`), the container cannot write to `/var/cache/nginx` because the directory is owned by root in the official image.

**Fix:** Mounted an `emptyDir` volume to `/var/cache/nginx` and `/var/run`. This provides a fresh, writable temporary space owned by the Pod's service group.

<img width="453" height="564" alt="image" src="https://github.com/user-attachments/assets/ec3746b2-a587-4c7d-9e96-d82e29ac154f" />


---

## 2. YAML Decoding Error (Invalid Field)

<img width="1077" height="243" alt="image" src="https://github.com/user-attachments/assets/43655b0f-0e79-4738-aed6-70ef1189d6e2" />

**Issue:** `strict decoding error: unknown field "spec.template.spec.volumeMounts"`

**Root Cause:** Incorrect YAML indentation. `volumeMounts` was placed at the same level as `containers` instead of inside a specific container's definition.

**Fix:** Relocated `volumeMounts` directly under the `- name: nginx-server` container spec.

<img width="436" height="325" alt="image" src="https://github.com/user-attachments/assets/5c73d350-2ab1-47a6-8af9-e47b8d41d628" />

---

## 3. SELinux Blocking subPath Mounts

<img width="1203" height="297" alt="image" src="https://github.com/user-attachments/assets/35124499-3486-4b6d-ba22-03d18089b49a" />

**Issue:** Container failed to start or could not read `/etc/nginx/nginx.conf`.

**Root Cause:** RHEL 9's SELinux policy restricts container processes from accessing host-mounted files unless the correct security context is applied.

**Fix:** Added `seLinuxOptions` to the `securityContext`:
```yaml
securityContext:
  seLinuxOptions:
    type: "container_t"
```

