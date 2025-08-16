#!/bin/bash

# Отключение swap
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Включение форвардинга пакетов и bridge-nf
echo "br_netfilter" | sudo tee /etc/modules-load.d/k8s.conf
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

# Установка необходимых пакетов
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release gpg

echo "Preparation done"