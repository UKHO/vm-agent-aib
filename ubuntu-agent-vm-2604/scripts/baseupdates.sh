#!/bin/bash

echo "update apt"
apt update

echo "install baseline"
apt install -y unzip dotnet10 dotnet-sdk-10.0
