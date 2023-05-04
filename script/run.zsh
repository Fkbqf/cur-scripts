#!/bin/zsh

set -x
runK8s(){
ssh $1 sudo systemctl start containerd
ssh $1 sudo systemctl start kubelet
}

masterName=master
masterIP="192.168.122.3"
nodeUserName="arch"

HOME1="/home/$nodeUserName"
runK8s $masterName &
runK8s worker1 &
runK8s worker0 &
wait
ssh $masterName rm -rf $HOME1/.kube
ssh $masterName sudo kubeadm init --apiserver-advertise-address=$masterIP --pod-network-cidr=10.244.0.0/16 --kubernetes-version=v1.26.1
# ssh $masterName sudo kubeadm init --skip-phases=addon/kube-proxy --apiserver-advertise-address=$masterIP --pod-network-cidr=10.244.0.0/16 --kubernetes-version=v1.26.1
# ssh $masterName sudo kubeadm init --pod-network-cidr=10.244.0.0/16,2001:db8:42:0::/56 --service-cidr=10.96.0.0/16,2001:db8:42:1::/112  --kubernetes-version=v1.26.1
# ssh $masterName sudo kubeadm init --pod-network-cidr=2001:db8:42:0::/56 --service-cidr=2001:db8:42:1::/112  --kubernetes-version=v1.26.1
ssh $masterName mkdir -p $HOME1/.kube
ssh $masterName sudo cp /etc/kubernetes/admin.conf $HOME1/.kube/config
ssh $masterName sudo chown $(id -u):$(id -g) $HOME1/.kube/config
rm $HOME/.kube -rf
mkdir -p $HOME/.kube
scp $masterName:~/.kube/config $HOME/.kube/config
# scp $HOME/Project/flannel/Documentation/modify.zsh $masterName:~/
token=$(ssh master sudo kubeadm token create --print-join-command)
ssh worker1 sudo $token &
ssh worker0 sudo $token &
wait
