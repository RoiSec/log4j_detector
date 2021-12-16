#!/bin/sh
if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit
fi
check_variables () {
    if [ -z ${LOG4J_FORMAT_MSG_NO_LOOKUPS} ]; then
    echo "Enviroment Variable Not Found!"
    else
    echo "LOG4J_FORMAT_MSG_NO_LOOKUPS enviroment variable found!"
    fi

    proc=$(ps -ef | grep java | grep -v grep)
    result=$(ps -ef | grep java | grep -v grep | grep log4j2.formatMsgNoLookups=true | wc -l)
    # echo "Found java procces: " $proc
    if [ $((result)) -eq 0 ]; then
            echo "Java Flag Not Found!"
    else
            echo "Found Java Flag!"
    fi
}
check_jar(){
    # echo "Checking jars"
    if ! command -v curl &> /dev/null
    then
        wget 'https://raw.githubusercontent.com/RoiSec/log4j_detector/main/logpresso/logpresso-log4j2-scan-1.6.3.jar' -q
    else
        curl -s 'https://raw.githubusercontent.com/RoiSec/log4j_detector/main/logpresso/logpresso-log4j2-scan-1.6.3.jar' -o 'logpresso-log4j2-scan-1.6.3.jar'
    fi
    FILE=$1
    java -jar logpresso-log4j2-scan-1.6.3.jar $FILE >>out.txt
    grep -i 'Found CVE-2021-44228' out.txt 2>/dev/null
    rm out.txt 2>/dev/null
        # else
        # echo "$FILE File not exists."
    rm logpresso-log4j2-scan-1.6.3.jar 2>/dev/null

}

check_container () {
    jar_paths=$1
    for containerId in $(docker ps -q)
    do
        echo "Image Name:" ;docker ps  -f "id=$containerId" --format '{{.Image}}'
        if ! $(docker exec -i $containerId sh -c 'command -v curl 2>&1 ') &> /dev/null
        then
            docker exec -i $containerId sh -c 'curl -s https://raw.githubusercontent.com/RoiSec/log4j_detector/main/log4j_detector.sh' > 'log4j_detector.sh'
        else
            docker exec -i $containerId sh -c 'wget https://raw.githubusercontent.com/RoiSec/log4j_detector/main/log4j_detector.sh -q'
        fi
        docker exec -i $containerId sh -c 'chmod +x ./log4j_detector.sh'
        cmd="./log4j_detector.sh ${jar_paths}"
        # echo $cmd
        docker exec -i $containerId sh -c "./log4j_detector.sh $jar_paths"
        docker exec -i $containerId sh -c  'rm ./log4j_detector.sh'
    done
}
check_variables
check_jar "$1" #array argument from client
if  docker info > /dev/null 2>&1; then
    check_container "$1"

fi
