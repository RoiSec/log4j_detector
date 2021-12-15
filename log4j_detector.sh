#!/bin/bash

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
check_container () {
    for containerId in $(docker ps -q)
    do
        echo "Image Name:" ;docker ps  -f "id=$containerId" --format '{{.Image}}'
        docker exec $containerId sh -c 'wget -qO - https://raw.githubusercontent.com/RoiSec/log4j_detector/main/log4j_detector.sh | sh'
    done
}
check_variables
if  docker info > /dev/null 2>&1; then
    check_container
fi
check_jar(){
    echo "checking jars"
    jars=("$@")
    wget https://github.com/logpresso/CVE-2021-44228-Scanner/releases/download/v1.5.0/logpresso-log4j2-scan-1.5.0.jar
        for index in "${!jars[@]}"
        do 
            jar=${jars[$index]}
            echo $jar
            FILE=$jar
            if [ -f "$FILE" ]; then
                echo "$FILE exists. Scan the jar file"
                java -jar logpresso-log4j2-scan-1.5.0.jar $FILE
                else
                echo "$FILE File not exists."
                
            fi
            
        
        done
    rm ./logpresso-log4j2-scan-1.5.0.jar
}
check_jar "$@" #input array from client