#!/bin/bash

echo "Configure loadbalancer"
echo "Work directory: ${LOADER_BALANCER_DIR}"

if [ -z "${HOST_ADDRESS}"  && -z "${CONFIG_URL}" ]; then

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
    sed -i "s/smppHost=.*/smppHost=${HOST_ADDRESS}/" $LOADER_BALANCER_CONFIG
fi

if [ "${AMAZON_EC2^^}" = "TRUE" ] && [ -z "${PUBLIC_IP}" ]; then
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

#Add TCPDUMP collection
echo "LB_TRACE_LOG /opt/loadbalancer/logs/trace"
mkdir -p "/opt/loadbalancer/logs/trace"
nohup xargs bash -c "tcpdump -pni any -t -n -s 0   -G 3500 -w /opt/loadbalancer/logs/trace/lb_trace_%Y-%m-%d_%H:%M:%S-%Z.pcap -z gzip" &



echo "Setup log level: ${LOG_LEVEL}"
sed -i "s/WARN/${LOG_LEVEL}/g" ${LOG4J_CONFIG}
#auto delete script after run once. No need more.
rm -- "$0"
