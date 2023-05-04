#!/bin/zsh

# kubectl delete -f /home/admin/Project/flannel/Documentation/kube-flannel.yml
cleanDev(){
  node=$1
  devName=$2
  ssh $node sudo ip link set $devName down
  ssh $node sudo ip link delete $devName
}
cleanIptables(){
  node=$1
  output=$(ssh $node sudo nft --json list tables|jq -r '.nftables[]|select(has("table")).table|"\(.family) \(.name)"')
  array=("${(@f)output}")
  for i ($array) {
    ssh $node sudo nft delete table $i
  }
}
cleanCache(){
  node=$1
  ssh $node sudo rm -rf /var/lib/cni /etc/cni/net.d /var/lib/kubelet /run/flannel
  ssh $node sudo rm -rf /opt/cni/bin/flannel
  ssh $node sudo rm -rf /opt/cni/bin/blitz
  ssh $node sudo rm -rf /var/lib/calico/ /var/log/calico/
  ssh $node sudo mv /tmp/cni.log /tmp/cni.log.bak
  ssh $node sudo mv /tmp/1.log /tmp/1.log.bak
  ssh $node sudo rm -rf /run/blitz/
}
stopService(){
  node=$1
  ssh $node sudo nerdctl -n k8s.io container prune -f
  ssh $node sudo systemctl stop kubelet
  ssh $node sudo systemctl stop containerd
  wait
}
cleanRoute(){
  node=$1
  output=$(ssh $node ip route)
  array=("${(@f)output}")
  for i ($array) {
    (($i[(I)default])) || ssh $node sudo ip route del $i
  }
}
resetHost(){
  ssh $1 sudo kubeadm reset -f
  stopService $1 &
  cleanCache $1 &
  cleanIptables $1 &
  cleanRoute $1 &
  for i (cni0 flannel.1 flannel-v6.1 blitz0 blitznet vxlan0) {
    cleanDev $1 $i &
  }
  wait
}
resetHost worker1 &
resetHost worker0 &
resetHost master &
rm -rf ~/.kube &
wait
