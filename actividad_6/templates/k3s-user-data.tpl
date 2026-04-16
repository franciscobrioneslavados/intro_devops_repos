#!/bin/bash
# k3s installation script
hostnamectl set-hostname ${node_name}

# Get Public IP from EC2 Metadata
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Install k3s with 644 permissions and Public IP in TLS cert
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --tls-san $PUBLIC_IP" K3S_KUBECONFIG_MODE="644" sh -

# Wait for k3s to be ready
until k3s kubectl get nodes; do
  sleep 5
done

# Set KUBECONFIG variable for ubuntu user
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> /home/ubuntu/.bashrc

echo "k3s installation finished successfully"
