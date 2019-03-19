#!/bin/bash

if [ -z $1 ] ;then
  printf "upgradeVersion can not be empty"
  exit
fi

frontendFile="/opt/upgrade/app/temp/bak/rcdc/rcdc-rco-module-frontend"
backendFile="/opt/upgrade/app/temp/bak/rcdc/rcdc-rco-module-deploy"
configFile="/opt/upgrade/app/temp/bak/rcdc/config"
shellFile="/opt/upgrade/app/temp/bak/rcdc/shell"

for filePath in  $frontendFile $backendFile $configFile $shellFile
do
    if [ -d $filePath ];then
        rm -rf $filePath
    fi
done

systemctl stop postgresql-10
if [  $? -ne 0 ];then
    printf "error:stop postgresql-10 "
    exit
fi

find /data/  -regex  "/data/postgresql_[0-9]+\.[0-9]+\.[0-9]+.?" -type d |xargs rm -rf

mkdir -p /data/postgresql_$1 $frontendFile $backendFile $configFile $shellFile

cp -ax /data/postgresql/. /data/postgresql_$1

cp -ax /data/web/rcdc/webapps/rcdc-rco-module-frontend/. $frontendFile

cp -ax /data/web/rcdc/webapps/rcdc-rco-module-deploy/. $backendFile

cp -ax /data/web/config/. $configFile

cp -ax /data/web/rcdc/shell/. $shellFile

systemctl start postgresql-10
if [  $? -eq 0 ];then
    printf "success"
else
    printf "error:start postgresql-10 "
    exit
fi
