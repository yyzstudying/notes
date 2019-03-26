#!/bin/bash

UPGRADE_LOG=/var/log/rcdc/upgrade/upgrade-rcdc-shell.log


function INFO(){
    local msg="$1"
    echo "[`date "+%y-%m-%d %H:%M:%S"`][INFO] $msg "  >> $UPGRADE_LOG
}
function ERROR(){
    local msg="$1"
    echo "[`date "+%y-%m-%d %H:%M:%S"`][ERROR] $msg "  >> $UPGRADE_LOG
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

if [ -z $3 ] ;then
  ERROR "rpm运行路径不能为空"
  exit 1
fi


systemctl stop postgresql-10
CHECK "关闭数据库"

postgresqlFile="/data/postgresql"
if [ -d $postgresqlFile ];then
    rm -rf $postgresqlFile
	CHECK "清空原有数据库"
fi

mkdir -p $postgresqlFile
cp -ax /data/postgresql_$1/. $postgresqlFile
CHECK "恢复数据库"


#rpm安装前的准备工作
if [ `rpm -qa | grep rcos-rcdc | wc -l` -eq 1 ];then
   rpm -e rcos-rcdc
   rm -rf /data/web/rcdc/webapps/*
   INFO "卸载rcos-rcdc"
fi

if [ `rpm -qa | grep rcos-rcdc-upgrade | wc -l` -eq 1 ];then
   rpm -e rcos-rcdc
   rm -rf /data/web/rcdc/webapps/*
   INFO "卸载rcos-rcdc-upgeade"
fi
INFO "开始安装 rcos-rcdc-upgrade-$1.rpm"
rpm -ivh $3/rcos-rcdc-upgrade-$1.rpm >> $UPGRADE_LOG 2>&1
#判断是否安装成功
text_check=`tail -n 1 $UPGRADE_LOG | grep "ERROR" | wc -l`
if [ $text_check -eq 1 ] ;then
   ERROR "rcos-rcdc-upgrade-$1.rpm 安装失败"
fi

text_check=`tail -n 1 $UPGRADE_LOG | grep "failed" | wc -l`
if [ $text_check -eq 1 ] ;then
   ERROR "execute-upgrade-sql.sh脚本执行失败"
fi


systemctl start postgresql-10
if [  $? -eq 0 ];then
    printf "success"
else
    ERROR "开启数据库"
    exit 1
fi




