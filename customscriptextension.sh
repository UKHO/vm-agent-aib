#!/bin/bash

echo "########### CONFIGURING AGENT ###########"
echo "Allow agent to run as root"
export AGENT_ALLOW_RUNASROOT="YES"

echo "Setup agent"
agentName = hostname
cd /usr/lib/agt
./config.sh --unattended --url https://dev.azure.com/$1 --auth PAT --token $2 --pool $3 --agent $agentName --acceptTeeEula --work _work

echo "Install service for agent"
./svc.sh install
echo "Start service for agent"
./svc.sh start

sleep 20s

echo "########### CONFIGURING DRAINER ###########"
echo "Reload systemd"
systemctl daemon-reload

echo "Enable drainer for restart"
systemctl enable azurevmagentdrainer.service
echo "Start drainer for restart"
systemctl start azurevmagentdrainer.service
