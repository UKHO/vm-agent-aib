#!/bin/bash

agtLocation=/usr/bin/agt
mkdir -p agtLocation

echo "download agent"
curl https://vstsagentpackage.azureedge.net/agent/2.150.3/vsts-agent-linux-x64-2.150.3.tar.gz | tar zx -C agtLocation

echo "set permissions on agent directory"
chmod 755 -R agtLocation