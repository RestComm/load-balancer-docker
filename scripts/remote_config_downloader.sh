#!/bin/bash

echo "Remote config downloader"

if [ -n "$CONFIG_URL" ]; then
    echo "Load file by url: ${CONFIG_URL}"
    wget -O ${LOADER_BALANCER_CONFIG} $CONFIG_URL
fi
