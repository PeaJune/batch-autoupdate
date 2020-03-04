#!/bin/sh
#set -e
workspace=$(cd `dirname $0`; pwd)

is_substr(){
    case "$2" in
        *$1*) return 0;;
        *) return 1;;
    esac
}

validate_args(){
  if is_substr "token" $1 and is_substr "discovery-token-ca-cert-hash" $1 and is_substr "server" $1 and is_substr "registry" $1;then
    echo 0
  else
    echo 1
  fi 
}

export  LD_LIBRARY_PATH=$workspace/system/lib:$LD_LIBRARY_PATH
mdnsd_pid=$(ps | grep mdnsd | grep -v grep | awk '{print $1}')
if [  "$mdnsd_pid" ];then
  kill $mdnsd_pid
fi
${workspace}/system/bin/mdnsd
dns_sd_pid=$(ps | grep dns-sd | grep -v grep | awk '{print $1}')
if [  "$dns_sd_pid" ];then
  kill $dns_sd_pid 
fi
${workspace}/system/bin/dns-sd -t1  -L k8s-server _http._tcp local > /run/dns-sd.log &
sleep 5
#cmd_args=$(cat /run/dns-sd.log | grep token)
cmd_args="--token hwfep2.iw7q7ltqdwxbati5 --discovery-token-ca-cert-hash sha256:17e481ad916cfe4f06e9289a06f33c57060be7ed3c3251493415e1f65550ed98 --server https://172.16.140.136:8443 --registry http://172.16.138.101:5000"
validate=$(validate_args "${cmd_args}")

while true
do
  if [ $validate = 1 ];then
    echo "Read join k8s cluster arguments  from mdns error,will try again after 5s"
    sleep 5
    #cmd_args=$(cat /run/dns-sd.log | grep -m 1  token)
    cmd_args="--token hwfep2.iw7q7ltqdwxbati5 --discovery-token-ca-cert-hash sha256:17e481ad916cfe4f06e9289a06f33c57060be7ed3c3251493415e1f65550ed98 --server https://172.16.140.136:8443 --registry http://172.16.138.101:5000"
    validate=$(validate_args "${cmd_args}")
    continue
  else
    break
  fi
done

dns_sd_pid=$(ps | grep dns-sd | grep -v grep | awk '{print $1}')
if [  "$dns_sd_pid" ];then
  kill $dns_sd_pid 
fi

mdnsd_pid=$(ps | grep mdnsd | grep -v grep | awk '{print $1}')
if [  "$mdnsd_pid" ];then
  kill $mdnsd_pid
fi


node_ip=$(ifconfig eth0 | grep "inet addr:" | awk '{print $2}' | awk -F':' '{print $2}')
${workspace}/k3s agent \
           --pause-image advertise/pause:3.1 \
           --registry-domain docker.io \
           --registry-user "" --registry-pass "" \
           --run-mode join_k8s \
           --k8s-version v1.14.1 \
	   --node-name ${node_ip} \
	   --node-ip ${node_ip} \
	   --node-label "device=camera" \
           -v 2 \
	   --log /mnt/nfs0/k3s/k3s-agent.log \
           --kubelet-arg bootstrap-kubeconfig="/etc/kubernetes/bootstrap-kubelet.conf" \
           --kubelet-arg kubeconfig="/etc/kubernetes/kubelet.conf" \
           --kubelet-arg pod-infra-container-image="advertise/pause:3.1" \
           --kubelet-arg v=2 \
           --kubelet-arg enforce-node-allocatable="pods" \
           --kubelet-arg kube-reserved="cpu=100m,memory=100Mi,ephemeral-storage=1Gi" \
           --kubelet-arg system-reserved="cpu=100m,memory=100Mi,ephemeral-storage=1Gi" \
           --kubelet-arg cni-conf-dir="/etc/cni/net.d" \
	   --no-flannel \
	   -d /mnt/nfs0/k3s \
	  ${cmd_args} 
sleep 10
rm -rf /mnt/nfs0/k3s/k3s/data
