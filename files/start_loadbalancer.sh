#!/bin/bash

LB_JAVA_OPT=''

if [ "${PROD_MODE^^}" = "TRUE" ]; then
    LB_JAVA_OPT='-Xms2048m -Xmx2048m -XX:PermSize=512M -XX:MaxPermSize=1024M -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalMode -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.local.only=false'
fi

java $LB_JAVA_OPT -DlogConfigFile=${LOADER_BALANCER_DIR}/lb-log4j.xml -DlogLevel=${LOG_LEVEL} -jar ${LOADER_BALANCER_DIR}/sip-balancer.jar -mobicents-balancer-config=${LOADER_BALANCER_CONFIG}
