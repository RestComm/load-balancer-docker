# RestComm Load Balancer Docker Image

RestComm is a next generation Cloud Communications Platform to rapidly build voice, video, and messaging applications, using mainstream development skills. Created by the people at Telestax.

Using the RestComm Load Balancer docker image makes running RestComm Load Balancer easy and intuitive and improve the easiness of creating Restcomm Clusters.

It uses the last successful build of the Restcomm Load Balancer project - https://github.com/RestComm/load-balancer

### Environment variables:
1. EXTERNAL_PORT - the SIP port used where clients should connect
2. INTERNAL_PORT - the SIP port used where restcomm instances should connect
3. HOST_ADDRESS - (optional) bind address for app. 
4. LOG_LEVEL - log level for app
5. CONFIG_URL - remote config url for app. Will be downloaded before start. Previous variables will be applied to it too

### Config file:
By default app uses config file from docker container. Config file are localted by path `/opt/loadbalancer/config`

Also you have 2 additional ways to specify config file:

1. use CONFIG_URL: config file will be downloaded and processed on start 
2. attach volume with config: `-v $PWD/config-lb-dir:/opt/loadbalancer/config`
