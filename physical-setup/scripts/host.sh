#!/bin/bash

git clone https://www.github.com/N-essuno/smol_scheduler

influxdbversion="2.7.3"
arch=$(dpkg --print-architecture)

# Checks the architecture and continues the setup only if arch is
# either arm64 or amd64
case "$arch" in
amd64)
    wget https://dl.influxdata.com/influxdb/releases/influxdb2-client-$influxdbversion-linux-amd64.tar.gz
    tar xvzf influxdb2-client-$influxdbversion-linux-amd64.tar.gz
    sudo cp influxdb2-client-$influxdbversion-linux-amd64/influx /usr/local/bin
    ;;
arm64)
    wget https://dl.influxdata.com/influxdb/releases/influxdb2-client-$influxdbversion-linux-arm64.tar.gz
    tar xvzf influxdb2-client-$influxdbversion-linux-arm64.tar.gz
    sudo cp influxdb2-client-$influxdbversion-linux-arm64/influx /usr/local/bin
    ;;
*)
    echo "Unsupported architecture: $arch"
    exit 1
    ;;
esac

# Sets up influxdb with the standard config tool
influx setup

exit 0
