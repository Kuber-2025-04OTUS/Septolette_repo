#!/bin/bash

# Версия K8s 
K8S_VERSION="1.33"
K8S_VERSION_MINOR="1.33.4"

# Добавление ключа репозитория
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/Release.key \
    | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring-upgrade.gpg

# Добавление репозитория
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring-upgrade.gpg] \
https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/ /" \
    | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Установка kubeadm нужной версии
sudo apt-mark unhold kubeadm kubelet kubectl || true
sudo apt-get update
sudo apt-get install -y kubeadm
sudo apt-mark hold kubeadm

# Проверка плана обновления
sudo kubeadm upgrade plan

# Применение обновления control-plane
sudo kubeadm upgrade apply v${K8S_VERSION_MINOR} -y || true

# Обновление kubelet и kubectl
sudo apt-get install -y kubelet kubectl
sudo apt-mark hold kubelet kubectl
sudo systemctl daemon-reload
sudo systemctl restart kubelet

echo "Master upgrade attempted to ${K8S_VERSION_MINOR}"