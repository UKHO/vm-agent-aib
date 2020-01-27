#!/bin/bash

# Download and extract azurevmagentservice
servicepath=/usr/local/bin/azurevmagentdrainer
mkdir -p $servicepath
curl -L https://github.com/ukho/azdoagentdrainer/releases/latest/download/azurevmagentservice.tar.gz | tar zx -C $servicepath

# Creat the service file
cat > /etc/systemd/system/azurevmagentdrainer.service << EOF
[Unit]
Description=Azure Pipelines Agent Draienr
[Service]
Type=notify
WorkingDirectory=$servicepath
ExecStart=/usr/bin/dotnet $servicepath/AzureVmAgentsService.dll --drainer:uri=https://dev.azure.com/$1 --drainer:pat=$2
Restart=always
[Install]
WantedBy=multi-user.target
EOF