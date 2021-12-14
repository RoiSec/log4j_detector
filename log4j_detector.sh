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
check_variables

    # for containerId in $(docker ps -q)
    # do
    #     docker exec -it $containerId bash -c 'cd /var/www/html && git pull'
    # done