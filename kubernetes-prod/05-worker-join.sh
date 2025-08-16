#!/bin/bash

# Скопировать /root/kubeadm-join-cmd.sh с master и выполнить

kubeadm join 10.129.0.3:6443 --token ys1h3n.31oa8c9jj4d5ploc --discovery-token-ca-cert-hash sha256:98b7a22481b60ca6dbd8d33ae3144f7868a4373f6ef6d93d91f4cf7e989a5d50 
