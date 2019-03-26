#!/bin/bash

configFile="/data/web/config"
shellFile="/data/web/rcdc/shell"
postgresqlFile="/data/postgresql"
frontendFile="/data/web/rcdc/webapps/rcdc-rco-module-frontend"
backendFile="/data/web/rcdc/webapps/rcdc-rco-module-deploy"
VersionDbFile="/opt/upgrade/app/temp/bak/rcdc/version_db/version-db.properties"
version_db_file="/data/web/rcdc"

UPGRADE_LOG=/var/log/rcdc/upgrade/upgrade-rcdc-shell.log

SQLSHELLFILE=/data/web/rcdc/webapps/shell_and_sql


function INFO(){
    local msg="$1"
    echo "[`date "+%y-%m-%d %H:%M:%S"`][INFO] $msg "  >> $UPGRADE_LOG
}
function ERROR(){
    local msg="$1"
    echo "[`date "+%y-%m-%d %H:%M:%S"`][ERROR] $msg " >> $UPGRADE_LOG
	exit 1
}

function CHECK(){
   if [  $? -eq 0 ];then
      INFO "$1成功"
	else
	  ERROR "$1失败"
	  exit 1
   fi
}
INFO "开始执行$0脚本"


if [ -z $1 ] ;then
  ERROR "升级版本参数不能为空"
  exit 1
fi

systemctl stop postgresql-10
CHECK "关闭数据库"

for filePath in $postgresqlFile $frontendFile $backendFile $configFile $shellFile $SQLSHELLFILE
do
    if [ -d $filePath ];then
        rm -rf $filePath
    fi
done

if [ -e $version_db_file/version-db.properties ];then
   rm -rf $version_db_file/version-db.properties
fi
 

mkdir -p $postgresqlFile $frontendFile $backendFile $configFile $shellFile

cp -ax  /data/postgresql_$1/. $postgresqlFile
CHECK "还原数据库"
cp -ax /opt/upgrade/app/temp/bak/rcdc/rcdc-rco-module-frontend/. $frontendFile
CHECK "还原frontend"
cp -ax /opt/upgrade/app/temp/bak/rcdc/rcdc-rco-module-deploy/. $backendFile
CHECK "还原deploy"
cp -ax /opt/upgrade/app/temp/bak/rcdc/shell/. $shellFile
CHECK "还原shell"
cp -ax /opt/upgrade/app/temp/bak/rcdc/config/. $configFile
CHECK "还原config"
cp -ax $VersionDbFile $version_db_file
CHECK "还原version-db.properties"

systemctl start postgresql-10
if [  $? -eq 0 ];then
    printf "success"
else
    ERROR "开启数据库失败"
	exit 1
fi



