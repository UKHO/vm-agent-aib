#!/bin/bash

echo "update apt"
apt update

echo "install unzip"
apt install -y unzip dotnet6 dotnet-sdk-6.0
