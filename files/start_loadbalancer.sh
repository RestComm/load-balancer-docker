#!/bin/bash

java -DlogLevel=${LOG_LEVEL} -jar ${LOADER_BALANCER_DIR}/sip-balancer.jar -mobicents-balancer-config=${LOADER_BALANCER_CONFIG}
