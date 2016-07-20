# RestComm Load Balancer Docker Image

RestComm is a next generation Cloud Communications Platform to rapidly build voice, video, and messaging applications, using mainstream development skills. Created by the people at Telestax.

Using the RestComm Load Balancer docker image makes running RestComm Load Balancer easy and intuitive and improve the easiness of creating Restcomm Clusters.

It uses the last successful build of the Restcomm Load Balancer project - https://github.com/RestComm/load-balancer

## Environment variables:

### General
1. EXTERNAL_PORT - the SIP port used where clients should connect
2. INTERNAL_PORT - the SIP port used where restcomm instances should connect
2. INTERFACE - Interface to be used from LB. If not set "eth0" will be used. (optional).
3. HOST_ADDRESS - (optional) bind address for app. 
4. LOG_LEVEL - log level for app
5. CONFIG_URL - remote config url for app. Will be downloaded before start. Previous variables will be applied to it too
6. AMAZON_EC2 - if **true**, script configures PUBLIC_IP automatically 

### Configure java options
7. PROD_MODE - if **true**, script configures additional `java options`
8. JAVA_XMS - override `Xms`, default 2048m
9. JAVA_XMX - override `Xmx`, default 2048m
10. JAVA_PERM_SIZE - override `PermSize`, default 512m
11. JAVA_MAX_PERM_SIZE - override `MaxPermSize`, default 1024m
12. JAVA_OPTS - override `java options` at all

### Config file:
By default app uses config file from docker container. Config file are localted by path `/opt/loadbalancer/config`. In the user guide  you can see how to configurate load balancer through config file - 
[Restcomm Load Balancer User Guide](https://mobicents.ci.cloudbees.com/job/Restcomm-LoadBalancer/lastSuccessfulBuild/artifact/documentation/html-book/Load_Balancer_User_Guide.html)

Also you have 2 additional ways to specify config file:

1. use CONFIG_URL: config file will be downloaded and processed on start 
2. attach volume with config: `-v $PWD/config-lb-dir:/opt/loadbalancer/config`

### Test :

1. Launch Docker Restcomm Load Balancer with command ```docker run --name=lb restcomm/load-balancer:latest```
2. Check the host address from the logs ```Setup host: 172.17.0.14```
3. Launch Docker Restcomm Core with command ```docker run -i --name=restcomm-lb -v /var/log/restcomm/:/var/log/restcomm/ -e STATIC_ADDRESS=192.168.1.12 -e USE_STANDARD_PORTS=false -e LOAD_BALANCERS=172.17.0.14 -e CONFIG_URL="https://raw.githubusercontent.com/RestComm/Restcomm-Docker/master/scripts/restcomm_env_locally.sh" -p 80:80 -p 443:443 -p 9990:9990 -p 5060:5060 -p 5061:5061 -p 5062:5062 -p 5063:5063 -p 5060:5060/udp -p 65000-65050:65000-65050/udp restcomm/restcomm:lb```
4. Register your Jitsi SIP client to use host address of the LB (ie 172.17.0.14 and port 5060 here) and place a call to sip:+1234@172.17.0.14
