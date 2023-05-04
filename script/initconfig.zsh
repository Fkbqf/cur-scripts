#!/bin/zsh
set -x

pacman -S kubeadm kubectl kubelet containerd crictl
systemctl enable containerd
systemctl enable kubelet
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
sch_ingress
cls_bpf
EOF
modprobe overlay
modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

mkdir -p /etc/containerd
containerd  config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml 
crictl config --set runtime-endpoint=unix:///run/containerd/containerd.sock
