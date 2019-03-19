#!/bin/bash

function info(){
    echo "[INFO] $(date "+%Y-%m-%d %H:%M:%S") $1"
}

function error(){
    echo "[ERROR] $(date "+%Y-%m-%d %H:%M:%S") $1"
}
function mkdirs(){

    if [[ ! -d $1 ]];then 
	  mkdir -p $1; 
	else 
	  rm -rf $1/*
	fi
}

function getVersion(){

    version=$(xmllint --xpath "string(//platform/components/component[@name='$1']/@version)" $VERSION_FILE)

    echo $version
}


function finish(){

    echo "{" > $LOG_RESULT
    echo "\"status\":\"$1\"", >> $LOG_RESULT
    echo "\"taking\":\"$[ $(date +%s)-$TIME ]\"", >> $LOG_RESULT
    echo "\"message\":\"$2\"" >> $LOG_RESULT
    echo "}" >> $LOG_RESULT

    if [[ $1 == 0 ]] ;then
        info "$2" >> $LOG_BUILD
    else
        error "$2" >> $LOG_BUILD
    fi

    exit $1
}


