#!/bin/bash

if [ -z "${JAVA_XMS}" ]; then
    JAVA_XMS='2048m'
fi

if [ -z "${JAVA_XMX}" ]; then
    JAVA_XMX='2048m'
fi

if [ -z "${JAVA_PERM_SIZE}" ]; then
    JAVA_PERM_SIZE='512m'
fi

if [ -z "${JAVA_MAX_PERM_SIZE}" ]; then
    JAVA_MAX_PERM_SIZE='1024m'
fi

if [ -z "$JAVA_OPTS" ] && [ "${PROD_MODE^^}" = "TRUE" ]; then
    JAVA_OPTS="-Xms${JAVA_XMS} -Xmx${JAVA_XMX} -XX:PermSize=${JAVA_PERM_SIZE} -XX:MaxPermSize=${JAVA_MAX_PERM_SIZE} -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalMode -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.local.only=false"
fi

java $JAVA_OPTS -DlogConfigFile=${LOADER_BALANCER_DIR}/lb-log4j.xml -DlogLevel=${LOG_LEVEL} -jar ${LOADER_BALANCER_DIR}/sip-balancer.jar -mobicents-balancer-config=${LOADER_BALANCER_CONFIG}
