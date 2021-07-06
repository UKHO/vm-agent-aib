#!/bin/bash

echo "########### CONFIGURING SWAP FILE ###########"
sed -i 's/ResourceDisk.Format=n/ResourceDisk.Format=y/' /etc/waagent.conf
sed -i 's/ResourceDisk.EnableSwap=n/ResourceDisk.EnableSwap=y/' /etc/waagent.conf
sed -i 's/ResourceDisk.SwapSizeMB=0/ResourceDisk.SwapSizeMB=8192/' /etc/waagent.conf

umount /mnt
service walinuxagent restart

sleep 20s

echo '########### SETUP NVD DC ###########'
mountpoint="owaspdependencycheck"
storageaccountname=$1
storageaccountfileshare="owaspdependencycheck"
storageaccountuser=$2
storageaccountpassword=$3

echo "${storageaccountname}"

echo "${storageaccountuser}"

mkdir /mnt/${mountpoint}

install -d /etc/smbcredentials

fifo=$(mktemp)
mkfifo ${fifo}
install --mode=600 ${fifo} "/etc/smbcredentials/${storageaccountuser}.cred" &
cat <<EOF > ${fifo}
username=${storageaccountuser}
password=${storageaccountpassword}
EOF
rm ${fifo}

echo "//${storageaccountname}.file.core.windows.net/${storageaccountfileshare} /mnt/${mountpoint} cifs nofail,vers=3.0,credentials=/etc/smbcredentials/${storageaccountuser}.cred,dir_mode=0777,file_mode=0777,serverino" >> /etc/fstab
mount -t cifs //${storageaccountname}.file.core.windows.net/${storageaccountfileshare} /mnt/${mountpoint} -o vers=3.0,credentials=/etc/smbcredentials/${storageaccountuser}.cred,dir_mode=0777,file_mode=0777,serverino

sleep 10s

export PATH=$PATH:/mnt/${mountpoint}/dependency-check/bin

echo "Allow agent to run as root"
export AGENT_ALLOW_RUNASROOT="YES"

