#!/bin/bash


function INFO(){
    local msg="$1"
    echo "[`date "+%y-%m-%d %H:%M:%S"`][INFO] $msg "  >> /var/log/rcdc/upgrade/upgrade-rcdc-shell.log
}

INFO "执行$0成功"

printf "success"