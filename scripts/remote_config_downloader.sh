#!/bin/bash

echo "Remote config downloader"

function download_conf(){
echo "url $1 $2 $3"
if [[ `wget -S --spider $1 $2 $3 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then
               if [ -n "$2" ] && [ -n "$3" ]; then
                    wget $1 $2 $3 -O $4
               else
                    wget $1 -O $2
                fi
                return 0;
        else
                echo "false"
                exit 1;
  fi
}

if [ -n "$CONFIG_URL" ]; then
  echo "Load file by url: ${CONFIG_URL}"
  if [ -n "$REPOUSR" ]  &&  [ -n "$REPOPWRD" ]; then
  		USR="--user=$REPOUSR"
  		PASS="--password=$REPOPWRD"
  fi
   URL="$CONFIG_URL $USR $PASS"
   download_conf $URL $LOADER_BALANCER_CONFIG
fi
#auto delete script after run once. No need more.
rm -- "$0"