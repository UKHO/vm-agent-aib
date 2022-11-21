#!/bin/bash

echo "update apt"
apt update

echo "install baseline"
apt install -y unzip dotnet6 dotnet-sdk-6.0 liblttng-ust0 libkrb5-3 zlib1g debsums
