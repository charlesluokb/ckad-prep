#!/usr/bin/env bash

function setup_k8s_node() {
  # step 1
  sudo apt-get install -y apt-transport-https ca-certificates curl gpg gnupg lsb-release
  # step 2
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update
  sudo apt-get install -y kubelet kubeadm kubectl
  sudo apt-mark hold kubelet kubeadm kubectl

  # step 3
#  sudo kubeadm init --pod-network-cidr=
}

# doc: https://kubernetes.io/docs/reference/networking/ports-and-protocols/
function open_k8s_ports_worker() {
  echo "opening k8s ports for worker node 10250,10256, 30000-32767 ..."
  sudo ufw allow 10250/tcp
  sudo ufw allow 10256/tcp
  sudo ufw allow 30000:32767/tcp
}

function open_k8s_ports_master() {
  # open ports for k8s
  echo "opening k8s ports for control node 6443, 2379-2380, 10250, 10259, 10257 ..."
  sudo ufw allow 6443/tcp
  sudo ufw allow 2379:2380/tcp
  sudo ufw allow 10250/tcp
  sudo ufw allow 10259/tcp
  sudo ufw allow 10257/tcp
}

# Need to setup Networking inbound rules for both control and worker nodes
# list which ports are open: sudo ss -tuln; sudo lsof -i -P -n | grep LISTEN; nc 127.0.0.1 10250 -v
