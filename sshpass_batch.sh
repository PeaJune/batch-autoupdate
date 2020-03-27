#!/usr/bin/env bash

CAMERA_3559_SSH_PASS="1234567a"
CAMERA_3559_SSH_PORT="2222"

function reset_camera_3559(){
   ip=$1
   echo "handle 3559 camera: ${ip}"
   #sshpass -p ${CAMERA_3559_SSH_PASS} ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  -p${CAMERA_3559_SSH_PORT} admin@${ip} 'ps | grep k3s  | grep -v grep  | awk "{print $1}" | xargs kill;sleep 1;mount | grep k3s | awk "{print $3}" | xargs umount;rm /mnt/nfs0/k3s -rf;rm /mnt/nfs0/k3s -rf;rm /var/lib/rancher -rf;rm /etc/kubernetes -rf;rm /var/lib/kubelet -rf;reboot'
   sshpass -p ${CAMERA_3559_SSH_PASS} scp -P ${CAMERA_3559_SSH_PORT} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /home/aibee/start.sh  admin@${ip}:/dav/package/k3s-agent/
   sshpass -p ${CAMERA_3559_SSH_PASS} ssh -p${CAMERA_3559_SSH_PORT} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  admin@${ip} 'reboot'
}

#prepare
apt-get install sshpass

#handle 3559
cameras_3559=$(kubectl get node -l kubernetes.io/arch=arm64 | grep -v NAME | awk '{print $1}')
#echo ${cameras_3559}
for item in ${cameras_3559[@]}
do
  reset_camera_3559 $item
done
