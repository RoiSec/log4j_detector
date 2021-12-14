#!/bin/bash
check_variables () {
if [ -z ${LOG4J_FORMAT_MSG_NO_LOOKUPS} ]; then
  echo "No Enviroment Variable Found"
else
  echo "LOG4J_FORMAT_MSG_NO_LOOKUPS enviroment variable found!"
fi

proc=$(ps -ef | grep java | grep -v grep)
result=$(ps -ef | grep java | grep -v grep | grep log4j2.formatMsgNoLookups=true | wc -l)
# echo "Found java procces: " $proc
if [ $((result)) -eq 0 ]; then
        echo "Not Found java System property!"
else
        echo "Found java System property!"
fi
}

check_container () {
    for containerId in $(docker ps -q)
    do
        echo "Image Name:" ;docker ps  -f "id=$containerId" | awk '{print $2}' | grep /
        docker exec -t $containerId sh -c 'wget -qO - https://raw.githubusercontent.com/RoiSec/log4j_detector/main/log4j_detector.sh | sh'
    done
}

if  docker info > /dev/null 2>&1; then
    check_container
fi
