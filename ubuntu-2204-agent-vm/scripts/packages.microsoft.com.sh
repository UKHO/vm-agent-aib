curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null

echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/azure-cli.list

apt-get update
apt-get install -y --no-install-recommends azure-cli=*
rm -rf /var/lib/apt/lists/*

sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-debian-buster-prod/ buster main" > /etc/apt/sources.list.d/microsoft.list'
apt-get update
apt-get install -y --no-install-recommends powershell=*
rm -rf /var/lib/apt/lists/*
