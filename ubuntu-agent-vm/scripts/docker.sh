#!/bin/bash

apt-get remove -y moby-engine moby-cli
apt-get update
apt-get install -y moby-engine moby-cli
apt-get install --no-install-recommends -y moby-buildx

# Enable docker.service
systemctl is-active --quiet docker.service || systemctl start docker.service
systemctl is-enabled --quiet docker.service || systemctl enable docker.service

# Docker daemon takes time to come up after installing
sleep 10
docker info
