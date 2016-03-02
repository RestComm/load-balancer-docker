#!/bin/bash

echo "Configure loadbalancer"
echo "Work directory: ${LOADER_BALANCER_DIR}"

if [ -z "${HOST_ADDRESS}" ]; then

    if [ -z "${INTERFACE}" ]; then
        NET_INTERFACE="${INTERFACE}"
    else
        NET_INTERFACE='eth0'
    fi
    echo "NET_INTERFACE: $INTERFACE"

    echo "Looking for the appropriate interface"
    NET_INTERFACES=$(ifconfig | expand | cut -c1-8 | sort | uniq -u | awk -F: '{print $1;}')

    if [[ -z $(echo $NET_INTERFACES | sed -n "/$NET_INTERFACE/p") ]]; then
        echo "The network interface $NET_INTERFACE is not available or does not exist."
        echo "The list of available interfaces is: $NET_INTERFACES"
        exit 1
    fi

    # load network properties for chosen interface
    echo "Looking for the IP Address, subnet, network and broadcast_address"
    source ${LOADER_BALANCER_DIR}/utils/read-network-props.sh "$NET_INTERFACE"
    HOST_ADDRESS="$PRIVATE_IP"
fi

if [ -n "${HOST_ADDRESS}" ]; then
    echo "Setup host: ${HOST_ADDRESS}"
    sed -i "s/host=.*/host=${HOST_ADDRESS}/" $LOADER_BALANCER_CONFIG
fi

if [ -n "${INTERNAL_PORT}" ]; then
    echo "Setup internalPort: ${INTERNAL_PORT}"
    sed -i "s/internalPort=.*/internalPort=${INTERNAL_PORT}/" $LOADER_BALANCER_CONFIG
fi

if [ -n "${EXTERNAL_PORT}" ]; then
    echo "Setup externalPort: ${EXTERNAL_PORT}"
    sed -i "s/externalPort=.*/externalPort=${EXTERNAL_PORT}/" $LOADER_BALANCER_CONFIG
fi

if [ -z "${LOG_LEVEL}" ]; then
    echo "Setup default log level"
    LOG_LEVEL="INFO"
fi
