#!/bin/bash

echo "Configure loadbalancer"
echo "Work directory: ${LOADER_BALANCER_DIR}"

if [ -z "${HOST_ADDRESS}" ]; then

    if [ -n "${INTERFACE}" ]; then
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

if [ -n "${AMAZON_EC2}" ] && [ -z "${PUBLIC_IP}" ]; then
    echo "Get real public ip for Amazon"
    # http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-instance-addressing.html
    PUBLIC_IP=`curl -s -m 5 http://169.254.169.254/latest/meta-data/public-ipv4`
    if [[ "$PUBLIC_IP" == *"404 Not Found"* ]]
    then
        PUBLIC_IP=""
    fi
fi

if [ -n "${PUBLIC_IP}" ]; then
    echo "PUBLIC_IP : ${PUBLIC_IP}"
    sed -i "s/#public-ip=.*/public-ip=${PUBLIC_IP}/" $LOADER_BALANCER_CONFIG
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

LOG_LEVEL_INT=0

case "$LOG_LEVEL" in
    OFF ) LOG_LEVEL_INT=0;;
    FATAL ) LOG_LEVEL_INT=100;;
    ERROR ) LOG_LEVEL_INT=200;;
    WARN ) LOG_LEVEL_INT=300;;
    INFO ) LOG_LEVEL_INT=400;;
    DEBUG ) LOG_LEVEL_INT=500;;
    TRACE ) LOG_LEVEL_INT=600;;
esac

echo "Setup gov.nist TRACE_LEVEL: ${LOG_LEVEL_INT}"
sed -i "s/gov.nist.javax.sip.TRACE_LEVEL=.*/gov.nist.javax.sip.TRACE_LEVEL=${LOG_LEVEL_INT}/" $LOADER_BALANCER_CONFIG

echo "Setup log level: ${LOG_LEVEL}"
sed -i "s/WARN/${LOG_LEVEL}/g" ${LOG4J_CONFIG}
