#!/usr/bin/env bash

function create_k8s_config() {
 cat << EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

  sudo modprobe overlay
  sudo modprobe br_netfilter
}

function create_systemctl_k8s_config() {
  cat << EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

  sudo sysctl --system
}

create_k8s_config
create_systemctl_k8s_config

# doc: https://docs.vultr.com/how-to-install-docker-on-ubuntu-24-04
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y

sudo mkdir -m 0755 -p /etc/apt/keyrings

# docker gpg key to host's keyring
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

# add docker repo to apt sources
echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker $USER

# enable docker system service
sudo systemctl enable docker
sudo systemctl status docker

sudo usermod -aG docker $USER

# Log out and log back in so that your group membership is re-evaluated

# Make sure that 'disabled_plugins' is commented out in your config.toml file
sudo sed -i 's/disabled_plugins/#disabled_plugins/' /etc/containerd/config.toml

# Restart containerd
sudo systemctl restart containerd

# On all nodes, disable swap.
sudo swapoff -a
