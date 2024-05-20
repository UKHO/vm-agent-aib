#!/bin/bash

echo "update apt"
apt update

echo "install baseline"
apt install -y unzip dotnet8 dotnet-sdk-8.0
