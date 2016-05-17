FROM phusion/baseimage:latest

MAINTAINER George Vagenas - gvagenas@telestax.com
MAINTAINER Jean Deruelle - jean.deruelle@telestax.com
MAINTAINER Lefteris Banos - liblefty@telestax.com
MAINTAINER Gennadiy Dubina - gennadiy.dubina@dataart.com

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

### install java and etc ###
ENV DEBIAN_FRONTEND noninteractive
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
RUN locale-gen en_US en_US.UTF-8 && dpkg-reconfigure locales

RUN add-apt-repository ppa:webupd8team/java -y
RUN apt-get update && apt-get install -y wget ipcalc bsdtar oracle-java8-installer openssl unzip tcpdump && apt-get autoremove && apt-get autoclean && rm -rf /var/lib/apt/lists/*
### end ###

# create work dir
ENV LOADER_BALANCER_DIR /opt/loadbalancer
ENV LOADER_BALANCER_CONFIG /opt/loadbalancer/config/lb-configuration.properties
ENV LOG4J_CONFIG ${LOADER_BALANCER_DIR}/lb-log4j.xml

RUN mkdir -p ${LOADER_BALANCER_DIR}
RUN mkdir -p ${LOADER_BALANCER_DIR}/utils
RUN mkdir -p ${LOADER_BALANCER_DIR}/config

#RUN wget -qO- https://mobicents.ci.cloudbees.com/view/RestComm/job/RestComm-LoadBalancer/lastSuccessfulBuild/artifact/load-balancer-version.txt -O version.txt
#RUN wget -qc  https://mobicents.ci.cloudbees.com/view/RestComm/job/RestComm-LoadBalancer/lastSuccessfulBuild/artifact/jar/target/sip-balancer-jar-`cat version.txt`-jar-with-dependencies.jar -O ${LOADER_BALANCER_DIR}/sip-balancer.jar && mv version.txt ${LOADER_BALANCER_DIR}

RUN wget -qO- https://mobicents.ci.cloudbees.com/view/RestComm/job/RestComm-LoadBalancer/38/artifact/load-balancer-version.txt -O version.txt
RUN wget -qc  https://mobicents.ci.cloudbees.com/view/RestComm/job/RestComm-LoadBalancer/38/artifact/jar/target/sip-balancer-jar-`cat version.txt`-jar-with-dependencies.jar -O ${LOADER_BALANCER_DIR}/sip-balancer.jar && mv version.txt ${LOADER_BALANCER_DIR}

# copy loadbalancer files
ADD ./files/lb-configuration.properties ${LOADER_BALANCER_CONFIG}
ADD ./files/keystore ${LOADER_BALANCER_DIR}/config/keystore
ADD ./files/utils/read-network-props.sh ${LOADER_BALANCER_DIR}/utils/read-network-props.sh
ADD ./files/lb-log4j.xml ${LOG4J_CONFIG}

# add configuration scripts
RUN mkdir -p /etc/my_init.d
ADD ./scripts/remote_config_downloader.sh /etc/my_init.d/loadbalancer1_remote.sh
ADD ./scripts/configure_load_balancer.sh /etc/my_init.d/loadbalancer2_configure.sh

# create start script
ENV service_path /etc/service/loadbalancer
RUN mkdir ${service_path}
ADD ./files/start_loadbalancer.sh ${service_path}/run

# expose default rmi ports
EXPOSE 2000/tcp
EXPOSE 2001/tcp
