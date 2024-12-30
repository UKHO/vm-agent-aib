#!/bin/bash

echo "update apt"
apt update

echo "check"
if ! apt check; then
    echo "Issues detected. Running 'apt update' again"
    apt update
else
    echo "System is healthy."
fi

echo "install unzip"
apt install -y unzip
