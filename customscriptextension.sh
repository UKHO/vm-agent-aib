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
storageaccountname=$4
storageaccountfileshare="owaspdependencycheck"
storageaccountuser=$5
storageaccountpassword=$6

echo "${storageaccountname}"

echo "${storageaccountuser}"

mkdir /mnt/${mountpoint}

if [ ! -d "/etc/smbcredentials" ]; then
mkdir /etc/smbcredentials
fi
if [ ! -f "/etc/smbcredentials/${storageaccountuser}.cred" ]; then
    echo "username=${storageaccountuser}" >> /etc/smbcredentials/${storageaccountuser}.cred
    echo "password=${storageaccountpassword}" >> /etc/smbcredentials/${storageaccountuser}.cred
fi
chmod 600 /etc/smbcredentials/${storageaccountuser}.cred

echo "//${storageaccountname}.file.core.windows.net/${storageaccountfileshare} /mnt/${mountpoint} cifs nofail,vers=3.0,credentials=/etc/smbcredentials/${storageaccountuser}.cred,dir_mode=0777,file_mode=0777,serverino" >> /etc/fstab
mount -t cifs //${storageaccountname}.file.core.windows.net/${storageaccountfileshare} /mnt/${mountpoint} -o vers=3.0,credentials=/etc/smbcredentials/${storageaccountuser}.cred,dir_mode=0777,file_mode=0777,serverino

export PATH=$PATH:/mnt/${mountpoint}/dependency-check/bin

echo "########### CONFIGURING AGENT ###########"
echo "Allow agent to run as root"
export AGENT_ALLOW_RUNASROOT="YES"

echo "Configure agent"
agentName=$(hostname)
echo "AgentName is ${agentName}"

if [[ $agentName == "linux-c"* ]];
then
    touch /etc/profile.d/capabilities.sh
    echo 'export CAPABILITY=canary' >> /etc/profile.d/capabilities.sh
fi

cd /usr/lib/agt

./config.sh --unattended --url https://dev.azure.com/$1 --auth PAT --token $2 --pool "$3" --agent "${agentName}" --acceptTeeEula --work _work

echo "Install service for agent"
./svc.sh install
echo "Start service for agent"
./svc.sh start

sleep 20s

echo "########### CONFIGURING DRAINER ###########"

echo "Update agent service file"
sed -i -e "s/<azdoaccount>/${1}/g" /etc/systemd/system/azurevmagentdrainer.service
sed -i -e "s/<azdopat>/${2}/g" /etc/systemd/system/azurevmagentdrainer.service

echo "Reload systemd"
systemctl daemon-reload

echo "Enable drainer for restart"
systemctl enable azurevmagentdrainer.service
echo "Start drainer for restart"
systemctl start azurevmagentdrainer.service
