#!/bin/bash

POD_CIDR="10.244.0.0/16"
K8S_VERSION="v1.32.8"

sudo kubeadm init --kubernetes-version=${K8S_VERSION} --pod-network-cidr=${POD_CIDR} --upload-certs | tee /root/kubeadm-init.out

# Настройка kubeconfig для текущего пользователя
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Установка Flannel (CNI)
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Сохранение join команды для воркеров
kubeadm token create --print-join-command > /root/kubeadm-join-cmd.sh
chmod +x /root/kubeadm-join-cmd.sh

echo "master inited; join command saved to /root/kubeadm-join-cmd.sh"