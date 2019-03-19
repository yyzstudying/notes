#!/bin/bash

function info(){
    echo "[INFO] $(date "+%Y-%m-%d %H:%M:%S") $1"
}

function error(){
    echo "[ERROR] $(date "+%Y-%m-%d %H:%M:%S") $1"
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

function mkdirs(){

    if [[ ! -d $1 ]];then mkdir -p $1; fi
}

function rmdirs(){

    rm -rf $1
}

function check(){

    if [ $? -ne 0 ];then finish 2 "$1" ;fi
}

function checkFile(){

    if [ ! -f $1 ];then finish 3 "$1 file not exist"; fi
}

function checkMd5(){

    info "正在校验$1 的md5"

    checkFile $1
    checkFile $2

    md5=$(md5sum $1 | awk '{print $1}')

    if [[ "$md5" != "$(cat $2)" ]];then finish 1 "${1##*/} md5 not match" ;fi

    info "校验md5成功:$md5"
}

function getPackage(){

    version=$(xmllint --xpath "string(//platform/components/component[@name='$1']/@version)" $VERSION_FILE)
    package=${component}-${version}.$2

    echo $package
}