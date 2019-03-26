#!/bin/bash



frontendFile="/opt/upgrade/app/temp/bak/rcdc/rcdc-rco-module-frontend"
backendFile="/opt/upgrade/app/temp/bak/rcdc/rcdc-rco-module-deploy"
configFile="/opt/upgrade/app/temp/bak/rcdc/config"
shellFile="/opt/upgrade/app/temp/bak/rcdc/shell"
VersionDbFile="/opt/upgrade/app/temp/bak/rcdc/version_db"
version_db_file="/data/web/rcdc/version-db.properties"
UPGRADE_LOG=/var/log/rcdc/upgrade/upgrade-rcdc-shell.log



function INFO(){
    local msg="$1"
    echo "[`date "+%y-%m-%d %H:%M:%S"`][INFO] $msg "  >> $UPGRADE_LOG
}
function ERROR(){
    local msg="$1"
    echo "[`date "+%y-%m-%d %H:%M:%S"`][ERROR] $msg " >> tee -a $UPGRADE_LOG
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
  exit
fi


for filePath in  $frontendFile $backendFile $configFile $shellFile $VersionDbFile
do
    if [ -d $filePath ];then
        rm -rf $filePath
    fi
done

if [ ! -e $version_db_file ];then
  ERROR "$version_db_file 不存在"
fi



systemctl stop postgresql-10
if [  $? -ne 0 ];then
    printf "error:stop postgresql-10 "
    exit
fi

find /data/  -regex  "/data/postgresql_[0-9]+\.[0-9]+\.[0-9]+.?" -type d |xargs rm -rf

mkdir -p /data/postgresql_$1 $frontendFile $backendFile $configFile $shellFile $VersionDbFile

cp -ax /data/postgresql/. /data/postgresql_$1
CHECK "备份数据库"
cp -ax /data/web/rcdc/webapps/rcdc-rco-module-frontend/. $frontendFile
CHECK "备份rcdc-rco-module-frontend"
cp -ax /data/web/rcdc/webapps/rcdc-rco-module-deploy/. $backendFile
CHECK "备份rcdc-rco-module-deploy"
cp -ax /data/web/config/. $configFile
CHECK "备份config"
cp -ax /data/web/rcdc/shell/. $shellFile
CHECK "备份shell"
cp -ax $version_db_file $VersionDbFile
CHECK "备份version-db.properties"

systemctl start postgresql-10
if [  $? -eq 0 ];then
    printf "success"
else
    ERROR "开启数据库失败"
    exit 1
fi
