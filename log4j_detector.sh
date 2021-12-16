#!/bin/sh
#ddd
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
    if ! command -v curl 2> /dev/null
    then
        wget 'https://raw.githubusercontent.com/RoiSec/log4j_detector/main/logpresso/logpresso-log4j2-scan-1.6.3.jar' --no-check-certificate -q -O '/tmp/logpresso-log4j2-scan-1.6.3.jar' 2>/dev/null
    else
        curl -s 'https://raw.githubusercontent.com/RoiSec/log4j_detector/main/logpresso/logpresso-log4j2-scan-1.6.3.jar' -o '/tmp/logpresso-log4j2-scan-1.6.3.jar' 2>/dev/null
    fi
    FILE=$1
    java_path=$(find /usr/ /bin/ -name java -type f -perm /a+x 2>/dev/null | head -n 1)
    # echo $java_path
    eval $java_path -jar /tmp/logpresso-log4j2-scan-1.6.3.jar $FILE >>/tmp/out.txt 2>/dev/null
    grep -i 'Found CVE-2021-44228' /tmp/out.txt 2>/dev/null
    rm /tmp/out.txt 2>/dev/null
        # else
        # echo "$FILE File not exists." 
    rm /tmp/logpresso-log4j2-scan-1.6.3.jar 2>/dev/null

}
check_container () {
    jar_paths=$1
    for containerId in $(docker ps -q)
    do
        echo -n "Image Name: " ;docker ps  -f "id=$containerId" --format '{{.Image}}'
        docker exec -i $containerId sh -c 'wget https://raw.githubusercontent.com/RoiSec/log4j_detector/main/log4j_detector.sh -q --no-check-certificate -O /tmp/log4j_detector.sh' 2>/dev/null
        docker exec -i $containerId sh -c 'curl -s https://raw.githubusercontent.com/RoiSec/log4j_detector/main/log4j_detector.sh -o /tmp/log4j_detector.sh' 2>/dev/null
        docker exec -i $containerId sh -c 'chmod +x /tmp/log4j_detector.sh'
        # cmd="./log4j_detector.sh ${jar_paths}"
        # echo $cmd
        docker exec -i $containerId sh -c "/tmp/log4j_detector.sh $jar_paths"
        docker exec -i $containerId sh -c  'rm /tmp/log4j_detector.sh'
        echo ""
    done
}


check_variables
check_jar "$1" #array argument from client
if  docker info > /dev/null 2>&1; then
    check_container "$1"
fi
