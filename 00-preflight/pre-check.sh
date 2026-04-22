#!/bin/bash
# 文件名: ~/K3s-Declarative-Nginx-Cluster/00-preflight/pre-check.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}>>> 开始 K3s 集群环境预检 (RHEL 9 / Rocky 10) <<<${NC}"

# 1. 检查当前用户权限
if [ "$USER" != "danny" ]; then
    echo -e "${RED}[错误]${NC} 必须以 danny 用户身份运行此脚本。"
    exit 1
fi

# 2. 检查 Kubeconfig 可访问性
if [ ! -f "$HOME/.kube/config" ]; then
    echo -e "${RED}[错误]${NC} 未发现 kubeconfig。请确保已执行: 
    sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config && sudo chown danny:danny ~/.kube/config"
    exit 1
fi

# 3. 检查 SELinux 状态 (核心约束)
SE_STATUS=$(getenforce)
if [ "$SE_STATUS" == "Enforcing" ]; then
    echo -e "${GREEN}[通过]${NC} SELinux 处于 Enforcing 模式。"
else
    echo -e "${RED}[警告]${NC} SELinux 未开启，不符合项目安全铁律。"
fi

# 4. 检查 Firewalld 关键端口 (VXLAN & API Server)
# K3s 默认 Flannel 使用 8472/UDP (VXLAN)
CHECK_PORTS=("6443/tcp" "8472/udp" "10250/tcp")
for port in "${CHECK_PORTS[@]}"; do
    if firewall-cmd --list-ports | grep -q "$port" || firewall-cmd --list-services | grep -q "k3s"; then
        echo -e "${GREEN}[通过]${NC} 防火墙端口 $port 已开放。"
    else
        echo -e "${RED}[缺失]${NC} 防火墙未发现端口 $port。请执行 firewall-cmd --permanent --add-port=$port"
    fi
done

# 5. 跨节点确权 (Master 视角的 Worker 状态)
echo -e "${GREEN}>>> 正在获取节点状态...${NC}"
kubectl get nodes -o wide

# 6. 检查存储目录权限 (用于后续 PVC 挂载)
STORAGE_PATH="/var/lib/rancher/k3s/storage"
if [ -d "$STORAGE_PATH" ]; then
    echo -e "${GREEN}[通过]${NC} K3s 默认存储路径已存在。"
else
    echo -e "${RED}[警告]${NC} 无法访问 $STORAGE_PATH，请确认 K3s 已正确安装。"
fi

echo -e "${GREEN}>>> 预检完成。若上方无红色 [错误]，请确认执行下一步。<<<${NC}"
