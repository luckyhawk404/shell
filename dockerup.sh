#!/usr/bin/env bash

typeset ALL_CONTAINERS=$( mktemp )
typeset CONTAINERS_NAMES=$( mktemp )
INIT_FILE='/etc/init/docker-containers.conf'
trap "rm -f ${ALL_CONTAINERS} ${CONTAINERS_NAMES}" SIGINT SIGKILL SIGQUIT SIGSEGV SIGPIPE SIGALRM SIGTERM EXIT


function ERROR() {
    printf $KRED"ERROR: "$KNRM 
    printf "%s " "$@" 
    printf "\n"
    exit 1
}

function OK() {
    printf $KGRN"OK: "$KNRM  
    printf "%s " "[ $@ ]" 
    printf "\n"
}


function CHECK_EXISTINGS(){
    if [ -f $INIT_FILE ]
        then
            ERROR 'FILE EXIST, EXIT'
    fi
}

function GET_DOCKER_CONTAINERS(){
    docker ps -a | grep 'weeks ago' | awk '{print $1}' | xargs --no-run-if-empty docker rm $(docker ps -a -q)
    docker ps -a > $ALL_CONTAINERS
    cat $ALL_CONTAINERS | awk '{print $NF}' | egrep -v '(deploy|NAMES)' > $CONTAINERS_NAMES
    sed -e 's/^/\/usr\/bin\/docker start /' -i $CONTAINERS_NAMES
}

function ECHO_TO_FILE(){
    echo 'description "Containers"' >> $INIT_FILE
    echo 'start on filesystem and started docker' >> $INIT_FILE
    echo 'stop on runlevel [!2345]' >> $INIT_FILE
    echo 'respawn' >> $INIT_FILE
    echo 'script' >> $INIT_FILE
    cat $CONTAINERS_NAMES >> $INIT_FILE
    echo 'end script' >> $INIT_FILE
}

CHECK_EXISTINGS
GET_DOCKER_CONTAINERS
ECHO_TO_FILE