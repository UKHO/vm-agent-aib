#!/bin/bash

agtLocation=/usr/lib/agt
mkdir -p $agtLocation
mkdir -p $agtLocation/_work

echo "download agent"
curl https://vstsagentpackage.azureedge.net/agent/3.218.2/vsts-agent-linux-x64-3.218.2.tar.gz | tar zx -C $agtLocation

echo "set permissions on agent directory"
chmod 755 -R $agtLocation
