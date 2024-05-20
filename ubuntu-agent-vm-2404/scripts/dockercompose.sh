#!/bin/bash

echo "install docker-compose"
curl -L "https://github.com/docker/compose/releases/download/2.27.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose