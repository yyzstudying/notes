#!/bin/bash

if [ -z $1 ] ;then
  printf "upgradeVersion can not be empty"
  exit
fi

systemctl stop postgresql-10
if [  $? -ne 0 ];then
    printf "error:stop postgresql-10 "
    exit
fi

configFile="/data/web/config"
shellFile="/data/web/rcdc/shell"
postgresqlFile="/data/postgresql"
frontendFile="/data/web/rcdc/webapps/rcdc-rco-module-frontend"
backendFile="/data/web/rcdc/webapps/rcdc-rco-module-deploy"

for filePath in $postgresqlFile $frontendFile $backendFile $configFile $shellFile
do
    if [ -d $filePath ];then
        rm -rf $filePath
    fi
done

mkdir -p $postgresqlFile $frontendFile $backendFile $configFile $shellFile

cp -ax  /data/postgresql_$1/. $postgresqlFile

cp -ax /opt/upgrade/app/temp/bak/rcdc/rcdc-rco-module-frontend/. $frontendFile

cp -ax /opt/upgrade/app/temp/bak/rcdc/rcdc-rco-module-deploy/. $backendFile

cp -ax /opt/upgrade/app/temp/bak/rcdc/shell/. $shellFile

cp -ax /opt/upgrade/app/temp/bak/rcdc/config/. $configFile

systemctl start postgresql-10
if [  $? -eq 0 ];then
    printf "success"
else
    printf "error:start postgresql-10 "
    exit
fi



