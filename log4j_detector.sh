#!/bin/sh
#sssss
if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit
fi
check_variables () {
    if [ -z ${LOG4J_FORMAT_MSG_NO_LOOKUPS} ]; then
    echo "Not Enviroment Variable Found!"
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
check_jar(){
    echo "Checking jars"
    wget 'https://github.com/logpresso/CVE-2021-44228-Scanner/releases/download/v1.5.0/logpresso-log4j2-scan-1.5.0.jar' -q
    FILE=$1
    if [ -f "$FILE" ]; then
        java -jar logpresso-log4j2-scan-1.5.0.jar $FILE >>out.txt  2>&1
        else
        echo "$FILE File not exists."         
    fi
    grep -i 'Found CVE-2021-44228' out.txt
    rm ./logpresso-log4j2-scan-1.5.0.jar out.txt
}

check_container () {
    for containerId in $(docker ps -q)
    do
        echo "Image Name:" ;docker ps  -f "id=$containerId" --format '{{.Image}}'
        docker exec $containerId sh -c 'wget https://raw.githubusercontent.com/RoiSec/log4j_detector/main/log4j_detector.sh -q'
        docker exec $containerId sh -c 'chmod +x log4j_detector.sh'
        jar_paths=$@
        cmd="./log4j_detector.sh ${jar_paths}"
        echo $cmd
        docker exec $containerId sh -c '$cmd'
        docker exec $containerId sh -c  'rm ./log4j_detector.sh'
    done
}
check_variables
check_jar "$1" #array argument from client
if  docker info > /dev/null 2>&1; then
    check_container "$1"
fi
